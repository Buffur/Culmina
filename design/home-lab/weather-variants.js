import {weatherSlots,instantLabel,timeLabel,hoursLabel,zone} from './night-model.js?v=20261020-hybrid7';
import {weatherDigest,weatherFreshnessLabel,clockRange,escapeHTML as esc} from './night-ui.js?v=20261020-hybrid7';
import {dataIcon} from './icons.js';

// Presentation only: both alternatives consume the same eligible existing hourly slots.
// A row's instant and precedingMinutes flags keep their existing, different meanings.
const metrics=[
 {key:'temp',label:'Temperature',unit:'°C',icon:'thermometer',tone:'temperature',extra:'dew',extraLabel:'Dew point'},
 {key:'humidity',label:'Relative humidity',unit:'%',icon:'droplets',tone:'moisture',percent:true},
 {key:'cloud',label:'Cloud cover',unit:'%',icon:'cloud',tone:'cloud',percent:true},
 {key:'wind',label:'Wind / gusts',unit:'km/h',icon:'wind',tone:'wind',extra:'gust',extraLabel:'Gusts'},
 {key:'precip',label:'Precipitation probability',unit:'%',icon:'cloud-rain',tone:'moisture',percent:true,preceding:true},
];
const number=n=>Number(n.toFixed(1));
const unitValue=(n,unit)=>Number.isFinite(n)?`${number(n)}${unit==='%'?'':' '}${unit}`:'Unknown';
const eligible=(h,key)=>h.available!==false&&(key==='gust'||key==='precip'?h.precedingMinutes>=30:h.instant);
const known=(rows,key)=>rows.filter(h=>eligible(h,key)&&Number.isFinite(h[key]));
function range(rows,key,unit){const values=known(rows,key).map(h=>h[key]);if(!values.length)return 'Unknown';const lo=Math.min(...values),hi=Math.max(...values);return `${number(lo)}${lo===hi?'':'–'+number(hi)}${unit==='%'?'':' '}${unit}`;}
function coverage(rows,key){const count=rows.filter(h=>eligible({...h,available:true},key)).length;return `${known(rows,key).length}/${count} known`;}
function overview(rows,m){return `${range(rows,m.key,m.unit)}${m.extra?` · ${m.extraLabel.toLowerCase()} ${range(rows,m.extra,m.unit)}`:''}`;}
function sample(h,key,unit){return !eligible(h,key)?h.available===false?'Unknown':'Outside dark span':unitValue(h[key],unit);}
function heading(m){return `<span class="wx-metric-name">${dataIcon(m.icon)}<span>${m.label}</span></span>`;}
function selectedMarkup(rows,index){const h=rows[index];if(!h)return '';return `<h3>${esc(instantLabel(h.start))}${h.precedingMinutes>=30&&h.precedingMinutes<60?' *':''}</h3><dl class="wx-selected-facts">${metrics.map(m=>`<div><dt>${m.label}</dt><dd>${sample(h,m.key,m.unit)}${m.extra?`<span>${m.extraLabel}: ${sample(h,m.extra,m.unit)}</span>`:''}</dd></div>`).join('')}<div><dt>Low / middle / high cloud</dt><dd>${['low','mid','high'].map(key=>sample(h,key,'%')).join(' / ')}</dd></div><div><dt>Visibility</dt><dd>${eligible(h,'visibility')?unitValue(Number.isFinite(h.visibility)?h.visibility/1000:null,'km'):'Unknown'}</dd></div></dl>${h.available===false?'<p class="wx-note wx-unknown">No sample at this hour. Missing values are unknown.</p>':''}`;}

function lineMarkup(rows,key,low,high){
 const x=i=>24+i*48,y=value=>64-(value-low)/(high-low||1)*48;
 let path='',previous=-2;
 const dots=[],gaps=[];
 rows.forEach((h,i)=>{if(eligible(h,key)&&Number.isFinite(h[key])){path+=`${previous===i-1?'L':'M'}${x(i)},${y(h[key])} `;previous=i;dots.push(`<circle class="wx-line${key==='dew'||key==='gust'?' wx-secondary-line':''}" cx="${x(i)}" cy="${y(h[key])}" r="2.2"/>`);}else{previous=-2;if(eligible({...h,available:true},key))gaps.push(`<text class="wx-gap" x="${x(i)}" y="43" text-anchor="middle">?</text>`);}});
 return `<path class="wx-line${key==='dew'||key==='gust'?' wx-secondary-line':''}" d="${path}"/>${dots.join('')}${gaps.join('')}`;
}
function chart(rows,m){
 const values=[m.key,m.extra].filter(Boolean).flatMap(key=>known(rows,key).map(h=>h[key]));
 const low=m.percent||m.key==='wind'?0:values.length?Math.floor(Math.min(...values))-1:0;
 const high=m.percent?100:values.length?Math.max(low+1,Math.ceil(Math.max(...values))+(m.key==='temp'?1:0)):1;
 const width=rows.length*48,description=`${m.label}; ${low} to ${high} ${m.unit}. ${m.extra?`${m.key==='wind'?'Wind':'Temperature'} solid; ${m.extraLabel.toLowerCase()} dashed. `:''}Question marks are missing values, disconnected from known samples.`;
 return `<section class="wx-mini-chart wx-tone-${m.tone}"><h3>${heading(m)}</h3><p class="wx-chart-summary">${overview(rows,m)} · ${coverage(rows,m.key)}${m.extra?` · ${m.extraLabel.toLowerCase()} ${coverage(rows,m.extra)}`:''}</p><p class="wx-axis-label">${values.length?`${low}–${high} ${m.unit}${m.extra?` · ${m.extraLabel.toLowerCase()} dashed`:''}`:'No known values'}${m.preceding?' · preceding hour':''}${m.key==='wind'?' · gusts: preceding hour':''}</p><svg viewBox="0 0 ${width} 80" preserveAspectRatio="none" role="img" aria-label="${esc(description)}"><line class="wx-chart-guide" x1="0" x2="${width}" y1="64" y2="64"/>${lineMarkup(rows,m.key,low,high)}${m.extra?lineMarkup(rows,m.extra,low,high):''}</svg></section>`;
}

