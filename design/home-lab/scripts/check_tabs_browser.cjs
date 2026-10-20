// Run against the loopback preview server. Uses an isolated browser profile and localhost origin.
const {launchChromium}=require('./browser_toolchain.cjs');
const fs=require('node:fs');
const path=require('node:path');
const assert=require('node:assert/strict');
const out=process.env.CULMINA_EVIDENCE?path.resolve(process.env.CULMINA_EVIDENCE):path.resolve(__dirname,'../evidence/tabs-2026-10-20');
fs.mkdirSync(out,{recursive:true});
const results={matrix:[],inner:[],states:[],errors:[],resources:[],interactions:[],home:[],palettes:[]};
async function inspect(page){
  return page.evaluate(()=>{
    const phone=document.querySelector('.android-device'),main=document.querySelector('#workspace-main'),scroll=document.querySelector('.android-scroll');
    const rect=phone.getBoundingClientRect();
    const small=[...document.querySelectorAll('.android-device button,.android-device select,.android-device input:not([type=checkbox]):not([type=radio])')].filter(e=>e.getClientRects().length).map(e=>({label:e.getAttribute('aria-label')||e.textContent.trim().slice(0,50),...(()=>{const r=e.getBoundingClientRect();return {w:r.width,h:r.height};})()})).filter(r=>r.w<47.5||r.h<47.5);
    return {title:document.querySelector('#workspace-title').textContent,viewport:{width:innerWidth,height:innerHeight},width:rect.width,bottom:rect.bottom,mainOverflow:main.scrollWidth>main.clientWidth+1,scrollOverflow:scroll.scrollWidth>scroll.clientWidth+1,pageOverflow:document.documentElement.scrollWidth>innerWidth+1,smallTargets:small,body:main.innerText.slice(0,180)};
  });
}
(async()=>{
  const browser=await launchChromium({headless:true});
  const context=await browser.newContext();
  // Enumeration visits deliberately start at each root. Session continuity is
  // exercised separately by check_tabs_interactions.cjs, without this reset.
  await context.addInitScript(()=>{
    for(const key of ['culmina-logbook-context-v1','culmina-library-navigation-v1'])sessionStorage.removeItem(key);
  });
  const page=await context.newPage();
  page.on('pageerror',e=>results.errors.push(String(e)));
  page.on('requestfailed',r=>results.resources.push({url:r.url(),failure:r.failure()}));
  page.on('response',r=>{if(r.status()>=400)results.resources.push({url:r.url(),status:r.status()});});
  try{
    for(const viewport of [{width:1280,height:1040},{width:412,height:915}])for(const theme of ['light','dark','field'])for(const scale of ['1','2'])for(const tab of ['logbook','library','settings']){
      await page.setViewportSize(viewport);
      await page.goto(`http://localhost:4173/workspace.html?tab=${tab}&theme=${theme}&scale=${scale}`);
      await page.waitForFunction(()=>document.querySelector('#workspace-main')?.textContent.trim().length>0);
      await page.evaluate(()=>document.fonts.ready);
      const r={tab,theme,scale,...await inspect(page)};results.matrix.push(r);
      assert.doesNotMatch(r.body,/Could not open this tab|Could not load the preview/,`${tab} must mount its actual screen`);
      assert.equal(r.pageOverflow,false,`${tab} page overflow`);assert.equal(r.mainOverflow,false,`${tab} main overflow`);assert.equal(r.scrollOverflow,false,`${tab} content overflow`);
      assert.ok(r.width<=412.5);assert.ok(r.bottom<=viewport.height+1);assert.deepEqual(r.smallTargets,[],`${tab} touch targets`);
      if(viewport.width===412&&((theme==='light'&&scale==='1')||(theme==='dark'&&scale==='1')||(theme==='light'&&scale==='2')))await page.locator('.android-device').screenshot({path:path.join(out,`${tab}-${theme}-${scale}.png`)});
    }
    for(const tab of ['logbook','library','settings'])for(const scenario of ['empty','error','storage-error']){
      await page.goto(`http://localhost:4173/workspace.html?tab=${tab}&scenario=${scenario}`);
      await page.waitForFunction(()=>document.querySelector('#workspace-main')?.textContent.trim().length>0);
      results.states.push({tab,scenario,...await inspect(page)});
    }
    const inner=async(name,theme)=>{const r={name,theme,scale:'2',...await inspect(page)};results.inner.push(r);assert.equal(r.mainOverflow,false,name+' overflow');assert.equal(r.scrollOverflow,false);assert.deepEqual(r.smallTargets,[],name+' targets');if(theme==='light'){r.capture=`qa-inner-${name.toLowerCase().replace(/[^a-z0-9]+/g,'-')}-200.png`;await page.locator('.android-device').screenshot({path:path.join(out,r.capture)});}};
    await page.setViewportSize({width:412,height:915});
    for(const theme of ['light','dark','field']){
      const visit=async tab=>{await page.goto(`http://localhost:4173/workspace.html?tab=${tab}&theme=${theme}&scale=2`);await page.waitForSelector(`.${tab}-view`);};
      await visit('logbook');await page.locator('[data-open-entry="example-m31-2026-10-12"]').click();await inner('Logbook detail',theme);await page.locator('[data-result-entry]').click();await inner('Result editor',theme);
      await visit('logbook');await page.locator('[data-open-progress]').click();await inner('Progress',theme);
      for(const[kind,list]of [['rig','rigs'],['target','targets'],['site','sites']]){
        await visit('library');await page.locator(`[data-open-list=${list}]`).click();await inner(list+' list',theme);
        await page.locator('[data-open]').first().click();await inner(kind+' detail',theme);
        await page.locator('#workspace-back').click();await page.locator(`[data-add=${kind}]`).click();await inner(kind+' editor',theme);
      }
      for(const section of ['appearance','planning','privacy','backup','about']){
        await visit('settings');await page.locator(`[data-open=${section}]`).click();
        if(section==='planning')await page.locator('[data-advanced] summary').click();
        await inner('Settings '+section,theme);
      }
    }
    for(const viewport of [{width:1280,height:1040},{width:412,height:915}])for(const theme of ['light','dark','field'])for(const scale of ['1','2']){
      await page.setViewportSize(viewport);await page.goto(`http://localhost:4173/index.html?variant=blend&view=wide&theme=${theme}&scale=${scale}#concepts`);await page.waitForSelector('.weather-row');
      const r=await page.locator('.app-frame').first().evaluate(e=>({overflow:e.scrollWidth>e.clientWidth+1,width:e.getBoundingClientRect().width,widget:e.querySelector('.weather-row').innerText,expanded:!!e.querySelector('.weather-row .wx-chips'),gradient:getComputedStyle(e.querySelector('.sky-track')).backgroundImage}));
      assert.equal(r.overflow,false);assert.ok(r.width<=412.5);assert.equal(r.expanded,false);assert.notEqual(r.gradient,'none');results.home.push({viewport,theme,scale,...r});
    }
    await page.setViewportSize({width:1280,height:1040});
    for(const theme of ['light','dark','field'])for(const sky of ['dusk','slate','ink']){
      await page.goto(`http://localhost:4173/index.html?variant=blend&view=wide&theme=${theme}&sky=${sky}#concepts`);await page.waitForSelector('.sky-track');
      const colours=await page.locator('html').evaluate(e=>{const s=getComputedStyle(e);return ['day','civil','nautical','astro','dark'].map(c=>s.getPropertyValue('--sky-'+c).trim());});
      results.palettes.push({theme,sky,colours});await page.locator('.night-slider').first().screenshot({path:path.join(out,`sky-${theme}-${sky}.png`)});
    }
    await page.goto('http://localhost:4173/index.html?variant=blend&view=wide&theme=dark#concepts');
    await page.waitForSelector('.weather-row');
    const widget=await page.locator('.weather-row').first().evaluate(e=>({text:e.innerText,expanded:!!e.querySelector('.wx-chips')}));
    assert.equal(widget.expanded,false);assert.doesNotMatch(widget.text,/cloud|dew|gust|rain/i);results.interactions.push({case:'Compact Home Weather',...widget});
    await page.locator('.app-nav [data-action=logbook]').first().click();
    await page.waitForURL(/workspace.html/);await page.waitForFunction(()=>document.querySelector('#workspace-main').textContent.trim());
    assert.equal(await page.locator('#workspace-title').textContent(),'Logbook');
    await page.locator('#workspace-nav [data-tab=library]').click();assert.equal(await page.locator('#workspace-title').textContent(),'Library');
    await page.locator('#workspace-nav [data-tab=settings]').click();assert.equal(await page.locator('#workspace-title').textContent(),'Settings');
    results.interactions.push({case:'Home to Logbook to Library to Settings',passed:true});
    assert.deepEqual(results.errors,[],'Browser module errors');
    console.log(JSON.stringify({matrixCases:results.matrix.length,innerCases:results.inner.length,homeCases:results.home.length,paletteCases:results.palettes.length,stateCases:results.states.length,errors:results.errors},null,2));
  }catch(error){results.failure={message:String(error),url:page.url(),body:await page.locator('body').innerText().catch(()=>'<unavailable>')};throw error;}finally{
    fs.writeFileSync(path.join(out,'browser-matrix.json'),JSON.stringify(results,null,2));
    await browser.close();
  }
})().catch(e=>{console.error(e);process.exitCode=1;});
