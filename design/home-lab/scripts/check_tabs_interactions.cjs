// Browser contract checks. All writes use a fresh localhost profile, never the owner's origin.
const {launchChromium}=require('./browser_toolchain.cjs');
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const out=process.env.CULMINA_EVIDENCE?path.resolve(process.env.CULMINA_EVIDENCE):path.resolve(__dirname,'../evidence/tabs-2026-10-20');fs.mkdirSync(out,{recursive:true});
const evidence={cases:[],screens:[],errors:[],resources:[]};
const keys={logbook:'culmina-logbook-preview-v1',library:'culmina-library-preview-v1',settings:'culmina-settings-preview-v1'};
const report=(name,detail={})=>{evidence.cases.push({name,passed:true,...detail});};
(async()=>{
 const browser=await launchChromium({headless:true});
 const context=await browser.newContext({viewport:{width:412,height:915},acceptDownloads:true});
 // open() requests a root visit, while explicit reload/Back keeps the real
 // navigation context. Clear on the next document, after pagehide remembered it.
 await context.addInitScript(()=>{
  if(sessionStorage.getItem('culmina-test-reset-navigation')==='1'){
   for(const key of ['culmina-logbook-context-v1','culmina-library-navigation-v1'])sessionStorage.removeItem(key);
   sessionStorage.removeItem('culmina-test-reset-navigation');
  }
 });
 const p=await context.newPage();p.on('pageerror',e=>evidence.errors.push(String(e)));
 p.on('requestfailed',r=>evidence.resources.push({url:r.url(),failure:r.failure()}));
 p.on('response',r=>{if(r.status()>=400)evidence.resources.push({url:r.url(),status:r.status()});});
 const title=async text=>p.waitForFunction(t=>document.querySelector('#workspace-title')?.textContent===t,text);
 const open=async(tab,scenario='ready')=>{if(p.url().startsWith('http://localhost:4173/'))await p.evaluate(()=>sessionStorage.setItem('culmina-test-reset-navigation','1'));await p.goto(`http://localhost:4173/workspace.html?variant=blend&tab=${tab}&scenario=${scenario}`);await p.waitForSelector(`.${tab}-view`);};
 const back=async()=>{await p.locator('#workspace-back').click();};
 const read=async tab=>p.evaluate(key=>JSON.parse(localStorage.getItem(key)),keys[tab]);
 const snap=async name=>{await p.locator('.android-device').screenshot({path:path.join(out,name+'.png')});evidence.screens.push(name+'.png');};
 const snapshotText=async()=>{const snapshot=p.locator('[aria-labelledby=logbook-snapshot]');if(await snapshot.evaluate(e=>e.tagName==='DETAILS'&&!e.open))await snapshot.locator('summary').click();return snapshot.innerText();};
 const layout=async(name)=>{
  const r=await p.locator('#workspace-main').evaluate(e=>({overflow:e.scrollWidth>e.clientWidth+1,small:[...e.querySelectorAll('button,input:not([type=radio]):not([type=checkbox]),select')].filter(n=>n.getClientRects().length).map(n=>({name:n.getAttribute('aria-label')||n.textContent.trim().slice(0,40),w:n.getBoundingClientRect().width,h:n.getBoundingClientRect().height})).filter(n=>n.w<47.5||n.h<47.5)}));
  assert.equal(r.overflow,false,name+' overflow');assert.deepEqual(r.small,[],name+' targets');
 };
 try{
  await open('logbook');
  await p.evaluate(()=>{localStorage.setItem('culmina-plan-preview-v1','PLAN_CHECKPOINT_UNTOUCHED');localStorage.setItem('culmina-plan-navigation-v1','DRAFT_CHECKPOINT_UNTOUCHED');});
  await p.locator('[data-search]').fill('M31');assert.equal(await p.locator('[data-open-entry]').count(),2);
  await p.locator('[data-search]').fill('no matching example');assert.equal(await p.locator('[data-open-entry]').count(),0);
  await p.locator('[data-search]').fill('');await p.locator('[data-filters] summary').click();
  await p.locator('[data-filter=target]').selectOption({label:'M31'});assert.equal(await p.locator('[data-open-entry]').count(),2);
  await p.locator('[data-clear-filters]').click();report('Logbook stable search, no results and target filter');
  await p.locator('[data-open-entry="example-m31-2026-10-12"]').click();
  const detailTitle=await p.locator('#workspace-title').textContent(),snapshot=await snapshotText();
  await p.locator('[data-result-entry]').click();await title('How did it go?');
  await p.locator('[name=logbook-outcome][value=partly]').check();
  await p.locator('[data-count]').first().fill('-1');await p.getByRole('button',{name:'Save result',exact:true}).click();
  assert.ok(await p.locator('[aria-invalid=true]').count());assert.equal(await read('logbook'),null);
  await p.locator('[data-count]').first().fill('42');await p.locator('[data-note=environmentalNotes]').fill('Browser verification note');
  await p.getByRole('button',{name:'Save result',exact:true}).click();await p.waitForSelector('[aria-labelledby=logbook-snapshot]');
  assert.equal(await snapshotText(),snapshot);
  let stored=await read('logbook');assert.equal(stored.entries.find(x=>x.id==='example-m31-2026-10-12').result.environmentalNotes,'Browser verification note');
  const plans=Object.fromEntries(stored.entries.map(x=>[x.id,JSON.stringify(x.plan)]));
  await snap('logbook-detail');await p.reload();await p.waitForSelector('.logbook-view');
  assert.equal(await p.locator('#workspace-title').textContent(),detailTitle,'reload retains the same Logbook detail');
  assert.equal(await snapshotText(),snapshot,'reload retains the complete saved snapshot');
  stored=await read('logbook');assert.equal(stored.entries.find(x=>x.id==='example-m31-2026-10-12').result.environmentalNotes,'Browser verification note');
  report('Logbook validation, result Save/reload continuity and immutable full plan snapshot');
  await back();await title('Logbook');
  await p.locator('[data-open-entry="example-m31-2026-10-12"]').click();await p.locator('[data-result-entry]').click();
  await p.locator('[data-note=processingNotes]').fill('Do not save this');
  await p.goBack();await p.waitForSelector('dialog[open]');await p.locator('dialog [data-dialog=cancel]').click();await title('How did it go?');
  assert.equal(await p.locator('[data-note=processingNotes]').inputValue(),'Do not save this');
  await p.locator('[data-cancel-edit]').click();await p.locator('dialog [data-dialog=ok]').click();await p.waitForSelector('[data-delete-entry]');
  assert.equal((await read('logbook')).entries.find(x=>x.id==='example-m31-2026-10-12').result.processingNotes,null);
  await p.locator('[data-delete-entry]').click();await p.locator('dialog [data-dialog=ok]').click();await title('Logbook');assert.equal((await read('logbook')).entries.length,5);
  await p.locator('[data-undo]').click();assert.equal((await read('logbook')).entries.length,6);
  for(const x of (await read('logbook')).entries)assert.equal(JSON.stringify(x.plan),plans[x.id]);
  await p.locator('[data-open-progress]').click();await title('Progress by target');assert.match(await p.locator('#workspace-main').innerText(),/Sensitivity not recorded/);await layout('Logbook progress');await snap('logbook-progress');
  report('Logbook browser Back/Cancel guard, delete/Undo and progress groups');

  await open('library');await p.locator('[data-open-list=targets]').click();await title('Targets');
  await p.locator('[data-search]').fill('NGC 224');assert.equal(await p.locator('[data-open^="catalogue:"]').count(),1);
  await p.locator('[data-open^="catalogue:"]').click();assert.match(await p.locator('#workspace-main').innerText(),/Bundled catalogue/);assert.equal(await p.locator('[data-edit]').count(),0);await back();await title('Targets');
  await p.locator('[data-search]').fill('');await p.locator('[data-add=target]').click();await title('Add target');
  await p.locator('[data-field=name]').fill('Browser test target');await p.locator('[data-field=ra]').fill('25');await p.locator('[data-field=dec]').fill('91');
  await p.getByRole('button',{name:'Save target',exact:true}).click();assert.ok(await p.locator('[aria-invalid=true]').count());assert.equal(await read('library'),null);
  await p.locator('[data-field=ra]').fill('05h35m17s');await p.locator('[data-field=dec]').fill('-5.39');await p.getByRole('button',{name:'Save target',exact:true}).click();
  let lib=await read('library');assert.equal(lib.targets.length,1);const custom=lib.targets[0];assert.ok(Math.abs(custom.raDeg-83.8208333333)<1e-6);assert.equal(custom.decDeg,-5.39);
  await p.locator('[data-edit]').click();await p.locator('[data-field=name]').fill('Renamed test target');await p.getByRole('button',{name:'Save target',exact:true}).click();
  assert.equal((await read('library')).targets[0].name,'Renamed test target');
  await p.locator('[data-delete]').click();await p.locator('dialog [data-dialog=ok]').click();await p.waitForSelector('[data-undo]');assert.equal((await read('library')).targets.length,0);
  await p.locator('[data-undo]').click();assert.equal((await read('library')).targets.length,1);report('Library bundled alias search/read-only and custom target validation/Add/Edit/Delete/Undo');
  await back();await title('Library');await p.locator('[data-open-list=sites]').click();await p.locator('[data-add=site]').click();
  await p.locator('[data-field=name]').fill('Verification site');await p.locator('[data-field=lat]').fill('91');await p.locator('[data-field=lon]').fill('30.5');await p.getByRole('button',{name:'Save site',exact:true}).click();assert.ok(await p.locator('[aria-invalid=true]').count());
  await p.locator('[data-field=lat]').fill('50.5');await p.locator('[data-field=zone]').selectOption('Europe/Kyiv');await p.getByRole('button',{name:'Save site',exact:true}).click();
  assert.equal((await read('library')).sites.at(-1).latDeg,50.5);await p.reload();await p.waitForSelector('.library-view');
  await title('Verification site');assert.match(await p.locator('#workspace-main').innerText(),/50\.50000/);
  await back();await title('Sites');await back();await title('Library');
  await p.locator('[data-open-list=rigs]').click();await p.locator('[data-open="rig:example-rig-dslr"]').click();assert.match(await p.locator('#workspace-main').innerText(),/Not recorded/i);await snap('library-rig');
  await back();await title('Rigs');await p.locator('[data-add=rig]').click();await layout('Add rig');await snap('library-rig-editor');
  await p.locator('[data-cancel-edit]').click();await title('Rigs');
  await p.locator('[data-add=rig]').click();await p.locator('[data-field=name]').fill('Verification camera and lens');await p.locator('[name=library-class][value=dslrMirrorless]').check();
  for(const[field,value]of Object.entries({resW:'6000',resH:'4000',pixel:'4',focal:'135',ratio:'2.8'}))await p.locator(`[data-field=${field}]`).fill(value);
  await p.getByRole('button',{name:'Save rig',exact:true}).click();assert.equal((await read('library')).rigs.at(-1).focalLengthMm,135);assert.deepEqual((await read('library')).rigs.at(-1).sensorMm,[24,16]);
  report('Library site bounds/zone/reload, recorded rig details, editor Cancel and new rig sensor derivation/Save');

  await open('settings');await p.locator('[data-open=planning]').click();await title('Planning');
  await p.locator('[data-plan=minAltitudeDeg]').fill('25');await p.locator('[data-plan=minAltitudeDeg]').dispatchEvent('input');
  await p.locator('#settings-save-planning').click();await title('Settings');assert.equal((await read('settings')).settings.planning.minAltitudeDeg,25);
  await p.locator('[data-open=planning]').click();await p.locator('[data-plan=minAltitudeDeg]').fill('30');await p.locator('[data-plan=minAltitudeDeg]').dispatchEvent('input');
  await p.locator('#settings-cancel-planning').click();await p.locator('dialog [data-dialog=ok]').click();await title('Settings');assert.equal((await read('settings')).settings.planning.minAltitudeDeg,25);
  await p.locator('[data-open=appearance]').click();await p.locator('#settings-theme-dark').check();assert.equal(await p.locator('html').getAttribute('data-theme'),'dark');
  await p.locator('#settings-field').check();assert.equal(await p.locator('html').getAttribute('data-theme'),'field');await p.locator('#settings-field').uncheck();assert.equal(await p.locator('html').getAttribute('data-theme'),'dark');
  await p.locator('#settings-scale-2').check();await layout('Appearance 200%');await snap('settings-appearance-200');await p.locator('#settings-scale-1').check();
  await back();await title('Settings');await p.locator('[data-open=privacy]').click();await p.locator('[data-place-names]').check();assert.equal((await read('settings')).settings.privacy.placeNameLookup,true);
  await back();await title('Settings');await p.locator('[data-open=backup]').click();
  const downloadWait=p.waitForEvent('download');await p.locator('[data-export]').click();const dl=await downloadWait;const downloaded=await dl.path();const backup=JSON.parse(fs.readFileSync(downloaded,'utf8'));assert.equal(backup.kind,'culmina-settings-preview-backup');
  const before=JSON.stringify(await read('settings'));
  await p.locator('[data-restore-file]').setInputFiles({name:'bad.json',mimeType:'application/json',buffer:Buffer.from('{"not":"a backup"}')});await p.waitForSelector('#settings-restore-error');assert.equal(JSON.stringify(await read('settings')),before);
  backup.settings.planning.minAltitudeDeg=35;
  await p.locator('[data-restore-file]').setInputFiles({name:'good.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(backup))});await title('Restore settings');
  assert.equal(JSON.stringify(await read('settings')),before);await p.locator('[data-restore-apply]').click();await title('Backup & data');assert.equal((await read('settings')).settings.planning.minAltitudeDeg,35);await layout('Backup & data');
  report('Settings planning Save/Cancel, live appearance/field/text, privacy, JSON export, rejected restore and confirmed restore');
  await back();await title('Settings');await p.locator('[data-open=planning]').click();await p.locator('#workspace-scale').selectOption('2');await p.locator('[data-advanced] summary').click();await layout('Planning advanced 200%');await snap('settings-planning-200');

  for(const tab of ['logbook','library','settings']){
   const key=keys[tab];await p.evaluate(k=>localStorage.setItem(k,'MALFORMED_KEEP_ME'),key);await open(tab);
   assert.match(await p.locator('#workspace-main').innerText(),/can't be read|cannot be read/i);assert.equal(await p.evaluate(k=>localStorage.getItem(k),key),'MALFORMED_KEEP_ME');
   await p.evaluate(k=>localStorage.removeItem(k),key);
  }
  report('All three malformed stores are reported and preserved');
  await open('logbook','storage-error');await p.locator('[data-result-entry="example-m33-2026-10-15"]').click();await p.locator('[name=logbook-outcome][value=asPlanned]').check();await p.getByRole('button',{name:'Save result',exact:true}).click();
  assert.equal(await read('logbook'),null);assert.match(await p.locator('.workspace-error').innerText(),/storage failure/);await p.locator('[data-retry-save]').click();await title('Logbook');assert.ok(await read('logbook'));
  await open('library','storage-error');await p.locator('[data-open-list=targets]').click();await p.locator('[data-add=target]').click();for(const[f,v]of Object.entries({name:'Retry target',ra:'1',dec:'1'}))await p.locator(`[data-field=${f}]`).fill(v);
  await p.getByRole('button',{name:'Save target',exact:true}).click();assert.equal(await read('library'),null);assert.equal(await p.locator('[data-field=name]').inputValue(),'Retry target');await p.locator('[data-retry-save]').click();assert.equal((await read('library')).targets.length,1);
  await open('settings','storage-error');await p.locator('[data-open=planning]').click();await p.locator('[data-plan=minAltitudeDeg]').fill('30');await p.locator('[data-plan=minAltitudeDeg]').dispatchEvent('input');await p.locator('#settings-save-planning').click();assert.equal(await read('settings'),null);await p.locator('[data-retry-planning]').click();await title('Settings');assert.equal((await read('settings')).settings.planning.minAltitudeDeg,30);
  report('All three simulated failed saves keep edits and storage unchanged; explicit Retry succeeds');
  assert.deepEqual(await p.evaluate(()=>[localStorage.getItem('culmina-plan-preview-v1'),localStorage.getItem('culmina-plan-navigation-v1')]),['PLAN_CHECKPOINT_UNTOUCHED','DRAFT_CHECKPOINT_UNTOUCHED']);
  report('Plan and navigation checkpoint keys unchanged by all tab operations');
  const blocked=await browser.newContext();await blocked.addInitScript(()=>{Storage.prototype.getItem=function(){throw new DOMException('Storage blocked','SecurityError');};Storage.prototype.setItem=function(){throw new DOMException('Storage blocked','SecurityError');};});
  const blockedPage=await blocked.newPage();for(const tab of Object.keys(keys)){await blockedPage.goto(`http://localhost:4173/workspace.html?tab=${tab}`);await blockedPage.waitForSelector(`.${tab}-view`);assert.match(await blockedPage.locator('#workspace-main').innerText(),/storage is unavailable/i);}await blocked.close();
  report('All tabs mount and report browser storage denial');
  const unavailable=await context.newPage();await unavailable.route('**/tokens.json',r=>r.fulfill({status:503,body:'Unavailable'}));await unavailable.goto('http://localhost:4173/workspace.html');await unavailable.waitForSelector('#reload-preview');assert.match(await unavailable.locator('#workspace-main').innerText(),/Could not load the preview/);await unavailable.close();
  report('Missing token resource shows a visible Retry, without touching records');
  assert.deepEqual(evidence.errors,[]);
  console.log(JSON.stringify({cases:evidence.cases.length,errors:evidence.errors},null,2));
 }catch(error){evidence.failure={message:String(error),url:p.url(),body:await p.locator('body').innerText().catch(()=>'<unavailable>')};throw error;}finally{fs.writeFileSync(path.join(out,'interactions.json'),JSON.stringify(evidence,null,2));await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
