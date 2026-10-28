from pathlib import Path
import hashlib, json, re, shutil

ROOT = Path.cwd().resolve()
HUB = ROOT / 'design/reference'
HUB.mkdir(parents=True, exist_ok=True)
moves = {'build/design-rules-web': 'design-rules-web', '.audit/app-map-20261028': 'app-map-20261028', '.audit/atlas': 'atlas', 'build/components-20261028': 'evidence/components-20261028', 'build/app-map-20261028': 'evidence/app-map-20261028'}
inventory = []
for old, new in moves.items():
    source, target = ROOT / old, HUB / new
    assert source.is_dir() and not target.exists(), (source, target)
    # Verify every byte after relocation, including historical evidence.
    hashes = {p.relative_to(source).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in source.rglob('*') if p.is_file()}
    assert source.is_relative_to(ROOT) and target.resolve().is_relative_to(HUB)
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.move(str(source), str(target))
    assert all(hashlib.sha256((target / p).read_bytes()).hexdigest() == h for p,h in hashes.items())
    inventory.append(dict(previous=old, current='design/reference/'+new, files=len(hashes), hashes=hashes))
(HUB/'relocation.json').write_text(json.dumps(inventory, indent=2), encoding='utf-8')

shared = HUB/'shared'
(shared/'fonts').mkdir(parents=True)
shutil.copy2(ROOT/'assets/fonts/Geist.ttf', shared/'fonts/Geist.ttf')
root_lookup = "next(p for p in Path(__file__).resolve().parents if (p/'pubspec.yaml').exists() and (p/'AGENTS.md').exists())"
for p in list((HUB/'design-rules-web').glob('*.py')) + list((HUB/'app-map-20261028').glob('*.py')):
    s=p.read_text(encoding='utf-8')
    s=s.replace('OUT.parents[1]', root_lookup).replace('out.parents[1]', root_lookup).replace('O.resolve().parents[1]', root_lookup).replace('Path(__file__).resolve().parents[2]', root_lookup)
    s=s.replace("ROOT/'.audit/atlas/", "ROOT/'design/reference/atlas/").replace("ROOT/'.audit/app-map-20261028/", "ROOT/'design/reference/app-map-20261028/")
    s=s.replace("'build/components-20261028/", "'design/reference/evidence/components-20261028/").replace("'build/app-map-20261028/", "'design/reference/evidence/app-map-20261028/")
    s=s.replace("'/.audit/app-map-20261028/", "'../app-map-20261028/")
    p.write_text(s, encoding='utf-8')

# Fix live URLs; source snapshots and original provenance remain historical records.
rules=HUB/'design-rules-web'
p=rules/'index.html';s=p.read_text(encoding='utf-8')
s=s.replace('/.audit/app-map-20261028/', '../app-map-20261028/').replace('/.audit/atlas/', '../atlas/').replace('python build/design-rules-web/build_catalog.py','python design/reference/design-rules-web/build_catalog.py')
s=s.replace('href="studio.css"','href="studio.css"><link rel="stylesheet" href="../shared/site.css"><script src="../shared/theme.js"></script><link rel="icon" href="data:,"')
s=s.replace('</nav></header>', '<label class="website-theme">Website theme<select id="website-theme" aria-label="Website theme"><option value="light">Light</option><option value="dark">Dark</option></select></label></nav></header>',1)
p.write_text(s,encoding='utf-8')
p=rules/'studio.css';s=p.read_text(encoding='utf-8').replace("url('/assets/fonts/Geist.ttf')", "url('../shared/fonts/Geist.ttf')")
# Replace shell colors with semantic variables, preserving the specimen-owned roles.
palette={'#191919':'var(--site-bg)','#ebebea':'var(--site-text)','#a5a5a3':'var(--site-muted)','#2f2f2f':'var(--site-line)','#252525':'var(--site-raised)','#202020':'var(--site-panel)','#8f8f8d':'var(--site-tertiary)','#6f6f6d':'var(--site-control)'}
scope=re.search(r'\.theme-scope\{[^}]+\}',s).group()
s=s.replace(scope,'__SPECIMEN_ROLES__')
for a,b in palette.items():s=s.replace(a,b)
s=s.replace('__SPECIMEN_ROLES__',scope)
p.write_text(s,encoding='utf-8')

mapdir=HUB/'app-map-20261028'
for filename in ['refined-runtime.js','index.html']:
    p=mapdir/filename;s=p.read_text(encoding='utf-8')
    s=re.sub(r"let siteTheme='dark';.*?setTheme\(\);setTheme\(\);",'',s,flags=re.S)
    # The theme block is three lines; keep the component rendering code intact.
    start=s.find("let siteTheme='dark';")
    if start>=0:
        end=s.index('const associations=',start)
        s=s[:start]+s[end:]
    p.write_text(s,encoding='utf-8')

# Atlas wrapper shared by generated and checked-in HTML. Running the decorator
# after the existing map generator keeps regeneration repeatable.
for old,new in list(moves.items())[:3]:
    location=ROOT/old;location.mkdir(parents=True,exist_ok=True)
    target='../../design/reference/'+new+'/'
    (location/'index.html').write_text('<!doctype html><meta charset="utf-8"><title>Culmina reference moved</title><p>This reference has moved to <a id="destination" href="'+target+'">design/reference/'+new+'</a>.</p><script>const a=document.getElementById("destination");location.replace(a.href+location.search+location.hash)</script>',encoding='utf-8')
print('Relocated and byte-verified',sum(i['files'] for i in inventory),'files')
