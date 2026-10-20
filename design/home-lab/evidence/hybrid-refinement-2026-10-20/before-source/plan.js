import {weatherFreshnessLabel,nightDateLabels} from './night-ui.js?v=20261020-hybrid6';
import {browserStorage,readLibraryChoices,readPlanningPreferences,planningBudget,selectLibraryRecord,libraryKey,settingsKey} from './preview-bridge.js?v=20261020-hybrid6';
document.documentElement.dataset.sky=['dusk','slate','ink'].includes(new URLSearchParams(location.search).get('sky'))?new URLSearchParams(location.search).get('sky'):'dusk';
import {targets as bundledTargets,rigs as bundledRigs,rigFor,targetName,defaultPlan,defaultBlock,newBlock,parseExposure,blockProblems,estimate,duration,assumptionsFor,readSavedPlan,savePlanRecord,saveProblem,readNavigationDraft,writeNavigationDraft,planStorageKey,navigationDraftKey,
  targetSample,catalogObjectCount,searchTargets,cameraClassLabels,trackingLabels,whiteBalancePresets,whiteBalanceLimits,tintApplies,whiteBalanceText,whiteBalanceEditErrors,planRelativeCurve,blockSteps} from './plan-model.js?v=20261020-hybrid6';
import {fixtureDates,fixtureNight,nightLabel,timeLabel,hoursLabel,totalTime,weatherForNight,zone,fixtureNow,retrievedAt} from './night-model.js?v=20261020-hybrid6';

// Browser prototype of the Android Plan screen. All numbers come from the
// explicit fixtures in plan-model.js / night-model.js, never from astronomy,
// weather providers or measured files.

const localStore=browserStorage();

