from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit,unquote
import hashlib
import json

out=Path(__file__).resolve().parent
root=next(p for p in Path(__file__).resolve().parents if (p/'pubspec.yaml').exists() and (p/'AGENTS.md').exists())
data=json.loads((out/'catalog.json').read_text(encoding='utf-8'))
missing=[]
class Check(HTMLParser):
    def handle_starttag(self,tag,attrs):
        for k,v in attrs:
            if k in ('href','src') and v and not urlsplit(v).scheme:
                path=unquote(urlsplit(v).path)
                if path and not ((root/path.lstrip('/')) if path.startswith('/') else (out/path)).exists():
                    missing.append(v)
Check().feed((out/'index.html').read_text(encoding='utf-8'))
for source in data['sources']:
    assert hashlib.sha256((root/source['path']).read_text(encoding='utf-8').encode('utf-8')).hexdigest()==source['sha256'],source['path']
    assert (out/source['href']).exists()
assert {r['category'] for r in data['rules']}=={'components','rules','spacing','tokens','typography'}
native=data['nativeGallery']
for sample in native['samples']+native['science']:
    assert (out/sample['file']).exists(),sample['file']
for folder in ['app-map-20261028','atlas']:
    base=out.parent/folder
    class AtlasCheck(HTMLParser):
        def handle_starttag(self,tag,attrs):
            for k,v in attrs:
                if k in ('href','src') and v and not urlsplit(v).scheme:
                    path=unquote(urlsplit(v).path)
                    if path and not (base/path).exists(): missing.append(folder+': '+v)
    AtlasCheck().feed((base/'index.html').read_text(encoding='utf-8'))
preserved=0
for group in json.loads((out.parent/'relocation.json').read_text(encoding='utf-8')):
    for name,digest in group['hashes'].items():
        if Path(name).suffix.lower() not in ('.png','.jpg','.ttf') and not name.endswith('manifest.json'): continue
        file=root/group['current']/name
        assert hashlib.sha256(file.read_bytes()).hexdigest()==digest,file
        preserved+=1
snapshots=json.loads((out.parent/'source-snapshots.json').read_text(encoding='utf-8'))['snapshots']
for snapshot in snapshots:
    file=out.parent/snapshot['current']
    assert hashlib.sha256(file.read_bytes()).hexdigest()==snapshot['sha256'],file
extra=out.parent/'evidence/source-audit-20261028'
audit_files=json.loads((extra/'manifest.json').read_text(encoding='utf-8'))['files']
for entry in audit_files:
    assert hashlib.sha256((extra/entry['file']).read_bytes()).hexdigest()==entry['sha256'],entry['file']
assert not missing,missing
result=dict(sourceSnapshots=len(data['sources']),indexedGuidance=len(data['rules']),themes=list(data['themes']),namedTypographyRoles=len(data['typography']),materialRoles=len(data['materialTypography']),nativeSamples=len(native['samples']),scientificNativeExamples=len(native['science']),missingLinks=missing,preservedImagesAndManifests=preserved,preservedSourceSnapshots=len(snapshots),preservedAuditFiles=len(audit_files),status='pass',boundary='Filesystem/source checks only. Browser checks are recorded in ../REVIEW.md. Native files were reused, not rerendered.')
(out/'validation.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps(result,indent=2))
