"""Builds iteration 2 of the identity lab from r3.py.

    python design/identity-lab/build_r3.py [--png CHROME] [--embed OUT]

Writes r3/svg/*.svg (editable vector sketches), r3.html (the comparison
sheet, from r3.template.html) and, with --png, r3/png/*.png rendered by a
headless Chrome. Proposals only; nothing is copied into the app.
"""

import base64
import subprocess
import sys
from pathlib import Path

from r3 import (MONO, R3_DELICATE, R3_ORIGINAL, R3_ROUND, R3_STRONG, TONES, contrast, mix,
                svg)

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
OUT = HERE / 'r3'
GEOMS = {'original': ('R3 без змін', R3_ORIGINAL),
         'delicate': ('R3·1 · делікатне', R3_DELICATE),
         'strong': ('R3·2 · виразніше', R3_STRONG)}
TONE_ORDER = ['control', 'light', 'blue', 'dark']
PICK = 'light'          # the tone carried into the geometry step
# Final candidates: (geometry, tone, label). The control stays alongside.
FINALS = [('strong', 'light', 'R3·2 · світла основа (рекомендація)'),
          ('strong', 'dark', 'R3·2 · оновлена темна (альтернатива)'),
          ('original', 'control', 'Чинний R3 (контроль)')]
FULL = '18 18 72 72'    # the launcher's visible area
MARK = '25 25 58 58'    # the mark alone, with a small margin


def icon(m, tone, px, shape='squircle', title=None):
    r = {'squircle': '22.4%', 'round': '50%'}[shape]
    return (f'<span class="ic" style="width:{px}px;height:{px}px;border-radius:{r}">'
            f'{svg(m, tone, title=title)}</span>')


def mark(m, tone, px):
    t = MONO.get(tone) or TONES[tone]
    return (f'<span class="mk" style="width:{px}px;height:{px}px;background:{t["bg1"]}">'
            f'{svg(m, tone, view=MARK, field=False)}</span>')


def tone_metrics(tone):
    t = TONES[tone]
    bg = mix(t['bg1'], t['bg2'], 0.4)
    return {e: contrast(t[e], bg) for e in ('orbit', 'inner', 'star')}


def fig(body, caption):
    return f'<figure><div class="fv">{body}</div><figcaption>{caption}</figcaption></figure>'


def step_tone():
    m = R3_ORIGINAL
    cols = []
    for k in TONE_ORDER:
        c = tone_metrics(k)
        sizes = ''.join(icon(m, k, s) for s in (48, 32, 24))
        cols.append(
            f'<div class="tcol"><h4>{TONES[k]["label"]}</h4>{icon(m, k, 168)}'
            f'<div class="sizes">{sizes}</div>'
            f'<dl class="nums"><dt>Орбіта</dt><dd>{c["orbit"]:.1f}:1</dd>'
            f'<dt>Внутрішня дуга</dt><dd>{c["inner"]:.1f}:1</dd>'
            f'<dt>Зірка</dt><dd>{c["star"]:.1f}:1</dd>'
            f'<dt>Світлі площі</dt><dd>{{{{LIGHT_{k}}}}}</dd></dl></div>')
    return '<div class="tgrid">' + ''.join(cols) + '</div>'


def step_geom():
    cols = []
    for k, (label, m) in GEOMS.items():
        sizes = ''.join(icon(m, PICK, s) for s in (48, 32, 24))
        cols.append(f'<div class="tcol"><h4>{label}</h4>{icon(m, PICK, 200)}'
                    f'<div class="sizes">{sizes}</div>{mark(m, "ink", 200)}</div>')
    return '<div class="ggrid">' + ''.join(cols) + '</div>'


