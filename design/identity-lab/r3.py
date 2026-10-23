"""Culmina identity lab, iteration 2 (2026-10-23): R3 developed, not replaced.

One parametric description of the R3 mark. `R3_ORIGINAL` reproduces the
approved, shipped geometry exactly (drawable/ic_launcher_foreground.xml);
the refinements change named parameters only, so every difference is
traceable. Tones (colour treatments) are separate from geometry, so the
sheet can show the effect of each on its own.

Canvas: the 108-unit adaptive icon, centre (54, 54). Angles in degrees,
counter-clockwise from east with y up, as in the vector.
"""

import math
from dataclasses import dataclass, replace

C = (54.0, 54.0)


def pt(r, a, c=C):
    return (c[0] + r * math.cos(math.radians(a)), c[1] - r * math.sin(math.radians(a)))


def f(v):
    return f'{v:.2f}'.rstrip('0').rstrip('.')


@dataclass(frozen=True)
class Mark:
    # Outer trajectory: radius, stroke, opening from/to (the drawn arc runs
    # counter-clockwise from `outer_to` round to `outer_from` + 360).
    outer_r: float = 22.0
    outer_w: float = 6.0
    outer_from: float = 7.94
    outer_to: float = 72.07
    # Inner trajectory.
    inner_r: float = 13.2
    inner_w: float = 2.4
    inner_from: float = -14.08
    inner_to: float = 94.08
    # Star: centre, half-lengths of the two ray pairs, the control offset of
    # the curved sides (bigger = fuller body, smaller = thinner rays), and
    # the rotation of the ray cross (0 = upright).
    star_x: float = 70.85
    star_y: float = 39.86
    ray_a: float = 9.6   # the pair at `star_rot` + 90 (upright: vertical)
    ray_b: float = 9.6   # the pair at `star_rot` (upright: horizontal)
    body: float = 1.54
    star_rot: float = 0.0
    # Rounded ray tips (iteration 3): each side is trimmed by this fraction of
    # its curve at both ends and the tip is closed with a curve whose control
    # point is the old sharp tip. 0 = sharp (R3). With `tip_keep` the rays are
    # lengthened so the rounded tips reach the same extent as the sharp ones.
    tip_round: float = 0.0
    tip_keep: bool = True
    # Uniform scale about the canvas centre (optical size in the container).
    scale: float = 1.0


R3_ORIGINAL = Mark()

# Delicate refinement: same construction and placement. The inner
# trajectory is made a deliberate second line (stroke 2.4 -> 3.0, its
# opening narrowed so its ends sit closer under the star) and the star gets
# a fuller body and a slightly longer vertical ray, so it reads as a point of
# light rather than the thin four-ray "sparkle" glyph.
# Iteration 3 (owner, 2026-10-23): the refreshed dark tone on the unchanged
# R3 geometry, only the star's tips rounded. Three levels for comparison.
R3_ROUND = {
    'sharp': R3_ORIGINAL,
    'soft': replace(R3_ORIGINAL, tip_round=0.08),
    'medium': replace(R3_ORIGINAL, tip_round=0.14),
    'round': replace(R3_ORIGINAL, tip_round=0.22),
}

R3_DELICATE = replace(
    R3_ORIGINAL,
    inner_r=13.4, inner_w=3.0, inner_from=-6.0, inner_to=86.0,
    ray_a=10.4, ray_b=8.8, body=2.15,
)


def _star_on_orbit(m, axis=40.0):
    # The star's centre on the outer orbit's line, on the opening's axis.
    x, y = pt(m.outer_r, axis)
    return replace(m, star_x=x, star_y=y)


