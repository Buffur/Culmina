"""Export the current Culmina design sources for the read-only browser catalogue."""
import hashlib
from datetime import datetime, timezone
import json
import pathlib
import re
import subprocess

LAB = pathlib.Path(__file__).resolve().parents[1]
REPO = LAB.parents[1]


def clean(text):
    return re.sub(r'//[^\n]*', '', text)


def delimited(text, start, opening='(', closing=')'):
    depth = 1
    for index in range(start, len(text)):
        depth += (text[index] == opening) - (text[index] == closing)
        if depth == 0:
            return text[start:index]
    raise ValueError('Unbalanced source expression')


def parts(text):
    result, current, depth = [], '', 0
    for char in text:
        if char in '([{':
            depth += 1
        elif char in ')]}':
            depth -= 1
        if char == ',' and depth == 0:
            if current.strip():
                result.append(current.strip())
            current = ''
        else:
            current += char
    if current.strip():
        result.append(current.strip())
    return result


def call(text, pattern):
    match = re.search(pattern, text)
    if not match:
        raise ValueError(f'Missing source construct: {pattern}')
    return {key.strip(): value.strip() for key, value in
            (part.split(':', 1) for part in parts(delimited(text, match.end())))}


def main():
    theme_paths = list((REPO / 'lib/core/theme').glob('*.dart'))
    paths = [REPO / 'docs/DESIGN_SYSTEM.md', *theme_paths]
    shared = ['status_block.dart', 'plan_state.dart', 'change_mark.dart', 'collapsible_section.dart',
              'context_line.dart', 'detail_scaffold.dart', 'confirmation_patterns.dart',
              'delete_patterns.dart', 'startup_mark.dart', 'app_words.dart']
    paths += [REPO / 'lib/presentation/shared' / name for name in shared]
    paths += [REPO / 'lib/presentation/screens/tonight/tonight_home_screen.dart',
              REPO / 'lib/presentation/navigation/app_shell.dart']
    sources = [{'path': path.relative_to(REPO).as_posix(),
                'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                'content': path.read_text(encoding='utf-8')} for path in paths]
    by_name = {pathlib.Path(item['path']).name: item['content'] for item in sources}
    colors = dict(re.findall(r'static const Color (\w+) = Color\(0x([A-Fa-f\d]{8})\)', by_name['app_colors.dart']))
    palette_text = clean(by_name['app_palette.dart'])
    named = {}
    flutter_root = pathlib.Path('C:/flutter/packages/flutter/lib/src')
    for path in [flutter_root / 'material/colors.dart', flutter_root / 'painting/colors.dart']:
        text = clean(path.read_text(encoding='utf-8'))
        literals = dict(re.findall(r'static const (?:int|Color) (\w+) = (?:Color\()?0x([A-Fa-f\d]{8})', text))
        named.update(literals)
        for name, expr in re.findall(r'static const (?:MaterialColor|MaterialAccentColor) (\w+) = (?:MaterialColor|MaterialAccentColor)\(\s*(0x[A-Fa-f\d]{8}|_\w+)', text):
            named[name] = expr[2:] if expr.startswith('0x') else literals[expr]
    aliases = dict(re.findall(r'static const (_\w+) = (Color\(0x[A-Fa-f\d]{8}\))', palette_text))
    for match in re.finditer(r'static const (_\w+) = \[', palette_text):
        aliases[match[1]] = '[' + delimited(palette_text, match.end(), '[', ']') + ']'

    def resolve(expr):
        expr = expr.strip()
        if expr.startswith('['):
            return [resolve(value) for value in parts(expr[1:-1])]
        if expr in aliases:
            return resolve(aliases[expr])
        argb = None
        if expr.startswith('AppColors.'):
            argb = colors[expr.split('.')[1]]
        elif expr.startswith('Colors.'):
            argb = named[expr.split('.')[1]]
        else:
            match = re.fullmatch(r'Color\(0x([A-Fa-f\d]{8})\)', expr)
            if match:
                argb = match[1]
        if argb is None:
            return {'expression': expr, 'css': None}
        argb = argb.upper()
        css = '#' + argb[2:] + (argb[:2] if argb[:2] != 'FF' else '')
        return {'expression': expr, 'argb': '#' + argb, 'css': css}

    palette = {theme: {key: resolve(value) for key, value in
                      call(palette_text, rf'static const {theme} = AppPalette\(').items()}
               for theme in ['light', 'dark', 'field']}
    theme_text = clean(by_name['app_theme.dart'])
    schemes = {}
    for mode in ['light', 'dark', 'field']:
        pattern = rf'colorScheme: const ColorScheme\.{mode}\(' if mode != 'field' else r'static const ColorScheme fieldColorScheme = ColorScheme\('
        schemes[mode] = {key: resolve(value) for key, value in call(theme_text, pattern).items() if key != 'brightness'}
    scale = [{'role': role, 'size': int(size), 'line': int(line), 'weight': int(weight)}
             for role, size, line, weight in re.findall(r'(\w+): _style\((\d+), (\d+), FontWeight.w(\d+)\)', by_name['app_typography.dart'])]
    scalar = lambda name: [{'name': key, 'value': float(value)} for key, value in
                           re.findall(r'static const double (\w+) = ([\d.]+);', by_name[name])]
    motion = {key: int(value) for key, value in re.findall(r'static const Duration (\w+) = Duration\(milliseconds: (\d+)\)', by_name['app_motion.dart'])}
    doc = by_name['DESIGN_SYSTEM.md']
    component_text = doc.split('## 7a. Components and patterns', 1)[1].split('## 8.', 1)[0]
    contracts = [{'title': part.split('\n', 1)[0], 'markdown': part.split('\n', 1)[1].strip()}
                 for part in component_text.split('### ')[1:]]
    unresolved = [(theme, role, value) for theme, roles in palette.items() for role, value in roles.items()
                  if isinstance(value, dict) and value.get('css') is None]
    if unresolved or len(scale) != 15:
        raise ValueError(f'Incomplete export: {unresolved}; type roles={len(scale)}')
    inventory = {
        'generatedDate': datetime.now(timezone.utc).date().isoformat(), 'baseline': subprocess.check_output(['git', 'rev-parse', '--short', 'HEAD'], cwd=REPO, text=True).strip(),
        'notice': 'Current local source snapshot, including uncommitted source if present. Production contracts and concept proposals remain separate.',
        'sources': sources, 'rawColors': [{'name': key, **resolve('AppColors.' + key)} for key in colors],
        'palette': palette, 'scheme': schemes, 'typeScale': scale,
        'spacing': scalar('app_spacing.dart'), 'radii': scalar('app_radius.dart'), 'motion': motion,
        'fontFamily': re.search(r"static const _family = '([^']+)'", theme_text)[1],
        'controls': {'minimumWidth': 64, 'minimumHeight': 48, 'iconSize': 24,
                     'pressedOverlay': float(re.search(r'pressedOverlay = ([\d.]+)', theme_text)[1]),
                     'focusOverlay': .12, 'hoverOverlay': .08, 'dividerWidth': 1,
                     'focusBorderWidth': 2, 'bodyMinimum': 12, 'curve': 'easeOutCubic',
                     'appBarTitle': {'size': 18, 'weight': 600}},
        'contracts': contracts,
        'coverage': {'paletteRoles': len(palette['light']), 'typeRoles': len(scale), 'spacingSteps': len(scalar('app_spacing.dart')),
                     'radiusSteps': len(scalar('app_radius.dart')), 'componentContracts': len(contracts), 'sourceFiles': len(sources)}
    }
    (LAB / 'inventory.json').write_text(json.dumps(inventory, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(inventory['coverage']))


if __name__ == '__main__':
    main()
