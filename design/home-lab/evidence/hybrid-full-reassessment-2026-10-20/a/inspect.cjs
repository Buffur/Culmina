const {chromium}=require('C:/Users/zalub/AppData/Local/npm-cache/_npx/31e32ef8478fbf80/node_modules/playwright');
const fs=require('fs'),path=require('path');
const out=__dirname;
(async()=>{const browser=await chromium.launch({headless:true,channel:"msedge"});const page=await browser.newPage({viewport:{width:1050,height:1050}});let manifest=[];const roots={home:'index.html?view=wide',plan:'plan.html?',night:'conditions.html?view=night',moon:'conditions.html?view=moon',weather:'conditions.html?view=weather',logbook:'workspace.html?tab=logbook',library:'workspace.html?tab=library',settings:'workspace.html?tab=settings'};
for(const theme of ['light','dark','field'])for(const [name,route]of Object.entries(roots)){await page.goto('http://localhost:4173/'+route+'&variant=blend&theme='+theme);await page.waitForTimeout(250);await page.screenshot({path:path.join(out,name+'-'+theme+'.png')});const text=await page.locator('body').innerText();manifest.push({name,theme,url:page.url(),text});}fs.writeFileSync(path.join(out,'roots.json'),JSON.stringify(manifest,null,2));await browser.close();})();

