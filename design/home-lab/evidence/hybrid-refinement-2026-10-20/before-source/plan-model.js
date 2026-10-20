import {fixtureDates,fixtureNight,totalTime} from './night-model.js?v=20261020-hybrid6';
// Arithmetic for the explicitly labelled browser fixture, not Culmina's
// astronomical engine, calibration matcher or production storage model.
export const planStorageKey = 'culmina-plan-preview-v1';
// A six-object sample copied from the app's bundled catalogue
// (assets/catalog/catalog_v2.json, version 3, 164 OpenNGC-derived objects):
// ids, types and alias lists as shipped. M42's display name stays the
// catalogue alias "Orion Nebula" that Home already shows.
export const catalogObjectCount = 164;
export const targetSample = Object.freeze([
  {id:'M27',name:'Dumbbell Nebula',type:'Nebula',aliasIds:['NGC 6853'],aliasNames:['Dumbbell Nebula']},
  {id:'M31',name:'Andromeda Galaxy',type:'Galaxy',aliasIds:['NGC 224'],aliasNames:['Andromeda Galaxy']},
  {id:'M33',name:'Triangulum Galaxy',type:'Galaxy',aliasIds:['NGC 598'],aliasNames:['Triangulum Galaxy','Triangulum Pinwheel']},
  {id:'M42',name:'Orion Nebula',type:'Nebula',aliasIds:['NGC 1976','LBN 974'],aliasNames:['Great Orion Nebula','Orion Nebula']},
  {id:'M45',name:'Pleiades',type:'Open Cluster',aliasIds:[],aliasNames:['Pleiades']},
  {id:'NGC 7000',name:'North America Nebula',type:'Nebula',aliasIds:['C 20','LBN 373'],aliasNames:['North America Nebula']}
].map(Object.freeze));
export const targets = Object.fromEntries(targetSample.map(t=>[t.id,t.name]));
// Mirrors TargetSearch.designationKey (lib/domain/services/target_search.dart).
export function targetDesignationKey(text) {
  const compact=String(text).toLowerCase().replace(/[\s-]+/g,''),m=/^([a-z]*)(\d+)(.*)$/.exec(compact);
  if(!m)return compact;
  return `${({messier:'m',caldwell:'c'})[m[1]]??m[1]}${m[2].replace(/^0+(?=\d)/,'')}${m[3]}`;
}
function idParts(id){const m=/^([^\d]*?)\s*(\d+)(.*)$/.exec(id.toLowerCase());return m?[m[1],Number(m[2]),m[3]]:[id.toLowerCase(),-1,''];}
function compareIds(a,b){const pa=idParts(a),pb=idParts(b);return pa[0]<pb[0]?-1:pa[0]>pb[0]?1:pa[1]-pb[1]||(pa[2]<pb[2]?-1:pa[2]>pb[2]?1:0);}
// TargetSearch.search over the sample: exact designation, then designation
// prefix, then name substring; ties by catalogue id. No score or popularity.
export function searchTargets(query,list=targetSample) {
  const q=String(query??'').trim();
  if(!q)return [...list];
  const key=targetDesignationKey(q),lower=q.toLowerCase(),found=[];
  for(const t of list){
    const designations=[t.id,...t.aliasIds].map(targetDesignationKey),names=[t.id,t.name,...t.aliasNames];
    const rank=designations.includes(key)?0:key&&designations.some(d=>d.startsWith(key))?1:names.some(n=>n.toLowerCase().includes(lower))?2:-1;
    if(rank>=0)found.push([rank,t]);
  }
  return found.sort((a,b)=>a[0]-b[0]||compareIds(a[1].id,b[1].id)).map(([,t])=>t);
}
// Rig fields follow EquipmentProfile (lib/domain/models/equipment_profile.dart);
// null = not recorded in this example, never a guess. `astro` reuses the
// app's one shipped example rig (lib/data/services/equipment_seeder.dart).
export const rigs = {
  dslr:{name:'DSLR · 135 mm lens',camera:'DSLR',sensitivity:'iso',cameraClass:'dslrMirrorless',cameraModel:null,focalLengthMm:135,apertureMm:null,focalRatio:null,sensorMm:null,resolutionPx:null,pixelUm:null,tracking:null,source:'Example rig: only the lens focal length in its name is recorded.'},
  phone:{name:'Phone · wide camera',camera:'Phone',sensitivity:'iso',cameraClass:'phone',cameraModel:null,focalLengthMm:null,apertureMm:null,focalRatio:null,sensorMm:null,resolutionPx:null,pixelUm:null,tracking:null,source:'Example rig: no optics or sensor values recorded.'},
  astro:{name:'Astro camera · refractor',camera:'Astro camera',sensitivity:'gain',cameraClass:'astroColour',cameraModel:'ZWO ASI2600MC',focalLengthMm:400,apertureMm:72,focalRatio:400/72,sensorMm:[23.5,15.7],resolutionPx:[6248,4176],pixelUm:3.76,tracking:null,source:'The app’s shipped example rig: camera values verified from the maker; the 72 mm f/5.6 refractor is an illustrative estimate.'},
  unknown:{name:'Camera type not recorded',camera:'Unknown',sensitivity:null,cameraClass:'unknown',cameraModel:null,focalLengthMm:null,apertureMm:null,focalRatio:null,sensorMm:null,resolutionPx:null,pixelUm:null,tracking:null,source:'Example rig: camera type not chosen.'}
};
// CameraClass.label and TrackingType.label from lib/domain/models.
export const cameraClassLabels = Object.freeze({phone:'Phone',dslrMirrorless:'DSLR or mirrorless',astroColour:'Astro camera (colour)',astroMono:'Astro camera (mono)',unknown:'Unknown'});
export const trackingLabels = Object.freeze({untracked:'Untracked (fixed tripod)',tracked:'Tracked (unguided mount)',guided:'Guided'});
// WhiteBalance (lib/domain/models/capture_evidence.dart): Auto, six presets,
// Kelvin and Custom; tint for every mode except Auto. Bounds are sanity
// limits, not a camera's range. Stored values are the prototype's strings.
export const whiteBalancePresets = Object.freeze(['Daylight','Cloudy','Shade','Tungsten','Fluorescent','Flash']);
export const whiteBalanceLimits = Object.freeze({minKelvin:1000,maxKelvin:40000,maxAbsTint:1000});
export const tintApplies = mode=>mode==='Kelvin'||mode==='Custom'||whiteBalancePresets.includes(mode);
export function whiteBalanceText(block) {
  const mode=block?.whiteBalance;
  if(!mode||mode==='Unrecorded')return 'unrecorded';
  const tint=tintApplies(mode)&&block.tint!==null&&block.tint!==undefined&&block.tint!==''&&Number.isFinite(Number(block.tint))?`, tint ${Number(block.tint)>0?'+':''}${Number(block.tint)}`:'';
  if(mode==='Kelvin')return `${block.kelvin??'—'} K${tint}`;
  if(mode==='Custom')return `Custom (measured)${tint}`;
  return whiteBalancePresets.includes(mode)?`${mode} preset${tint}`:mode;
}
// Edit-time checks matching the app's block editor (capture_block_dialog.dart
// _validateKelvin/_validateTint). Not part of validPlan, so earlier saved
// examples stay readable.
export function whiteBalanceEditErrors(mode,kelvinText,tintText) {
  const errors={},{minKelvin,maxKelvin,maxAbsTint}=whiteBalanceLimits,k=String(kelvinText??'').trim(),t=String(tintText??'').trim();
  if(mode==='Kelvin'&&!(/^\d+$/.test(k)&&Number(k)>=minKelvin&&Number(k)<=maxKelvin))errors.kelvin=`Enter a whole number of kelvins, ${minKelvin}–${maxKelvin}.`;
  if(tintApplies(mode)&&t!==''&&!(Number.isFinite(Number(t))&&Math.abs(Number(t))<=maxAbsTint))errors.tint=`Enter a number from −${maxAbsTint} to ${maxAbsTint}, as the camera shows it, or leave it blank.`;
  return errors;
}
export const fixtureAssumptions = Object.freeze({
  usableSeconds:4*3600+15*60, windowStart:'00:30', windowEnd:'04:45',
  perFrameOverhead:7.5, outsideSetup:15*60, bytesPerFrame:30_000_000
});
export function parseExposure(input) {
  const text=String(input).trim().replace(',','.');
  if(!/^\d+(?:\.\d+)?(?:\s*\/\s*\d+(?:\.\d+)?)?$/.test(text))return null;
  const [a,b='1']=text.split('/').map(Number), result=a/b;
  return Number.isFinite(result)&&result>0?result:null;
}
export function defaultBlock(id='light-1') {
  return {id,type:'Light',exposure:'60',count:120,filter:'Broadband',iso:null,gain:null,binning:1,whiteBalance:'Unrecorded',kelvin:null,tint:null,focus:'Unrecorded',placement:'window'};
}
// A new block's editor starting point: like the app (no filter for a colour,
// phone or Unknown class), the filter field starts empty and shows only a
// placeholder. defaultBlock keeps its fixture values for existing callers.
export function newBlock(id) {return {...defaultBlock(id),filter:''};}
export function defaultPlan() {
  return {version:1,target:'M31',rig:'dslr',site:'Kyiv outskirts',night:'2026-10-19',blocks:[{...defaultBlock(),iso:800,whiteBalance:'Auto',source:'Recorded example'}]};
}
export function rigFor(plan){return plan?.rigSnapshot||rigs[plan?.rig];}
export function targetName(plan){return plan?.targetSnapshot?.name||targets[plan?.target]||'No target chosen';}
export function blockProblems(block,rigKey,budget=fixtureAssumptions) {
  const rig=typeof rigKey==='object'?rigKey:rigs[rigKey];
  const errors={};
  if(!['Light','Dark','Flat','Bias'].includes(block.type))errors.type='Choose a frame type.';
  if(parseExposure(block.exposure)===null)errors.exposure='Enter positive seconds, for example 60 or 1/125.';
  if(!Number.isSafeInteger(Number(block.count))||Number(block.count)<1)errors.count='Enter a positive whole number of frames.';
  const sensitivity=rig?.sensitivity;
  if(sensitivity==='iso'&&block.iso!==null&&(!Number.isSafeInteger(Number(block.iso))||Number(block.iso)<=0))errors.iso='Enter a positive whole ISO value or leave it unrecorded.';
  if(sensitivity==='gain'&&block.gain!==null&&(!Number.isFinite(Number(block.gain))||Number(block.gain)<0))errors.gain='Enter a non-negative gain or leave it unrecorded.';
  if(rig?.sensitivity==='gain'&&(!Number.isSafeInteger(Number(block.binning))||Number(block.binning)<1))errors.binning='Enter a positive whole binning value.';
  if(['dslrMirrorless','phone','unknown'].includes(rig?.cameraClass)&&block.whiteBalance==='Kelvin'&&(!Number.isSafeInteger(Number(block.kelvin))||Number(block.kelvin)<=0))errors.kelvin='Enter a positive whole colour temperature in K.';
  if(block.tint!==null&&block.tint!==undefined&&!Number.isFinite(Number(block.tint)))errors.tint='Enter a numeric tint or leave it unrecorded.';
  if(typeof block.filter!=='string'||block.filter.length>100)errors.filter='Keep the filter name within 100 characters.';
  if(!['window','outside'].includes(block.placement))errors.placement='Choose when the block is planned.';
  const duration=(parseExposure(block.exposure)+(budget.perFrameOverhead||0))*Number(block.count);
  if(!Number.isFinite(duration)||duration>Number.MAX_SAFE_INTEGER/1e6)errors.count='This capture duration is too large to represent safely. Use a smaller exposure or frame count.';
  return errors;
}
export function validPlan(plan) {
  return plan?.version===1&&(plan.target===''||Object.hasOwn(targets,plan.target)||validTargetSnapshot(plan))&&
    (plan.rig===''||Object.hasOwn(rigs,plan.rig)||validRigSnapshot(plan))&&(['','Kyiv outskirts','Rural site'].includes(plan.site)||validSiteSnapshot(plan))&&
    fixtureDates.includes(plan.night)&&Array.isArray(plan.blocks)&&plan.blocks.length<=100&&
    plan.blocks.every(block=>block&&typeof block==='object')&&
    new Set(plan.blocks.map(block=>block.id)).size===plan.blocks.length&&
    (!plan.budgetSnapshot||['perFrameOverhead','outsideSetup','fitMargin','bytesPerFrame'].every(k=>Number.isFinite(plan.budgetSnapshot[k])&&(k==='bytesPerFrame'?plan.budgetSnapshot[k]>0:plan.budgetSnapshot[k]>=0)))&&
    (!plan.assumptions||['perFrameOverhead','outsideSetup','fitMargin','bytesPerFrame'].every(k=>plan.assumptions[k]===undefined||Number.isFinite(plan.assumptions[k])&&(k==='bytesPerFrame'?plan.assumptions[k]>0:plan.assumptions[k]>=0)))&&
    plan.blocks.every(block=>typeof block.id==='string'&&Object.keys(blockProblems(block,rigFor(plan),assumptionsFor(plan))).length===0);
}
export function readSavedPlan(storage) {
  try {const value=JSON.parse(storage.getItem(planStorageKey));const active=value?.kind==='planning-lab-v2'?value.active:value;return validPlan(active)?active:null;} catch {return null;}
}
export function relativeGroups(plan) {
  const groups=new Map(),kind=rigFor(plan)?.sensitivity;
  for(const block of plan.blocks.filter(block=>block.type==='Light')) {
    const value=kind?block[kind]:null,known=kind&&value!==null&&value!=='';
    const key=known?JSON.stringify([parseExposure(block.exposure),block.filter,kind,Number(value),kind==='gain'?Number(block.binning):1]):block.id;
    const group=groups.get(key)||{frames:0,filter:block.filter,exposure:parseExposure(block.exposure),recorded:!!known,
      kind:known?kind:null,value:known?Number(value):null,binning:kind==='gain'?Number(block.binning):1,blocks:[]};
    group.frames+=Number(block.count);group.blocks.push({id:block.id,count:Number(block.count)});groups.set(key,group);
  }
  return [...groups.values()].map(group=>({...group,gain:Math.sqrt(group.frames)}));
}
// StackingGainCurve.of (lib/domain/services/stacking_gain_curve.dart) for one
// comparable group: one frame to twice the plan (at least 4), the plan's count
// always sampled. `relative` is √(T / T_plan); one exposure per group makes it
// √(N / N_plan). Relative only, never combined across groups.
export function planRelativeCurve(frames,samples=32) {
  const planned=Math.max(Number.isSafeInteger(frames)?frames:0,1),maxFrames=Math.max(4,2*planned),n=Math.max(samples,2);
  const counts=[...new Set([...Array.from({length:n},(_,i)=>1+Math.round((maxFrames-1)*i/(n-1))),planned])].sort((a,b)=>a-b);
  return {frames:planned,maxFrames,points:counts.map(c=>({frames:c,gain:Math.sqrt(c),relative:Math.sqrt(c/planned)}))};
}
// Each block's step within its group, in plan order: cumulative √N after the
// block and what that block added. Order-dependent by construction.
export function blockSteps(group) {
  let cumulative=0;
  return (group?.blocks||[]).map(block=>{const before=Math.sqrt(cumulative);cumulative+=block.count;const gain=Math.sqrt(cumulative);return {...block,cumulative,gain,added:gain-before};});
}
// Saved budget is a historical fallback; current global preferences may be
// previewed without altering it. Explicit per-plan assumptions remain overrides.
export function assumptionsFor(plan,overrides=null){const a={...(plan.budgetSnapshot||{}),...(overrides||{}),...(plan.assumptions||{})};return {perFrameOverhead:Number.isFinite(a.perFrameOverhead)&&a.perFrameOverhead>=0?a.perFrameOverhead:fixtureAssumptions.perFrameOverhead,outsideSetup:Number.isFinite(a.outsideSetup)&&a.outsideSetup>=0?a.outsideSetup:fixtureAssumptions.outsideSetup,bytesPerFrame:Number.isFinite(a.bytesPerFrame)&&a.bytesPerFrame>0?a.bytesPerFrame:fixtureAssumptions.bytesPerFrame,fitMargin:Number.isFinite(a.fitMargin)&&a.fitMargin>=0?a.fitMargin:900};}
function validRigSnapshot(p){const r=p.rigSnapshot;return typeof p.rig==='string'&&p.rig.startsWith('library:')&&r&&typeof r.name==='string'&&Object.hasOwn(cameraClassLabels,r.cameraClass)&&r.sensitivity===(['astroColour','astroMono'].includes(r.cameraClass)?'gain':['phone','dslrMirrorless'].includes(r.cameraClass)?'iso':null);}
function validTargetSnapshot(p){const t=p.targetSnapshot;return typeof p.target==='string'&&p.target.startsWith('library:')&&t?.id===p.target&&typeof t.name==='string'&&Number.isFinite(t.raDeg)&&t.raDeg>=0&&t.raDeg<360&&Number.isFinite(t.decDeg)&&Math.abs(t.decDeg)<=90;}
function validSiteSnapshot(p){const s=p.siteSnapshot;return s&&p.site==='library:'+s.id&&typeof s.name==='string'&&typeof s.zone==='string'&&Number.isFinite(s.latDeg)&&Math.abs(s.latDeg)<=90&&Number.isFinite(s.lonDeg)&&Math.abs(s.lonDeg)<=180;}

