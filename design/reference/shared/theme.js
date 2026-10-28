/* Shared shell theme. Specimen controls can still be overridden independently. */
(() => {
  const key = 'culmina-reference-theme';
  const preferred = () => matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
  let current = preferred();
  try { const saved = localStorage.getItem(key); if (['light', 'dark'].includes(saved)) current = saved; } catch {}
  document.documentElement.dataset.theme = current;
  function apply(value, updateSpecimens = true) {
    current = value;
    document.documentElement.dataset.theme = value;
    try { localStorage.setItem(key, value); } catch {}
    const control = document.getElementById('website-theme');
    if (control) control.value = value;
    if (updateSpecimens) {
      const specimen = document.getElementById('theme') || document.getElementById('component-theme');
      if (specimen) { specimen.value = value; specimen.dispatchEvent(new Event('change')); }
    }
  }
  document.addEventListener('DOMContentLoaded', () => {
    apply(current);
    document.getElementById('website-theme')?.addEventListener('change', event => apply(event.target.value));
    document.querySelectorAll('[data-view]').forEach(link => link.addEventListener('click', () => document.getElementById('tab-' + link.dataset.view)?.click()));
    function active() {
      const view = location.hash.slice(1) || 'map';
      const tab = document.getElementById('tab-' + view);
      if (tab && tab.getAttribute('aria-selected') !== 'true') tab.click();
      document.querySelectorAll('.atlas-sidebar [data-view]').forEach(link => {
        if (link.dataset.view === view) link.setAttribute('aria-current', 'page');
        else link.removeAttribute('aria-current');
      });
    }
    addEventListener('hashchange', active);
    active();
  });
  addEventListener('storage', event => { if (event.key === key && ['light', 'dark'].includes(event.newValue)) apply(event.newValue); });
})();
