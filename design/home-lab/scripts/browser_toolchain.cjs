// Development tooling only; no app dependency or browser profile is modified.
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const toolsRoot = process.env.CULMINA_PLAYWRIGHT_TOOLS || path.join(os.homedir(), '.codex', 'tools', 'culmina-playwright');
const modulePath = process.env.CULMINA_PLAYWRIGHT || path.join(toolsRoot, 'node_modules', 'playwright');
if (!fs.existsSync(path.join(modulePath, 'package.json'))) {
  throw new Error('Pinned Playwright tooling is missing. See docs/AI_TOOL_CAPABILITIES_2026_10_20.md; use the dedicated tools install, not an npx cache.');
}
const version = require(path.join(modulePath, 'package.json')).version;
if (version !== '1.64.1') throw new Error(`Expected stable Playwright 1.64.1; found ${version}. Update the tooling pin and evidence together.`);
process.env.PLAYWRIGHT_BROWSERS_PATH ||= path.join(toolsRoot, 'browsers');
const {chromium} = require(modulePath);

function launchChromium(options = {}) {
  const launch = {...options};
  if (process.env.CULMINA_BROWSER) launch.channel = process.env.CULMINA_BROWSER;
  else if (process.env.CULMINA_EXECUTABLE_PATH) launch.executablePath = process.env.CULMINA_EXECUTABLE_PATH;
  else launch.executablePath = chromium.executablePath();
  return chromium.launch(launch);
}

module.exports = {chromium, launchChromium, toolchainInfo: {version, modulePath, toolsRoot, executablePath: chromium.executablePath()}};
