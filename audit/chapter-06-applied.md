# Chapter 6 audit — applied

Target file: `06-synthetic-did.qmd` (+ `DESCRIPTION` for a pinned dependency). Source
report: `audit/chapter-06.md`. Applied on `main`, verified with
`quarto render --to html 06-synthetic-did.qmd` (R 4.5.2; clean: exit 0, zero `Warning:`
outputs in the freeze, zero broken `NA` data cells). User choices: staggered SEs
**placebo-only throughout**; apply **P1 + P2 + P3**; commit on `main`.

## P1 — applied

### P1 · M1 — staggered jackknife/bootstrap were `NA` (single-treated cohorts)
- **Changed** the staggered section: `fit_cohort()` now returns ATT + placebo SE only (the
  `vcov(..., "jackknife"/"bootstrap")` columns removed); `tbl-staggered-per-cohort` and
  `tbl-staggered-aggregate` are placebo-only; `agg-staggered-stats` drops `se_agg_jk` /
  `se_agg_boot`; `fig-sdid-event` bands now use the placebo SE. Rewrote the per-cohort
  caption and both "A note on standard errors" passages to state the truth: each cohort is
  a single-treated SDID, so placebo is the only valid SE — reinforcing the Prop 99 lesson.
  Also re-pointed the two forward references in the Prop 99 / covariate "Common pitfall"
  paragraphs, Learning objective 3, and the Key-takeaways inference bullet
  (`se_agg_jk` → `se_agg_pl`).
- **Verified:** the rendered staggered tables show real placebo values (aggregate
  ATT −22.31, placebo SE 1.76); the 10 previously-`NA` cells are gone; `fig-sdid-event`
  draws visible bands. Removed `#| warning: false` from the per-cohort fitting chunk (no
  longer hiding the jackknife/bootstrap `NA` warnings).

### P1 · M2 — SDID-X "modest correction" contradicted the rendered −1.96
- **Changed** the SDID-X "Reading the output" block and the Key-takeaways covariate bullet:
  the +13.6-pack shift (vanilla −15.60 → SDID-X −1.96) is now described as near-total
  absorption and explained — retail price is a **post-treatment mediator** the Prop 99 tax
  raised, so adjusting for it is a *bad control* that soaks up the policy's channel
  (consistent with the chapter's own Exercise 2, which isolates `retprice`).
- **Verified:** prose now matches the rendered `tau_sdid_x = -1.96` (confirmed −1.960
  independently; unchanged by the mice edit below).

### P1 · C2 — render failed on missing `ranger`
- **Changed** environment + `DESCRIPTION`: `renv::install("ranger")` (0.18.0); added
  `ranger` to `DESCRIPTION` Imports so the explicit snapshot pins it.
- **Verified:** the chapter renders end-to-end; `renv::snapshot()` will pin `ranger` at
  commit time.

## P2 — applied

### P2 · C3 — three leaked-warning families cleared
- **Changed:**
  - **Palette "No shared levels":** removed the inert `scale_color_manual()` /
    `scale_fill_manual()` overrides on `fig-sdid-units` (1×) and `fig-sdid-comparison` (7×)
    — their names never matched synthdid's internal series labels, so they only warned;
    the figures keep synthdid's native colouring. `fig-sdid-vanilla`'s override **does**
    match and was kept.
  - **ggplot2 `size`→`linewidth` deprecation:** added
    `options(lifecycle_verbosity = "quiet")` to the setup chunk (scoped to deprecation
    warnings; the warning originates inside `synthdid_plot()` and is not fixable in our
    code).
  - **mice "Number of logged events":** the imputation now holds `state` out of the
    predictors (`select(-state)` before `mice()`, rejoined after) — mice was dropping the
    39-level identifier as collinear and logging it. Applied to both the main data-load
    chunk and Exercise 3's `m = 5` imputation. Confirmed `tau_sdid_x` is unchanged by this
    (−1.960 with `state` in or out of the predictor set), and `cigsale` is never imputed.
- **Verified:** freeze JSON has **zero `Warning:` outputs**; no "No shared levels", no
  "Using `size` aesthetic", no "logged events".

## P3 — applied

### P3 · S1 — advertised-but-unused `xsdid_se_bootstrap()`
- **Changed** the Setup "Packages" paragraph to say `xsdid_se_bootstrap()` supplies SEs for
  designs with ≥ 2 treated units in one fit, "so it stays unused here — every fit in this
  chapter has a single treated unit."
- **Verified:** prose no longer implies the chapter calls it.

## Items explicitly NOT changed (and why)

- **X1 — book-wide stale cross-references / `audit/` numbering drift.** Deferred: the
  augmented-SC (ch 5) and SDID (ch 6) insertions left inbound references in *other* chapters
  stale (e.g. `05-augmented-synthetic-control.qmd:35` says "chapter 9" for Callaway-Sant'Anna,
  now ch 10), and the `audit/chapter-NN.md` files are numbered to the pre-insertion scheme.
  Both span >2 chapters — out of this skill's target-plus-neighbours edit scope. The stale
  SCPI report that occupied `chapter-06.md` was preserved as
  `audit/chapter-06-SCPI-OLD.md` (+ `-applied-SCPI-OLD.md`). Handle in a book-wide pass.

## Verification notes (next render)

- After the full-book `quarto render --to html` + `quarto publish gh-pages --no-prompt
  --no-render`, chapter 6 should show: placebo-only staggered tables (no `NA`); a
  placebo-banded `fig-sdid-event`; the SDID-X bad-control narrative; and no warning callout
  boxes anywhere.
- Self-audit gate (write-book-chapter integration checklist §G): inline numbers all live;
  no silenced modelling-chunk warnings (only the scoped `lifecycle_verbosity` for the
  upstream synthdid deprecation); tables non-empty; figures carry data; notation ω/ν
  conformant; opening callback (ch 5) + closing hand-off (ch 7) intact.
- `ranger` pinned via `renv::snapshot()` in the same commit.
