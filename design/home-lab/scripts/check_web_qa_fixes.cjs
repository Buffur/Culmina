// WQA-01…WQA-06 targeted regressions for the Hybrid web reference (QA of 2026-10-22).
// Fresh isolated Chromium contexts and demonstration data only; never an owner's profile.
// Studio 1200 CSS px with the phone itself set to 375/412 CSS px (DOMRect-checked), zoom 1, text 1.
// CULMINA_QA_PHASE=before records the reproduction without failing; the default (after) asserts.
const {launchChromium}=require('./browser_toolchain.cjs');
const fs=require('node:fs'),path=require('node:path');
const base=process.env.CULMINA_PREVIEW_URL||'http://127.0.0.1:4173/';
const phase=process.env.CULMINA_QA_PHASE==='before'?'before':'after';
const out=process.env.CULMINA_EVIDENCE||path.resolve(__dirname,'../evidence/qa-fixes-2026-10-22');
fs.mkdirSync(out,{recursive:true});
const report={phase,base,studio:{width:1200,height:1000},results:{},errors:[]};
const result=id=>report.results[id]||={pass:true,failures:[],cases:[]};
function expect(id,ok,message,data){const r=result(id);r.cases.push({ok:!!ok,message,...(data===undefined?{}:{data})});if(!ok){r.pass=false;r.failures.push(message);}}
const settle=p=>p.waitForTimeout(260); // Hybrid colour transitions are 120 ms.

async function session(browser,{viewport={width:1200,height:1000}}={}){
  const ctx=await browser.newContext({viewport,deviceScaleFactor:1}),p=await ctx.newPage();
  p.setDefaultTimeout(6000);p.on('pageerror',e=>report.errors.push(String(e)));
  let width=null;
  const phone=()=>p.locator('.android-device,.concept.variant-blend .app-frame').first();
  const fit=async(w=width)=>{width=w;if(w)await phone().evaluate((e,w)=>{e.style.width=w+'px';e.style.maxWidth=w+'px';e.style.flexShrink='0';},w);};
  const go=async(file,query={},w=width)=>{
    await p.goto(base+file+'?'+new URLSearchParams({variant:'blend',font:'native',theme:'light',scale:'1',...query}));
    await p.evaluate(()=>document.fonts.ready);await p.addStyleTag({content:'html{scroll-behavior:auto!important}'});
    await phone().waitFor();await fit(w);await p.waitForTimeout(80);
  };
  const phoneRect=()=>phone().evaluate(e=>{const r=e.getBoundingClientRect();return {left:r.left,right:r.right,top:r.top,bottom:r.bottom,width:r.width,height:r.height};});
  return {ctx,p,go,fit,phone,phoneRect};
}