def finals():
    out = []
    for g, tone, label in FINALS[:2]:
        m = GEOMS[g][1]
        big = icon(m, tone, 220)
        sizes = ''.join(fig(icon(m, tone, s), f'{s} px') for s in (48, 32, 24))
        marks = (fig(mark(m, tone, 104), 'Без контейнера') +
                 fig(mark(m, 'ink', 104), 'Монохром') + fig(mark(m, 'paper', 104), 'Інверсія'))
        out.append(f'<div class="final"><h3>{label}</h3><div class="frow">{fig(big, "Іконка, 220 px")}'
                   f'<div class="fstack"><div class="frow sizes">{sizes}</div><div class="frow">{marks}</div></div></div>'
                   '</div>')
    m = GEOMS[FINALS[0][0]][1]
    locks = (f'<div class="final"><h3>З назвою</h3><p class="note">Колір знака в композиції '
             f'визначає поверхня, а не тон іконки: на світлій — темно-синій знак, на темній — світлий. '
             f'Тому для обох кандидатів композиція однакова.</p>'
             f'<div class="locks">{lockup(m, "light", "light")}{lockup(m, "dark", "dark")}</div></div>')
    return '<div class="fgrid">' + ''.join(out) + '</div>' + locks


def lockup(m, tone, surface):
    t = TONES[tone]
    bg = '#FFFFFF' if surface == 'light' else '#191919'
    ink = '#0F1C4D' if surface == 'light' else '#F5F7FD'
    return (f'<div class="lock" style="background:{bg}">'
            f'<span class="lm">{svg(m, tone, view=MARK, field=False)}</span>'
            f'<span class="lw" style="color:{ink}">Culmina</span></div>')


# Neutral placeholder icons for the home screens: plain fields and simple
# shapes, not real apps, so no third-party mark is reproduced.
PLACEHOLDERS = [
    ('#E8503A', 'circle', 'Камера'), ('#F5B83D', 'square', 'Нотатки'),
    ('#3FA66B', 'wave', 'Карти'), ('#7B61FF', 'tri', 'Музика'),
    ('#202124', 'circle', 'Годинник'), ('#FFFFFF', 'square', 'Фото'),
    ('#1E88E5', 'wave', 'Погода'),
]


def placeholder(col, shape, px):
    fg = '#FFFFFF' if col not in ('#FFFFFF', '#F5B83D') else '#3A3A3A'
    g = {'circle': f'<circle cx="50" cy="50" r="22" fill="{fg}"/>',
         'square': f'<rect x="30" y="30" width="40" height="40" rx="8" fill="{fg}"/>',
         'wave': f'<path d="M24 58 Q37 38 50 52 T76 46" stroke="{fg}" stroke-width="9" fill="none" stroke-linecap="round"/>',
         'tri': f'<path d="M50 27 L74 70 H26 Z" fill="{fg}"/>'}[shape]
    return (f'<span class="ic" style="width:{px}px;height:{px}px;border-radius:22.4%">'
            f'<svg viewBox="0 0 100 100"><rect width="100" height="100" fill="{col}"/>{g}</svg></span>')


def home(m, tone, wall):
    walls = {'light': 'linear-gradient(160deg,#E9EEF6 0%,#F3EDE4 55%,#DCE6F2 100%)',
             'dark': 'linear-gradient(160deg,#1D2233 0%,#2A2440 50%,#121722 100%)'}
    txt = '#1F1F1F' if wall == 'light' else '#F2F2F2'
    cells = []
    items = PLACEHOLDERS[:3] + [None] + PLACEHOLDERS[3:]
    for it in items:
        if it is None:
            cells.append(f'<div class="app">{icon(m, tone, 56)}<span style="color:{txt}">Culmina</span></div>')
        else:
            col, sh, name = it
            cells.append(f'<div class="app">{placeholder(col, sh, 56)}<span style="color:{txt}">{name}</span></div>')
    return f'<div class="phone" style="background:{walls[wall]}"><div class="apps">{"".join(cells)}</div></div>'


def homes():
    out = []
    for g, tone, label in FINALS:
        m = GEOMS[g][1]
        out.append(f'<div class="hcol"><h4>{label}</h4><div class="homes">{home(m, tone, "light")}{home(m, tone, "dark")}</div></div>')
    return '<div class="hgrid">' + ''.join(out) + '</div>'


