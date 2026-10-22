// Hybrid field controls: actual keyboard selection, persisted checkbox state and glyph captures.
// Run with CULMINA_EVIDENCE outside the source tree; never connects to an owner's browser.
const {launchChromium}=require('./browser_toolchain.cjs');
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const out=process.env.CULMINA_EVIDENCE;
if(!out)throw new Error('Set CULMINA_EVIDENCE to the evidence directory.');
fs.mkdirSync(out,{recursive:true});
const report={cases:[],errors:[]};
const url=(file,query)=>(process.env.CULMINA_PREVIEW_URL||'http://127.0.0.1:4173/')+file+'?'+new URLSearchParams({variant:'blend',theme:'field',...query});
(async()=>{
 const browser=await launchChromium({headless:true});
 try{
  for(const width of [375,412])for(const scale of ['1','1.25','2']){
   const context=await browser.newContext({viewport:{width,height:915}}),page=await context.newPage();
   page.setDefaultTimeout(6000);page.on('pageerror',e=>report.errors.push(e.message));
   await page.goto(url('plan.html',{scale}));await page.locator('[data-open=rig]').click();
   const radio=page.locator('.choice input[type=radio]');
   const before=await radio.evaluateAll(es=>es.findIndex(e=>e.checked));
   await radio.nth(before).focus();await page.keyboard.press('ArrowDown');
   const after=await radio.evaluateAll(es=>es.findIndex(e=>e.checked));
   assert.notEqual(after,before,'ArrowDown changes the native radio group');
   for(const state of ['checked','unchecked']){
    const input=page.locator('.choice input[type=radio]'+(state==='checked'?':checked':':not(:checked)')).first();
    const style=await input.evaluate(e=>{const s=getComputedStyle(e);return {appearance:s.appearance,color:s.color,border:s.borderColor};});
    assert.equal(style.appearance,'none');assert.equal(style.color,'rgb(255, 0, 0)');
    await input.screenshot({path:path.join(out,`radio-${state}-${width}-${scale}.png`)});
   }
   await page.emulateMedia({forcedColors:'active'});
   const forcedRadios=await radio.evaluateAll(es=>es.map(e=>({appearance:getComputedStyle(e).appearance,background:getComputedStyle(e).backgroundImage})));
   assert.ok(forcedRadios.every(s=>s.appearance==='auto'&&s.background==='none'));
   await page.emulateMedia({forcedColors:'none'});
   await page.locator('[data-apply-screen]').click();assert.match(await page.locator('.plan-row-value').last().innerText(),/Phone/);
   await page.goto(url('workspace.html',{tab:'settings',scale}));await page.locator('[data-open=privacy]').click();
   const checkbox=page.locator('[data-place-names]');
   assert.equal(await checkbox.isChecked(),false);await checkbox.focus();await page.keyboard.press('Space');
   assert.equal(await checkbox.isChecked(),true);
   await checkbox.screenshot({path:path.join(out,`checkbox-checked-${width}-${scale}.png`)});
   await page.reload();await page.locator('[data-open=privacy]').click();assert.equal(await page.locator('[data-place-names]').isChecked(),true);
   await page.emulateMedia({forcedColors:'active'});
   const forced=await page.locator('[data-place-names]').evaluate(e=>({appearance:getComputedStyle(e).appearance,marker:getComputedStyle(e,':before').content}));
   assert.equal(forced.appearance,'auto');assert.equal(forced.marker,'none');
   await page.emulateMedia({forcedColors:'none'});
   await page.locator('[data-place-names]').focus();await page.keyboard.press('Space');assert.equal(await page.locator('[data-place-names]').isChecked(),false);
   const overflow=await page.locator('.android-device').evaluate(e=>e.scrollWidth>e.clientWidth+1);
   assert.equal(overflow,false);
   report.cases.push({width,scale,radioKeyboard:true,checkboxSpaceAndPersistence:true,forcedColorsFallback:true,overflow});
   await context.close();
  }
 }finally{await browser.close();fs.writeFileSync(path.join(out,'field-checks.json'),JSON.stringify(report,null,2));}
 assert.deepEqual(report.errors,[]);console.log(JSON.stringify(report));
})().catch(e=>{console.error(e);process.exitCode=1;});
