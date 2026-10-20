import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {searchTargets,targetSample,catalogObjectCount,newBlock,defaultPlan,whiteBalanceEditErrors,whiteBalanceText,planRelativeCurve,blockSteps,relativeGroups} from '../plan-model.js';
import {fixtureNight,weatherForNight,weatherSlots,localInstant} from '../night-model.js';
import {weatherDigest,weatherFreshnessLabel,weatherWidgetSummary,dayTag,skyGradient,moonFreeSummary} from '../night-ui.js';

test('search normalizes actual catalogue aliases and retains exact-match priority',()=>{
  for(const q of ['M031','Messier 31','NGC-00224','andromeda'])assert.equal(searchTargets(q)[0]?.id,'M31');
  assert.equal(searchTargets('LBN 974')[0]?.id,'M42');
  assert.equal(searchTargets('nothing matches this').length,0);
  assert.equal(searchTargets('').length,targetSample.length);
});
test('search examples are real bundled catalogue records, never new objects',()=>{
  const data=JSON.parse(readFileSync(new URL('../../../assets/catalog/catalog_v2.json',import.meta.url)));
  assert.equal(data.objects.length,catalogObjectCount);
  for(const t of targetSample){const actual=data.objects.find(o=>o.id===t.id);assert.ok(actual);assert.equal(actual.type,t.type);assert.ok(actual.name===t.name||actual.aliasNames.includes(t.name));assert.deepEqual(t.aliasIds,actual.aliasIds);assert.deepEqual(t.aliasNames,actual.aliasNames);}
});
test('new filter is genuinely empty; recorded sample filter remains intact',()=>{
  assert.equal(newBlock('new').filter,'');assert.equal(defaultPlan().blocks[0].filter,'Broadband');
});
test('WB edit bounds match domain sanity bounds, Custom tint is not Kelvin',()=>{
  assert.deepEqual(whiteBalanceEditErrors('Kelvin','5600','-10'),{});
  for(const v of ['','999','40001','5600.5'])assert.ok(whiteBalanceEditErrors('Kelvin',v,'').kelvin);
  assert.deepEqual(whiteBalanceEditErrors('Custom','','25'),{});
  assert.ok(whiteBalanceEditErrors('Custom','','1001').tint);
  assert.equal(whiteBalanceText({whiteBalance:'Kelvin',kelvin:5600,tint:-10}),'5600 K, tint -10');
});
test('time graph includes planned normalization and uses the app curve formula',()=>{
  for(const n of [1,2,120,500]){const c=planRelativeCurve(n);assert.equal(c.points.find(p=>p.frames===n).relative,1);assert.equal(c.maxFrames,Math.max(4,n*2));for(const p of c.points)assert.equal(p.relative,Math.sqrt(p.frames/n));}
});
test('graph block steps remain within one comparable group with diminishing increments',()=>{
  const p=defaultPlan();p.blocks.push({...p.blocks[0],id:'second'});const groups=relativeGroups(p);assert.equal(groups.length,1);const s=blockSteps(groups[0]);assert.equal(s[1].cumulative,240);assert.ok(s[1].added<s[0].added);assert.equal(s[1].gain,Math.sqrt(240));
});
test('weather digest keeps temperatures when cloud alone is unknown',()=>{
  const n=fixtureNight(),s=weatherForNight(n,'missing-variable'),d=weatherDigest(n,s);
  assert.equal(d.clearest,null);assert.equal(d.cloudiest,null);assert.equal(d.tempMin,s.tempMin);assert.ok(d.any);assert.equal(d.dewKnown,s.dewKnownSamples);
});
test('weather digest distinguishes no forecast from zero precipitation',()=>{
  const n=fixtureNight();for(const scene of ['unknown','loading','error']){const d=weatherDigest(n,weatherForNight(n,scene));assert.equal(d.any,false);assert.equal(d.precipMax,null);assert.equal(d.tempMin,null);}
  assert.equal(weatherDigest(n,weatherForNight(n)).precipMax,0);
});
test('preceding-only hour contributes gust but cannot contaminate instantaneous temperature',()=>{
  const n=fixtureNight(),s=structuredClone(weatherForNight(n));const last=weatherSlots(n,s).find(h=>!h.instant&&h.precedingMinutes>=30);assert.ok(last);
  const row=s.hours.find(h=>h.start===last.start);row.temp=999;row.cloud=100;row.wind=999;row.gust=123;
  const d=weatherDigest(n,s);assert.ok(d.tempMax<999);assert.ok(d.windMax<999);assert.equal(d.gustMax,123);
});
test('unavailable rows with residual values do not enter digest aggregates',()=>{
  const n=fixtureNight(),s=structuredClone(weatherForNight(n));for(const h of s.hours){h.available=false;h.temp=999;h.gust=999;}
  const d=weatherDigest(n,s);assert.equal(d.any,false);assert.equal(d.tempMax,null);assert.equal(d.gustMax,null);
});
test('local day tags survive DST, and moon-free text retains next-day meaning',()=>{
  const n=fixtureNight('2026-10-24');assert.equal(dayTag(n,localInstant('2026-10-24','21:15')),'');assert.equal(dayTag(n,localInstant('2026-10-25','04:45')),' (+1)');assert.match(moonFreeSummary(n),/\(\+1\)/);
});
test('sky gradient represents all known event classes without moving model intervals',()=>{
  const n=fixtureNight(),before=JSON.stringify(n),g=skyGradient(n);for(const cls of ['day','civil','nautical','astro','dark'])assert.ok(g.includes('--sky-'+cls));assert.equal(JSON.stringify(n),before);
});

