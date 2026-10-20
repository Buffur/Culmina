const {launchChromium,toolchainInfo}=require('../../scripts/browser_toolchain.cjs');
const fs=require('fs'),path=require('path'),assert=require('assert/strict');
const results=[],failures=[],out=__dirname;
(async()=>{
 const browser=await launchChromium({headless:true});
 const context=await browser.newContext({viewport:{width:412,height:915},permissions:[],reducedMotion:'no-preference'});
 const page=await context.newPage();page.setDefaultTimeout(5000);
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 const go=async query=>{await page.goto('http://127.0.0.1:4173/conditions.html?variant=blend&'+query);await page.locator('#conditions-main h2').first().waitFor();await page.evaluate(()=>document.fonts.ready);};
 for(const theme of ['light','dark','field'])for(const scale of ['1','2'])for(const view of ['night','moon','weather']){
  const query=`view=${view}&theme=${theme}&scale=${scale}&scenario=${view==='weather'?'partial':'ready'}`;
  try{
   await go(query);
   const measure=await page.locator('.android-device').evaluate(e=>({width:e.clientWidth,overflow:e.scrollWidth>e.clientWidth+1,inner:[...e.querySelectorAll('.android-scroll,main')].map(n=>({name:n.className,overflow:n.scrollWidth>n.clientWidth+1}))}));
   assert.equal(measure.overflow,false);assert.equal(measure.inner.some(x=>x.overflow),false);
   if(view==='weather'){
    assert.match(await page.locator('.weather-answer h2').innerText(),/known dark hours/);
    assert.match(await page.locator('.headline-coverage').innerText(),/5 of 7/);
    assert.equal(await page.locator('.humidity-plot').count(),1);
    assert.equal(await page.locator('.hour-gap .gap-mark').count(),2);
    const humiditySegments=await page.locator('.humidity-plot polyline,.humidity-plot circle').count();assert.equal(humiditySegments,2);
    assert.equal(await page.locator('.humidity-plot').getAttribute('aria-label'),'Relative humidity; separate scale 0 to 100 percent; same hourly positions; gaps stay disconnected');
   }else{
    if(view==='moon')await page.locator('[data-night-cursor]').scrollIntoViewIfNeeded();
    const slider=page.locator('[data-night-cursor]'),initial=await slider.inputValue();
    await slider.press('ArrowRight');assert.equal(Number(await slider.inputValue()),Number(initial)+5);
    await page.locator('.timeline-reset').click();assert.equal(await slider.inputValue(),initial);
    assert.equal(await page.locator('.key-dark').first().evaluate(e=>getComputedStyle(e,'::after').content),'none');
    const reset=await page.locator('.timeline-reset').boundingBox();assert.ok(reset.height>=48&&reset.width>=48);
   }
   if(scale==='1'){
    await page.locator('.android-scroll').evaluate(e=>e.scrollTop=0);
    await page.locator('.android-device').screenshot({path:path.join(out,`conditions-${view}-${theme}.png`)});
    if(view==='weather'){await page.locator('.hourly-scroll').scrollIntoViewIfNeeded();await page.locator('.android-device').screenshot({path:path.join(out,`humidity-${theme}.png`)});}
   }
   results.push({query,...measure,status:'PASS'});
  }catch(e){failures.push({query,error:e.message});}
 }
 for(const width of [360,412])for(const view of ['night','moon','weather']){
  await page.setViewportSize({width,height:915});
  try{await go(`view=${view}&scale=2&scenario=partial`);const measure=await page.locator('.android-scroll').evaluate(e=>({width:e.clientWidth,scrollWidth:e.scrollWidth}));assert.ok(measure.scrollWidth<=measure.width+1);results.push({width,view,scale:2,...measure,status:'PASS'});}catch(e){failures.push({width,view,error:e.message});}
 }
 await page.setViewportSize({width:412,height:915});
 for(const scenario of ['unknown','missing-variable','error','no-dark','dst']){
  await go(`view=weather&scenario=${scenario}`);
  const text=await page.locator('#conditions-main').innerText();assert.ok(!text.includes('Infinity')&&!text.includes('NaN'));
  if(['unknown','error'].includes(scenario))assert.equal(await page.locator('.hourly-chart').count(),0);
  if(scenario==='unknown')assert.equal(((await page.locator('.weather-answer').innerText()).match(/Forecast unavailable/g)||[]).length,1);
  if(scenario==='missing-variable'){assert.match(text,/Cloud cover unknown/);assert.equal(await page.locator('.humidity-plot').count(),1);assert.equal(await page.locator('.cloud-column>i:not(.gap-mark):not(.outside-mark)').count(),0);}
  if(scenario==='no-dark')assert.match(text,/No dark hours to summarize/);
  results.push({scenario,unknownsPreserved:true,status:'PASS'});
 }
 await go('view=night&scale=2');await page.locator('.android-device').screenshot({path:path.join(out,'conditions-night-200.png')});
 await go('view=moon&scale=2');await page.locator('.android-device').screenshot({path:path.join(out,'conditions-moon-200.png')});
 await go('view=moon');await page.emulateMedia({reducedMotion:'reduce'});
 const motion=await page.locator('.calendar-grid button').first().evaluate(e=>({transition:getComputedStyle(e).transitionDuration,animation:getComputedStyle(e).animationName}));
 assert.equal(motion.transition,'0s');assert.equal(motion.animation,'none');results.push({reducedMotion:motion,status:'PASS'});
 // Non-Hybrid preserves the legacy caption and decorative legend bracket.
 await page.goto('http://127.0.0.1:4173/conditions.html?variant=paper&view=night');
 await page.locator('.night-slider').waitFor();assert.equal(await page.locator('.timeline-hint').count(),0);assert.notEqual(await page.locator('.key-dark').first().evaluate(e=>getComputedStyle(e,'::after').content),'none');
 results.push({variant:'paper',legacyTimeline:true,status:'PASS'});
 fs.writeFileSync(path.join(out,'conditions-check.json'),JSON.stringify({toolchainInfo,results,failures,errors},null,2));
 await browser.close();console.log(JSON.stringify({checks:results.length,failures,errors}));if(failures.length||errors.length)process.exitCode=1;
})().catch(e=>{console.error(e);process.exitCode=1;});
