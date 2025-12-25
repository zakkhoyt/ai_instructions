---
applyTo: "**/*.md"
---

# Research-Backed Markdown Deliverables

## Why This Instruction Exists
- The user depends on AI-generated markdown as drop-in documentation, so fabricated content wastes time and breaks trust.
- A recent Apple Photos request (see [docs/todo/TODO_AI_AGENT.md](docs/todo/TODO_AI_AGENT.md)) produced invented features such as a macOS "Sync Now" button that does not exist in Photos 26; the rewrite only succeeded after every statement was fact-checked against Apple Support's [Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264).
- These expectations are now formalized so future agents default to research-backed writing instead of assumptions.

## Non-Negotiable Expectations
- **Research every claim**: do not add any sentence to a markdown deliverable unless you have verified it against primary or clearly reputable sources.
- **Cite inline**: follow the [Links](instructions/markdown/markdown-conventions.instructions.md#links) guidance (internal vs. external references, footnotes/syntax) by linking to the source near the sentence or list item it supports; a single "References" block with matching citations is acceptable if each point clearly inherits a source.
- **State uncertainty instead of guessing**: if a behavior cannot be confirmed for the specified OS/app version, call it out as unknown or ask the user, rather than inventing a workaround.
- **Respect version constraints**: when the user specifies platforms (for example, iOS 26 + macOS 26), confirm that every described UI label, toggle, or workflow actually exists in those releases.
- **No lazy research**: skimming unrelated blog posts or copy-pasting outdated lore without validation is considered a violation.

## Required Workflow When Asked to Write Markdown Answers
1. **Clarify scope**: restate the question, target file, platforms, and any constraints so gaps can be resolved before writing.
2. **Collect sources**: gather official documentation, release notes, or vendor KBs that directly cover the requested behavior; save URLs for later citation.
3. **Fact-check line-by-line**: for each paragraph, confirm the UI labels, feature availability, and limitations against the collected sources.
4. **Annotate with citations**: attach the relevant link(s) immediately after the statements they support so the user can audit the document quickly.
5. **Highlight open issues**: if the research exposes conflicting info or missing functionality, add a clearly labeled "Unknowns" or "Needs Confirmation" section instead of speculating.
6. **Summarize verification**: in the chat response that accompanies the file update, briefly mention which sources were consulted so the audit trail is obvious.

## Acceptable vs. Unacceptable Behavior
- ✅ Acceptable: "Apple does not expose a manual `Sync Now` control in Photos 26 preferences; edits propagate automatically once both devices are online." (Cites [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264).)
- ❌ Unacceptable: "Click the Photos `Sync Now` button on macOS to force updates" with zero evidence, because that UI element is fictional.

## Quick Checklist Before Submitting Markdown Docs
- [ ] Every section is backed by at least one trustworthy reference.
- [ ] Citations follow markdown-source formatting (no bare URLs) and match the statements they justify.
- [ ] The document calls out any uncertain areas explicitly instead of filling gaps with guesses.
- [ ] The accompanying chat summary explains the verification effort and references the sources used.
