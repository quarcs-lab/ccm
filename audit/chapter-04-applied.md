# Chapter 4 — Audit applied

File edited: `/Users/carlosmendez/Documents/GitHub/ccm/04-classical-synthetic-control.qmd`
Audit source: `/Users/carlosmendez/Documents/GitHub/ccm/audit/chapter-04.md`
Constraints honoured: edits scoped to the single target `.qmd`; analysis logic untouched (donor weights, ATT, MSPE ranking all preserved); every `#| label:` / `#| tbl-cap:` / `#| fig-cap:` line preserved verbatim.

## P1 — Critical fixes (all done)

| Audit ID | Fix | What changed |
|---|---|---|
| 3.1 | Suppress three `tidysynth`-originated ggplot2 deprecation / "ignoring unknown labels" warnings | Added `#| warning: false` to `fig-sc-trends`, `fig-sc-differences`, `fig-sc-mspe-ratio`. All three leak points identified by the audit are now covered (Phase 1's two-point list was incomplete). |
| 3.2 | Stale RDD chapter reference | Line that opened the **Dataset** paragraph rewritten from "Unlike the ITS, RDD, and DiD chapters" to "Unlike the ITS and DiD chapters". |
| 3.3 | V-matrix bar chart clobbering chapter theme | Deleted the trailing `+ theme_minimal()` from the `fig-sc-predictor-weights` chunk. The chapter-wide `theme_set(theme_minimal(...) + theme(...))` set in `setup` now governs that figure (transparent panel, slate-grey text). |

## P2 — Major fixes (all done)

| Audit ID | Fix | What changed |
|---|---|---|
| 3.6 | "Western/sunbelt" → "Mountain-West" mislabel | Two replacements made: (a) **Donor weights and predictor weights** §, list item 1: "California is matched mostly to other Mountain-West states…"; (b) Recap table, "synthetic California" row: "A convex combination of four Mountain-West states (Utah, Nevada, Montana, Colorado) plus Connecticut". |
| 3.4 | No leave-one-out / in-time-placebo robustness check | New §**Robustness: in-time placebo and leave-one-out** added between the MSPE-ratio section and the nested-tibble inspection section. Two new code chunks: `fit-syn-intime-placebo` (refits the pipeline with the panel truncated to pre-1989 and `i_time = 1980`, then computes the 1981–1988 placebo "ATT") and `fit-syn-loo-utah` (refits with `state != "Utah"` and reports the leave-one-out ATT). Both placebo and LOO ATTs are reported via inline R references so the prose can't drift from the live computation. |
| 3.5 | Common-Pitfall callout incomplete | Added a "**More pitfalls — what else can go wrong**" sub-block immediately after the existing single-pitfall callout. Three bulleted entries: (a) interpolation outside the convex hull (with @abadie2021using citation), (b) extreme / concentrated weights (cross-references the new robustness §), (c) donor-pool contamination from controls that themselves experienced post-period policy shocks. |
| Forward links | Recap closing sentence only signalled chapter 5 | Recap now closes with one sentence each on ch.5 (Bayesian credible intervals), ch.6 (`scpi` prediction intervals decomposing forecast error), and ch.7 (Bayesian spatial SCM relaxing SUTVA). All three forward references match the framing the downstream chapters use in their own openings (verified against the first 50 lines of `05-`, `06-`, `07-`). |

## P3 — Polish (all done except 3.9 which the audit instructed to keep)

| Audit ID | Fix | What changed |
|---|---|---|
| 3.7 | Donor-weights table shows 8 rows but prose names 5 | `tbl-cap` reworded to "Donor unit weights (top 8 states; only the top 5 carry meaningful weight)." plus a three-line code comment in the chunk explaining why eight rows are kept (full transparency; bottom three are near zero). `head(8)` retained — the audit listed this fix as optional. |
| 3.8 | Hard-coded `-18.85` could drift from the live computation | Replaced two hard-coded occurrences with inline R: the prose immediately under `sc-att` (`r sprintf("%.2f", mean(sc_post$dif))`) and the matching cell in the Recap table. The two new robustness chunks (in-time placebo, LOO Utah) likewise use inline R for their ATT references. |
| 3.10 | `set.seed(42)` could mislead readers into thinking the pipeline is stochastic | Added a four-line comment above the seed call noting the pipeline is deterministic and the seed is set for cross-chapter consistency only. |
| 3.11 | "Four behavioural and demographic covariates" excludes `cigsale_1988` but says so only implicitly | Reworded to "The four non-lagged covariates (`lnincome`, `retprice`, `age15to24`, `beer`) get less than 9% combined." The arithmetic is now self-evident. |
| 3.9 | Nested-tibble inspection block as a callout? | **Kept inline as-is**, per the audit's own conclusion ("pedagogically useful, not distracting — Keep as is"). No change made. |

## What was NOT changed

- Analysis logic: pipeline call, predictor windows, IPOP tuning, donor weights, V-matrix, the headline `mean(sc_post$dif) ≈ −18.85` calculation. Every cached number flagged in §2 of the audit as faithful to @abadie2010synthetic is preserved.
- Citation keys: `@abadie2010synthetic`, `@abadie2021using`, `@dunford2024tidysynth` — all retained. Added one new citation: `@abadie2021using` is now also cited inside the new convex-hull pitfall bullet (it was already in the chapter's Further reading list, so no `references.bib` edit was needed).
- Off-limits files: `references.bib`, `_quarto.yml`, `install_packages.R`, `README.md`, anything under `R/`, other `.qmd` files, the `_freeze/` cache. None touched.
- Chunk labels, table captions, figure captions: all preserved byte-for-byte where the chunk was edited; new chunks (`fit-syn-intime-placebo`, `fit-syn-loo-utah`) follow the same labelling convention.

## Notation rename plan — no changes required for ch.4

Per `audit/NOTATION-RENAME-PLAN.md`, ch.4 was not on the rename list. The chapter already uses the book-wide conventions for $Y_{1t}$, $\widehat{Y_{1t}(0)}$, and ATT, and introduces the SCM-family donor-weight letter $w$ as the canonical symbol (which is the symbol the rename plan asks chs.7 and 10 to adopt). No notation edits needed.

## Re-render checklist (for the operator)

The new robustness chunks will trigger one-time re-execution of two IPOP solves on the next `quarto render --to html` because their source is new (≈ 30–60 s each on a warm cache). The three plot chunks that gained `#| warning: false` will also re-execute, but they are sub-second. After that, the warmed `_freeze/04-classical-synthetic-control/` cache will be stable. Per `CLAUDE.md`, the operator should run, at the end of their session:

```bash
quarto render --to html
quarto publish gh-pages --no-prompt --no-render
```

so the live website at <https://quarcs-lab.github.io/ccm/> reflects the new robustness section, the corrected Mountain-West framing, and the suppressed warning leaks.
