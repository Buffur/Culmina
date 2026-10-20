# Official design-system research brief

Owner-supplied reference, recorded 2026-10-19, for future design-system documentation and UI/UX research. This is a reusable research brief, not completed research or a source-coverage claim. Original attachment: `8707aef8-c6d9-494d-b6a5-5803d4efc9bd/Pasted text.txt`.

Apply the relevant portions when a task calls for this research. Verify Context7/Firecrawl availability and actual source coverage at execution time; the imported brief's tool names are not an operational check. Consult only the needed topics. Preserve Culmina's product decisions and the owner's restrained Hybrid Notion + Journal direction; keep platform-specific conventions separate.

The full brief below is retained for a future dedicated research task. Its requested `docs/design-systems/` knowledge base has not been created by merely recording this reference.

A focused application of this method is now recorded in [the Home/Plan review](PLAN_CONCEPT_REVIEW_2026_10_19.md), with six official pages retrieved. This does not claim completion of the full knowledge-base scope below.

## Supplied brief

Use these three official design systems as primary sources:

Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

Microsoft Fluent 2: https://fluent2.microsoft.design/

Adobe Spectrum: https://spectrum.adobe.com/

Available tools: Context7 and Firecrawl.

This is a documentation research and context-engineering task, not a request to implement an application or retrain a model.

Phase 1 — Inspect available tools

Verify that Context7 and Firecrawl tools are available and operational in this Codex session.

Inspect their available capabilities and determine how to search documentation, map websites, retrieve pages, and obtain source URLs.

Do not assume that a website is fully indexed by Context7 merely because its URL was supplied.

If an integration or source is unavailable, report the limitation and continue using the other available tool.

Phase 2 — Discover and retrieve documentation

Use Firecrawl to map the information architecture of each official website before crawling pages.

Prioritize documentation about:

Design principles and foundational concepts.

Color systems, typography, spacing, shapes, and design tokens.

Layout, responsive/adaptive design, and information hierarchy.

Navigation, menus, dialogs, forms, lists, tables, and other common components.

Interaction behavior, feedback, motion, and transitions.

Accessibility, keyboard interaction, assistive technologies, and inclusive design.

Content hierarchy, readability, and usability.

Component states, usage guidelines, do's and don'ts, and common mistakes.

Start with a manageable set of high-value pages, approximately 10–20 per source where sufficient. Expand the scope only when important gaps remain.

Use Context7 to retrieve relevant documentation for specific topics. Check existing indexed sources first; use their exact library IDs where available. For Adobe Spectrum, verify whether the official website itself is available. Do not treat the Spectrum CSS repository as a complete substitute for the official Spectrum design-system documentation.

Use Firecrawl to retrieve missing, deeper, or insufficiently indexed pages.

Do not crawl unrelated sections, unrestricted external links, or duplicate pages. Do not dump entire crawls into the conversation.

Phase 3 — Analyze and synthesize

Compare the sources and organize findings into three categories:

Shared principles that are applicable across different platforms.

Platform-specific conventions that must remain separate.

Distinctive approaches and trade-offs unique to each design system.

Do not blindly merge these design systems into a single set of rules.

For every major recommendation:

Explain the principle and its purpose.

Identify when and why it should be applied.

Include important exceptions, limitations, or accessibility considerations.

Attach links to the relevant official source pages.

Distinguish documented recommendations from your own synthesis.

Explicitly note any conflicting recommendations instead of inventing a universal rule.

Paraphrase and synthesize the documentation instead of copying long passages verbatim.

Phase 4 — Create persistent project documentation

First inspect the existing project structure and AGENTS.md instructions. Preserve existing files and conventions.

Create the following structure, adapting filenames only when necessary:

docs/design-systems/
README.md
shared-principles.md
apple-human-interface-guidelines.md
microsoft-fluent-2.md
adobe-spectrum.md
cross-system-comparison.md
source-index.md

Requirements:

README.md: overview, scope, how to use the knowledge base, and links to all other files.

shared-principles.md: concise, actionable cross-platform UX/UI principles.

Each system-specific file: official principles, components, usage guidance, accessibility, constraints, and source links.

cross-system-comparison.md: comparison of equivalent concepts and components, meaningful differences, and situations where one system's approach should not be applied to another platform.

source-index.md: source title, canonical URL, retrieved topics, retrieval date, and any known coverage limitations.

Keep the documents structured, searchable, and practical for future coding agents. Prefer concise summaries, checklists, and comparison tables over large unfiltered text dumps.

Avoid storing a redundant copy of the same material in multiple files.

Phase 5 — Integrate the knowledge base into Codex

Inspect the existing AGENTS.md hierarchy before changing any instructions.

Add a short, non-duplicative instruction to the appropriate AGENTS.md that tells Codex:

When performing UI/UX work, read docs/design-systems/README.md first.

Consult only the relevant knowledge-base sections for the task at hand.

Use Context7 to verify current official guidance and component/API documentation when needed.

Use Firecrawl to investigate relevant official pages when Context7 coverage is missing or insufficient.

Prefer the appropriate platform's conventions over blindly mixing design systems.

Cite source URLs in research and explain significant design decisions.

Do not load all source documents into every conversation unnecessarily.

Do not modify application code, dependencies, build configuration, or unrelated project files.

Phase 6 — Validate and report

Check the resulting files for:

Working source links and traceable recommendations.

Clear separation of shared and platform-specific guidance.

Important coverage gaps and unresolved questions.

Duplicate content and contradictions.

Consistent Markdown structure.

Then report:

Which sources were successfully investigated.

Which tools were actually used.

Which files were created or updated.

Which topics remain incomplete and why.

How to use this knowledge base in future Codex tasks.

Do not claim exhaustive coverage unless it has been demonstrated. Begin with tool inspection, then carry out the work using the available integrations.