const config=await fetch('./tokens.json',{cache:'no-store'}).then(r=>{if(!r.ok)throw new Error('Design tokens unavailable');return r.json();});
const $=selector=>document.querySelector(selector);
const esc=value=>String(value??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const lc=text=>text.charAt(0).toLowerCase()+text.slice(1);
const params=new URLSearchParams(location.search);
const variant=Object.hasOwn(config.variants,params.get('variant'))?params.get('variant'):'blend';
const fontNames=['native','Inter','Roboto','Manrope','IBM Plex Sans','Source Serif 4','Open Sans','Noto Sans','Source Sans 3','Geist','Onest','Golos Text'];
const font=fontNames.includes(params.get('font'))?params.get('font'):'native';
const display={theme:['light','dark','field'].includes(params.get('theme'))?params.get('theme'):'light',scale:['1','1.25','2'].includes(params.get('scale'))?params.get('scale'):'1'};
const SCENARIOS=['ready','unknown','empty','no-site','no-rig','save-error'];
let libraryChoices=readLibraryChoices(localStore);
const rigs={...libraryChoices.rigs},targets={...bundledTargets,...Object.fromEntries(libraryChoices.targets.map(t=>[t.id,t.name]))};
const allTargets=()=>libraryChoices.targets;
const findTargets=q=>searchTargets(q,allTargets());
const SITES=['Kyiv outskirts','Rural site',...libraryChoices.sites.map(s=>s.key)];
const currentBudget=()=>planningBudget(plan,readPlanningPreferences(localStore),plan?.siteSnapshot||plan?.targetSnapshot?null:totalTime(fixtureNight(plan.night).targetWindows)/1000);
const currentAssumptions=()=>assumptionsFor(plan,currentBudget());
const currentEstimate=()=>estimate(plan,currentBudget());
const FRAME_TYPES=['Light','Dark','Flat','Bias'];
const WHITE_BALANCE=['Unrecorded','Auto',...whiteBalancePresets,'Kelvin','Custom'];
const CALIBRATION_TYPES=['Dark','Flat','Bias'];
const GAIN_VIEWS={curve:'A · Time curve (default)',bars:'B · Group bars',steps:'C · Block steps',all:'Compare all three'};
const MAX_GAIN_PANELS=6;
const SCREEN_KINDS=['block','calibration','context','target','rig','assumptions'];
const ASSUMPTION_FIELDS=[
  {name:'perFrameOverhead',label:'Time between frames (seconds)',hint:'Download, dither or settle time added to every frame.',max:3600},
  {name:'outsideSetup',label:'Setup outside the window (minutes)',hint:'Set-up and alignment done before the imaging window.',max:720},
  {name:'fitMargin',label:'Fit margin (minutes)',hint:'Fixed minutes for this plan. The global margin is a percentage of the usable window; this override takes priority.',max:720},
  {name:'bytesPerFrame',label:'Theoretical file size per frame (MB)',hint:'A planning figure, not measured from your files.',max:10000,positive:true}
];
const icons={
  chevron:'<svg class="row-chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="m9 6 6 6-6 6"/></svg>',
  up:'<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 19V5m-6 6 6-6 6 6"/></svg>',
  down:'<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14m-6-6 6 6 6-6"/></svg>'
};
// One line icon per CameraClass, the rig property that decides the block fields.
const classIcons={
  phone:'<rect x="7" y="3" width="10" height="18" rx="2"/><path d="M11 18h2"/>',
  dslrMirrorless:'<path d="M4 8h3l1.5-2h7L17 8h3v11H4z"/><circle cx="12" cy="13.5" r="3.5"/>',
  astroColour:'<circle cx="12" cy="12" r="8.5"/><rect x="9" y="9.5" width="6" height="5" rx=".5"/>',
  astroMono:'<circle cx="12" cy="12" r="8.5"/><rect x="9" y="9.5" width="6" height="5" rx=".5"/>',
  unknown:'<circle cx="12" cy="12" r="8.5" stroke-dasharray="3 2.4"/><path d="M9.8 9.6a2.3 2.3 0 1 1 3.3 2.1c-.7.3-1.1.8-1.1 1.5v.5M12 16.4v.1"/>'
};
const classIcon=rig=>`<svg class="rig-icon" viewBox="0 0 24 24" aria-hidden="true">${classIcons[rig?.cameraClass]||classIcons.unknown}</svg>`;

let scenario=SCENARIOS.includes(params.get('scenario'))?params.get('scenario'):'ready';
// Lab review control (outside the phone): which stacking-gain graph Details shows.
let gainView=Object.hasOwn(GAIN_VIEWS,params.get('gain'))?params.get('gain'):'curve';
let plan,savedSnapshot,hasSaved,stack=[],mainScroll=0,pendingFeedback='';
let undo=null,saveFailure='',failedOnce=false,checkpointError=false,leaveIntent='home',announcementTimer;
const openDisclosures=new Set();

/* ---------- State, persistence and lifecycle ---------- */

function loadInitialState(fromStorage=false){
  stack=[];mainScroll=0;pendingFeedback='';openDisclosures.clear();
  let saved=null,checkpoint=null;
  try{saved=readSavedPlan(localStore);checkpoint=readNavigationDraft(localStore);}catch{/* Storage may be unavailable; the page still works in memory. */}
  if(checkpoint){
    // The working checkpoint wins over URL context: it carries the latest edits.
    plan=checkpoint.plan;includeSnapshotChoices();savedSnapshot=checkpoint.savedSnapshot;hasSaved=checkpoint.hasSaved;
    stack=restoreStack(checkpoint.editor?.stack);
    for(const name of checkpoint.editor?.disclosures||[])if(['budget','gain','rig'].includes(name))openDisclosures.add(name);
    if(!fromStorage&&checkpoint.scenario!==scenario&&['empty','no-site','no-rig'].includes(scenario))applyScenarioToPlan();
    mainScroll=Number(checkpoint.editor?.mainScroll)||0;
    pendingFeedback=typeof checkpoint.feedback==='string'?checkpoint.feedback:'';
    return;
  }
  const base=saved||defaultPlan();
  plan=structuredClone(base);includeSnapshotChoices();savedSnapshot=JSON.stringify(base);hasSaved=true;
  const allowed={target:['',...Object.keys(targets)],rig:['',...Object.keys(rigs)],site:['',...SITES],night:fixtureDates};
  for(const [name,list] of Object.entries(allowed))if(!fromStorage&&params.has(name)&&list.includes(params.get(name)))plan[name]=params.get(name);
  if(!fromStorage&&applyScenarioToPlan()){hasSaved=false;savedSnapshot=JSON.stringify(plan);}
}
function applyScenarioToPlan(){
  if(scenario==='empty'){plan.target='';return true;}
  if(scenario==='no-site'){plan.site='';return true;}
  if(scenario==='no-rig'){plan.rig='';return true;}
  return false;
}
function restoreStack(raw){
  if(!Array.isArray(raw))return [];
  return raw.slice(0,3).filter(s=>s&&SCREEN_KINDS.includes(s.kind)&&s.draft&&typeof s.draft==='object'&&typeof s.original==='string').filter(s=>{
    if(s.kind==='block')return s.base&&typeof s.base==='object'&&typeof s.blockId==='string'&&(s.isNew||plan.blocks.some(b=>b.id===s.blockId));
    if(s.kind==='calibration')return plan.blocks.some(b=>b.type==='Light')&&CALIBRATION_TYPES.every(t=>s.draft.rows?.[t]&&typeof s.draft.rows[t].count==='string');
    return true;
  }).map(s=>{
    const screen={...s,errors:s.errors&&typeof s.errors==='object'?s.errors:{}};
    if(s.kind==='target')screen.query=typeof s.query==='string'?s.query.slice(0,100):'';
    if(s.kind==='block'){const fallback=blockToDraft(s.base);screen.draft=Object.fromEntries(Object.keys(blockToDraft(defaultBlock())).map(k=>[k,String(s.draft[k]===undefined?(fallback[k]??''):s.draft[k]??'')]));}
    const keys=s.kind==='context'?['site','night']:s.kind==='assumptions'?ASSUMPTION_FIELDS.map(f=>f.name):['calibration','block'].includes(s.kind)?[]:[s.kind];
    if(keys.length)screen.draft=Object.fromEntries(keys.map(k=>[k,String(s.draft[k]??'')]));
    if(s.kind==='calibration')screen.draft={ref:String(s.draft.ref??''),rows:Object.fromEntries(CALIBRATION_TYPES.map(t=>[t,{include:s.draft.rows[t].include===true,count:s.draft.rows[t].count}]))};
    return screen;
  });
}
function persist(){
  try{writeNavigationDraft(localStore,{plan,savedSnapshot,hasSaved,scenario,editor:{stack,mainScroll,disclosures:[...openDisclosures]}});checkpointError=false;return true;}
  catch{checkpointError=true;return false;}
}
function includeSnapshotChoices(){if(plan.rigSnapshot)rigs[plan.rig]=plan.rigSnapshot;if(plan.targetSnapshot)targets[plan.target]=plan.targetSnapshot.name;if(plan.siteSnapshot&&!SITES.includes(plan.site))SITES.push(plan.site);}
const budgetChanged=()=>!!readPlanningPreferences(localStore)&&JSON.stringify(currentAssumptions())!==JSON.stringify(plan.budgetSnapshot||{});
const dirty=()=>JSON.stringify(plan)!==savedSnapshot||budgetChanged();
const changed=screen=>JSON.stringify(screen.draft)!==screen.original;
const stateWord=()=>dirty()?(hasSaved?'Saved · changed':'Not saved'):(hasSaved?'Saved':'Not saved');
// Explain the source of a changed budget, not a guessed history of user actions.
// Compare Settings on the saved context so a different night/window is not
// mistaken for a Settings change. This is presentation only.
function settingsBudgetReason(){
  if(variant!=='blend'||!hasSaved||!dirty())return '';
  const preferences=readPlanningPreferences(localStore);
  if(!preferences)return '';
  let saved;
  try{saved=JSON.parse(savedSnapshot);}catch{return '';}
  if(!saved)return '';
  const usable=saved.siteSnapshot||saved.targetSnapshot?null:totalTime(fixtureNight(saved.night).targetWindows)/1000;
  const updated=planningBudget(saved,preferences,usable),baseline=assumptionsFor(saved);
  const differs=Object.keys(updated||{}).some(key=>
    !Number.isFinite(saved.assumptions?.[key])&&!Number.isFinite(plan.assumptions?.[key])&&updated[key]!==baseline[key]);
  return differs?'Settings defaults differ from the saved budget.':'';
}
function assumptionSource(name,{inherit=false}={}){
  if(!inherit&&Number.isFinite(plan.assumptions?.[name]))return 'Plan override';
  if(Number.isFinite(currentBudget()?.[name]))return 'Global default';
  if(Number.isFinite(plan.budgetSnapshot?.[name]))return 'Saved budget';
  return 'Example default';
}
function assumptionFieldSource(screen,name){
  if(screen.inheritDefaults)return `${assumptionSource(name,{inherit:true})} on Apply`;
  if(changed(screen))return 'Plan override on Apply';
  return `Current: ${assumptionSource(name)}`;
}
function assumptionIntro(screen){
  return screen.inheritDefaults?'Apply removes plan overrides. Sources below show what will apply.':'Apply sets all four plan overrides. Use global defaults to remove overrides.';
}
function marginSummary(e){
  if(Number.isFinite(plan.assumptions?.fitMargin)&&e.usable===null)return `Fixed · ${duration(e.assumptions.fitMargin)}. Fit unknown until an imaging window is calculated.`;
  if(e.usable===null)return 'Unknown until an imaging window is calculated';
  if(Number.isFinite(plan.assumptions?.fitMargin))return `Fixed · ${duration(e.assumptions.fitMargin)}`;
  const preferences=readPlanningPreferences(localStore);
  return Number.isFinite(currentBudget()?.fitMargin)
    ?`${preferences.feasibilityMarginPercent}% → ${duration(e.assumptions.fitMargin)}`
    :duration(e.assumptions.fitMargin);
}
const newId=prefix=>`${prefix}-${Date.now().toString(36)}-${Math.random().toString(36).slice(2,7)}`;
const sensitivityOf=rigKey=>rigs[rigKey]?.sensitivity??null;
// CameraClass.offersCameraRecords: white balance and focus mode on light blocks of a phone, camera or Unknown rig.
const cameraRecordsShown=(rigKey,type)=>['phone','dslrMirrorless','unknown'].includes(rigs[rigKey]?.cameraClass)&&type==='Light';
const weekday=date=>new Intl.DateTimeFormat('en-GB',{weekday:'short',timeZone:'UTC'}).format(Date.parse(date+'T12:00Z'));
const nightName=date=>`${weekday(date)} ${nightLabel(date)}`;
const lights=()=>plan.blocks.filter(b=>b.type==='Light');
const position=block=>plan.blocks.indexOf(block)+1;
function formatBytes(bytes){if(bytes>=1e9)return `${(bytes/1e9).toFixed(2)} GB`;return `${Math.round(bytes/1e6)} MB`;}

function savePlan(){
  if(stack.length||saveProblem(plan))return false;
  if(scenario==='save-error'&&!failedOnce){failedOnce=true;saveFailure='Couldn’t save this example plan. Your latest changes are still here.';render();return false;}
  let candidate={...plan,budgetSnapshot:currentAssumptions()};
  try{savePlanRecord(localStore,candidate);plan=candidate;}
  catch{saveFailure='Couldn’t save: browser storage is unavailable. Your changes remain on this page.';render();return false;}
  savedSnapshot=JSON.stringify(plan);hasSaved=true;saveFailure='';undo=null;
  render();announce('Plan saved in this browser.');
  return true;
}
function revertToSource(){
  let source=null;
  if(hasSaved&&savedSnapshot){try{source=JSON.parse(savedSnapshot);}catch{source=null;}}
  if(!source){try{source=readSavedPlan(localStore);}catch{source=null;}source=source||defaultPlan();}
  plan=structuredClone(source);savedSnapshot=JSON.stringify(plan);hasSaved=true;undo=null;saveFailure='';stack=[];
}
function startNewPlan(){
  // A fresh id: savePlanRecord archives the previous canonical record only when this one is saved.
  plan={version:1,id:newId('preview'),target:'',rig:plan.rig,site:plan.site,night:plan.night,blocks:[]};
  savedSnapshot=JSON.stringify(plan);hasSaved=false;undo=null;saveFailure='';stack=[];mainScroll=0;
  render();$('.android-scroll').scrollTop=0;
  $('#plan-main [data-open="target"]')?.focus();
  announce('New plan started. Your saved plan stays unchanged until you save this one.');
}

/* ---------- Navigation ---------- */

function displayParams(){return {...display,font,variant,sky:document.documentElement.dataset.sky};}
function homeURL(){const url=new URL('./index.html',location.href);for(const [k,v] of Object.entries(displayParams()))url.searchParams.set(k,v);url.hash='concepts';return url.href;}
function conditionsScenario(){
  if(['no-dark','moon-all','moon-below','moon-middle','polar-dark','mixed'].includes(plan.exampleScenario))return plan.exampleScenario;
  return ['unknown','save-error'].includes(scenario)?scenario:'ready';
}
function conditionsURL(view){
  const url=new URL('./conditions.html',location.href);
  for(const [k,v] of Object.entries({view,from:'plan',night:plan.night,planNight:plan.night,site:plan.site,...displayParams(),scenario:conditionsScenario()}))url.searchParams.set(k,v);
  return url.href;
}
function navigateToConditions(view){
  // Browsing never saves the canonical plan; the working checkpoint carries the draft there and back.
  if(!stack.length)mainScroll=$('.android-scroll').scrollTop;
  if(!persist()){announce('Couldn’t keep your working plan for this screen: browser storage is unavailable. Nothing was lost here.');render();return;}
  location.assign(conditionsURL(view));
}
function goHome(){location.assign(homeURL());}
function copyToAnotherNight(){
  if(!plan.site){openChoice('context','#plan-menu-button');announce('Choose an observing site before browsing other nights.');return;}
  navigateToConditions('moon');
}
function requestLeave(intent){
  closeMenu(false);
  const editing=stack.length>0;
  if(!dirty()&&!stack.some(changed)){if(intent==='home')goHome();else startNewPlan();return;}
  leaveIntent=intent;
  const problem=saveProblem(plan);
  $('#leave-title').textContent=intent==='new'?'Start a new plan?':'Leave this plan?';
  $('#leave-description').textContent=dirty()?(hasSaved?'Your saved plan has changes that are not saved.':'This plan is not saved yet.'):'An open edit has not been applied.';
  $('#leave-reason').textContent=editing?'Apply or cancel the open edit to use Save.':problem?`To save, ${lc(problem)}`:'';
  $('#leave-error').textContent='';
  const save=$('#leave-save');save.disabled=editing||!!problem;save.textContent=intent==='new'?'Save and start new':'Save and leave';
  $('#leave-plan [data-leave="discard"]').textContent=intent==='new'?'Discard and start new':'Discard';
  $('#leave-plan').showModal();
}
function handleLeave(action){
  const dialog=$('#leave-plan');
  if(action==='cancel'){dialog.close();return;}
  if(action==='discard'){
    revertToSource();dialog.close();
    if(leaveIntent==='home'){persist();goHome();}else startNewPlan();
    return;
  }
  if(savePlan()){dialog.close();if(leaveIntent==='home')goHome();else startNewPlan();}
  else{$('#leave-error').textContent=saveFailure||'Couldn’t save this plan.';$('#leave-save').textContent='Retry save';}
}

/* ---------- Scoped screens ---------- */

function blockToDraft(block){
  return {type:block.type,exposure:String(block.exposure??''),count:String(block.count??''),iso:block.iso==null?'':String(block.iso),gain:block.gain==null?'':String(block.gain),
    binning:String(block.binning??1),whiteBalance:block.whiteBalance||'Unrecorded',kelvin:block.kelvin==null?'':String(block.kelvin),tint:block.tint==null?'':String(block.tint),
    focus:block.focus||'Unrecorded',filter:block.filter??'',placement:block.placement||'window',exposureSource:block.exposureSource||'',exposureNote:block.exposureNote||''};
}
function proposalFor(type){
  if(type==='Flat')return {exposure:'1',note:'Proposal: 1 s flat starting point. Adjust it to your light source.'};
  if(type==='Bias')return {exposure:'1/4000',note:'Proposal: 1/4000 s. Choose the shortest exposure supported by your camera.'};
  if(type==='Dark'){const ref=lights()[0];return ref?{exposure:String(ref.exposure),note:`Proposal: matches the light exposure in block ${position(ref)} (${ref.exposure} s).`}:{exposure:'60',note:'Proposal: 60 s. Set it to your light exposure.'};}
  return {exposure:'60',note:'Proposal: 60 s starting point for a light frame. Replace it with your exposure.'};
}
function screenTitle(screen){return {block:screen.isNew?'Add block':'Edit block',calibration:'Calibration frames',context:'Site and night',target:'Target',rig:'Rig',assumptions:'Plan assumptions'}[screen.kind];}
function openScreen(screen){
  if(!stack.length)mainScroll=$('.android-scroll').scrollTop;
  closeMenu(false);
  stack.push({errors:{},...screen,original:JSON.stringify(screen.draft)});
  render();$('.android-scroll').scrollTop=0;
  const box=$('#block-screen');
  (screen.kind==='block'?$('#block-exposure'):screen.kind==='target'?$('#target-query'):box.querySelector('input[type="radio"]:checked')||box.querySelector('input,select'))?.focus();
}
function closeTop({message='',focus=null}={}){
  const screen=stack.pop();
  render();
  if(!stack.length)$('.android-scroll').scrollTop=mainScroll;
  const target=[focus,screen?.focus,screen?.fallback].map(sel=>sel&&document.querySelector(sel)).find(el=>el&&!el.disabled);
  (target||(stack.length?$('#block-screen'):$('#plan-main')))?.focus();
  if(message)announce(message);
}
function requestCloseScreen(){
  const screen=stack.at(-1);if(!screen)return;
  if(changed(screen))$('#discard-edit').showModal();else closeTop();
}
function openFromKey(key,focus){
  if(key==='light')return openBlockEditor(null,focus);
  if(['site','night','context'].includes(key))return openChoice('context',focus);
  if(key==='target'||key==='rig')return openChoice(key,focus);
}
function openChoice(kind,focus){
  const draft=kind==='context'?{site:plan.site,night:plan.night}:{[kind]:plan[kind]};
  openScreen({kind,draft,...(kind==='target'?{query:''}:{}),focus,fallback:stack.length?'#block-exposure':`#row-${kind}`});
}
function openBlockEditor(id,focus){
  const existing=id?plan.blocks.find(b=>b.id===id):null;
  if(id&&!existing)return;
  if(!existing&&plan.blocks.length>=100){announce('This preview plan holds at most 100 blocks.');return;}
  const proposal=proposalFor('Light');
  const base=existing?structuredClone(existing):{...newBlock(newId('block')),exposure:proposal.exposure,exposureSource:'Proposal',exposureNote:proposal.note};
  openScreen({kind:'block',isNew:!existing,blockId:base.id,base,draft:blockToDraft(base),detailsOpen:false,focus,fallback:'#plan-main [data-add-block]'});
}
function openCalibration(focus){
  const lightBlocks=lights();if(!lightBlocks.length)return;
  openScreen({kind:'calibration',draft:{ref:lightBlocks[0].id,rows:{Dark:{include:true,count:'20'},Flat:{include:true,count:'20'},Bias:{include:true,count:'20'}}},focus,fallback:'#plan-main [data-add-block]'});
}
function assumptionDraft(values){return {perFrameOverhead:String(values.perFrameOverhead),outsideSetup:String(values.outsideSetup/60),fitMargin:String(values.fitMargin/60),bytesPerFrame:String(values.bytesPerFrame/1e6)};}
function openAssumptions(focus){openScreen({kind:'assumptions',draft:assumptionDraft(currentAssumptions()),focus,fallback:'#plan-main [data-edit-assumptions]'});}
function resetAssumptions(){
  const screen=stack.at(-1);if(screen?.kind!=='assumptions')return;
  screen.draft=assumptionDraft(assumptionsFor(variant==='blend'?{...plan,assumptions:undefined}:{},currentBudget()));screen.inheritDefaults=true;screen.errors={};render();
  $('#asm-perFrameOverhead')?.focus();announce('Global defaults selected. Apply changes removes this plan’s overrides.');
}
function applyTypeChange(screen,type){
  // A type change never inherits the light exposure silently: it proposes one and says so.
  const proposal=proposalFor(type),d=screen.draft;
  d.type=type;d.exposure=proposal.exposure;d.exposureSource='Proposal';d.exposureNote=proposal.note;d.placement=type==='Light'?'window':'outside';
}
function focusFirstError(){
  const box=$('#block-screen');
  const error=box.querySelector('.field-error');
  (box.querySelector('[aria-invalid="true"]')||error?.closest('fieldset')?.querySelector('input')||(error&&box.querySelector('input')))?.focus();
}

/* ---------- Applying scoped edits ---------- */

function applyTop(){
  const screen=stack.at(-1);if(!screen)return;
  ({block:applyBlock,calibration:applyCalibration,context:applyContext,target:applyChoice,rig:applyChoice,assumptions:applyAssumptions})[screen.kind](screen);
}
function applyBlock(screen){
  const d=screen.draft,base=screen.base,kind=sensitivityOf(plan.rig);
  const optional=text=>text.trim()===''?null:Number(text.trim());
  const candidate={...base,type:d.type,exposure:d.exposure.trim(),count:d.count.trim(),filter:d.filter.trim(),placement:d.type==='Light'?'window':d.placement,
    exposureSource:d.exposureSource||undefined,exposureNote:d.exposureSource==='Proposal'?d.exposureNote:undefined};
  // Fields hidden for this camera class or frame type keep their stored values untouched.
  const records=cameraRecordsShown(plan.rig,d.type);
  if(kind==='iso')candidate.iso=optional(d.iso);
  if(records)Object.assign(candidate,{whiteBalance:d.whiteBalance,kelvin:d.whiteBalance==='Kelvin'?optional(d.kelvin):base.kelvin,focus:d.focus,tint:tintApplies(d.whiteBalance)?optional(d.tint):base.tint??null});
  if(kind==='gain')Object.assign(candidate,{gain:optional(d.gain),binning:d.binning.trim()===''?Number.NaN:Number(d.binning.trim())});
  // The app's editor bounds apply to a changed white balance; an unchanged earlier record stays applicable.
  const wbTouched=records&&(d.whiteBalance!==(base.whiteBalance||'Unrecorded')||d.kelvin!==(base.kelvin==null?'':String(base.kelvin))||d.tint!==(base.tint==null?'':String(base.tint)));
  screen.errors={...blockProblems(candidate,rigFor(plan),currentAssumptions()),...(wbTouched?whiteBalanceEditErrors(d.whiteBalance,d.kelvin,d.tint):{})};
  if(Object.keys(screen.errors).length){
    if(screen.errors.binning||screen.errors.placement)screen.detailsOpen=true;
    render();focusFirstError();announce('Check the highlighted fields. Your typed values are kept.');return;
  }
  candidate.count=Number(candidate.count);
  const recordKeys=[...(kind==='iso'?['iso']:kind==='gain'?['gain','binning']:[]),...(records?['whiteBalance','kelvin','focus','tint']:[])];
  if(recordKeys.some(k=>JSON.stringify(candidate[k])!==JSON.stringify(base[k])))candidate.source=screen.isNew||!base.source?'Entered':'Edited';
  for(const key of Object.keys(candidate))if(candidate[key]===undefined)delete candidate[key];
  const before=JSON.stringify(plan.blocks),previous=structuredClone(plan.blocks);
  if(screen.isNew)plan.blocks.push(candidate);else plan.blocks=plan.blocks.map(b=>b.id===candidate.id?candidate:b);
  if(JSON.stringify(plan.blocks)!==before)undo={blocks:previous,message:screen.isNew?'Block added.':'Block edited.'};
  closeTop({focus:`#plan-main [data-edit-block="${candidate.id}"]`,message:`${screen.isNew?'Block added':'Block updated'} in this plan. Save plan records it.`});
}
function applyCalibration(screen){
  const d=screen.draft,errors={},included=CALIBRATION_TYPES.filter(t=>d.rows[t].include);
  if(!included.length)errors.none='Choose at least one calibration type, or cancel.';
  for(const t of included){const c=d.rows[t].count.trim();if(!/^\d+$/.test(c)||Number(c)<1||Number(c)>10000)errors[`count-${t}`]='Enter a whole number of frames from 1 to 10000.';}
  if(plan.blocks.length+included.length>100)errors.none='This preview plan holds at most 100 blocks.';
  screen.errors=errors;
  if(Object.keys(errors).length){render();focusFirstError();return;}
  const ref=plan.blocks.find(b=>b.id===d.ref&&b.type==='Light')||lights()[0];
  const added=included.map(t=>{
    const proposal=calibrationProposal(t,ref);
    return {...defaultBlock(newId('block')),type:t,exposure:proposal.exposure,count:Number(d.rows[t].count.trim()),filter:t==='Flat'?ref.filter||'':'',
      iso:ref.iso??null,gain:ref.gain??null,binning:ref.binning??1,placement:'outside',exposureSource:'Proposal',exposureNote:proposal.note,source:`Calibration proposal · references block ${position(ref)}`};
  }).filter(b=>!Object.keys(blockProblems(b,rigFor(plan),currentAssumptions())).length);
  const previous=structuredClone(plan.blocks);
  plan.blocks.push(...added);
  undo={blocks:previous,message:'Calibration frames added.'};
  closeTop({focus:added[0]&&`#plan-main [data-edit-block="${added[0].id}"]`,message:`Added ${added.length} proposed calibration block${added.length===1?'':'s'}. Undo is available.`});
}
function applyContext(screen){
  const d=screen.draft;screen.errors={};
  if(!SITES.includes(d.site))screen.errors.site='Choose an observing site.';
  if(!fixtureDates.includes(d.night))screen.errors.night='Choose one of the example nights.';
  if(Object.keys(screen.errors).length){render();focusFirstError();return;}
  const different=plan.site!==d.site||plan.night!==d.night;
  selectLibraryRecord(plan,'site',d.site,libraryChoices);plan.night=d.night;if(different)undo=null;
  closeTop({message:different?'Site and night applied to this plan. Save plan records it.':''});
}
function applyChoice(screen){
  const kind=screen.kind,value=screen.draft[kind],valid=kind==='target'?Object.hasOwn(targets,value):Object.hasOwn(rigs,value);
  screen.errors=valid?{}:{[kind]:kind==='target'?'Choose a target.':'Choose a rig.'};
  if(!valid){render();focusFirstError();return;}
  const different=plan[kind]!==value;
  selectLibraryRecord(plan,kind,value,libraryChoices);if(different)undo=null;
  closeTop({message:different?`${kind==='target'?'Target':'Rig'} applied to this plan. Save plan records it.`:''});
}
function applyAssumptions(screen){
  if(screen.inheritDefaults){delete plan.assumptions;undo=null;closeTop({message:'Plan overrides removed. Current global defaults now apply; Save plan records the budget.'});return;}
  const values={},errors={};
  for(const f of ASSUMPTION_FIELDS){
    const text=screen.draft[f.name].trim().replace(',','.'),value=Number(text);
    if(text==='')errors[f.name]='Enter a number.';
    else if(!Number.isFinite(value)||value<0)errors[f.name]='Enter zero or a positive number.';
    else if(f.positive&&value<=0)errors[f.name]='Enter a number greater than 0.';
    else if(value>f.max)errors[f.name]=`Enter at most ${f.max}.`;
    values[f.name]=value;
  }
  screen.errors=errors;
  if(Object.keys(errors).length){render();focusFirstError();return;}
  const assumptions={perFrameOverhead:values.perFrameOverhead,outsideSetup:values.outsideSetup*60,fitMargin:values.fitMargin*60,bytesPerFrame:values.bytesPerFrame*1e6};
  if(plan.blocks.some(block=>Object.keys(blockProblems(block,rigFor(plan),assumptions)).length)){screen.errors.perFrameOverhead='These overheads make the capture too large to represent safely. Reduce the frame count or overhead.';render();focusFirstError();return;}
  plan.assumptions=assumptions;
  undo=null;
  closeTop({message:'Assumptions applied to this plan’s estimate. Save plan records them.'});
}

/* ---------- Block list actions ---------- */

function removeBlock(id){
  const index=plan.blocks.findIndex(b=>b.id===id);if(index<0)return;
  const previous=structuredClone(plan.blocks);
  plan.blocks.splice(index,1);undo={blocks:previous,message:'Block removed.'};
  render();$('#plan-main [data-undo]')?.focus();announce('Block removed. Undo is available.');
}
function moveBlock(id,direction){
  const from=plan.blocks.findIndex(b=>b.id===id),to=from+direction;
  if(from<0||to<0||to>=plan.blocks.length)return;
  const [block]=plan.blocks.splice(from,1);plan.blocks.splice(to,0,block);undo=null;
  render();
  const same=document.querySelector(`#plan-main [data-move-block="${id}"][data-dir="${direction}"]`);
  (same&&!same.disabled?same:document.querySelector(`#plan-main [data-edit-block="${id}"]`))?.focus();
  announce(`Moved to position ${to+1} of ${plan.blocks.length}.`);
}
function applyUndo(){
  if(!undo)return;
  plan.blocks=undo.blocks;undo=null;
  render();$('#plan-main [data-add-block]')?.focus();announce('Change undone.');
}

/* ---------- Components: shared ---------- */

function field({id,name,label,value,error,hint,note,attrs=''}){
  const described=[hint&&`hint-${name}`,note!==undefined&&`note-${name}`,error&&`error-${name}`].filter(Boolean).join(' ');
  return `<div class="block-input"><label for="${id}" id="label-${name}">${label}</label><input id="${id}" name="${name}" type="text" value="${esc(value)}" autocomplete="off" ${attrs} ${described?`aria-describedby="${described}"`:''} ${error?'aria-invalid="true"':''}>${hint?`<span id="hint-${name}" class="field-hint">${hint}</span>`:''}${note!==undefined?`<span id="note-${name}" class="field-source">${esc(note)}</span>`:''}${error?`<span id="error-${name}" class="field-error">${esc(error)}</span>`:''}</div>`;
}
function radioGroup({name,legend,options,value,idPrefix,cls='segmented',error}){
  const slug=v=>String(v).replace(/[^A-Za-z0-9]+/g,'-')||'none';
  return `<fieldset class="${cls}" ${error?`aria-describedby="error-${name}"`:''}><legend>${legend}</legend>${options.map(([v,label,caption])=>{const id=`${idPrefix}-${slug(v)}`;return `<label class="choice" for="${id}"><input type="radio" id="${id}" name="${name}" value="${esc(v)}" ${v===value?'checked':''}><span class="choice-text"><span>${esc(label)}</span>${caption?`<small>${esc(caption)}</small>`:''}</span></label>`;}).join('')}${error?`<p id="error-${name}" class="field-error">${esc(error)}</p>`:''}</fieldset>`;
}
function rowButton({key,label,value,caption,icon=''}){
  return `<button class="plan-row" id="row-${key}" data-open="${key}">${icon}<span class="plan-row-text"><span class="plan-row-label">${label}</span><span class="plan-row-value">${value}</span>${caption?`<span class="plan-row-caption">${caption}</span>`:''}</span>${icons.chevron}</button>`;
}
function cameraCaption(rig){
  if(!rig)return '';
  if(rig.sensitivity==='iso')return `${cameraClassLabels[rig.cameraClass]} · ISO, white balance and AF/MF per light block`;
  if(rig.sensitivity==='gain')return `${cameraClassLabels[rig.cameraClass]} · gain per block, binning in Details`;
  return 'Camera type not recorded · choose a rig with a known type to record ISO or gain';
}
const fNumber=n=>`f/${Number(n.toFixed(1))}`;
// Only properties the rig actually records; anything else says so.
function opticsText(rig){
  if(!rig)return '';
  const parts=[rig.focalLengthMm!=null&&`${rig.focalLengthMm} mm`,rig.focalRatio!=null&&fNumber(rig.focalRatio)].filter(Boolean);
  return parts.length?parts.join(' '):'optics not recorded';
}
function rigSummary(rig){
  if(!rig)return '';
  return [cameraClassLabels[rig.cameraClass],opticsText(rig),rig.tracking?trackingLabels[rig.tracking]:'tracking not recorded'].join(' · ');
}
function targetCaption(t){
  if(t.recordId)return `${t.type} · Your Library · RA ${t.raDeg}°, Dec ${t.decDeg}°`;
  const also=[...t.aliasIds,...t.aliasNames.filter(n=>n!==t.name)];
  return `${t.type}${also.length?` · also ${also.join(', ')}`:''}`;
}
function missingItems(){
  return [!plan.site&&{key:'site',label:'Choose an observing site',short:'Choose site'},!plan.target&&{key:'target',label:'Choose a target',short:'Choose target'},
    !plan.rig&&{key:'rig',label:'Choose a rig',short:'Choose rig'},!lights().length&&{key:'light',label:'Add light frames',short:'Add light frames'}].filter(Boolean);
}

/* ---------- Components: Plan screen ---------- */

function identityStrip(){
  const reason=settingsBudgetReason(),date=nightDateLabels(plan.night);
  return `<div class="plan-identity"><span>${variant==='blend'?`${date.night} · ${date.ends}`:`Night of ${nightName(plan.night)}`}</span><span class="plan-state" aria-live="polite" ${reason?'aria-describedby="plan-budget-change"':''}>${stateWord()}</span></div>${reason?`<p id="plan-budget-change" class="plan-budget-change">${esc(reason)}</p>`:''}`;
}
function answerSection(e){
  const missing=missingItems();
  if(missing.length){
    const blocking=missing.some(m=>m.key!=='light');
    return `<section class="plan-answer" aria-labelledby="answer-title"><h2 id="answer-title">${blocking?'Plan incomplete':'Add light frames to estimate'}</h2><p>${missing.length===1?'One step':`${missing.length} steps`} before a fit answer.${saveProblem(plan)?'':' You can already save this plan.'}</p><ul class="plan-checklist" aria-label="To finish this plan">${missing.map(m=>`<li><button class="checklist-item" data-open="${m.key}"><span class="check-mark" aria-hidden="true"></span><span>${m.label}</span>${icons.chevron}</button></li>`).join('')}</ul></section>`;
  }
  const a=e.assumptions;
  if(e.verdict==='Needs window')return `<section class="plan-answer" aria-labelledby="answer-title"><h2 id="answer-title">Imaging window unknown</h2><p>${duration(e.needed)} needed in the imaging window. Your Library selection is copied into this plan; this browser example cannot calculate a window for custom coordinates.</p></section>`;
  if(e.verdict==='No window')return `<section class="plan-answer" aria-labelledby="answer-title"><h2 id="answer-title">No imaging window</h2><p>The example night has no imaging window for this target. Try another night with More › Copy to another night.</p></section>`;
  const spare=e.usable-e.needed;
  const reason=e.verdict==='Fits'?`Leaves ${duration(spare)} spare in the window.`:e.verdict==='Tight'?`Leaves ${duration(spare)}, less than the ${duration(a.fitMargin)} fit margin.`:`${duration(-spare)} more than the window. Remove frames or shorten exposures.`;
  let end='';
  if(e.windowStart!==null&&e.needed>0){
    const finish=e.windowStart+e.needed*1000;
    const endLabel=new Intl.DateTimeFormat('en-GB',{timeZone:zone,day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',hourCycle:'h23',timeZoneName:'shortOffset'}).format(finish);
    end=`<p class="answer-end">Example capture end: ${endLabel}${finish>e.windowEnd?' · beyond the window':''}.</p>`;
  }
  return `<section class="plan-answer" aria-labelledby="answer-title"><h2 id="answer-title">${esc(e.verdict)}</h2><p class="answer-figures">Needed in imaging window: ${duration(e.needed)}<br><span class="answer-usable">${duration(e.usable)} usable</span></p><p>${reason}</p>${end}</section>`;
}
function contextRows(){
  const rig=rigs[plan.rig],target=plan.targetSnapshot||allTargets().find(t=>t.id===plan.target);
  return `<div class="plan-rows">${rowButton({key:'context',label:'Site and night',value:plan.site?esc(plan.siteSnapshot?.name||plan.site):'Choose a site',caption:plan.site?`Site zone: ${esc(plan.siteSnapshot?.zone||zone)}`:'Night conditions need a site'})}${rowButton({key:'target',label:'Target',value:plan.target?`${esc(plan.targetSnapshot?.catalogId||plan.targetSnapshot?.name||plan.target)} · ${esc(targetName(plan))}`:'Choose a target',caption:target?esc(target.type):'Search by name or catalogue number'})}${rowButton({key:'rig',label:'Rig',value:rig?esc(rig.name):'Choose a rig',caption:rig?esc(rigSummary(rig)):'Its camera type decides ISO or gain',icon:rig?classIcon(rig):''})}</div>`;
}
function recordsLine(block){
  const kind=sensitivityOf(plan.rig),focus=!block.focus||block.focus==='Unrecorded'?'unrecorded':esc(block.focus);
  // White balance and focus belong to light blocks; a value kept on another frame type is still shown.
  const camera=block.type==='Light'||(block.whiteBalance&&block.whiteBalance!=='Unrecorded')||(block.focus&&block.focus!=='Unrecorded')?` · WB ${esc(whiteBalanceText(block))} · Focus ${focus}`:'';
  if(kind==='iso')return `ISO ${block.iso??'unrecorded'}${camera}`;
  if(kind==='gain')return `Gain ${block.gain??'unrecorded'} · Binning ${block.binning}×${block.binning}${((block.whiteBalance&&block.whiteBalance!=='Unrecorded')||(block.focus&&block.focus!=='Unrecorded'))?camera+' (kept record)':''}`;
  return plan.rig?`Camera type not recorded · no ISO or gain record${camera}`:'Choose a rig to record ISO or gain';
}
function sourceLine(block){
  return [block.exposureSource==='Proposal'?(block.exposureNote||'Exposure: proposal'):block.exposureSource==='Entered'?'Exposure entered by you':'',block.source?`Records: ${block.source}`:''].filter(Boolean).map(esc).join(' · ');
}
function fitLine(block,e){
  if(block.type!=='Light'&&block.placement==='outside')return 'Outside the imaging window · adds to total time';
  if(e.usable===null)return 'Window capacity unknown for this context';
  if(!e.usable)return plan.site&&plan.target?'No example imaging window this night':'Window capacity unknown until site and target are set';
  const per=parseExposure(block.exposure)+e.assumptions.perFrameOverhead,room=e.usable-(e.needed-per*block.count),capacity=Math.max(0,Math.floor(room/per));
  return block.count<=capacity?`Fits: room for up to ${capacity.toLocaleString('en-GB')} frames like this in the example window`:`Only ${capacity.toLocaleString('en-GB')} of ${block.count} frames fit the example window`;
}
function blockRow(block,index,e){
  const exposure=parseExposure(block.exposure),total=exposure*block.count,n=index+1,last=index===plan.blocks.length-1,source=sourceLine(block);
  // Blank filter means no filter; say so where the filter decides stacking (lights) or matching (flats).
  const filter=block.filter?esc(block.filter):['Light','Flat'].includes(block.type)?'no filter':'';
  return `<li class="capture-block"><h3>${esc(block.type)}${filter?` · ${filter}`:''}</h3>
    <p class="block-math">${block.count} × ${esc(block.exposure)} s = ${duration(total)} ${block.type==='Light'?'integration':'planned calibration, not integration'}</p>
    <p class="block-records">${recordsLine(block)}</p>${source?`<p class="block-source">${source}</p>`:''}
    <p class="block-fit">${fitLine(block,e)}</p>
    <div class="block-actions"><button class="secondary-button" data-edit-block="${esc(block.id)}" aria-label="Edit block ${n}, ${esc(block.type)}">Edit</button><button class="android-icon-button" data-move-block="${esc(block.id)}" data-dir="-1" aria-label="Move block ${n} up" ${index===0?'disabled':''}>${icons.up}</button><button class="android-icon-button" data-move-block="${esc(block.id)}" data-dir="1" aria-label="Move block ${n} down" ${last?'disabled':''}>${icons.down}</button><button class="quiet-button" data-remove-block="${esc(block.id)}" aria-label="Remove block ${n}, ${esc(block.type)}">Remove</button></div></li>`;
}
function captureSection(e){
  const count=plan.blocks.length;
  const list=count?`<ol class="capture-blocks">${plan.blocks.map((b,i)=>blockRow(b,i,e)).join('')}</ol>`:`<div class="empty-blocks"><p>No frames planned yet. You can still save this plan and add frames later.</p><button class="secondary-button" data-add-block>Add light frames</button></div>`;
  return `<section class="capture-section" aria-labelledby="capture-title"><div class="capture-heading"><h2 id="capture-title">Capture plan</h2>${count?`<p>${count} block${count===1?'':'s'} · ${e.frames} frames</p>`:''}</div>${list}
    ${undo?`<div class="undo-row" role="status"><span>${esc(undo.message)}</span><button class="quiet-button" data-undo>Undo</button></div>`:''}
    ${count?`<div class="capture-actions"><button class="secondary-button" data-add-block>Add block</button>${lights().length?'<button class="secondary-button" data-build-calibration>Build calibration frames</button>':''}</div>`:''}</section>`;
}
function estimateSection(e){
  const groups=e.groups;
  const gain=groups.length===1?`×${groups[0].gain.toFixed(2)}`:groups.length?`${groups.length} groups`:'Unknown';
  const gainNote=groups.length===1?`vs one comparable frame · ${groups[0].frames} frames`:groups.length?'per comparable group, listed below':'needs light frames';
  return `<section class="estimate-section" aria-labelledby="estimate-title"><h2 id="estimate-title">Estimate</h2><dl class="estimate-grid">
    <div><dt>Integration</dt><dd class="estimate-value">${duration(e.integration)}</dd><dd>light exposures only</dd></div>
    <div><dt>Total session time</dt><dd class="estimate-value">${duration(e.total)}</dd><dd>with overheads, setup and calibration</dd></div>
    <div><dt>Storage</dt><dd class="estimate-value">${formatBytes(e.bytes)}</dd><dd>theoretical example, not measured</dd></div>
    <div><dt>Relative stacking gain</dt><dd class="estimate-value">${gain}</dd><dd>${gainNote}</dd></div></dl>
    ${groups.length>1?`<ul class="gain-groups">${groups.map(g=>`<li><strong>×${g.gain.toFixed(2)}</strong> vs one comparable frame · ${groupLabel(g)}</li>`).join('')}</ul>`:''}
    <p class="estimate-note">Relative gain is ideal √N within comparable light frames, not absolute signal-to-noise.</p></section>`;
}
function disclosure(key,title,summary,body){
  return `<details class="plan-disclosure" data-disclosure="${key}" ${openDisclosures.has(key)?'open':''}><summary>${title} <span>${summary}</span></summary>${body}</details>`;
}
function budgetDisclosure(e){
  const a=e.assumptions,window=e.usable?`${duration(e.usable)} · ${timeLabel(e.windowStart)}–${timeLabel(e.windowEnd)}`:plan.siteSnapshot||plan.targetSnapshot?'Unknown for custom coordinates':plan.site&&plan.target?'None this night':'Unknown until site and target are set';
  return disclosure('budget','Budget and assumptions','Window time, overheads and file-size basis',`<dl class="assumption-list">
    <div><dt>Needed in imaging window</dt><dd>${duration(e.needed)}</dd></div>
    <div><dt>Time outside the window</dt><dd>${duration(e.outside)}</dd></div>
    <div><dt>Example usable window</dt><dd>${window}</dd></div>
    <div><dt>Between frames${variant==='blend'?` · ${assumptionSource('perFrameOverhead')}`:''}</dt><dd>${a.perFrameOverhead} s per frame</dd></div>
    <div><dt>Setup outside the window${variant==='blend'?` · ${assumptionSource('outsideSetup')}`:''}</dt><dd>${duration(a.outsideSetup)}</dd></div>
    <div><dt>Fit margin${variant==='blend'?` · ${assumptionSource('fitMargin')}`:Number.isFinite(plan.assumptions?.fitMargin)?' · plan override':readPlanningPreferences(localStore)?' · '+readPlanningPreferences(localStore).feasibilityMarginPercent+'% of usable window':' · example default'}</dt><dd>${variant==='blend'?marginSummary(e):e.usable===null?'Unknown until an imaging window is calculated':duration(a.fitMargin)+' (less reads as Tight)'}</dd></div>
    <div><dt>File size basis${variant==='blend'?` · ${assumptionSource('bytesPerFrame')}`:''}</dt><dd>${a.bytesPerFrame/1e6} MB per frame, theoretical, not measured</dd></div></dl>
    <p>The window is an example fixture. Budgets use your recorded values; no astronomy, weather gate or measured files are calculated. ${plan.assumptions?'Explicit plan assumptions override global defaults.':readPlanningPreferences(localStore)?'Current global time budgets apply. Save plan captures these values.':'This plan uses the example defaults.'} Light frames and in-window calibration use window time; integration counts light exposures only.</p>
    <button class="secondary-button" data-edit-assumptions>Edit assumptions</button>`);
}
/* Stacking gain graphs: three reviewable alternatives over the same comparable
   groups (relativeGroups). None combines groups or projects a measurement. */
const times=n=>`×${n.toFixed(2)}`;
function sensitivityName(g){
  if(g.recorded)return `${g.kind==='iso'?'ISO':'gain'} ${g.value}`;
  const kind=sensitivityOf(plan.rig);return `${kind==='iso'?'ISO':kind==='gain'?'gain':'sensitivity'} unrecorded`;
}
function groupName(g){return [g.filter||'No filter',`${g.exposure} s`,sensitivityName(g),g.binning>1&&`bin ${g.binning}`].filter(Boolean).join(' · ');}
function groupLabel(g){return `${g.frames} × ${g.exposure} s · ${esc(g.filter||'no filter')}${g.recorded?'':' · sensitivity unrecorded, kept separate'}`;}
const timeAt=(g,frames)=>`${duration(frames*g.exposure)} (${frames.toLocaleString('en-GB')} frame${frames===1?'':'s'})`;
function shownGroups(groups){return {list:groups.slice(0,MAX_GAIN_PANELS),more:Math.max(0,groups.length-MAX_GAIN_PANELS)};}
// A. The app's own graph (StackingGainGraph, PD-05 O2b): time along x, √(T / T_plan) along y, 1.00× at the plan.
function curvePanel(g,i){
  const c=planRelativeCurve(g.frames),W=320,H=150,L=48,R=16,T=12,B=30,w=W-L-R,h=H-T-B,top=c.points.at(-1).relative;
  const x=n=>L+(n-1)/(c.maxFrames-1)*w,y=r=>T+h-r/top*h,half=c.frames/2,halfRel=Math.SQRT1_2;
  const line=c.points.map(p=>`${x(p.frames).toFixed(1)},${y(p.relative).toFixed(1)}`).join(' ');
  const px=x(c.frames),py=y(1),hx=x(Math.max(1,half)),hy=y(halfRel);
  const label=`Relative improvement over integration time, group ${i+1}, ${groupName(g)}: 1.00× at your plan, ${timeAt(g,c.frames)}; ${halfRel.toFixed(2)}× at half that time; ${top.toFixed(2)}× at ${timeAt(g,c.maxFrames)}, for comparison. Relative to your plan, not a signal-to-noise ratio.`;
  const ticks=[[0,'0'],[1,'1.00×'],[top,`${top.toFixed(2)}×`]].map(([v,t])=>`<path class="gain-grid" d="M${L} ${y(v).toFixed(1)}H${L+w}"/><text x="${L-6}" y="${(y(v)+4).toFixed(1)}" text-anchor="end">${t}</text>`).join('');
  const xLabels=`${c.frames>4?`<text x="${L}" y="${H-10}">${esc(duration(g.exposure))}</text>`:''}<text x="${px.toFixed(1)}" y="${H-10}" text-anchor="middle">${esc(duration(c.frames*g.exposure))}</text><text x="${L+w}" y="${H-10}" text-anchor="end">${esc(duration(c.maxFrames*g.exposure))}</text>`;
  return `<figure class="gain-panel"><figcaption>${i+1} · ${esc(groupName(g))}</figcaption><p class="gain-axis-title">Relative to your planned time (1.00×)</p>
    <div class="gain-plot-scroll"><svg class="gain-graph" viewBox="0 0 ${W} ${H}" role="img" aria-label="${esc(label)}">${ticks}<path class="gain-axis" d="M${L} ${T}V${T+h}H${L+w}"/><path class="gain-guide" d="M${px.toFixed(1)} ${T+h}V${py.toFixed(1)}"/><polyline class="gain-curve" points="${line}"/>${c.frames>1?`<circle class="gain-point-half" cx="${hx.toFixed(1)}" cy="${hy.toFixed(1)}" r="4"/>`:''}<circle class="gain-point" cx="${px.toFixed(1)}" cy="${py.toFixed(1)}" r="5.5"/>${xLabels}</svg></div>
    <p class="gain-axis-title gain-axis-x">Integration time for this group</p>
    <ul class="gain-legend"><li><span class="gain-key gain-key-plan" aria-hidden="true"></span>Your plan: ${esc(timeAt(g,c.frames))} · 1.00×</li>${c.frames>1?`<li><span class="gain-key gain-key-half" aria-hidden="true"></span>Half the time: ${esc(duration(half*g.exposure))} · ${halfRel.toFixed(2)}×</li>`:''}<li><span class="gain-key" aria-hidden="true"></span>End of curve, for comparison only: ${esc(timeAt(g,c.maxFrames))} · ${top.toFixed(2)}×</li></ul></figure>`;
}
// B. One bar per comparable group on a shared ×√N axis, each against one of its own frames.
function niceMax(v){const p=10**Math.floor(Math.log10(Math.max(v,1))),m=v/p;return (m<=1?1:m<=2?2:m<=5?5:10)*p;}
function barsView(groups){
  const {list}=shownGroups(groups),max=niceMax(Math.max(...list.map(g=>g.gain)));
  return `<div class="gain-bars"><p class="gain-axis-title">Gain against one frame of the same group (×√N)</p><ul>${list.map((g,i)=>`<li class="gain-bar${g.recorded?'':' is-unrecorded'}"><span class="gain-bar-label">${i+1} · ${esc(groupName(g))}</span><span class="gain-bar-track" aria-hidden="true"><span class="gain-bar-fill" style="width:${(g.gain/max*100).toFixed(2)}%"></span></span><span class="gain-bar-value">${times(g.gain)} · ${g.frames.toLocaleString('en-GB')} frames${g.recorded?'':' · kept separate'}</span></li>`).join('')}</ul>
    <p class="gain-bar-axis" aria-hidden="true"><span>×0</span><span>×${Number((max/2).toFixed(1))}</span><span>×${max}</span></p></div>`;
}
// C. Steps of one group in plan order: cumulative frames along x (to the planned total only), √N along y.
function stepsPanel(g,i){
  const steps=blockSteps(g),N=g.frames,W=320,H=150,L=48,R=16,T=12,B=30,w=W-L-R,h=H-T-B,top=Math.sqrt(N);
  const x=n=>L+n/N*w,y=v=>T+h-v/top*h;
  const curve=Array.from({length:41},(_,k)=>{const n=N*k/40;return `${x(n).toFixed(1)},${y(Math.sqrt(n)).toFixed(1)}`;}).join(' ');
  let prev=0;
  const marks=steps.map((s,k)=>{const x0=x(prev),x1=x(s.cumulative);prev=s.cumulative;return `<path class="gain-run${k%2?' is-alt':''}" d="M${x0.toFixed(1)} ${T+h}H${x1.toFixed(1)}"/><path class="gain-guide" d="M${L} ${y(s.gain).toFixed(1)}H${x1.toFixed(1)}"/><circle class="gain-point" cx="${x1.toFixed(1)}" cy="${y(s.gain).toFixed(1)}" r="4.5"/>`;}).join('');
  const label=`Block steps, group ${i+1}, ${groupName(g)}: ${steps.map(s=>`block ${position(plan.blocks.find(b=>b.id===s.id))} adds ${s.count} frames, reaching ×${s.gain.toFixed(2)} (+${s.added.toFixed(2)})`).join('; ')}. Gain against one frame of the group.`;
  return `<figure class="gain-panel"><figcaption>${i+1} · ${esc(groupName(g))}</figcaption><p class="gain-axis-title">Gain against one frame (×√N)</p>
    <div class="gain-plot-scroll"><svg class="gain-graph" viewBox="0 0 ${W} ${H}" role="img" aria-label="${esc(label)}"><path class="gain-axis" d="M${L} ${T}V${T+h}H${L+w}"/><polyline class="gain-curve is-reference" points="${curve}"/>${marks}<text x="${L-6}" y="${T+h+4}" text-anchor="end">×0</text><text x="${L-6}" y="${(y(top)+4).toFixed(1)}" text-anchor="end">${times(top)}</text><text x="${L}" y="${H-10}">0</text><text x="${L+w}" y="${H-10}" text-anchor="end">${N.toLocaleString('en-GB')} frames</text></svg></div>
    <p class="gain-axis-title gain-axis-x">Comparable frames, in capture-plan order</p>
    <ol class="gain-legend">${steps.map(s=>{const n=position(plan.blocks.find(b=>b.id===s.id));return `<li>Block ${n}: ${s===steps[0]?'':'+'}${s.count.toLocaleString('en-GB')} frames → ${times(s.gain)}${s===steps[0]?'':` (+${s.added.toFixed(2)})`}</li>`;}).join('')}</ol>${steps.length===1?'<p class="gain-panel-note">One block in this group. A later comparable block would add less for the same frame count.</p>':''}</figure>`;
}
const GAIN_QUESTIONS={curve:['A · Time curve','Would more or less time help this group? Reference: your planned time. This is the graph the app draws.'],bars:['B · Group bars','How deep is each group’s stack? Reference: one frame of the same group; bars of different filters or exposures don’t compare signal.'],steps:['C · Block steps','What does each block add to its group? Reference: one frame; order follows the capture plan.']};
function gainGraphs(groups){
  if(!groups.length)return '';
  const {list,more}=shownGroups(groups);
  const render={curve:()=>list.map(curvePanel).join(''),bars:()=>barsView(groups),steps:()=>list.map(stepsPanel).join('')};
  const extra=more?`<p class="gain-panel-note">Showing ${MAX_GAIN_PANELS} of ${groups.length} groups; the table lists all.</p>`:'';
  if(gainView!=='all')return render[gainView]()+extra;
  return Object.entries(GAIN_QUESTIONS).map(([key,[title,question]])=>`<section class="gain-alternative" aria-label="${esc(title)}"><h3>${esc(title)}${key==='curve'?' · default':''}</h3><p class="gain-panel-note">${esc(question)}</p>${render[key]()}</section>`).join('')+extra;
}
function gainDisclosure(e){
  const groups=e.groups,summary=gainView==='all'?'Table and three graph proposals':gainView==='bars'?'Per-group table and group bars':gainView==='steps'?'Per-group table and block steps':'Per-group table and time curve';
  return disclosure('gain','Stacking gain details',summary,`${groups.length?`<div class="table-wrap"><table class="gain-table"><caption>Ideal relative gain within each comparable light group</caption><thead><tr><th scope="col">Group</th><th scope="col">Frames</th><th scope="col">Gain vs one frame</th></tr></thead><tbody>${groups.map((g,i)=>`<tr><th scope="row">${i+1} · ${esc(groupName(g))}${g.recorded?'':' · kept separate'}</th><td>${g.frames.toLocaleString('en-GB')}</td><td>${times(g.gain)}</td></tr>`).join('')}</tbody></table></div>`:'<p>Add light frames to see a gain per comparable group.</p>'}${gainGraphs(groups)}
    <p>Frames are comparable when exposure, filter and recorded sensitivity match${plan.rig==='astro'?', and binning':''}. Groups with unrecorded sensitivity stay separate. √N describes ideal averaging of comparable frames: twice the time gives 1.41×, not 2×. It isn’t absolute signal-to-noise and doesn’t include sky, sensor or processing effects.</p>`);
}
function rigDisclosure(){
  const rig=rigs[plan.rig];
  const records=rig?.sensitivity==='iso'?'ISO on every block; white balance and AF/MF on light blocks':rig?.sensitivity==='gain'?'Gain, with binning in Details':'White balance and AF/MF on light blocks; no ISO or gain until the camera type is set';
  const row=(dt,dd)=>`<div><dt>${dt}</dt><dd>${dd}</dd></div>`,none='Not recorded';
  const body=rig?`<dl class="assumption-list">${row('Camera type',esc(cameraClassLabels[rig.cameraClass]))}${row('Camera',rig.cameraModel?esc(rig.cameraModel):none)}${row('Sensor',rig.sensorMm?`${rig.sensorMm[0]} × ${rig.sensorMm[1]} mm`:none)}${row('Resolution',rig.resolutionPx?`${rig.resolutionPx[0].toLocaleString('en-GB')} × ${rig.resolutionPx[1].toLocaleString('en-GB')} px`:none)}${row('Pixel pitch',rig.pixelUm!=null?`${rig.pixelUm} µm`:none)}${row('Focal length',rig.focalLengthMm!=null?`${rig.focalLengthMm} mm`:none)}${row('Focal ratio',rig.focalRatio!=null?`${fNumber(rig.focalRatio)}${rig.apertureMm!=null?` · ${rig.apertureMm} mm aperture`:''}`:none)}${row('Tracking',rig.tracking?trackingLabels[rig.tracking]:none)}${row('Recorded in blocks',records)}</dl>
    <p>${esc(rig.source)} ${rig.sensorMm&&rig.focalLengthMm!=null?'The app derives field of view from sensor size and focal length; this preview doesn’t show it.':'Field of view needs sensor size and focal length, so it isn’t available for this rig.'} Camera type belongs to the rig, so blocks never switch between ISO and gain.</p>`:'<p>Choose a rig to see its recorded details.</p>';
  return disclosure('rig','Rig details',rig?esc(rig.name):'No rig chosen',body);
}
function conditionsSection(){
  if(plan.siteSnapshot||plan.targetSnapshot)return `<section class="plan-night"><h2>The night ahead</h2><p>Conditions unknown for this Library context. The browser preview has fixed example astronomy and weather only.</p></section>`;
  if(!plan.site)return `<section class="plan-night" aria-labelledby="plan-night-title"><h2 id="plan-night-title">The night ahead</h2><p class="night-missing">Night, Moon and weather belong to a site and its time zone.</p><button class="secondary-button" data-open="context">Choose a site</button></section>`;
  const night=fixtureNight(plan.night,plan.exampleScenario||'ready'),weather=weatherForNight(night,scenario==='unknown'?'unknown':'ready',Date.now());
  const darkValue=night.dark.length?`${hoursLabel(totalTime(night.dark))} dark · ${timeLabel(night.dark[0].start)}–${timeLabel(night.dark.at(-1).end)}`:'No dark time';
  const moonValue=`${night.moonFree.length?`Moon-free ${night.moonFree.map(x=>`${timeLabel(x.start)}–${timeLabel(x.end)}`).join(', ')}`:night.classification} · ${night.phase}, ${night.illumination}%`;
  const cloud=weather.cloudMin!==null?`Cloud ${weather.cloudMin}–${weather.cloudMax}% in the dark`:weather.darkMs?'Cloud unknown':'No dark hours to forecast';
  const weatherExtra=`${weather.status}${weatherFreshnessLabel(weather)&&weatherFreshnessLabel(weather)!==weather.status?' · '+weatherFreshnessLabel(weather):''}${weather.unavailable&&weather.darkMs?' · unknown is not 0%':''} · updated ${hoursLabel(Date.now()-weather.retrievedAt)} ago`;
  const row=(view,label,value,extra)=>`<a class="night-row" href="${esc(conditionsURL(view))}" data-conditions="${view}"><span class="night-row-text"><span class="night-row-label">${label}</span><span class="night-row-value">${value}</span><span class="night-row-extra">${extra}</span></span>${icons.chevron}</a>`;
  return `<section class="plan-night" aria-labelledby="plan-night-title"><h2 id="plan-night-title">The night ahead</h2>${row('night','Night & Moon',darkValue,moonValue)}${row('weather','Weather',cloud,weatherExtra)}</section>`;
}
function mainView(){
  const e=currentEstimate();
  return identityStrip()+answerSection(e)+contextRows()+captureSection(e)+estimateSection(e)+budgetDisclosure(e)+gainDisclosure(e)+rigDisclosure()+conditionsSection();
}
function mainBar(){
  const problem=saveProblem(plan),fix=problem?missingItems().find(m=>m.key!=='light'):null;
  const reason=saveFailure?'Your latest changes are still on this page.':problem?`To save, ${lc(problem)}`:dirty()?(hasSaved?'Changes are not saved yet.':'This plan is not saved yet.'):'Saved in this browser.';
  return `${saveFailure?`<p class="save-error" role="alert">${esc(saveFailure)}</p>`:''}${checkpointError?'<p class="save-error">This browser can’t keep the working draft across reloads or screens.</p>':''}<div class="savebar-row"><p id="save-reason">${reason}</p>${fix?`<button class="quiet-button savebar-remedy" data-open="${fix.key}">${fix.short}</button>`:''}</div><button class="primary-button" data-save-plan ${problem?'disabled':''} aria-describedby="save-reason">${saveFailure?'Retry save':'Save plan'}</button>`;
}

/* ---------- Components: scoped screens ---------- */

function exposureNoteText(d){return d.exposureSource==='Proposal'?d.exposureNote:d.exposureSource==='Entered'?'Entered by you.':'';}
function integrationText(d){
  const exposure=parseExposure(d.exposure),count=Number(d.count);
  if(exposure===null||!Number.isSafeInteger(count)||count<1||!Number.isFinite(exposure*count))return 'Enter exposure and frames to see the total.';
  return d.type==='Light'?`= ${duration(exposure*count)} of integration`:`= ${duration(exposure*count)} of planned ${d.type.toLowerCase()} frames, not integration`;
}
function blockView(screen){
  const d=screen.draft,errors=screen.errors,kind=sensitivityOf(plan.rig),rig=rigs[plan.rig];
  const input=(name,label,options={})=>field({id:`block-${name}`,name,label,value:d[name],error:errors[name],...options});
  const records=cameraRecordsShown(plan.rig,d.type);
  let classFields=kind==='iso'?input('iso','ISO (optional)',{attrs:'inputmode="numeric" placeholder="Unrecorded"',hint:'Leave blank to keep it unrecorded.'}):kind==='gain'?input('gain','Gain (optional)',{attrs:'inputmode="decimal" placeholder="Unrecorded"'}):`<div class="class-remedy" role="note"><p><strong>${plan.rig?'Camera type not recorded.':'No rig chosen.'}</strong> Choose a known camera type to record ISO or gain. Existing records are kept.</p><button type="button" class="secondary-button" data-open="rig">Choose a rig with a known camera type</button></div>`;
  if(records){
    classFields+=`<fieldset class="wb-fields"><legend>White balance</legend><div class="block-input"><label for="block-whiteBalance">Mode (optional)</label><select id="block-whiteBalance" name="whiteBalance">${WHITE_BALANCE.map(v=>`<option value="${v}" ${v===d.whiteBalance?'selected':''}>${v}</option>`).join('')}</select></div>${d.whiteBalance==='Kelvin'?input('kelvin','Colour temperature (K)',{attrs:'inputmode="numeric" placeholder="e.g. 5600"',hint:'1000–40000 K are model sanity limits, not the camera’s range.'}):''}${tintApplies(d.whiteBalance)?input('tint','White balance tint (optional)',{attrs:'inputmode="decimal" placeholder="Unrecorded"',hint:d.whiteBalance==='Custom'?'Custom is a measured camera balance, not a kelvin value. Record tint only if the camera reports it.':'Record the camera’s tint value or leave blank.'}):''}</fieldset>`;
    classFields+=radioGroup({name:'focus',legend:'Focus mode (optional)',options:[['Unrecorded','Unrecorded'],['AF','AF'],['MF','MF']],value:d.focus,idPrefix:'block-focus'});
    if(d.focus==='MF')classFields+='<p class="field-hint">Manual focus is a record only. This app has no lens-position value or camera focus control.</p>';
  }else if(d.type!=='Light')classFields+='<p class="field-hint">White balance and focus records belong to light frames. Existing records on this block are preserved.</p>';
  const details=(kind==='gain'?input('binning','Binning',{attrs:'inputmode="numeric"',hint:'1 means 1×1.'}):'')+(d.type==='Light'?'<p class="field-hint">Light frames are planned inside the imaging window.</p>':`<div class="block-input"><label for="block-placement">Planned timing</label><select id="block-placement" name="placement" ${errors.placement?'aria-invalid="true"':''}><option value="outside" ${d.placement==='outside'?'selected':''}>Outside the imaging window</option><option value="window" ${d.placement==='window'?'selected':''}>During the imaging window</option></select><span class="field-hint">Proposed: outside the window, so calibration doesn’t use imaging time.</span></div>`);
  return `<form id="block-editor" class="scoped-form" novalidate><p class="screen-context">Rig: ${esc(rig?.name||'none chosen')}</p>${radioGroup({name:'type',legend:'Frame type',options:FRAME_TYPES.map(t=>[t,t]),value:d.type,idPrefix:'block-type',error:errors.type})}${input('exposure','Exposure (seconds)',{attrs:'inputmode="decimal"',hint:'For example 60, 2.5 or 1/125.',note:exposureNoteText(d)})}${input('count','Frames',{attrs:'inputmode="numeric"'})}<p id="block-integration" class="live-total" aria-live="polite">${integrationText(d)}</p>${['Light','Flat'].includes(d.type)?input('filter','Filter (optional)',{attrs:'maxlength="100" placeholder="e.g. Ha, OIII or a filter name"',hint:'Leave blank for no filter. A placeholder is not a selected filter.'}):''}${classFields}<details class="plan-disclosure" data-screen-details ${screen.detailsOpen?'open':''}><summary>Details <span>${kind==='gain'?'Binning and timing':'Timing'}</span></summary><div class="block-fields">${details}</div></details><p class="editor-help">Records describe how you plan to shoot. This preview doesn’t control a camera.</p></form>`;
}
function calibrationProposal(type,ref){
  if(type==='Dark')return {exposure:String(ref.exposure),note:'Proposal: matches the referenced light exposure.'};
  return proposalFor(type);
}
function sensitivityText(ref){
  const kind=sensitivityOf(plan.rig);
  if(kind==='iso')return ref.iso!=null?`ISO ${ref.iso} from the referenced light (proposal)`:'ISO unrecorded, as in the referenced light';
  if(kind==='gain')return `Gain ${ref.gain??'unrecorded'} · binning ${ref.binning}×${ref.binning} from the referenced light (proposal)`;
  return 'Camera type not recorded: no ISO or gain to match';
}
function calibrationView(screen){
  const d=screen.draft,errors=screen.errors,lightBlocks=lights(),ref=lightBlocks.find(b=>b.id===d.ref)||lightBlocks[0];
  const refText=b=>`Block ${position(b)} · ${b.count} × ${b.exposure} s · ${b.filter||'no filter'}`;
  const reference=lightBlocks.length>1?radioGroup({name:'ref',legend:'Reference light block',options:lightBlocks.map(b=>[b.id,refText(b)]),value:ref.id,cls:'choice-list',idPrefix:'cal-ref'}):`<p class="reference-light">References light ${esc(refText(ref))}</p>`;
  const rows=CALIBRATION_TYPES.map(t=>{const row=d.rows[t],proposal=calibrationProposal(t,ref);return `<fieldset class="cal-row"><legend>${t} frames</legend><label class="check-row" for="cal-include-${t}"><input type="checkbox" id="cal-include-${t}" name="include-${t}" ${row.include?'checked':''}><span>Add ${t.toLowerCase()} frames</span></label>${row.include?field({id:`cal-count-${t}`,name:`count-${t}`,label:'Proposed frames',value:row.count,error:errors[`count-${t}`],attrs:'inputmode="numeric"'}):''}<p class="field-source">Exposure ${esc(proposal.exposure)} s. ${esc(proposal.note)}</p><p class="field-source">${esc(sensitivityText(ref))} · outside the imaging window</p></fieldset>`;}).join('');
  return `<form id="scoped-form" class="scoped-form" novalidate><p class="screen-intro">Add proposed frames to this plan. Review counts before applying.</p>${reference}${errors.none?`<p id="error-none" class="field-error" role="alert">${esc(errors.none)}</p>`:''}${rows}<p class="editor-help">These add session time and storage, not integration. No calibration files are checked or acquired.</p></form>`;
}
function contextView(screen){
  const d=screen.draft;
  return `<form id="scoped-form" class="scoped-form" novalidate>${radioGroup({name:'site',legend:'Observing site',options:SITES.map(s=>[s,libraryChoices.sites.find(x=>x.key===s)?.name||plan.siteSnapshot?.key===s&&plan.siteSnapshot.name||s,s.startsWith('library:')?'Library · saved coordinates':'Example fixture']),value:d.site,cls:'choice-list',idPrefix:'ctx-site',error:screen.errors.site})}
    <div class="block-input"><label for="ctx-night">Night</label><select id="ctx-night" name="night" aria-describedby="hint-night" ${SITES.includes(d.site)?'':'disabled'}>${fixtureDates.map(x=>`<option value="${x}" ${x===d.night?'selected':''}>${variant==='blend'?nightDateLabels(x).night:nightName(x)}</option>`).join('')}</select><span id="hint-night" class="field-hint">${SITES.includes(d.site)?`${variant==='blend'?nightDateLabels(d.night).ends+'. ':''}Example nights 19 Oct–1 Nov. Times are in the site zone, ${zone}.`:'Choose a site first to resolve the night in its time zone.'}</span></div>
    ${hasSaved?'<p class="editor-help">Changing the night edits this plan. To keep the saved plan and plan a copy, use More › Copy to another night.</p>':''}</form>`;
}
function targetResults(screen,found=findTargets(screen.query||'')){
  return found.length?radioGroup({name:'target',legend:'Choose a target',options:found.map(t=>[t.id,`${t.catalogId|| (t.recordId?'Your target':t.id)} · ${t.name}`,targetCaption(t)]),value:screen.draft.target,cls:'choice-list',idPrefix:'choice-target',error:screen.errors.target}):'<p>No matches in this sample. Try a catalogue number or another name.</p>';
}
function choiceView(screen){
  if(screen.kind==='target'){
    const found=findTargets(screen.query||''),selected=screen.draft.target;
    return `<form id="scoped-form" class="scoped-form" novalidate><div class="block-input"><label for="target-query">Search targets</label><input id="target-query" type="search" value="${esc(screen.query||'')}" autocomplete="off" placeholder="Name, M31 or NGC 224" aria-describedby="target-search-note"></div><p id="target-search-note" class="field-hint">${targetSample.length} bundled examples and ${allTargets().length-targetSample.length} Library targets. Library selections are copied into this plan. ${selected?`Selected: ${esc(selected)} · ${esc(targets[selected])}.`:''}</p><p id="target-count" class="search-count" role="status">${found.length} result${found.length===1?'':'s'}</p><div id="target-results">${targetResults(screen,found)}</div></form>`;
  }
  return `<form id="scoped-form" class="scoped-form" novalidate>${radioGroup({name:'rig',legend:'Choose a rig',options:Object.entries({...rigs,...libraryChoices.rigs}).map(([k,rig])=>[k,rig.name,rigSummary(rig)]),value:screen.draft.rig,cls:'choice-list',idPrefix:'choice-rig',error:screen.errors.rig})}<p class="editor-help">Camera type comes from the rig. Blocks show ISO or gain to match it; values recorded for another type are kept.</p></form>`;
}
function assumptionsView(screen){
  const hybrid=variant==='blend';
  const intro=hybrid?assumptionIntro(screen):'Overrides for this plan. Global Planning settings apply where no override is recorded.';
  return `<form id="scoped-form" class="scoped-form" novalidate><p class="screen-intro">${intro}</p>${ASSUMPTION_FIELDS.map(f=>field({id:`asm-${f.name}`,name:f.name,label:f.label,value:screen.draft[f.name],error:screen.errors[f.name],hint:hybrid&&f.name==='fitMargin'?'Fixed minutes when overridden. The global percentage uses the usable window.':f.hint,...(hybrid?{note:assumptionFieldSource(screen,f.name)}:{}),attrs:'inputmode="decimal"'})).join('')}<button type="button" class="quiet-button" data-reset-assumptions>Use global defaults</button></form>`;
}
function screenView(screen){return ({block:blockView,calibration:calibrationView,context:contextView,target:choiceView,rig:choiceView,assumptions:assumptionsView})[screen.kind](screen);}
function screenBar(screen){
  const label=screen.kind==='block'?(screen.isNew?'Add block':'Apply changes'):screen.kind==='calibration'?'Add selected frames':'Apply changes';
  return `<p id="save-reason">Apply updates the draft. Save plan records it.</p><button type="submit" form="${screen.kind==='block'?'block-editor':'scoped-form'}" class="primary-button" data-apply-screen>${label}</button>`;
}

/* ---------- Rendering ---------- */

function applyDisplay(){
  const root=document.documentElement;
  root.dataset.theme=display.theme;root.dataset.textScale=display.scale;root.style.colorScheme=display.theme==='light'?'light':'dark';
  for(const [key,value] of Object.entries(config.themes[display.theme]))root.style.setProperty('--'+key,value);
  for(const [key,value] of Object.entries(config.space))root.style.setProperty('--space-'+key,value+'px');
  root.style.setProperty('--text-scale',display.scale);
  const family=font==='native'?config.variants[variant].family:font;
  root.style.setProperty('--lab-font',`'${family==='Source Serif 4'?'Inter':family}',sans-serif`);
  root.style.setProperty('--plan-night-font',font==='native'||family==='Source Serif 4'?"'Source Serif 4'":`'${family}'`);
  $('#plan-theme').value=display.theme;$('#plan-scale').value=display.scale;$('#back-home').href=homeURL();
  $('#plan-field-mode').setAttribute('aria-pressed',String(display.theme==='field'));
  $('#plan-field-mode').setAttribute('aria-label',display.theme==='field'?'Turn off field mode':'Turn on field mode');
}
function syncURL(){
  // Display and lab-state controls survive a reload without touching the plan.
  const url=new URL(location.href);
  url.searchParams.set('gain',gainView);url.searchParams.set('theme',display.theme);url.searchParams.set('scale',display.scale);url.searchParams.set('scenario',scenario);
  history.replaceState(null,'',url);
}
function focusKeyOf(el){
  if(!el||el===document.body)return null;
  const box=el.closest('#plan-main,#block-screen,#plan-savebar');if(!box)return null;
  if(el.id)return '#'+CSS.escape(el.id);
  for(const {name,value} of el.attributes)if(name.startsWith('data-'))return `#${box.id} [${name}${value?`="${value.replace(/["\\]/g,'\\$&')}"`:''}]`;
  return null;
}
function render(skipPersist=false){
  const restore=focusKeyOf(document.activeElement),top=stack.at(-1);
  applyDisplay();if(!skipPersist)persist();
  $('#plan-scenario').value=scenario;
  $('#plan-main').hidden=!!top;$('#block-screen').hidden=!top;
  $('.skip').href=top?'#block-screen':'#plan-main';$('#back-home').hidden=!!top;$('#back-editor').hidden=!top;$('#plan-menu-button').hidden=!!top;
  if(top)closeMenu(false);
  $('#appbar-title').textContent=top?screenTitle(top):'Plan';
  $('#back-editor').setAttribute('aria-label',top?`Close ${screenTitle(top).toLowerCase()}`:'Close editor');
  if(top){$('#block-screen').setAttribute('aria-label',screenTitle(top));$('#block-screen').innerHTML=screenView(top);$('#plan-main').innerHTML='';}
  else{$('#block-screen').innerHTML='';$('#plan-main').innerHTML=mainView();}
  $('#plan-savebar').innerHTML=top?screenBar(top):mainBar();
  if(restore&&(!document.activeElement||document.activeElement===document.body))document.querySelector(restore)?.focus({preventScroll:true});
}
function announce(text){
  clearTimeout(announcementTimer);
  const box=$('#plan-announcement');box.textContent=text;box.classList.add('visible');
  announcementTimer=setTimeout(()=>box.classList.remove('visible'),text.length>80?6000:4000);
}
function openMenu(){const menu=$('#plan-menu');menu.hidden=false;$('#plan-menu-button').setAttribute('aria-expanded','true');menu.querySelector('[role="menuitem"]').focus();}
function closeMenu(returnFocus){const menu=$('#plan-menu');if(menu.hidden)return;menu.hidden=true;$('#plan-menu-button').setAttribute('aria-expanded','false');if(returnFocus)$('#plan-menu-button').focus();}

