"""Builds the identity lab's comparison sheet and SVG masters from geometry.py.

    python design/identity-lab/build.py

Writes design/identity-lab/marks/*.svg and design/identity-lab/index.html
(from report.template.html); `--embed OUT` writes a self-contained copy. Proposals only; nothing is copied into the app.
"""

import base64
import json
from pathlib import Path

from geometry import CONCEPTS, concept_a, svg

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
NAMES = {'current': 'Чинний R3-final', 'A': 'A · Уточнена орбіта',
         'B': 'B · Зоряний трек', 'C': 'C · Проходження меридіана'}
ORDER = ['current', 'A', 'B', 'C']

# Colourways. Hybrid values: lib/core/theme/app_colors.dart and
# hybrid_tokens.dart (light/dark text, background, accent); navy: the current
# mark (AppColors.mark*). Field: AppColors.field* text roles, dimmed.
THEMES = {
    'mono-light': dict(bg='#FFFFFF', orbit='#37352F', inner='#37352F', star='#37352F'),
    'mono-dark': dict(bg='#191919', orbit='#EBEBEA', inner='#EBEBEA', star='#EBEBEA'),
    'navy': dict(bg='#0B1230', orbit='#E6EBF7', inner='#7F8DC0', star='#8CCBFF'),
    'hyb-dark': dict(bg='#191919', orbit='#EBEBEA', inner='#A5A5A3', star='#62AFF3'),
    'hyb-light': dict(bg='#FFFFFF', orbit='#37352F', inner='#6E6D69', star='#0075DE'),
    'field': dict(bg='#000000', orbit='#880000', inner='#660000', star='#AA0000'),
    'themed': dict(bg='#D3E3FD', orbit='#0B3A73', inner='#0B3A73', star='#0B3A73'),
}

VISIBLE = '18 18 72 72'   # the launcher's visible area
INK = '22 22 64 64'       # the mark's own extent, for glyphs and lockups


def theme_css():
    out = []
    for k, v in THEMES.items():
        out.append(f'.t-{k}{{' + ';'.join(f'--{n}:{c}' for n, c in v.items()) + '}')
    return '\n'.join(out)


def icon(shapes, theme, px, shape='round'):
    clip = {'round': 'circle(50%)', 'squircle': 'inset(0 round 22.4%)',
            'square': 'none'}[shape]
    return (f'<span class="ic t-{theme}" style="width:{px}px;height:{px}px;'
            f'clip-path:{clip}">{svg(shapes, view=VISIBLE, bg=True)}</span>')


def glyph(shapes, theme, px):
    return (f'<span class="gl t-{theme}" style="width:{px}px;height:{px}px">'
            f'{svg(shapes, view=INK, bg=False)}</span>')


def standalone(shapes, theme):
    v = THEMES[theme]
    style = '<style>' + ':root{' + ';'.join(f'--{n}:{c}' for n, c in v.items()) + '}</style>'
    return ('<?xml version="1.0" encoding="utf-8"?>\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108" width="108" height="108">'
            f'{style}<rect width="108" height="108" fill="{v["bg"]}"/>{shapes}</svg>\n')


def cell(label, body):
    return f'<figure class="cell"><div class="cv">{body}</div><figcaption>{label}</figcaption></figure>'


def section_large():
    rows = []
    for k in ORDER:
        s = CONCEPTS[k]()
        rows.append(f'<div class="cmp"><h4>{NAMES[k]}</h4><div class="pair">'
                    f'{glyph(s, "mono-light", 132)}{glyph(s, "mono-dark", 132)}</div></div>')
    return '<div class="grid4">' + ''.join(rows) + '</div>'


def section_small():
    head = '<tr><th></th>' + ''.join(f'<th>{NAMES[k]}</th>' for k in ORDER) + '</tr>'
    body = []
    for px in (48, 32, 24):
        for mode, title in (('icon', 'іконка'), ('glyph', 'знак')):
            tds = []
            for k in ORDER:
                s = CONCEPTS[k]()
                if mode == 'icon':
                    tds.append(f'<td><div class="sz">{icon(s, "navy", px)}{icon(s, "hyb-light", px)}</div></td>')
                else:
                    tds.append(f'<td><div class="sz">{glyph(s, "mono-light", px)}'
                               f'<span class="onblack">{glyph(s, "mono-dark", px)}</span></div></td>')
            body.append(f'<tr><th>{px} px · {title}</th>' + ''.join(tds) + '</tr>')
    return f'<div class="scroll"><table class="small">{head}{"".join(body)}</table></div>'


