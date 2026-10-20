import test from 'node:test';
import assert from 'node:assert/strict';
import {defaultPlan,validPlan,estimate,savePlanRecord,readSavedPlan,rigFor,blockProblems,assumptionsFor} from '../plan-model.js?v=20261020-hybrid4';
import {readLibraryChoices,selectLibraryRecord,planningBudget,readPlanningPreferences,libraryKey,settingsKey} from '../preview-bridge.js?v=20261020-hybrid4';
import {capturePreviewBackup,validatePreviewBackup,restorePreviewBackup,previewBackupKeys} from '../preview-backup.js?v=20261020-hybrid4';
const store=()=>{const m=new Map();return {getItem:k=>m.get(k)??null,setItem:(k,v)=>m.set(k,v),removeItem:k=>m.delete(k)};};
test('Library selection snapshots preserve identity, camera semantics and unknown custom window',()=>{
 const s=store(),r={id:'local-rig-a',name:'My mono rig',cameraClass:'astroMono',gain:10},t={id:'local-target-a',name:'My target',catalogId:'Custom',type:'Other',raDeg:12,decDeg:-20},site={id:'local-site-a',name:'My site',latDeg:45,lonDeg:20,zone:'Europe/Kyiv'};
 s.setItem(libraryKey,JSON.stringify({kind:'culmina-library-preview',version:1,rigs:[r],targets:[t],sites:[site]}));
 const c=readLibraryChoices(s),p=defaultPlan();for(const [kind,value]of [['rig','library:local-rig-a'],['target','library:local-target-a'],['site','library:local-site-a']])selectLibraryRecord(p,kind,value,c);
 assert.equal(validPlan(p),true);assert.equal(rigFor(p).sensitivity,'gain');assert.equal(estimate(p).usable,null);assert.equal(estimate(p).verdict,'Needs window');assert.equal(estimate(p).integration,7200);
 savePlanRecord(s,p);c.rigs[p.rig].name='Edited later';c.targets.find(x=>x.id===p.target).name='Edited later';assert.equal(readSavedPlan(s).rigSnapshot.name,'My mono rig');assert.equal(p.targetSnapshot.name,'My target');
 assert.ok(blockProblems({...p.blocks[0],gain:-1},rigFor(p)).gain);assert.ok(blockProblems({...p.blocks[0],binning:0},rigFor(p)).binning);
});
test('Global budget changes preview current fit without mutating saved snapshot; per-plan overrides win',()=>{
 const s=store(),p=defaultPlan();savePlanRecord(s,p);const before=s.getItem('culmina-plan-preview-v1');
 s.setItem(settingsKey,JSON.stringify({kind:'culmina-settings-preview',version:1,settings:{planning:{perFrameOverheadSeconds:60,setupMinutes:30,feasibilityMarginPercent:50}}}));
 const b=planningBudget(p,readPlanningPreferences(s),15300),e=estimate(p,b);assert.equal(e.needed,14400);assert.equal(e.total,16200);assert.equal(e.verdict,'Tight');assert.equal(s.getItem('culmina-plan-preview-v1'),before);
 p.assumptions={perFrameOverhead:0};assert.equal(estimate(p,b).needed,7200);assert.equal(assumptionsFor(p,b).outsideSetup,1800);
 const candidate={...p,budgetSnapshot:assumptionsFor(p,b)};savePlanRecord(s,candidate);assert.equal(estimate(readSavedPlan(s)).total,9000);
});
test('Corrupt collection shapes, invalid coordinates and invalid budget snapshots are rejected safely',()=>{
 const s=store();s.setItem(libraryKey,JSON.stringify({kind:'culmina-library-preview',version:1,rigs:{},targets:[{id:'bad',name:'Bad',raDeg:999,decDeg:0}],sites:[]}));assert.equal(readLibraryChoices(s).targets.length,6);
 assert.equal(validPlan({...defaultPlan(),budgetSnapshot:{perFrameOverhead:-1}}),false);
 assert.equal(validPlan({...defaultPlan(),target:'library:bad',targetSnapshot:{id:'library:bad',name:'Bad',raDeg:999,decDeg:0}}),false);
});
test('Prototype backup validates archives, protects stale state and rolls back refused writes',()=>{
 const s=store(),empty=capturePreviewBackup(s),baseline={...empty.records};assert.equal(validatePreviewBackup(empty),true);
 const broken=structuredClone(empty);broken.records['culmina-plan-preview-v1']=JSON.stringify({kind:'planning-lab-v2',active:defaultPlan(),archive:[{version:999}]});assert.equal(validatePreviewBackup(broken),false);
 s.setItem('unrelated-owner-key','keep');s.setItem('culmina-plan-preview-v1',JSON.stringify(defaultPlan()));assert.equal(restorePreviewBackup(s,empty,baseline).kind,'stale');assert.equal(s.getItem('unrelated-owner-key'),'keep');
 const target=structuredClone(empty);target.records['culmina-plan-preview-v1']=JSON.stringify(defaultPlan());target.records['culmina-plan-navigation-v1']=JSON.stringify({plan:defaultPlan(),savedSnapshot:'',hasSaved:false});
 assert.equal(validatePreviewBackup(target),true);const failing=store();let writes=0;const rawSet=failing.setItem;failing.setItem=(k,v)=>{if(++writes===2)throw Error('disk full');rawSet(k,v);};const result=restorePreviewBackup(failing,target,baseline);assert.deepEqual(result,{ok:false,kind:'write',rollbackComplete:true});for(const key of previewBackupKeys)assert.equal(failing.getItem(key),null);
});
