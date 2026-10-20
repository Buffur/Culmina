import test from 'node:test';
import assert from 'node:assert/strict';
import {defaultPlan,defaultBlock,estimate,parseExposure,relativeGroups,blockProblems,readSavedPlan,planStorageKey,validPlan,duration} from '../plan-model.js';

test('reference fixture separates integration, window budget, total and storage',()=>{
  const e=estimate(defaultPlan());
  assert.deepEqual([e.integration,e.needed,e.total,e.bytes,e.usable],[7200,8100,9000,3_600_000_000,15300]);
  assert.equal(e.verdict,'Fits');
  assert.ok(Math.abs(e.groups[0].gain-10.954451150103322)<1e-10);
});
test('a longer plan exceeds the same fixture window',()=>{
  const plan=defaultPlan();plan.blocks[0].count=240;
  assert.equal(estimate(plan).needed,16200);assert.equal(estimate(plan).verdict,'Doesn’t fit');
});
test('fractional and decimal exposure entry have equivalent positive meaning',()=>{
  assert.equal(parseExposure('1/125'),0.008);assert.equal(parseExposure('0,008'),0.008);
  assert.equal(duration(0.008),'0.008 s');assert.equal(duration(0.96),'0.96 s');
  for(const value of ['0','1/0','-10','Infinity','bad',''])assert.equal(parseExposure(value),null,value);
});
test('calibration outside the window changes total/storage, not integration or fit time',()=>{
  const plan=defaultPlan();plan.blocks.push({...defaultBlock('dark'),type:'Dark',count:30,placement:'outside'});
  const e=estimate(plan);assert.equal(e.integration,7200);assert.equal(e.needed,8100);
  assert.equal(e.total,11025);assert.equal(e.frames,150);assert.equal(e.groups.length,1);
});
test('known equivalent light blocks combine while different exposure/filter stays separate',()=>{
  const plan=defaultPlan();plan.blocks.push({...defaultBlock('second'),count:60,iso:800});
  assert.equal(relativeGroups(plan)[0].frames,180);
  plan.blocks[1].exposure='120';assert.equal(relativeGroups(plan).length,2);
  plan.blocks[1].exposure='60';plan.blocks[1].filter='Custom filter';assert.equal(relativeGroups(plan).length,2);
});
test('unrecorded sensitivity is not treated as a matching zero or merged group',()=>{
  const plan=defaultPlan();plan.blocks[0].iso=null;plan.blocks.push({...defaultBlock('second'),iso:null});
  assert.equal(relativeGroups(plan).length,2);assert.ok(relativeGroups(plan).every(g=>!g.recorded));
});
test('camera class selects gain versus ISO without converting one into the other',()=>{
  const plan=defaultPlan();plan.rig='astro';plan.blocks.push(defaultBlock('second'));
  assert.equal(relativeGroups(plan).length,2);
  plan.blocks.forEach(b=>b.gain=100);assert.equal(relativeGroups(plan).length,1);
  assert.ok(blockProblems({...plan.blocks[0],gain:-1},'astro').gain);
  assert.ok(blockProblems({...plan.blocks[0],iso:0},'dslr').iso);
});
test('missing inputs and empty light plan stay neutral',()=>{
  const plan=defaultPlan();plan.site='';assert.equal(estimate(plan).verdict,'Needs a site');assert.equal(estimate(plan).usable,null);
  plan.site='Kyiv outskirts';plan.target='';assert.equal(estimate(plan).verdict,'Needs a target');
  plan.target='M31';plan.rig='';assert.equal(estimate(plan).verdict,'Needs a rig');
  plan.rig='dslr';plan.blocks=[];assert.equal(estimate(plan).verdict,'Needs a block');
});
test('snapshot round trip retains custom filter, optional records and fractional exposure',()=>{
  const plan=defaultPlan();Object.assign(plan.blocks[0],{filter:'My custom filter',focus:'MF',whiteBalance:'Custom',exposure:'1/125'});
  assert.ok(validPlan(plan));const storage={getItem:key=>key===planStorageKey?JSON.stringify(plan):null};
  assert.deepEqual(readSavedPlan(storage),plan);
});
test('Kelvin requires a positive record without inventing a hardware range',()=>{
  const block={...defaultBlock(),whiteBalance:'Kelvin',kelvin:null};
  assert.ok(blockProblems(block,'dslr').kelvin);
  assert.equal(blockProblems({...block,kelvin:5600,tint:-2},'dslr').kelvin,undefined);
  assert.ok(blockProblems({...block,kelvin:5600,tint:NaN},'dslr').tint);
});
test('malformed, invalid and unavailable preview storage has an honest fallback',()=>{
  for(const value of ['{','null',JSON.stringify({...defaultPlan(),blocks:[null]}),JSON.stringify({...defaultPlan(),blocks:[{...defaultBlock(),count:0}]})])assert.equal(readSavedPlan({getItem:()=>value}),null);
  assert.equal(readSavedPlan({getItem(){throw new Error('Storage denied');}}),null);
});

test('new blocks do not invent recorded sensitivity or white balance',()=>{const b=defaultBlock();assert.equal(b.iso,null);assert.equal(b.gain,null);assert.equal(b.whiteBalance,'Unrecorded');});

test('large finite duration is rejected before date or schedule rendering can overflow',()=>{const block={...defaultBlock(),exposure:'10000000000000000',count:1};assert.ok(blockProblems(block,'dslr').count);assert.equal(validPlan({...defaultPlan(),blocks:[block]}),false);});

test('tiny exposures with enormous frame counts cannot overflow the overhead schedule',()=>{const b={...defaultBlock(),exposure:'1/10000000000000',count:9007199254740990};assert.ok(blockProblems(b,'dslr').count);assert.equal(validPlan({...defaultPlan(),blocks:[b]}),false);});
