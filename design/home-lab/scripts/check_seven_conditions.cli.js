// Run with playwright-cli -s=<isolated-session> run-code --filename <this file>.
// Browser-only Hybrid presentation checks. No owner profile or storage is used.
async (page) => {
 const results=[],errors=[];
 page.on('pageerror',error=>errors.push(error.message));
 await page.setViewportSize({width:412,height:915});
 await page.addInitScript(()=>{Date.now=()=>Date.parse('2026-10-19T16:00:00Z');});
 const base='http://localhost:4173/conditions.html?variant=blend';
 const evidence='C:/Users/zalub/OneDrive/Desktop/Astro Planner/Astro-Planner/design/home-lab/evidence/hybrid-seven-2026-10-20/';
 const check=(ok,message)=>{if(!ok)throw Error(message);};
 const go=async(query)=>{await page.goto(base+query);await page.locator('#viewed-night').waitFor();};
 const read=()=>page.locator('.weather-answer').innerText();
 for(const [scenario,expected] of [
  ['ready','Coverage: 7/7 hourly samples in dark time'],
  ['stale','Stale snapshot'],
  ['partial','Forecast gaps remain unknown'],
  ['offline','Offline · cached example; no refresh request was sent'],
  ['unknown','Forecast unavailable'],
  ['error','Couldn’t load forecast'],
  ['loading','Loading'],
  ['missing-variable','cloud values known'],
  ['no-dark','No dark hours to summarize']
 ]){
  await go(`&view=weather&scenario=${scenario}&theme=light&scale=1`);
  const text=await read();
  check(text.includes(expected),scenario+': expected '+expected);
  check(!text.includes('Full dark-time coverage'),scenario+': misleading coverage label');
  if(scenario==='stale')check((text.match(/Stale snapshot/g)||[]).length===1,'stale warning must occur once');
  if(['unknown','error','loading','no-dark'].includes(scenario))check(!/Stale snapshot|Aging snapshot/.test(text),'unavailable weather must not claim a retained forecast');
  if(scenario==='offline')check((text.match(/Aging snapshot/g)||[]).length===1,'offline aging warning must occur once');
  if(scenario==='unknown')check(!text.includes('0%'),'unknown must not become zero');
  check(await page.locator('#viewed-night').innerText()==='Night of 19 Oct','evening identity');
  check(await page.locator('.night-end').innerText()==='Ends 20 Oct','morning identity');
  check(await page.locator('.view-context').innerText().then(t=>t.includes('Europe/Kyiv')),'zone preserved');
  results.push(scenario+': coverage/status/unknown/date semantics');
 }
 await go('&view=weather&scenario=stale&theme=light&scale=1');
 await page.locator('.android-device').screenshot({path:evidence+'conditions-weather-stale.png'});
 for(const theme of ['light','dark','field']){
  await go(`&view=weather&scenario=stale&theme=${theme}&scale=2`);
  check(await page.locator('.android-scroll').evaluate(e=>e.scrollWidth<=e.clientWidth+1),'200% horizontal overflow '+theme);
  await page.locator('.android-device').screenshot({path:evidence+`conditions-weather-${theme}-200.png`});
  results.push(theme+': 200% no horizontal overflow');
 }
 await go('&view=night&scenario=dst&night=2026-10-24&theme=light&scale=1');
 check(await page.locator('#viewed-night').innerText()==='Night of 24 Oct','DST evening date');
 check(await page.locator('.night-end').innerText()==='Ends 25 Oct','DST morning date');
 check(await page.locator('.night-answer').innerText().then(t=>t.includes('(+1)')),'rollover indicator preserved');
 await page.locator('[data-step="1"]').click();
 check(await page.locator('#viewed-night').innerText()==='Night of 25 Oct','next-night navigation');
 await page.reload();
 check(await page.locator('#viewed-night').innerText()==='Night of 25 Oct','URL reload retention');
 const storage=await page.evaluate(()=>[localStorage.getItem('culmina-plan-preview-v1'),localStorage.getItem('culmina-plan-navigation-v1')]);
 check(storage.every(v=>v===null),'browsing wrote plan/draft storage');
 results.push('DST dates, (+1), next-night/reload, no plan or draft write');
 await go('&view=night&night=2026-10-31&theme=light&scale=1');
 check(await page.locator('.night-end').innerText()==='Ends 1 Nov','cross-month end date');
 await page.locator('.android-device').screenshot({path:evidence+'conditions-night-month-end.png'});
 results.push('cross-month calendar label');
 await page.goto('http://localhost:4173/conditions.html?variant=paper&view=weather&scenario=ready');
 await page.locator('#viewed-night').waitFor();
 check(await page.locator('#viewed-night').innerText()==='19 Oct–20','nonHybrid date changed');
 check(await read().then(t=>t.includes('Full dark-time coverage')),'nonHybrid weather changed');
 check(await page.locator('.night-end').count()===0,'nonHybrid end label added');
 check(errors.length===0,'page errors: '+errors.join('; '));
 results.push('Paper comparison retains original date/weather presentation');
 return {cases:results,pageErrors:errors};
}