export function estimate(plan,overrides=null) {
  const a=assumptionsFor(plan,overrides),night=fixtureNight(plan.night,plan.exampleScenario||'ready');
  let integration=0,window=0,outside=a.outsideSetup,frames=0;
  for(const block of plan.blocks) {
    const exposure=parseExposure(block.exposure),count=Number(block.count);
    if(exposure===null||!Number.isSafeInteger(count)||count<1)continue;
    const span=(exposure+a.perFrameOverhead)*count;
    if(block.type==='Light')integration+=exposure*count;
    if(block.type==='Light'||block.placement==='window')window+=span;else outside+=span;
    frames+=count;
  }
  const missing=!plan.site?'Needs a site':!plan.target?'Needs a target':!plan.rig?'Needs a rig':!plan.blocks.some(block=>block.type==='Light')?'Needs a block':null;
  const fixtureContext=!plan.siteSnapshot&&!plan.targetSnapshot;
  const usable=plan.site&&plan.target&&fixtureContext?totalTime(night.targetWindows)/1000:null;
  const verdict=missing||(!fixtureContext?'Needs window':!usable?'No window':window>usable?"Doesn’t fit":usable-window<a.fitMargin?'Tight':'Fits');
  return {integration,needed:window,total:window+outside,outside,frames,bytes:frames*a.bytesPerFrame,usable,verdict,missing,groups:relativeGroups(plan),windowStart:fixtureContext?night.targetWindows[0]?.start??null:null,windowEnd:fixtureContext?night.targetWindows.at(-1)?.end??null:null,assumptions:a};
}
export function duration(seconds) {
  if(seconds===null||!Number.isFinite(seconds))return 'Unknown';
  if(seconds>0&&seconds<1)return `${Number(seconds.toPrecision(3))} s`;
  const rounded=Math.round(seconds),h=Math.floor(rounded/3600),m=Math.floor(rounded%3600/60),s=rounded%60;
  return [h?`${h} h`:'',m?`${m} min`:'',(!h&&!m)||s?`${s} s`:''].filter(Boolean).join(' ');
}

