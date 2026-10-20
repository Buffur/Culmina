from PIL import Image,ImageDraw
from pathlib import Path
p=Path('design/home-lab/evidence/hybrid-full-reassessment-2026-10-20/a')
for theme in ['light','dark','field']:
 names=['plan','night','moon','weather','logbook','library','settings']
 out=Image.new('RGB',(412*4,890*2),'#dddddd');d=ImageDraw.Draw(out)
 for i,n in enumerate(names):
  im=Image.open(p/f'{n}-{theme}.png').crop((319,165,731,1025));x=(i%4)*412;y=(i//4)*890;out.paste(im,(x,y+25));d.text((x+5,y+5),n,fill='black')
 out.save(p/f'contact-{theme}.png')
