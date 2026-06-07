# Chapter 6 audit — Synthetic Difference-in-Differences

File: `06-synthetic-did.qmd` (942 lines).
Cached freeze: `_freeze/06-synthetic-did/execute-results/html.json` and `figure-html/`.
Published HTML: `_book/06-synthetic-did.html` (built from the same freeze).

Audited against the working tree at commit `06d0090` (`main`, 2026-06-07), with a fresh
`quarto render --to html 06-synthetic-did.qmd` (R 4.5.2; synthdid 0.0.9, xsynthdid 0.1.0,
mice 3.19.0, ranger 0.18.0). Spec: `.claude/skills/write-book-chapter/references/`
(house-style, skeleton, integration-checklist).

> **Note on this report.** This is the *first* audit of the SDID chapter. The previous
> `audit/chapter-06.md` was a stale report on the SCPI chapter (renumbered to ch 8 by the
> SDID/augmented-SC insertions) and was preserved as `audit/chapter-06-SCPI-OLD.md`
> (+ `-applied-SCPI-OLD.md`). The `audit/` directory's numbering is drifted book-wide
> (see X1) — that cleanup is **deferred**, out of this chapter's scope.

## Summary

The chapter is conceptually strong and, on the **Proposition 99 single-treated demo, fully
correct**: I reproduced the headline Arkhangelsky-et-al-2021 Table 1 replication exactly —
DiD `-27.35`, SC `-19.62`, SDID `-15.60` against the paper's `-27.3 / -19.6 / -15.6`, with
the spread rendering as "8 packs". The DiD/SC/SDID bracketing pedagogy is clean, the
**Identification.** paragraph is present, every prose number is live inline R and matches
its chunk, citations all resolve, and the cross-chapter seams are correct (ch 5's Recap
hands off to SDID and explains the ω/ν rename; ch 7 opens by calling back to "chapter 6's
synthetic DiD").

**However the staggered-adoption demo is broken in the rendered output.** Each cohort is
fitted as a *single-treated* SDID (one treated state per cohort, `N1 = 1`), so synthdid's
**jackknife and bootstrap standard errors are undefined and return `NA`** — exactly the
failure the chapter itself documents for Prop 99 at `:327-334`. Those `NA`s leak straight
into the published HTML: **15 `NA` table cells** across `tbl-staggered-per-cohort` and
`tbl-staggered-aggregate`, the `fig-sdid-event` error bars vanish (the caption promises
"jackknife 95% bands"), and the inline `se_agg_jk` in the Recap and Key-takeaways renders
the literal text `NA`. The chapter's prose actively contradicts the output: the
`tbl-staggered-per-cohort` caption asserts jackknife/bootstrap "work here," and "A note on
standard errors" calls jackknife "the asymptotically defensible default."

Two further issues: the chapter **did not render at all** until `ranger` (needed by
`mice(method = "rf")`, invoked by string so no dependency scanner catches it) was
installed — a reproducibility gap now fixed but not yet pinned; and **three families of
warnings leak into the published HTML** (ineffective palette overrides on the
`synthdid_plot()` figures, a ggplot2 `size`→`linewidth` deprecation from inside synthdid,
and a mice log message).

Verdict: methodology is sound but the staggered inference must be re-grounded (cohort-level
resampling) and the leaked warnings cleared before the chapter is republished.

## Strengths

- **Exact Table 1 replication.** `tbl-arkhangelsky-table1` and the surrounding prose
  (`:457-484`) reproduce Arkhangelsky-et-al-2021 to two decimals; I confirmed
  DiD `-27.35`, SC `-19.62`, SDID `-15.60` live. Exercise 1's hard-coded paper values
  (`:768-769`) match.
- **Clean two-knob pedagogy.** "The SDID idea" (`:43-77`) and "The estimator" (`:79-111`)
  build the unit/time double-weighting and state the nesting (DiD ⊂ SCM ⊂ SDID). The
  **Identification.** paragraph (`:71-77`) names the latent-factor / weighted-parallel-
  trends assumption.
- **Inline numbers are live and correct.** Every prose figure is `` `r ...` ``; spot-checks
  (`tau_sdid`, `|tau_did−tau_sc|`, `tau_agg ≈ -22`) match the freeze. (The 35 raw
  `` `r ` `` tokens in the HTML are inside the code-tools "view source" listing, not the
  visible prose — not a bug.)
- **Cross-chapter seams correct.** ch 5 `:557` hands off to "Chapter 6 (Synthetic
  Difference-in-Differences)" and documents the ω/ν rename; ch 7 `:?` opens "Chapter 6 ran
  DiD on a panel doubly de-meaned by simplex unit and time weights." ch 6's own references
  to chs 4/5/7/8/11 are all correct for the current numbering.
