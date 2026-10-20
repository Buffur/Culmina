import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { sha256 } from './prepare.mjs';

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const evidence = path.join(repo, 'docs/design/migration/evidence/matched');
const source = JSON.parse(await readFile(path.join(evidence, 'browser-source-manifest.json')));
const log = await readFile(path.join(evidence, 'browser-capture.log'), 'utf8');
const capture = JSON.parse(log.split(/\r?\n/).find(line => line.startsWith('{"capturedAtUtc"')));
for (const entry of source.source) {
  const current = await readFile(path.join(repo, 'design/home-lab', entry.path));
  if (sha256(current) !== entry.sha256) throw new Error(`Original source changed: ${entry.path}`);
}
const screenshots = [];
for (const name of [...new Set(capture.records.map(record => record.name))].sort()) {
  const data = await readFile(path.join(evidence, name));
  screenshots.push({ name, bytes: data.length, sha256: sha256(data),
    width: data.readUInt32BE(16), height: data.readUInt32BE(20) });
}
const manifest = {
  ...capture, fixtureSha256: source.fixture.sha256,
  captureRunnerSha256: sha256(await readFile(path.join(repo, 'tool/design/comparison/capture-cli.js'))),
  tooling: { launcher: 'pinned PowerShell Playwright CLI', cli: '0.1.22', playwright: '1.64.1',
    screenshot: 'locator screenshot, scale css, animations disabled; no pixel resizing' },
  originalSourceReverified: source.source.length,
  originalSourceChanged: false,
  screenshotCount: screenshots.length, screenshots,
  matching: 'Canonical native initial data for eight roots; composition differences remain. No parity acceptance.',
};
await writeFile(path.join(evidence, 'browser-capture-manifest.json'), JSON.stringify(manifest, null, 2));
console.log(JSON.stringify({ screenshots: screenshots.length,
  all412x915: screenshots.every(x => x.width === 412 && x.height === 915),
  originalFilesVerified: source.source.length, fixtureSha256: source.fixture.sha256 }, null, 2));
