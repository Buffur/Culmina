"""Build a source-preserving screenshot comparison gallery and diagnostic diffs.

This is image analysis, not rendering acceptance. Pixels are never resized,
aligned, cropped, or modified in the source PNGs. A diff includes font rasterizer
and native composition differences and is not a regression score.
"""

from datetime import datetime, timezone
import hashlib
import html
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageStat

REPO = Path(__file__).resolve().parents[3]
EVIDENCE = REPO / "docs/design/migration/evidence/matched"
OUTPUT = EVIDENCE / "gallery"
ROOTS = ("home", "plan", "night", "moon", "weather", "logbook", "library", "settings")
SETTINGS = ("settings_appearance", "settings_planning", "settings_privacy", "settings_backup")
# OPEN-01: the capture-block editor, plain and with an invalid exposure.
EDITOR = ("plan_editor", "plan_editor_invalid")
THEMES = ("light", "dark", "field")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    (OUTPUT / "diagnostics").mkdir(exist_ok=True)
    notes_path = EVIDENCE / "visual-review.json"
    notes = json.loads(notes_path.read_text(encoding="utf-8")) if notes_path.exists() else {}
    records = []
    cards = []
    for surface in ROOTS + SETTINGS + EDITOR:
        for theme in THEMES:
            for scale in (100, 200):
                key = f"{surface}-{theme}{scale}"
                web = EVIDENCE / f"browser-{key}.png"
                native = EVIDENCE / "flutter" / f"{surface}_{theme}_{scale}.png"
                record = {
                    "id": key, "surface": surface, "theme": theme, "textScale": scale,
                    "kind": "root" if surface in ROOTS else "editor" if surface in EDITOR else "settings section",
                    "review": notes.get(key, notes.get(surface, {
                        "status": "awaiting visual inspection",
                        "notes": "Capture existence is not visual acceptance.",
                    })),
                }
                images = []
                for label, file in (("Approved Hybrid · browser", web), ("Flutter · host", native)):
                    entry = {"path": file.relative_to(EVIDENCE).as_posix(), "exists": file.exists()}
                    if file.exists():
                        with Image.open(file) as image:
                            entry.update(size=list(image.size), sha256=digest(file))
                        rel = "../" + entry["path"]
                        images.append(
                            f'<div><h3>{label}</h3><a href="{rel}">'
                            f'<img loading="lazy" src="{rel}" alt="{label} {key}"'
                            ' width="412" height="915"></a></div>'
                        )
                    else:
                        images.append(f'<div class="missing"><h3>{label}</h3>Capture missing</div>')
                    record["web" if file == web else "flutterHost"] = entry
                diagnostics = ""
                if web.exists() and native.exists():
                    with Image.open(web) as web_image, Image.open(native) as native_image:
                        if web_image.size == native_image.size:
                            a, b = web_image.convert("RGB"), native_image.convert("RGB")
                            difference = ImageChops.difference(a, b)
                            overlay_name = f"diagnostics/{key}-overlay.png"
                            diff_name = f"diagnostics/{key}-absolute-difference.png"
                            Image.blend(a, b, .5).save(OUTPUT / overlay_name)
                            difference.save(OUTPUT / diff_name)
                            record["diagnostics"] = {
                                "overlay": overlay_name, "absoluteDifference": diff_name,
                                "meanAbsoluteRgbDifference": ImageStat.Stat(difference).mean,
                                "interpretation": "Diagnostic only; unaligned original pixels, no pass threshold.",
                            }
                            diagnostics = (
                                '<details><summary>Pixel diagnostics (not a pass/fail score)</summary>'
                                '<p>No registration, crop, resampling or component masking. '
                                'Text antialiasing and native adaptations remain visible.</p>'
                                f'<a href="{overlay_name}">50% overlay</a> · '
                                f'<a href="{diff_name}">Absolute RGB difference</a></details>'
                            )
                        else:
                            record["diagnostics"] = {"reason": "Dimensions differ; no resizing performed."}
                review = record["review"]
                cards.append(
                    f'<section data-surface="{surface}" data-theme="{theme}" data-scale="{scale}">'
                    f'<h2>{surface.title()} · {theme} · {scale}%</h2>'
                    f'<p><strong>{html.escape(review["status"])}</strong> — '
                    f'{html.escape(review["notes"])}</p>'
                    f'<div class="pair">{"".join(images)}</div>{diagnostics}</section>'
                )
                records.append(record)
    manifest = {
        "generatedAtUtc": datetime.now(timezone.utc).isoformat(),
        "scope": "8 roots ×3 themes ×100/200%; original browser vs Flutter host; not Android acceptance",
        "pairCount": sum(r["kind"] == "root" and r["web"]["exists"] and r["flutterHost"]["exists"] for r in records),
        "supplementalPairCount": sum(r["kind"] != "root" and r["web"]["exists"] and r["flutterHost"]["exists"] for r in records),
        "expectedPairCount": 48,
        "records": records,
    }
    for name in ("browser-capture-manifest.json", "browser-source-manifest.json", "canonical-fixture.json"):
        path = EVIDENCE / name
        if path.exists():
            manifest[name] = {"path": "../" + name, "sha256": digest(path)}
    (OUTPUT / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    options = lambda values: '<option value="all">All</option>' + "".join(
        f'<option value="{value}">{value}</option>' for value in values)
    document = """<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Hybrid → Flutter · matched comparison</title>
<style>
@font-face{font-family:Geist;src:url('../../../../../../assets/fonts/Geist.ttf') format('truetype');font-weight:100 900}
*{box-sizing:border-box}body{margin:0;background:#eee;color:#222;font:16px/1.5 Geist,system-ui}
header,section{padding:24px;max-width:1400px;margin:auto}header{background:#fff}
h1{font-size:28px}h2{font-size:22px}h3{font-size:16px;font-weight:500}
nav{display:flex;flex-wrap:wrap;gap:16px;padding:12px 0}select{font:inherit;padding:8px}
.pair{display:flex;gap:24px;align-items:start;overflow-x:auto}.pair>div{flex:0 0 412px}
img{display:block;width:412px;height:auto;background:#fff}
section{border-bottom:1px solid #bbb}.missing{border:2px dashed #a00;padding:16px}
details{margin-top:16px}a{color:#12478d}section[hidden]{display:none}
</style><header><h1>Approved Hybrid → Flutter</h1>
<p>Same canonical initial fixture, selected evening 10 November 2026, Ljubljana,
Geist, metric units and 24-hour time. Each screenshot retains its original pixels.
The browser preview frame excludes simulated OS bars; the Flutter host uses a
412 ×915 logical canvas. Real Android status/navigation/IME insets belong to the
separate device evidence and are not pixel-aligned here.</p>
<p>These pairs expose composition differences. A pair is not automatically accepted:
read its review status. Subsequent edits in the isolated browser still use its
illustrative model, so editor captures establish UI state only.</p>
<p><a href="manifest.json">Pair hashes and dimensions</a> ·
<a href="../browser-capture-manifest.json">Browser capture manifest</a> ·
<a href="../browser-source-manifest.json">Reference/source hashes</a> ·
<a href="../canonical-fixture.json">Canonical native DTO</a> ·
<a href="../../../VISUAL_COMPARISON_AUDIT.md">Visual audit</a></p>
"""
    document += (
        f'<p><strong>{manifest["pairCount"]}/48 root pairs</strong>; '
        f'{manifest["supplementalPairCount"]}/24 supplemental Settings pairs.</p><nav>'
        f'<label>Screen <select id="surface">{options(ROOTS + SETTINGS)}</select></label>'
        f'<label>Theme <select id="theme">{options(THEMES)}</select></label>'
        f'<label>Text scale <select id="scale">{options((100,200))}</select></label>'
        '</nav></header>' + "".join(cards)
    )
    supplemental = sorted([
        *EVIDENCE.glob("browser-plan_editor-*.png"),
        *EVIDENCE.glob("browser-plan_editor_invalid-*.png"),
        *EVIDENCE.glob("browser-weather-charts-*.png"),
    ])
    document += (
        '<header><h2>Additional browser state references</h2><p>These states are '
        'not claimed as matched pairs. Block edits were never applied to the '
        'fixture; invalid exposure demonstrates browser validation presentation.</p><ul>'
        + "".join(f'<li><a href="../{file.name}">{file.name}</a></li>' for file in supplemental)
        + '</ul></header>'
    )
    document += """<script>
const filters=['surface','theme','scale'];
function apply(){document.querySelectorAll('section').forEach(s=>{
s.hidden=filters.some(k=>{let v=document.getElementById(k).value;return v!=='all'&&s.dataset[k]!==v})})}
filters.forEach(k=>document.getElementById(k).addEventListener('change',apply));
</script></html>"""
    (OUTPUT / "index.html").write_text(document, encoding="utf-8")
    print(json.dumps({"pairs": manifest["pairCount"], "expected": 48, "gallery": str(OUTPUT / "index.html")}))


if __name__ == "__main__":
    main()
