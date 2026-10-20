"""Refresh the lab's licensed fonts from official Google Fonts sources."""
import hashlib
from datetime import datetime, timezone
import json
import pathlib
import re
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
FAMILIES = [
    ('Inter', 'inter', 'Нейтральний робочий простір'),
    ('Roboto', 'roboto', 'Знайомий і функціональний'),
    ('Manrope', 'manrope', 'М’яка геометрія'),
    ('IBM Plex Sans', 'ibmplexsans', 'Характер у деталях'),
    ('Source Serif 4', 'sourceserif4', 'Редакційний акцент для заголовків'),
    ('Open Sans', 'opensans', 'Відкриті форми, звична читабельність'),
    ('Noto Sans', 'notosans', 'Універсальний багатомовний UI'),
    ('Source Sans 3', 'sourcesans3', 'Гуманістичний, компактний і спокійний'),
    ('Geist', 'geist', 'Точний сучасний інтерфейс'),
    ('Onest', 'onest', 'М’які форми без зайвої округлості'),
    ('Golos Text', 'golostext', 'Кирилиця та щільні інформаційні екрани'),
]
USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/130.0.0.0 Safari/537.36'


def get(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': USER_AGENT}), timeout=30).read()


def main():
    font_dir = ROOT / 'fonts'
    font_dir.mkdir(exist_ok=True)
    metadata_url = 'https://fonts.google.com/metadata/fonts'
    metadata = json.loads(get(metadata_url).decode().lstrip(")]}'\n"))
    metadata = {item['family']: item for item in metadata['familyMetadataList']}
    styles, manifest = [], []
    for family, slug, use in FAMILIES:
        css_url = 'https://fonts.googleapis.com/css2?family=' + urllib.parse.quote(family) + ':wght@400..700&display=swap'
        css = get(css_url).decode()
        urls = list(dict.fromkeys(re.findall(r'https://fonts.gstatic.com/[^)\s]+', css)))
        files = []
        for index, url in enumerate(urls):
            suffix = '.woff2' if '.woff2' in url else '.ttf'
            filename = f'{slug}-{index}{suffix}'
            content = get(url)
            (font_dir / filename).write_bytes(content)
            files.append({'file': filename, 'sha256': hashlib.sha256(content).hexdigest()})
            css = css.replace(url, './' + filename)
        license_url = f'https://raw.githubusercontent.com/google/fonts/main/ofl/{slug}/OFL.txt'
        (font_dir / f'{slug}-OFL.txt').write_bytes(get(license_url))
        styles.append(css)
        info = metadata[family]
        manifest.append({'family': family, 'slug': slug, 'use': use, 'cssSource': css_url,
                         'licenseSource': license_url, 'metadataSource': metadata_url,
                         'metadataDate': datetime.now(timezone.utc).date().isoformat(), 'popularityIndex': info.get('popularity'),
                         'subsets': info['subsets'], 'files': len(files), 'assets': files})
        print(f'{family}: {len(files)} files; metadata popularity field {info.get("popularity")}')
    (font_dir / 'fonts.css').write_text('\n'.join(styles), encoding='utf-8')
    (font_dir / 'sources.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
