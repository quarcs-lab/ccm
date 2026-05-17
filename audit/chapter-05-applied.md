# Chapter 05 — applied audit fixes

File edited: `/Users/carlosmendez/Documents/GitHub/ccm/05-structural-bayesian-ts.qmd`.
Stage 2 agent for ch.5. Every P1, P2, and P3 item in `audit/chapter-05.md` is addressed; no other files were edited.

## Verification

Numbers below are computed live (not from the freeze cache) by running the new chunks against `data/proposition99.rds` outside of Quarto. `quarto render` itself is currently blocked by an unrelated `date-modified: last-modified` validation error in `_quarto.yml` that this agent is not permitted to touch.

| Quantity                              | Cached / asserted in audit | Actually computed by new chunk |
|---------------------------------------|---------------------------|-------------------------------|
| Average ATT (full fit)                | −12.8                     | −12.82                        |
| Average 95% CI (full)                 | [−31.9, +5.7]             | [−32.10, +5.02]               |
| Cumulative effect (full)              | −153.9                    | −153.87                       |
| Cumulative 95% CI (full)              | [−383.4, +68.1]           | [−385.26, +60.23]             |
| Posterior $p$ (full)                  | 0.082                     | 0.078                         |
| Average ATT (no-covariates)           | "around −21" (asserted)   | −21.50                        |
| Posterior probability (no-cov)        | "≈ 97%" (asserted)        | 1 − 0.034 = 96.6%             |
| Average CI (no-covariates)            | not given                 | [−40.47, +3.16]               |

Audit assertions ("$-21$ packs, ≈ 97%") are now backed by a live chunk (`tbl-causalimpact-nocov`). Prose for the cumulative CI in the two-panel section was updated from the wrong $[-383, +68]$ to a rounded $[-385, +60]$ to match what the cache will return.

## P1 fixes

1. **Spike-and-slab named and explained.** Added a "The spike-and-slab prior" paragraph after the model equation in §"The model in two pieces". Names SSVS, cites `@george1997approaches` and `@scott2014predicting`, explains `expected.model.size = 3` setting $\pi = 3/194$, defines posterior inclusion probability, and calls out the analogy to chapter 4's simplex weights.

2. **Seed narration corrected.** Replaced the `Reset the seed so the BSTS MCMC draws are reproducible` comment in `tbl-causalimpact` with the accurate four-line note explaining that `CausalImpact::ConstructModel` internally calls `bsts(..., seed = 1)`, so the MCMC is deterministic regardless of `set.seed(42)`. Updated the surrounding prose ("**The fit.**" paragraph) to match.

3. **"Includes zero only at the upper edge" rewritten.** The line under `fig-causalimpact` now reports the cumulative CI explicitly as approximately $[-385, +60]$ and says zero is *comfortably inside* the band, with a 92% posterior probability of a non-zero effect — the opposite of the original wrong claim.

4. **No-covariates fit reproduced in code.** New section "What if we drop the covariates?" with chunk `tbl-causalimpact-nocov` that pivots `prop99` to wide using only `cigsale` per state and re-runs `CausalImpact()` on the un-imputed 38-column donor matrix. The chunk reports the cached summary table; prose recap then refers to the live numbers (−21.5, 96.6%) without hard-coding them.

## P2 fixes

5. **MCMC convergence diagnostics added.** Two new chunks under §"MCMC convergence diagnostics":
   - `fig-bsts-components`: `plot(impact_full$model$bsts.model, "components")` for visual convergence.
   - `tbl-mcmc-diagnostics`: extracts the post-burn-in coefficient draws, computes inclusion probability, posterior mean, a Gelman-style Rhat (within/between-half), and an ESS estimate from the autocorrelation of non-zero draws — for the 5 donors with the highest inclusion probability. Helper functions `rhat_one()` and `ess_one()` are defined inline (no external dependency beyond base R + tibble).

