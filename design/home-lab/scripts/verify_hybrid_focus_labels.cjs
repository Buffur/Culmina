const {launchChromium}=require('./browser_toolchain.cjs');
const fs=require('node:fs'),path=require('node:path');
const out=path.resolve(__dirname,'../evidence/hybrid-reference-verification-2026-10-20');
(async()=>{const browser=await launchChromium({headless:true}),rows=[];
try{for(const width of [360,412])for(const theme of ['light','dark','field'])for(const scale of ['1','2']){
 const context=await browser.newContext({viewport:{width,height:1050}}),p=await context.newPage();
 await p.goto(`http://127.0.0.1:4173/plan.html?variant=blend&theme=${theme}&scale=${scale}`);await p.locator('[data-edit-block]').first().click();
 const label=p.locator('label').filter({has:p.locator('input[name=focus][value=Unrecorded]')});
 const m=await label.evaluate(e=>{const walker=document.createTreeWalker(e,NodeFilter.SHOW_TEXT);let node;while((node=walker.nextNode()))if(node.textContent.trim()==='Unrecorded')break;const range=document.createRange();range.selectNodeContents(node);const rects=[...range.getClientRects()].map(r=>({x:r.x,y:r.y,width:r.width,height:r.height})),r=e.getBoundingClientRect();return {label:e.innerText,lines:new Set(rects.map(r=>Math.round(r.y))).size,rects,width:r.width,height:r.height,textSize:getComputedStyle(node.parentElement).fontSize,wrap:getComputedStyle(node.parentElement).overflowWrap};});
 rows.push({viewportWidth:width,theme,scale,...m});await context.close();
}}finally{await browser.close();fs.writeFileSync(path.join(out,'focus-labels.json'),JSON.stringify({rows,wordBreaks:rows.filter(x=>x.lines>1)},null,2));console.log(JSON.stringify({cases:rows.length,wordBreaks:rows.filter(x=>x.lines>1).map(({viewportWidth,theme,scale,lines})=>({viewportWidth,theme,scale,lines}))}));}
})();
