"""Reapply the shared shell after regenerating either atlas. Idempotent."""
from pathlib import Path
import re

HUB = Path(__file__).resolve().parent

# Source snapshots keep their text and hashes; their viewer follows the site.
for folder in [HUB/'design-rules-web/sources', HUB/'app-map-20261028/design-sources']:
    for page in folder.glob('*.html'):
        text = page.read_text(encoding='utf-8')
        if 'data-source-view' not in text:
            text = text.replace('</style>', '</style><link data-source-view="true" rel="stylesheet" href="../../shared/site.css"><script src="../../shared/theme.js"></script><body class="source-view">', 1)
            page.write_text(text, encoding='utf-8')

def top(title):
    return f'''<header class="reference-top"><a class="brand" href="../design-rules-web/#overview">Culmina <span>{title}</span></a><nav aria-label="Reference sites"><a href="../design-rules-web/#overview">Design rules</a><a href="../app-map-20261028/index.html#atlas">Application atlas</a><a href="../atlas/index.html">Historical atlas</a><label class="website-theme">Website theme<select id="website-theme" aria-label="Website theme"><option value="light">Light</option><option value="dark">Dark</option></select></label></nav></header>'''

for name in ['app-map-20261028', 'atlas']:
    p = HUB/name/'index.html'
    s = p.read_text(encoding='utf-8')
    if 'data-reference-shell' in s and '../shared/site.css' not in s:
        s = s.replace(' data-reference-shell="true"', '')
    if 'data-reference-shell' in s:
        continue
    # Historical captures and manifest are unchanged; only the viewer changes.
    s = re.sub(r'<style>.*?</style>', '', s, flags=re.S) if name == 'atlas' else s
    shell = '<link rel="stylesheet" href="../shared/site.css"><link rel="icon" href="data:,"><script src="../shared/theme.js"></script>'
    s = s.replace('<html ', '<html data-reference-shell="true" ', 1)
    anchor = '<header>' if name.startswith('app-map') else '<main>'
    s = s.replace(anchor, shell + '<body class="'+('atlas-site' if name.startswith('app-map') else 'historical-site')+'">'+top('Application atlas' if name.startswith('app-map') else 'Historical atlas')+anchor, 1)
    if name.startswith('app-map'):
        s = s.replace('<header>','''<div class="atlas-layout"><aside class="atlas-sidebar"><p>Application reference</p><nav aria-label="Atlas sections"><a href="#map" data-view="map">Screen map</a><a href="#atlas" data-view="atlas">Refreshed Atlas</a><a href="#coverage" data-view="coverage">Coverage & provenance</a><a href="#design" data-view="design">Culmina design skills</a><a href="#components" data-view="components">Components</a></nav><p class="sidebar-note">Source-traced navigation.<br>Real Flutter host captures.<br>Five Culmina design owners.</p></aside><div class="atlas-content"><header class="atlas-heading">''',1)
        s = re.sub(r'<button type="button" id="site-theme"[^>]*>.*?</button>', '', s)
        s = re.sub(r"let siteTheme='dark';.*?(?=const associations=)",'',s,flags=re.S)
        s = s.replace('</footer>', '</footer></div></div>',1)
    # Existing documents use optional body tags; remove an old body opener.
    s = re.sub(r'<body>(?=.*<body class=)', '', s, flags=re.S)
    s = s.replace('</body>', '').replace('</html>', '</body></html>')
    p.write_text(s, encoding='utf-8')
print('Shared atlas shells ready')