def params():
    rows = [('Зовнішня дуга: товщина', 'outer_w'), ('Зовнішній розрив, від–до (°)', ('outer_from', 'outer_to')),
            ('Внутрішня дуга: радіус', 'inner_r'), ('Внутрішня дуга: товщина', 'inner_w'),
            ('Внутрішній розрив, від–до (°)', ('inner_from', 'inner_to')),
            ('Зірка: вертикальний промінь', 'ray_a'), ('Зірка: бічний промінь', 'ray_b'),
            ('Зірка: повнота тіла', 'body')]
    head = '<tr><th>Параметр (одиниці полотна 108)</th>' + ''.join(f'<th>{v[0]}</th>' for v in GEOMS.values()) + '</tr>'
    body = []
    for label, key in rows:
        tds = []
        base = None
        for i, (_, m) in enumerate(GEOMS.values()):
            if isinstance(key, tuple):
                v = f'{getattr(m, key[0]):.1f}…{getattr(m, key[1]):.1f}'
            else:
                v = f'{getattr(m, key):.2f}'.rstrip('0').rstrip('.')
            changed = i and v != base
            base = v if i == 0 else base
            tds.append(f'<td{" class=chg" if changed else ""}>{v}</td>')
        body.append(f'<tr><td>{label}</td>{"".join(tds)}</tr>')
    return f'<div class="scroll"><table>{head}{"".join(body)}</table></div>'


# Iteration 3: the owner chose the refreshed dark tone on the unchanged R3
# geometry and asked for smoother star tips only.
ROUND_LABELS = {'sharp': 'Гострі кінці (R3 без змін)', 'soft': 'Легке заокруглення',
                'medium': 'Середнє заокруглення', 'round': 'Сильне — межа'}
CHOSEN = 'medium'
STAR_VIEW = '58 27 26 26'


def ray_growth(m):
    from r3 import _rounded_reach
    if not m.tip_round:
        return 0.0
    a, b = m.ray_a, m.ray_b
    for _ in range(30):
        a *= m.ray_a / _rounded_reach(a, b, m.body, m.tip_round)
        b *= m.ray_b / _rounded_reach(b, a, m.body, m.tip_round)
    return a - m.ray_a


def step_star():
    cols = []
    for k, m in R3_ROUND.items():
        g = ray_growth(m)
        note = 'контроль' if not g else f'промінь +{g:.1f} од., розмах 19,2 збережено'
        zoom = (f'<span class="mk" style="width:200px;height:200px;border-radius:8px">'
                f'{svg(m, "dark", view=STAR_VIEW)}</span>')
        sizes = ''.join(icon(m, 'dark', s) for s in (48, 32, 24))
        pick = ' · обрано' if k == CHOSEN else ''
        cols.append(f'<div class="tcol"><h4>{ROUND_LABELS[k]}{pick}</h4>{icon(m, "dark", 200)}'
                    f'{zoom}<div class="sizes">{sizes}</div><p class="note" style="margin:0">{note}</p></div>')
    return '<div class="tgrid">' + ''.join(cols) + '</div>'


def chosen():
    m = R3_ROUND[CHOSEN]
    sizes = ''.join(fig(icon(m, 'dark', s), f'{s} px') for s in (48, 32, 24))
    marks = (fig(mark(m, 'dark', 104), 'Без контейнера') +
             fig(mark(m, 'ink', 104), 'Монохром') + fig(mark(m, 'paper', 104), 'Інверсія'))
    top = (f'<div class="final"><div class="frow">{fig(icon(m, "dark", 220), "Іконка, 220 px")}'
           f'<div class="fstack"><div class="frow sizes">{sizes}</div><div class="frow">{marks}</div></div></div>'
           f'<div class="locks" style="max-width:560px">{lockup(m, "light", "light")}{lockup(m, "dark", "dark")}</div></div>')
    homes_ = (f'<div class="homes" style="margin-top:20px">{home(m, "dark", "light")}{home(m, "dark", "dark")}</div>')
    return top + homes_