- **Notation conformant.** ω (SDID unit weights) and ν (time weights) are deliberately
  chosen to avoid the book-wide `λ`/`w` collisions and are glossed at `:19-21`; ch 5
  pre-announces the rename. Citations `@arkhangelsky2021synthetic`,
  `@clarkepailanir2023synthetic`, `@synthdid_pkg`, `@xsynthdid_pkg`, `@kranz2022xsynthdid`,
  `@abadie2010synthetic` all resolve in `references.bib`.

## Methodology issues

### M1. Staggered jackknife/bootstrap are undefined for single-treated cohorts (**P1**)
- **Where:** `06-synthetic-did.qmd:531-553` (`fit_cohort`, the `vcov(est, method =
  "jackknife")` / `"bootstrap"` calls at `:548-549`); claims at `:562` (caption) and
  `:591-599` ("A note on standard errors").
- **Problem:** Each cohort is fitted by `synthdid_estimate()` on `(never-treated ∪ one
  cohort state)`, so the estimate has exactly one treated unit (`N1 = 1`). synthdid's
  jackknife leaves the single treated unit out → undefined; its bootstrap resamples treated
  units → the same singleton. Both return `NA` (I reproduced: all four cohorts give
  jackknife = bootstrap = `NA`, placebo defined at 2.79/2.95/3.90/4.68). This is the *same*
  fact the chapter correctly states for Prop 99 at `:327-334`, so the staggered section
  contradicts the single-treated section. The caption at `:562` ("Jackknife and bootstrap
  work here…the inference resamples *cohorts*, not within-cohort cells") describes a
  cohort-level resampling that the code does **not** perform — the code resamples *within
  each single-treated cohort fit*.
- **Impact:** The chapter's stated headline-inference method ("jackknife is the right
  citation" `:598`, `:702-706`) produces `NA`. The reader sees an empty inference story
  exactly where the chapter claims its staggered payoff.
- **Fix (needs a methodological choice — propose at the P1 gate):** resample at the
  **cohort** level, matching the chapter's own prose and @clarkepailanir2023synthetic:
  - Per-cohort table (`tbl-staggered-per-cohort`): report **placebo SE only** (the only
    per-cohort-defined SE); drop the two `NA` columns.
  - Aggregate: compute a **leave-one-cohort-out jackknife** and a **cohort resampling
    bootstrap** of `tau_agg` (G = 4 cohorts → coarse but defined; say so). Replace the
    quadrature combination at `:570-574`.
  - Drive `fig-sdid-event` bands and the inline `se_agg_jk` from the cohort-level jackknife.
  - Rewrite the `:562` caption and `:591-599` "A note on standard errors" to state honestly
    that per-cohort SEs are placebo-only and the jackknife/bootstrap act across the four
    cohorts.

### M2. SDID-X "modest correction" contradicts the rendered −1.96 (**P1**, found in fix pass)
- **Where:** `06-synthetic-did.qmd` "Reading the output" (the SDID-X block) and the
  Key-takeaways covariate bullet ("a real but modest correction").
- **Problem:** The covariate-adjusted estimate renders `tau_sdid_x = -1.96` (I verified it
  is −1.960 independently, and unchanged by the mice predictor edit), a **+13.6-pack shift
  off the vanilla −15.60** — near-total absorption of the effect. The prose calls this "a
  real but modest correction," which contradicts both the rendered number and the chapter's
  own Exercise 2 ("retail price is the usual culprit"). Missed in the first-pass summary
  (I had not extracted `tau_sdid_x`).
- **Impact:** The reader is told the adjustment barely moves the estimate while the table
  shows it collapsing to ≈ 0.
- **Fix (applied):** Rewrite both spots to state the large shift honestly and explain it:
  retail price is a **post-treatment mediator** (the Prop 99 tax raised it), so adjusting
  for it is a *bad control* that absorbs the policy's main channel — turning the
  inconsistency into the chapter's intended caution and aligning the main text with
  Exercise 2.

## Code & reproducibility issues

### C1. `NA` standard errors leak into the rendered HTML (**P1**)
- **Where:** rendered `tbl-staggered-per-cohort` (`:560-565`), `tbl-staggered-aggregate`
  (`:577-589`), `fig-sdid-event` (`:601-621`), inline Recap `:663` and Key-takeaways `:705`.
- **Problem / evidence:** the freeze/HTML contain **15 `>NA<` cells** plus `(NA` inline
  tokens. `se_agg_jk`/`se_agg_boot` are `sqrt(sum((π · NA)^2)) = NA`; the
  `fig-sdid-event` error bars (`ymin/ymax = ATT ± 1.96·NA`) are dropped, so the figure
  shows points but none of the captioned jackknife bands. This is the rendered face of M1.
- **Impact:** published tables show `NA`; the inline prose reads "jackknife SE `NA`"; the
  event-study figure silently loses its uncertainty layer.
- **Fix:** resolved by the M1 fix (cohort-level resampling), then re-render and confirm zero
  `NA` cells and visible bands.

### C2. Render fails on missing `ranger` (**P1** — resolved, needs pinning) ✅
- **Where:** `data-load-prop99` chunk (`:164-181`), `mice(m = 1, method = "rf")`.
- **Problem:** mice's random-forest method dispatches to `ranger`, which was **not
  installed and not in `renv.lock`**. The first render halted: `Error in loadNamespace():
  there is no package called 'ranger'`. Because `ranger` is invoked by *string*
  (`method="rf"`), `renv::dependencies()`/`renv::status()` never flag it.
- **Fix (done):** `renv::install("ranger")` (0.18.0 installed); the re-render is clean.
  **Still to do:** add `ranger` to `DESCRIPTION` Imports and `renv::snapshot()` so the lock
  is reproducible — fold into this chapter's commit.

### C3. Three warning families leak into the published HTML (**P2**)
- **Where / evidence (from the freeze JSON):**
  - **"No shared levels found between `names(values)` of the manual scale and the data's
    colour/fill values"** (×4) — `fig-sdid-vanilla` (`scale_*_manual` at `:301-304`) and
    `fig-sdid-comparison` (`:499-504`). The override names (e.g. "California (observed)")
    don't match the factor levels `synthdid_plot()` actually produces, so **the book
    palette is silently not applied** and the warning prints.
  - **"Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0"** (×2) — emitted
    from *inside* `synthdid_plot()` (the package still uses `size=`); not fixable in our
    code.
  - **mice "Number of logged events: 1"** — from the imputation chunk (`:164-181`).
- **Impact:** warning callout boxes render in the published chapter; the intended palette is
  not used on two key figures.
- **Fix:** (a) make the manual scales match `synthdid_plot()`'s series names (inspect the
  built plot's `data`/labels), or recolour via the correct aesthetic, so the override
  applies and the warning disappears; (b) the upstream synthdid `size=` deprecation is the
  sanctioned exception — wrap those two `synthdid_plot()` calls in `suppressWarnings()` (or
  `#| warning: false` on just those figure chunks) with a comment that it is upstream and
  unfixable here; (c) quiet the mice log (it is a single benign logged event from the rf
  imputation) by capturing it, or note it explicitly.

## Cross-chapter consistency issues

### X1. Book-wide stale cross-references from the renumbering (**deferred**)
- **Where:** e.g. `05-augmented-synthetic-control.qmd:35` ("the Callaway-Sant'Anna
  machinery in chapter 9" — now chapter 10). The augmented-SC (ch 5) and SDID (ch 6)
  insertions shifted later chapters but their inbound references were not all updated.
- **Scope:** ch 6's *own* cross-references are correct; this is a >2-chapter book-wide
  sweep. **Deferred** — handle via a book-wide pass / `write-book-chapter` integration
  checklist, not this chapter's target-plus-neighbours edit scope.

## Writing & structure (format) issues

### S1. Advertised `xsdid_se_bootstrap()` is never called (**P3**)
- **Where:** `:120-121` ("`xsynthdid` adds … `xsdid_se_bootstrap()` for the matching
  standard errors").
- **Problem:** No chunk uses `xsdid_se_bootstrap()`; the staggered demo uses synthdid's
  `vcov()`. The function is advertised but unused (and on Prop 99 it errors by design,
  correctly noted at `:398-401, :416-425`).
- **Fix:** either demonstrate it once in the staggered/covariate path, or soften `:120` to
  "ships `xsdid_se_bootstrap()` for designs with multiple treated units" without implying
  this chapter calls it.

### S2. `tbl-staggered-per-cohort` caption overclaims (**P2**, folded into M1)
- **Where:** `:562`. The caption's "Jackknife and bootstrap work here" is false; rewrite as
  part of the M1 fix.

## Action checklist (priority order)

**P1 (must fix before next render):**
- [ ] M1 — re-ground staggered SEs (user chose **placebo-only throughout**); rewrite the
      per-cohort caption + the "A note on standard errors" passages.
- [ ] M2 — correct the SDID-X "modest correction" prose to match the rendered −1.96 and
      frame `retprice` as a post-treatment bad control.
- [ ] C1 — verify the rewrite removes all `NA` cells and restores `fig-sdid-event` bands.
- [x] C2 — `ranger` installed; **pin** it (DESCRIPTION + `renv::snapshot()`) in this commit.

**P2:**
- [ ] C3 — fix/clear the leaked warnings (palette-scale mismatch ×4; synthdid `size=`
      deprecation ×2; mice log ×1).
- [ ] S2 — caption rewrite (with M1).

**P3:**
- [ ] S1 — reconcile the advertised-but-unused `xsdid_se_bootstrap()` prose.

**Deferred (out of this skill's edit scope — book-wide):**
- X1 — stale inbound cross-references from the chapter renumbering (e.g. ch 5 → "chapter 9"
  should be "chapter 10"); and the `audit/` report-number drift. Handle in a book-wide pass.
