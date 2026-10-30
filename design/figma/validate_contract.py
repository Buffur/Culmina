"""Validate the D01 document contract without changing Flutter or reference assets."""
from pathlib import Path
import json
import re
import sys

BASE = Path(__file__).resolve().parent
REPO = BASE.parents[1]
REF = Path(r"C:\Users\zalub\.codex\visualizations\2026\10\29\01a18540-fc19-7d30-a78c-581e611ffa11\android-ui-atlas")
REQUIRED = [
    "TARGET_DESIGN_SYSTEM.md", "tokens_semantic.md", "typography.md",
    "spacing_and_border.md", "rules_and_constraints.md",
    "components/forms.md", "components/navigation.md", "components/data_display.md",
    "reference_mapping.md", "flutter_mapping.md",
    "screens/tonight.md", "screens/plan.md", "screens/weather.md",
    "qa_checklist.md", "WORKFLOW.md",
]
errors = []
def require(ok, message):
    if not ok:
        errors.append(message)

for name in REQUIRED:
    require((BASE / name).is_file(), "Missing module: " + name)

files = sorted(BASE.rglob("*.md")) + [REPO / "AGENTS.md", REPO / ".agents/skills/culmina-figma-after/SKILL.md"]
link_count = 0
for file in files:
    text = file.read_text(encoding="utf-8")
    for match in re.finditer(r"\[[^\]\n]+\]\((?:<([^>]+)>|([^\s)]+))\)", text):
        target = (match.group(1) or match.group(2)).split("#", 1)[0]
        if not target or re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*://", target):
            continue
        link_count += 1
        require((file.parent / target).resolve().exists(), f"Broken link: {file.relative_to(REPO)} -> {target}")
    require("\ufffd" not in text, "Replacement character: " + str(file))

token_text = (BASE / "tokens_semantic.md").read_text(encoding="utf-8")
tokens = {}
for line in token_text.splitlines():
    if not line.startswith("| ") or "." not in line.split("|")[1]:
        continue
    cells = [v.strip() for v in line.strip("|").split("|")]
    name, value, usage = cells
    require(name not in tokens, "Duplicate token: " + name)
    require(bool(re.fullmatch(r"#[0-9A-F]{6}|[0-9]+(?:\.[0-9]+)? dp", value)), "Invalid token value: " + name)
    require(bool(usage), "No token usage: " + name)
    tokens[name] = value
mapping = (BASE / "flutter_mapping.md").read_text(encoding="utf-8")
for name in tokens:
    require(mapping.count("| " + name + " |") == 1, "Missing/duplicate binding: " + name)
require(not re.search(r"#[0-9A-Fa-f]{6}\b|\b\d+(?:\.\d+)? dp\b", mapping), "Independent values in Flutter mapping")
owners = {
    "AppPalette": "app_palette.dart", "HybridTokens": "hybrid_tokens.dart",
    "AppSpacing": "app_spacing.dart", "AppRadius": "app_radius.dart",
    "ThemeData": "app_theme.dart",
}
for name in tokens:
    owner, member = name.split(".", 1)
    if owner == "AfterGeometry":
        require(name == "AfterGeometry.focusRingWidth", "Unreviewed new role: " + name)
        continue
    source = (REPO / "lib/core/theme" / owners[owner]).read_text(encoding="utf-8")
    # Textual ownership check only; not a Dart type checker.
    leaf = member.split(".")[-1]
    require(bool(re.search(r"\b" + re.escape(leaf) + r"\b", source)), "Owner/member not found in source: " + name)

component_count = sum(len(re.findall(r"^## After/", (BASE / name).read_text(encoding="utf-8"), re.M)) for name in REQUIRED if name.startswith("components/"))
require(component_count == 24, "Component count differs from index")

evidence_files = [
    "README.md", "QA_SUMMARY.md",
    "ui_atlas/notion.id/llm_ready/START_HERE.md",
    "ui_atlas/notion.id/llm_ready/AI_DESIGN_SPEC.md",
    "ui_atlas/notion.id/llm_ready/QA_REVIEW.md",
    "ui_atlas/notion.id/llm_ready/00_ui_kit_anatomy.png",
    "ui_atlas/notion.id/llm_ready/cluster_01_main_tabs.png",
    "ui_atlas/notion.id/llm_ready/cluster_03_lists_and_cards.png",
    "ui_atlas/notion.id/llm_ready/01_navigation_details.png",
    "ui_atlas/notion.id/llm_ready/02_search_and_sheet_details.png",
    "ui_atlas/notion.id/llm_ready/03_database_details.png",
]
for name in evidence_files:
    require((REF / name).is_file(), "External source unavailable: " + name)
spec = (REF / "ui_atlas/notion.id/llm_ready/AI_DESIGN_SPEC.md").read_text(encoding="utf-8") if REF.exists() else ""
for label in ["C01", "C02", "C03", "C04", "C05", "C06", "C08", "C09", "C10", "C11", "C12", "C13", "C14", "S01", "S03", "S07", "S08", "S13", "S14", "S18", "S24"]:
    require(label in spec, "Referenced label not found in source spec: " + label)

def luminance(value):
    rgb = [int(value[i:i+2], 16) / 255 for i in (1, 3, 5)]
    rgb = [v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4 for v in rgb]
    return sum(v * w for v, w in zip(rgb, (.2126, .7152, .0722)))

pairs = []
def contrast(fg, bg, minimum):
    a, b = sorted((luminance(tokens[fg]), luminance(tokens[bg])))
    ratio = (b + .05) / (a + .05)
    pairs.append({"foreground": fg, "background": bg, "ratio": round(ratio, 3), "minimum": minimum})
    require(ratio >= minimum, f"Contrast below target: {fg} on {bg}: {ratio:.3f}")

for bg in ["ThemeData.scaffoldBackgroundColor", "AppPalette.surfaceRaised", "ThemeData.colorScheme.surfaceContainerHigh", "ThemeData.hoverColor", "ThemeData.highlightColor", "HybridTokens.surfaceSunken"]:
    for fg in ["AppPalette.textPrimary", "AppPalette.textSecondary", "AppPalette.textTertiary", "HybridTokens.action"]:
        contrast(fg, bg, 4.5)
    contrast("AppPalette.controlBorder", bg, 3)
    contrast("ThemeData.focusColor", bg, 3)
contrast("HybridTokens.onAction", "HybridTokens.action", 4.5)
contrast("ThemeData.colorScheme.onSecondaryContainer", "ThemeData.colorScheme.secondaryContainer", 4.5)
for name in ["statusFits", "statusTight", "statusDoesNotFit", "statusNoWindow", "statusNeutral", "stateUnsaved", "stateSettled", "stateQuiet"]:
    contrast("AppPalette." + name, "AppPalette.surfaceRaised", 4.5)
for fg, bg in [("success", "successWash"), ("caution", "cautionWash"), ("errorText", "errorWash"), ("selectedHourText", "selectedHourFill")]:
    contrast("HybridTokens." + fg, "HybridTokens." + bg, 4.5)

report = {
    "revision": "AFTER-DARK-1.0",
    "scope": "Document consistency, local source existence, textual owner/member checks and selected opaque color pairs; not Figma/native acceptance.",
    "required_modules": len(REQUIRED), "resolved_local_links": link_count,
    "tokens": len(tokens), "component_contracts": component_count,
    "external_evidence_paths": len(evidence_files),
    "contrast_pairs": pairs, "errors": errors,
}
print(json.dumps(report, indent=2))
if "--write" in sys.argv:
    (BASE / "verification.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
raise SystemExit(bool(errors))
