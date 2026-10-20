// Focused seven-refinement checks; fresh localhost storage only.
const {launchChromium}=require('./browser_toolchain.cjs');
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const out=path.resolve(__dirname,'../evidence/hybrid-seven-2026-10-20');
fs.mkdirSync(out,{recursive:true});
(async()=>{
 const browser=await launchChromium({headless:true});
 const ctx=await browser.newContext({viewport:{width:412,height:915}});
 await ctx.addInitScript(()=>sessionStorage.removeItem('culmina-logbook-context-v1'));
 const page=await ctx.newPage(),evidence={cases:[],errors:[],geometry:[]};
 page.on('pageerror',e=>evidence.errors.push(e.message));
 try {
  for(const theme of ['light','dark','field'])for(const scale of ['1','2']){
   await page.goto(`http://localhost:4173/workspace.html?tab=logbook&variant=blend&theme=${theme}&scale=${scale}`);
   await page.locator('[data-filters] summary').click();
   await page.locator('[data-clear-filters]').click();
   const note=page.locator('#workspace-announcement');
   await note.waitFor({state:'visible'});
   assert.equal(await note.innerText(),'Filters cleared.');
   const geometry=await page.evaluate(()=>{
    const get=s=>{const r=document.querySelector(s).getBoundingClientRect();return {top:r.top,bottom:r.bottom,left:r.left,right:r.right};};
    const n=document.querySelector('#workspace-announcement');
    return {scroll:get('.android-scroll'),note:get('#workspace-announcement'),nav:get('#workspace-nav'),phone:get('.android-device'),position:getComputedStyle(n).position,overflow:n.scrollWidth>n.clientWidth+1};
   });
   assert.equal(geometry.position,'static');assert.equal(geometry.overflow,false);
   assert.ok(geometry.scroll.bottom<=geometry.note.top+1);
   assert.ok(geometry.note.bottom<=geometry.nav.top+1);
   assert.ok(geometry.note.bottom<geometry.phone.bottom);
   evidence.geometry.push({theme,scale,...geometry});
   if(scale==='2')await page.locator('.android-device').screenshot({path:path.join(out,`feedback-${theme}-200.png`)});
   await page.locator('[data-open-progress]').click();
   assert.equal(await note.isVisible(),false);
   if(theme==='light'&&scale==='2'){
    await page.locator('.logbook-progress-guide summary').click();
    assert.match(await page.locator('.logbook-progress-guide').innerText(),/exposure, sensitivity, binning and rig all match/);
    await page.locator('.logbook-progress-guide').screenshot({path:path.join(out,'progress-guide-confirm.png')});
   }
   evidence.cases.push(`Feedback ${theme}/${scale}: in-flow, no content/nav overlap, clears on destination change`);
  }
  await page.goto('http://localhost:4173/workspace.html?tab=logbook&variant=blend&scale=2');
  await page.locator('[data-open-entry="example-m31-2026-10-12"]').click();
  await page.locator('.logbook-export summary').click();
  const download=page.waitForEvent('download');
  await page.locator('[data-export-format=text]').click();await download;
  assert.match(await page.locator('#workspace-announcement').innerText(),/download requested.*unchanged/);
  const longGeometry=await page.evaluate(()=>{
   const n=document.querySelector('#workspace-announcement'),r=n.getBoundingClientRect();
   return {top:r.top,bottom:r.bottom,scrollBottom:document.querySelector('.android-scroll').getBoundingClientRect().bottom,
    gestureTop:document.querySelector('.android-gesture').getBoundingClientRect().top,overflow:n.scrollWidth>n.clientWidth+1};
  });
  assert.ok(longGeometry.scrollBottom<=longGeometry.top+1);
  assert.ok(longGeometry.bottom<=longGeometry.gestureTop+1);assert.equal(longGeometry.overflow,false);
  evidence.geometry.push({longMessage:longGeometry});
  await page.locator('.android-device').screenshot({path:path.join(out,'feedback-download-200.png')});
  evidence.cases.push('Real download confirmation at200% wraps in own row without covering record/actions');
  await page.goto('http://localhost:4173/workspace.html?tab=logbook&variant=paper');
  await page.locator('[data-filters] summary').click();await page.locator('[data-clear-filters]').click();
  assert.equal(await page.locator('#workspace-announcement').evaluate(e=>getComputedStyle(e).position),'absolute');
  evidence.cases.push('Non-Hybrid Paper retains original floating feedback');
  await ctx.close();
  const home=await browser.newContext({viewport:{width:1280,height:1040}}),hp=await home.newPage();
  hp.on('pageerror',e=>evidence.errors.push(e.message));
  for(const scale of ['1','2']){
   await hp.goto(`http://localhost:4173/index.html?variant=blend&view=wide&scale=${scale}#concepts`);
   const date=hp.locator('[data-variant=blend] [data-action=date]');
   assert.match(await date.innerText(),/Night of/);
   await date.click();
   assert.match(await hp.locator('#date-form').innerText(),/Night of[\s\S]*Ends/);
   const fonts=await hp.locator('#detail-body').evaluate(e=>Object.fromEntries(
    ['p','label','select','.primary-button','.secondary-button'].map(s=>[s,parseFloat(getComputedStyle(e.querySelector(s)).fontSize)])));
   for(const size of Object.values(fonts))assert.equal(size,14*Number(scale));
   evidence.geometry.push({pickerFonts:{scale,...fonts}});
   await hp.locator('#date-form select').selectOption('2026-10-31');
   assert.equal(await hp.locator('#home-night-ends').innerText(),'Ends 1 Nov');
   assert.equal(await hp.locator('#detail').evaluate(e=>e.scrollWidth>e.clientWidth+1),false);
   await hp.locator('#detail').screenshot({path:path.join(out,`home-date-confirm-${scale}.png`)});
   await hp.locator('#detail [data-action=cancel]').click();
   assert.equal(await hp.evaluate(()=>localStorage.getItem('culmina-plan-navigation-v1')),null);
  }
  await hp.goto('http://localhost:4173/index.html?variant=blend&view=wide#concepts');
  const weather=hp.locator('[data-variant=blend] .weather-row');
  assert.equal(await weather.count(),1);assert.equal(await weather.locator('.wx-chips').count(),0);
  assert.doesNotMatch(await weather.innerText(),/Dew point|Rain chance|Hour by hour/);
  await weather.screenshot({path:path.join(out,'home-weather-compact-confirm.png')});
  evidence.cases.push('Home Weather remains one compact widget; no expanded metrics, hourly table or chips');
  await hp.goto('http://localhost:4173/index.html?variant=paper&family=all&view=wide#concepts');
  assert.doesNotMatch(await hp.locator('[data-variant=paper] [data-action=date]').innerText(),/Night of/);
  evidence.cases.push('Hybrid Home/date100/200 labels and Cancel no writes; Paper date unchanged');
  await home.close();assert.deepEqual(evidence.errors,[]);
 }finally{fs.writeFileSync(path.join(out,'feedback-home-checks.json'),JSON.stringify(evidence,null,2));await browser.close();}
 console.log(JSON.stringify(evidence,null,2));
})().catch(e=>{console.error(e);process.exitCode=1;});
