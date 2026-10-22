"""Side-by-side pair: python pair.py left.png right.png out.png [y0 y1] [scale]
Never resizes non-uniformly; both are shown at the same logical scale.
Optional crop window y0..y1 in logical px (applied to both, after DPR normalisation)."""
import sys
from PIL import Image, ImageDraw

a, b, out = sys.argv[1:4]
y0 = int(sys.argv[4]) if len(sys.argv) > 4 else None
y1 = int(sys.argv[5]) if len(sys.argv) > 5 else None
scale = float(sys.argv[6]) if len(sys.argv) > 6 else 1.0
ims = []
for p in (a, b):
    im = Image.open(p).convert('RGB')
    if im.width > 500:  # DPR 2 capture -> logical, proportional
        f = 375 / im.width if im.width in (750,) else 1 / round(im.width / 375)
        im = im.resize((round(im.width * f), round(im.height * f)), Image.LANCZOS)
    if y0 is not None:
        im = im.crop((0, y0, im.width, min(y1, im.height)))
    if scale != 1:
        im = im.resize((round(im.width * scale), round(im.height * scale)), Image.LANCZOS)
    ims.append(im)
h = max(i.height for i in ims)
w = sum(i.width for i in ims) + 12
c = Image.new('RGB', (w, h), (255, 0, 255))
x = 0
for i in ims:
    c.paste(i, (x, 0))
    x += i.width + 12
c.save(out)
print(out, c.size)
