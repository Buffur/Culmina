// Browser-only continuity. Selection copies a Library record into the working
// plan; managing that record never rewrites an existing plan or its history.
import {rigs,targetSample} from './plan-model.js?v=20261020-hybrid7';
export const libraryKey='culmina-library-preview-v1';
export const settingsKey='culmina-settings-preview-v1';
// One source for the initial values displayed by Settings and used by a new
// Hybrid plan. These are planning assumptions, not measured rig timings.
export const initialPlanningPreferences=Object.freeze({
  minAltitudeDeg:20,darknessLimitDeg:-18,feasibilityMarginPercent:15,perFrameOverheadSeconds:5,
  moonGateEnabled:false,moonGateMinIlluminationPct:50,cloudGateEnabled:false,cloudGateMaxPct:50,
  ditherEveryNFrames:null,ditherSettleSeconds:15,refocusEveryMinutes:null,refocusSeconds:90,
  filterChangeSeconds:null,meridianFlipSeconds:null,setupMinutes:null,npfK:1,dewMarginC:2,
});
const clone=x=>structuredClone(x);
export function browserStorage(){try{return window.localStorage;}catch{return {getItem(){throw Error('Browser storage unavailable');},setItem(){throw Error('Browser storage unavailable');},removeItem(){throw Error('Browser storage unavailable');}};}}
function payload(storage,key,kind){try{const p=JSON.parse(storage.getItem(key));return p?.kind===kind&&p.version===1?p:null;}catch{return null;}}
export function readPlanningPreferences(storage,{initialDefaults=false,plan=null}={}){
  const p=payload(storage,settingsKey,'culmina-settings-preview')?.settings?.planning;
  if(p&&Number.isFinite(p.perFrameOverheadSeconds)&&p.perFrameOverheadSeconds>=0&&p.perFrameOverheadSeconds<=120&&Number.isFinite(p.feasibilityMarginPercent)&&p.feasibilityMarginPercent>=0&&p.feasibilityMarginPercent<=50&&(p.setupMinutes===null||Number.isFinite(p.setupMinutes)&&p.setupMinutes>=0&&p.setupMinutes<=240))return p;
  // Preserve the original variants and the historical budget of a saved plan.
  // Reading defaults must never create a Settings record or rewrite a plan.
  return initialDefaults&&!plan?.budgetSnapshot?{...initialPlanningPreferences}:null;
}
export function readLibraryChoices(storage){
  const p=payload(storage,libraryKey,'culmina-library-preview')||{};
  const ownRigs=(Array.isArray(p.rigs)?p.rigs:[]).filter(r=>r&&typeof r.id==='string'&&typeof r.name==='string'&&Object.hasOwn({phone:1,dslrMirrorless:1,astroColour:1,astroMono:1,unknown:1},r.cameraClass));
  const ownTargets=(Array.isArray(p.targets)?p.targets:[]).filter(t=>t&&typeof t.id==='string'&&typeof t.name==='string'&&Number.isFinite(t.raDeg)&&t.raDeg>=0&&t.raDeg<360&&Number.isFinite(t.decDeg)&&Math.abs(t.decDeg)<=90);
  const ownSites=(Array.isArray(p.sites)?p.sites:[]).filter(s=>s&&typeof s.id==='string'&&typeof s.name==='string'&&Number.isFinite(s.latDeg)&&Math.abs(s.latDeg)<=90&&Number.isFinite(s.lonDeg)&&Math.abs(s.lonDeg)<=180&&typeof s.zone==='string');
  const rigChoices={...rigs};
  for(const r of ownRigs)rigChoices['library:'+r.id]={...clone(r),camera:r.cameraClass,sensitivity:['astroColour','astroMono'].includes(r.cameraClass)?'gain':['phone','dslrMirrorless'].includes(r.cameraClass)?'iso':null,source:r.provenance?.record||'Library record'};
  const targetChoices=[...targetSample,...ownTargets.map(t=>({...clone(t),recordId:t.id,id:'library:'+t.id,aliasIds:[t.catalogId].filter(Boolean),aliasNames:[],source:'Your Library'}))];
  return {rigs:rigChoices,targets:targetChoices,sites:ownSites.map(s=>({...clone(s),key:'library:'+s.id}))};
}
export function planningBudget(plan,preferences,usableSeconds){
  if(!preferences)return null;
  const p=preferences,result={};
  if(Number.isFinite(p.perFrameOverheadSeconds)&&p.perFrameOverheadSeconds>=0&&p.perFrameOverheadSeconds<=120)result.perFrameOverhead=p.perFrameOverheadSeconds;
  if(p.setupMinutes===null)result.outsideSetup=0;
  if(Number.isFinite(p.setupMinutes)&&p.setupMinutes>=0&&p.setupMinutes<=240)result.outsideSetup=p.setupMinutes*60;
  if(Number.isFinite(p.feasibilityMarginPercent)&&p.feasibilityMarginPercent>=0&&p.feasibilityMarginPercent<=50&&Number.isFinite(usableSeconds))result.fitMargin=usableSeconds*p.feasibilityMarginPercent/100;
  return result;
}
export function selectLibraryRecord(plan,kind,value,choices){
  plan[kind]=value;
  delete plan[kind+'Snapshot'];
  if(kind==='rig'&&value.startsWith('library:'))plan.rigSnapshot=clone(choices.rigs[value]);
  if(kind==='target'&&value.startsWith('library:'))plan.targetSnapshot=clone(choices.targets.find(t=>t.id===value));
  if(kind==='site'){
    const site=choices.sites.find(s=>s.key===value);
    if(site)plan.siteSnapshot=clone(site);
  }
}