// One canonical lab record; copy saves retain prior immutable snapshots here.
export function readPlanArchive(storage){try{const data=JSON.parse(storage.getItem(planStorageKey));return data?.kind==='planning-lab-v2'&&Array.isArray(data.archive)?data.archive.filter(validPlan):[];}catch{return [];}}
export function savePlanRecord(storage,plan){if(!validPlan(plan))throw new Error('Invalid plan');const prior=readSavedPlan(storage),archive=readPlanArchive(storage);const id=x=>x.id||'example-original';if(prior&&id(prior)!==id(plan)&&!archive.some(x=>id(x)===id(prior)))archive.push(structuredClone(prior));storage.setItem(planStorageKey,JSON.stringify({kind:'planning-lab-v2',active:plan,archive}));}
export function saveProblem(plan){if(!plan.site)return 'Choose an observing site.';if(!plan.target)return 'Choose a target.';if(!plan.rig)return 'Choose a rig.';return null;}
export const navigationDraftKey='culmina-plan-navigation-v1';
export function readNavigationDraft(storage){try{const d=JSON.parse(storage.getItem(navigationDraftKey));return validPlan(d?.plan)&&typeof d.savedSnapshot==='string'&&typeof d.hasSaved==='boolean'?d:null;}catch{return null;}}
export function writeNavigationDraft(storage,state){if(!validPlan(state.plan))throw new Error('Invalid plan draft');storage.setItem(navigationDraftKey,JSON.stringify(state));}
export function adoptViewedNight(state,date,choice='continue'){
 if(!fixtureDates.includes(date))return {status:'error',reason:'This date has no example night data.'};
 const changed=JSON.stringify(state.plan)!==state.savedSnapshot;
 if(state.hasSaved&&changed&&!['save','discard'].includes(choice))return {status:choice==='cancel'?'cancelled':'needs-choice'};
 let source=state.plan;
 if(state.hasSaved&&changed&&choice==='discard'){try{source=JSON.parse(state.savedSnapshot);}catch{return {status:'error',reason:'Saved source is unavailable.'};}}
 const copy=structuredClone(source),wasSaved=state.hasSaved;
 if(wasSaved){copy.id='preview-'+Date.now()+'-'+Math.random().toString(36).slice(2,6);copy.copyOfId=source.id||'example-original';}
 copy.night=date;
 return {status:'adopted',source:structuredClone(source),state:{plan:copy,savedSnapshot:wasSaved?'':state.savedSnapshot,hasSaved:false},message:wasSaved?'Created a draft copy for '+date+'. The saved original is unchanged.':'Draft night changed to '+date+'. Not saved.'};
}
