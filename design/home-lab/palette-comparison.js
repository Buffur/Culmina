import {jumpCursor,updateTimeline} from './night-ui.js?v=20261020-hybrid7';
import {renderWeatherVariant,updateWeatherSelection} from './weather-variants.js';
// Accent studies only. Canvas, surfaces, text, controls and actions stay in the
// existing Culmina light/dark theme. Colours identify data and explicit states.
const tweak='https://github.com/jnsahaj/tweakcn/blob/main/utils/theme-presets.ts';
const palettes=[
  {id:'culmina',name:'Culmina · current accents',note:'Existing quantity colours as the baseline; neutral interface unchanged.',url:'docs'},
  {id:'notion',name:'Notion · Blue & soft states',note:'Homepage blue and pale-blue selection, neutral reading surfaces, compact semantic tags. Dark colours and the sky ramp are Culmina adaptations.',url:'https://www.notion.com/',swatches:['#0075de','#e6f3fe'],light:'#0075de',dark:'#62aff3'},
  {id:'hunt-steel',name:'Reference 1 · Steel blue',note:'Source blue-grey tones identify weather quantities; neutral grey is a swatch, not a replacement canvas.',url:'https://colorhunt.co/palette/334257476072548ca8eeeeee',swatches:['#334257','#476072','#548ca8','#eeeeee'],light:'#476072',dark:'#548ca8',series:{light:['#476072','#548ca8','#334257'],dark:['#548ca8','#476072','#334257']}},
  {id:'hunt-cobalt',name:'Reference 2 · Cobalt blue',note:'Cobalt, mid-blue and periwinkle for primary data; grey stays in the source preview.',url:'https://colorhunt.co/palette/14279b3d56b25c7aeae6e6e6',swatches:['#14279b','#3d56b2','#5c7aea','#e6e6e6'],light:'#3d56b2',dark:'#5c7aea',series:{light:['#14279b','#5c7aea','#3d56b2'],dark:['#5c7aea','#3d56b2','#14279b']}},
  {id:'hunt-indigo',name:'Reference 3 · Night indigo',note:'Muted indigo data colours; the darkest source swatch never replaces the black night interval.',url:'https://colorhunt.co/palette/070f2b1b1a55535c919290c3',swatches:['#070f2b','#1b1a55','#535c91','#9290c3'],light:'#535c91',dark:'#9290c3',series:{light:['#1b1a55','#9290c3','#535c91'],dark:['#9290c3','#535c91','#1b1a55']}},
  {id:'slate-cyan',name:'Radix · Cyan',note:'Cyan11 on weather icons and primary chart lines; status semantics stay independent.',url:'https://www.radix-ui.com/colors/docs/palette-composition/composing-a-palette',light:'#107d98',dark:'#4ccce6'},
  {id:'cosmic-night',name:'Cosmic · Violet',note:'Source violet accents on weather data; neutral surfaces and controls.',url:tweak,light:'#6e56cf',dark:'#a48fff'},
  {id:'starry-night',name:'Starry · Gold',note:'Source yellow accent; a darker gold is adapted for light-mode legibility.',url:tweak,light:'#896200',dark:'#ffe066'},
  {id:'ocean-breeze',name:'Ocean · Mint',note:'Source mint accent, with darker source green for the light theme.',url:tweak,light:'#047857',dark:'#34d399'},
  {id:'happy-hues',name:'Happy Hues · Rose',note:'Source rose accent; a darker rose is adapted for the light theme.',url:'https://www.happyhues.co/palettes/12',light:'#9a4f69',dark:'#eebbc3'},
  {id:'steel-night',name:'Color Hunt · Steel',note:'Blue-grey accents selected from the source palette.',url:'https://colorhunt.co/palette/27374d526d829db2bfdde6ed',light:'#526d82',dark:'#9db2bf'},
];
const skyPalettes=[
  {id:'notion',name:'Notion · Soft blue to black',light:['#e6f3fe','#a6d2f3','#599fd5','#285b90'],dark:['#a6d2f3','#78b5e5','#4388bd','#244f7a']},
  {id:'hunt-steel',name:'Reference 1 · Steel blue',light:['#eeeeee','#548ca8','#476072','#334257'],dark:['#eeeeee','#548ca8','#476072','#334257']},
  {id:'hunt-cobalt',name:'Reference 2 · Cobalt blue',light:['#e6e6e6','#5c7aea','#3d56b2','#14279b'],dark:['#e6e6e6','#5c7aea','#3d56b2','#14279b']},
  {id:'hunt-indigo',name:'Reference 3 · Night indigo',light:['#9290c3','#535c91','#1b1a55','#070f2b'],dark:['#9290c3','#535c91','#1b1a55','#070f2b']},
  {id:'blue',name:'Blue · clear sky',light:['#c8edfa','#83cdea','#439ed6','#2465ad'],dark:['#7dd3fc','#46b6e8','#278ccb','#1d5ea8']},
  {id:'steel',name:'Steel · muted blue',light:['#e0ebe9','#c8dcdd','#a0bbc6','#7797aa'],dark:['#9eb9ba','#86abb6','#678fa5','#456e8b']},
  {id:'indigo',name:'Indigo · blue violet',light:['#e6e7fa','#c6c6ed','#9096d4','#545ea0'],dark:['#bdc4ef','#959ed7','#6879b7','#3d4d85']},
  {id:'aqua',name:'Aqua · cool teal',light:['#d5f1ee','#a7dcd8','#68b2b9','#357486'],dark:['#a1d9d6','#70b9be','#418b9b','#245967']},
  {id:'dusk',name:'Dusk · rose to blue',light:['#f3e2d7','#d6bdce','#9a9cc8','#525f98'],dark:['#dfbfb1','#ba9eb8','#8385b4','#495783']},
];

