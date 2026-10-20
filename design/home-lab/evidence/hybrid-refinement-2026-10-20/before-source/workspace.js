import {mountBackupTools} from './preview-backup.js?v=20261020-hybrid6';
import {mountLogbook} from './logbook.js?v=20261020-hybrid6';
import {mountLibrary} from './library.js?v=20261020-hybrid6';
import {mountSettings} from './settings.js?v=20261020-hybrid6';
import {escapeHTML as esc} from './night-ui.js?v=20261020-hybrid6';

const $=s=>document.querySelector(s),params=new URLSearchParams(location.search);
const config=await fetch('./tokens.json',{cache:'no-store'}).then(r=>{if(!r.ok)throw Error('Design tokens unavailable');return r.json();}).catch(()=>null);
const tabs={logbook:mountLogbook,library:mountLibrary,settings:mountSettings};
const display={theme:['light','dark','field'].includes(params.get('theme'))?params.get('theme'):'light',scale:['1','1.25','2'].includes(params.get('scale'))?params.get('scale'):'1'};
const variant=Object.hasOwn(config?.variants||{},params.get('variant'))?params.get('variant'):'blend';
document.documentElement.dataset.variant=variant;
const font=params.get('font')||'native';
const paths={moon:'M20 15a8 8 0 0 1-11-11 8 8 0 1 0 11 11Z',book:'M4 3h15v18H4V3Zm0 14h15M8 3v14',library:'M4 7h16v14H4V7Zm-1-4h18v4H3V3Zm6 8h6',settings:'M4 6h16M4 12h16M4 18h16M8 3v6m8 0v6m-6 0v6',plus:'M12 5v14M5 12h14',back:'M20 12H4m7-7-7 7 7 7',next:'m9 5 7 7-7 7',camera:'M3 7h4l2-3h6l2 3h4v14H3V7Zm13 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0',pin:'M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0Zm-5 0a3 3 0 1 1-6 0 3 3 0 0 1 6 0',target:'M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-4 0a5 5 0 1 1-10 0 5 5 0 0 1 10 0M12 9v6m-3-3h6',edit:'m4 16 12-12 4 4L8 20H4v-4ZM14 6l4 4',trash:'M4 6h16M9 6V3h6v3M6 6l1 15h10l1-15M10 10v7m4-7v7',check:'m5 12 4 4L19 6',download:'M12 3v12m-5-5 5 5 5-5M4 16v5h16v-5',search:'m16 16 5 5M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0'};
const icon=name=>`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="${paths[name]||paths.next}"/></svg>`;
let lastTab='logbook';try{lastTab=sessionStorage.getItem('culmina-workspace-tab-v1')||lastTab;}catch{}
let tab=Object.hasOwn(tabs,params.get('tab'))?params.get('tab'):Object.hasOwn(tabs,lastTab)?lastTab:'logbook',cleanup=null,back=null,lastTheme=display.theme==='field'?'light':display.theme,timer;
let backArmed=false,handlingPop=false,ignoreNextPop=false;
let storage;try{storage=window.localStorage;}catch{storage={getItem(){throw Error('Browser storage is unavailable');},setItem(){throw Error('Browser storage is unavailable');},removeItem(){throw Error('Browser storage is unavailable');}};}
function homeURL(){const u=new URL('index.html',location.href);for(const[k,v]of Object.entries({...display,variant,font,view:'wide'}))u.searchParams.set(k,v);u.hash='concepts';return u;}
function updateURL(){for(const[k,v]of Object.entries({...display,tab}))params.set(k,v);history.replaceState(history.state||{},'',location.pathname+'?'+params);$('#lab-home').href=homeURL();}
function applyDisplay(patch={}){
  if(!config)return;
  if(['light','dark','field'].includes(patch.theme))display.theme=patch.theme;
  if(['1','1.25','2'].includes(String(patch.scale)))display.scale=String(patch.scale);
  const root=document.documentElement;root.dataset.theme=display.theme;root.dataset.textScale=display.scale;root.style.colorScheme=display.theme==='light'?'light':'dark';
  for(const[k,v]of Object.entries(config.themes[display.theme]))root.style.setProperty('--'+k,v);
  root.style.setProperty('--text-scale',display.scale);
  const family=font==='native'?config.variants[variant].family:font;
  const allowed=['Inter','Roboto','Manrope','IBM Plex Sans','Source Serif 4','Open Sans','Noto Sans','Source Sans 3','Geist','Onest','Golos Text'];
  root.style.setProperty('--lab-font',`'${allowed.includes(family)?family:'Manrope'}',sans-serif`);
  $('#workspace-theme').value=display.theme;$('#workspace-scale').value=display.scale;
  $('#workspace-field').setAttribute('aria-pressed',String(display.theme==='field'));$('#workspace-field').setAttribute('aria-label',display.theme==='field'?'Turn off field mode':'Turn on field mode');
  updateURL();fitPhone();
}
function setHeader(title,backFunction=null){
  if(variant==='blend'&&$('#workspace-title').textContent!==title){
    clearTimeout(timer);$('#workspace-announcement').classList.remove('visible');$('#workspace-announcement').textContent='';
  }
  $('#workspace-title').textContent=title;back=typeof backFunction==='function'?backFunction:null;$('#workspace-back').hidden=!back;$('#workspace-nav').hidden=!!back;$('.android-scroll').scrollTop=0;
  if(!handlingPop){
    if(back&&!backArmed){history.pushState({culminaDetail:true},'',location.href);backArmed=true;}
    else if(!back&&backArmed){backArmed=false;ignoreNextPop=true;history.back();}
  }
}
function announce(message){const n=$('#workspace-announcement');n.textContent=message;n.classList.add('visible');clearTimeout(timer);timer=setTimeout(()=>n.classList.remove('visible'),4500);}
function navigate(next){
  if(!config)return;
  if(next==='home'||next==='tonight'){location.assign(homeURL());return;}
  if(!Object.hasOwn(tabs,next))return;
  if(typeof cleanup==='function')cleanup();cleanup=null;tab=next;try{sessionStorage.setItem('culmina-workspace-tab-v1',tab);}catch{}setHeader(tab[0].toUpperCase()+tab.slice(1));updateURL();
  $('#workspace-nav').innerHTML=[['moon','Tonight','home'],['book','Logbook','logbook'],['library','Library','library'],['settings','Settings','settings']].map(([symbol,label,dest])=>`<button data-tab="${dest}" ${dest===tab?'aria-current="page"':''}>${icon(symbol)}<span>${label}</span></button>`).join('');
  const root=$('#workspace-main');root.className='plan-main';
  try{cleanup=tabs[tab](root,{esc,icon,announce,setHeader,navigate,display,applyDisplay,storage,variant,scenario:$('#workspace-scenario').value,entry:params.get('entry'),editResult:params.get('result')==='1'});if(tab==='logbook'){params.delete('entry');params.delete('result');updateURL();}}
  catch(error){console.error('Culmina tab could not mount:',error);root.innerHTML='<section class="workspace-empty"><h2>Could not open this tab</h2><p>Your stored records have not been changed.</p><button class="secondary-button" id="workspace-retry">Retry</button></section>';$('#workspace-retry').onclick=()=>navigate(tab);}
}
function fitPhone(){const phone=$('.android-device');const top=phone.getBoundingClientRect().top;phone.style.height=Math.max(280,Math.min(852,innerHeight-top-12))+'px';}
$('#workspace-back').innerHTML=icon('back');$('#workspace-field').innerHTML=icon('moon');
// Hybrid feedback owns a layout row. It never floats over records or actions.
if(variant==='blend')$('#workspace-nav').before($('#workspace-announcement'));
$('#workspace-back').onclick=()=>back?.();$('#workspace-nav').onclick=e=>{const b=e.target.closest('[data-tab]');if(b)navigate(b.dataset.tab);};
$('#workspace-theme').onchange=e=>applyDisplay({theme:e.target.value});$('#workspace-scale').onchange=e=>applyDisplay({scale:e.target.value});
$('#workspace-field').onclick=()=>{if(display.theme!=='field')lastTheme=display.theme;applyDisplay({theme:display.theme==='field'?lastTheme:'field'});};
$('#workspace-scenario').value=['ready','empty','error','storage-error'].includes(params.get('scenario'))?params.get('scenario'):'ready';
$('#workspace-scenario').onchange=()=>navigate(tab);
window.addEventListener('resize',fitPhone);new ResizeObserver(fitPhone).observe($('.lab-toolbar'));
window.addEventListener('popstate',async()=>{
  if(ignoreNextPop){ignoreNextPop=false;updateURL();return;}
  if(!backArmed||!back)return;
  backArmed=false;handlingPop=true;
  try{await back();}finally{
    handlingPop=false;
    // A cancelled discard or an editor returning to a detail view still owns Back.
    if(back){history.pushState({culminaDetail:true},'',location.href);backArmed=true;}
    updateURL();
  }
});
if(config){applyDisplay();navigate(tab);mountBackupTools({storage,phone:$('.android-device'),announce});}
else{
  $('#workspace-title').textContent='Preview unavailable';
  $('#workspace-main').innerHTML='<section class="workspace-empty"><h2>Could not load the preview</h2><p>Check that the local server is running, then try again. Your records have not been changed.</p><button class="secondary-button" id="reload-preview">Retry</button></section>';
  $('#reload-preview').onclick=()=>location.reload();fitPhone();
}
