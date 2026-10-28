from pathlib import Path
import re,json,hashlib,html,subprocess
from datetime import datetime,timezone
O=Path(__file__).parent;R=next(p for p in Path(__file__).resolve().parents if (p/'pubspec.yaml').exists() and (p/'AGENTS.md').exists())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
S=[]
def add(p,kind):
 text=p.read_text(encoding='utf-8'); rel=str(p.relative_to(R)) if p.is_relative_to(R) else str(p)
 name=p.parent.name if p.name=='SKILL.md' else p.name
 title=re.search(r'^# (.+)',text,re.M)
 lines=text.splitlines()
 rules=[{'line':i+1,'text':s.lstrip('- ').strip()} for i,s in enumerate(lines) if s.startswith('- ') or re.match(r'^\d+\. ',s)]
 key=hashlib.sha256(str(p).encode()).hexdigest()[:12]
 dst=O/'design-sources'/f'{key}.html';dst.parent.mkdir(exist_ok=True)
 dst.write_text('<!doctype html><meta charset="utf-8"><title>'+html.escape(name)+'</title><style>body{font:15px/1.6 system-ui;max-width:1100px;margin:32px auto;padding:20px}pre{white-space:pre-wrap;overflow-wrap:anywhere}a{color:#1768ae}</style><h1>'+html.escape(name)+'</h1><p>'+html.escape(rel)+'</p><p>SHA-256: '+sha(p)+'</p><pre>'+html.escape('\n'.join(f'{i+1:4}  {s}' for i,s in enumerate(lines)))+'</pre>',encoding='utf-8')
 S.append(dict(name=name,title=title.group(1) if title else name,path=rel,category=kind,sha256=sha(p),lines=len(lines),rules=rules,text=text,href='design-sources/'+dst.name))
for p in sorted((R/'.agents/skills').glob('culmina-design-*/SKILL.md')):add(p,'Culmina skill')
for p in sorted((R/'.agents/skills').glob('culmina-design-*/references/*.md')):add(p,'Culmina reference')
for p in [R/'AGENTS.md',R/'docs/DESIGN_SYSTEM.md',R/'docs/PRODUCT_SPEC.md',R/'docs/ARCHITECTURE.md']:add(p,'Project authority' if p.name=='AGENTS.md' else 'Implementation reference')
for p in sorted((R/'.agents/rules').glob('*.md')):add(p,'Compatibility pointer')
for p in sorted((R/'lib/core/theme').glob('*.dart')):add(p,'Implementation owner')
for p in [R/'lib/presentation/shared/document_section.dart',R/'lib/presentation/shared/confirmation_patterns.dart',R/'lib/presentation/shared/unsaved_plan_prompt.dart']:add(p,'Implementation owner')
external=[]
names={'imagegen','impeccable','visualize','audit','ideate','index','image-to-code','url-to-code','generate-design-tokens','compose-ui-theme','build-brand-palette','direct-creative-palette','extract-image-palette','harmonize-palette','plan-interior-palette','design','brand-identity','generate-library','generate-design','design-qa','sites','sites-remix'}
home=Path('C:/Users/zalub')
for root in [home/'.codex/skills',home/'.agents/skills',home/'.codex/plugins/cache']:
 for p in root.rglob('SKILL.md'):
  if p.parent.name.startswith('figma') or p.parent.name in names or 'product-design' in p.parts:
   if p.parent.name in {'index','audit','ideate','image-to-code','url-to-code','design-qa'} and 'product-design' not in str(p):continue
   t=p.read_text(encoding='utf-8',errors='replace');nm=re.search(r'^name:\s*[\"\']?([^\r\n\"\']+)',t,re.M)
   name=nm.group(1).strip() if nm else p.parent.name
   key=hashlib.sha256(str(p).encode()).hexdigest()[:12]
   dst=O/'design-sources'/f'external-{key}.html'
   dst.write_text('<!doctype html><meta charset="utf-8"><title>'+html.escape(name)+'</title><style>body{font:15px/1.6 system-ui;max-width:1100px;margin:32px auto;padding:20px}pre{white-space:pre-wrap;overflow-wrap:anywhere}</style><h1>'+html.escape(name)+'</h1><p>Optional external playbook — not adopted Culmina policy.</p><p>'+html.escape(str(p))+'</p><pre>'+html.escape('\n'.join(f'{i+1:4}  {s}' for i,s in enumerate(t.splitlines())))+'</pre>',encoding='utf-8')
   external.append(dict(name=name,path=str(p),sha256=sha(p),href='design-sources/'+dst.name,description=next((l[12:].strip(' "') for l in t.splitlines() if l.startswith('description:')),'')))
