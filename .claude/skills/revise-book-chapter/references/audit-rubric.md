# Audit rubric — what to check in a chapter

The checkable taxonomy for `revise-book-chapter`, across four dimensions. It is
distilled from the prior manual audit (`audit/AUDIT.md`,
`audit/cross-cutting-notation-arc.md`) and the `write-book-chapter` anti-bug
checklist. The **conformance spec** (notation table, bold-label inventory,
palette, chunk conventions, section order) is *not* repeated here — load it from
`../write-book-chapter/references/house-style.md` and `chapter-skeleton.qmd` and
check against it.

Render the chapter first (SKILL.md Phase 1). The captured `_book/NN-slug.html`
and `_freeze/NN-slug/execute-results/html.json` are the ground truth for the
code/reproducibility checks.

---

## Priority rubric

- **P1 — must fix before next render/publish.** Makes the rendered book
  incorrect, incomplete, or misleading: a failed/NULL model, an empty table, a
  flat-zero figure, an `NA` inline number, a prose number that contradicts the
  rendered output, a wrong statistical input that flips a conclusion, a notation
  collision the reader cannot resolve, a missing identification assumption, a
  broken cross-reference.
- **P2 — substantially improves credibility or pedagogy.** Does not block
  rendering but hurts comprehension or coherence: a missing opening callback or
  closing hand-off, an unstated window/estimand that makes a cross-method
  comparison misleading, a missing diagnostic, a headline number that is never
  extracted, an incomplete recap.
- **P3 — polish.** Cosmetic or minor clarity: a stray `+ theme_minimal()` that
  clobbers the house theme, a bibliography entry missing a field, a long sentence
  that should be split, a slightly-off caption.

Every finding gets: dimension · priority · `file:line` · impact (what the reader
sees) · concrete fix.

---

## Dimension 1 — Content / methodology

- **Identification stated.** The chapter has a bold **Identification.** paragraph
  naming the one assumption under which the method recovers the ATT. Missing → P1.
- **Assumptions & diagnostics present.** Each estimator's assumptions are stated,
  and the expected diagnostics are run (e.g. residual/whiteness checks for ITS,
  pre-trends/placebo for SCM/DiD, balance/imbalance for ASCM). Missing a
  load-bearing diagnostic → P2.
- **Headline number extracted.** The chapter's ATT (per variant) is actually
  computed and surfaced as an **inline R** number — not merely described. A
  method that runs but never reports a numeric estimate → P2 (P1 if the chapter
  claims a value it never computes).
- **Data values verified live.** Any data shown (illustrative cells, counts,
  shapes) is pulled live from the `.rds`, not transcribed. Cross-check against the
  actual dataset; transcribed/incorrect cells → P1.
- **Equation matches the code.** The displayed math is the model actually fitted
  (orders, terms, penalties, links). Mismatch → P1.
- **Estimand & scope clear.** The estimand (ATT on whom, over which window) is
  stated so the number means something.

## Dimension 2 — Format / template & style

Check against `chapter-skeleton.qmd` and `house-style.md`:

- **Section order & completeness.** Learning objectives → "… idea" +
  Identification → Setup and data → per-method sections → discussion → Key
  takeaways → Further reading → Exercises. Missing/way out-of-order sections → P2.
- **Bold-label inventory.** Only the sanctioned labels (**The idea. / The
  equation. / Reading the output. / Common pitfall. / Identification. / Recap.**
  etc.); no invented ones. Stray labels → P3.
- **Notation conformance.** Symbols match the book-wide table; `Y` uppercase;
  `\widehat{Y_{1t}(0)}` used as the counterfactual; `\tau` reserved for treatment
  effects. Deviations → P2/P3 (collisions are Dimension 4, P1).
- **Chunk & caption conventions.** Every chunk `#| label:`-ed; tables
  `tbl-<slug>` + `#| tbl-cap`; figures `fig-<slug>` + `#| fig-cap`; shown chunks
  carry `#| code-summary: "Code: …"`; no `title=`/`subtitle=` passed to
  `gt_pretty()`/`ms_pretty()`. Violations → P3 (P2 if it breaks cross-refs).
- **Palette & theme.** Figures use the house palette (`#d97757` treated,
  `#6a9bcc` counterfactual, `#94a3b8` grid/text); the transparent setup theme is
  present and not clobbered by a trailing `+ theme_minimal()`. → P2/P3.
