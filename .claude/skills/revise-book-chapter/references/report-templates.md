# Report templates

Two reports per audit, written to `audit/`, matching the format of the existing
files. **Before writing, open a real exemplar** (`audit/chapter-02.md` and
`audit/chapter-02-applied.md`) and match its headings, tone, and priority
scheme — the templates below are the shape, the exemplars are the ground truth.

`audit/` is a tracked directory (not gitignored). Refresh `chapter-NN.md` in
place if it already exists; create `chapter-NN-applied.md` after fixes.

---

## 1. `audit/chapter-NN.md` — diagnostic report (Phase 3)

Written after the audit, before any fix. Every finding carries a priority and a
`file:line`. Group findings by dimension; number them within each group
(`M1, M2…` methodology, `C1, C2…` code, `X1, X2…` cross-chapter, `S1, S2…`
structure/format).

```markdown
# Chapter N audit — <Full Title>

Audited against the working tree at commit `<short-sha>` (`<branch>`, <date>),
with a fresh `quarto render --to html NN-slug.qmd`. Spec:
`.claude/skills/write-book-chapter/references/` (house-style, skeleton,
integration-checklist).

## Summary

<1–3 paragraphs: is the methodology sound? does it render clean? the critical
issues and their impact on the reader / the live site. End with a one-line
verdict.>

## Strengths

- <what the chapter does well — keep brief>

## Methodology issues

### M1. <one-line title> (**P1|P2|P3**)
- **Where:** `NN-slug.qmd:LINES`
- **Problem:** <description>
- **Impact:** <what the reader sees / the conclusion affected>
- **Fix:** <concrete steps, with code/prose snippets>

## Code & reproducibility issues

### C1. <title> (**P1|P2|P3**)
- **Where / Problem / Impact / Fix** (as above; cite the rendered evidence,
  e.g. "freeze JSON shows `[1] NA`" or "`Table has no data`")

## Cross-chapter consistency issues

### X1. <title> (**P1|P2|P3**)
- **Where / Problem / Impact / Fix.** Mark whether the fix is in scope
  (target chapter or immediate neighbour) or **deferred** (wider book-wide edit).

## Writing & structure (format) issues

### S1. <title> (**P1|P2|P3**)
- **Where / Problem / Impact / Fix**

## Action checklist (priority order)

**P1 (must fix before next render):**
- [ ] M1 — <short>
- [ ] C1 — <short>

**P2:**
- [ ] X1 — <short>

**P3:**
- [ ] S1 — <short>

**Deferred (out of this skill's edit scope — book-wide):**
- <X#> — <short> — handle via write-book-chapter integration checklist / a book pass.
```

---

## 2. `audit/chapter-NN-applied.md` — applied record (Phase 5)

Written after fixes are applied. Prescriptive (what was done), not diagnostic.
Mirror the priority grouping of the diagnostic report; reference the same
finding IDs (M1, C1, …).

```markdown
# Chapter N audit — applied

Target file: `NN-slug.qmd` (+ neighbour edits where noted). Source report:
`audit/chapter-NN.md`. Applied on `<branch>`, verified with
`quarto render --to html`.

## P1 — applied

### P1 · M1 — <title>
- **Changed** `NN-slug.qmd:LINES`: <what was edited, with before → after>.
- **Verified:** <how the render confirms it — e.g. "inline number now renders
  `-18.9`, matches the chunk; no `NA`">.

## P2 — applied
### P2 · X1 — <title>
- **Changed** `NN-slug.qmd:…` and/or neighbour `MM-slug.qmd:…` (hand-off/callback).
- **Verified:** …

## P3 — applied
### P3 · S1 — <title>
- **Changed** … **Verified:** …

## Items explicitly NOT changed (and why)

- **<finding ID> — <title>.** Deferred: <reason — e.g. "notation rename spans
  chs. 7, 9, 10; out of this skill's target-plus-neighbours edit scope. Handle in
  a book-wide pass.">
- **<finding ID>.** User declined this priority group.

## Verification notes (next render)

- After `quarto render --to html` + `quarto publish gh-pages --no-prompt
  --no-render`, the following should be visible: <list>.
- Self-audit gate (write-book-chapter integration checklist §G): all boxes pass.
```

---

## Conventions

- Keep findings terse and located. One `file:line`, one impact, one fix each.
- Use the same P1/P2/P3 meanings as `audit-rubric.md`.
- The diagnostic report lists *everything found*; the applied report records
  *what was done and what was deferred and why* — deferred items must reconcile
  with the diagnostic report's "Deferred" checklist.
- If the chapter already had an `audit/chapter-NN.md` from the prior manual pass,
  note at the top what changed since then (resolved vs still-open vs new).
