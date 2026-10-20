// Explicit browser fixtures matching existing Night/Moon/Weather data shapes.
// No ephemeris, weather request, reliability score, or production calculation.
export const zone='Europe/Kyiv';
export const fixtureNow=Date.parse('2026-10-19T16:00:00Z');
export const retrievedAt=Date.parse('2026-10-19T15:00:00Z');
export const dayMs=86400000;
export const fixtureDates=Array.from({length:14},(_,i)=>new Date(Date.UTC(2026,9,19+i)).toISOString().slice(0,10));
const minute=60000;
const instantCache=new Map();
export function nextDate(date){return new Date(Date.parse(date+'T12:00:00Z')+dayMs).toISOString().slice(0,10);}
export function previousDate(date){return new Date(Date.parse(date+'T12:00:00Z')-dayMs).toISOString().slice(0,10);}
export function localInstant(date,time){const key=date+'T'+time;if(instantCache.has(key))return instantCache.get(key);const formatter=new Intl.DateTimeFormat('en-CA',{timeZone:zone,year:'numeric',month:'2-digit',day:'2-digit',hour:'2-digit',minute:'2-digit',hourCycle:'h23'});const candidates=['+03:00','+02:00'].map(offset=>Date.parse(`${date}T${time}:00${offset}`)).filter(t=>{const parts=Object.fromEntries(formatter.formatToParts(t).map(x=>[x.type,x.value]));return `${parts.year}-${parts.month}-${parts.day}T${parts.hour}:${parts.minute}`===key;});if(!candidates.length)throw new Error('No valid local fixture instant: '+key);const result=Math.min(...candidates);instantCache.set(key,result);return result;}
// When a fixture wall time repeats, choose its first occurrence; cursor steps
// remain UTC elapsed minutes and include offsets so both occurrences differ.
export function timeLabel(utc,includeDate=false){return new Intl.DateTimeFormat('en-GB',{timeZone:zone,...(includeDate?{day:'2-digit',month:'short'}:{}),hour:'2-digit',minute:'2-digit',hourCycle:'h23'}).format(utc);}
export function instantLabel(utc){return new Intl.DateTimeFormat('en-GB',{timeZone:zone,day:'numeric',month:'short',hour:'2-digit',minute:'2-digit',hourCycle:'h23',timeZoneName:'shortOffset'}).format(utc);}
export function nightLabel(date){const formatter=new Intl.DateTimeFormat('en-GB',{day:'numeric',month:'short',timeZone:'UTC'}),a=formatter.format(Date.parse(date+'T12:00Z')),next=nextDate(date);return a+'–'+(next.slice(0,7)===date.slice(0,7)?Number(next.slice(-2)):formatter.format(Date.parse(next+'T12:00Z')));}
export function currentFixtureNight(now=Date.now()){return new Date(now-10*3600000).toISOString().slice(0,10);}
export function hoursLabel(ms){const m=Math.round(ms/minute);return `${Math.floor(m/60)?Math.floor(m/60)+' h ':''}${m%60?m%60+' min':''}`.trim()||'0 min';}
export function intersect(a,b){const start=Math.max(a.start,b.start),end=Math.min(a.end,b.end);return end>start?{start,end}:null;}
export function subtractIntervals(span,covered){let result=[span];for(const block of [...covered].sort((a,b)=>a.start-b.start)){result=result.flatMap(x=>{const hit=intersect(x,block);if(!hit)return [x];return [...(x.start<hit.start?[{start:x.start,end:hit.start}]:[]),...(hit.end<x.end?[{start:hit.end,end:x.end}]:[])];});}return result;}
export const totalTime=intervals=>intervals.reduce((n,x)=>n+x.end-x.start,0);
export function fixtureNight(date='2026-10-19',scenario='ready'){
 if(!fixtureDates.includes(date))date=fixtureDates[0];
 // ADR-007 / SessionNight: fixed mean-solar-noon UTC anchor, exactly 24 h.
 // This explicit example uses longitude 30°E (noon at 10:00Z), not civil noon.
 const tomorrow=nextDate(date),start=Date.parse(date+'T10:00:00Z'),end=start+dayMs;
 const sunset=localInstant(date,'18:00'),sunrise=localInstant(tomorrow,'07:00');
 let dark=[{start:localInstant(date,'21:15'),end:localInstant(tomorrow,'04:45')}];
 const index=fixtureDates.indexOf(date);
 const moonset=localInstant(tomorrow,'00:30')+Math.min(index,5)*35*minute;
 let moonUp=index<6?[{start:localInstant(date,'16:30'),end:moonset}]:[{start:localInstant(date,'20:00')+Math.min(index-6,6)*35*minute,end}];
 if(scenario==='no-dark')dark=[];if(scenario==='polar-dark')dark=[{start,end}];
 if(scenario==='moon-all')moonUp=[{start,end}];
 if(scenario==='moon-below')moonUp=[];
 if(scenario==='moon-middle')moonUp=[{start,end:localInstant(date,'23:00')},{start:localInstant(tomorrow,'02:00'),end}];
 if(scenario==='mixed')moonUp=[{start:localInstant(date,'23:00'),end:localInstant(tomorrow,'02:00')}];
 const moonFree=dark.flatMap(d=>subtractIntervals(d,moonUp));
 const darkMs=totalTime(dark),freeMs=totalTime(moonFree);
 const classification=!darkMs?'No dark time':!freeMs?'No moon-free dark':freeMs===darkMs?'Moon-free all dark time':moonFree.length>1?'Split moon-free intervals':moonFree[0].start===dark[0].start?'Moon-free in the evening':moonFree[0].end===dark.at(-1).end?'Moon-free in the morning':'Moon-free in the middle of dark time';
 const illumination=[62,71,80,88,94,98,100,99,95,89,81,72,62,51][index];
 const phase=index<6?'Waxing gibbous':index===6?'Full Moon':'Waning gibbous';
 const targetWindows=scenario==='no-dark'?[]:[{start:localInstant(tomorrow,'00:30'),end:localInstant(tomorrow,'04:45')}];
 const civilDusk=localInstant(date,'18:35'),nauticalDusk=localInstant(date,'19:25'),nauticalDawn=localInstant(tomorrow,'05:35'),civilDawn=localInstant(tomorrow,'06:25');
 const skySegments=scenario==='polar-dark'?[{start,end,sky:'Dark'}]:[{start,end:sunset,sky:'Daylight'},{start:sunset,end:civilDusk,sky:'Civil twilight'},{start:civilDusk,end:nauticalDusk,sky:'Nautical twilight'},...(dark.length?[{start:nauticalDusk,end:dark[0].start,sky:'Astronomical twilight'},{...dark[0],sky:'Dark'},{start:dark[0].end,end:nauticalDawn,sky:'Astronomical twilight'}]:[{start:nauticalDusk,end:nauticalDawn,sky:'Astronomical twilight'}]),{start:nauticalDawn,end:civilDawn,sky:'Nautical twilight'},{start:civilDawn,end:sunrise,sky:'Civil twilight'},{start:sunrise,end,sky:'Daylight'}];
 const solarEvents=scenario==='polar-dark'?['Sunset','Civil dusk','Nautical dusk','Astronomical dusk','Astronomical dawn','Nautical dawn','Civil dawn','Sunrise'].map(label=>({label,at:null})):null;
 return {date,zone,limitDeg:-18,skySegments,start,end,sunset,sunrise,dark,moonUp,moonFree,classification,illumination,phase,targetWindows,twilight:solarEvents||[{label:'Sunset',at:sunset},{label:'Civil dusk',at:localInstant(date,'18:35')},{label:'Nautical dusk',at:localInstant(date,'19:25')},{label:'Astronomical dusk',at:dark[0]?.start??null},{label:'Astronomical dawn',at:dark.at(-1)?.end??null},{label:'Nautical dawn',at:localInstant(tomorrow,'05:35')},{label:'Civil dawn',at:localInstant(tomorrow,'06:25')},{label:'Sunrise',at:sunrise}]};
}
const inside=(x,t)=>x.start<=t&&t<x.end;
export function cursorFacts(night,instant){
 const t=Math.min(night.end-300000,Math.max(night.start,instant));
 const dark=night.dark.find(x=>inside(x,t)),moonUp=night.moonUp.some(x=>inside(x,t));
 const free=night.moonFree.find(x=>inside(x,t));
 const next=night.dark.find(x=>x.start>t);
 const moonChange=night.moonUp.flatMap(x=>[x.start,x.end]).filter(x=>x>t&&x<night.end).sort((a,b)=>a-b)[0];
 const sky=night.skySegments.find(x=>inside(x,t))?.sky||'Daylight';
 const state=dark?(moonUp?'Dark · Moon above horizon':'Moon-free dark'):sky+' · '+(moonUp?'Moon above horizon':'Moon below horizon');
 const remaining=dark;
 const detail=remaining?`${hoursLabel(remaining.end-t)} remaining · until ${instantLabel(remaining.end)}`:next?`Darkness in ${hoursLabel(next.start-t)} · from ${instantLabel(next.start)}`:night.dark.length?'Dark time has ended for this night.':'No dark time at the selected −18° limit.';
 const compactDetail=free?`Moon-free for ${hoursLabel(free.end-t)} · until ${timeLabel(free.end)}`:detail.split(' · ')[0];
 return {instant:t,state,compactDetail,detail:detail+(free&&free.end!==dark.end?`. Moon-free for another ${hoursLabel(free.end-t)}, until ${instantLabel(free.end)}`:'')+(moonChange?`. Moon ${moonUp?'sets':'rises'} at ${instantLabel(moonChange)}.`:''),moon:moonUp?'Moon above horizon':'Moon below horizon'};
}
export function resetCursor(night,now=Date.now()){return now>=night.start&&now<night.end?{instant:night.start+Math.floor((now-night.start)/300000)*300000,label:'Now'}:{instant:night.start,label:'Night start'};}
const clouds=[22,18,15,25,30,24,19,28,36,42,35,27];
export function weatherHours(scenario='ready'){
 const end=Date.parse('2026-10-21T23:00Z');
 return Array.from({length:Math.round((end-retrievedAt)/3600000)},(_,i)=>{
  const start=retrievedAt+i*3600000,missing=scenario==='partial'&&[8,9,31].includes(i);
  const cloud=clouds[i%clouds.length];
  return {start,end:start+3600000,available:!missing,cloud:missing||scenario==='missing-variable'?null:cloud,temp:missing?null:Math.round((8-Math.sin(i/4)*3)*10)/10,dew:missing?null:Math.round((4-Math.sin(i/4)*2)*10)/10,wind:missing?null:Math.round((2+i%4)*36)/10,gust:missing?null:Math.round((4+i%5)*36)/10,precip:missing?null:i%17===0?20:0,visibility:missing?null:18000+i%3*1000,humidity:missing?null:65+i%20,low:missing?null:Math.round(cloud*.5),mid:missing?null:Math.round(cloud*.3),high:missing?null:Math.round(cloud*.2)};
 });
}
export function weatherForNight(night,scenario='ready',referenceNow=fixtureNow){
 const hours=weatherHours(scenario).filter(h=>h.end>night.start&&h.start<=night.end);
 const noForecast=['unknown','error','loading','no-site'].includes(scenario),rows=noForecast?[]:hours;
 const darkMs=totalTime(night.dark),instantRows=rows.filter(h=>night.dark.some(d=>h.start>=d.start&&h.start<=d.end));
 const sampleCount=night.dark.reduce((n,d)=>n+Math.floor(d.end/3600000)-Math.ceil(d.start/3600000)+1,0);
 const coveredSamples=instantRows.filter(h=>h.available!==false).length;
 const finite=key=>instantRows.map(h=>h[key]).filter(Number.isFinite),clouds=finite('cloud'),temps=finite('temp'),dews=finite('dew');
 const spreads=instantRows.filter(h=>Number.isFinite(h.temp)&&Number.isFinite(h.dew)).map(h=>h.temp-h.dew);
 const unavailable=darkMs>0&&coveredSamples===0,partial=coveredSamples>0&&coveredSamples<sampleCount;
 const status=!darkMs?'No dark time':scenario==='loading'?'Loading':scenario==='error'?'Couldn’t load forecast':unavailable?'Forecast unavailable':partial?'Partial dark-time coverage':scenario==='stale'?'Stale snapshot':scenario==='offline'?'Offline · cached snapshot':'Full dark-time coverage';
 const exampleAgeHours=scenario==='stale'?18:scenario==='offline'?4:1,snapshotRetrievedAt=fixtureNow-exampleAgeHours*3600000;
 const ageHours=Math.max(0,(referenceNow-snapshotRetrievedAt)/3600000);
 return {hours:rows,ageHours,sampleCount,coveredSamples,cloudSamples:clouds.length,outOfRange:hours.length===0&&!noForecast,cloudMin:clouds.length?Math.min(...clouds):null,cloudMax:clouds.length?Math.max(...clouds):null,darkMs,cloud:clouds.length?Math.round(clouds.reduce((a,b)=>a+b,0)/clouds.length):null,tempMin:temps.length?Math.min(...temps):null,tempMax:temps.length?Math.max(...temps):null,dewMin:dews.length?Math.min(...dews):null,dewMargin:2,dewKnownSamples:spreads.length,dewRiskSamples:spreads.length?spreads.filter(x=>x<=2).length:null,dewSpreadMin:spreads.length?Math.min(...spreads):null,dewSpreadMax:spreads.length?Math.max(...spreads):null,status,partial,unavailable,stale:scenario==='stale',offline:scenario==='offline',leadDays:Math.max(0,Math.round((Date.parse(night.date+'T12:00Z')-Date.parse('2026-10-19T12:00Z'))/dayMs)),retrievedAt:snapshotRetrievedAt};
}

export function weatherSlots(night,summary){
 if(summary.unavailable||!night.dark.length)return [];
 const start=Math.ceil(night.dark[0].start/3600000)*3600000,end=Math.ceil(night.dark.at(-1).end/3600000)*3600000;
 const result=[];
 for(let t=start;t<=end;t+=3600000){
  const source=summary.hours.find(h=>h.start===t);
  const hour=source||{start:t,end:t+3600000,available:false,cloud:null,temp:null,dew:null,wind:null,gust:null,precip:null,visibility:null,humidity:null,low:null,mid:null,high:null};
  const instant=night.dark.some(d=>t>=d.start&&t<=d.end),precedingMinutes=night.dark.reduce((n,d)=>n+Math.max(0,Math.min(t,d.end)-Math.max(t-3600000,d.start)),0)/60000;
  if(instant||precedingMinutes>=30)result.push({...hour,instant,precedingMinutes});
 }
 return result;
}
