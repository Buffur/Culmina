// Verification artifact QA; source/application state is read only.
const {launchChromium}=require('./browser_toolchain.cjs');
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),repo=path.resolve(root,'../..');
const out=path.join(root,'evidence/hybrid-reference-verification-2026-10-20');
const reportFile=path.join(repo,'docs/design/HYBRID_REFERENCE_VERIFICATION_2026_10_20.md');
const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
fs.copyFileSync(reportFile,path.join(out,'report.md'));
(async()=>{const browser=await launchChromium({headless:true});const errors=[],rows=[];
try{const p=await browser.newPage({viewport:{width:1100,height:1000}});p.on('pageerror',e=>errors.push(e.message));p.on('response',r=>{if(r.status()>=400)errors.push(`${r.status()} ${r.url()}`);});
 await p.goto('http://127.0.0.1:4173/evidence/hybrid-reference-verification-2026-10-20/comparison.html');
 for(const theme of ['dark','light','field'])for(const scale of ['1','2']){
  await p.selectOption('#theme',theme);await p.selectOption('#scale',scale);
  const images=await p.locator('img').evaluateAll(async es=>Promise.all(es.map(async e=>{const probe=new Image();probe.src=e.src;await probe.decode();return {src:e.getAttribute('src'),width:probe.naturalWidth,height:probe.naturalHeight};})));
  rows.push({theme,scale,articles:await p.locator('main article').count(),images:images.length,loaded:images.every(x=>x.width>0&&x.height>0)});
 }
 await p.screenshot({path:path.join(out,'gallery-overview.png'),fullPage:false});
}finally{await browser.close();}
 const prior=JSON.parse(fs.readFileSync(path.join(root,'evidence/hybrid-refinement-2026-10-20/final-verification.json')));
 const captures=JSON.parse(fs.readFileSync(path.join(out,'checks.json'))),focus=JSON.parse(fs.readFileSync(path.join(out,'focus-labels.json'))),scrollers=JSON.parse(fs.readFileSync(path.join(out,'scrollers.json')));
 const sources=Object.entries(prior.latestSourceHashes).map(([file,expected])=>({file,expected,current:hash(path.join(root,file)),match:expected===hash(path.join(root,file))}));
 const payload={status:'PARTIAL_V3_V5_RV01',applicationCodeChanged:false,sourcesMatchPreviousFinal:sources.every(x=>x.match),sources,captures:captures.captures.length,pageErrors:captures.errors,focusChecks:focus.rows.length,focusWordBreaks:focus.wordBreaks.length,scrollerChecks:scrollers.rows.length,scrollersPass:scrollers.rows.every(x=>x.keyboardScroll&&x.afterEnd.remaining===0&&(x.kind!=='gain'||x.reachedByTab)),gallery:{rows,errors},priorReport:{originalSHA256:prior.reportSHA256,preservedCopySHA256:hash(path.join(out,'prior-report-before-reference-verification.md')),amendedSHA256:hash(path.join(repo,'docs/design/HYBRID_REFINEMENT_2026_10_20.md'))},newReportSHA256:hash(reportFile),artifacts:{}};
 for(const name of fs.readdirSync(out))if(fs.statSync(path.join(out,name)).isFile()&&name!=='verification.json')payload.artifacts[name]=hash(path.join(out,name));
 fs.writeFileSync(path.join(out,'verification.json'),JSON.stringify(payload,null,2));
 console.log(JSON.stringify({status:payload.status,sources:sources.length,sourcesMatchPreviousFinal:payload.sourcesMatchPreviousFinal,captures:payload.captures,focusChecks:payload.focusChecks,focusWordBreaks:payload.focusWordBreaks,scrollerChecks:payload.scrollerChecks,scrollersPass:payload.scrollersPass,gallery:payload.gallery,priorReportPreserved:payload.priorReport.originalSHA256===payload.priorReport.preservedCopySHA256}));
 if(errors.length||!payload.sourcesMatchPreviousFinal||!payload.scrollersPass||rows.some(x=>!x.loaded||x.articles!==9))process.exitCode=1;
})();
