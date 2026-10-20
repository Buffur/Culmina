"""Read-only provenance and semantic completeness check for the Home Lab."""
import argparse
import copy
import hashlib
import json
from pathlib import Path

LAB = Path(__file__).resolve().parents[1]
REPO = LAB.parents[1]


def source_drift(inventory, root):
    problems = []
    for entry in inventory['sources']:
        path = root / entry['path']
        if not path.is_file():
            problems.append(f"Missing source: {entry['path']}")
        elif (hashlib.sha256(path.read_bytes()).hexdigest() != entry['sha256']
              or path.read_text(encoding='utf-8') != entry['content']):
            problems.append(f"Changed source: {entry['path']}")
    expected = {p.relative_to(root).as_posix() for p in (root / 'lib/core/theme').glob('*.dart')}
    exported = {entry['path'] for entry in inventory['sources']}
    problems.extend(f'Missing theme export: {path}' for path in sorted(expected - exported))
    return problems


def check(inventory, config, root):
    problems = source_drift(inventory, root)
    described = set(config['roles'])
    for theme, values in config['themes'].items():
        if set(values) != described:
            problems.append(f'{theme}: usage descriptions and values differ')
    for theme, values in inventory['palette'].items():
        if set(values) != set(config['paletteUsage']):
            problems.append(f'{theme}: palette usage coverage differs')
    for background, foreground in config['rolePairings'].items():
        if background not in described or foreground not in described:
            problems.append(f'Unknown pairing: {background}/{foreground}')
    if set(config['proposalRadius']) != set(config['variants']):
        problems.append('Variant radius coverage differs')
    for name, exported in [('space', 'spacing'), ('productionRadius', 'radii')]:
        expected = {item['name']: item['value'] for item in inventory[exported]}
        if config[name] != expected:
            problems.append(f'{name}: production geometry snapshot differs')
    if any(not text.strip() for text in [*config['roles'].values(), *config['paletteUsage'].values()]):
        problems.append('Empty usage description')
    return problems


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--self-test', action='store_true', help='Also reject deliberately stale/missing metadata in memory')
    args = parser.parse_args()
    inventory = json.loads((LAB / 'inventory.json').read_text(encoding='utf-8'))
    config = json.loads((LAB / 'tokens.json').read_text(encoding='utf-8'))
    problems = check(inventory, config, REPO)
    if args.self_test:
        stale = copy.deepcopy(inventory)
        stale['sources'][0]['sha256'] = 'deliberately stale'
        assert any('Changed source:' in item for item in source_drift(stale, REPO))
        stale['sources'][0]['path'] = 'missing-design-audit-source'
        assert any('Missing source:' in item for item in source_drift(stale, REPO))
        incomplete = copy.deepcopy(config)
        del incomplete['roles']['action']
        assert any('usage descriptions' in item for item in check(inventory, incomplete, REPO))
    print(json.dumps({'result': 'FAIL' if problems else 'PASS', 'sources': len(inventory['sources']),
                      'proposalRoles': len(config['roles']), 'paletteUsage': len(config['paletteUsage']),
                      'selfTest': args.self_test, 'problems': problems}))
    raise SystemExit(bool(problems))


if __name__ == '__main__':
    main()