function rgb(hex){return hex.match(/[a-f\d]{2}/gi).map(x=>parseInt(x,16));}
function luminance(hex){return rgb(hex).map(v=>{v/=255;return v<=.04045?v/12.92:((v+.055)/1.055)**2.4;}).reduce((s,v,i)=>s+v*[.2126,.7152,.0722][i],0);}
function contrast(a,b){const x=luminance(a),y=luminance(b);return (Math.max(x,y)+.05)/(Math.min(x,y)+.05);}
function readable(candidate,backgrounds,fallback,minimum){return backgrounds.every(b=>contrast(candidate,b)>=minimum)?candidate:fallback;}
function fitAccent(colour,backgrounds,theme,minimum=4.5){
  const original=rgb(colour),toward=theme==='light'?0:255;
  for(let step=0;step<=25;step++){
    const candidate='#'+original.map(v=>Math.round(v+(toward-v)*step/25).toString(16).padStart(2,'0')).join('');
    if(backgrounds.every(b=>contrast(candidate,b)>=minimum))return candidate;
  }
  return theme==='light'?'#000000':'#ffffff';
}
function tokens(p,theme,config){
  const base={...config.themes[theme]};
  const accent=theme==='field'?base['text-primary']:p.id==='culmina'?base['text-primary']:fitAccent(p[theme],[base['surface-default'],base['surface-subtle']],theme,3);
  return {...base,'palette-accent':accent};
}

