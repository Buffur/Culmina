import {cursorFacts,timeLabel,instantLabel,nightLabel,nextDate,hoursLabel,totalTime,resetCursor,weatherSlots,intersect,zone} from './night-model.js?v=20261020-hybrid7';
export const escapeHTML=value=>String(value??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
// Evening-date wording for Hybrid callers. This labels calendar dates only;
// the fixed UTC night span and all local-time/DST calculations remain in the model.
export function nightDateLabels(date){
 const format=value=>new Intl.DateTimeFormat('en-GB',{day:'numeric',month:'short',timeZone:'UTC'}).format(Date.parse(value+'T12:00:00Z'));
 return {night:`Night of ${format(date)}`,ends:`Ends ${format(nextDate(date))}`};
}
export const symbols={back:'M20 12H4m7-7-7 7 7 7',next:'m9 5 7 7-7 7',previous:'m15 5-7 7 7 7',moon:'M20 15a8 8 0 0 1-11-11 8 8 0 1 0 11 11Z',sun:'M12 3V1m0 22v-2M3 12H1m22 0h-2M5.6 5.6 4.2 4.2m15.6 15.6-1.4-1.4m-12.8 0-1.4 1.4M19.8 4.2l-1.4 1.4M16 12a4 4 0 1 1-8 0 4 4 0 0 1 8 0',close:'m6 6 12 12M18 6 6 18',more:'M12 5h.01M12 12h.01M12 19h.01',check:'m5 12 4 4L19 6',plus:'M12 5v14M5 12h14',arrow:'M5 12h14m-6-6 6 6-6 6'};
export const svgIcon=name=>`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="${symbols[name]||symbols.arrow}"/></svg>`;

const span=(night,x)=>{const hit=intersect(x,{start:night.start,end:night.end});return hit?{left:(hit.start-night.start)/(night.end-night.start)*100,width:(hit.end-hit.start)/(night.end-night.start)*100}:null;};
const f3=n=>Number(n.toFixed(3));
const bars=(night,intervals,cls)=>intervals.map(x=>span(night,x)).filter(Boolean).map(p=>`<span class="${cls}" style="left:${f3(p.left)}%;width:${f3(p.width)}%"></span>`).join('');

// Local calendar date of an instant in the site zone, to tag times that fall after the evening date.
const dateFormat=new Intl.DateTimeFormat('en-CA',{timeZone:zone,year:'numeric',month:'2-digit',day:'2-digit'});
export const dayTag=(night,t)=>{const d=dateFormat.format(t);return d>night.date?' (+1)':d<night.date?' (−1)':'';};
export const clockRange=(night,x)=>`${timeLabel(x.start)}${dayTag(night,x.start)} → ${timeLabel(x.end)}${dayTag(night,x.end)}`;

const skyClass={Daylight:'day','Civil twilight':'civil','Nautical twilight':'nautical','Astronomical twilight':'astro',Dark:'dark'};
// Colours interpolate across the twilight span, rather than making each class a stripe.
// Knots are presentation only. The dark bracket and cursor still use exact model intervals.
export function skyGradient(night){
 const segments=night.skySegments.map(s=>({...s,start:Math.max(night.start,s.start),end:Math.min(night.end,s.end)})).filter(s=>s.end>s.start);
 const at=t=>f3((t-night.start)/(night.end-night.start)*100);
 const knots=[];
 const push=(t,c)=>{if(knots.at(-1)?.t===t)knots[knots.length-1]={t,c};else knots.push({t,c});};
 for(const [i,s] of segments.entries()){
  const c=`var(--sky-${skyClass[s.sky]||'day'})`;
  if(i===0)push(s.start,c);
  if(s.sky==='Dark'){push(s.start,c);push(s.end,c);}
  else push((s.start+s.end)/2,c);
  if(i===segments.length-1)push(s.end,c);
 }
 const stops=[];
 for(let i=0;i<knots.length;i++){
  const k=knots[i],next=knots[i+1];stops.push(`${k.c} ${at(k.t)}%`);
  if(next&&next.c!==k.c)for(let j=1;j<8;j++){
   const x=j/8,eased=x*x*(3-2*x),weight=f3(eased*100);
   stops.push(`color-mix(in oklab,${k.c} ${100-weight}%,${next.c} ${weight}%) ${at(k.t+(next.t-k.t)*x)}%`);
  }
 }
 if(!stops.length)return 'linear-gradient(90deg,var(--sky-day),var(--sky-day))';
 return `linear-gradient(90deg,${stops.join(',')})`;
}
const present=(night,name)=>night.skySegments.some(x=>x.sky===name&&Math.min(x.end,night.end)>Math.max(x.start,night.start));
const key=(cls,label)=>`<span><i class="key key-${cls}"></i>${label}</span>`;
function legend(night,compact){
 const sky=compact?[present(night,'Daylight')&&key('day','Daylight'),['Civil twilight','Nautical twilight','Astronomical twilight'].some(n=>present(night,n))&&key('twilight','Twilight')]:[['Daylight','day'],['Civil twilight','civil'],['Nautical twilight','nautical'],['Astronomical twilight','astro']].map(([n,c])=>present(night,n)&&key(c,n));
 const times=night.dark.map(x=>`${timeLabel(x.start)}–${timeLabel(x.end)}`).join(', ');
 const dark=night.dark.length?key('dark',compact?`Dark ${times}`:`Dark · Sun below −18° · ${times}`):`<span>No dark time: the Sun stays above −18°</span>`;
 return `<div class="rail-legend"><div class="legend-group">${[...sky,dark].filter(Boolean).join('')}</div><div class="legend-group">${key('up','Moon above horizon')}${key('free','Moon-free dark')}</div>${compact?'':'<p class="rail-note">Sky colour blends between known Sun-event times. It is not measured sky brightness.</p>'}</div>`;
}
// The full reading key is shared with compact condition browsers without duplicating the rail.
export const timelineReadingGuide=night=>legend(night,false);
// Owner 2026-10-22: the hybrid browser jumps to the start or end of dark time (the rail itself spans
// noon to noon, so its own start is daylight). Without dark time it jumps to the rail's ends.
// Cursor values stay on the five-minute grid the range input uses.
export function jumpCursor(night,to){
 const last=night.end-300000,grid=t=>night.start+Math.floor((Math.min(last,Math.max(night.start,t))-night.start)/300000)*300000;
 const dark=night.dark.length;
 const instant=to==='end'?grid(dark?night.dark.at(-1).end:last):grid(dark?night.dark[0].start:night.start);
 const what=dark?(to==='end'?'end of dark time':'start of dark time'):(to==='end'?'end of the timeline':'start of the timeline');
 return {instant,label:`Go to ${what}, ${timeLabel(instant)}`};
}
const jumpIcon=to=>`<svg viewBox="0 0 24 24" aria-hidden="true"><path d="${to==='end'?'M18 5v14M7 6l6 6-6 6':'M6 5v14M17 6l-6 6 6 6'}"/></svg>`;
export function timeline(night,instant,id='night',compact=false,hybrid=false){
 const grid=night.start+Math.floor((Math.min(night.end-300000,Math.max(night.start,instant))-night.start)/300000)*300000;
 const f=cursorFacts(night,grid),max=Math.round((night.end-night.start)/60000)-5,value=Math.round((f.instant-night.start)/60000);
 const reset=resetCursor(night),label=`${night.classification}; ${hoursLabel(totalTime(night.dark))} dark, ${hoursLabel(totalTime(night.moonFree))} moon-free dark`;
 const resetLabel=hybrid?(reset.label==='Now'?'Return to now':'Return to night start'):reset.label;
 const hintId=`cursor-hint-${id}`;
 return `<section class="night-slider ${compact?'compact':''}" data-timeline="${escapeHTML(id)}" data-night="${night.date}" aria-label="Darkness and Moon time browser"><div class="slider-caption"><label for="cursor-${escapeHTML(id)}">${hybrid?'Preview time':compact?'Time':'Preview time'}</label><time data-cursor-time>${instantLabel(f.instant)}</time>${hybrid?`<span class="timeline-jumps">${['start','end'].map(to=>{const j=jumpCursor(night,to);return `<button type="button" class="timeline-jump" data-action="cursor-${to}" aria-label="${escapeHTML(j.label)}" title="${escapeHTML(j.label)}" aria-describedby="${escapeHTML(hintId)}">${jumpIcon(to)}</button>`;}).join('')}</span>`:compact?`<button type="button" class="timeline-reset" data-action="reset-cursor" aria-label="Reset preview to ${reset.label}">${resetLabel}</button>`:''}</div><div class="rail-stack"><div class="rail-visual" role="img" aria-label="${escapeHTML(label)}"><span class="sky-track" style="background:${skyGradient(night)}"></span>${hybrid?'':`<span class="dark-lane">${bars(night,night.dark,'dark-bracket')}</span>`}<span class="moon-lane lane-up">${bars(night,night.moonUp,'moon-bar')}</span><span class="moon-lane lane-free">${bars(night,night.moonFree,'moon-bar')}</span></div><input id="cursor-${escapeHTML(id)}" data-night-cursor ${hybrid?`aria-describedby="${escapeHTML(hintId)}"`:""} style="--range-fraction:${max/((night.end-night.start)/60000)}" type="range" min="0" max="${max}" step="5" value="${value}" aria-label="Preview time in ${escapeHTML(nightLabel(night.date))}" aria-valuetext="${escapeHTML(instantLabel(f.instant)+'. '+f.state+'. '+f.detail)}"></div><div class="rail-labels"><span>${timeLabel(night.start,true)}</span><span>${timeLabel(night.end,true)}</span></div>${hybrid?`<p class="timeline-hint" id="${escapeHTML(hintId)}">Drag to preview · arrow keys step 5 min.</p>`:""}${legend(night,compact)}<output for="cursor-${escapeHTML(id)}" class="cursor-output" aria-live="polite"><strong data-cursor-state>${f.state}</strong><span data-cursor-detail>${escapeHTML(compact?f.compactDetail:f.detail)}</span></output></section>`;
}
export function updateTimeline(element,night,minutes){const f=cursorFacts(night,night.start+Number(minutes)*60000);element.querySelector('[data-cursor-time]').textContent=instantLabel(f.instant);element.querySelector('[data-cursor-state]').textContent=f.state;element.querySelector('[data-cursor-detail]').textContent=element.classList.contains('compact')?f.compactDetail:f.detail;element.querySelector('[data-night-cursor]').setAttribute('aria-valuetext',instantLabel(f.instant)+'. '+f.state+'. '+f.detail);return f;}
export function intervalRows(intervals,empty='None in the dark interval'){return intervals.length?intervals.map(x=>`<p class="interval-row"><span>${timeLabel(x.start)}–${timeLabel(x.end)}</span><span>${hoursLabel(x.end-x.start)}</span></p>`).join(''):`<p class="quiet-copy">${empty}</p>`;}

// Moon facts. A Moon interval is shown as labelled From / Until lines rather than one arrow string:
// each endpoint is an unbreakable unit, so a long local date + offset can never split mid-value or
// sit ragged against its label. Windows clipped by the SessionNight edges say so.
export function moonUpRanges(night){
 const ups=night.moonUp.map(x=>intersect(x,{start:night.start,end:night.end})).filter(Boolean);
 if(!ups.length)return 'Not during this night';
 if(ups.length===1&&ups[0].start<=night.start&&ups[0].end>=night.end)return 'All night';
 return ups.map(x=>`<span class="range-pair"><span class="range-label">From</span><span class="range-value">${x.start<=night.start?'Up at window start':instantLabel(x.start)}</span><span class="range-label">Until</span><span class="range-value">${x.end>=night.end?'Still up at window end':instantLabel(x.end)}</span></span>`).join('');
}
export function moonFreeSummary(night){
 if(!night.dark.length)return '<span class="big-value">No dark time</span><span class="fact-sub">So there is no moon-free dark interval.</span>';
 if(!night.moonFree.length)return '<span class="big-value">None</span><span class="fact-sub">The Moon is above the horizon throughout dark time.</span>';
 return `<span class="big-value">${hoursLabel(totalTime(night.moonFree))}</span>${night.moonFree.map(x=>`<span class="clock-range">${clockRange(night,x)}${night.moonFree.length>1?`<span class="range-duration"> · ${hoursLabel(x.end-x.start)}</span>`:''}</span>`).join('')}<span class="fact-sub">${night.classification}</span>`;
}
export function moonFacts(night,fact){return `<dl class="condition-facts moon-facts">${fact('Moon above horizon',moonUpRanges(night),'fact-key fact-wide')}${fact('Moon-free dark',moonFreeSummary(night),'fact-key fact-wide')}</dl>`;}

// Dark-period weather aggregates built only from rows the project's rules make eligible:
// instantaneous variables inside the dark span; gust and precipitation need >=30 min of preceding-hour
// overlap. A missing value stays null: it is never counted as 0 or as clear.
export function weatherDigest(night,summary){
 const rows=weatherSlots(night,summary),have=h=>h.available!==false;
 const now=rows.filter(h=>h.instant&&have(h)),before=rows.filter(h=>h.precedingMinutes>=30&&have(h));
 const list=(source,k)=>source.map(h=>h[k]).filter(Number.isFinite);
 const lo=a=>a.length?Math.min(...a):null,hi=a=>a.length?Math.max(...a):null;
 const clouds=now.filter(h=>Number.isFinite(h.cloud));
 const spreads=now.filter(h=>Number.isFinite(h.temp)&&Number.isFinite(h.dew)).map(h=>({h,s:h.temp-h.dew}));
 const pick=(a,better)=>a.reduce((best,h)=>best===null||better(h.cloud,best.cloud)?h:best,null);
 return {rows,any:now.length>0||before.length>0,clearest:pick(clouds,(a,b)=>a<b),cloudiest:clouds.length>1?pick(clouds,(a,b)=>a>b):null,tempMin:lo(list(now,'temp')),tempMax:hi(list(now,'temp')),dewMin:lo(list(now,'dew')),dewMax:hi(list(now,'dew')),windMax:hi(list(now,'wind')),gustMax:hi(list(before,'gust')),precipMax:hi(list(before,'precip')),dewKnown:spreads.length,dewClose:spreads.filter(x=>x.s<=summary.dewMargin).length,dewMargin:summary.dewMargin,isDewClose:h=>Number.isFinite(h.temp)&&Number.isFinite(h.dew)&&h.temp-h.dew<=summary.dewMargin};
}

// Home stays a widget: one factual headline and one provenance/status line.
// Coverage, cloud extrema, precipitation and dew analysis belong on Weather.
// WeatherFreshness (native night_weather.dart, ADR-012): presentation of age,
// independent of sample coverage. No forecast values or science are changed.
export function weatherFreshnessLabel(summary){return summary.stale||summary.ageHours>=12?'Stale snapshot':summary.ageHours>=3?'Aging snapshot':'';}
export function weatherWidgetSummary(night,summary){
 const d=weatherDigest(night,summary),num=x=>Number(x.toFixed(1));
 if(!summary.darkMs)return {headline:'No dark-time forecast',detail:'Example night · open Weather'};
 if(summary.unavailable)return {headline:summary.status==='Loading'?'Loading forecast':'Forecast unavailable',detail:'Example forecast · open Weather'};
 if(!d.any)return {headline:summary.status==='Loading'?'Loading forecast':'Forecast unavailable',detail:'Example forecast · open Weather'};
 const pieces=[];
 if(d.tempMin!==null)pieces.push(`${num(d.tempMin)}${num(d.tempMin)===num(d.tempMax)?'':'–'+num(d.tempMax)} °C`);
 if(d.windMax!==null)pieces.push(`wind up to ${num(d.windMax)} km/h`);
 const freshness=weatherFreshnessLabel(summary),status=[/offline|partial|gap/i.test(summary.status)?summary.status:'',freshness].filter(Boolean).join(' · ');
 return {headline:pieces.length?pieces.join(' · '):'Measurements incomplete',detail:`Example forecast for the dark hours${/offline|stale|aging|partial|gap/i.test(status)?' · '+status:''}`};
}