/* ---------- Events ---------- */

document.addEventListener('submit',event=>{event.preventDefault();if(stack.at(-1)?.kind==='target'&&document.activeElement?.id==='target-query')return;applyTop();});
document.addEventListener('input',event=>{
  const screen=stack.at(-1),target=event.target;
  if(screen?.kind==='target'&&target.id==='target-query'){screen.query=target.value;const found=findTargets(screen.query);$('#target-count').textContent=`${found.length} result${found.length===1?'':'s'}`;$('#target-results').innerHTML=targetResults(screen,found);persist();return;}
  if(!screen||!target.closest('#block-screen')||target.type!=='text')return;
  if(screen.kind==='block'){
    const d=screen.draft;d[target.name]=target.value;
    if(target.name==='exposure'){
      if(!screen.isNew&&target.value.trim()===String(screen.base.exposure)){d.exposureSource=screen.base.exposureSource||'';d.exposureNote=screen.base.exposureNote||'';}
      else{d.exposureSource='Entered';d.exposureNote='';}
      $('#note-exposure').textContent=exposureNoteText(d);
    }
    if(['exposure','count'].includes(target.name))$('#block-integration').textContent=integrationText(d);
  }else if(screen.kind==='calibration'&&target.name.startsWith('count-'))screen.draft.rows[target.name.slice(6)].count=target.value;
  else if(screen.kind==='assumptions'){
    screen.draft[target.name]=target.value;screen.inheritDefaults=false;
    if(variant==='blend'){
      $('#scoped-form .screen-intro').textContent=assumptionIntro(screen);
      for(const f of ASSUMPTION_FIELDS){const source=$(`#note-${f.name}`);if(source)source.textContent=assumptionFieldSource(screen,f.name);}
    }
  }
  persist();
});
document.addEventListener('change',event=>{
  const screen=stack.at(-1),target=event.target;
  if(!screen||!target.closest('#block-screen')||['text','search'].includes(target.type))return;
  if(screen.kind==='block'){if(target.name==='type')applyTypeChange(screen,target.value);else if(['whiteBalance','focus','placement'].includes(target.name))screen.draft[target.name]=target.value;}
  else if(screen.kind==='context')screen.draft[target.name]=target.value;
  else if(screen.kind==='target'||screen.kind==='rig')screen.draft[screen.kind]=target.value;
  else if(screen.kind==='calibration'){if(target.name==='ref')screen.draft.ref=target.value;else if(target.name.startsWith('include-'))screen.draft.rows[target.name.slice(8)].include=target.checked;}
  render();
});
document.addEventListener('toggle',event=>{
  const details=event.target;if(!(details instanceof HTMLDetailsElement))return;
  if(details.dataset.disclosure){if(details.open)openDisclosures.add(details.dataset.disclosure);else openDisclosures.delete(details.dataset.disclosure);}
  if(details.hasAttribute('data-screen-details')&&stack.at(-1)){stack.at(-1).detailsOpen=details.open;persist();}
},true);
document.addEventListener('click',event=>{
  if(!$('#plan-menu').hidden&&!event.target.closest('#plan-menu,#plan-menu-button'))closeMenu(false);
  const button=event.target.closest('button,a[data-conditions]');if(!button)return;
  const data=button.dataset;
  if(button.id==='plan-menu-button'){$('#plan-menu').hidden?openMenu():closeMenu(true);return;}
  if(data.menu){closeMenu(false);if(data.menu==='new')requestLeave('new');else copyToAnotherNight();return;}
  if(data.conditions){event.preventDefault();navigateToConditions(data.conditions);return;}
  if('cancelEditor' in data){requestCloseScreen();return;}
  if(data.leave){handleLeave(data.leave);return;}
  if(data.discardEdit){$('#discard-edit').close();if(data.discardEdit==='discard')closeTop({message:'Unapplied edit discarded.'});return;}
  if(data.open){openFromKey(data.open,focusKeyOf(button));return;}
  if('addBlock' in data){openBlockEditor(null,focusKeyOf(button));return;}
  if(data.editBlock){openBlockEditor(data.editBlock,focusKeyOf(button));return;}
  if(data.removeBlock){removeBlock(data.removeBlock);return;}
  if(data.moveBlock){moveBlock(data.moveBlock,Number(data.dir));return;}
  if('undo' in data){applyUndo();return;}
  if('buildCalibration' in data){openCalibration(focusKeyOf(button));return;}
  if('editAssumptions' in data){openAssumptions(focusKeyOf(button));return;}
  if('resetAssumptions' in data){resetAssumptions();return;}
  if('savePlan' in data)savePlan();
});
document.addEventListener('keydown',event=>{
  if(event.target.id==='target-query'&&event.key==='Enter'&&!event.isComposing){event.preventDefault();return;}
  if(event.key!=='Escape')return;
  if(!$('#plan-menu').hidden){event.preventDefault();closeMenu(true);return;}
  if(document.querySelector('dialog[open]'))return;
  if(stack.length){event.preventDefault();requestCloseScreen();}
});
$('#plan-menu').addEventListener('keydown',event=>{
  const items=[...$('#plan-menu').querySelectorAll('[role="menuitem"]')],index=items.indexOf(document.activeElement);
  if(event.key==='ArrowDown'||event.key==='ArrowUp'){event.preventDefault();items[(index+(event.key==='ArrowDown'?1:-1)+items.length)%items.length].focus();}
  else if(event.key==='Home'){event.preventDefault();items[0].focus();}
  else if(event.key==='End'){event.preventDefault();items.at(-1).focus();}
  else if(event.key==='Tab')closeMenu(false);
});
$('.android-scroll').addEventListener('scroll',()=>{if(!stack.length)mainScroll=$('.android-scroll').scrollTop;},{passive:true});
$('#back-home').addEventListener('click',event=>{event.preventDefault();requestLeave('home');});
$('#lab-home').addEventListener('click',event=>{event.preventDefault();requestLeave('home');});
let previousTheme=display.theme==='field'?'light':display.theme;
$('#plan-field-mode').addEventListener('click',()=>{if(display.theme==='field')display.theme=previousTheme;else{previousTheme=display.theme;display.theme='field';}applyDisplay();syncURL();});
$('#plan-theme').addEventListener('change',event=>{display.theme=event.target.value;applyDisplay();syncURL();});
$('#plan-scale').addEventListener('change',event=>{display.scale=event.target.value;applyDisplay();syncURL();});
$('#plan-scenario').addEventListener('change',event=>{scenario=event.target.value;saveFailure='';failedOnce=false;if(applyScenarioToPlan())undo=null;syncURL();render();});

loadInitialState();
render();
if(!stack.length)$('.android-scroll').scrollTop=mainScroll;
if(pendingFeedback)announce(pendingFeedback);

window.addEventListener('storage',event=>{if([libraryKey,settingsKey].includes(event.key)){libraryChoices=readLibraryChoices(localStore);Object.assign(rigs,libraryChoices.rigs);Object.assign(targets,Object.fromEntries(libraryChoices.targets.map(t=>[t.id,t.name])));for(const s of libraryChoices.sites)if(!SITES.includes(s.key))SITES.push(s.key);includeSnapshotChoices();render();return;}if(![planStorageKey,navigationDraftKey].includes(event.key))return;const fresh=readNavigationDraft(localStore);scenario=SCENARIOS.includes(fresh?.scenario)?fresh.scenario:'ready';loadInitialState(true);undo=null;saveFailure='';for(const dialog of document.querySelectorAll('dialog[open]'))dialog.close();render(true);if(!stack.length)$('.android-scroll').scrollTop=mainScroll;announce('Preview updated from the shared working plan.');});

$('#gain-view').value=gainView;
$('#gain-view').addEventListener('change',event=>{gainView=event.target.value;syncURL();render();});
