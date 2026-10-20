"""Read the bundled SFNT directly; no font tooling dependency is needed."""
from pathlib import Path
import hashlib
import json
import struct

ROOT = Path(__file__).resolve().parents[2]
FONT = ROOT / 'assets/fonts/Geist.ttf'
SPECIMEN = 'ІіЇїЄєҐґ°×−0O1Il0123456789'

def inspect_font():
    data = FONT.read_bytes()
    u16 = lambda p: struct.unpack_from('>H', data, p)[0]
    u32 = lambda p: struct.unpack_from('>I', data, p)[0]
    tables = {}
    for i in range(u16(4)):
        tag, _, offset, length = struct.unpack_from('>4sIII', data, 12 + i * 16)
        tables[tag.decode()] = (offset, length)
    base = tables['cmap'][0]
    supported = set()
    for i in range(u16(base + 2)):
        platform, encoding, offset = struct.unpack_from('>HHI', data, base + 4 + 8 * i)
        if platform not in (0, 3):
            continue
        p = base + offset
        fmt = u16(p)
        if fmt == 12:
            for g in range(u32(p + 12)):
                start, end, glyph = struct.unpack_from('>III', data, p + 16 + 12 * g)
                supported.update(range(start + (glyph == 0), end + 1))
        elif fmt == 4:
            count = u16(p + 6) // 2
            ends, starts = p + 14, p + 16 + 2 * count
            deltas, offsets = starts + 2 * count, starts + 4 * count
            for seg in range(count):
                for cp in range(u16(starts + 2 * seg), u16(ends + 2 * seg) + 1):
                    delta, ro = u16(deltas + 2 * seg), u16(offsets + 2 * seg)
                    glyph = (cp + delta) % 65536 if ro == 0 else u16(offsets + 2 * seg + ro + 2 * (cp - u16(starts + 2 * seg)))
                    if glyph:
                        supported.add(cp)
    fvar = tables['fvar'][0]
    axes = []
    for i in range(u16(fvar + 8)):
        p = fvar + u16(fvar + 4) + i * u16(fvar + 10)
        tag, low, default, high = struct.unpack_from('>4siii', data, p)
        axes.append({'tag': tag.decode(), 'min': low / 65536, 'default': default / 65536, 'max': high / 65536})
    missing = [f'U+{ord(c):04X}' for c in SPECIMEN if ord(c) not in supported]
    result = {'file': 'assets/fonts/Geist.ttf', 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data), 'unicodeCoverageCount': len(supported), 'specimen': SPECIMEN, 'missingCodepoints': missing, 'variableAxes': axes, 'evidence': 'SFNT cmap/fvar inspection only; native glyph rendering still requires visual QA'}
    if missing:
        raise ValueError(result)
    return result

if __name__ == '__main__':
    print(json.dumps(inspect_font(), ensure_ascii=True, indent=2))
