"""Validate active agent manifests and local Markdown file references.

Does not validate remote URLs, heading anchors, backtick paths, Dartdoc symbol
references, archived guidance, or whether a skill makes good decisions.
"""

import argparse
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

import yaml

ROOT = Path(__file__).resolve().parent.parent
ENTRYPOINTS = ("AGENTS.md", "CLAUDE.md", "GEMINI.md", "README.md")


class UniqueSafeLoader(yaml.SafeLoader):
    """Safe YAML parsing with duplicate keys rejected at every mapping level."""

    def construct_mapping(self, node, deep=False):
        keys = set()
        for key_node, _ in node.value:
            key = self.construct_object(key_node, deep=deep)
            try:
                duplicate = key in keys
                keys.add(key)
            except TypeError as error:
                raise ValueError("YAML mapping keys must be hashable") from error
            if duplicate:
                raise ValueError(f"Duplicate YAML key: {key!r}")
        return super().construct_mapping(node, deep=deep)


def frontmatter(text):
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        raise ValueError("Missing opening YAML frontmatter delimiter")
    try:
        end = lines.index("---", 1)
    except ValueError as error:
        raise ValueError("Missing closing YAML frontmatter delimiter") from error
    data = yaml.load("\n".join(lines[1:end]), Loader=UniqueSafeLoader)
    if not isinstance(data, dict):
        raise ValueError("Frontmatter must be a YAML mapping")
    return data


def prose(text):
    """Remove fenced and inline code before scanning literal Markdown links."""
    result, fence = [], None
    for line in text.splitlines():
        marker = re.match(r"^\s*(`{3,}|~{3,})(.*)$", line)
        if marker:
            token, rest = marker.groups()
            if fence is None:
                fence = token
            elif token[0] == fence[0] and len(token) >= len(fence) and not rest.strip():
                fence = None
            continue
        if fence is None:
            result.append(re.sub(r"(`+).*?\1", "", line))
    return "\n".join(result)


def markdown_destinations(text):
    """Inline links/images and reference definitions; no heading validation."""
    cleaned = prose(text)
    # The supported local convention is a bare destination (balanced parentheses
    # allowed) or <destination with spaces>, optionally followed by a title.
    target = r'(<[^>\n]+>|(?:[^\s()\\]|\\.|\([^()]*\))+)'
    inline = re.compile(r'!?\[[^\]\n]*\]\(\s*' + target + r'(?:\s+["\'][^\n]*["\'])?\s*\)')
    definition = re.compile(r'^\s{0,3}\[[^\]\n]+\]:\s*' + target, re.MULTILINE)
    for pattern in (inline, definition):
        for match in pattern.finditer(cleaned):
            yield match.group(1).strip('<>')


def active_documents(root):
    files = {root / name for name in ENTRYPOINTS}
    for folder in (".agents", ".claude"):
        files.update((root / folder).rglob("*.md"))
    return sorted(files)


def validate(root=ROOT):
    root = Path(root).resolve()
    errors, names = [], set()
    manifests = sorted((root / ".agents/skills").glob("*/SKILL.md"))
    if not manifests:
        errors.append("No active skill manifests found")
    for path in manifests:
        try:
            data = frontmatter(path.read_text(encoding="utf-8"))
            name, description = data.get("name"), data.get("description")
            if not isinstance(name, str) or not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) or len(name) > 64:
                raise ValueError("name must be nonempty hyphen-case, at most 64 characters")
            if name in names:
                raise ValueError(f"Duplicate skill name: {name}")
            names.add(name)
            if name != path.parent.name:
                raise ValueError("name must match its skill directory")
            if not isinstance(description, str) or not description.strip() or len(description) > 1024:
                raise ValueError("description must be nonempty text, at most 1024 characters")
            if "metadata" in data and not isinstance(data["metadata"], dict):
                raise ValueError("metadata, when present, must be a mapping")
        except (ValueError, yaml.YAMLError, UnicodeError, OSError) as error:
            errors.append(f"{path.relative_to(root)}: {error}")
    documents = active_documents(root)
    for path in documents:
        try:
            text = path.read_text(encoding="utf-8")
            if path not in manifests and text.startswith("---\n"):
                frontmatter(text)
            for destination in markdown_destinations(text):
                url = urlsplit(destination)
                if url.scheme or url.netloc or not url.path:
                    continue
                target = (path.parent / unquote(url.path)).resolve()
                if not target.is_relative_to(root):
                    errors.append(f"{path.relative_to(root)}: reference escapes repository: {destination}")
                elif not target.exists():
                    errors.append(f"{path.relative_to(root)}: missing local target: {destination}")
        except (ValueError, yaml.YAMLError, UnicodeError, OSError) as error:
            errors.append(f"{path.relative_to(root)}: {error}")
    return errors, len(manifests), len(documents)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    args = parser.parse_args()
    errors, skills, documents = validate(args.root)
    for error in errors:
        print(error, file=sys.stderr)
    print(f"Instruction check: {skills} skills, {documents} Markdown files, {len(errors)} errors")
    return bool(errors)


if __name__ == "__main__":
    sys.exit(main())