/** Exactly two alternatives, no element IDs. Scope events to the returned [data-weather-variant].
 * Set metadata=false only when the host already displays the same period and provenance.
 * Selection is caller-owned; updateWeatherSelection changes only the selected-hour presentation.
 */
export function renderWeatherVariant(night,weather,variant='rows',{selectedIndex=0,metadata=true}={}){
 const d=weatherDigest(night,weather),rows=weatherSlots(night,weather),kind=variant==='charts'?'charts':'rows';
 const index=Math.max(0,Math.min(rows.length-1,selectedIndex));
 const meta=metadata?`<p class="wx-note">Demonstration forecast · Open-Meteo-shaped sample · ${zone}<br>${night.dark.length?`Dark ${night.dark.map(x=>clockRange(night,x)).join(', ')} · ${hoursLabel(weather.darkMs)}`:'No dark time'}</p><p class="wx-note">${esc(weather.status)} · ${weather.coveredSamples}/${weather.sampleCount} hourly rows covered${weatherFreshnessLabel(weather)?' · '+weatherFreshnessLabel(weather):''}<br>Retrieved ${esc(instantLabel(weather.retrievedAt))} · ${hoursLabel(weather.ageHours*3600000)} old · lead ${weather.leadDays} day${weather.leadDays===1?'':'s'}</p>`:'';
 if(!rows.length||!d.any)return `<section class="weather-variant" data-weather-variant="${kind}"><h2>Dark-time statistics</h2>${meta}<p class="wx-note wx-unknown">${weather.darkMs?'No eligible hourly data. Values remain unknown.':'No dark-time interval to summarize.'}</p></section>`;
 const rowsView=`<dl class="wx-overview">${metrics.map(m=>`<div class="wx-overview-row wx-tone-${m.tone}"><dt>${heading(m)}</dt><dd>${overview(rows,m)}<span>${coverage(rows,m.key)}${m.extra?` · ${m.extraLabel.toLowerCase()} ${coverage(rows,m.extra)}`:''}${m.preceding?' · preceding hour':''}${m.key==='wind'?' · gusts: preceding hour':''}</span></dd></div>`).join('')}</dl>`;
 const chartsView=`<p class="wx-note">Shared hourly positions; each panel keeps its own physical unit and scale. Scroll sideways for later hours.</p><div class="wx-chart-scroll" tabindex="0" aria-label="Aligned hourly weather panels; scroll horizontally"><div class="wx-chart-grid" style="--wx-hours:${rows.length}"><div class="wx-time-axis">${rows.map((h,i)=>`<button type="button" data-weather-index="${i}" aria-pressed="${i===index}" aria-label="Select ${esc(instantLabel(h.start))}">${timeLabel(h.start)}</button>`).join('')}</div>${metrics.map(m=>chart(rows,m)).join('')}</div></div><p class="wx-note">Solid temperature / dashed dew point; solid wind / dashed gusts. ? = unknown; gaps stay disconnected.</p>`;
 return `<section class="weather-variant" data-weather-variant="${kind}"><h2>Dark-time statistics</h2>${meta}${kind==='charts'?chartsView:rowsView}${d.dewClose?`<p class="wx-note wx-caution">${d.dewClose} of ${d.dewKnown} samples have a dew point within ${d.dewMargin} °C of air. This example caution is not a condensation forecast.</p>`:''}<p class="wx-note">Ranges summarize known dark-time samples. Temperature, humidity, cloud and wind are instantaneous. Gusts and precipitation probability describe the preceding hour; * marks partial dark-time overlap. Probability is %, not rainfall amount.</p><label class="wx-hour-slider">Inspect an hour<input type="range" data-weather-slider min="0" max="${rows.length-1}" value="${index}" step="1" aria-label="Select weather hour" aria-valuetext="${esc(instantLabel(rows[index].start))}"></label><details class="wx-hour-details"><summary>Hourly values <span data-weather-selected-label>${timeLabel(rows[index].start)}</span></summary><div data-weather-selection aria-live="polite">${selectedMarkup(rows,index)}</div></details></section>`;
}

export function updateWeatherSelection(root,night,weather,index){
 if(!root)return;const rows=weatherSlots(night,weather),selected=Math.max(0,Math.min(rows.length-1,index)),h=rows[selected];if(!h)return;
 root.querySelectorAll('[data-weather-index]').forEach(button=>button.setAttribute('aria-pressed',String(Number(button.dataset.weatherIndex)===selected)));
 const slider=root.querySelector('[data-weather-slider]');if(slider){slider.value=selected;slider.setAttribute('aria-valuetext',instantLabel(h.start));}
 const label=root.querySelector('[data-weather-selected-label]');if(label)label.textContent=timeLabel(h.start);
 const detail=root.querySelector('[data-weather-selection]');if(detail)detail.innerHTML=selectedMarkup(rows,selected);
}
