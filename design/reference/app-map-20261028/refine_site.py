from pathlib import Path
import json,re,shutil,hashlib,subprocess
O=Path(__file__).parent;R=next(p for p in Path(__file__).resolve().parents if (p/'pubspec.yaml').exists() and (p/'AGENTS.md').exists())
C=json.loads((O/'design-catalog.json').read_text(encoding='utf-8'));M=json.loads((O/'map.json').read_text(encoding='utf-8'))
samples=json.loads((R/'design/reference/evidence/components-20261028/renders/manifest.json').read_text(encoding='utf-8'))
(O/'components').mkdir(exist_ok=True)
for s in samples:
 p=R/'design/reference/evidence/components-20261028/renders'/s['file'];shutil.copy2(p,O/'components'/p.name)
 s['file']='components/'+p.name;s['sha256']=hashlib.sha256(p.read_bytes()).hexdigest()
groups={}
for s in samples:
 k=str(s['id']);g=groups.setdefault(k,dict(id=k,label=s['label'],types=s['types'],texts=s.get('texts',[]),images={}))
 g['images'][s['theme']]=s['file']
 if g['label'] in ['SizedBox','Row','Wrap','Padding','Card','Column','Builder']:
  owned=[t for t in s['types'] if t.startswith(('Hybrid','Library','Settings','StatusBlock','PlanStateLabel','EntryStateBadge','ContextLine','Startup','Launch','Collapsible','ChangeMark','_TextRoles'))]
  g['label']=' / '.join(dict.fromkeys(owned[:2])) or ('Surfaces & typography' if s['id']==0 else s['label'])
inventory=[]
for path in list((R/'lib/presentation/shared').glob('*.dart'))+[R/'lib/presentation/screens/library/library_parts.dart',R/'lib/presentation/screens/settings/settings_parts.dart']:
 for n in re.findall(r'^class ([A-Z]\w*)(?:<[^\n]+?>)? extends (?:StatelessWidget|StatefulWidget)',path.read_text(encoding='utf-8'),re.M):
  found=[g['id'] for g in groups.values() if any(t.split('<')[0]==n for t in g['types'])]
  inventory.append(dict(name=n,source=path.relative_to(R).as_posix(),specimens=found))
labels={'0':'Typography · plain surface','1':'Typography · card surface','2':'Typography · tonal surface','3':'Material actions · enabled and disabled','18':'EntryStateBadge · all record states','34':'HybridRadio · selected and unselected','39':'HybridSwitch · on, off and disabled','41':'HybridCheckbox · checked and unchecked','52':'StartupCover · loading','54':'HybridFocusHighlight · idle','59':'HybridIcon · moon','79':'LaunchGate · initialization pending','80':'LaunchPreview · developer preview','detail':'DetailScaffold · reference composition','confirm':'Destructive confirmation','unsaved':'Unsaved changes prompt','undo':'Undo notification'}
for key,label in labels.items():
 if key in groups: groups[key]['label']=label
science=[]
sd=R/'design/reference/evidence/components-20261028/science'
for p in sd.glob('*.json'):
 d=json.loads(p.read_text(encoding='utf-8'))
 if d.get('fixtureSucceeded'):
  png=p.with_suffix('.png');shutil.copy2(png,O/'components'/png.name)
  science.append(dict(name=d['name'],theme=d['theme'],file='components/'+png.name,kind='Actual isolated Flutter chart' if d['name']=='component_altitude' else 'Production context — exact Flutter capture'))
