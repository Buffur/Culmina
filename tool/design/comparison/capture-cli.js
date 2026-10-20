// Run through the pinned Playwright CLI, after opening/snapshotting the adapter.
// This only normalizes the preview host frame to the Flutter host canvas.
async (page) => {
  const startedAtUtc = new Date().toISOString();
  const base = 'http://127.0.0.1:4174/';
  const output = 'docs/design/migration/evidence/matched';
  const framing = `
    .planner-page>.lab-toolbar,.planner-page>.plan-preview-bar,.skip-link,.skip{display:none!important}
    .planner-page{padding:0!important;margin:0!important}
    .planner-page>.android-device{width:412px!important;height:915px!important;min-height:915px!important;max-height:915px!important;flex:none!important;margin:0!important;border:0!important;border-radius:0!important}
    .android-statusbar,.android-gesture{display:none!important}
    body:not(.planner-page)>header,body:not(.planner-page)>footer,
    body:not(.planner-page)>main>:not(#concepts),#concepts>:not(#concept-grid),
    .concept:not([data-variant="blend"]),.concept-heading,.concept-summary{display:none!important}
    body:not(.planner-page),body:not(.planner-page)>main,#concepts,#concept-grid,
    .concept,.preview-well,.app-frame{margin:0!important;padding:0!important;border:0!important;border-radius:0!important}
    #concept-grid{display:block!important;width:412px!important;max-width:none!important}
    .concept-grid .phone-viewport{width:412px!important;height:915px!important;min-height:915px!important;max-height:915px!important}
    .concept-grid .app-brand-row:before,.concept-grid .app-nav:after{display:none!important}
  `;
  await page.setViewportSize({ width: 412, height: 915 });
  // Each page begins at the canonical initial fixture. The prototype persists
  // editor checkpoints across navigation; an invalid-state reference must not
  // become the following root's initial state.
  await page.addInitScript(() => {
    localStorage.clear();
    sessionStorage.clear();
  });
  const records = [];
  const diagnostics = [];
  page.on('pageerror', error => diagnostics.push({ kind: 'pageerror', message: error.message }));
  page.on('console', message => {
    if (['error', 'warning'].includes(message.type()))
      diagnostics.push({ kind: message.type(), message: message.text() });
  });
  async function capture(name, url, frameSelector, state = 'initial root') {
    await page.evaluate(() => document.fonts.ready);
    await page.locator(frameSelector).screenshot({
      path: `${output}/${name}`, scale: 'css', animations: 'disabled',
    });
    records.push(await page.evaluate(({ name, url, frameSelector, state }) => ({
      name, url, state, viewport: [innerWidth, innerHeight],
      frame: document.querySelector(frameSelector).getBoundingClientRect().toJSON(),
      font: getComputedStyle(document.querySelector(frameSelector)).fontFamily,
      fontLoaded: document.fonts.check('16px Geist'),
      bodyOverflow: document.documentElement.scrollWidth > innerWidth,
      scale: getComputedStyle(document.documentElement).getPropertyValue('--text-scale'),
      visibleText: document.querySelector(frameSelector).innerText,
    }), { name, url, frameSelector, state }));
  }
  for (const theme of ['light', 'dark', 'field']) {
    await page.emulateMedia({ colorScheme: theme === 'dark' ? 'dark' : 'light' });
    for (const scale of ['1', '2']) {
      for (const view of ['home', 'plan', 'night', 'moon', 'weather', 'logbook', 'library', 'settings']) {
        const route = view === 'home' ? 'index.html?view=wide'
          : view === 'plan' ? 'plan.html?from=home'
          : ['night', 'moon', 'weather'].includes(view) ? `conditions.html?view=${view}`
          : `workspace.html?tab=${view}`;
        const url = `${base}${route}&variant=blend&font=Geist&night=2026-11-10&theme=${theme}&scale=${scale}`;
        await page.goto(url);
        const frameSelector = view === 'home' ? '[data-variant="blend"] .phone-viewport' : '.android-device';
        await page.locator(frameSelector).waitFor();
        if (view === 'plan') await page.locator('[data-edit-block]').first().waitFor();
        if (['night', 'moon', 'weather'].includes(view)) await page.locator('#viewed-night').waitFor();
        if (['logbook', 'library', 'settings'].includes(view)) await page.locator('#workspace-main > :first-child').waitFor();
        await page.evaluate(() => document.fonts.ready);
        await page.addStyleTag({ content: framing });
        const name = `browser-${view}-${theme}${scale === '1' ? '100' : '200'}.png`;
        await capture(name, url, frameSelector);
        if (view === 'weather') {
          await page.locator('.hourly-section').evaluate(element =>
            element.scrollIntoView({ block: 'start', behavior: 'instant' }));
          const charts = `browser-weather-charts-${theme}${scale === '1' ? '100' : '200'}.png`;
          await capture(charts, url, frameSelector, 'hourly section start');
        }
        if (view === 'settings') {
          for (const section of ['appearance', 'planning', 'privacy', 'backup']) {
            // Source settings.js row() exposes these stable IDs.
            await page.goto(url);
            await page.locator(`#settings-open-${section}`).waitFor();
            await page.addStyleTag({ content: framing });
            await page.locator(`#settings-open-${section}`).click();
            await capture(`browser-settings_${section}-${theme}${scale === '1' ? '100' : '200'}.png`,
              url, frameSelector, `settings ${section}`);
          }
        }
        if (view === 'plan') {
          await page.locator('[data-edit-block]').first().click();
          await page.locator('#block-editor').waitFor();
          await capture(`browser-plan_editor-${theme}${scale === '1' ? '100' : '200'}.png`,
            url, frameSelector, 'first actual fixture block editor; no change applied');
          await page.locator('#block-editor input[name="exposure"]').fill('invalid');
          await page.locator('[data-apply-screen]').click();
          await capture(`browser-plan_editor_invalid-${theme}${scale === '1' ? '100' : '200'}.png`,
            url, frameSelector, 'invalid exposure; browser validation UI only; no change applied');
        }
      }
    }
  }
  return { capturedAtUtc: new Date().toISOString(), startedAtUtc, framing,
    storageIsolation: 'local/session storage cleared on each document before canonical fixture module initialization',
    diagnostics, records };
}
