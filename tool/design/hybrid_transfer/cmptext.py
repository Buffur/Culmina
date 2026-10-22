"""Compare web computed-style dump with Flutter text dump by visible text.
python cmptext.py web.json flutter.json [maxrows]
Web x is relative to the frame's outer edge (1 px border) -> shifted by -1."""
import json, sys, re, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
web = json.load(open(sys.argv[1], encoding='utf-8'))
fl = json.load(open(sys.argv[2], encoding='utf-8'))
limit = int(sys.argv[3]) if len(sys.argv) > 3 else 400
wyoff = float(sys.argv[4]) if len(sys.argv) > 4 else 0.0
for w in web: w['y'] = w['y'] - wyoff
norm = lambda t: re.sub(r'\s+', ' ', t or '').strip().lower()
px = lambda v: float(v[:-2]) if isinstance(v, str) and v.endswith('px') else None
def rgb(c):
    m = re.findall(r'[\d.]+', c or '')
    return '#%02x%02x%02x' % tuple(int(float(x)) for x in m[:3]) if len(m) >= 3 else c
used = set()
rows = []
for f in fl:
    ft = norm(f['text'])
    best = None
    for i, w in enumerate(web):
        if i in used or not w.get('text'):
            continue
        wt = norm(w['text'])
        if wt == ft or (len(wt) > 6 and (ft.startswith(wt) or wt.startswith(ft))):
            best = i
            break
    fs, fh = f.get('size'), f.get('height')
    flh = fs * fh if fs and fh else None
    fcol = '#' + f['color'][3:] if f.get('color') else None
    if best is None:
        rows.append(f"  -- F only: {f['text'][:40]!r} @({f['x']:.0f},{f['y']:.0f}) {fs}/{f.get('weight')} {f.get('family')}")
        continue
    used.add(best)
    w = web[best]
    ws, wl = px(w.get('size')), px(w.get('lh'))
    d = []
    if ws != fs: d.append(f"size {ws}->{fs}")
    if str(w.get('weight')) != str(f.get('weight')): d.append(f"wt {w.get('weight')}->{f.get('weight')}")
    if wl and flh and abs(wl - flh) > 0.6: d.append(f"lh {wl:.1f}->{flh:.1f}")
    wls = px(w.get('ls')) or 0.0
    if abs(wls - (f.get('ls') or 0)) > 0.05: d.append(f"ls {wls}->{f.get('ls')}")
    if w.get('font') and f.get('family') and w['font'] != f['family']: d.append(f"fam {w['font']}->{f['family']}")
    if fcol and rgb(w.get('color')) != fcol.lower(): d.append(f"col {rgb(w.get('color'))}->{fcol}")
    dx, dy = f['x'] - (w['x'] - 1), f['y'] - w['y']
    if abs(dx) > 1: d.append(f"dx {dx:+.1f}")
    if abs(dy) > 1: d.append(f"dy {dy:+.1f}")
    rows.append(f"{'OK' if not d else '!!'} {w['text'][:36]!r:40} w({w['x']-1:.1f},{w['y']:.1f}) f({f['x']:.1f},{f['y']:.1f}) " + '; '.join(d))
for i, w in enumerate(web):
    if i not in used and w.get('text'):
        rows.append(f"  -- W only: {w['text'][:40]!r} @({w['x']-1:.0f},{w['y']:.0f}) {w.get('size')}/{w.get('weight')}")
print('\n'.join(rows[:limit]))
