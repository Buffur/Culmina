"""Generate a local, source-backed design reference without changing app files."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
from html import escape
from datetime import datetime, timezone

OUT = Path(__file__).resolve().parent
ROOT = next(p for p in Path(__file__).resolve().parents if (p/'pubspec.yaml').exists() and (p/'AGENTS.md').exists())
SKILLS = ['components', 'rules', 'spacing', 'tokens', 'typography']
sources = []
paths = [Path('AGENTS.md'), Path('docs/DESIGN_SYSTEM.md'), Path('.agents/skills/references/refinement-decision.md')]
paths += [Path(f'.agents/skills/culmina-design-{name}/SKILL.md') for name in SKILLS]
for name in SKILLS:
    paths += sorted(p.relative_to(ROOT) for p in (ROOT/f'.agents/skills/culmina-design-{name}/references').glob('*.md'))
paths += [Path('lib/core/theme')/name for name in ['app_text_theme.dart','culmina_mark_colors.dart','app_colors.dart','app_palette.dart','hybrid_tokens.dart','app_typography.dart','app_spacing.dart','app_radius.dart','app_motion.dart','app_theme.dart']]
paths += [Path('lib/presentation/shared')/name for name in ['document_section.dart','plan_state.dart','status_block.dart','collapsible_section.dart','context_line.dart','confirmation_patterns.dart']]
paths += [Path('lib/presentation/navigation/app_shell.dart')]
source_dir = OUT/'sources'
source_dir.mkdir(exist_ok=True)
for number, path in enumerate(dict.fromkeys(paths)):
    text = (ROOT/path).read_text(encoding='utf-8')
    category = next((name for name in SKILLS if f'culmina-design-{name}/' in str(path).replace('\\','/')), 'shared')
    filename = f'{number:02d}.html'
    numbered = '\n'.join(f'<div id="L{i}"><a href="#L{i}">{i}</a> {escape(line)}</div>' for i,line in enumerate(text.splitlines(),1))
    (source_dir/filename).write_text(f'<!doctype html><meta charset="utf-8"><title>{escape(str(path))}</title><style>body{{background:#191919;color:#ebebea;font:14px/1.65 monospace;padding:24px}}a{{color:#a5a5a3}}div{{white-space:pre-wrap;overflow-wrap:anywhere}}div:target{{background:#343432}}h1{{font:20px system-ui}}</style><h1>{escape(str(path))}</h1>{numbered}', encoding='utf-8')
    sources.append(dict(path=path.as_posix(),text=text,category=category,href=f'sources/{filename}',sha256=hashlib.sha256(text.encode('utf-8')).hexdigest(),hashKind='UTF-8/LF text'))

colors_text = (ROOT/'lib/core/theme/app_colors.dart').read_text(encoding='utf-8')
raw = dict(re.findall(r'static const Color (\w+) = Color\(0xFF([0-9A-Fa-f]{6})\)', colors_text))
hybrid = (ROOT/'lib/core/theme/hybrid_tokens.dart').read_text(encoding='utf-8')
themes = {}
for theme in ['light','dark','field']:
    block = re.search(r'static const '+theme+r' = HybridTokens\((.*?)\n  \);',hybrid,re.S).group(1)
    values = {name:'#'+value for name,value in re.findall(r'(\w+): Color\(0xFF([0-9A-Fa-f]{6})\)',block)}
    for role in ['Background','Surface','SurfaceRaised','TextPrimary','TextSecondary','TextTertiary','TextDisabled','Border','ControlBorder']:
        values[role[0].lower()+role[1:]] = '#'+raw[theme+role]
    themes[theme] = values
type_text = (ROOT/'lib/core/theme/app_typography.dart').read_text(encoding='utf-8')
types = [dict(name=n,size=float(s),line=float(h),weight=int(w)) for n,s,h,w in re.findall(r'static final TextStyle (\w+) = _style\(\s*([\d.]+),\s*([\d.]+),\s*FontWeight.w(\d+)',type_text)]
types.append(dict(name='navigationLabel',size=11,line=16.5,weight=400))
for role in types:
    declaration=re.search(r'static (?:final|const) TextStyle '+role['name']+r'\s*=(.*?);',type_text,re.S)
    tracking=re.search(r'letterSpacing:\s*([\d.-]+)',declaration.group(1)) if declaration else None
    role['letterSpacing']=float(tracking.group(1)) if tracking else 0
material_block = type_text.split('static final TextTheme scale = TextTheme(')[1]
material = [dict(name=n,size=float(s),line=float(h),weight=int(w)) for n,s,h,w in re.findall(r'(\w+): _style\(([\d.]+), ([\d.]+), FontWeight.w(\d+)\)',material_block)]
spacing = dict((n,float(v)) for n,v in re.findall(r'static const double (\w+) = ([\d.]+)',(ROOT/'lib/core/theme/app_spacing.dart').read_text(encoding='utf-8')))
radii = dict((n,float(v)) for n,v in re.findall(r'static const double (\w+) = ([\d.]+)',(ROOT/'lib/core/theme/app_radius.dart').read_text(encoding='utf-8')))
rules = []
targets = dict(components='components',rules='meaning',spacing='geometry',tokens='palette',typography='type')
for source in sources:
    if source['category'] not in SKILLS:
        continue
    lines = source['text'].splitlines()
    start = lines.index('---',1)+1 if lines and lines[0]=='---' else 0
    paragraph, first = [], 0
    def append_paragraph():
        if paragraph:
            rules.append(dict(category=source['category'],text=' '.join(paragraph),line=first,source=source['href'],demo=targets[source['category']]))
            paragraph.clear()
    for index in range(start,len(lines)):
        line=lines[index].strip()
        if not line or line.startswith('#'):
            append_paragraph()
            continue
        if line.startswith('|'):
            append_paragraph()
            if re.match(r'^\|[\s:|-]+\|$',line) or (index+1<len(lines) and re.match(r'^\|[\s:|-]+\|$',lines[index+1].strip())):
                continue
            rules.append(dict(category=source['category'],text=' · '.join(cell.strip() for cell in line.strip('|').split('|')),line=index+1,source=source['href'],demo=targets[source['category']]))
        elif re.match(r'^(- |\d+\. )',line):
            append_paragraph()
            rules.append(dict(category=source['category'],text=re.sub(r'^(- |\d+\. )','',line),line=index+1,source=source['href'],demo=targets[source['category']]))
        else:
            if not paragraph:
                first=index+1
            paragraph.append(line)
    append_paragraph()
# Preserve every complete canonical source, including paragraphs and tables, not
# only the extracted bullet index. Supplemental sources have their own viewer.
catalog = dict(generatedUtc=datetime.now(timezone.utc).isoformat(),head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),scope='Current working tree; browser specimens are illustrative, not Flutter/native acceptance.',sources=sources,themes=themes,typography=types,materialTypography=material,spacing=spacing,radii=radii,rules=rules)
native_path=ROOT/'design/reference/app-map-20261028/component-manifest.json'
native=json.loads(native_path.read_text(encoding='utf-8'))
catalog['nativeGallery']={
    'source':'../app-map-20261028/component-manifest.json',
    'sha256':hashlib.sha256(native_path.read_bytes()).hexdigest(),
    'head':native['head'],'renderKind':native['renderKind'],
    'inventory':native['inventory'],
    'samples':[dict(id=str(s['id']),theme=s['theme'],label=s['label'],file='../app-map-20261028/'+s['file'],texts=s.get('texts',[])) for s in native['samples'] if s.get('error') is None],
    'science':[dict(id=s['name'],theme=s['theme'],label=s['kind'],file='../app-map-20261028/'+s['file'],texts=[s['name']]) for s in native['science']],
}
(OUT/'catalog.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2),encoding='utf-8')
print(f'Built {len(sources)} source snapshots, {len(rules)} indexed rule statements, {len(types)} named text roles and {len(material)} Material roles.')
import sys
subprocess.run([sys.executable, str(OUT.parent/'style_atlases.py')], check=True, cwd=ROOT)