def section_launcher():
    out = []
    for k in ORDER:
        s = CONCEPTS[k]()
        tiles = ''.join(icon(s, 'navy', 64, sh) for sh in ('round', 'squircle')) + icon(s, 'themed', 64)
        out.append(f'<div class="launch-col"><h4>{NAMES[k]}</h4>'
                   f'<div class="launcher lt">{tiles}</div><div class="launcher dk">{tiles}</div></div>')
    return '<div class="grid4">' + ''.join(out) + '</div>'


def section_lockups():
    out = []
    for k in ORDER:
        s = CONCEPTS[k]()
        out.append(f'<div class="lockups"><h4>{NAMES[k]}</h4>'
                   f'<div class="lock t-hyb-light">{svg(s, view=INK)}<span>Culmina</span></div>'
                   f'<div class="lock t-hyb-dark">{svg(s, view=INK)}<span>Culmina</span></div></div>')
    return '<div class="grid2">' + ''.join(out) + '</div>'


STORY_MS = [0, 100, 200, 300, 450, 600]


def section_story():
    out = []
    for k in ['A', 'B', 'C']:
        fn = CONCEPTS[k]
        frames = ''.join(
            f'<figure class="sf">{icon(fn(ms / 600), "navy", 84, "squircle")}'
            f'<figcaption>{ms} мс</figcaption></figure>' for ms in STORY_MS)
        out.append(f'<div class="story"><h4>{NAMES[k]}</h4><div class="frames">{frames}</div></div>')
    return ''.join(out)


def frames_json():
    """60 fps frames of each concept's 600 ms motion, for the live preview."""
    data = {}
    for k in ['A', 'B', 'C']:
        data[k] = [CONCEPTS[k](i / 36) for i in range(37)]
    return json.dumps(data)


def section_colour():
    out = []
    for theme, label in (('navy', 'Чинна нічна синя'), ('hyb-dark', 'Hybrid темна'),
                         ('hyb-light', 'Hybrid світла'), ('field', 'Польовий режим')):
        s = concept_a()
        out.append(cell(label, icon(s, theme, 96, 'squircle') + icon(s, theme, 48, 'round')))
    return '<div class="colour">' + ''.join(out) + '</div>'


def section_star_options():
    return ('<div class="colour">' +
            cell('A зі зіркою-фото (рекомендовано)', icon(concept_a(), 'navy', 96, 'squircle')
                 + glyph(concept_a(), 'mono-light', 48) + glyph(concept_a(), 'mono-light', 24)) +
            cell('A′ з чинною іскрою', icon(concept_a(star='sparkle'), 'navy', 96, 'squircle')
                 + glyph(concept_a(star='sparkle'), 'mono-light', 48)
                 + glyph(concept_a(star='sparkle'), 'mono-light', 24)) + '</div>')


def main(font_mode='relative', out=None):
    marks = HERE / 'marks'
    marks.mkdir(exist_ok=True)
    for k in ORDER:
        for theme in ('mono-light', 'navy'):
            (marks / f'{k}-{theme}.svg').write_text(standalone(CONCEPTS[k](), theme), encoding='utf-8')
    if font_mode == 'embed':
        b64 = base64.b64encode((ROOT / 'assets/fonts/Geist.ttf').read_bytes()).decode()
        font = f'data:font/ttf;base64,{b64}'
        evidence = 'data:image/png;base64,' + base64.b64encode(
            (HERE / 'evidence/phone-cold-start-2026-10-23.png').read_bytes()).decode()
    else:
        font = '../../assets/fonts/Geist.ttf'
        evidence = 'evidence/phone-cold-start-2026-10-23.png'
    tpl = (HERE / 'report.template.html').read_text(encoding='utf-8')
    repl = {
        'THEMES': theme_css(), 'FONT': font, 'LARGE': section_large(), 'SMALL': section_small(),
        'LAUNCHER': section_launcher(), 'LOCKUPS': section_lockups(), 'STORY': section_story(),
        'FRAMES': frames_json(), 'EVIDENCE': evidence, 'COLOUR': section_colour(), 'STAROPT': section_star_options(),
    }
    for k, v in repl.items():
        tpl = tpl.replace('{{' + k + '}}', v)
    out = Path(out) if out else HERE / 'index.html'
    out.write_text(tpl, encoding='utf-8')
    print('wrote', out)


if __name__ == '__main__':
    import sys
    # --embed OUT: one self-contained page (font and evidence inlined) for
    # sharing outside the repository; written outside it.
    if '--embed' in sys.argv:
        main('embed', sys.argv[sys.argv.index('--embed') + 1])
    else:
        main()
