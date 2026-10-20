// Bounded follow-up for the enlarged charts; no application or owner storage changes.
const {launchChromium}=require('./browser_toolchain.cjs');
const fs=require('node:fs'),path=require('node:path');
const out=path.resolve(__dirname,'../evidence/hybrid-reference-verification-2026-10-20');
(async()=>{const browser=await launchChromium({headless:true}),rows=[];
try{for(const theme of ['dark','light','field'])for(const kind of ['gain','weather']){
 const context=await browser.newContext({viewport:{width:412,height:1050}}),p=await context.newPage();
 await p.goto(`http://127.0.0.1:4173/${kind==='gain'?'plan.html':'conditions.html?view=weather'}${kind==='gain'?'?':'&'}variant=blend&theme=${theme}&scale=2`);
 if(kind==='gain'){await p.locator('.plan-rows').waitFor();await p.locator('[data-disclosure=gain]>summary').click();}
 const locator=p.locator(kind==='gain'?'.gain-plot-scroll':'.hourly-scroll').first();
 await locator.scrollIntoViewIfNeeded();
 let reachedByTab=null;
 if(kind==='gain'){
  await p.locator('[data-disclosure=gain]>summary').focus();
  for(let i=0;i<12;i++){await p.keyboard.press('Tab');if(await locator.evaluate(e=>document.activeElement===e)){reachedByTab=true;break;}}
  reachedByTab??=false;
 }else await locator.focus();
 const before=await locator.evaluate(e=>({clientWidth:e.clientWidth,scrollWidth:e.scrollWidth,scrollLeft:e.scrollLeft,overflowX:getComputedStyle(e).overflowX,focused:document.activeElement===e,tabIndex:e.tabIndex,ariaLabel:e.getAttribute('aria-label'),svgLabels:[...e.querySelectorAll('svg')].map(x=>x.getAttribute('aria-label'))}));
 await p.keyboard.press('ArrowRight');await p.waitForTimeout(300);
 const afterArrow=await locator.evaluate(e=>e.scrollLeft);
 await locator.evaluate(e=>{e.scrollLeft=e.scrollWidth;});
 const afterEnd=await locator.evaluate(e=>({scrollLeft:e.scrollLeft,remaining:e.scrollWidth-e.clientWidth-e.scrollLeft}));
 const file=`current/${kind}-right-${theme}-2.png`;await locator.screenshot({path:path.join(out,file)});
 rows.push({kind,theme,scale:2,viewportWidth:412,reachedByTab,before,afterArrow,afterEnd,file,keyboardScroll:afterArrow>before.scrollLeft,visibleHint:kind==='weather'?await p.locator('.hourly-section>.quiet-copy').first().innerText():await p.locator('.gain-panel').first().innerText()});
 await context.close();
}}finally{await browser.close();fs.writeFileSync(path.join(out,'scrollers.json'),JSON.stringify({rows},null,2));console.log(JSON.stringify(rows.map(({kind,theme,reachedByTab,before,afterArrow,afterEnd,keyboardScroll})=>({kind,theme,reachedByTab,before,afterArrow,afterEnd,keyboardScroll}))));}
})();