// Effective colours after every ancestor's opacity and brightness filter (WCAG 2.2 relative luminance).
function measureAction(e){
  const parse=s=>{const n=s.match(/[\d.]+/g)?.map(Number);return n?.length>=3?[...n.slice(0,3),n[3]??1]:[0,0,0,0];};
  const over=(a,b)=>[0,1,2].map(i=>a[i]*a[3]+b[i]*(1-a[3])).concat(1);
  const lum=a=>{const c=a.slice(0,3).map(v=>{v/=255;return v<=.04045?v/12.92:((v+.055)/1.055)**2.4;});return .2126*c[0]+.7152*c[1]+.0722*c[2];};
  const chain=[];for(let a=e;a;a=a.parentElement)chain.unshift(a);
  let bg=[255,255,255,1],opacity=1,brightness=1,otherFilter=false;
  for(const a of chain){const cs=getComputedStyle(a);bg=over(parse(cs.backgroundColor),bg);opacity*=Number(cs.opacity);
    for(const m of cs.filter.matchAll(/brightness\(([\d.]+)\)/g))brightness*=Number(m[1]);
    if(/(contrast|invert|grayscale|saturate|sepia|hue-rotate|opacity)\(/.test(cs.filter))otherFilter=true;}
  const cs=getComputedStyle(e),fgRaw=over(parse(cs.color),bg);
  const dim=c=>c.slice(0,3).map(v=>Math.min(255,v*brightness)).concat(1);
  const fg=dim(fgRaw),back=dim(bg);
  const ratio=(Math.max(lum(fg),lum(back))+.05)/(Math.min(lum(fg),lum(back))+.05);
  return {text:e.textContent.trim(),fg:cs.color,bg:getComputedStyle(e).backgroundColor,effectiveFg:fg.slice(0,3).map(Math.round),effectiveBg:back.slice(0,3).map(Math.round),opacity,brightness,filter:cs.filter,otherFilter,fontSize:cs.fontSize,fontWeight:cs.fontWeight,disabled:e.disabled===true,ratio:Number(ratio.toFixed(4))};
}
const redBlack=c=>c[1]===0&&c[2]===0;
async function actionStates(id,s,locator,label,away=null){
  const {p}=s,rest=async()=>{if(away){const b=await away.boundingBox();await p.mouse.move(b.x+4,b.y+4);}else await p.mouse.move(2,2);};
  await locator.scrollIntoViewIfNeeded();await rest();await settle(p);
  const states={default:await locator.evaluate(measureAction)};
  await locator.hover();await settle(p);states.hover=await locator.evaluate(measureAction);
  await p.mouse.down();await settle(p);states.pressed=await locator.evaluate(measureAction);
  await rest();await p.mouse.up();await settle(p); // Released away from the control: no activation.
  for(const [state,m] of Object.entries(states)){
    expect(id,m.ratio>=4.5&&m.opacity===1&&!m.otherFilter,`${label} ${state}: ${m.ratio}:1 >= 4.5`,m);
    expect(id,!m.disabled,`${label} ${state}: control stays enabled`);
    expect(id,redBlack(m.effectiveFg)&&redBlack(m.effectiveBg),`${label} ${state}: red/black only`);
  }
  return states;
}
// Raster check of a rendered control: in Field every pixel must be red or black (G and B channels ~0).
async function raster(p,locator,name){
  const file=path.join(out,`${phase}-${name}.png`);const buf=await locator.screenshot({path:file});
  return p.evaluate(async b64=>{const img=new Image();img.src='data:image/png;base64,'+b64;await img.decode();
    const c=new OffscreenCanvas(img.width,img.height),x=c.getContext('2d');x.drawImage(img,0,0);const d=x.getImageData(0,0,img.width,img.height).data;
    let pixels=0,nonRed=0,maxGB=0,bright=0;for(let i=0;i<d.length;i+=4){pixels++;const m=Math.max(d[i+1],d[i+2]);if(m>maxGB)maxGB=m;if(m>8)nonRed++;if(d[i]>160)bright++;}
    return {width:img.width,height:img.height,pixels,nonRed,maxGB,redThumbPixels:bright};},buf.toString('base64')).then(r=>({...r,file:path.relative(out,file)}));
}
const planState=p=>p.locator('.plan-state').evaluate(e=>({text:e.textContent.trim(),persistence:e.dataset.persistence}));
const budgetReason=p=>p.locator('#plan-main').evaluate(e=>/Settings defaults differ/.test(e.textContent));
const storedPlan=p=>p.evaluate(()=>localStorage.getItem('culmina-plan-preview-v1'));
const homeLabel=async s=>{await s.go('index.html',{view:'wide'});return s.p.locator('.concept.variant-blend .saved-label').evaluate(e=>({text:e.textContent.trim(),persistence:e.dataset.persistence}));};
async function weatherCharts(s){await s.go('workspace.html',{tab:'settings'});await s.p.locator('[data-open=appearance]').click();await s.p.locator('#settings-weather-charts').check();await settle(s.p);}
async function planningOverhead(s,value){
  await s.go('workspace.html',{tab:'settings'});await s.p.locator('[data-open=planning]').click();
  await s.p.locator('#settings-perFrameOverheadSeconds').fill(String(value));await s.p.locator('#settings-save-planning').click();await settle(s.p);
}
async function editCount(s,count,apply=true){
  await s.p.locator('[data-edit-block]').first().click();await s.p.locator('#block-count').fill(String(count));
  if(apply){await s.p.locator('[data-apply-screen]').click();await s.p.waitForSelector('#block-screen',{state:'hidden'});}
}

async function wqa01(browser){
  const id='WQA-01',s=await session(browser),{p}=s,measured={};
  await s.go('index.html',{view:'wide',theme:'field'},375);
  measured.homeOpenPlanner=await actionStates(id,s,p.locator('.concept.variant-blend [data-action=planner]'),'Home Open planner');
  await s.go('plan.html',{theme:'field'},375);
  measured.planSave=await actionStates(id,s,p.locator('[data-save-plan]'),'Plan Save plan');
  await p.locator('[data-edit-block]').first().click();await p.waitForSelector('[data-apply-screen]');
  measured.planApply=await actionStates(id,s,p.locator('[data-apply-screen]'),'Plan Apply changes');
  expect(id,await p.locator('#block-screen').isVisible(),'Pressed-and-released-away Apply did not activate');
  await p.locator('[data-apply-screen]').screenshot({path:path.join(out,`${phase}-WQA01-plan-apply-field-375.png`)});
  await p.locator('.android-device').screenshot({path:path.join(out,`${phase}-WQA01-block-editor-field-375.png`)});
  // The planner dialogs sit outside the phone element but share the same primary pair.
  await p.locator('#block-count').fill('122');await p.locator('#back-editor').click();await p.waitForSelector('#discard-edit[open]');
  measured.dialogDiscard=await actionStates(id,s,p.locator('[data-discard-edit=discard]'),'Plan dialog Discard edit',p.locator('#discard-title'));
  expect(id,await p.locator('#discard-edit').evaluate(e=>e.open),'Pressed-and-released-away Discard edit did not activate');
  await p.locator('.planner-page').screenshot({path:path.join(out,`${phase}-WQA01-discard-dialog-field-375.png`)});
  await p.locator('[data-discard-edit=keep]').click();
  await s.go('workspace.html',{tab:'library',theme:'field'},375);await p.locator('[data-open-list=rigs]').click();
  await p.locator('[data-add=rig]').click();await p.waitForSelector('.library-form-actions .primary-button');
  measured.librarySave=await actionStates(id,s,p.locator('.library-form-actions .primary-button'),'Library Save rig');
  await p.locator('.library-form-actions .primary-button').screenshot({path:path.join(out,`${phase}-WQA01-library-save-field-375.png`)});
  await s.ctx.close();
  // Light/Dark action palette must stay exactly as it was (fresh context: no editor draft).
  for(const [theme,bg,fg] of [['light','rgb(55, 53, 47)','rgb(255, 255, 255)'],['dark','rgb(235, 235, 234)','rgb(25, 25, 25)']]){
    const t=await session(browser);await t.go('plan.html',{theme},375);const m=await t.p.locator('[data-save-plan]').evaluate(measureAction);
    expect(id,m.bg===bg&&m.fg===fg,`${theme} primary action unchanged (${m.bg} / ${m.fg})`,m);await t.ctx.close();
  }
  return measured;
}

async function wqa06(browser){
  const id='WQA-06',measured=[];
  for(const width of [375,412]){
    const s=await session(browser),{p}=s;await s.go('index.html',{view:'wide'},width);
    const pickers=[['site','Observing site'],['date','Choose a night']];
    for(const [action,title] of pickers){
      await s.fit(width);await p.locator(`.concept.variant-blend [data-action=${action}]`).first().click();await p.waitForSelector('#detail[open]');await settle(p);
      const g=await p.evaluate(()=>{const row=document.querySelector('#detail .dialog-actions'),r=row.getBoundingClientRect();return {actions:{width:r.width,height:r.height},buttons:[...row.children].map(b=>{const q=b.getBoundingClientRect(),cs=getComputedStyle(b);return {text:b.textContent.trim(),width:q.width,height:q.height,flex:cs.flex,lines:Math.round(b.scrollHeight/parseFloat(cs.lineHeight))};})};});
      measured.push({width,picker:title,...g});
      for(const b of g.buttons){
        expect(id,b.height>=48&&b.height<72,`${width} ${title} “${b.text}” height ${b.height} in [48,72)`,b);
        expect(id,Math.abs(b.width-g.actions.width)<=1,`${width} ${title} “${b.text}” full width (${b.width}/${g.actions.width})`);
      }
      await p.locator('#detail').screenshot({path:path.join(out,`${phase}-WQA06-${action}-${width}.png`)});
      await p.locator('#detail [data-action=cancel]').click();await p.waitForFunction(()=>!document.querySelector('#detail').open);
    }
    // Representative adopters: the candidate picker rows and the welcome confirmation's stacked actions.
    await p.locator('.concept.variant-blend [data-action=candidates]').first().click();await p.waitForSelector('#detail[open]');
    const rows=await p.locator('#detail .candidate-button').evaluateAll(es=>es.map(e=>e.getBoundingClientRect().height));
    expect(id,rows.length>0&&rows.every(h=>h>=48&&h<120),`${width} candidate rows keep content height (${rows.join(', ')})`);
    await p.locator('#close-detail').click();await p.waitForFunction(()=>!document.querySelector('#detail').open);
    await p.evaluate(()=>{const b=document.createElement('button');b.dataset.action='welcome';b.id='qa-welcome';b.textContent='QA welcome';document.querySelector('.concept.variant-blend .app-content').append(b);});
    await p.locator('#qa-welcome').click();await p.waitForSelector('#detail[open] .dialog-actions');
    const welcome=await p.locator('#detail .dialog-actions>*').evaluateAll(es=>es.map(e=>({text:e.textContent.trim(),height:e.getBoundingClientRect().height})));
    expect(id,welcome.every(b=>b.height>=48&&b.height<72),`${width} confirmation actions keep content height`,welcome);
    measured.push({width,candidates:rows,welcome});
    await s.ctx.close();
  }
  return measured;
}

async function wqa02(browser){
  const id='WQA-02',log={};
  { // Clean initial example, then only the Weather presentation changes.
    const s=await session(browser),{p}=s;await s.go('plan.html',{},375);
    const before={state:await planState(p),reason:await budgetReason(p),plan:await storedPlan(p)};
    await weatherCharts(s);await s.go('plan.html',{},375);
    const after={state:await planState(p),reason:await budgetReason(p),plan:await storedPlan(p)};
    await p.locator('.android-device').screenshot({path:path.join(out,`${phase}-WQA02-plan-after-weather-b.png`)});
    const home=await homeLabel(s);
    expect(id,before.state.text==='Saved','Initial example reads Saved',before);
    expect(id,after.state.text==='Saved'&&!after.reason,'Weather A→B leaves Plan Saved, with no budget reason',after);
    expect(id,home.text==='Saved','Weather A→B leaves Home Saved',home);
    expect(id,after.plan===before.plan&&after.plan===null,'No plan record or budgetSnapshot written by the display change');
    // A real block edit is dirty, without the false Settings reason.
    await s.go('plan.html',{},375);await editCount(s,121);
    const edited={state:await planState(p),reason:await budgetReason(p)};
    expect(id,edited.state.text==='Saved · changed'&&!edited.reason,'Real block edit: Saved · changed without a Settings reason',edited);
    await p.locator('[data-save-plan]').click();await settle(p);
    expect(id,(await planState(p)).text==='Saved','Save after the edit reads Saved');
    log.initial={before,after,home,edited};await s.ctx.close();
  }
  { // A plan saved with a snapshot, then Weather B, then a real Planning change.
    const s=await session(browser),{p}=s;await s.go('plan.html',{},375);await editCount(s,121);await p.locator('[data-save-plan]').click();await settle(p);
    const saved=await storedPlan(p);expect(id,!!JSON.parse(saved).active.budgetSnapshot,'Explicit Save records a budgetSnapshot');
    await weatherCharts(s);await s.go('plan.html',{},375);
    const afterWeather={state:await planState(p),reason:await budgetReason(p)};
    expect(id,afterWeather.state.text==='Saved'&&!afterWeather.reason&&await storedPlan(p)===saved,'Snapshot plan stays Saved and unchanged after Weather B',afterWeather);
    await planningOverhead(s,6);await s.go('plan.html',{},375);
    const planning={state:await planState(p),reason:await budgetReason(p)};
    expect(id,planning.state.text==='Saved · changed'&&planning.reason,'Real Planning change on a snapshot plan stays Saved · changed with its reason',planning);
    expect(id,await storedPlan(p)===saved,'Planning change does not rewrite the saved plan');
    log.snapshot={afterWeather,planning};await s.ctx.close();
  }
  { // Real Planning change on the initial example, and its honest revert.
    const s=await session(browser),{p}=s;await planningOverhead(s,6);await s.go('plan.html',{},375);
    const changed={state:await planState(p),reason:await budgetReason(p)};
    expect(id,changed.state.text==='Saved · changed'&&changed.reason,'Initial example: changed Planning is Saved · changed with its reason',changed);
    await planningOverhead(s,5);await s.go('plan.html',{},375);
    const reverted={state:await planState(p),reason:await budgetReason(p)};
    expect(id,reverted.state.text==='Saved'&&!reverted.reason,'Initial example: Planning back to the initial defaults reads Saved',reverted);
    // A plan override is a real plan change.
    await p.locator('[data-edit-assumptions]').evaluate(e=>{const d=e.closest('details');if(d)d.open=true;});
    await p.locator('[data-edit-assumptions]').click();await p.locator('#asm-perFrameOverhead').fill('9');await p.locator('[data-apply-screen]').click();await p.waitForSelector('#block-screen',{state:'hidden'});
    const override={state:await planState(p),reason:await budgetReason(p)};
    expect(id,override.state.text==='Saved · changed'&&!override.reason,'Plan override: Saved · changed (plan change, not a Settings reason)',override);
    log.planning={changed,reverted,override};await s.ctx.close();
  }
  { // Legacy settings (no weatherPresentation) and a legacy plain plan record without budgetSnapshot.
    const s=await session(browser),{p}=s;await s.go('plan.html',{},375);await editCount(s,121);await p.locator('[data-save-plan]').click();await settle(p);
    const legacyPlan=JSON.parse(await storedPlan(p)).active;delete legacyPlan.budgetSnapshot;
    await weatherCharts(s);const settings=JSON.parse(await p.evaluate(()=>localStorage.getItem('culmina-settings-preview-v1')));delete settings.settings.display.weatherPresentation;
    const fresh=await session(browser);await fresh.go('plan.html',{},375);
    await fresh.p.evaluate(([plan,settings])=>{localStorage.clear();localStorage.setItem('culmina-plan-preview-v1',JSON.stringify(plan));localStorage.setItem('culmina-settings-preview-v1',JSON.stringify(settings));},[legacyPlan,settings]);
    await fresh.go('plan.html',{},375);
    const legacy={state:await planState(fresh.p),reason:await budgetReason(fresh.p),count:await fresh.p.locator('.capture-block .block-math').first().innerText()};
    expect(id,legacy.state.text==='Saved'&&!legacy.reason,'Legacy settings + legacy plan without snapshot read Saved',legacy);
    expect(id,await storedPlan(fresh.p)===JSON.stringify(legacyPlan),'Reading a legacy plan never rewrites it or adds a budgetSnapshot');
    expect(id,(await homeLabel(fresh)).text==='Saved','Home agrees for the legacy plan');
    log.legacy=legacy;await s.ctx.close();await fresh.ctx.close();
  }
  return log;
}

async function wqa03(browser){
  const id='WQA-03',measured={};
  const s=await session(browser),{p}=s;
  for(const view of ['rows','charts']){
    await s.go('conditions.html',{view:'weather',theme:'field',weatherPresentation:view},375);
    const slider=p.locator('[data-weather-slider]');await slider.scrollIntoViewIfNeeded();await p.mouse.move(2,2);await settle(p);
    const attrs=await slider.evaluate(e=>({min:e.min,max:e.max,step:e.step,value:e.value,appearance:getComputedStyle(e).appearance,rect:e.getBoundingClientRect().toJSON()}));
    const pixels=await raster(p,slider,`WQA03-weather-${view}-field-375`);
    expect(id,pixels.nonRed===0&&pixels.redThumbPixels>0,`Field Weather ${view} range: red/black only (${pixels.nonRed} non-red px, max G/B ${pixels.maxGB})`,pixels);
    expect(id,attrs.rect.height>=48,`Field Weather ${view} range target ${attrs.rect.height}px >= 48`);
    await slider.focus();await p.keyboard.press('ArrowRight');
    const stepped=await slider.evaluate(e=>({value:e.value,label:document.querySelector('[data-weather-selected-label]').textContent}));
    expect(id,Number(stepped.value)===Number(attrs.value)+1,`ArrowRight steps the hour (${attrs.value}→${stepped.value})`,stepped);
    await p.keyboard.press('End');expect(id,(await slider.inputValue())===attrs.max,'End selects the last hour');
    await p.keyboard.press('Home');expect(id,(await slider.inputValue())===attrs.min,'Home selects the first hour');
    const focusPixels=await raster(p,slider,`WQA03-weather-${view}-field-375-focus`);
    const ring=await slider.evaluate(e=>({visible:e.matches(':focus-visible'),style:getComputedStyle(e).outlineStyle,color:getComputedStyle(e).outlineColor,width:getComputedStyle(e).outlineWidth}));
    expect(id,focusPixels.nonRed===0&&ring.visible&&ring.style==='solid'&&ring.color==='rgb(255, 0, 0)',`Field keyboard focus: red outline, red/black control (${focusPixels.nonRed} non-red px)`,ring);
    const box=await slider.boundingBox();await p.mouse.click(box.x+box.width*.97,box.y+box.height/2);
    expect(id,(await slider.inputValue())===attrs.max,'Pointer at the right end selects the last hour');
    const after=await slider.evaluate(e=>({min:e.min,max:e.max,step:e.step}));
    expect(id,after.min===attrs.min&&after.max===attrs.max&&after.step===attrs.step,'min/max/step unchanged');
    await p.emulateMedia({forcedColors:'active'});const forced=await slider.evaluate(e=>getComputedStyle(e).appearance);await p.emulateMedia({forcedColors:'none'});
    measured[view]={attrs,pixels,stepped,forcedColorsAppearance:forced};
  }
  await s.go('workspace.html',{tab:'settings',theme:'field'},375);await p.locator('[data-open=planning]').click();
  const range=p.locator('#settings-perFrameOverheadSeconds');await range.scrollIntoViewIfNeeded();await p.mouse.move(2,2);await settle(p);
  const sp=await raster(p,range,'WQA03-settings-planning-field-375');
  expect(id,sp.nonRed===0&&sp.redThumbPixels>0,`Field Settings Planning range red/black only (${sp.nonRed} non-red px)`,sp);
  await range.focus();await p.keyboard.press('ArrowRight');
  expect(id,(await p.locator('#settings-perFrameOverheadSeconds-value').innerText())==='6 s','Settings range ArrowRight updates its value');
  await p.locator('#settings-cancel-planning').click();
  measured.settings=sp;
  // Light/Dark keep the native control and their accent colours.
  for(const theme of ['light','dark']){
    await s.go('conditions.html',{view:'weather',theme},375);const slider=p.locator('[data-weather-slider]');await slider.scrollIntoViewIfNeeded();await p.mouse.move(2,2);await settle(p);
    const st=await slider.evaluate(e=>({appearance:getComputedStyle(e).appearance,accent:getComputedStyle(e).accentColor}));
    await slider.screenshot({path:path.join(out,`${phase}-WQA03-weather-${theme}-375.png`)});
    expect(id,st.appearance==='auto'&&st.accent===(theme==='light'?'rgb(0, 117, 222)':'rgb(98, 175, 243)'),`${theme} Weather range keeps native rendering and its blue accent`,st);
    await s.go('workspace.html',{tab:'settings',theme},375);await p.locator('[data-open=planning]').click();
    expect(id,await p.locator('#settings-perFrameOverheadSeconds').evaluate(e=>getComputedStyle(e).appearance)==='auto',`${theme} Settings range keeps native rendering`);
  }
  await s.ctx.close();return measured;
}

async function dialogGeometry(s,selector){
  const phone=await s.phoneRect();
  const g=await s.p.locator(selector).evaluate(e=>{const r=e.getBoundingClientRect();return {left:r.left,right:r.right,top:r.top,bottom:r.bottom,width:r.width,height:r.height,buttons:[...e.querySelectorAll('button')].filter(b=>b.getClientRects().length).map(b=>({text:b.textContent.trim(),height:b.getBoundingClientRect().height,width:b.getBoundingClientRect().width})),overflow:document.documentElement.scrollWidth>innerWidth};});
  return {phone,dialog:g,leftInset:g.left-phone.left,rightInset:phone.right-g.right};
}
function expectDialog(id,label,g,{gutter=20}={}){
  expect(id,Math.abs(g.leftInset-gutter)<=1&&Math.abs(g.rightInset-gutter)<=1,`${label}: ${g.leftInset.toFixed(1)} / ${g.rightInset.toFixed(1)} px from the phone edges (≈${gutter})`,g);
  expect(id,g.dialog.top>=g.phone.top&&g.dialog.bottom<=g.phone.bottom,`${label}: inside the phone vertically`);
  expect(id,g.dialog.buttons.every(b=>b.height>=48&&b.width>=48),`${label}: actions >= 48 px`);
  expect(id,!g.dialog.overflow,`${label}: no host horizontal overflow`);
}
async function wqa04(browser){
  const id='WQA-04',measured=[];
  for(const theme of ['light','dark','field'])for(const width of [375,412]){
    const s=await session(browser),{p}=s;await s.go('plan.html',{theme},width);
    await editCount(s,122,false);await p.locator('#back-editor').click();await p.waitForSelector('#discard-edit[open]');
    const g=await dialogGeometry(s,'#discard-edit');measured.push({theme,width,name:'discard-edit',...g});
    expectDialog(id,`${theme} ${width} Discard this edit?`,g);
    if(theme!=='dark'||width===375)await p.locator('.planner-page').screenshot({path:path.join(out,`${phase}-WQA04-discard-${theme}-${width}.png`)});
    await p.locator('[data-discard-edit=keep]').click();
    expect(id,!(await p.locator('#discard-edit').evaluate(e=>e.open))&&await p.locator('#block-screen').isVisible()&&(await p.locator('#block-count').inputValue())==='122',`${theme} ${width} Keep editing keeps the unapplied edit`);
    await p.locator('#back-editor').click();await p.locator('[data-discard-edit=discard]').click();
    expect(id,await p.locator('#block-screen').isHidden()&&/120/.test(await p.locator('.capture-block .block-math').first().innerText()),`${theme} ${width} Discard edit leaves the draft unchanged`);
    if(theme==='light'){
      await editCount(s,123);await p.locator('#back-home').click();await p.waitForSelector('#leave-plan[open]');
      const leave=await dialogGeometry(s,'#leave-plan');measured.push({theme,width,name:'leave-plan',...leave});expectDialog(id,`${theme} ${width} Unsaved changes`,leave);
      await p.locator('[data-leave=cancel]').click();expect(id,/plan\.html/.test(p.url())&&(await planState(p)).text==='Saved · changed','Cancel keeps the changed draft on Plan');
      await s.go('conditions.html',{view:'night'},width);await p.locator('[data-step="1"]').click();await p.locator('[data-plan-viewed]').click();await p.waitForSelector('#adopt-dialog[open]');
      const adopt=await dialogGeometry(s,'#adopt-dialog');measured.push({theme,width,name:'adopt-dialog',...adopt});expectDialog(id,`${theme} ${width} Plan this night?`,adopt);
      await p.locator('[data-adopt-choice=cancel]').click();expect(id,!(await p.locator('#adopt-dialog').evaluate(e=>e.open)),'Adopt Cancel closes without a choice');
    }
    await s.ctx.close();
  }
  { // Representative narrow host: the browser itself is the phone.
    const s=await session(browser,{viewport:{width:375,height:800}}),{p}=s;await s.go('plan.html',{},null);
    await editCount(s,122,false);await p.locator('#back-editor').click();await p.waitForSelector('#discard-edit[open]');
    const g=await dialogGeometry(s,'#discard-edit');measured.push({host:375,name:'discard-edit',...g});
    expectDialog(id,'Narrow 375 host Discard this edit?',g);await p.screenshot({path:path.join(out,`${phase}-WQA04-discard-narrow-host-375.png`)});
    await s.ctx.close();
  }
  return measured;
}

async function wqa05(browser){
  const id='WQA-05',measured=[];
  for(const [theme,width,scenario] of [['light',375,'ready'],['dark',412,'ready'],['light',375,'partial']]){
    const s=await session(browser),{p}=s;await s.go('conditions.html',{view:'weather',theme,weatherPresentation:'charts',scenario},width);
    await p.waitForSelector('[data-weather-variant=charts]');
    const data=await p.locator('.wx-mini-chart').evaluateAll(es=>es.map(e=>({title:e.querySelector('h3').textContent.trim(),paths:[...e.querySelectorAll('path')].map(x=>x.getAttribute('d')),gaps:e.querySelectorAll('.wx-gap').length,scale:e.querySelector('.wx-axis-label').textContent})));
    for(const name of ['Wind / gusts','Precipitation probability']){
      await p.locator('.wx-mini-chart',{hasText:name}).evaluate(e=>{const sc=e.closest('.android-scroll');sc.scrollTop+=e.getBoundingClientRect().top-sc.getBoundingClientRect().top-8;});
      for(const scrollLeft of [0,96]){
        await p.locator('.wx-chart-scroll').evaluate((e,v)=>{e.scrollLeft=v;},scrollLeft);await p.waitForTimeout(60);
        const g=await p.locator('.wx-mini-chart',{hasText:name}).evaluate(chart=>{
          const port=chart.closest('.android-scroll').getBoundingClientRect(),h=chart.closest('.wx-chart-scroll').getBoundingClientRect(),axis=chart.closest('.wx-chart-grid').querySelector('.wx-time-axis');
          const visible=r=>r.bottom>port.top&&r.top<port.bottom&&r.right>h.left&&r.left<h.right;
          const axisButtons=[...axis.querySelectorAll('button')].map(b=>b.getBoundingClientRect());
          const labels=[...chart.querySelectorAll('.wx-panel-hours>*')].map(l=>({text:l.textContent,rect:l.getBoundingClientRect(),selected:l.classList.contains('is-selected')}));
          return {axisVisible:axisButtons.some(visible),labels:labels.map(l=>l.text),visibleLabels:labels.filter(l=>visible(l.rect)).map(l=>l.text),aligned:labels.length===axisButtons.length&&labels.every((l,i)=>Math.abs((l.rect.left+l.rect.right)/2-(axisButtons[i].left+axisButtons[i].right)/2)<=1),axisTexts:[...axis.querySelectorAll('button')].map(b=>b.textContent),chartInView:chart.getBoundingClientRect().top>=port.top-1};
        });
        measured.push({theme,width,scenario,panel:name,scrollLeft,...g});
        expect(id,!g.axisVisible&&g.chartInView,`${theme} ${width} ${scenario} ${name} @${scrollLeft}: top axis is scrolled away (reproduction context)`);
        expect(id,g.visibleLabels.length>=4&&g.aligned&&g.labels.join()===g.axisTexts.join(),`${theme} ${width} ${scenario} ${name} @${scrollLeft}: visible hour labels share the axis positions (${g.visibleLabels.join(' ')})`);
      }
      await p.locator('.wx-chart-scroll').evaluate(e=>{e.scrollLeft=0;});
      if(scenario==='ready')await p.locator('.android-device').screenshot({path:path.join(out,`${phase}-WQA05-${name.split(' ')[0].toLowerCase()}-${theme}-${width}.png`)});
    }
    // Selected hour follows the existing selector in every panel's hour row.
    const slider=p.locator('[data-weather-slider]');await slider.focus();await p.keyboard.press('Home');await p.keyboard.press('ArrowRight');await p.keyboard.press('ArrowRight');
    const sel=await p.evaluate(()=>({axis:[...document.querySelectorAll('.wx-time-axis [aria-pressed=true]')].map(b=>b.dataset.weatherIndex),rows:[...document.querySelectorAll('.wx-panel-hours')].map(r=>[...r.children].findIndex(c=>c.classList.contains('is-selected')))}));
    expect(id,sel.axis.join()==='2'&&sel.rows.length>0&&sel.rows.every(i=>i===2),`${theme} ${width} ${scenario}: selected hour 2 marked on the axis and each panel row`,sel);
    expect(id,await p.locator('.wx-panel-hours').evaluateAll(es=>es.every(e=>e.getAttribute('aria-hidden')==='true')),'Repeated hour rows are hidden from assistive technology (the axis stays the one selector)');
    measured.push({theme,width,scenario,data,selection:sel});
    if(scenario==='partial')await p.locator('.android-device').screenshot({path:path.join(out,`${phase}-WQA05-partial-light-375.png`)});
    await s.ctx.close();
  }
  // A overview and compact Home stay without charts.
  const s=await session(browser),{p}=s;await s.go('conditions.html',{view:'weather',weatherPresentation:'rows'},375);
  expect(id,(await p.locator('.wx-panel-hours').count())===0&&(await p.locator('.wx-overview').count())===1,'Weather A overview unchanged');
  await s.go('index.html',{view:'wide'},375);expect(id,(await p.locator('.concept.variant-blend .weather-variant,.concept.variant-blend .wx-panel-hours').count())===0,'Home weather stays compact');
  await s.ctx.close();
  return measured;
}

(async()=>{
  const browser=await launchChromium({headless:true});const measured={};
  try{
    for(const [id,run] of [['WQA-01',wqa01],['WQA-06',wqa06],['WQA-02',wqa02],['WQA-03',wqa03],['WQA-04',wqa04],['WQA-05',wqa05]]){
      try{measured[id]=await run(browser);}catch(e){expect(id,false,`Scenario error: ${String(e).split('\n')[0]}`);}
    }
  }finally{await browser.close();}
  report.measured=measured;
  const file=path.join(out,`${phase}-qa-fixes.json`);fs.writeFileSync(file,JSON.stringify(report,null,2));
  const summary=Object.fromEntries(Object.entries(report.results).map(([id,r])=>[id,{pass:r.pass,failures:r.failures.length,checks:r.cases.length}]));
  console.log(JSON.stringify({phase,summary,pageErrors:report.errors},null,1));
  if(phase==='after'&&(report.errors.length||Object.values(report.results).some(r=>!r.pass)))process.exitCode=1;
})().catch(e=>{console.error(e);process.exitCode=1;});
