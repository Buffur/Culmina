import {fixtureNight,weatherForNight,resetCursor} from './night-model.js?v=20261020-hybrid7';
import {timeline,timelineVariants,jumpCursor,updateTimeline,escapeHTML as esc} from './night-ui.js?v=20261020-hybrid7';
import {renderWeatherVariant,updateWeatherSelection} from './weather-variants.js';
import {initPaletteComparison} from './palette-comparison.js';

// Studio-only, no owner storage writes. Each comparison reuses one fixture and one clock.
const $=s=>document.querySelector(s),params=new URLSearchParams(location.search);
const state={theme:['light','dark','field'].includes(params.get('theme'))?params.get('theme'):'light',width:params.get('width')==='412'?'412':'375',scenario:['ready','partial','missing-variable','unknown','stale','no-dark'].includes(params.get('scenario'))?params.get('scenario'):'ready',timeline:timelineVariants.some(v=>v.id===params.get('timeline'))?params.get('timeline'):'gradient',weather:params.get('weather')==='charts'?'charts':'rows'};
const referenceNow=Date.now();
let config,night,weather,cursor,hourIndex=0;
let palettes;
function fixtures(){night=fixtureNight('2026-10-19',state.scenario);weather=weatherForNight(night,state.scenario,referenceNow);cursor=jumpCursor(night,'start').instant;hourIndex=0;}
function syncURL(){for(const [key,value]of Object.entries(state))params.set(key,value);history.replaceState(history.state,'',location.pathname+'?'+params+location.hash);for(const [id,view]of [['open-night','night'],['open-weather','weather']]){const u=new URL('conditions.html',location.href);for(const [k,v]of Object.entries({variant:'blend',theme:state.theme,scale:'1',view,night:night.date,scenario:state.scenario,weatherPresentation:state.weather}))u.searchParams.set(k,v);$(('#'+id)).href=u.href;}}
function display(){const root=document.documentElement;root.dataset.theme=state.theme;root.style.colorScheme=state.theme==='light'?'light':'dark';for(const[k,v]of Object.entries(config.themes[state.theme]))root.style.setProperty('--'+k,v);root.style.setProperty('--study-width',state.width+'px');$('#study-theme').value=state.theme;$('#study-width').value=state.width;$('#study-state').value=state.scenario;$('#shared-context').textContent=`Demonstration data · Europe/Kyiv · ${state.width} CSS px per phone · 100% text. Switching presentation preserves the selected time/hour.`;syncURL();}
function renderTimeline(){const host=$('#timeline-component'),open=host.querySelector('.timeline-exact')?.open;host.innerHTML=timeline(night,cursor,'study',true,true,state.timeline)+'<button type="button" class="secondary-button study-reset" data-study-reset>Reset preview</button>';if(open)host.querySelector('.timeline-exact').open=true;$('#timeline-description').textContent=timelineVariants.find(v=>v.id===state.timeline).description;$('#timeline-choices').querySelectorAll('button').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.timelineChoice===state.timeline)));}
function renderWeather(){const host=$('#weather-component'),open=host.querySelector('.wx-hour-details')?.open;host.innerHTML=renderWeatherVariant(night,weather,state.weather,{selectedIndex:hourIndex});if(open&&host.querySelector('.wx-hour-details'))host.querySelector('.wx-hour-details').open=true;$('#weather-description').textContent='Radix Gray + Blue trial. '+(state.weather==='rows'?'Five separated metric rows with ranges and coverage for the dark hours.':'Five hourly panels on the same time axis, with exact values available below.');$('#weather-choices').querySelectorAll('button').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.weatherChoice===state.weather)));}
function moveCursor(instant){const input=$('[data-night-cursor]');input.value=Math.round((instant-night.start)/60000);cursor=updateTimeline($('[data-timeline]'),night,input.value).instant;}
function selectHour(index){hourIndex=Number(index);updateWeatherSelection($('[data-weather-variant]'),night,weather,hourIndex);}
try{
  config=await fetch('./tokens.json',{cache:'no-store'}).then(r=>{if(!r.ok)throw new Error('Tokens unavailable');return r.json();});
  fixtures();
  $('#timeline-choices').innerHTML=timelineVariants.map(v=>`<button type="button" data-timeline-choice="${v.id}" aria-pressed="${v.id===state.timeline}">${esc(v.label)}</button>`).join('');
  display();renderTimeline();renderWeather();
  palettes=initPaletteComparison({params,getContext:()=>({theme:state.theme,config,night,weather,cursor,weatherPresentation:state.weather}),timeline});
  $('.study-controls').addEventListener('submit',e=>e.preventDefault());
  $('#study-theme').addEventListener('change',e=>{state.theme=e.target.value;display();palettes.render();});
  $('#study-width').addEventListener('change',e=>{state.width=e.target.value;display();});
  $('#study-state').addEventListener('change',e=>{state.scenario=e.target.value;fixtures();display();renderTimeline();renderWeather();palettes.render();});
  $('#timeline-choices').addEventListener('click',e=>{const choice=e.target.closest('[data-timeline-choice]');if(!choice)return;state.timeline=choice.dataset.timelineChoice;renderTimeline();syncURL();});
  $('#weather-choices').addEventListener('click',e=>{const choice=e.target.closest('[data-weather-choice]');if(!choice)return;state.weather=choice.dataset.weatherChoice;renderWeather();palettes.render();syncURL();});
  $('#timeline-component').addEventListener('input',e=>{if(e.target.matches('[data-night-cursor]'))cursor=updateTimeline($('[data-timeline]'),night,e.target.value).instant;});
  $('#timeline-component').addEventListener('click',e=>{const action=e.target.closest('[data-action]')?.dataset.action;if(action==='cursor-start'||action==='cursor-end')moveCursor(jumpCursor(night,action==='cursor-start'?'start':'end').instant);if(e.target.closest('[data-study-reset]')){const r=resetCursor(night,referenceNow);moveCursor(r.label==='Now'?r.instant:jumpCursor(night,'start').instant);}});
  $('#weather-component').addEventListener('input',e=>{if(e.target.matches('[data-weather-slider]'))selectHour(e.target.value);});
  $('#weather-component').addEventListener('click',e=>{const hour=e.target.closest('[data-weather-index]');if(hour)selectHour(hour.dataset.weatherIndex);});
  document.body.dataset.studyReady='true';
}catch(error){$('#study-error').hidden=false;$('#study-error').textContent='The local comparison could not load. Reload the preview. '+error.message;}