# Stronger refinement, the same image. One spacing module (the clear gap
# between the two trajectories, 3.6) is reused: between each end of the outer
# opening and the star, and between the inner ends and the star's lower rays.
# The star is a glint rather than a symbol: a long vertical ray, shorter side
# rays and a fuller body, set on the orbit's own line. Its upper ray ends on
# the orbit's top tangent and its right ray on the orbit's right tangent, so
# the whole mark fits one square (in R3 the right ray overshoots by 1.45 and
# the upper ray stops 1.26 short). The outer line is a
# little heavier and the inner one is clearly second: thinner than the outer
# by half, but heavy enough to hold at 24 px.
# Rejected on the way: the star's long rays laid along the orbit's tangent
# (they ran into the ends of the opening; the star read as a blob), and a
# 14-degree tilt with a 1.5:1 ray ratio (the star read as a flame).
R3_STRONG = _star_on_orbit(replace(
    R3_ORIGINAL,
    outer_r=22.0, outer_w=6.4, outer_from=5.0, outer_to=75.0,
    inner_r=13.6, inner_w=3.2, inner_from=-20.0, inner_to=100.0,
    body=2.3,
))
_top = 54 - R3_STRONG.outer_r - R3_STRONG.outer_w / 2
_right = 54 + R3_STRONG.outer_r + R3_STRONG.outer_w / 2
R3_STRONG = replace(R3_STRONG, ray_a=R3_STRONG.star_y - _top, ray_b=_right - R3_STRONG.star_x)


def arc(r, a0, a1, w, role):
    x0, y0 = pt(r, a0)
    x1, y1 = pt(r, a1)
    large = 1 if (a1 - a0) % 360 > 180 else 0
    return (f'<path d="M{f(x0)},{f(y0)} A{f(r)},{f(r)} 0 {large} 0 {f(x1)},{f(y1)}" '
            f'fill="none" stroke="var(--{role})" stroke-width="{f(w)}" stroke-linecap="round"/>')


def _star_points(A, B, k):
    tips = [(0, -A), (B, 0), (0, A), (-B, 0)]
    ctrl = [(k, -k), (k, k), (-k, k), (-k, -k)]
    return tips, ctrl


def _qb(p0, q, p2, t):
    return tuple((1 - t) ** 2 * a + 2 * (1 - t) * t * b + t * t * c for a, b, c in zip(p0, q, p2))


def _sub(p0, q, p2, a, b):
    """The control point of the quadratic's sub-curve on [a, b]."""
    return tuple(x * (1 - a) * (1 - b) + y * ((1 - a) * b + a * (1 - b)) + z * a * b
                 for x, y, z in zip(p0, q, p2))


def _rounded_reach(A, B, k, t0):
    """How far the rounded upper tip reaches, for ray length A."""
    tips, ctrl = _star_points(A, B, k)
    e1 = _qb(tips[3], ctrl[3], tips[0], 1 - t0)
    e2 = _qb(tips[0], ctrl[0], tips[1], t0)
    apex = _qb(e1, tips[0], e2, 0.5)
    return -apex[1]


def star_path(m):
    def rot(pt_):
        dx, dy = pt_
        a = math.radians(m.star_rot)
        # Screen coordinates (y down): rotate counter-clockwise on screen.
        return (m.star_x + dx * math.cos(a) + dy * math.sin(a),
                m.star_y - dx * math.sin(a) + dy * math.cos(a))
    A, B, k, t0 = m.ray_a, m.ray_b, m.body, m.tip_round
    if t0 and m.tip_keep:
        # Lengthen both ray pairs so the rounded tips reach the sharp extent.
        for _ in range(30):
            A *= m.ray_a / _rounded_reach(A, B, k, t0)
            B *= m.ray_b / _rounded_reach(B, A, k, t0)
    tips, ctrl = _star_points(A, B, k)
    if not t0:
        p = [rot(t) for t in tips]
        q = [rot(c) for c in ctrl]
        d = f'M{f(p[0][0])},{f(p[0][1])}'
        for i in range(4):
            n = p[(i + 1) % 4]
            d += f' Q{f(q[i][0])},{f(q[i][1])} {f(n[0])},{f(n[1])}'
        return d + ' Z'
    # Each side i runs from tip i to tip i+1; keep its middle [t0, 1 - t0].
    sides = []
    for i in range(4):
        p0, q, p2 = tips[i], ctrl[i], tips[(i + 1) % 4]
        sides.append((_qb(p0, q, p2, t0), _sub(p0, q, p2, t0, 1 - t0), _qb(p0, q, p2, 1 - t0)))
    start = rot(sides[0][0])
    d = f'M{f(start[0])},{f(start[1])}'
    for i in range(4):
        _, c, e = sides[i]
        c, e = rot(c), rot(e)
        d += f' Q{f(c[0])},{f(c[1])} {f(e[0])},{f(e[1])}'
        # The rounded tip: from this side's end to the next side's start,
        # with the old sharp tip as the control point.
        tip = rot(tips[(i + 1) % 4])
        nxt = rot(sides[(i + 1) % 4][0])
        d += f' Q{f(tip[0])},{f(tip[1])} {f(nxt[0])},{f(nxt[1])}'
    return d + ' Z'


