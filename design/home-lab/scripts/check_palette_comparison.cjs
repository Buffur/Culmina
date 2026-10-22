// Bounded browser checks for the palette study, using the existing pinned runtime.
const {launchChromium}=require('./browser_toolchain.cjs');
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const out=path.resolve(__dirname,'../evidence/palette-comparison-2026-10-22');
fs.mkdirSync(out,{recursive:true});
(async()=>{
  const browser=await launchChromium({headless:true});
  const page=await browser.newPage({viewport:{width:1200,height:1000}}),errors=[],cases=[],skyCases=[],neutralBaselines={};
  page.on('pageerror',e=>errors.push(String(e)));
  try{
    await page.goto('http://127.0.0.1:4173/hybrid-studies.html?theme=dark&width=412&weather=charts#palette-examples');
    await page.waitForSelector('body[data-study-ready=true]');
    await page.evaluate(()=>document.fonts.ready);
    await page.addStyleTag({content:'html{scroll-behavior:auto!important}'});
    const ids=await page.locator('#palette-A option').evaluateAll(options=>options.map(o=>o.value));
    assert.equal(ids.length,11);
    for(const theme of ['light','dark'])for(const width of ['375','412'])for(const id of ids){
      await page.selectOption('#study-theme',theme);await page.selectOption('#study-width',width);await page.selectOption('#palette-A',id);
      const measure=await page.locator('[data-sample=A]').evaluate(phone=>{
        const luminance=colour=>{const v=colour.match(/[\d.]+/g).slice(0,3).map(Number).map(x=>{x/=255;return x<=.04045?x/12.92:((x+.055)/1.055)**2.4;});return v[0]*.2126+v[1]*.7152+v[2]*.0722;};
        const ratio=(a,b)=>{a=luminance(a);b=luminance(b);return (Math.max(a,b)+.05)/(Math.min(a,b)+.05);};
        const background=e=>{while(e){const c=getComputedStyle(e).backgroundColor;if(c!=='rgba(0, 0, 0, 0)'&&c!=='transparent')return c;e=e.parentElement;}return 'rgb(255,255,255)';};
        const text=[...phone.querySelectorAll('.palette-support,.palette-eyebrow,.palette-plan h4,.palette-primary,.palette-selected,.palette-input input,[data-palette-state],.palette-metrics dt,.palette-saved,.wx-chart-summary,.wx-axis-label,.wx-time-axis [aria-pressed=true]')].map(e=>({label:e.textContent.trim()||e.value,ratio:ratio(getComputedStyle(e).color,background(e))}));
        const input=phone.querySelector('.palette-input input'),control=ratio(getComputedStyle(input).borderTopColor,background(input));
        const neutral=Object.fromEntries([':scope','.palette-plan','.palette-primary','.palette-selected','.palette-input input','.palette-support','.palette-plan h4','.wx-mini-chart h3','.wx-chart-summary'].map(selector=>{const e=selector===':scope'?phone:phone.querySelector(selector),c=getComputedStyle(e);return [selector,[c.backgroundColor,c.color,c.borderTopColor]];}));
        const saved=getComputedStyle(phone.querySelector('.palette-saved')).color,icon=getComputedStyle(phone.querySelector('.wx-tone-temperature .culmina-data-icon')).color;
        const lines=[...phone.querySelectorAll('.wx-mini-chart path.wx-line')].map(e=>({secondary:e.classList.contains('wx-secondary-line'),stroke:getComputedStyle(e).stroke,ratio:ratio(getComputedStyle(e).stroke,background(e))}));
        return {width:phone.getBoundingClientRect().width,overflow:phone.scrollWidth>phone.clientWidth+1,minText:Math.min(...text.map(t=>t.ratio)),control,text,neutral,saved,icon,lines};
      });
      assert.equal(measure.width,Number(width));assert.equal(measure.overflow,false,`${theme}/${width}/${id} overflow`);
      assert(measure.minText>=4.5,`${theme}/${id} text: ${JSON.stringify(measure.text.filter(t=>t.ratio<4.5))}`);
      assert(measure.control>=3,`${theme}/${id} control ${measure.control}`);
      const baselineKey=theme+width;
      if(id==='culmina')neutralBaselines[baselineKey]=measure.neutral;else {assert.deepEqual(measure.neutral,neutralBaselines[baselineKey],`${theme}/${id} changed neutral theme`);assert.notEqual(measure.icon,measure.neutral['.palette-plan h4'][1],`${theme}/${id} lost its data accent`);}
      if(id==='culmina')neutralBaselines[baselineKey+'Saved']=measure.saved;else assert.equal(measure.saved,neutralBaselines[baselineKey+'Saved'],`${theme}/${id} changed Saved semantics`);
      assert(measure.lines.every(l=>l.ratio>=3),`${theme}/${id} chart line contrast`);
      cases.push({theme,width,id,...measure});
    }
    const skyIds=await page.locator('#sky-A option').evaluateAll(options=>options.map(o=>o.value));assert.equal(skyIds.length,9);
    for(const theme of ['light','dark']){await page.selectOption('#study-theme',theme);for(const sky of skyIds){
      await page.selectOption('#sky-A',sky);
      const actual=await page.locator('[data-sample=A]').evaluate(p=>({ramp:getComputedStyle(p.querySelector('.sky-track')).backgroundImage,dark:getComputedStyle(p.querySelector('.key-dark')).backgroundColor,legend:getComputedStyle(p.querySelector('.key-day')).backgroundColor,canvas:getComputedStyle(p).backgroundColor}));
      assert.equal(actual.dark,'rgb(0, 0, 0)');assert.match(actual.ramp,/rgb\(0, 0, 0\)/);skyCases.push({theme,sky,...actual});
    }}
    for(const theme of ['light','dark'])assert.equal(new Set(skyCases.filter(s=>s.theme===theme).map(s=>s.ramp)).size,9);
    await page.selectOption('#sky-A','aqua');await page.selectOption('#sky-B','dusk');
    await page.selectOption('#palette-A','starry-night');await page.selectOption('#palette-B','ocean-breeze');
    await page.click('#palette-swap');assert.equal(await page.inputValue('#palette-A'),'ocean-breeze');
    assert.equal(await page.inputValue('#palette-B'),'starry-night');await page.reload();await page.waitForSelector('body[data-study-ready=true]');
    assert.equal(await page.inputValue('#palette-A'),'ocean-breeze');assert.equal(await page.inputValue('#palette-B'),'starry-night');
    assert.equal(await page.inputValue('#sky-A'),'dusk');assert.equal(await page.inputValue('#sky-B'),'aqua');
    await page.addStyleTag({content:'html{scroll-behavior:auto!important}'});
    await page.locator('[data-weather-choice=rows]').click();assert.equal(await page.locator('.palette-phone [data-weather-variant=rows]').count(),2);
    await page.locator('[data-weather-choice=charts]').click();assert.equal(await page.locator('.palette-phone [data-weather-variant=charts]').count(),2);
    await page.locator('[data-sample=A] [data-weather-index="2"]').click();
    assert.equal(await page.locator('[data-sample=A] [data-weather-index="2"]').getAttribute('aria-pressed'),'true');
    assert.equal(await page.locator('[data-sample=B] [data-weather-index="0"]').getAttribute('aria-pressed'),'true');
    const beforeB=await page.locator('[data-sample=B] [data-night-cursor]').inputValue();
    await page.locator('[data-sample=A] [data-action=cursor-end]').click();
    assert.equal(await page.locator('[data-sample=B] [data-night-cursor]').inputValue(),beforeB);
    assert.notEqual(await page.locator('[data-sample=A] [data-night-cursor]').inputValue(),beforeB);
    await page.locator('[data-sample=A] [data-palette-demo]').click();assert.match(await page.locator('[data-sample=A] .palette-action-result').innerText(),/Example action selected/);
    await page.selectOption('#study-state','no-dark');assert.match(await page.locator('[data-sample=A] .palette-selected').innerText(),/No dark time/);
    await page.selectOption('#study-state','unknown');assert.match(await page.locator('[data-sample=B] .palette-weather').innerText(),/No forecast|Unknown|unavailable/i);
    await page.selectOption('#palette-A','notion');await page.selectOption('#palette-B','culmina');await page.selectOption('#study-state','ready');
    await page.selectOption('#study-theme','field');
    const field=await page.locator('.palette-phone').evaluateAll(phones=>phones.map(p=>[getComputedStyle(p).backgroundColor,getComputedStyle(p).color]));
    assert.deepEqual(field[0],field[1]);assert.equal(field[0][0],'rgb(0, 0, 0)');
    const fieldRamps=await page.locator('.palette-phone .sky-track').evaluateAll(es=>es.map(e=>getComputedStyle(e).backgroundImage));assert.equal(fieldRamps[0],fieldRamps[1]);
    const fieldHour=await page.locator('[data-sample=A] .wx-time-axis [aria-pressed=true]').evaluate(e=>[getComputedStyle(e).color,getComputedStyle(e).backgroundColor]);
    assert(fieldHour.every(c=>{const channels=c.match(/\d+/g).map(Number);return channels[1]===0&&channels[2]===0;}),'Notion selected hour must stay red/black in Field');
    await page.selectOption('#study-state','ready');await page.selectOption('#study-theme','dark');
    await page.selectOption('#palette-A','notion');await page.selectOption('#palette-B','culmina');
    await page.selectOption('#sky-A','notion');await page.selectOption('#sky-B','blue');
    await page.locator('#palette-examples').evaluate(e=>e.scrollIntoView({block:'start',behavior:'instant'}));await page.screenshot({path:path.join(out,'dark-ab.png')});
    await page.locator('[data-sample=A] .palette-night').scrollIntoViewIfNeeded();await page.screenshot({path:path.join(out,'dark-timelines.png')});
    await page.locator('[data-sample=A] .wx-mini-chart').first().scrollIntoViewIfNeeded();await page.screenshot({path:path.join(out,'dark-charts.png')});
    await page.selectOption('#study-theme','light');
    await page.locator('#palette-examples').evaluate(e=>e.scrollIntoView({block:'start',behavior:'instant'}));await page.screenshot({path:path.join(out,'light-ab.png')});
    await page.locator('[data-sample=A] .palette-night').scrollIntoViewIfNeeded();await page.screenshot({path:path.join(out,'light-timelines.png')});
    await page.locator('[data-sample=A] .wx-mini-chart').first().scrollIntoViewIfNeeded();await page.screenshot({path:path.join(out,'light-charts.png')});
    await page.setViewportSize({width:412,height:915});
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1),false);
    await page.locator('#palette-A').scrollIntoViewIfNeeded();await page.screenshot({path:path.join(out,'mobile-412.png')});
    await page.setViewportSize({width:375,height:900});await page.selectOption('#study-width','375');
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1),false);
    assert.deepEqual(errors,[]);
    fs.writeFileSync(path.join(out,'qa.json'),JSON.stringify({status:'pass',cases,skyCases,field,errors,checks:['11 data palettes × 2 themes × 2 widths','neutral surfaces/text/actions/inputs invariant across accents','Saved semantic colour stays stable across palettes','selected hour text contrast including Notion pale blue','chart line contrast','9 sky ramps × 2 themes with black dark interval','swap and URL reload include sky','independent timeline jump and weather-hour selection','rows/charts switching','example action','no-dark and unknown forecast','Field regression','375/412 browser overflow']},null,2));
    console.log(JSON.stringify({status:'pass',cases:cases.length,skyCases:skyCases.length,minText:Math.min(...cases.map(c=>c.minText)),minControl:Math.min(...cases.map(c=>c.control)),errors}));
  }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
