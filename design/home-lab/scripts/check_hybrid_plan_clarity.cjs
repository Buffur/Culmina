// Focused browser regression: presentation provenance never changes saved budgets.
// Fresh localhost context only; no owner profile/storage is read.
const {launchChromium}=require('./browser_toolchain.cjs');
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const out=path.resolve(process.env.CULMINA_EVIDENCE||path.join(__dirname,'../evidence/hybrid-seven-2026-10-20/plan-clarity'));
fs.mkdirSync(out,{recursive:true});
(async()=>{
  const browser=await launchChromium({headless:true});
  const context=await browser.newContext({viewport:{width:412,height:915}}),page=await context.newPage();
  const result={cases:[],pageErrors:[]},base=process.env.CULMINA_BASE||'http://localhost:4173/';
  page.on('pageerror',e=>result.pageErrors.push(e.message));
  const ready=()=>page.locator('#plan-main .plan-identity').waitFor();
  const go=async(query='variant=blend')=>{await page.goto(base+'plan.html?'+query);await ready();};
  const saved=()=>page.evaluate(()=>localStorage.getItem('culmina-plan-preview-v1'));
  const capture=async(name)=>{await page.locator('.android-scroll').evaluate(e=>e.scrollTop=0);await page.locator('.android-device').screenshot({path:path.join(out,name+'.png')});};
  const seed=async({preferences=true,override=false,fileSize=30000000,query='variant=blend'}={})=>{
    await page.goto(base+'tokens.json');
    await page.evaluate(async({preferences,override,fileSize})=>{
      localStorage.clear();
      const model=await import('./plan-model.js'),bridge=await import('./preview-bridge.js'),night=await import('./night-model.js');
      const p=model.defaultPlan(),prefs={perFrameOverheadSeconds:7.5,setupMinutes:15,feasibilityMarginPercent:15};
      p.budgetSnapshot={...model.assumptionsFor(p,preferences?bridge.planningBudget(p,prefs,night.totalTime(night.fixtureNight(p.night).targetWindows)/1000):null),bytesPerFrame:fileSize};
      if(override)p.assumptions={...p.budgetSnapshot,fitMargin:900};
      model.savePlanRecord(localStorage,p);
      if(preferences)localStorage.setItem(bridge.settingsKey,JSON.stringify({kind:'culmina-settings-preview',version:1,settings:{planning:prefs}}));
    },{preferences,override,fileSize});
    await go(query);
  };
  const openAssumptions=async()=>{
    const disclosure=page.locator('[data-disclosure=budget]');
    if(!await disclosure.evaluate(e=>e.open))await disclosure.locator('summary').click();
    await page.locator('[data-edit-assumptions]').click();
  };
  try{
    await go();await seed();
    assert.equal(await page.locator('#plan-budget-change').count(),0);
    assert.match(await page.locator('.plan-identity').innerText(),/Night of 19 Oct · Ends 20 Oct/);
    const initial=await saved();
    await page.evaluate(()=>{
      const key='culmina-settings-preview-v1',p=JSON.parse(localStorage.getItem(key));
      p.settings.planning.perFrameOverheadSeconds=60;localStorage.setItem(key,JSON.stringify(p));
      localStorage.removeItem('culmina-plan-navigation-v1');
    });
    await go();
    assert.match(await page.locator('#plan-budget-change').innerText(),/Settings defaults differ from the saved budget/);
    assert.match(await page.locator('.plan-state').innerText(),/Saved · changed/);
    assert.equal(await saved(),initial);
    await capture('settings-budget-change');
    await page.locator('#plan-scale').selectOption('2');await capture('settings-budget-change-200');
    assert.equal(await page.locator('.android-device').evaluate(e=>e.scrollWidth>e.clientWidth+1),false);
    await page.locator('#plan-scale').selectOption('1');
    await page.locator('[data-disclosure=budget] summary').click();
    assert.match(await page.locator('[data-disclosure=budget]').innerText(),/15% → 38 min/);
    await page.locator('[data-disclosure=budget]').screenshot({path:path.join(out,'global-margin-summary.png')});
    await openAssumptions();
    assert.equal(await page.locator('#note-perFrameOverhead').innerText(),'Current: Global default');
    assert.equal(await page.locator('#note-bytesPerFrame').innerText(),'Current: Saved budget');
    await capture('assumption-sources');
    await page.locator('#asm-perFrameOverhead').fill('10');
    for(const key of ['perFrameOverhead','outsideSetup','fitMargin','bytesPerFrame'])assert.equal(await page.locator('#note-'+key).innerText(),'Plan override on Apply');
    await page.locator('[data-apply-screen]').click();
    assert.equal(await saved(),initial);
    assert.equal(await page.locator('#plan-budget-change').count(),0);
    assert.match(await page.locator('[data-disclosure=budget]').innerText(),/Fixed · 38 min/);
    await openAssumptions();assert.equal(await page.locator('#note-fitMargin').innerText(),'Current: Plan override');
    result.cases.push('Settings changes explain persistence separately from fit; canonical bytes untouched; effective and pending override sources accurate');

    await seed({fileSize:40000000,override:true});
    await openAssumptions();
    await page.locator('[data-reset-assumptions]').click();
    assert.equal(await page.locator('#note-perFrameOverhead').innerText(),'Global default on Apply');
    assert.equal(await page.locator('#note-bytesPerFrame').innerText(),'Saved budget on Apply');
    assert.equal(await page.locator('#asm-bytesPerFrame').inputValue(),'40');
    assert.match(await page.locator('.screen-intro').innerText(),/Apply removes plan overrides/);
    const beforeReset=await saved();
    await page.locator('[data-apply-screen]').click();assert.equal(await saved(),beforeReset);
    assert.match(await page.locator('[data-disclosure=budget]').innerText(),/40 MB per frame/);
    result.cases.push('Reset preview accurately retains saved file-size fallback and only changes the draft on Apply');

    await seed({query:'variant=blend&night=2026-10-20'});
    assert.equal(await page.locator('#plan-budget-change').count(),0);
    assert.match(await page.locator('.plan-state').innerText(),/changed/);
    await page.locator('[data-open=context]').click();
    assert.match(await page.locator('#ctx-night option:checked').innerText(),/^Night of 20 Oct$/);
    assert.match(await page.locator('#hint-night').innerText(),/Ends 21 Oct/);
    result.cases.push('A night-only edit is not falsely attributed to Settings; date chooser names evening and following morning');

    await seed({override:true});
    await page.evaluate(()=>{
      const key='culmina-settings-preview-v1',p=JSON.parse(localStorage.getItem(key));
      p.settings.planning.perFrameOverheadSeconds=60;localStorage.setItem(key,JSON.stringify(p));
      localStorage.removeItem('culmina-plan-navigation-v1');
    });
    await go();assert.equal(await page.locator('#plan-budget-change').count(),0);
    await page.locator('[data-disclosure=budget] summary').click();
    assert.match(await page.locator('[data-disclosure=budget]').innerText(),/Fixed · 15 min/);
    await page.locator('[data-disclosure=budget]').screenshot({path:path.join(out,'fixed-margin-summary.png')});
    result.cases.push('Explicit overrides shield the saved plan from unrelated global changes and retain fixed-minute margin');

    await page.evaluate(()=>{
      const key='culmina-plan-preview-v1',p=JSON.parse(localStorage.getItem(key)),active=p.active||p;
      active.site='library:unknown-window';active.siteSnapshot={id:'unknown-window',name:'Custom site',zone:'Europe/Kyiv',latDeg:50.4,lonDeg:30.6};
      localStorage.setItem(key,JSON.stringify(p));localStorage.removeItem('culmina-plan-navigation-v1');
    });
    await go();await page.locator('[data-disclosure=budget] summary').click();
    assert.match(await page.locator('[data-disclosure=budget]').innerText(),/Fixed · 15 min. Fit unknown until an imaging window is calculated/);
    await page.locator('[data-disclosure=budget]').screenshot({path:path.join(out,'fixed-unknown-confirm.png')});
    assert.match(await page.locator('.plan-answer').innerText(),/Imaging window unknown/);
    result.cases.push('Known fixed margin remains visible while custom-coordinate fit/window remains Unknown');
    await seed({preferences:false});
    await page.evaluate(()=>{const k='culmina-plan-preview-v1',p=JSON.parse(localStorage.getItem(k));delete p.active.budgetSnapshot;localStorage.setItem(k,JSON.stringify(p));localStorage.removeItem('culmina-plan-navigation-v1');});
    await go();await openAssumptions();
    assert.equal(await page.locator('#note-bytesPerFrame').innerText(),'Current: Example default');
    await page.locator('#note-bytesPerFrame').scrollIntoViewIfNeeded();
    await page.locator('.android-device').screenshot({path:path.join(out,'example-fourth-field-confirm.png')});
    result.cases.push('Legacy plan without saved budget or global settings labels all fields Example default');

    await seed({preferences:false,query:'variant=paper'});
    assert.equal(await page.locator('#plan-budget-change').count(),0);
    assert.match(await page.locator('.plan-identity').innerText(),/19 Oct–20/);
    await openAssumptions();
    assert.equal(await page.locator('#note-perFrameOverhead').count(),0);
    assert.match(await page.locator('.screen-intro').innerText(),/Global Planning settings apply where no override is recorded/);
    result.cases.push('Paper retains prior date, assumption copy and source-free form rendering');
    assert.deepEqual(result.pageErrors,[]);
    console.log(JSON.stringify(result,null,2));
  }finally{fs.writeFileSync(path.join(out,'checks.json'),JSON.stringify(result,null,2));await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
