"""Culmina identity lab (2026-10-23, Stage A): one source of geometry for the
current mark and the three concepts. Proposals only; nothing here is wired
into the app.

Every shape is built on the 108-unit adaptive-icon canvas used by
android/app/src/main/res/drawable/ic_launcher_foreground.xml: centre (54, 54),
66-unit safe zone, 72-unit visible launcher area. Angles are degrees,
counter-clockwise from east with y up, as in the existing vector.

`frame(concept, t)` returns the SVG shapes of a concept at animation progress
t in [0, 1]; t = 1 is the static mark, so the last frame is the mark by
construction.
"""

import math

C = (54.0, 54.0)


def pt(r, a, c=C):
    return (c[0] + r * math.cos(math.radians(a)), c[1] - r * math.sin(math.radians(a)))


def f(v):
    return f'{v:.2f}'.rstrip('0').rstrip('.')


def arc_d(r, a0, a1, c=C):
    """SVG path for an arc from a0 to a1 (a1 > a0, counter-clockwise)."""
    x0, y0 = pt(r, a0, c)
    x1, y1 = pt(r, a1, c)
    large = 1 if (a1 - a0) % 360 > 180 else 0
    return f'M{f(x0)},{f(y0)} A{f(r)},{f(r)} 0 {large} 0 {f(x1)},{f(y1)}'


def arc_stroke(r, a0, a1, w, role, c=C):
    if a1 - a0 <= 0.5:
        return ''
    return (f'<path d="{arc_d(r, a0, a1, c)}" fill="none" stroke="var(--{role})" '
            f'stroke-width="{f(w)}" stroke-linecap="round"/>')


def poly(points, role):
    d = 'M' + ' L'.join(f'{f(x)},{f(y)}' for x, y in points) + ' Z'
    return f'<path d="{d}" fill="var(--{role})"/>'


# --- stars -----------------------------------------------------------------

def sparkle(cx, cy, s=1.0, role='star'):
    """The approved R3 curved sparkle (quadratic sides), scaled about its centre."""
    h = 9.6 * s
    k = 1.53 * s
    d = (f'M{f(cx)},{f(cy - h)} Q{f(cx + k)},{f(cy - k)} {f(cx + h)},{f(cy)} '
         f'Q{f(cx + k)},{f(cy + k)} {f(cx)},{f(cy + h)} '
         f'Q{f(cx - k)},{f(cy + k)} {f(cx - h)},{f(cy)} '
         f'Q{f(cx - k)},{f(cy - k)} {f(cx)},{f(cy - h)} Z')
    return f'<path d="{d}" fill="var(--{role})"/>'


# A photographed star: a round core with four straight diffraction spikes (the
# signature of a star through a reflector's spider vanes), not the concave
# "sparkle" glyph that now reads as an AI feature.
STAR_CORE = 3.7
STAR_SPIKE = 10.6
STAR_WAIST = 1.75


def astro_star(cx, cy, s=1.0, role='star', rot=0.0):
    pts = []
    for i in range(8):
        a = rot + i * 45
        r = (STAR_SPIKE if i % 2 == 0 else STAR_WAIST) * s
        pts.append((cx + r * math.cos(math.radians(a + 90)),
                    cy - r * math.sin(math.radians(a + 90))))
    return (poly(pts, role) +
            f'<circle cx="{f(cx)}" cy="{f(cy)}" r="{f(STAR_CORE * s)}" fill="var(--{role})"/>')


# --- the current mark (R3-final, approved 2026-10-17) ----------------------

def current(t=1.0):
    return ''.join([
        arc_stroke(13.2, 94.08, 345.92, 2.4, 'inner'),
        arc_stroke(22, 72.07, 367.94, 6.0, 'orbit'),
        sparkle(70.85, 39.86),
    ])


# --- A: refined orbit ------------------------------------------------------
# Same idea and placement as R3: orbit R 22 centred on the canvas, the star
# on the orbit itself at 40 degrees, in the opening. Changes: the inner orbit
# stays (without it the open ring reads as a generic refresh/progress glyph)
# but gets a weight that survives 24 px (3.2, radius 12.4, its opening on the
# same axis), the sparkle becomes a photographed star, and the opening is cut
# symmetrically about the star with equal clearance to both ends.

A_R, A_W, A_AXIS, A_HALF_GAP = 22.0, 6.0, 40.0, 31.0
A_INNER = (12.4, 3.2, 46.0)  # radius, stroke, half-opening about the axis
# Degrees the star travels along the orbit in the motion. The opening moves
# with it: at t = 0 the opening runs from its fixed lower end to just behind
# the star, and the orbit closes behind the star as it settles.
A_TRAVEL = 58.0


def ease(t):
    """AppMotion.curve, Cubic(0.16, 1, 0.3, 1), solved for x -> y."""
    lo, hi = 0.0, 1.0
    for _ in range(40):
        m = (lo + hi) / 2
        x = 3 * (1 - m) ** 2 * m * 0.16 + 3 * (1 - m) * m * m * 0.3 + m ** 3
        lo, hi = (m, hi) if x < t else (lo, m)
    m = (lo + hi) / 2
    return 3 * (1 - m) ** 2 * m * 1 + 3 * (1 - m) * m * m * 1 + m ** 3