6. **Forward link to ch.6 added.** New §"Where to next" before "Recap" briefly motivates the move from a Bayesian credible interval (whose width depends on the prior) to a frequentist prediction interval (`scpi`, ch.6), citing `@cattaneo2021prediction` and `@cattaneo2025scpi` — both already in `references.bib`.

7. **Contrast with ch.4 spelled out.** New "Contrast with classical synthetic control (chapter 4)" paragraph at the end of §"The model in two pieces" that explicitly contrasts simplex weights $w$ (non-negative, sum to one, convex hull, Fisher exact $p$) with spike-and-slab $\beta$ (sparse but possibly negative, posterior credible interval).

8. **`@vanbuuren2011mice` cited.** Added to "Packages" paragraph in §"Setup and data" at the first mention of `mice`, and to the Further Reading list.

9. **Lowercase $y$ → uppercase $Y$.** Both occurrences of $y_{1t}$ (in the model equation and the projection statement) changed to $Y_{1t}$, plus the mermaid block now uses Ŷ₁ₜ instead of ŷ₁ₜ. Matches the book-wide convention.

## P3 fixes (writing & structure polish)

10. **Credible vs confidence intervals expanded** from one sentence to a three-sentence passage with the "given the model and data" Bayesian frame contrasted against the "if we re-ran the study many times" frequentist frame.

11. **`m = 1` caveat surfaced into headline.** "Reading the output" bullet for the Average ATT now adds "see Common pitfall below for why this interval is mildly anti-conservative under $m = 1$ imputation". Recap row "What is the uncertainty quantification?" gains "widened by 1–3 packs under proper $m \ge 5$ multiple imputation (see pitfall)".

12. **Posterior SD corrected.** Was "≈ 11"; the cached half-width implies ≈ 10; bullet updated.

13. **Pitfall examples 3 and 4 added.** "Posterior inclusion probabilities are not causal weights" and "No MCMC convergence check".

14. **Recap table updated.** Counterfactual-construction row now mentions the spike-and-slab (SSVS) prior and `expected.model.size = 3` explicitly; design-time-pitfall row expanded to four items.

15. **Further Reading** now lists six entries (added Scott-Varian, George-McCulloch, van Buuren).

16. **"Single random-forest imputation" framing.** Wording in §"Setup and data" makes explicit that calling `mice()` with `m = 1` is "*single* random-forest imputation, i.e. one draw from what would otherwise be a multiple-imputation procedure".

## Honest disclosure: the inclusion-probability picture is different from chapter 4's

When I ran the diagnostics chunk, the top-5 columns by posterior inclusion probability turned out to be `retprice_Nevada`, `age15to24_South Carolina`, `retprice_South Dakota`, `age15to24_Utah`, `retprice_North Dakota` — i.e., **covariate** columns dominate the spike-and-slab selection rather than raw `cigsale_*` donor states. Top inclusion probabilities are around 5–10% (not the 80–100% one might naively expect), because with `expected.model.size = 3` over 194 columns, prior mass per column is genuinely tiny. Prose under `fig-inclusion` was rewritten to reflect this rather than to assert a clean Utah/Nevada/Montana/Colorado/Connecticut parallel that the data does not support. The teaching point becomes: *spike-and-slab and SC simplex weights pick fundamentally different objects from the same donor pool*, which actually strengthens the contrast-with-ch.4 message.

## Files touched

- `/Users/carlosmendez/Documents/GitHub/ccm/05-structural-bayesian-ts.qmd` — every audit P1/P2/P3 item.
- `/Users/carlosmendez/Documents/GitHub/ccm/audit/chapter-05-applied.md` — this report.

No other files were modified.

## Renderability

Could not run `quarto render --to html 05-structural-bayesian-ts.qmd` to refresh the freeze cache: `_quarto.yml:17` carries `date-modified: last-modified`, which the installed Quarto rejects as an invalid book property. That edit was made in Stage 1 and is outside this agent's allowed file set. The chapter's R chunks were verified to execute correctly outside of Quarto (`Rscript`-driven smoke test reproduced both summary tables and the diagnostic objects).