def shapes(m):
    inner = arc(m.inner_r, m.inner_to, m.inner_from + 360, m.inner_w, 'inner')
    outer = arc(m.outer_r, m.outer_to, m.outer_from + 360, m.outer_w, 'orbit')
    star = f'<path d="{star_path(m)}" fill="var(--star)"/>'
    g = inner + outer + star
    if m.scale != 1.0:
        s = m.scale
        g = f'<g transform="translate({f(54 - 54 * s)},{f(54 - 54 * s)}) scale({f(s)})">{g}</g>'
    return g


# --- tones -----------------------------------------------------------------
# bg1/bg2: the field from top to bottom (equal for a flat field). Values are
# chosen against the shipped palettes: navy = AppColors.mark*; the blues come
# from HybridTokens' sky ramp (#E6F3FE, #A6D2F3, #599FD5, #285B90) and accent
# (#0075DE / #62AFF3).

TONES = {
    'control': dict(label='Чинний R3 (контроль)', bg1='#0B1230', bg2='#0B1230',
                    orbit='#E6EBF7', inner='#7F8DC0', star='#8CCBFF'),
    'light': dict(label='A · Світла основа', bg1='#F7F9FD', bg2='#E3ECF8',
                  orbit='#0F1C4D', inner='#6C7FB8', star='#1F7FE5'),
    'blue': dict(label='B · Блакитне поле', bg1='#4F8DDB', bg2='#2D62B4',
                 orbit='#F4F8FF', inner='#B4CDF2', star='#FFFFFF'),
    'dark': dict(label='C · Оновлена темна', bg1='#1B2A63', bg2='#0B1230',
                 orbit='#F5F7FD', inner='#A4B2E2', star='#A3D8FF'),
}

MONO = {
    'ink': dict(bg1='#FFFFFF', bg2='#FFFFFF', orbit='#0F1C4D', inner='#0F1C4D', star='#0F1C4D'),
    'paper': dict(bg1='#0F1C4D', bg2='#0F1C4D', orbit='#FFFFFF', inner='#FFFFFF', star='#FFFFFF'),
}


def lum(hexc):
    h = hexc.lstrip('#')
    rgb = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in rgb]
    return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2]


def contrast(a, b):
    la, lb = sorted((lum(a), lum(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def mix(a, b, t):
    ha, hb = a.lstrip('#'), b.lstrip('#')
    return '#' + ''.join(f'{round(int(ha[i:i+2], 16) * (1 - t) + int(hb[i:i+2], 16) * t):02X}' for i in (0, 2, 4))


_gid = [0]


def svg(m, tone, view='18 18 72 72', field=True, size=None, title=None):
    """An SVG of mark `m` in `tone` (a TONES/MONO key or dict)."""
    t = TONES.get(tone) or MONO.get(tone) or tone
    _gid[0] += 1
    gid = f'g{_gid[0]}'
    style = (f'--orbit:{t["orbit"]};--inner:{t["inner"]};--star:{t["star"]}')
    defs = ''
    bg = ''
    if field:
        defs = (f'<defs><linearGradient id="{gid}" x1="0" y1="18" x2="0" y2="90" '
                f'gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="{t["bg1"]}"/>'
                f'<stop offset="1" stop-color="{t["bg2"]}"/></linearGradient></defs>')
        bg = f'<rect width="108" height="108" fill="url(#{gid})"/>'
    s = f' width="{size}" height="{size}"' if size else ''
    ttl = f'<title>{title}</title>' if title else ''
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{view}"{s} style="{style}" '
            f'role="img">{ttl}{defs}{bg}{shapes(m)}</svg>')
