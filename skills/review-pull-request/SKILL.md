---
name: review-pull-request
description: "Orchestrated PR review for other engineers' PRs. Given one or more GitHub PR URLs, reads the repo docs for conventions, runs /review + /code-review + the coderabbit CLI, merges and prioritizes findings using docs/review/risk-scoring.md, gets my approval, then posts each approved finding as a separate PR comment in CodeRabbit's format with a collapsible copy-paste AI fix prompt. Trigger when I paste a PR URL and want it reviewed, or say 'review this PR' / 'run a PR review'."
---

# PR Review Orchestrator

A personal skill for reviewing **other engineers' PRs**. It drives three review engines
(`/review`, `/code-review`, and the `coderabbit` CLI), merges and ranks their findings against
the repository's own standards, gets your approval, and posts the approved findings to the PR as
your comments — each in CodeRabbit's content style with a collapsible, copy-pasteable AI fix prompt.

## Operating principles (read first)

- **You (the orchestrator) are the ONLY thing that posts to GitHub.** The sub-tools run in
  **capture-only** mode. Never let `/review` or `/code-review` post comments or reviews. You hold
  the gh credentials and you decide what posts — and only after explicit approval.
- **Never post anything before the user approves** the specific findings (Step 5).
- **Process one PR at a time.** If given multiple PR URLs, fully complete the cycle
  (checkout → review → approve → post) for one PR before starting the next.
- **Capture long command output to logs.** Per the user's global terminal conventions, save
  long-running output to `.gitignored/pr-review/<command>_$(date +%Y%m%d_%H%M%S).log` using
  `2>&1 | tee "$log_file"`, then filter the saved log rather than re-running. Bypass pagers
  (`gh ... | cat` or `--no-pager`).

## Inputs

