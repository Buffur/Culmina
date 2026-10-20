import test from 'node:test';
import assert from 'node:assert/strict';
import {defaultPlan,estimate,assumptionsFor,savePlanRecord,readSavedPlan,planStorageKey} from '../plan-model.js';
import {initialPlanningPreferences,readPlanningPreferences,planningBudget,settingsKey} from '../preview-bridge.js';

function store(){const records=new Map();return {getItem:key=>records.get(key)??null,setItem:(key,value)=>records.set(key,value),removeItem:key=>records.delete(key)};}
const hybridPreferences=(storage,plan)=>readPlanningPreferences(storage,{initialDefaults:true,plan});
const budget=(storage,plan)=>planningBudget(plan,hybridPreferences(storage,plan),estimate(plan).usable);

test('fresh Hybrid uses Settings defaults with seconds, a percentage of usable time and setup off',()=>{
  const storage=store(),plan=defaultPlan(),preferences=hybridPreferences(storage,plan),e=estimate(plan,budget(storage,plan));
  assert.equal(preferences.perFrameOverheadSeconds,5);
  assert.equal(preferences.feasibilityMarginPercent,15);
  assert.equal(preferences.setupMinutes,null);
  assert.equal(e.needed,7800); // 120 × (60 s exposure + 5 s delay)
  assert.equal(e.total,7800); // optional setup is not included
  assert.equal(e.assumptions.fitMargin,2295); // 15% of the 15300 s usable window, not 15 min
  assert.equal(storage.getItem(settingsKey),null);
  assert.equal(storage.getItem(planStorageKey),null);
  preferences.perFrameOverheadSeconds=99;
  assert.equal(initialPlanningPreferences.perFrameOverheadSeconds,5);
});

test('new plan after changed Settings uses their current values without saving or mutating records',()=>{
  const storage=store(),plan=defaultPlan();
  storage.setItem(settingsKey,JSON.stringify({kind:'culmina-settings-preview',version:1,settings:{planning:{...initialPlanningPreferences,perFrameOverheadSeconds:12,feasibilityMarginPercent:20,setupMinutes:10}}}));
  const before=storage.getItem(settingsKey),e=estimate(plan,budget(storage,plan));
  assert.equal(e.needed,8640);
  assert.equal(e.total,9240);
  assert.equal(e.assumptions.fitMargin,3060);
  assert.equal(storage.getItem(settingsKey),before);
  assert.equal(storage.getItem(planStorageKey),null);
});

test('explicit user overrides retain fixed-minute meaning when Settings change',()=>{
  const storage=store(),plan=defaultPlan();
  plan.assumptions={perFrameOverhead:8,outsideSetup:180,fitMargin:600};
  storage.setItem(settingsKey,JSON.stringify({kind:'culmina-settings-preview',version:1,settings:{planning:{...initialPlanningPreferences,perFrameOverheadSeconds:30,feasibilityMarginPercent:50}}}));
  savePlanRecord(storage,{...plan,budgetSnapshot:assumptionsFor(plan,budget(storage,plan))});
  const savedBefore=storage.getItem(planStorageKey),saved=readSavedPlan(storage),e=estimate(saved,budget(storage,saved));
  assert.equal(e.assumptions.perFrameOverhead,8);
  assert.equal(e.assumptions.fitMargin,600);
  assert.equal(e.total,8340);
  assert.equal(storage.getItem(planStorageKey),savedBefore);
});

test('saved budget remains historical fallback without stored Settings; initial defaults never overwrite it',()=>{
  const storage=store(),plan={...defaultPlan(),budgetSnapshot:{perFrameOverhead:7.5,outsideSetup:900,fitMargin:900,bytesPerFrame:30000000}};
  savePlanRecord(storage,plan);
  const before=storage.getItem(planStorageKey),saved=readSavedPlan(storage);
  assert.equal(hybridPreferences(storage,saved),null);
  assert.equal(estimate(saved,budget(storage,saved)).total,9000);
  assert.equal(storage.getItem(planStorageKey),before);
});

test('original variants retain fixture fallback and an unknown window never becomes a percentage of zero',()=>{
  const storage=store(),plan=defaultPlan();
  assert.equal(readPlanningPreferences(storage),null);
  assert.equal(planningBudget(plan,readPlanningPreferences(storage),15300),null);
  assert.equal(estimate(plan).total,9000);
  assert.equal(Object.hasOwn(planningBudget(plan,hybridPreferences(storage,plan),null),'fitMargin'),false);
});