review=dict(head=C['head'],retained=[dict(name=s['name'],status='Current — retain',reason='Distinct bounded purpose; no duplicate Culmina design skill.',path=s['path']) for s in C['sources'] if s['category']=='Culmina skill'],reclassified=[dict(category='Implementation sources / references',decision='Supporting evidence under the relevant skill; not independent design policy'),dict(category='6 compatibility pointers',decision='Redirects to AGENTS/skills; no additional rules'),dict(category='External playbooks and duplicate acquisitions',decision='Removed from normal Culmina design navigation; optional tools, not adopted product policy. Global installations preserved.'),dict(category='Archived or empty project skill directories',decision='No active SKILL.md: not active skills; preserve historical acquisition evidence.')],notes=['No obsolete one of the five Culmina design skills was found.','DetailScaffold and AltitudeChartWidget remain reference-only where there is no current production adopter; gallery availability does not imply adoption.','Legacy gallery renderer did not load Geist. New isolated renderer loads the actual bundled Geist font.'],productionModified=False)
(O/'skills-review.json').write_text(json.dumps(review,indent=2),encoding='utf-8')
data=dict(audit=json.loads((O/'code-design-audit.json').read_text(encoding='utf-8')),skills=[s for s in C['sources'] if s['category']=='Culmina skill'],support=[s for s in C['sources'] if s['category']!='Culmina skill'],review=review,components=list(groups.values()),inventory=inventory,science=science,head=C['head'])
(O/'component-manifest.json').write_text(json.dumps(dict(head=C['head'],font='Bundled Geist + SDK MaterialIcons',renderKind='Native Flutter host, 412 logical px, synthetic specimens, 100% text',samples=samples,inventory=inventory,science=science),indent=2),encoding='utf-8')
base=(O/'map-template.html').read_text(encoding='utf-8')
base=base.replace('</nav>','<button type="button" role="tab" id="tab-design" aria-controls="view-design" aria-selected="false">Culmina design skills</button><button type="button" role="tab" id="tab-components" aria-controls="view-components" aria-selected="false">Components</button></nav>',1)
base=base.replace('<h1>Culmina / Application map</h1>','<h1>Culmina / Application map</h1><button type="button" id="site-theme" aria-label="Switch website theme">Switch to light</button>')
css='''<style>:root[data-theme=light]{color-scheme:light;--bg:#ffffff;--panel:#f7f7f5;--text:#37352f;--muted:#5a5955;--line:#c8c8c3;--accent:#145c99;--selected:#e2edf6}.specimen-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:20px}.specimen{padding:12px;text-align:left;min-width:0}.specimen img{display:block;width:100%;height:auto;margin:12px 0}.skill{padding:20px 0;border-top:1px solid var(--line)}.specimen-note{font-size:13px;color:var(--muted)}#specimen-image{max-width:100%;height:auto;display:block;margin:auto}#specimen-modal{width:600px}.site-theme{margin:8px 0}</style>'''
base=base.replace('</style>','</style>'+css,1)
section='''<section id="view-design" role="tabpanel" aria-labelledby="tab-design" hidden><h2>Five Culmina design skills</h2><p class="notice">AGENTS.md supplies shared product invariants. Select the relevant Culmina skill; inspect its supporting source and actual caller. References, implementation files and optional external tools are not additional design authorities.</p><div id="five-skills"></div><h2>Independent production code review</h2><p class="muted">Read-only delegated review. Confirmed source discrepancies and unverified visual risks are separate. No whole-app compliance score.</p><div id="code-review"></div><h2>Skill relevance review</h2><div id="skill-review"></div><p><a href="skills-review.json">Review evidence</a> · <a href="code-design-audit.json">Previous independent code review</a></p><details><summary>Previous inventory — technical archive, not project policy</summary><p>The former 34-item catalogue mixed skills, code owners, references and compatibility pointers. It has been replaced by the five-skill structure above. External tool installations were not uninstalled.</p><a href="design-catalog.json">Archived discovery inventory</a></details></section>
<section id="view-components" role="tabpanel" aria-labelledby="tab-components" hidden><h2>Real Flutter components</h2><p class="notice">Exact current Flutter pixels, bundled Geist and MaterialIcons. Illustrative inputs. Website theme changes the page and selects matching specimens; Component theme can override the PNG specimen independently. Gallery/reference availability does not prove production adoption or device acceptance.</p><p class="muted">Inventory: all 61 public widget classes in shared/ and Library/Settings parts, plus additional scientific views. Private screen subwidgets are represented by the screen map, not exhaustively catalogued here.</p><div class="controls"><input id="component-search" type="search" aria-label="Search components" placeholder="Find switch, button, StatusBlock…"><select id="component-theme" aria-label="Component theme"><option value="light">Light</option><option value="dark">Dark</option><option value="field">Field Red</option></select></div><p id="component-count" class="muted" aria-live="polite"></p><div class="specimen-grid" id="specimens"></div><h2>Scientific and composed views</h2><p class="muted">Existing source-owned calculations, not recreated browser charts. Full production-context screenshots retain surrounding labels and provenance.</p><div class="specimen-grid" id="science-specimens"></div><details><summary>Component coverage inventory</summary><div id="component-inventory"></div></details><p><a href="component-manifest.json">Render provenance and scoped component coverage</a> · <a href="component-QA.json">Verification results and limits</a></p></section>
<dialog id="specimen-modal"><div class="modalhead"><h2 id="specimen-title"></h2><button type="button" id="specimen-close">Close</button></div><img id="specimen-image" alt=""><p id="specimen-meta" class="muted"></p></dialog>'''
base=base.replace('</main>',section+'</main>')
runtime=(O/'refined-runtime.js').read_text(encoding='utf-8')
base=base.replace('</html>','<script id="refined-data" type="application/json">'+json.dumps(data,ensure_ascii=False).replace('</','<\\/')+'</script><script>'+runtime+'</script></html>')
(O/'index.html').write_text(base.replace('__MAP_DATA__',json.dumps(M,ensure_ascii=False).replace('</','<\\/')),encoding='utf-8')
print(json.dumps({'skills':5,'specimens':len(groups),'images':len(samples),'science':len(science),'inventory':len(inventory),'missing':[i['name'] for i in inventory if not i['specimens']]}))
import sys
subprocess.run([sys.executable, str(O.parent/'style_atlases.py')], check=True, cwd=R)