# Keep every discovered copy visible; these are filesystem discoveries, not a claim of runtime activation.
colors=[]
for name,value in re.findall(r'static const Color (\w+) = Color\(0x([A-Fa-f0-9]{8})\)',(R/'lib/core/theme/app_colors.dart').read_text()):colors.append(dict(name=name,value='#'+value[2:]))
spaces=dict(re.findall(r'static const double (\w+) = ([0-9.]+)',(R/'lib/core/theme/app_spacing.dart').read_text()))
catalog=dict(head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip(),generatedUtc=datetime.now(timezone.utc).isoformat(),sources=S,external=external,colors=colors,spacing=spaces,scope='All five project design skills and their supporting references, project governance pointers, current theme owners, plus design-facing skill copies discovered in the three listed local skill/cache roots. External copies are optional tools, not adopted Culmina rules; duplicate versions remain visible. Archived evidence is not active policy.')
(O/'design-catalog.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2),encoding='utf-8')
audit=json.loads((O/'code-design-audit.json').read_text(encoding='utf-8')) if (O/'code-design-audit.json').exists() else {'status':'Parallel code review in progress','findings':[]}
base=(O/'map-template.html').read_text(encoding='utf-8')
base=base.replace('</nav>','<button type="button" role="tab" id="tab-design" aria-controls="view-design" aria-selected="false">Design rules & skills</button></nav>',1)
section='''<section id="view-design" role="tabpanel" aria-labelledby="tab-design" hidden><h2>Design rules & skills</h2><p class="notice">User task → AGENTS.md invariants → relevant Culmina skill → actual production owner / caller → evidence. Compatibility pointers add no independent rules. External playbooks are optional, not product policy.</p><div id="design-summary" class="badges"></div><div class="controls"><input id="design-search" type="search" aria-label="Search design sources" placeholder="Find typography, unknown, Field, Figma…"><select id="design-kind" aria-label="Design source category"><option>All project sources</option></select></div><div id="design-list"></div><h2>Implemented token specimens</h2><p class="muted">Extracted from current AppColors / AppSpacing. Swatches document values; they do not establish readability or visual acceptance.</p><div id="design-spacing" class="badges"></div><div id="design-colors" class="areas"></div><h2>Parallel code review</h2><p class="notice">Source-only review. A compliance conclusion about pixels, text scaling, TalkBack or device behavior cannot be established from code alone.</p><div id="design-audit"></div><h2>External design playbooks on disk</h2><p class="muted">Separate from Culmina authority. Includes acquisition/version duplicates; filesystem presence does not prove a tool is enabled in this chat.</p><details><summary id="external-count"></summary><div id="external-design"></div></details><p><a href="design-catalog.json">Complete inventory + source hashes</a> · <a href="code-design-audit.json">Code review evidence</a></p></section>'''
base=base.replace('</main>',section+'</main>')
script=(O/'design-runtime.js').read_text(encoding='utf-8')
data=json.dumps({'catalog':catalog,'audit':audit},ensure_ascii=False).replace('</','<\\/')
base=base.replace('</html>','<script id="design-data" type="application/json">'+data+'</script><script>'+script+'</script></html>')
mapdata=json.loads((O/'map.json').read_text(encoding='utf-8'))
(O/'index.html').write_text(base.replace('__MAP_DATA__',json.dumps(mapdata,ensure_ascii=False).replace('</','<\\/')),encoding='utf-8')
print(json.dumps({'projectSources':len(S),'projectSkills':sum(s['category']=='Culmina skill' for s in S),'externalCopies':len(external),'head':catalog['head']},indent=2))

# Final five-skill presentation supersedes the discovery inventory UI.
if (O/'refine_site.py').exists():
 import sys
 subprocess.run([sys.executable,str(O/'refine_site.py')],check=True,cwd=R)