export function initPaletteComparison({params,getContext,timeline}){
  const grid=document.querySelector('#palette-comparison-grid');
  const selected=['paletteA','paletteB'].map((key,i)=>palettes.some(p=>p.id===params.get(key))?params.get(key):['notion','culmina'][i]);
  const selectedSky=['skyA','skyB'].map((key,i)=>skyPalettes.some(p=>p.id===params.get(key))?params.get(key):['notion','blue'][i]);
  const save=()=>{selected.forEach((id,i)=>params.set(i?'paletteB':'paletteA',id));selectedSky.forEach((id,i)=>params.set(i?'skyB':'skyA',id));history.replaceState(history.state,'',location.pathname+'?'+params+location.hash);};
  function render(){
    const {theme,config,night,weather,cursor,weatherPresentation}=getContext();
    document.querySelector('#palette-status').textContent=theme==='field'?'Field mode: existing red/black colours in both samples.':'Neutral interface · palette colours identify weather data · stable green/amber/red status tags · black night';
    grid.innerHTML=selected.map((id,i)=>{
      const p=palettes.find(p=>p.id===id),label=i?'B':'A';
      return `<article class="palette-column"><label class="palette-picker" for="palette-${label}">Sample ${label} · Data accents<select id="palette-${label}" data-palette-slot="${i}">${palettes.map(o=>`<option value="${o.id}"${o.id===id?' selected':''}>${o.name}</option>`).join('')}</select></label><label class="palette-picker palette-sky-picker" for="sky-${label}">Timeline colours<select id="sky-${label}" data-sky-slot="${i}">${skyPalettes.map(o=>`<option value="${o.id}"${o.id===selectedSky[i]?' selected':''}>${o.name}</option>`).join('')}</select></label><p class="palette-source">${p.note} ${p.url==='docs'?'<a href="index.html?variant=blend">Current lab</a>':`<a href="${p.url}" target="_blank" rel="noreferrer">Source palette</a>`}</p><div class="palette-swatches" aria-label="Source colour samples">${(p.swatches||[p.light||'#37352f',p.dark||'#ebebea']).map(hex=>`<span style="--swatch:${hex}" title="${hex}" aria-label="${hex}"></span>`).join('')}</div><div class="study-stage"><div class="android-device study-phone variant-blend palette-phone" data-palette="${id}" data-sky-palette="${selectedSky[i]}" data-sample="${label}"><div class="study-component">
        <p class="palette-eyebrow">Kyiv outskirts · Example night</p><h3>Night of 19 Oct</h3><p class="palette-support">A clear plan for the night ahead.</p>
        <section class="palette-plan"><div class="palette-section-title"><h4>Your plan</h4><span class="palette-saved">✓ Saved</span></div><h4>Andromeda Galaxy</h4><p class="palette-support">M31 · DSLR · 135 mm lens</p><p class="palette-selected">${night.dark.length?'Fits in example window':'No dark time · review this plan'}</p><dl class="palette-metrics"><div><dt>Needed</dt><dd>2 h 10 min</dd></div><div><dt>Usable</dt><dd>${night.dark.length?'4 h 15 min':'No dark time'}</dd></div></dl><button type="button" class="palette-primary" data-palette-demo>Preview action</button><p class="palette-action-result" role="status"></p></section>
        <section class="palette-night"><h4>The night ahead</h4>${timeline(night,cursor,'palette-'+label,true,true,'gradient')}</section>
        <section class="palette-weather"><h4>Weather</h4>${renderWeatherVariant(night,weather,weatherPresentation||'charts',{selectedIndex:0})}<label class="palette-input">Dew margin threshold<input type="text" value="2 °C" readonly></label></section>
        <section class="palette-states"><h4>State examples</h4><p data-palette-state="success">✓ Saved · operation completed</p><p data-palette-state="warning">! Tight · review the fit reason</p><p data-palette-state="error">× Save failed · retry required</p><p class="palette-support">— Unknown · cloud cover unavailable</p><button class="palette-secondary" type="button" disabled>Unavailable action</button></section>
      </div></div></div></article>`;
    }).join('');
    grid.querySelectorAll('.palette-phone').forEach((phone,i)=>{
      const p=palettes.find(p=>p.id===selected[i]),t=tokens(p,theme,config);
      for(const [key,value]of Object.entries(t))phone.style.setProperty('--'+key,value);
      const field=theme==='field';
      if(p.id==='notion'&&!field){
        phone.style.setProperty('--palette-hour-bg',theme==='light'?'#e6f3fe':'#152d40');
        phone.style.setProperty('--palette-hour-text',theme==='light'?'#005bab':'#a6d2f3');
      }
      const semantic={success:field?t['text-primary']:theme==='light'?'#27633d':'#99c5a6',warning:field?t['text-primary']:theme==='light'?'#754600':'#ffca70',error:field?t['text-primary']:t.error};
      for(const [role,value]of Object.entries(semantic)){
        const base=t['surface-subtle'],amount=field?.08:theme==='light'?.09:.10;
        const tint='#'+rgb(base).map((v,j)=>Math.round(v*(1-amount)+rgb(value)[j]*amount).toString(16).padStart(2,'0')).join('');
        phone.style.setProperty('--palette-'+role+'-wash',tint);
        phone.style.setProperty('--palette-'+role,fitAccent(value,[t['surface-default'],t['surface-subtle'],tint],theme));
      }
      if(!field&&p.id!=='culmina'){
        const source=p.series?.[theme]||[p[theme],p[theme],p[theme]],tones=source.map(colour=>fitAccent(colour,[t['surface-default'],t['surface-subtle']],theme,3));
        for(const [role,value]of Object.entries({temperature:tones[0],moisture:tones[1],wind:tones[2],cloud:t['text-secondary'],unknown:t['text-secondary']}))phone.style.setProperty('--data-'+role,value);
      }
      phone.style.setProperty('--palette-selected-text',t['text-primary']);
      const ramp=field?['#800000','#650000','#4d0000','#340000']:skyPalettes.find(s=>s.id===selectedSky[i])[theme];
      ['day','civil','nautical','astro'].forEach((role,j)=>phone.style.setProperty('--sky-'+role,ramp[j]));
      phone.style.setProperty('--sky-dark','#000000');
    });
    save();
  }
  grid.addEventListener('change',e=>{if(!e.target.matches('[data-palette-slot],[data-sky-slot]'))return;const focusId=e.target.id;if(e.target.matches('[data-palette-slot]'))selected[Number(e.target.dataset.paletteSlot)]=e.target.value;else selectedSky[Number(e.target.dataset.skySlot)]=e.target.value;render();document.getElementById(focusId).focus({preventScroll:true});});
  function selectWeather(phone,index){const {night,weather}=getContext();updateWeatherSelection(phone.querySelector('[data-weather-variant]'),night,weather,Number(index));}
  grid.addEventListener('input',e=>{const phone=e.target.closest('.palette-phone');if(!phone)return;const {night}=getContext();if(e.target.matches('[data-night-cursor]'))updateTimeline(phone.querySelector('[data-timeline]'),night,e.target.value);if(e.target.matches('[data-weather-slider]'))selectWeather(phone,e.target.value);});
  grid.addEventListener('click',e=>{
    const button=e.target.closest('[data-palette-demo]');if(button)button.nextElementSibling.textContent='Example action selected · no plan changes';
    const phone=e.target.closest('.palette-phone');if(!phone)return;
    const action=e.target.closest('[data-action]')?.dataset.action;
    if(action==='cursor-start'||action==='cursor-end'){const {night}=getContext(),input=phone.querySelector('[data-night-cursor]');input.value=Math.round((jumpCursor(night,action==='cursor-start'?'start':'end').instant-night.start)/60000);updateTimeline(phone.querySelector('[data-timeline]'),night,input.value);}
    const hour=e.target.closest('[data-weather-index]');if(hour)selectWeather(phone,hour.dataset.weatherIndex);
  });
  document.querySelector('#palette-swap').addEventListener('click',()=>{selected.reverse();selectedSky.reverse();render();});
  render();return {render};
}
