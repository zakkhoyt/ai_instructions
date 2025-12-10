---
applyTo: "**/*.zsh"
---

# Convention Deviation Commentary Requirements

Whenever you intentionally break a documented convention—whether for portability, backwards compatibility, or any other unavoidable constraint—you must annotate the exception with a short inline comment. This applies equally to:

* **Code** (e.g., using `typeset -n` instead of `local -n`, naming a function argument `UPPER_CASE_ARG`, skipping a required `zparseopts` stage, etc.).
* **Instruction files** themselves (if an instruction cannot follow a higher-level rule, explain why in-place).

## Minimum expectations

1. **State the reason** – be explicit about the constraint (`local -n` unsupported in `$ZSH_VERSION`, environment variable exported for external tooling, etc.).
2. **Place the comment adjacent** – directly above or on the same line as the deviation so future edits cannot miss it.
3. **Scope broadly** – cover any deviation from the AI instructions or repo conventions, including casing rules, logging requirements, sourcing patterns, temporary disablements, legacy tooling, platform limits, or security requirements.
4. **Keep it succinct** – one line is usually sufficient, but include enough context that later contributors know not to "fix" it back.

If you discover an unavoidable exception that spans an entire section, add both the inline comment **and** a sentence in the nearest instruction file explaining the rationale so the rule and the exception stay in sync.
