// Web reference capture + computed-style dump for the Hybrid transfer.
// Usage: node webcap.cjs spec.json outDir
// spec: {base, shots:[{id,file,query,width,height,theme,steps:[...],dump}]}
// Read-only against design/home-lab; isolated contexts; no storage persisted.
const repo = process.env.REPO;
// HT_PLAYWRIGHT: a local Playwright package path where the pinned toolchain is
// absent (the version used is written to the manifest).
const launchChromium = process.env.HT_PLAYWRIGHT
  ? () => require(process.env.HT_PLAYWRIGHT).chromium.launch()
  : require(repo + '/design/home-lab/scripts/browser_toolchain.cjs').launchChromium;
const playwrightVersion = process.env.HT_PLAYWRIGHT
  ? require(process.env.HT_PLAYWRIGHT + '/package.json').version
  : '1.64.1 (pinned)';
const fs = require('node:fs'), path = require('node:path');
const [specFile, outDir] = process.argv.slice(2);
const spec = JSON.parse(fs.readFileSync(specFile, 'utf8'));
fs.mkdirSync(outDir, {recursive: true});
const base = spec.base || 'http://127.0.0.1:4197/';

function dumpStyles(frameSel) {
  const frame = document.querySelector(frameSel);
  const sb = frame.querySelector('.android-statusbar');
  const top = sb ? sb.getBoundingClientRect().bottom : frame.getBoundingClientRect().top;
  const left = frame.getBoundingClientRect().left;
  const out = [];
  const walker = frame.querySelectorAll('*');
  for (const e of walker) {
    if (e.closest('.android-statusbar,.android-gesture')) continue;
    const r = e.getBoundingClientRect();
    if (r.width === 0 || r.height === 0) continue;
    const cs = getComputedStyle(e);
    if (cs.visibility === 'hidden' || cs.display === 'none') continue;
    const own = [...e.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim()).map(n => n.textContent.trim()).join(' ');
    const ctl = /^(BUTTON|INPUT|SELECT|TEXTAREA|A|SUMMARY|LABEL|svg|HR)$/i.test(e.tagName);
    const bordered = ['Top','Bottom','Left','Right'].some(s => parseFloat(cs['border' + s + 'Width']) > 0);
    const bg = cs.backgroundColor !== 'rgba(0, 0, 0, 0)' || cs.backgroundImage !== 'none';
    if (!own && !ctl && !bordered && !bg) continue;
    const item = {
      tag: e.tagName.toLowerCase(), cls: (e.getAttribute('class') || '').slice(0, 60), id: e.id || undefined,
      text: own.slice(0, 80) || undefined,
      x: +(r.left - left).toFixed(1), y: +(r.top - top).toFixed(1), w: +r.width.toFixed(1), h: +r.height.toFixed(1),
    };
    if (own || ctl) Object.assign(item, {font: cs.fontFamily.split(',')[0].replace(/['"]/g, ''), size: cs.fontSize, weight: cs.fontWeight, lh: cs.lineHeight, ls: cs.letterSpacing, color: cs.color, var: cs.fontVariationSettings !== 'normal' ? cs.fontVariationSettings : undefined, num: cs.fontVariantNumeric !== 'normal' ? cs.fontVariantNumeric : undefined});
    if (e.tagName.toLowerCase() === 'svg') { item.stroke = cs.strokeWidth; item.d = [...e.querySelectorAll('path')].map(x => x.getAttribute('d')).join(' | ').slice(0, 120); item.svgColor = cs.stroke !== 'none' ? cs.stroke : cs.fill; }
    if (bg) item.bg = cs.backgroundImage !== 'none' ? cs.backgroundImage.slice(0, 160) : cs.backgroundColor;
    if (bordered) item.border = ['Top','Right','Bottom','Left'].map(s => cs['border' + s + 'Width'] + ' ' + cs['border' + s + 'Color']).join(' | ');
    if (cs.borderRadius !== '0px') item.radius = cs.borderRadius;
    const pad = cs.padding; if (pad !== '0px') item.pad = pad;
    out.push(item);
  }
  return out;
}

(async () => {
  const browser = await launchChromium();
  const manifest = [];
  for (const shot of spec.shots) {
    const ctx = await browser.newContext({viewport: {width: 1200, height: 1000}, deviceScaleFactor: shot.dpr || 1});
    const p = await ctx.newPage();
    const errors = [];
    p.on('pageerror', e => errors.push(String(e)));
    const q = new URLSearchParams({variant: 'blend', font: 'native', theme: shot.theme || 'light', scale: '1', ...(shot.query || {})});
    await p.goto(base + shot.file + '?' + q);
    await p.evaluate(() => document.fonts.ready);
    await p.addStyleTag({content: 'html{scroll-behavior:auto!important} *,*::before,*::after{transition:none!important;animation:none!important}'});
    const frameSel = shot.frame || '.android-device';
    await p.locator(frameSel).first().waitFor();
    // Set the phone width (and the app-area-matching height) on the frame itself.
    await p.locator(frameSel).first().evaluate((e, [w, h]) => {
      e.style.width = w + 'px'; e.style.maxWidth = w + 'px'; e.style.flexShrink = '0';
      if (h) { e.style.height = h + 'px'; e.style.maxHeight = h + 'px'; e.style.minHeight = h + 'px'; e.style.flex = 'none'; }
    }, [shot.width || 375, shot.height || null]);
    if (shot.css) await p.addStyleTag({content: shot.css});
    await p.waitForTimeout(150);
    for (const step of shot.steps || []) {
      if (step.click) await p.locator(step.click).first().click();
      if (step.fill) await p.locator(step.fill[0]).first().fill(step.fill[1]);
      if (step.check) await p.locator(step.check).first().check();
      if (step.press) await p.keyboard.press(step.press);
      if (step.scroll) await p.locator(step.scroll[0]).first().evaluate((e, y) => { e.scrollTop = y; }, step.scroll[1]);
      if (step.scrollTo) await p.locator(step.scrollTo).first().evaluate(e => {
        const s = e.closest('.android-scroll,.phone-viewport,.app-content') || document.scrollingElement; const r = e.getBoundingClientRect(), sr = s.getBoundingClientRect(); s.scrollTop += r.top - sr.top - 8; });
      if (step.eval) await p.evaluate(step.eval);
      if (step.wait) await p.waitForTimeout(step.wait);
      await p.waitForTimeout(120);
    }
    const frame = p.locator(frameSel).first();
    const rects = await frame.evaluate(e => {
      const Y = scrollY, X = scrollX; const r0 = e.getBoundingClientRect(); const r = {left: r0.left + X, top: r0.top + Y, width: r0.width, height: r0.height}; const sb = e.querySelector('.android-statusbar'); const g = e.querySelector('.android-gesture');
      return {frame: r, top: sb ? sb.getBoundingClientRect().bottom + Y : r.top, bottom: g ? g.getBoundingClientRect().top + Y : r.top + r.height,
        font: getComputedStyle(e).fontFamily, geist: document.fonts.check('16px Geist'), serif: document.fonts.check('25px "Source Serif 4"')};
    });
    const clip = {x: rects.frame.left + 1, y: rects.top, width: rects.frame.width - 2, height: rects.bottom - rects.top};
    if (shot.fullFrame) Object.assign(clip, {x: rects.frame.left, y: rects.frame.top, width: rects.frame.width, height: rects.frame.height});
    const png = path.join(outDir, shot.id + '.png');
    await p.screenshot({path: png, clip, fullPage: true, animations: 'disabled'});
    if (shot.dump !== false) fs.writeFileSync(path.join(outDir, shot.id + '.json'), JSON.stringify(await p.evaluate(dumpStyles, frameSel), null, 0).replace(/\},\{/g, '},\n{'));
    manifest.push({id: shot.id, url: base + shot.file + '?' + q, steps: shot.steps || [], phone: [rects.frame.width, rects.frame.height], appArea: [clip.width, clip.height], dpr: shot.dpr || 1, font: rects.font, geistLoaded: rects.geist, serifLoaded: rects.serif, errors});
    await ctx.close();
  }
  await browser.close();
  fs.writeFileSync(path.join(outDir, 'web-manifest-' + (spec.name || 'run') + '.json'), JSON.stringify({webSha: '86873ce343160c860706091e12b257090cc96d94', playwright: playwrightVersion, studio: [1200, 1000], zoom: 1, textScale: 1, shots: manifest}, null, 1));
  console.log(JSON.stringify(manifest.map(m => [m.id, m.appArea, m.errors.length])));
})().catch(e => { console.error(e); process.exit(1); });
