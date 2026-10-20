from PIL import Image,ImageDraw
from pathlib import Path
p=Path(__file__).parent
names=['logbook-detail','logbook-result','library-sites-editor','geolocation','plan-target','plan-rig','plan-context','plan-block','restore-review','restore-error','target-custom-editor','plan-save-error']
for k in range(3):
 out=Image.new('RGB',(412*4,890),'#ddd');d=ImageDraw.Draw(out)
 for i,n in enumerate(names[k*4:k*4+4]):
  f=p/f'{n}.png'
  if f.exists():out.paste(Image.open(f),(i*412,25));d.text((i*412+4,4),n,fill='black')
 out.save(p/f'contact-final{k}.png')
