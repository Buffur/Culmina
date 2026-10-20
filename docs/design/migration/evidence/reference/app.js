import {browserStorage,readLibraryChoices,readPlanningPreferences,planningBudget,selectLibraryRecord,libraryKey,settingsKey} from './preview-bridge.js?v=20261020-hybrid7';
import { mountCatalog } from './catalog.js?v=20261020-hybrid7';
import {rigFor,targetName,readSavedPlan,planStorageKey,targets,rigs,estimate,duration,defaultPlan,readNavigationDraft,writeNavigationDraft,navigationDraftKey} from './plan-model.js?v=20261020-hybrid7';
import {fixtureDates,fixtureNight,nightLabel as fixtureNightLabel,timeLabel,hoursLabel,totalTime,resetCursor,weatherForNight,currentFixtureNight} from './night-model.js?v=20261020-hybrid7';
import {timeline,updateTimeline,weatherWidgetSummary,dayTag,nightDateLabels} from './night-ui.js?v=20261020-hybrid7';

const localStore=browserStorage();

const config = await fetch('./tokens.json',{cache:'no-store'}).then(response => {
  if (!response.ok) throw new Error('Could not load design tokens');
  return response.json();
});
const [fontSources, referenceData] = await Promise.all([
  fetch('./fonts/sources.json',{cache:'no-store'}).then(response => response.json()),
  fetch('./references.json',{cache:'no-store'}).then(response => response.json())
]);
const root = document.documentElement;
const $ = selector => document.querySelector(selector);
const escapeHtml = value => String(value).replace(/[&<>"']/g, char => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[char]));
const storeKey = 'culmina-home-lab-v2';
const defaults = {theme:'light',font:'native',scale:'1',scenario:'ready',view:'compare',variant:'blend',family:'hybrid',homeOrder:'plan-first',sky:'dusk',choice:null};
let saved = {};
try { saved = JSON.parse(localStore.getItem(storeKey) || '{}') || {}; } catch { /* Private browsing still works. */ }
const params = Object.fromEntries(new URLSearchParams(location.search));
const state = {...defaults,...saved,...params};
const allowed = {theme:['light','dark','field'],font:['native',...fontSources.map(item=>item.family)],scale:['1','1.25','2'],scenario:['ready','unknown','empty','no-site','loading','error','no-dark','partial','stale','offline'],view:['compare','wide'],variant:Object.keys(config.variants),family:['hybrid','all'],sky:['dusk','slate','ink'],homeOrder:['plan-first','conditions-first']};
for (const [key,values] of Object.entries(allowed)) if (!values.includes(state[key])) state[key] = defaults[key];
if (!allowed.variant.includes(state.choice)) state.choice = null;
const visibleKeys = () => Object.keys(config.variants).filter(key=>state.family==='all'||config.variants[key].familyGroup==='hybrid');
if(!visibleKeys().includes(state.variant)) state.family='all';
for(const [name,value] of Object.entries(config.space)) root.style.setProperty('--space-'+name,`${value}px`);
for(const [name,value] of Object.entries(config.productionRadius)) root.style.setProperty('--radius-'+name,`${value}px`);
const fixture = {site:'Kyiv outskirts',night:'2026-10-19',target:'Andromeda Galaxy',catalog:'M31',resultDue:true};
let previewPlan=null,activePlanState=null;
function refreshActivePlan(){try{const checkpoint=readNavigationDraft(localStore),savedPlan=readSavedPlan(localStore);previewPlan=checkpoint?.plan||savedPlan||defaultPlan();activePlanState=checkpoint||{plan:previewPlan,savedSnapshot:JSON.stringify(previewPlan),hasSaved:true};Object.assign(fixture,{site:previewPlan.site,night:previewPlan.night,catalog:previewPlan.target,target:targetName(previewPlan)});}catch{previewPlan=defaultPlan();activePlanState={plan:previewPlan,savedSnapshot:JSON.stringify(previewPlan),hasSaved:true};}}
refreshActivePlan();
if(!previewPlan.site)state.scenario='no-site';else if(!previewPlan.target)state.scenario='empty';
const homeCursors=new Map();
function homeNight(){return fixtureNight(fixture.night,state.scenario==='ready'?(previewPlan?.exampleScenario||'ready'):state.scenario);}
function updateHomePlanContext(){const current=readNavigationDraft(localStore)||activePlanState;const copy=structuredClone(current.plan),choices=readLibraryChoices(localStore);if(copy.site!==fixture.site)selectLibraryRecord(copy,'site',fixture.site,choices);if(copy.target!==fixture.catalog)selectLibraryRecord(copy,'target',fixture.catalog,choices);copy.night=fixture.night;const updated={...current,plan:copy};try{writeNavigationDraft(localStore,updated);refreshActivePlan();}catch{toast('Could not keep this draft in browser storage.');}}
function conditionsURL(view,conceptKey){const u=new URL('./conditions.html',location.href);for(const [key,value] of Object.entries({view,from:'home',sky:state.sky,night:fixture.night,planNight:fixture.night,site:fixture.site,theme:state.theme,scale:state.scale,font:state.font,variant:conceptKey||state.variant,scenario:state.scenario==='ready'?(previewPlan?.exampleScenario||'ready'):state.scenario}))u.searchParams.set(key,value);return u.href;}
const homePositionKey='culmina-home-position-v1';
function homePositions(){try{return JSON.parse(sessionStorage.getItem(homePositionKey)||'{}');}catch{return {};}}
window.addEventListener('pagehide',()=>{try{const positions={};for(const e of document.querySelectorAll('.concept'))positions[e.dataset.variant+fixture.night]=e.querySelector('.phone-viewport')?.scrollTop||0;sessionStorage.setItem(homePositionKey,JSON.stringify(positions));}catch{}});
let toastTimer;
let sampleFamily = 'Manrope';
let suppressRailScroll = false;
$('#font').innerHTML = '<option value="native">За задумом варіанта</option>' + fontSources.map(item=>`<option value="${item.family}">${item.family}${item.family==='Source Serif 4'?' + Inter':''}</option>`).join('');

const paths = {
  moon:'M20.9 13A9 9 0 0 1 11 3.1 9 9 0 1 0 20.9 13Z',
  sun:'M12 3v2m0 14v2M3 12h2m14 0h2M5.6 5.6 7 7m10 10 1.4 1.4M5.6 18.4 7 17M17 7l1.4-1.4M16 12a4 4 0 1 1-8 0 4 4 0 0 1 8 0Z',
  cloud:'M6 18a4 4 0 0 1-.7-7.9A6 6 0 0 1 17 8a5 5 0 1 1 1 10H6Z',
  chevron:'m9 5 7 7-7 7',down:'m6 9 6 6 6-6',arrow:'M4 12h15m-6-6 6 6-6 6',check:'m5 12 4 4L19 6',
  planner:'M7 3v4m10-4v4M4 10h16M6 5h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2Zm3 10h6',
  book:'M4 4h6a2 2 0 0 1 2 2v14a3 3 0 0 0-3-2H4V4Zm16 0h-6a2 2 0 0 0-2 2v14a3 3 0 0 1 3-2h5V4Z',
  library:'M4 8h16v12H4V8Zm-1-4h18v4H3V4Zm6 8h6',settings:'M4 6h16M4 12h16M4 18h16M8 3v6m8 0v6M9 15v6',
  pin:'M19 10c0 5-7 11-7 11S5 15 5 10a7 7 0 1 1 14 0Zm-7-2a2 2 0 1 0 0 4 2 2 0 0 0 0-4Z',
  close:'m6 6 12 12M6 18 18 6',edit:'m4 16 12-12 4 4L8 20H4v-4Zm10-10 4 4',search:'M17 10a7 7 0 1 1-14 0 7 7 0 0 1 14 0Zm-2 5 6 6',
  info:'M12 11v6m0-10v.1M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0Z'
};
const icon = (name, className='') => `<svg class="${className}" viewBox="0 0 24 24" aria-hidden="true"><path d="${paths[name] || paths.info}"/></svg>`;
$('#close-detail').innerHTML = icon('close');
const isTonight = () => fixture.night === currentFixtureNight();
const nightLabel = () => fixtureNightLabel(fixture.night);
const pageTitle = () => isTonight() ? 'Tonight' : 'Night of '+new Intl.DateTimeFormat('en-GB',{day:'numeric',month:'short',timeZone:'UTC'}).format(Date.parse(fixture.night+'T12:00Z'));
const candidateLabel = () => isTonight() ? 'What can I image tonight?' : `What can I image on ${nightLabel().split('–')[0]}?`;

function persist() {
  try { localStore.setItem(storeKey,JSON.stringify(state)); } catch { /* Persistence is optional. */ }
}
function toast(message) {
  clearTimeout(toastTimer);
  $('#toast').textContent = message;
  $('#toast').classList.add('visible');
  toastTimer = setTimeout(() => $('#toast').classList.remove('visible'),4200);
}
function applyTheme() {
  root.dataset.theme = state.theme;
  root.dataset.sky = ['dusk','slate','ink'].includes(state.sky)?state.sky:'dusk';
  root.dataset.textScale = state.scale;
  root.style.colorScheme = state.theme === 'light' ? 'light' : 'dark';
  for (const [name,value] of Object.entries(config.themes[state.theme])) root.style.setProperty(`--${name}`,value);
  root.style.setProperty('--text-scale',state.scale);
  document.querySelectorAll('[data-theme-choice]').forEach(button => button.setAttribute('aria-pressed',String(button.dataset.themeChoice === state.theme)));
  document.dispatchEvent(new CustomEvent('culmina-theme',{detail:state.theme}));
}
function condition(name,label,value,extra,action,join='') {
  return `<button class="condition-row${join?' '+join:''}" data-action="${action}">${icon(name)}<span class="condition-text"><span class="condition-label">${label}</span><span class="condition-value numeral">${value}</span><span class="condition-extra">${extra}</span></span>${icon('chevron','chevron')}</button>`;
}
function conditions(key='blend') {
  if(key==='blend'&&(previewPlan?.siteSnapshot||previewPlan?.targetSnapshot))return `<section class="conditions"><h4 class="home-section-title">The night ahead</h4><p>Conditions unknown for this Library context.</p>${condition('moon','Night & Moon','Unknown','Custom coordinates need astronomical calculations','night')}${condition('cloud','Weather','Unknown','No forecast for this saved site','weather','weather-row')}</section>`;
  const n=homeNight(),w=weatherForNight(n,state.scenario,Date.now()),reset=resetCursor(n),cursor=homeCursors.get(key+fixture.night)??reset.instant;
  const range=x=>timeLabel(x.start)+'–'+timeLabel(x.end)+dayTag(n,x.end);
  const dark=n.dark.length?n.dark.map(range).join(', '):'No dark time this night';
  const moonFree=!n.dark.length?'No dark time, so no moon-free dark':!n.moonFree.length?'Moon above the horizon through dark time':`Moon-free ${n.moonFree.map(range).join(', ')} · ${hoursLabel(totalTime(n.moonFree))}`;
  // One selected night, three questions: when is it dark (row + the band that shows it), what is the
  // Moon doing, what will the weather do during exactly those hours. The band stays attached to the
  // dark-time row it explains; Weather opens its own group.
  return `<section class="conditions" aria-label="Night conditions"><h4 class="home-section-title">The night ahead</h4>
    ${condition('moon','Night',dark,`${hoursLabel(totalTime(n.dark))} dark · ${n.zone}`,'night','joined')}
    ${timeline(n,cursor,'home-'+key,true,key==='blend')}
    ${condition('moon','Moon',`${n.phase} · ${n.illumination}% lit`,moonFree,'moon')}
    ${weatherRow(n,w)}
  </section>`;
}
function weatherRow(n,w) {
  const {headline,detail}=weatherWidgetSummary(n,w);
  return condition('cloud','Weather',headline,detail,'weather','weather-row');
}
function homeBudgetSource(){
  if(previewPlan?.assumptions)return 'Example window · plan overrides take priority over Settings.';
  if(readPlanningPreferences(localStore))return 'Example window · current Planning settings apply.';
  if(previewPlan?.budgetSnapshot)return 'Example window · this plan’s saved budget applies.';
  return 'Example window · initial Planning settings apply (5 s between frames; 15% margin).';
}
function plan(key=state.variant) {
  const empty = state.scenario === 'empty';
  const needsSite = state.scenario === 'no-site';
  const needsRig = previewPlan&& !previewPlan.rig;
  const noBlock=previewPlan&&!previewPlan.blocks.some(block=>block.type==='Light');
  const missing = empty || needsSite || needsRig || noBlock;
  const previewEstimate=previewPlan?estimate(previewPlan,planningBudget(previewPlan,readPlanningPreferences(localStore,{initialDefaults:key==='blend',plan:previewPlan}),totalTime(fixtureNight(previewPlan.night).targetWindows)/1000)):null;
  const preferenceChanged=readPlanningPreferences(localStore)&&JSON.stringify(previewEstimate?.assumptions)!==JSON.stringify(previewPlan?.budgetSnapshot||{});
  return `<section class="plan-section" aria-label="Your plan"><div class="plan-heading-row"><h4 class="home-section-title">Your plan</h4><span class="saved-label">${icon(empty||!activePlanState?.hasSaved||(JSON.stringify(previewPlan)!==activePlanState.savedSnapshot||preferenceChanged)?'edit':'check')}${empty||!activePlanState?.hasSaved?'Not saved':(JSON.stringify(previewPlan)!==activePlanState.savedSnapshot||preferenceChanged)?'Saved · changed':'Saved'}</span></div>
    <p class="target-name">${empty ? 'No target chosen' : escapeHtml(fixture.target)}</p><p class="rig-name">${empty ? 'Choose an object to see whether it fits.' : `${escapeHtml(previewPlan?.targetSnapshot?.catalogId|| (previewPlan?.targetSnapshot?'Your target':fixture.catalog))} · ${escapeHtml(previewPlan?(rigFor(previewPlan)?.name||'No rig selected'):'DSLR · 135 mm lens')}`}</p>
    <p class="fit-line">${icon(missing ? 'info' : 'check')}${needsSite ? 'Needs a site' : empty ? 'Needs a target' : needsRig?'Needs a rig':noBlock?'Needs a block':previewEstimate?.verdict==='Needs window'?'Imaging window unknown':previewEstimate?`${previewEstimate.verdict} in example window`:`Fits ${isTonight() ? 'tonight' : 'this night'}`}</p>
    <p class="plan-reason">${needsSite ? 'Set an observing site to calculate the night and imaging window.' : empty ? 'Choose a catalog object or explore candidates for this site and night.' : needsRig?'Choose a rig to complete this plan.':noBlock?'Add a light block to estimate this capture.':previewEstimate?(key==='blend'?homeBudgetSource():'Time budget uses this plan’s assumptions and current global defaults.'):'Your plan fits within the available imaging window.'}</p>
    ${empty ? `<button class="candidate-button" data-action="targets">Choose a target ${icon('search')}</button>` : missing ? '' : `<dl class="plan-measures"><div><dt>Needed in imaging window</dt><dd>${previewEstimate?duration(previewEstimate.needed):'2 h 15 min'}</dd></div><div><dt>Usable</dt><dd>${previewEstimate?duration(previewEstimate.usable):'4 h 15 min'}</dd></div></dl>`}
    <button class="primary-button" data-action="planner">${icon('planner')}Open planner</button></section>`;
}
function dueResult() {
  let due=true;
  try{const stored=JSON.parse(localStore.getItem('culmina-logbook-preview-v1'));if(stored?.kind==='culmina-logbook-preview'&&Array.isArray(stored.entries)){const entry=stored.entries.find(x=>x.id==='example-m33-2026-10-15');due=!!entry&&!entry.result;}}catch{/* Keep the safe link to the example Logbook. */}
  return due ? `<button class="due-result" data-action="result">${icon('edit')}<span><strong>Record result</strong><br>M33 · 15 Oct · not recorded</span>${icon('chevron')}</button>` : '';
}
function navigation() {
  return `<nav class="app-nav" aria-label="App navigation">${[['moon','Tonight','home'],['book','Logbook','logbook'],['library','Library','library'],['settings','Settings','settings']].map(([name,label,action]) => `<button data-action="${action}" ${action==='home'?'aria-current="page"':''}>${icon(name)}<span>${label}</span></button>`).join('')}</nav>`;
}
function body(key='blend') {
  if (state.scenario === 'loading') return `<section class="state-message" aria-busy="true"><h3>Loading your night…</h3><p>Preparing the site, conditions and current plan.</p><div class="loading-lines" aria-hidden="true"><span></span><span></span><span></span><span></span></div><button class="candidate-button" data-action="retry">Finish demo loading ${icon('arrow')}</button></section>`;
  if (state.scenario === 'error') return `<section class="state-message">${icon('info')}<h3>Couldn't load your plan</h3><p>Your site, settings and current plan couldn't be loaded. Retry to show the example again.</p><button class="primary-button" data-action="retry">Retry</button></section>`;
  if (state.scenario === 'no-site') return `<section class="state-message">${icon('pin')}<h3>Where will you observe?</h3><p>Set up your observing site to see the night, Moon and weather for it.</p><button class="primary-button" data-action="site">Set site</button><button class="candidate-button" data-action="position">Use current position ${icon('arrow')}</button></section>${plan()}`;
  return `<div class="home-body" data-order="${state.homeOrder}">${state.homeOrder==='plan-first'?plan(key)+conditions(key)+(key==='blend'?'':dueResult()):conditions(key)+(key==='blend'?'':dueResult())+plan(key)}${key==='blend'?'<section class="home-actions" aria-label="Next actions">'+dueResult():''}<button class="candidate-button" data-action="candidates">${candidateLabel()}${icon('arrow')}</button>${key==='blend'?'</section>':''}</div>`;
}
function renderConcept(key) {
  const variant = config.variants[key];
  const family = state.font === 'native' ? variant.family : state.font;
  const serif = family === 'Source Serif 4';
  const appFont = serif ? 'Inter' : family;
  const headingFont = serif ? 'Source Serif 4' : appFont;
  const nightHeadingFont = state.font==='native' ? (variant.nightHeading || headingFont) : headingFont;
  const selected = state.choice === key;
  return `<article class="concept variant-${key}${variant.familyGroup==='hybrid'?' hybrid-family':''}" data-variant="${key}" style="--app-font:'${appFont}';--heading-font:'${headingFont}';--night-heading-font:'${nightHeadingFont}';--concept-radius:${config.proposalRadius[key]}px"><div class="concept-heading"><div><h3>${variant.name}</h3><p>${variant.inspiration}</p></div><span class="font-tag">${family}${serif?' + Inter':''}</span></div>
  <div class="preview-well"><div class="app-frame"><div class="phone-viewport"><div class="app-content"><div class="app-brand-row">${key==='blend'?`<button class="app-wordmark" data-action="welcome" aria-label="Welcome and setup">${icon('moon')}<span class="wordmark-copy">culmina<span class="welcome-label">Welcome &amp; setup</span></span></button>`:`<span class="app-wordmark">${icon('moon')}culmina</span>`}<button class="icon-button" data-action="field" aria-label="${state.theme==='field'?'Turn off field mode':'Turn on field mode'}" aria-pressed="${state.theme==='field'}">${icon('moon')}</button></div><h3 class="home-title">${pageTitle()}</h3><p class="home-subtitle">A clear plan for the night ahead.</p><div class="app-context"><button data-action="site">${icon('pin')}${state.scenario==='no-site'?'Set site':escapeHtml(previewPlan?.siteSnapshot?.name||fixture.site)}${icon('down')}</button>${state.scenario==='no-site'?'':`<button data-action="date">${icon('planner')}${key==='blend'?nightDateLabels(fixture.night).night:nightLabel()}${icon('down')}</button>`}</div>${body(key)}</div>${navigation()}</div></div></div>
  <div class="concept-summary"><p>${variant.description}</p><p class="tradeoff">${variant.tradeoff}</p><button class="choose-button" data-choose="${key}" aria-pressed="${selected}">${icon(selected?'check':'arrow')}${selected?'Позначено для обговорення':'Позначити для обговорення'}</button></div></article>`;
}
function render() {
  applyTheme();
  if(!visibleKeys().includes(state.variant)) state.variant=visibleKeys()[0];
  document.querySelectorAll('[data-family-choice]').forEach(button=>button.setAttribute('aria-pressed',String(button.dataset.familyChoice===state.family)));
  for (const key of ['font','scale','scenario','homeOrder','sky']) $(`#${key}`).value = state[key];
  document.querySelectorAll('[data-view]').forEach(button => button.setAttribute('aria-pressed',String(button.dataset.view===state.view)));
  $('#wide-picker').hidden = false;
  $('#wide-picker').innerHTML = visibleKeys().map(key => `<button data-variant-choice="${key}" aria-pressed="${key===state.variant}">${config.variants[key].name}</button>`).join('');
  $('#concept-grid').classList.toggle('wide',state.view==='wide');
  $('#concept-grid').innerHTML = (state.view==='wide' ? [state.variant] : visibleKeys()).map(renderConcept).join('');
  document.querySelectorAll('[data-sample-font]').forEach(button => button.setAttribute('aria-pressed',String(button.dataset.sampleFont===state.font)));
  persist();
  suppressRailScroll = true;
  requestAnimationFrame(()=>{
    const rail=$('#concept-grid');
    const target=rail.querySelector(`[data-variant="${state.variant}"]`);
    if(state.view==='compare'&&target) rail.scrollTo({left:target.offsetLeft,behavior:'instant'});
    else rail.scrollTo({left:0,behavior:'instant'});
    suppressRailScroll=false;
    const positions=homePositions();for(const e of document.querySelectorAll('.concept')){const phone=e.querySelector('.phone-viewport');if(phone)phone.scrollTop=positions[e.dataset.variant+fixture.night]||0;}
    updateCarouselStatus();
  });
}

function updateCarouselStatus() {
  const rail=$('#concept-grid'), keys=visibleKeys();
  if(state.view==='wide') {
    const index=keys.indexOf(state.variant);
    $('#carousel-status').textContent=`${config.variants[state.variant].name} · ${index+1} з ${keys.length} · Android-телефон`;
    $('#previous-design').disabled=index===0;$('#next-design').disabled=index===keys.length-1;return;
  }
  const bounds=rail.getBoundingClientRect();
  const visible=[...rail.children].filter(card=>{const box=card.getBoundingClientRect();return box.right>bounds.left+16&&box.left<bounds.right-16;});
  if(!visible.length)return;
  const first=keys.indexOf(visible[0].dataset.variant),last=keys.indexOf(visible.at(-1).dataset.variant);
  $('#carousel-status').textContent=`${first+1}${last===first?'':`–${last+1}`} з ${keys.length} · стрілки або горизонтальне гортання`;
  $('#previous-design').disabled=rail.scrollLeft<2;$('#next-design').disabled=rail.scrollWidth-rail.clientWidth-rail.scrollLeft<2;
  document.querySelectorAll('[data-variant-choice]').forEach(button=>button.setAttribute('aria-pressed',String(button.dataset.variantChoice===state.variant)));
}
function moveDesign(direction) {
  const keys=visibleKeys();
  if(state.view==='wide') {state.variant=keys[Math.max(0,Math.min(keys.length-1,keys.indexOf(state.variant)+direction))];render();return;}
  const rail=$('#concept-grid'),step=rail.children[0].getBoundingClientRect().width+24;
  rail.scrollBy({left:direction*step,behavior:matchMedia('(prefers-reduced-motion: reduce)').matches?'instant':'smooth'});
}
$('#previous-design').addEventListener('click',()=>moveDesign(-1));
$('#next-design').addEventListener('click',()=>moveDesign(1));
$('#concept-grid').addEventListener('scroll',()=>{if(!suppressRailScroll)updateCarouselStatus();},{passive:true});
$('#concept-grid').addEventListener('keydown',event=>{if(event.target!==event.currentTarget)return;if(['ArrowLeft','ArrowRight'].includes(event.key)){event.preventDefault();moveDesign(event.key==='ArrowRight'?1:-1);}});
window.addEventListener('resize',updateCarouselStatus);
function renderSpecimen() {
  const item=fontSources.find(font=>font.family===sampleFamily);
  $('#specimens').innerHTML=`<article class="specimen specimen-active" style="font-family:'${item.family}',sans-serif"><div class="specimen-top"><h3>${item.family}</h3><span class="font-use">${item.use}</span></div><p class="specimen-en">A clear plan for tonight.</p><p class="specimen-uk" lang="uk">${escapeHtml($('#sample-text').value)}</p><p class="specimen-numbers">0123456789 · 120 × 60 s · −12 °C · 3.6 GB</p><div class="specimen-scale"><p style="font-size:12px">12 px · Дані, одиниці й підписи</p><p style="font-size:14px">14 px · План зйомки на ніч</p><p style="font-size:16px">16 px · Зрозумілий наступний крок</p><p style="font-size:24px">24 px · Tonight</p><p style="font-size:32px">32 px · Your plan</p></div><div class="specimen-actions"><button data-sample-font="${item.family}" aria-pressed="${state.font===item.family}">Застосувати до макетів</button><a href="fonts/${item.slug}-OFL.txt">SIL OFL 1.1</a></div></article>`;
  document.querySelectorAll('[data-specimen-family]').forEach(button=>button.setAttribute('aria-pressed',String(button.dataset.specimenFamily===sampleFamily)));
}
$('#font-picker').innerHTML=fontSources.map(item=>`<button data-specimen-family="${item.family}" aria-pressed="${item.family===sampleFamily}"><span>${item.family}</span><small>${item.use}</small></button>`).join('');
$('#sample-text').addEventListener('input',renderSpecimen);
$('#font-research').innerHTML='<thead><tr><th>Сімейство</th><th>Орієнтир</th><th>Google popularity</th><th>Локальні subsets</th></tr></thead><tbody>'+fontSources.map(item=>`<tr><th><a href="https://fonts.google.com/specimen/${encodeURIComponent(item.family)}" target="_blank" rel="noreferrer">${item.family}</a></th><td>${item.use}</td><td>${item.popularityIndex}</td><td>${item.subsets.filter(value=>value!=='menu').join(', ')}</td></tr>`).join('')+'</tbody>';
$('#reference-list').innerHTML=referenceData.items.map(item=>`<details class="reference-item" name="references"><summary><strong>${item.name}</strong><span>${item.take}</span></summary><div><p><strong>Для Culmina:</strong> ${item.adapt}</p><p>${item.avoid}</p><div class="reference-actions"><a href="${item.url}" target="_blank" rel="noreferrer">Офіційне джерело</a><button data-reference-variant="${item.variant}">Показати концепцію ${config.variants[item.variant].name}</button></div></div></details>`).join('');
renderSpecimen();

let detailPhone=null;
function fitDetail(){if(!detailPhone)return;const r=detailPhone.getBoundingClientRect(),d=$('#detail');for(const [k,v]of Object.entries({left:Math.max(0,Math.min(r.left,innerWidth-r.width)),top:Math.max(0,r.top),width:Math.min(r.width,innerWidth),height:Math.min(r.height,innerHeight-Math.max(0,r.top)-12)}))d.style[k]=v+'px';}
window.addEventListener('resize',fitDetail);window.addEventListener('scroll',()=>{if($('#detail').open)fitDetail();},{passive:true});
function openDetail(title, content,conceptKey=state.variant) {
  const dialog=$('#detail');detailPhone=conceptKey==='blend'?document.querySelector('[data-variant="blend"] .phone-viewport'):null;dialog.classList.toggle('phone-detail',!!detailPhone);if(detailPhone){detailPhone.scrollIntoView({block:'start',inline:'nearest',behavior:'instant'});const family=getComputedStyle(detailPhone).fontFamily;dialog.style.fontFamily=family;dialog.querySelector('.dialog-header>span').textContent='Culmina';dialog.querySelector('#close-detail').setAttribute('aria-label','Back');fitDetail();}else{dialog.removeAttribute('style');dialog.querySelector('.dialog-header>span').textContent='Culmina · приклад взаємодії';}

  $('#detail-body').innerHTML = `<h2 id="detail-title">${title}</h2>${content}`;
  if (!$('#detail').open) $('#detail').showModal();
}
const facts = rows => `<dl class="detail-facts">${rows.map(([label,value])=>`<div><dt>${label}</dt><dd>${value}</dd></div>`).join('')}</dl>`;
const demoNote = '<p>Демонстраційні значення для порівняння дизайну. Це не актуальний прогноз або астрономічний розрахунок.</p>';
function handleAction(action,conceptKey=state.variant) {
  switch(action) {
    case 'home': document.querySelector('.concept-grid').scrollIntoView({behavior:'smooth',block:'start'}); break;
    case 'field': state.theme=state.theme==='field'?'light':'field';render();break;
    case 'retry': state.scenario='ready';render();toast('Демонстраційні дані завантажено.');break;
    case 'position': handleAction('site',conceptKey);break;
    case 'welcome': openDetail('Welcome to Culmina',`<p>Plan a night, save a capture plan, then record what happened.</p><p>Choose a saved observing site or add coordinates in Library. Location permission is requested only when you choose Get location there.</p><p class="preview-note">Browser prototype · example astronomy and weather. Your records stay in this browser.</p>${conceptKey==='blend'?'<div class="dialog-actions">':''}<button class="primary-button" data-action="site">Choose observing site</button><button class="secondary-button" data-action="cancel">Continue with this plan</button>${conceptKey==='blend'?'</div>':''}`,conceptKey);break;
    case 'site': {const sites=[{key:'Kyiv outskirts',name:'Kyiv outskirts'},{key:'Rural site',name:'Rural site'},...readLibraryChoices(localStore).sites];openDetail('Observing site',`<p>Choose for the working plan. Save plan records the change. Cancel leaves the draft unchanged.</p><form id="site-form"><label>Site<select name="site">${sites.map(site=>`<option value="${escapeHtml(site.key)}" ${fixture.site===site.key?'selected':''}>${escapeHtml(site.name)}${site.key.startsWith('library:')?' · Library':''}</option>`).join('')}</select></label><div class="dialog-actions"><button type="button" class="secondary-button" data-action="cancel">Cancel</button><button class="primary-button">Apply site</button></div></form><p>Add or manage coordinates in Library → Sites.</p>`,conceptKey);break;}
    case 'date': openDetail('Choose a night',`<p>Choose for the working plan. Save plan records the change. Cancel leaves the draft unchanged.</p><form id="date-form"><label>Evening date<select name="night">${fixtureDates.map(date=>`<option value="${date}" ${fixture.night===date?'selected':''}>${conceptKey==='blend'?nightDateLabels(date).night:fixtureNightLabel(date)}</option>`).join('')}</select></label>${conceptKey==='blend'?`<p id="home-night-ends">${nightDateLabels(fixture.night).ends}</p>`:''}<div class="dialog-actions"><button type="button" class="secondary-button" data-action="cancel">Cancel</button><button class="primary-button">Apply night</button></div></form>`,conceptKey==='blend'?'blend':state.variant);if(conceptKey==='blend')$('#date-form select').onchange=e=>{$('#home-night-ends').textContent=nightDateLabels(e.target.value).ends;};break;
    case 'night': if(previewPlan?.siteSnapshot||previewPlan?.targetSnapshot){openDetail('Night & Moon','<p>Unknown for these custom coordinates. The browser preview contains example astronomy only.</p>',conceptKey);break;}location.assign(conditionsURL('night',conceptKey));break;
    case 'moon': if(previewPlan?.siteSnapshot||previewPlan?.targetSnapshot){openDetail('Moon','<p>Unknown for these custom coordinates. The browser preview contains example astronomy only.</p>',conceptKey);break;}location.assign(conditionsURL('moon',conceptKey));break;
    case 'weather': if(previewPlan?.siteSnapshot||previewPlan?.targetSnapshot){openDetail('Weather','<p>No forecast is available for this Library context. Unknown is not zero cloud or rain. No weather provider is contacted by this preview.</p>',conceptKey);break;}location.assign(conditionsURL('weather',conceptKey));break;
    case 'retry-weather': $('#detail').close();state.scenario='ready';render();toast('Приклад прогнозу відновлено.');break;
    case 'reset-cursor': {const n=homeNight(),reset=resetCursor(n);homeCursors.set(conceptKey+fixture.night,reset.instant);const box=document.querySelector(`[data-timeline="home-${conceptKey}"]`);if(box){const minutes=Math.round((reset.instant-n.start)/60000);box.querySelector('[data-night-cursor]').value=minutes;updateTimeline(box,n,minutes);}break;}
    case 'planner': {const url=new URL('./plan.html',location.href);for(const [key,value] of Object.entries({variant:conceptKey,theme:state.theme,font:state.font,scale:state.scale,sky:state.sky,scenario:state.scenario,site:state.scenario==='no-site'?'':fixture.site,night:fixture.night,target:state.scenario==='empty'?'':fixture.catalog}))url.searchParams.set(key,value);if($('#detail').open)$('#detail').close();location.assign(url.href);break;}
    case 'targets': case 'candidates': {const choices=readLibraryChoices(localStore);openDetail(action==='targets'?'Choose a target':candidateLabel(),`<p>Bundled examples and your Library targets. Candidate order is illustrative.</p>${choices.targets.map(t=>`<button class="candidate-button" data-target="${escapeHtml(t.id)}"><span>${escapeHtml(t.name)}<br><small>${escapeHtml(t.catalogId||(t.recordId?'Your target':t.id))} · ${t.recordId?'Library record':'bundled example'}</small></span>${icon('arrow')}</button>`).join('')}`,conceptKey);break;}
    case 'result': {const url=new URL('./workspace.html',location.href);for(const[k,v]of Object.entries({tab:'logbook',entry:'example-m33-2026-10-15',result:'1',variant:conceptKey,theme:state.theme,font:state.font,scale:state.scale}))url.searchParams.set(k,v);location.assign(url);break;}
    case 'logbook': case 'library': case 'settings': {const url=new URL('./workspace.html',location.href);for(const[k,v]of Object.entries({tab:action,variant:conceptKey,theme:state.theme,font:state.font,scale:state.scale}))url.searchParams.set(k,v);location.assign(url);break;}
    case 'cancel': $('#detail').close();break;
  }
}
document.addEventListener('click',event => {
  const button = event.target.closest('button');
  if (!button) return;
  if (button.dataset.themeChoice) {state.theme=button.dataset.themeChoice;render();}
  if (button.dataset.view) {state.view=button.dataset.view;render();}
  if (button.dataset.familyChoice) {state.family=button.dataset.familyChoice;render();}
  if (button.dataset.variantChoice) {state.variant=button.dataset.variantChoice;render();}
  if (button.dataset.specimenFamily) {sampleFamily=button.dataset.specimenFamily;renderSpecimen();}
  if (button.dataset.referenceVariant) {state.variant=button.dataset.referenceVariant;state.family=config.variants[state.variant].familyGroup==='hybrid'?'hybrid':'all';state.view='compare';render();$('#concepts').scrollIntoView({block:'start'});}
  if (button.dataset.choose) {state.choice=state.choice===button.dataset.choose?null:button.dataset.choose;render();toast(state.choice?`${config.variants[state.choice].name} позначено для обговорення. Це не змінює production.`:'Позначку знято.');}
  if (button.dataset.sampleFont) {state.font=button.dataset.sampleFont;render();toast(`${state.font} застосовано до всіх макетів.`);}
  if (button.dataset.action) handleAction(button.dataset.action,button.closest('.concept')?.dataset.variant||state.variant);
  if (button.dataset.dialogTheme) {state.theme=button.dataset.dialogTheme;render();$('#detail').close();}
  if (button.dataset.target) {fixture.catalog=button.dataset.target;fixture.target=readLibraryChoices(localStore).targets.find(t=>t.id===fixture.catalog)?.name||fixture.catalog;state.scenario='ready';updateHomePlanContext();$('#detail').close();render();toast('Target applied to the draft. Save plan records it.');}
});
for (const key of ['font','scale','scenario','homeOrder','sky']) $(`#${key}`).addEventListener('change',event=>{state[key]=event.target.value;render();});
$('#reset').addEventListener('click',()=>{
  Object.assign(state,defaults);Object.assign(fixture,{site:'Kyiv outskirts',night:'2026-10-19',target:'Andromeda Galaxy',catalog:'M31',resultDue:true});
  previewPlan=null;try{localStore.removeItem(planStorageKey);localStore.removeItem(navigationDraftKey);}catch{/* Storage is optional. */}
  refreshActivePlan();history.replaceState(null,'',location.pathname);render();toast('Налаштування й приклади скинуто.');
});
$('#close-detail').addEventListener('click',()=>$('#detail').close());
$('#detail').addEventListener('click',event=>{if(event.target===$('#detail')){const bounds=$('#detail').getBoundingClientRect();if(event.clientX<bounds.left||event.clientX>bounds.right||event.clientY<bounds.top||event.clientY>bounds.bottom)$('#detail').close();}});
document.addEventListener('submit',event=>{
  if (!['site-form','date-form','plan-form','result-form'].includes(event.target.id)) return;
  event.preventDefault();const data=new FormData(event.target);
  if(event.target.id==='site-form'){fixture.site=data.get('site');if(state.scenario==='no-site')state.scenario='ready';}
  if(event.target.id==='date-form') fixture.night=data.get('night');
  if(event.target.id==='plan-form'){fixture.catalog=data.get('target');fixture.target=readLibraryChoices(localStore).targets.find(t=>t.id===fixture.catalog)?.name||fixture.catalog;state.scenario='ready';}
  if(event.target.id==='result-form') fixture.resultDue=false;
  if(['site-form','date-form','plan-form'].includes(event.target.id))updateHomePlanContext();
  $('#detail').close();render();toast('Draft updated. Save plan records it.');
});
render();
await mountCatalog({config,icon,toast});

document.addEventListener('input',event=>{if(!event.target.matches('[data-night-cursor]'))return;const box=event.target.closest('[data-timeline]'),n=homeNight();const f=updateTimeline(box,n,event.target.value);const key=box.dataset.timeline.replace('home-','');homeCursors.set(key+fixture.night,f.instant);});
window.addEventListener('storage',event=>{if([planStorageKey,navigationDraftKey,libraryKey,settingsKey].includes(event.key)){refreshActivePlan();render();}});
