async page => {
 const out='C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/design/home-lab/evidence/hybrid-seven-2026-10-20/';
 await page.setViewportSize({width:412,height:1000});
 if(!(await page.locator('.logbook-progress').count()))await page.getByRole('button',{name:'Progress by target Integration so far, from your results'}).click();
 const hybrid=await page.locator('.logbook-progress').allTextContents();
 if(hybrid.some(text=>text.includes('Recorded integration')))throw Error('Repeated integration label retained');
 const groups=await page.locator('.logbook-groups').allTextContents();
 if(!(await page.locator('.logbook-progress-guide').count()))throw Error('Missing disclosure');
 if(await page.locator('.logbook-progress-guide').getAttribute('open')!==null)throw Error('Guide should start closed');
 const first=await page.locator('.logbook-progress').first().boundingBox();
 const scroll=await page.locator('.android-scroll').boundingBox();
 if(first.y>=scroll.y+scroll.height)throw Error('Target not visible in first viewport');
 await page.locator('.android-device').screenshot({path:out+'progress-200.png'});
 await page.locator('.logbook-progress-guide summary').click();
 if(!(await page.locator('.logbook-progress-guide').innerText()).includes('exposure, sensitivity, binning and rig all match'))throw Error('Missing compatible semantics');
 await page.goto('http://localhost:4173/workspace.html?tab=logbook&variant=paper&scale=2');
 if(!(await page.locator('.logbook-progress').count()))await page.getByRole('button',{name:'Progress by target Integration so far, from your results'}).click();
 if(await page.locator('.logbook-progress-guide').count())throw Error('NonHybrid changed');
 const originalGroups=await page.locator('.logbook-groups').allTextContents();
 if(JSON.stringify(groups)!==JSON.stringify(originalGroups))throw Error('Data groups changed');
 await page.goto('http://localhost:4173/workspace.html?tab=settings&variant=blend&scale=2');
 await page.locator('[data-open=backup]').click();
 const download=page.waitForEvent('download');
 await page.locator('[data-export]').click();
 await (await download).saveAs(out+'settings-original.json');
 return {progress:'pass',unchangedGroups:groups.length,firstTargetTop:first.y,scrollBottom:scroll.y+scroll.height,hybridSummary:hybrid[0].trim().slice(0,180)};
}