def write_svgs():
    (OUT / 'svg').mkdir(parents=True, exist_ok=True)
    files = []
    for g, (_, m) in GEOMS.items():
        for t in TONE_ORDER:
            files.append((f'icon-{g}-{t}.svg', svg(m, t, view=FULL, size=1024)))
        for t in ('ink', 'paper'):
            files.append((f'mark-{g}-mono-{t}.svg', svg(m, t, view=MARK, field=t == 'paper', size=1024)))
    m = R3_ROUND[CHOSEN]
    files.append(('chosen-icon-r3-dark-star-medium.svg', svg(m, 'dark', view=FULL, size=1024)))
    for t in ('ink', 'paper'):
        files.append((f'chosen-mark-r3-star-medium-mono-{t}.svg', svg(m, t, view=MARK, field=t == 'paper', size=1024)))
    files.append(('chosen-mark-r3-star-medium-dark.svg', svg(m, 'dark', view=MARK, field=True, size=1024)))
    for k, mm in R3_ROUND.items():
        files.append((f'star-tips-{k}-dark.svg', svg(mm, 'dark', view=FULL, size=1024)))
    # Lockups: the mark at 58 units beside "Culmina" in Geist 500 (the app's
    # family), cap height ~0.55 of the mark; the font loads from the repo.
    font = '../../../../assets/fonts/Geist.ttf'
    for g, m in (('strong', R3_STRONG), ('original', R3_ORIGINAL), ('chosen', R3_ROUND[CHOSEN])):
        for surface, bg, ink, tone in (('light', '#FFFFFF', '#0F1C4D', 'light'),
                                       ('dark', '#191919', '#F5F7FD', 'dark')):
            inner = svg(m, tone, view=MARK, field=False)
            body = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 100" width="1600" height="400">'
                    f'<style>@font-face{{font-family:Geist;src:url({font})}}</style>'
                    f'<rect width="400" height="100" fill="{bg}"/>'
                    f'{inner.replace("<svg ", "<svg x=\"20\" y=\"18\" width=\"64\" height=\"64\" ", 1)}'
                    f'<text x="100" y="68" font-family="Geist" font-weight="500" font-size="46" '
                    f'letter-spacing="0.25" fill="{ink}">Culmina</text></svg>')
            files.append((f'lockup-{g}-on-{surface}.svg', body))
    for name, body in files:
        (OUT / 'svg' / name).write_text('<?xml version="1.0" encoding="utf-8"?>\n' + body + '\n', encoding='utf-8')
    return [n for n, _ in files]


def render_pngs(chrome, names):
    png = OUT / 'png'
    png.mkdir(exist_ok=True)
    for n in names:
        src = (OUT / 'svg' / n).as_uri()
        subprocess.run([chrome, '--headless=new', '--disable-gpu', '--hide-scrollbars',
                        '--default-background-color=00000000',
                        '--window-size=' + ('1600,400' if n.startswith('lockup') else '1024,1024'),
                        f'--screenshot={png / n.replace(".svg", ".png")}', src],
                       stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL, check=False)


def main():
    names = write_svgs()
    if '--png' in sys.argv:
        render_pngs(sys.argv[sys.argv.index('--png') + 1], names)
    embed = '--embed' in sys.argv
    font = ('data:font/ttf;base64,' + base64.b64encode((ROOT / 'assets/fonts/Geist.ttf').read_bytes()).decode()
            if embed else '../../assets/fonts/Geist.ttf')
    tpl = (HERE / 'r3.template.html').read_text(encoding='utf-8')
    light = {}
    lf = HERE / 'r3' / 'light_share.txt'
    if lf.exists():
        for line in lf.read_text(encoding='utf-8').splitlines():
            k, v = line.split('=')
            light[k] = v
    repl = {'FONT': font, 'TONE': step_tone(), 'GEOM': step_geom(), 'PARAMS': params(),
            'FINALS': finals(), 'HOMES': homes(),
            'STAR': step_star(), 'CHOSEN': chosen()}
    for k, v in repl.items():
        tpl = tpl.replace('{{' + k + '}}', v)
    for k in TONE_ORDER:
        tpl = tpl.replace('{{LIGHT_' + k + '}}', light.get(k, '—'))
    out = Path(sys.argv[sys.argv.index('--embed') + 1]) if embed else HERE / 'r3.html'
    out.write_text(tpl, encoding='utf-8')
    print('wrote', out)


if __name__ == '__main__':
    main()
