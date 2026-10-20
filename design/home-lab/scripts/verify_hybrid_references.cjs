// Read-only source verification; UI changes occur only in fresh browser contexts.
const {launchChromium}=require('./browser_toolchain.cjs');
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),out=path.join(root,'evidence/hybrid-reference-verification-2026-10-20');
fs.mkdirSync(path.join(out,'current'),{recursive:true});
const hashes=()=>Object.fromEntries(fs.readdirSync(root).filter(x=>/\.(js|css|html|json)$/.test(x)).map(x=>[x,crypto.createHash('sha256').update(fs.readFileSync(path.join(root,x))).digest('hex')]));
const report={sourceBefore:hashes(),captures:[],errors:[],measurements:[]};
const geometry=e=>{const b=e.getBoundingClientRect(),s=getComputedStyle(e);return {text:e.innerText,width:b.width,height:b.height,font:s.fontSize,padding:[s.paddingTop,s.paddingRight,s.paddingBottom,s.paddingLeft],borderTop:s.borderTopWidth,borderBottom:s.borderBottomWidth};};
(async()=>{const b=await launchChromium({headless:true});
try{for(const theme of ['dark','light','field'])for(const scale of ['1','2']){
 const ctx=await b.newContext({viewport:{width:412,height:1050}}),p=await ctx.newPage();p.on('pageerror',e=>report.errors.push(e.message));
 const go=async route=>{await p.goto(`http://127.0.0.1:4173/${route}${route.includes('?')?'&':'?'}variant=blend&theme=${theme}&scale=${scale}`);await p.evaluate(()=>document.fonts.ready);};
 const snap=async(id,loc)=>{await loc.scrollIntoViewIfNeeded();const file=`current/${String(id).padStart(2,'0')}-${theme}-${scale}.png`;await loc.screenshot({path:path.join(out,file)});report.captures.push({reference:id,theme,scale,file,url:p.url(),geometry:await loc.evaluate(geometry)});};
 await go('plan.html');await p.locator('.plan-rows').waitFor();
 await snap(2,p.locator('.capture-actions'));await snap(5,p.locator('.plan-rows'));await snap(6,p.locator('.capture-section'));
 report.measurements.push({theme,scale,buttons:await p.locator('.capture-actions button').evaluateAll(es=>es.map(e=>{const r=e.getBoundingClientRect(),s=getComputedStyle(e);return {text:e.textContent,width:r.width,height:r.height,font:s.fontSize,padding:s.padding,flex:s.flex,widthRule:s.width};})),contextIcons:await p.locator('.plan-row .rig-icon').count(),captureDividers:await p.locator('.capture-block,.capture-actions').evaluateAll(es=>es.map(e=>({class:e.className,borderTop:getComputedStyle(e).borderTopWidth,font:getComputedStyle(e).fontSize}))),mathFont:await p.locator('.block-math').evaluate(e=>getComputedStyle(e).fontSize)});
 await p.locator('[data-disclosure=gain]>summary').click();await snap(1,p.locator('.gain-panel').first());
 report.measurements.at(-1).gain={halfPoint:await p.locator('.gain-point-half').count(),legendItems:await p.locator('.gain-legend li').count(),groupLabels:await p.locator('.gain-panel figcaption').allTextContents()};
 await p.locator('[data-edit-block]').first().click();await p.locator('input[name=focus][value=MF]').check();
 const focusGroup=p.locator('fieldset').filter({has:p.locator('input[name=focus]')});await snap(9,focusGroup);
 report.measurements.at(-1).focus={hint:await p.getByText('Manual focus is a record only.',{exact:false}).innerText(),ranges:await p.locator('#block-screen input[type=range]').count()};
 await go('index.html?view=wide');await p.locator('.variant-blend .night-slider').waitFor();
 await p.locator('.variant-blend [data-night-cursor]').evaluate(e=>{e.value='510';e.dispatchEvent(new Event('input',{bubbles:true}));});
 await snap(3,p.locator('.variant-blend .night-slider'));await snap(4,p.locator('.home-actions'));
 report.measurements.at(-1).timeline={legendAfter:await p.locator('.variant-blend .key-dark').evaluate(e=>getComputedStyle(e,'::after').content),reset:await p.locator('.variant-blend .timeline-reset').innerText(),hint:await p.locator('.variant-blend .timeline-hint').innerText()};
 await go('conditions.html?view=weather');await p.locator('.hourly-chart').waitFor();await snap(7,p.locator('.hourly-chart'));
 report.measurements.at(-1).weather={humidityPlots:await p.locator('.humidity-plot').count(),captions:await p.locator('.plot-caption').allTextContents(),legend:await p.locator('.weather-legend').innerText(),homeWeather:'Compact widget retained'};
 await go('conditions.html?view=moon');await p.locator('.moon-answer').waitFor();await snap(8,p.locator('.moon-answer'));
 report.measurements.at(-1).moon={heading:await p.locator('.moon-answer h2').innerText(),value:await p.locator('.moon-answer-value').innerText(),overflow:await p.locator('.android-scroll').evaluate(e=>e.scrollWidth>e.clientWidth+1)};
 await ctx.close();
}
}finally{report.sourceAfter=hashes();report.sourceUnchanged=JSON.stringify(report.sourceBefore)===JSON.stringify(report.sourceAfter);fs.writeFileSync(path.join(out,'checks.json'),JSON.stringify(report,null,2));await b.close();console.log(JSON.stringify({captures:report.captures.length,errors:report.errors,sourceUnchanged:report.sourceUnchanged}));}
})();
