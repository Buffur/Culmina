async page => {
 const out='C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/design/home-lab/evidence/hybrid-seven-2026-10-20/';
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 const checks=[];
 for(const theme of ['light','dark','field']){
   await page.goto('http://localhost:4173/workspace.html?tab=logbook&variant=blend&scale=2&theme='+theme);
   await page.locator('.logbook-progress').first().waitFor();
   const main=await page.locator('#workspace-main').evaluate(e=>({w:e.clientWidth,sw:e.scrollWidth,text:e.textContent}));
   if(main.sw>main.w+1)throw Error(theme+' horizontal overflow');
   if(!main.text.includes('Sensitivity not recorded: kept separate'))throw Error('Unknown group explanation lost');
   await page.locator('.android-device').screenshot({path:out+'progress-'+theme+'-200.png'});
   checks.push(theme+' 200%: no horizontal overflow, unknown group retained');
 }
 await page.goto('http://localhost:4173/workspace.html?tab=settings&variant=blend&scale=2&theme=light');
 await page.locator('[data-open=backup]').click();
 await page.locator('[data-restore-file]').setInputFiles(out+'settings-reordered.json');
 await page.getByRole('button',{name:'Close',exact:true}).waitFor();
 const boxes=await page.evaluate(()=>{
   const names=['.android-scroll','#workspace-announcement','.android-gesture'];
   return names.map(s=>{const e=document.querySelector(s);if(!e)return {s,missing:true};const r=e.getBoundingClientRect();return {s,top:r.top,bottom:r.bottom,height:r.height};});
 });
 if(boxes[0].bottom>boxes[1].top+1)throw Error('Status overlaps scrolling content');
 await page.locator('.android-device').screenshot({path:out+'settings-identical-200.png'});
 if(errors.length)throw Error(errors.join('\n'));
 return {result:'pass',checks,boxes,pageErrors:errors};
}