- **Pedagogical blocks.** Learning objectives are 3–4 two-sentence items; Key
  takeaways grouped **Methods / Lessons / Caveats**; Further reading bullets
  carry a `*type*` tag; Exercises are graduated with `::: {.callout-tip
  collapse="true"}` solutions and `ex-chNN-0K` labels. Missing structure → P2/P3.
- **Bibliography hygiene.** Cited keys exist in `references.bib`; entries have the
  required fields; correct entry type. Missing field → P3; missing key (renders
  as `?@key`) → P1.

## Dimension 3 — Code / reproducibility

Use the captured render as ground truth.

- **No silent NULL/failure.** No `<NULL model>`, no estimator returning `NULL`/
  error that downstream code swallows. → P1. (History: ch.2 auto-`ARIMA` returned
  a NULL model.)
- **No silenced warnings on modelling chunks.** `#| warning: false` is allowed
  only on the setup chunk for library noise. A modelling chunk that hides
  warnings, or upstream deprecation warnings leaking into the HTML → P1/P2; fix
  the cause, don't silence it.
- **Prose-vs-rendered-number drift.** Diff every number in the prose against the
  value the corresponding chunk renders in the freeze JSON. Any mismatch → P1.
  (History: ch.6 prose `-19.5` vs cached `-11.11`.) The structural fix is to make
  the number inline R so it can never drift again.
- **No empty tables / flat figures.** Search the render for `Table has no data`
  and inspect figures that should carry data but render as bare axes / a flat
  zero line. → P1. (History: ch.10 implicit-weights table + cumulative figure.)
- **No `NA` inline numbers.** Search the rendered HTML/JSON for `[1] NA`, `NaN`,
  `NULL` where a number should be. → P1.
- **Correct algorithm inputs.** Spot-check that functions get the right argument
  (units vs panel rows, pre vs full window, level vs event-time). A wrong input
  that changes the answer → P1. (History: `R/honest_did.R` used `N·T` not `N`.)
- **Fragile code.** Coercions relying on undocumented behaviour (e.g.
  tsibble→tibble), or seeds set on deterministic pipelines. → P3.

## Dimension 4 — Cross-chapter consistency

Read the two neighbour chapters.

- **Notation collisions.** A symbol reused for a different meaning than the
  book-wide table without a rename + gloss (`τ`, `λ`, `α`, `w`/`W` are the known
  offenders). → P1. Fix = rename the local one (`\tau_{HS}`, `\eta`/`\lambda_{MC}`,
  `w`, `\Omega`) and add a one-line gloss.
- **Opening callback.** The chapter's first paragraph names the previous chapter
  and what changes. Missing → P2.
- **Closing hand-off.** The discussion ends by naming the next chapter and what
  it adds (or, for the last method chapter, the planned comparison chapter).
  Missing → P2. If a neighbour is the one missing the callback/hand-off to *this*
  chapter, fixing it is in scope (immediate neighbour).
- **Part-seam callout.** A chapter that opens a Part carries the `::: {.callout-
  note}` "Part … begins here" block, and the chapter before the seam signposts
  the dataset/estimand switch. → P1/P2 at a seam.
- **Window/estimand & case-study coherence.** Headline numbers compared across
  chapters are on comparable windows/estimands, or the difference is disclosed.
  Undisclosed window mismatch presented as "essentially identical" → P2.
- **Wider cross-chapter edits** (notation rename spanning >2 chapters, preface or
  chapter-1 roadmap/decision-tree updates): **report and defer** — out of this
  skill's edit scope.

---

## Where render-time bugs surface

| Symptom | Where to look | Priority |
|---|---|---|
| `[1] NA` / `NaN` / `NULL` where a number belongs | `_freeze/NN-slug/execute-results/html.json`; rendered HTML | P1 |
| `<NULL model>` (silent estimator failure) | freeze JSON; chunk output | P1 |
| `Table has no data` | rendered `_book/NN-slug.html`; freeze JSON | P1 |
| Flat-zero / empty figure (axes but no data layer) | `_book/NN-slug.html`; the `figure-html/*.png` | P1 |
| Leaked package warnings (deprecation, etc.) | rendered HTML chunk output | P1/P2 |
| Prose number ≠ rendered number | diff `.qmd` prose vs freeze JSON value | P1 |
| Broken cross-reference (`?@fig-…`, wrong "chapter K") | rendered HTML; full-book render | P1/P2 |

Rule: cross-check **every** prose number against the rendered chunk that should
produce it. If a number is not inline R, that is itself a finding — converting it
to inline R is the durable fix.
