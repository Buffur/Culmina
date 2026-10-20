from PIL import Image,ImageDraw
from pathlib import Path
p=Path(__file__).parent
sets={'states':['weather-unknown','weather-partial','weather-no-dark','weather-no-site','logbook-empty','logbook-error','settings-error','metadata-error'],'deep':['settings-appearance','settings-planning','settings-privacy','settings-about','library-rigs-detail','library-rigs-editor','metadata','welcome']}
for name,names in sets.items():
 out=Image.new('RGB',(412*4,885*2),'#ddd');d=ImageDraw.Draw(out)
 for i,n in enumerate(names):
  im=Image.open(p/f'{n}.png');x=i%4*412;y=i//4*885;out.paste(im,(x,y+25));d.text((x+4,y+4),n,fill='black')
 out.save(p/f'contact-{name}.png')