def orbit_with_holes(r, w, holes, role='orbit'):
    """A full orbit minus angular holes [(from, to)], drawn as arcs."""
    cuts = []
    for a0, a1 in holes:
        a0 %= 360
        a1 = a0 + (a1 - a0) % 360
        cuts.append((a0, a1))
    # Unwrap onto [base, base + 360) and merge.
    base = cuts[0][0]
    norm = sorted(((a0 - base) % 360, (a0 - base) % 360 + (a1 - a0)) for a0, a1 in cuts)
    merged = []
    for a0, a1 in norm:
        if merged and a0 <= merged[-1][1]:
            merged[-1] = (merged[-1][0], max(merged[-1][1], a1))
        else:
            merged.append((a0, a1))
    out = []
    for i, (a0, a1) in enumerate(merged):
        nxt = merged[(i + 1) % len(merged)][0] + (360 if i + 1 == len(merged) else 0)
        out.append(arc_stroke(r, base + a1, base + nxt, w, role))
    return ''.join(out)


def concept_a(t=1.0, star='astro'):
    e = ease(t)
    a = A_AXIS + A_TRAVEL * (1 - e)
    sx, sy = pt(A_R, a)
    holes = [(A_AXIS - A_HALF_GAP, A_AXIS + A_HALF_GAP), (a - A_HALF_GAP, a + A_HALF_GAP)]
    s = astro_star(sx, sy) if star == 'astro' else sparkle(sx, sy)
    r, w, h = A_INNER
    inner = arc_stroke(r, A_AXIS + h, A_AXIS + 360 - h, w, 'inner')
    return inner + orbit_with_holes(A_R, A_W, holes) + s


# --- B: star trail ---------------------------------------------------------
# The C is a long-exposure star trail: one stroke that thickens toward the
# star, recording light over time. The star moves clockwise (as a southern
# star moves toward culmination) and the trail is what it has already drawn.

B_R, B_AXIS, B_LEAD = 22.0, 40.0, 30.0
B_W_HEAD, B_W_TAIL, B_SPAN = 7.6, 2.4, 262.0
B_TRAVEL = 64.0


def tapered(r, a_head, span, w_head, w_tail, role='orbit', steps=120):
    outer, inner = [], []
    for i in range(steps + 1):
        u = i / steps
        a = a_head + span * u
        w = w_head + (w_tail - w_head) * u ** 0.9
        outer.append(pt(r + w / 2, a))
        inner.append(pt(r - w / 2, a))
    cap_t = []
    for i in range(1, 12):  # round tail cap
        g = 180 * i / 12
        a = a_head + span
        w = w_tail / 2
        ex, ey = pt(r, a)
        dx, dy = math.cos(math.radians(a + 90)), -math.sin(math.radians(a + 90))
        rx, ry = math.cos(math.radians(a)), -math.sin(math.radians(a))
        cap_t.append((ex + w * (rx * math.cos(math.radians(g)) + dx * math.sin(math.radians(g))),
                      ey + w * (ry * math.cos(math.radians(g)) + dy * math.sin(math.radians(g)))))
    cap_h = []
    for i in range(1, 12):  # round head cap
        g = 180 * i / 12
        a = a_head
        w = w_head / 2
        ex, ey = pt(r, a)
        dx, dy = math.cos(math.radians(a - 90)), -math.sin(math.radians(a - 90))
        rx, ry = math.cos(math.radians(a)), -math.sin(math.radians(a))
        cap_h.append((ex + w * (-rx * math.cos(math.radians(g)) + dx * math.sin(math.radians(g))),
                      ey + w * (-ry * math.cos(math.radians(g)) + dy * math.sin(math.radians(g)))))
    return poly(outer + cap_t + inner[::-1] + cap_h, role)


def concept_b(t=1.0):
    e = ease(t)
    a = B_AXIS + B_TRAVEL * (1 - e)
    sx, sy = pt(B_R, a)
    span = B_SPAN - B_TRAVEL * (1 - e)
    return tapered(B_R, a + B_LEAD, span, B_W_HEAD, B_W_TAIL) + astro_star(sx, sy)


# --- C: transit ------------------------------------------------------------
# A meridian-transit diagram: one arc of an object's path, the meridian as a
# thin vertical, the star where they meet (the culmination). No C, no horizon
# line (which would read as a sunrise).

C_CENTRE, C_R, C_W, C_SPAN = (54.0, 80.0), 30.0, 5.0, 66.0
C_MER = (25.0, 85.0, 1.8)  # meridian y from, y to, width
C_GAP = 5.4  # clearance between the meridian and the star core
C_TRAVEL = 42.0


def concept_c(t=1.0):
    e = ease(t)
    a = 90 + C_TRAVEL * (1 - e)
    sx, sy = pt(C_R, a, C_CENTRE)
    y0, y1, w = C_MER
    top_end = C_CENTRE[1] - C_R - C_GAP - STAR_CORE
    bot_start = C_CENTRE[1] - C_R + C_GAP + STAR_CORE
    mer = (f'<path d="M54,{f(y0)} V{f(top_end)} M54,{f(bot_start)} V{f(y1)}" '
           f'stroke="var(--inner)" stroke-width="{f(w)}" stroke-linecap="round" fill="none"/>')
    hole = 13.5  # degrees of path left open around the star
    arcs = (arc_stroke(C_R, 90 - C_SPAN, a - hole, C_W, 'orbit', C_CENTRE) +
            arc_stroke(C_R, a + hole, 90 + C_SPAN, C_W, 'orbit', C_CENTRE))
    return mer + arcs + astro_star(sx, sy, s=1.2)


CONCEPTS = {
    'current': current,
    'A': concept_a,
    'B': concept_b,
    'C': concept_c,
}


def svg(shapes, size=None, view='0 0 108 108', bg=None, extra=''):
    s = f' width="{size}" height="{size}"' if size else ''
    b = f'<rect width="108" height="108" fill="var(--bg)"/>' if bg else ''
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view}"{s} '
            f'role="img"{extra}>{b}{shapes}</svg>')