One or more PR references, in any of these forms:
- `https://github.com/<owner>/<repo>/pull/<number>`
- `<owner>/<repo>#<number>`
- a bare `<number>` (assume the current worktree's origin repo)

---

## Step 0 — Preflight

1. Create the log dir: `mkdir -p .gitignored/pr-review`.
2. Verify GitHub auth: `gh auth status`. If not authenticated, stop and tell the user to run
   `gh auth login`.
3. Verify CodeRabbit auth: `coderabbit auth status --agent`.
   - If unauthenticated or expired, **STOP** and present this exact re-auth command, then wait:

     ```
     coderabbit auth logout && coderabbit auth login
     ```

     (Alternatively `coderabbit auth login --api-key <key>`.) Resume only after the user confirms
     re-authentication.
   - Note the active org in the output; if the PR's repo belongs to a different org, mention it
     so the user can switch with `coderabbit auth org` if needed.
4. Parse each PR reference into `owner`, `repo`, `pr_number`.
5. Sanity-check the repo: run `gh repo view <owner>/<repo> --json nameWithOwner | cat` and compare
   to this worktree's origin (`git remote get-url origin`). If they differ, warn the user — the
   local checkout-based engines (`/code-review`, `coderabbit`) need this worktree to be the PR's
   repo. Do not proceed for a mismatched repo without confirmation.

---

## Step 1 — Learn the repository's conventions

Before reviewing, ground yourself in this repo's standards so findings cite real conventions:

1. **Read `docs/review/risk-scoring.md` in full** — this defines the severity/type/dimension
   taxonomy and risk tiers you will use for ranking (Step 4). It is the north star.
2. Read the root `CLAUDE.md` (and any `CLAUDE-*.md` it references).
3. Skim `docs/architecture/` and the relevant `docs/adrs/` for the platform the PR touches
   (iOS vs Android — infer from the changed files). Pull in specific ADRs only as relevant to the
   diff; do not exhaustively read all 75 docs.

Keep a short mental/written list of the conventions most relevant to this PR's diff — you'll
reference them in finding descriptions.

---

## Step 2 — Check out the PR

1. Save current state context: `gh pr view <pr_number> --repo <owner>/<repo>
   --json baseRefName,headRefName,headRefOid,title,url,isDraft,state | cat`.
   - If the PR is **closed/merged**, ask the user whether to continue.
   - Record `baseRefName` (e.g. `main`) and `headRefOid` (the head commit SHA — needed for inline
     comments in Step 6).
2. `gh pr checkout <pr_number> --repo <owner>/<repo>` to bring the PR's code into this worktree.
3. Confirm the checkout: `git log --oneline -1 | cat`.

---

## Step 3 — Run the three review engines (CAPTURE-ONLY)

Run all three. Collect every finding into a single working list. **None of these may post.**

### 3a. `/review` (built-in)
Invoke the `/review` skill via the Skill tool to analyze PR `<pr_number>`. **Critical instruction
to carry through:** it must **only report findings to you** — it must **NOT** run `gh pr review`,
`gh pr comment`, or otherwise post to GitHub. You control tool execution: capture its analysis and
do not execute any posting step it proposes.

> If `/review` cannot be kept capture-only in practice (it insists on posting), abandon `/review`
> for this run, tell the user, and proceed with `/code-review` + coderabbit only.

### 3b. `/code-review` (built-in)
Invoke the `/code-review` skill via the Skill tool with **no flags** — specifically **without
`--comment`** (which would post) and **without `--fix`** (which would edit files). Plain invocation
reviews the current working-tree diff and reports findings only. Capture them.

### 3c. `coderabbit` CLI
Run against the local checkout, comparing to the PR base:

```zsh
log_file=".gitignored/pr-review/coderabbit_$(date +%Y%m%d_%H%M%S).log"
coderabbit review --agent --base <baseRefName> 2>&1 | tee "$log_file"
```

Parse the structured (`--agent`) JSON findings from the saved log. CodeRabbit runs locally and
never posts to GitHub.

### Normalize
Convert every finding (from all three tools) into a uniform record:

```
{ tool, title, file, line, severity, type, body, suggested_fix? }
```

- `severity` ∈ {critical, major, minor, trivial, info}
- `type` ∈ {potential_issue, refactor, nitpick}
- Map each tool's own wording onto this taxonomy (from `docs/review/risk-scoring.md`). For tools
  that don't emit severity/type explicitly, infer conservatively from the finding content.

---

## Step 4 — Merge, dedupe, and rank

1. **Dedupe** across tools by `(file, approximate line, normalized issue text)`. When ≥2 tools flag
   the same thing, merge into one entry and record all tools in `flagged_by` — multi-tool agreement
   raises confidence and priority.
2. **Rank** using `docs/review/risk-scoring.md`:
   - **Severity:** 🔴 Critical > 🟠 Major > 🟡 Minor > 🔵 Trivial > ⚪ Info
   - **Type:** ⚠️ Potential issue > 🛠️ Refactor suggestion > 🧹 Nitpick
   - **Dimension escalation:** findings touching the doc's *sensitive areas* rank above
     equivalent-severity findings elsewhere — Security (auth, keychain, entitlements/permissions,
     IoT/BLE control, firmware/OTA, payment, secrets), Architecture (module graph / `Package.swift`
     / gradle, cross-module public APIs, navigation routes, persistence/migrations, API schema),
     and CI/CD (`.github/workflows/**`, Fastlane, build/signing/release).
   - **Tie-break:** multi-tool agreement upward.
3. **Group for display by severity.** Each section header carries a severity circle +
   word, and **every finding under it repeats the SAME circle + word**, so a section and
   its items always correlate. Order sections most-severe first and **omit any empty
   section**:
   - **## 🔴 Critical**
   - **## 🟠 Major**
   - **## 🟡 Minor**
   - **## 🔵 Trivial**
   - **## 🧹 Nitpicks** — `type = nitpick` / pure style; always last
   The section a finding lands in is its **severity**. Use dimension-escalation +
   multi-tool agreement (from the ranking above) to ORDER findings *within* a section
   and to settle borderline severity calls — not to move a finding into a higher section
   than its severity warrants. Number findings sequentially (1..N) across all sections so
   the user can select them. The **only** emoji used is the severity circle (reused
   verbatim on every item in its section); **never** introduce type emojis (⚠️ 🛠️ etc.) —
   express "kind" with the `Type:` word field instead.

---

## Step 5 — Present for approval

Render the findings grouped under the **word severity sections from Step 4**. Give
**each finding its own `###` subheading** so the list is easy to scan, followed by a
metadata line and the labeled Problem / Recommended-fix paragraphs:

```
### <n>. <severity-circle> <Severity word> — <one-line title>
`<file>` ~L<line>  ·  Type: <Potential issue | Refactor | Nitpick>  ·  Flagged by: <tools>

#### Problem
<2–3 sentences: what's wrong and the concrete consequence.>

#### Recommended fix
<1–2 sentences: the specific change to make.>
```

- The finding heading repeats its section's **severity circle + word** (e.g.
  `### 1. 🟠 Major — …`); every item in a section uses the identical circle + word.
- Convey **kind** with the `Type:` word field. The only emoji is the severity circle —
  no type emojis.
- **Problem** and **Recommended fix** are `####` headings (one level below the `###`
  finding title) so they pop; heading hierarchy is section (`##`) → finding (`###`) →
  Problem/Recommended fix (`####`).
- Leave a blank line between findings.

Then ask which to approve. Accept flexible selections, e.g.:
- `all` · `all except nitpicks` · `critical+major` · `none`
- specific numbers/ranges, e.g. `1-6, 9`

**Do not post anything yet.** Wait for the explicit selection.

---

## Step 6 — Post approved findings (each as its own separate comment)

