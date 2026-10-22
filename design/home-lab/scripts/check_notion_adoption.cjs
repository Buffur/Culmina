const {launchChromium}=require('./browser_toolchain.cjs');
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const base='http://127.0.0.1:4173/',out=path.resolve(__dirname,'../evidence/notion-adoption-2026-10-22');
fs.mkdirSync(out,{recursive:true});
(async()=>{
  const b=await launchChromium({headless:true}),ctx=await b.newContext({viewport:{width:1200,height:1000}}),p=await ctx.newPage(),errors=[],cases=[];
  p.on('pageerror',e=>errors.push(String(e)));p.setDefaultTimeout(7000);
  const go=async(file,query={})=>{await p.goto(base+file+'?'+new URLSearchParams({variant:'blend',theme:'light',scale:'1',...query}));await p.evaluate(()=>document.fonts.ready);await p.addStyleTag({content:'html{scroll-behavior:auto!important}'});};
  const shot=async(name,selector='.android-device')=>{await p.locator(selector).first().screenshot({path:path.join(out,name+'.png')});};
  const contrastRoles=async(selector)=>p.locator(selector).first().evaluate(root=>{
    const lum=c=>{const a=c.match(/[\d.]+/g).slice(0,3).map(Number).map(x=>{x/=255;return x<=.04045?x/12.92:((x+.055)/1.055)**2.4;});return a[0]*.2126+a[1]*.7152+a[2]*.0722;};
    const ratio=(a,b)=>{a=lum(a);b=lum(b);return (Math.max(a,b)+.05)/(Math.min(a,b)+.05);};
    const bg=e=>{while(e){const c=getComputedStyle(e).backgroundColor;if(c!=='rgba(0, 0, 0, 0)'&&c!=='transparent')return c;e=e.parentElement;}return 'rgb(255,255,255)';};
    const text=[...root.querySelectorAll('.saved-label,.plan-state,.wx-time-axis [aria-pressed=true]')].filter(e=>e.getClientRects().length).map(e=>({label:e.textContent.trim(),ratio:ratio(getComputedStyle(e).color,bg(e))}));
    const lines=[...root.querySelectorAll('.wx-mini-chart path.wx-line')].map(e=>ratio(getComputedStyle(e).stroke,bg(e)));
    return {text,lines};
  });
  try{
    await go('conditions.html',{view:'weather'});await p.waitForSelector('[data-weather-variant=rows]');assert.equal(await p.locator('[data-weather-presentation]').count(),0);
    const before=await p.evaluate(()=>Object.fromEntries(Object.keys(localStorage).filter(k=>/plan|draft/.test(k)).map(k=>[k,localStorage.getItem(k)])));
    await p.locator('.weather-view-setting a').click();await p.waitForSelector('[data-open=appearance]');await p.locator('[data-open=appearance]').click();
    await p.locator('#settings-weather-charts').check();
    let stored=await p.evaluate(()=>JSON.parse(localStorage.getItem('culmina-settings-preview-v1')));assert.equal(stored.settings.display.weatherPresentation,'charts');
    await shot('settings-weather-charts');
    await p.locator('#workspace-back').click();await p.locator('[data-open=backup]').click();
    const downloadWait=p.waitForEvent('download');await p.locator('[data-export]').click();const download=await downloadWait;
    const backup=JSON.parse(fs.readFileSync(await download.path(),'utf8'));assert.equal(backup.settings.display.weatherPresentation,'charts');
    const legacyBackup=structuredClone(backup);delete legacyBackup.settings.display.weatherPresentation;
    await p.locator('[data-restore-file]').setInputFiles({name:'legacy-weather.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(legacyBackup))});
    await p.waitForSelector('[data-restore-apply]');await p.locator('[data-restore-apply]').click();await p.waitForSelector('[data-restore-file]');
    assert.equal(await p.evaluate(()=>JSON.parse(localStorage.getItem('culmina-settings-preview-v1')).settings.display.weatherPresentation),'rows');
    await p.locator('[data-restore-file]').setInputFiles({name:'weather-charts.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(backup))});
    await p.waitForSelector('[data-restore-apply]');await p.locator('[data-restore-apply]').click();await p.waitForSelector('[data-restore-file]');
    assert.equal(await p.evaluate(()=>JSON.parse(localStorage.getItem('culmina-settings-preview-v1')).settings.display.weatherPresentation),'charts');
    const oldPayload=structuredClone(stored);delete oldPayload.settings.display.weatherPresentation;
    assert.equal(await p.evaluate(async data=>{const {validateSettingsPayload}=await import('./settings.js?v=20261020-hybrid7');return validateSettingsPayload(data);},oldPayload),true);
    const badPayload=structuredClone(stored);badPayload.settings.display.weatherPresentation='invented';
    assert.equal(await p.evaluate(async data=>{const {validateSettingsPayload}=await import('./settings.js?v=20261020-hybrid7');return validateSettingsPayload(data);},badPayload),false);
    const settingsUrl=p.url();
    await p.locator('#workspace-back').click();await p.locator('#workspace-nav [data-tab=home]').click();await p.waitForSelector('.concept.variant-blend');
    assert.equal(await p.locator('.concept.variant-blend .weather-variant').count(),0,'Tonight must stay compact');
    await p.locator('.concept.variant-blend [data-action=weather]').first().click();await p.waitForSelector('[data-weather-variant=charts]');
    await p.reload();await p.waitForSelector('[data-weather-variant=charts]');
    await shot('weather-charts');
    const conditionsUrl=p.url(),other=await ctx.newPage();await other.goto(settingsUrl);await other.waitForSelector('[data-open=appearance]');await other.locator('[data-open=appearance]').click();await other.locator('#settings-weather-rows').check();
    await p.waitForSelector('[data-weather-variant=rows]');await other.close();
    await p.goto(conditionsUrl);await p.waitForSelector('[data-weather-variant=rows]'); // stored preference beats stale charts URL
    await shot('weather-rows');
    await p.evaluate(data=>localStorage.setItem('culmina-settings-preview-v1',JSON.stringify(data)),oldPayload);
    await go('workspace.html',{tab:'settings'});await p.locator('[data-open=appearance]').click();assert.equal(await p.locator('#settings-weather-rows').isChecked(),true);
    assert.equal(await p.evaluate(()=>Object.hasOwn(JSON.parse(localStorage.getItem('culmina-settings-preview-v1')).settings.display,'weatherPresentation')),false,'Reading old settings must not rewrite them');
    const legacyWeather=await ctx.newPage();await legacyWeather.goto(conditionsUrl);await legacyWeather.waitForSelector('[data-weather-variant=rows]');await legacyWeather.close();
    await p.locator('#settings-weather-charts').check();
    stored=await p.evaluate(()=>JSON.parse(localStorage.getItem('culmina-settings-preview-v1')));assert.deepEqual(stored.settings.planning,oldPayload.settings.planning);assert.deepEqual(stored.settings.privacy,oldPayload.settings.privacy);
    const after=await p.evaluate(()=>Object.fromEntries(Object.keys(localStorage).filter(k=>/plan|draft/.test(k)).map(k=>[k,localStorage.getItem(k)])));assert.deepEqual(after,before,'Settings must not mutate a plan/draft');
    for(const theme of ['light','dark','field']){
      for(const view of ['night','weather']){
        await go('conditions.html',{theme,view});await p.waitForSelector('#conditions-main h2');
        const expected=theme==='light'?'#0075de':theme==='dark'?'#62aff3':'#ff0000';
        const measure=await p.locator('.android-device').evaluate(e=>({blue:getComputedStyle(e).getPropertyValue('--data-temperature').trim(),overflow:e.scrollWidth>e.clientWidth+1,background:getComputedStyle(e).backgroundColor}));
        assert.equal(measure.blue.toLowerCase(),expected);assert.equal(measure.overflow,false);
        if(view==='night'){
          assert.equal(await p.locator('[data-timeline]').getAttribute('data-timeline-variant'),'gradient');
          assert.equal(await p.locator('.key-dark').first().evaluate(e=>getComputedStyle(e).backgroundColor),'rgb(0, 0, 0)');
          await shot('night-'+theme);
        }else if(theme!=='field'){
          const colours=await p.locator('.wx-time-axis [aria-pressed=true]').evaluate(e=>({text:getComputedStyle(e).color,background:getComputedStyle(e).backgroundColor})),contrast=await contrastRoles('.android-device');assert(contrast.text.every(c=>c.ratio>=4.5));assert(contrast.lines.every(c=>c>=3));cases.push({theme,view,...measure,colours,contrast});
          await shot('weather-'+theme);
        }
        cases.push({theme,view,...measure});
      }
      await go('index.html',{theme,view:'wide'});await p.waitForSelector('.concept.variant-blend');
      const home=await p.locator('.concept.variant-blend').evaluate(e=>({sky:getComputedStyle(e.querySelector('.key-dark')).backgroundColor,variant:e.querySelector('[data-timeline]').dataset.timelineVariant,status:e.querySelector('.saved-label').dataset.persistence,temperature:getComputedStyle(e).getPropertyValue('--data-temperature').trim()}));
      assert.equal(home.sky,'rgb(0, 0, 0)');assert.equal(home.variant,'gradient');await shot('home-'+theme,'.concept.variant-blend .app-frame');cases.push({theme,view:'home',...home});
      if(theme!=='field'){const contrast=await contrastRoles('.concept.variant-blend');assert(contrast.text.every(c=>c.ratio>=4.5));cases.push({theme,view:'home-status',contrast});}
      await go('plan.html',{theme});await p.waitForSelector('.plan-state');assert(await p.locator('.plan-state').getAttribute('data-persistence'));await shot('plan-'+theme);
      await go('workspace.html',{theme,tab:'logbook'});await p.waitForSelector('.logbook-view');
      await p.locator('#workspace-nav [data-tab=library]').click();await p.waitForSelector('.library-view');
      await p.locator('#workspace-nav [data-tab=settings]').click();await p.waitForSelector('.settings-view');
    }
    await p.setViewportSize({width:412,height:915});await go('workspace.html',{tab:'settings'});await p.locator('[data-open=appearance]').click();
    for(const width of [375,412]){await p.setViewportSize({width,height:915});assert.equal(await p.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1),false);const controls=await p.locator('[name=settings-weather]').evaluateAll(es=>es.map(e=>{const r=e.closest('label').getBoundingClientRect();return {width:r.width,height:r.height};}));assert(controls.every(c=>c.height>=48&&c.width>=48));}
    assert.deepEqual(errors,[]);
    fs.writeFileSync(path.join(out,'qa.json'),JSON.stringify({status:'pass',cases,errors,checks:['A default','Settings stores B','Tonight stays compact','navigation and reload respect B','cross-tab A switch','stored preference overrides stale URL','legacy v1 read/validation without rewriting','actual JSON export and confirmed restore of legacy/new weather preference','invalid weather enum rejected','planning/privacy/plan/draft preserved','gradient and black night on main Home/Night','Notion roles in light/dark/field','main Plan/Logbook/Library/Settings smoke','375/412 Settings controls']},null,2));
    console.log(JSON.stringify({status:'pass',cases:cases.length,errors}));
  }finally{await b.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