test('Home weather is a compact measured temperature and wind summary, not a cloud verdict',()=>{
  const n=fixtureNight(),s=weatherForNight(n),w=weatherWidgetSummary(n,s);
  assert.match(w.headline,/°C/);assert.match(w.headline,/km\/h/);
  assert.doesNotMatch(w.headline,/cloud|clear|good|score/i);
  assert.match(w.detail,/Example forecast/);
  const missing=weatherWidgetSummary(n,weatherForNight(n,'missing-variable'));
  assert.match(missing.headline,/°C/);assert.doesNotMatch(missing.headline,/unknown/i);
  const absent=weatherWidgetSummary(n,weatherForNight(n,'unknown'));
  assert.match(absent.headline,/unavailable/i);assert.doesNotMatch(absent.headline,/0|°C|km/);
});

test('smooth sky ramp uses ordered stops and preserves exact dark boundary colours',()=>{
  for(const date of ['2026-10-19','2026-10-24'])for(const scene of ['ready','no-dark','polar-dark']){
    const n=fixtureNight(date,scene),g=skyGradient(n);
    // Split CSS stops outside nested var()/color-mix() calls, not their colour weights.
    const stops=[];let depth=0,start=0;const body=g.slice('linear-gradient(90deg,'.length,-1);
    for(let i=0;i<body.length;i++){if(body[i]==='(')depth++;if(body[i]===')')depth--;if(body[i]===','&&depth===0){stops.push(body.slice(start,i));start=i+1;}}stops.push(body.slice(start));
    const positions=stops.map(s=>Number(s.match(/ ([\d.]+)%$/)?.[1]));
    assert.ok(positions.length>0);assert.equal(positions[0],0);assert.equal(positions.at(-1),100);
    for(let i=1;i<positions.length;i++)assert.ok(positions[i]>=positions[i-1],`${scene}: backwards stop`);
    if(n.skySegments.length>1)assert.match(g,/color-mix\(in oklab/);
    for(const x of n.dark){const at=t=>Number(((t-n.start)/(n.end-n.start)*100).toFixed(3));assert.ok(g.includes(`var(--sky-dark) ${at(x.start)}%`));assert.ok(g.includes(`var(--sky-dark) ${at(x.end)}%`));}
  }
});

test('Forecast age warns independently of full coverage without changing measured values',()=>{
 const n=fixtureNight('2026-10-19'),original=weatherForNight(n,'ready'),aged={...original,ageHours:12,stale:false};
 assert.equal(weatherFreshnessLabel({...aged,ageHours:2.99}),'');assert.equal(weatherFreshnessLabel({...aged,ageHours:3}),'Aging snapshot');
 assert.match(weatherWidgetSummary(n,aged).detail,/Stale snapshot/);assert.equal(weatherWidgetSummary(n,aged).headline,weatherWidgetSummary(n,original).headline);assert.equal(aged.coveredSamples,original.coveredSamples);
});
