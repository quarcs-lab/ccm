---
name: revise-book-chapter
description: >-
  Audit and revise one chapter of the "Comparative Causal Metrics" Quarto book
  (this repo) across four dimensions — content/methodology, format/template &
  style, code/reproducibility, and cross-chapter consistency. Re-renders the
  chapter to catch live-code bugs, writes a diagnostic report to audit/, fixes
  findings on approval by priority (P1 → P2 → P3), records what was applied, then
  commits and publishes. Use whenever the user wants to audit, review, revise,
  QA, or fix an existing chapter of the book.
---

# Revise a book chapter

This skill runs the book's audit discipline on one chapter on demand. It is the
counterpart to `write-book-chapter`: that skill *creates* chapters; this one
*audits and fixes* them. It diagnoses, reports in the project's existing `audit/`
format, and — on your approval, by priority group — applies the fixes, verifies
by re-rendering, and commits & publishes.

See the project `CLAUDE.md` for publishing rules (HTML only; never a bare
`quarto render`; PDF on request; no EPUB; no CI; the live site must stay in sync
with `main`).

## Reference files — read these first

1. `references/audit-rubric.md` — the checkable taxonomy across all four
   dimensions, the P1/P2/P3 priority rubric, and where render-time bugs surface.
   This is *what to look for*.
2. `references/report-templates.md` — the exact formats for `audit/chapter-NN.md`
   (diagnostic) and `audit/chapter-NN-applied.md` (applied). This is *what to
   write*.

The **conformance spec** lives in the sibling skill — do not duplicate it, load
it:

- `../write-book-chapter/references/house-style.md` — voice, the book-wide
  notation table + collision rule, the bold-label inventory, palette, chunk/
  caption conventions, and the anti-bug checklist (§12).
- `../write-book-chapter/references/chapter-skeleton.qmd` — the canonical section
  order a chapter must follow.
- `../write-book-chapter/references/integration-checklist.md` — the self-audit
  gate (§G) and the cross-file integration touchpoints.

Also open a real existing report (e.g. `audit/chapter-02.md` and
`audit/chapter-02-applied.md`) as a live format exemplar before writing yours.

## Workflow

Single thorough pass. Do not skip the render (Phase 1) — the most damaging bugs
in this book's history were only visible in rendered output.

### Phase 0 — Intake and load the spec

- Resolve the target chapter from the user's request to a file `NN-slug.qmd`.
- Load: the target `.qmd`; its two **neighbours** (chapter `NN-1` and `NN+1`,
  for callback/hand-off and notation checks); the three `write-book-chapter` spec
  files; this skill's `audit-rubric.md` + `report-templates.md`; and any existing
  `audit/chapter-NN.md` (prior findings + format exemplar).
- Note which Part the chapter is in (Part I single-unit / Part II staggered) and
  its dataset — this sets which conformance rules apply.

### Phase 1 — Render and capture output

```bash
quarto render --to html NN-slug.qmd
```

- If the render fails on a missing package, `renv::install("pkg")` (use
  `renv::install("ebenmichael/augsynth")` for the GitHub-only one ch. 5 needs),
  then re-render. A render that cannot be made to pass is itself a **P1** finding.
- Capture the fresh `_book/NN-slug.html` and
  `_freeze/NN-slug/execute-results/html.json`. These are the ground truth for the
  code/reproducibility checks.

### Phase 2 — Audit (fan out across the four dimensions)

Apply `references/audit-rubric.md` against the chapter, using the
`write-book-chapter` spec as the conformance reference and the captured render as
ground truth. Cover all four dimensions:

1. Content / methodology
2. Format / template & style
3. Code / reproducibility (cross-check **every** prose number against the
   rendered chunk that produces it)
4. Cross-chapter consistency (read the two neighbours)

Tag each finding with: **dimension**, **priority (P1/P2/P3)**, **location**
(`file:line`), **impact** (what the reader sees), and a **concrete fix**.

### Phase 3 — Report

Write/refresh `audit/chapter-NN.md` in the existing diagnostic format (see
`report-templates.md`). Then present the user a compact summary grouped by
priority: the P1s, P2s, and P3s, each one line with its location.

### Phase 4 — Fix by priority group (on approval)

Approval is **per priority group**, not all-or-nothing:

1. Ask the user to approve the **P1** fixes. On approval, apply them, then
   re-render to verify each one is resolved.
2. Then ask about **P2**; apply on approval; re-render.
3. Then ask about **P3**; apply on approval; re-render.

**Edit scope:** the target chapter **plus its immediate neighbours** only — the
previous chapter's closing hand-off and the next chapter's opening callback when
a cross-chapter finding requires it. Any wider cross-chapter issue (a notation
rename that spans several chapters, a preface/roadmap edit, a book-wide change)
is **reported and recorded as deferred**, not edited here — point the user at
`write-book-chapter`'s integration checklist or a book-wide pass.

Honour the house-style rules when fixing: numbers become inline R, warnings get
fixed at the source (not silenced), notation matches the book-wide table, etc.

### Phase 5 — Verify and record

- Re-render until clean: no errors; no warnings leaking into HTML; no `NA`/`[1]
  NA` inline numbers; no empty tables; no flat-zero figures; prose numbers match
  the rendered output. Run the self-audit gate from the `write-book-chapter`
  integration checklist (§G).
- Write `audit/chapter-NN-applied.md` (see `report-templates.md`): what was
  applied (P1/P2/P3), what was explicitly **not** changed and why (deferred
  cross-chapter items), and verification notes for the next render.

### Phase 6 — Commit and publish

Per the user's standing choice for this skill: render-verify, commit, **and**
publish.

```bash
quarto render --to html
quarto publish gh-pages --no-prompt --no-render
```

- If on the default branch `main`, create a feature branch first.
- Commit the changed chapter, any neighbour edits, and both audit reports
  (`audit/chapter-NN.md`, `audit/chapter-NN-applied.md`). End the message with
  `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
- Publish to `gh-pages`, then remind the user to merge the branch into `main`
  (the site↔`main` sync rule in `CLAUDE.md`).
- Never a bare `quarto render`; never add PDF/EPUB to the routine publish.

## Definition of done

- The chapter re-renders with no errors/warnings and passes the self-audit gate.
- `audit/chapter-NN.md` (diagnostic) and `audit/chapter-NN-applied.md` (applied +
  deferred + verification) are written in the project's format.
- Approved fixes applied at P1 → P2 → P3; edits confined to the target chapter +
  immediate neighbours; wider issues recorded as deferred.
- Full book rendered, changes committed on a branch, published to `gh-pages`;
  user reminded to merge to `main`.
