// Opt-in presentation tokens and feedback for the original Hybrid only.
const variant=new URLSearchParams(location.search).get('variant')||'blend';
// Full-page previews use a root scope. The gallery must scope each concept
// separately so Hybrid's inherited chart variables cannot leak to its neighbours.
if(document.body.classList.contains('planner-page'))document.documentElement.dataset.variant=variant;
// Modal dialogs belong to the phone, not to the studio around it (WQA-04): publish the phone's
// visible rectangle so planner dialogs keep their 20 px phone edges at any phone width.
const phone=document.body.classList.contains('planner-page')?document.querySelector('.android-device'):null;
if(phone){
  const place=()=>{
    const r=phone.getBoundingClientRect(),w=document.documentElement.clientWidth,h=document.documentElement.clientHeight;
    const left=Math.max(0,r.left),right=Math.min(w,r.right),top=Math.max(0,r.top),bottom=Math.min(h,r.bottom);
    for(const [name,value] of Object.entries({left,right:w-right,top,bottom:h-bottom,width:right-left,height:bottom-top}))document.documentElement.style.setProperty('--phone-'+name,value+'px');
  };
  place();new ResizeObserver(place).observe(phone);addEventListener('resize',place);addEventListener('scroll',place,{passive:true});
}
const tokens=await fetch('./tokens.json',{cache:'no-store'}).then(r=>r.json());
for(const [name,value] of Object.entries(tokens.hybridRefinement||{})){
  if(typeof value==='string')document.documentElement.style.setProperty('--hybrid-'+name,value);
}
// Navigation feedback follows the replaced view; inputs never replay an entrance.
document.addEventListener('click',event=>{
  if(variant!=='blend'||matchMedia('(prefers-reduced-motion: reduce)').matches)return;
  const action=event.target.closest('[data-open],[data-open-list],[data-edit],[data-add],[data-open-entry],[data-open-progress],[data-edit-block],[data-add-block],[data-view]');
  if(!action||!action.closest('.android-device,.variant-blend'))return;
  requestAnimationFrame(()=>{
    const view=document.querySelector('#block-screen:not([hidden]),#workspace-main,#conditions-main,#plan-main');
    view?.animate([{opacity:.72,transform:'translateY(4px)'},{opacity:1,transform:'translateY(0)'}],{duration:180,easing:'cubic-bezier(.16,1,.3,1)'});
  });
});
