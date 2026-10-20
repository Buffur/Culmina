// Verify the residual QA observation at the real sticky footer, not just isVisible().
const {launchChromium}=require('./browser_toolchain.cjs');
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict');
const source=path.resolve(__dirname,'..'),out=path.join(source,'evidence/hybrid-refinement-2026-10-20/import-focus');
fs.mkdirSync(out,{recursive:true});
const hashes=()=>Object.fromEntries(fs.readdirSync(source).filter(x=>/\.(js|css|html|json)$/.test(x)).map(x=>[x,crypto.createHash('sha256').update(fs.readFileSync(path.join(source,x))).digest('hex')]));
(async()=>{const report={sourceBefore:hashes(),cases:[],errors:[]},browser=await launchChromium({headless:true});
try{for(const width of [360,412])for(const theme of ['light','dark','field'])for(const kind of ['photo','json']){
 const context=await browser.newContext({viewport:{width,height:915}}),p=await context.newPage();
 p.on('pageerror',e=>report.errors.push(e.message));
 const row={width,theme,kind,status:'running'};report.cases.push(row);
 try{
 await p.goto(`http://127.0.0.1:4173/workspace.html?variant=blend&tab=library&scale=2&theme=${theme}`);
 await p.locator('[data-open-list=rigs]').click();await p.locator('[data-add=rig]').click();
 await p.locator('[data-field=name]').fill('Focus proof '+kind);await p.locator('[name=library-class][value=dslrMirrorless]').check();
 const before=await p.evaluate(()=>localStorage.getItem('culmina-library-preview-v1'));
 if(kind==='photo'){await p.locator('[data-photo-metadata]>summary').click();await p.locator('[data-photo-example]').click();}
 else{await p.locator('[data-metadata]>summary').click();await p.locator('[data-metadata-file]').setInputFiles({name:'rig.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify({metadata:{cameraModel:'Example'}}))});await p.locator('.library-metadata-review').waitFor();}
 await p.getByRole('button',{name:'Save rig',exact:true}).click();
 row.geometry=await p.locator('[data-metadata-apply]').evaluate(e=>{const r=e.getBoundingClientRect(),bar=document.querySelector('.library-form-actions,.library-savebar').getBoundingClientRect(),scroller=document.querySelector('.android-scroll').getBoundingClientRect();return {focused:document.activeElement===e,top:r.top,bottom:r.bottom,footerTop:bar.top,scrollTop:scroller.top,scrollBottom:scroller.bottom,width:r.width,height:r.height};});
 assert.equal(row.geometry.focused,true,'Apply receives keyboard focus');
 assert.ok(row.geometry.top>=row.geometry.scrollTop-1,'Apply is above the top clipping boundary');
 assert.ok(row.geometry.bottom<=Math.min(row.geometry.footerTop,row.geometry.scrollBottom)+1,'whole Apply button stays above the sticky Save footer');
 assert.equal(await p.evaluate(()=>localStorage.getItem('culmina-library-preview-v1')),before,'refused Save writes nothing');
 await p.locator('.android-device').screenshot({path:path.join(out,`${kind}-${width}-${theme}-200.png`)});row.status='pass';
 }catch(e){row.status='fail';row.error=String(e);}finally{await context.close();}
}
 for(const width of [360,412])for(const theme of ['light','dark','field'])for(const kind of ['target','site']){
  const context=await browser.newContext({viewport:{width,height:915}}),p=await context.newPage();
  const row={width,theme,kind,status:'running'};report.cases.push(row);p.on('pageerror',e=>report.errors.push(e.message));
  try{
   await p.goto(`http://127.0.0.1:4173/workspace.html?variant=blend&tab=library&scale=2&theme=${theme}`);
   await p.locator(`[data-open-list=${kind==='target'?'targets':'sites'}]`).click();await p.locator(`[data-add=${kind}]`).click();
   const footer=p.locator('.library-form-actions');await footer.scrollIntoViewIfNeeded();
   row.geometry=await footer.evaluate(e=>{const r=e.getBoundingClientRect(),s=document.querySelector('.android-scroll').getBoundingClientRect();return {top:r.top,bottom:r.bottom,scrollTop:s.top,scrollBottom:s.bottom,overflow:e.scrollWidth>e.clientWidth+1,buttons:[...e.querySelectorAll('button')].map(b=>{const x=b.getBoundingClientRect();return {label:b.textContent,width:x.width,height:x.height,bottom:x.bottom};})};});
   assert.ok(!row.geometry.overflow);assert.ok(row.geometry.top>=row.geometry.scrollTop-1);assert.ok(row.geometry.bottom<=row.geometry.scrollBottom+1);assert.ok(row.geometry.buttons.every(b=>b.width>=47.5&&b.height>=47.5));
   await p.locator('.android-device').screenshot({path:path.join(out,`${kind}-${width}-${theme}-200.png`)});row.status='pass';
  }catch(e){row.status='fail';row.error=String(e);}finally{await context.close();}
 }
}finally{report.sourceAfter=hashes();report.sourceStable=JSON.stringify(report.sourceBefore)===JSON.stringify(report.sourceAfter);report.summary={cases:report.cases.length,passed:report.cases.filter(x=>x.status==='pass').length,failed:report.cases.filter(x=>x.status==='fail').length};fs.writeFileSync(path.join(out,'checks.json'),JSON.stringify(report,null,2));await browser.close();console.log(JSON.stringify(report));if(report.summary.failed||report.errors.length||!report.sourceStable)process.exitCode=1;}
})();
