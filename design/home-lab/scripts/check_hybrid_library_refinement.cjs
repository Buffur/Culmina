// Scoped browser contracts; every scenario has a fresh profile. No owner data.
const {launchChromium}=require('./browser_toolchain.cjs');
const assert=require('node:assert/strict');
const fs=require('node:fs'),path=require('node:path');
const out=path.resolve(__dirname,'../evidence/hybrid-refinement-2026-10-20/library');
fs.mkdirSync(out,{recursive:true});
const result={cases:[],screens:[],errors:[]};
const key='culmina-library-preview-v1';
(async()=>{
 const browser=await launchChromium({headless:true});
 const run=async(name,fn,variant='blend',scenario='ready')=>{
  const context=await browser.newContext({viewport:{width:412,height:915}});
  const page=await context.newPage();
  page.on('pageerror',e=>result.errors.push(String(e)));
  try{
   await page.goto(`http://localhost:4173/workspace.html?variant=${variant}&tab=library&scenario=${scenario}`);
   await page.waitForSelector('.library-view');
   await fn(page,context);
   result.cases.push({name,passed:true});
  }finally{await context.close();}
 };
 const snap=async(p,name)=>{await p.locator('.android-device').screenshot({path:path.join(out,name+'.png')});result.screens.push(name+'.png');};
 const addRig=async p=>{await p.locator('[data-open-list=rigs]').click();await p.locator('[data-add=rig]').click();};
 const read=async p=>p.evaluate(k=>localStorage.getItem(k),key);
 const draft=async p=>p.locator('[data-edit-form]').evaluate(e=>Object.fromEntries([...e.querySelectorAll('[data-field]')].map(x=>[x.dataset.field,x.value])));
 const validRig=async p=>{
  await addRig(p);await p.locator('[name=library-class][value=dslrMirrorless]').check();
  for(const [field,value] of Object.entries({name:'Review boundary rig',resW:'6000',resH:'4000',pixel:'3.9',focal:'135',ratio:'2.8'}))await p.locator(`[data-field=${field}]`).fill(value);
 };
 try{
  await run('R2 root error, unknown count, retry',async p=>{
   assert.match(await p.locator('.library-view').innerText(),/Couldn't load the Library/);
   assert.match(await p.locator('[data-open-list=sites]').innerText(),/Count unavailable/);
   assert.doesNotMatch(await p.locator('[data-open-list=sites]').innerText(),/\d+ saved/);
   await snap(p,'root-error');
   await p.locator('[data-retry-load]').click();
   assert.equal(await p.locator('[data-retry-load]').count(),0);
   assert.match(await p.locator('[data-open-list=sites]').innerText(),/2 example sites/);
  },'blend','error');
  await run('R5 search precedes disclosure; R8 new target copy',async p=>{
   await p.locator('[data-open-list=targets]').click();
   const positions=await p.evaluate(()=>({search:document.querySelector('[data-search]').getBoundingClientRect().top,info:[...document.querySelectorAll('summary')].find(e=>e.textContent==='Sources and preview limits').getBoundingClientRect().top}));
   assert.ok(positions.search<positions.info);
   assert.equal(await p.locator('details').first().getAttribute('open'),null);
   await p.locator('[data-add=target]').click();
   const text=await p.locator('[data-focus-start]').innerText();
   assert.match(text,/new target/);assert.doesNotMatch(text,/exactly what is stored/);
   await snap(p,'new-target');
  });
  await run('F1 photo demo review and cancel preserve draft/storage; partial and error states',async p=>{
   await addRig(p);const initial=await draft(p);
   await p.locator('[data-photo-metadata] > summary').click();
   await p.locator('[data-photo-file]').setInputFiles({name:'example.dng',mimeType:'application/octet-stream',buffer:Buffer.from('not a real photo')});
   assert.match(await p.locator('#library-photo-title').innerText(),/example DNG/);
   assert.deepEqual(await draft(p),initial);assert.equal(await read(p),null);
   await snap(p,'photo-review');
   await p.locator('[data-metadata-cancel]').click();assert.deepEqual(await draft(p),initial);assert.equal(await read(p),null);
   await p.locator('[data-photo-metadata] > summary').click();
   await p.locator('[data-photo-outcome]').selectOption('partial');await p.locator('[data-photo-example]').click();
   assert.equal(await p.locator('[data-metadata-choice]').count(),4);
   assert.match(await p.locator('.library-metadata-review').innerText(),/Missing in this example/);
   await snap(p,'photo-partial');
   await p.locator('[data-metadata-cancel]').click();await p.locator('[data-photo-metadata] > summary').click();
   await p.locator('[data-photo-outcome]').selectOption('unreadable');await p.locator('[data-photo-example]').click();
   assert.match(await p.locator('[role=alert]').innerText(),/header could not be read/);
   assert.deepEqual(await draft(p),initial);assert.equal(await read(p),null);
   await p.locator('[data-photo-outcome]').selectOption('complete');
   await p.locator('[data-photo-file]').setInputFiles({name:'unsupported.nef',mimeType:'application/octet-stream',buffer:Buffer.from('x')});
   assert.match(await p.locator('[role=alert]').innerText(),/not read by the app/);
   assert.equal(await read(p),null);
  });
  await run('F1 photo Apply changes chosen fields only; Save is still required; JSON separate',async p=>{
   await addRig(p);await p.locator('[data-field=name]').fill('Demo rig contract');
   await p.locator('[name=library-class][value=dslrMirrorless]').check();
   await p.locator('[data-photo-metadata] > summary').click();await p.locator('[data-photo-example]').click();
   await p.locator('[data-metadata-choice="0"]').uncheck();
   await p.locator('[data-metadata-apply]').click();
   assert.equal(await p.locator('[data-field=manufacturer]').inputValue(),'');
   assert.equal(await p.locator('[data-field=resW]').inputValue(),'6000');assert.equal(await read(p),null);
   await p.getByRole('button',{name:'Save rig',exact:true}).click();
   const stored=JSON.parse(await read(p));
   const record=stored.rigs.find(r=>r.name==='Demo rig contract');
   assert.ok(record);assert.equal(record.manufacturer,null);assert.match(record.provenance.camera,/Example photo walkthrough/);
   await snap(p,'photo-saved');
  });
  await run('R5 denied position is announced locally once and coordinates unchanged',async p=>{
   await p.locator('[data-open-list=sites]').click();await p.locator('[data-add=site]').click();
   await p.locator('[data-field=lat]').fill('50.45');await p.locator('[data-field=lon]').fill('30.52');
   await p.evaluate(()=>Object.defineProperty(navigator,'geolocation',{value:{getCurrentPosition(success,failure){failure({code:1});}},configurable:true}));
   await p.locator('[data-location] > summary').click();await p.locator('[data-request-position]').click();
   assert.equal(await p.locator('[data-field=lat]').inputValue(),'50.45');
   assert.equal(await p.locator('[data-field=lon]').inputValue(),'30.52');
   assert.equal((await p.locator('.android-device').innerText()).match(/Location permission was denied/g).length,1);
   await snap(p,'location-denied');
  });
  await run('F1 real JSON import stays separate, validates, reviews and applies only checked fields',async p=>{
   await addRig(p);await p.locator('[data-metadata] > summary').click();const initial=await draft(p);
   await p.locator('[data-metadata-file]').setInputFiles({name:'invalid.json',mimeType:'application/json',buffer:Buffer.from('{bad')});
   await p.locator('[role=alert]').waitFor();
   assert.match(await p.locator('[role=alert]').innerText(),/not valid JSON/);assert.deepEqual(await draft(p),initial);
   await p.locator('[data-metadata-file]').setInputFiles({name:'values.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify({manufacturer:'Reviewed JSON',resolutionPx:[6000,4000]}))});
   await p.locator('#library-metadata-title').waitFor();
   assert.equal(await p.locator('[data-metadata-choice]').count(),3);assert.deepEqual(await draft(p),initial);
   await p.locator('[data-metadata-choice="0"]').uncheck();await p.locator('[data-metadata-apply]').click();
   assert.equal(await p.locator('[data-field=manufacturer]').inputValue(),'');assert.equal(await p.locator('[data-field=resW]').inputValue(),'6000');
   assert.equal(await read(p),null);
  });
  await run('Claude correction: pending photo review blocks Save; Apply then Save writes checked values',async p=>{
   await validRig(p);const before=await draft(p);
   await p.locator('[data-photo-metadata] > summary').click();await p.locator('[data-photo-example]').click();
   await p.locator('[data-metadata-choice="1"]').check();
   await p.getByRole('button',{name:'Save rig',exact:true}).click();
   assert.equal(await read(p),null);assert.deepEqual(await draft(p),before);
   assert.match(await p.locator('[role=alert]').innerText(),/Apply checked values or Cancel review before Save rig/);
   assert.equal(await p.locator('[data-metadata-apply]').evaluate(e=>e===document.activeElement),true);
   await snap(p,'photo-review-save-blocked');
   await p.locator('[data-metadata-apply]').click();await p.getByRole('button',{name:'Save rig',exact:true}).click();
   const stored=JSON.parse(await read(p));assert.equal(stored.rigs.find(r=>r.name==='Review boundary rig').cameraModel,'Example camera');
  });
  await run('Claude correction: pending JSON review blocks Save; Cancel permits unchanged draft to Save',async p=>{
   await validRig(p);const before=await draft(p);
   await p.locator('[data-metadata] > summary').click();
   await p.locator('[data-metadata-file]').setInputFiles({name:'review.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify({cameraModel:'Not applied'}))});
   await p.locator('#library-metadata-title').waitFor();await p.locator('[data-metadata-choice="0"]').check();
   await p.getByRole('button',{name:'Save rig',exact:true}).click();assert.equal(await read(p),null);assert.deepEqual(await draft(p),before);
   assert.equal(await p.locator('[data-metadata-apply]').evaluate(e=>e===document.activeElement),true);
   await p.locator('[data-metadata-cancel]').click();assert.deepEqual(await draft(p),before);
   await p.getByRole('button',{name:'Save rig',exact:true}).click();
   const stored=JSON.parse(await read(p));assert.equal(stored.rigs.find(r=>r.name==='Review boundary rig').cameraModel,null);
  });
  await run('Claude correction: Sources copy distinguishes photo walkthrough and actual JSON reads',async p=>{
   await p.locator('[data-open-list=rigs]').click();
   const text=await p.locator('.library-view').textContent();
   assert.doesNotMatch(text,/This browser preview reads no files/);assert.match(text,/image bytes are not parsed/);assert.match(text,/JSON is a separate local file-reading workflow/);
  });
  await run('F1 Plan metadata provenance clears after manual field edit and stays clear after Save/reopen',async p=>{
   await p.goto('http://localhost:4173/plan.html?variant=blend');
   await p.locator('[data-edit-block]').first().click();await p.locator('[data-block-photo] > summary').click();
   await p.locator('[data-block-photo-file]').setInputFiles({name:'example.dng',mimeType:'image/x-adobe-dng',buffer:Buffer.from('example only')});
   await p.locator('[data-block-photo-read]').click();await p.locator('[data-block-photo-field=iso]').check();
   await p.locator('[data-block-photo-apply]').click();assert.equal(await p.locator('[name=iso]').inputValue(),'1600');
   await p.getByRole('button',{name:'Apply changes',exact:true}).click();
   await p.getByRole('button',{name:'Save plan',exact:true}).click();
   const imported=await p.evaluate(()=>JSON.parse(localStorage.getItem('culmina-plan-preview-v1')));
   assert.equal((imported.active||imported).blocks[0].metadataSource,'ISO');
   await p.locator('[data-edit-block]').first().click();
   await p.locator('[name=iso]').fill('3200');await p.getByRole('button',{name:'Apply changes',exact:true}).click();
   const block=p.locator('.capture-block').first();
   assert.match(await block.innerText(),/ISO 3200/);assert.doesNotMatch(await block.innerText(),/Example metadata: ISO/);
   const beforeSave=await p.evaluate(()=>JSON.parse(localStorage.getItem('culmina-plan-preview-v1')));
   assert.equal((beforeSave.active||beforeSave).blocks[0].iso,1600);
   await p.getByRole('button',{name:'Save plan',exact:true}).click();
   const stored=await p.evaluate(()=>JSON.parse(localStorage.getItem('culmina-plan-preview-v1')));
   const saved=stored.active||stored;assert.equal(saved.blocks[0].iso,3200);assert.ok(!saved.blocks[0].metadataSource);
   await p.reload();assert.match(await p.locator('.capture-block').first().innerText(),/ISO 3200/);
   assert.doesNotMatch(await p.locator('.capture-block').first().innerText(),/Example metadata: ISO/);
  });
  // Legacy alternatives retain their original read-JSON-only presentation.
  await run('Non-Hybrid Library behavior preserved',async p=>{
   await addRig(p);assert.equal(await p.locator('[data-photo-metadata]').count(),0);
   assert.match(await p.locator('[data-metadata] > summary').innerText(),/Read local metadata/);
  },'paper');
  assert.deepEqual(result.errors,[]);
 }finally{await browser.close();fs.writeFileSync(path.join(out,'checks.json'),JSON.stringify(result,null,2));}
 console.log(JSON.stringify(result));
})().catch(e=>{console.error(e);process.exitCode=1;});