For **each** approved finding, post **independently** (this yields one notification per comment —
the user's chosen behavior). Comments post as the user (gh is authenticated as them).

1. **Resolve the anchor line in the CURRENT checked-out file** (not the diff-log line
   number — they differ). Grep the file for the offending statement to get its real line.
2. **Decide inline vs general by whether that line is in the PR diff.** Inline review
   comments only attach to lines inside a diff hunk. Check the hunks:
   `git diff origin/main...HEAD -- <file> | grep '^@@'` → each `@@ -a,b +c,d @@` means new-file
   lines `c..c+d-1` are commentable. New files: every line is in-diff. If the anchor line
   falls in a hunk → **inline**; otherwise → **general** (and name `file:line` in the body).
3. Write each comment body to `.gitignored/pr-review/comment_<n>.md` (a file — never inline
   the body in the shell; it contains backticks and `${{ }}` that the shell would evaluate).
4. Post. **Build the JSON payload with `jq --rawfile`** so the markdown body is passed
   verbatim (this is why `-f body="$(cat …)"` is wrong — command substitution executes the
   backticks/`$(…)` inside the body):
   - **Inline** review comment on the PR head commit:

     ```zsh
     jq -n --rawfile body .gitignored/pr-review/comment_<n>.md \
           --arg sha "<headRefOid>" --arg path "<file>" --argjson line <line> \
       '{commit_id:$sha, path:$path, line:$line, side:"RIGHT", body:$body}' \
       | gh api --method POST repos/<owner>/<repo>/pulls/<pr_number>/comments \
           --input - --jq '"posted: \(.html_url)"'
     ```

     For a multi-line anchor add `--argjson start <start_line>` and
     `start_line:$start, start_side:"RIGHT"`. If GitHub still rejects it (line off-diff),
     fall back to the general comment below.
   - **General** PR comment (anchor not in diff):

     ```zsh
     gh pr comment <pr_number> --repo <owner>/<repo> \
       --body-file .gitignored/pr-review/comment_<n>.md
     ```

> **Environment note:** if `gh auth status` reports "not logged in" but the user says they
> are authenticated, prefix git/gh commands with `source ~/.zshrc 2>/dev/null` (shell state
> doesn't persist between Bash calls and gh's token may be configured there).

### Comment body format

Make the posted comment look like the **chat summary item** — not plain. GitHub renders
emojis, headings, and inline code, so use them: a severity **circle + word** as the `###`
title, and `####` headings for Problem / Recommended fix.

````markdown
### <severity-circle> <Severity word> — <title>
`<file>` ~L<line>  ·  Type: <Potential issue | Refactor | Nitpick>  ·  Flagged by: <tools>

#### Problem
<2–4 sentences: what's wrong and why it matters. Cite the specific repo doc/convention when
relevant, e.g. "docs/review/risk-scoring.md treats any auth-path change as risk: high.">

#### Recommended fix
<1–2 sentences naming the precise change; optional short fenced snippet.>

<details>
<summary>🤖 AI Prompt</summary>

```
<A self-contained prompt the user can paste into a coding agent. It must name the exact file and
line, describe the problem, and state the precise change to make — enough that an agent with no
other context can apply the fix.>
```

</details>

<sub>sent with <code>/review-pull-request</code></sub>
````

- The `###` title carries the **severity circle + word** (🔴 Critical · 🟠 Major · 🟡 Minor ·
  🔵 Trivial · ⚪ Info) — the same circle the chat summary uses. Convey **kind** with the
  `Type:` word field (Potential issue · Refactor · Nitpick). This mirrors the in-chat summary
  styling exactly, so the comment pops the same way.
- **Problem** and **Recommended fix** are `####` headings (not bold-italic) so they stand out.
- **Every posted comment** (inline or general) must end with the attribution footer
  `<sub>sent with <code>/review-pull-request</code></sub>` (skill name in inline code, with a
  leading slash). If the skill is renamed, update this footer to match.

### After posting
Print a summary: number of comments posted, links to them, and any findings that were skipped
(e.g., approved findings that fell back to general comments because the line was off-diff).

If there are more PRs in the batch, return to Step 2 for the next one.

---

## Quick reference

| Need | Command |
|---|---|
| Check CodeRabbit auth | `coderabbit auth status --agent` |
| Re-authenticate CodeRabbit | `coderabbit auth logout && coderabbit auth login` |
| Run CodeRabbit (capture-only) | `coderabbit review --agent --base <base>` |
| Check out PR locally | `gh pr checkout <n> --repo <owner>/<repo>` |
| PR metadata + head SHA | `gh pr view <n> --repo <owner>/<repo> --json baseRefName,headRefOid,url,state \| cat` |
| Which new-file lines are commentable | `git diff origin/main...HEAD -- <file> \| grep '^@@'` |
| Post inline review comment (body-safe) | `jq -n --rawfile body <file.md> --arg sha <sha> --arg path <file> --argjson line <line> '{commit_id:$sha,path:$path,line:$line,side:"RIGHT",body:$body}' \| gh api --method POST repos/<owner>/<repo>/pulls/<n>/comments --input -` |
| Post general PR comment | `gh pr comment <n> --repo <owner>/<repo> --body-file <file>` |
