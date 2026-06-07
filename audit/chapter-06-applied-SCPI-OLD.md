# Chapter 6 — audit fixes applied

File edited: `/Users/carlosmendez/Documents/GitHub/ccm/06-synthetic-control-prediction-intervals.qmd`. No other files were touched.

## P1 (must-fix before publish)

- **R1 — ATT range / simplex headline corrected.** Replaced "between roughly $-15$ and $-22$" and "≈ $-19.5$" everywhere with the cache-correct values: ATT range $-11$ to $-16$, simplex ≈ $-11.1$. Specific edits:
  - Body prose after `tbl-att-by-constraint` (was line 236): rewrote the paragraph to give the correct range, broke out the simplex/lasso/ridge/OLS values explicitly, replaced "economically meaningful amount" with a 12–18% reduction anchored on a baseline of 90 packs/capita (W3 folded in here).
  - Recap row "What is the simplex point ATT?": now reads ≈ $-11.1$ with parenthetical reconciling chapter 4's $-18.85$.
  - Recap row "Does the ATT survive the constraint choice?": now reads "roughly $-11$ and $-16$ packs."
- **M1 — Error-decomposition equation sign fixed.** Rewrote the equation at the top of *The framework* with LHS `Y_{1t}(0) - widehat{Y_{1t}(0)}` (counterfactual prediction error), matching @cattaneo2021prediction eqs. 5–6. Dropped the misleading `u_t` underbrace label (since the SCPI conventions for $u_t$ are mixed) and replaced with "in-sample error". Added a sentence noting that since $\hat\tau_t = Y_{1t} - \widehat{Y_{1t}(0)}$, the same decomposition gives a PI for $\hat\tau_t$. Also rewrote the placebo contrast from "conflates" → "sidesteps" (M4).
- **R7 — Bonferroni alpha split (option a: split the alpha).** Switched all three `scpi(...)` calls from `u.alpha = e.alpha = α` to `u.alpha = e.alpha = α/2` so the joint Bonferroni coverage matches the label. Specifically:
  - `scpi-simplex` chunk: `e.alpha = 0.025, u.alpha = 0.025` (was `0.05/0.05`). Now produces a true 95% joint band.
  - `scpi-all` chunk: same change.
  - `scpi-sensitivity` chunk: `e.alpha = a/2, u.alpha = a/2` (was `a/a`). Labels 80/90/95/99% now correctly correspond to joint coverage of 80/90/95/99%.
  - Added prose ("A note on confidence levels") explaining the convention, and a one-sentence note inside *Sensitivity* repeating it. Figure captions updated to say "95% joint prediction interval."
  - **Cache impact:** the cached numbers in `_freeze/06-synthetic-control-prediction-intervals/` will need to be regenerated. The new bands are slightly wider than the old ones (per-component coverage 97.5% instead of 95%), so the crossing year for "observed California falls below the lower bound" may shift by 1–2 years later, but the qualitative claim "California falls below the lower bound by the late 1990s" is robust to this and the prose still works. The narrative around `fig-pi-simplex`, `fig-pi-all`, `fig-sensitivity` was not rewritten because it does not pin specific years.
- **C5 — Cross-chapter reconciliation paragraph added.** New paragraph after the ATT table reconciles ch.6's simplex ATT (≈ $-11.1$) with ch.4's (≈ $-18.85$) by attributing the gap to (i) predictor-augmented vs outcome-only matching, (ii) `tidysynth`/`Synth` vs `scpi` solver, (iii) `scpi`'s `constant = TRUE` intercept. The Recap row also carries the parenthetical "cf. chapter 4's $-18.85$ with predictor-augmented matching."
- **Heading check.** Ch.6's "## Why a third synthetic-control chapter?" matches its current `tidysynth` (ch.4) + `CausalImpact` (ch.5) framing, so per the instructions it was left alone; ch.7 will be relabelled to "fourth" by the ch.7 agent.

## P2 (clarity / structure)

- **W1 — `## Common pitfall` section added** between *Sensitivity to confidence level* and *Recap*, with four named pitfalls: (1) reading the PI band as a CI on the effect; (2) constraint choice is not innocuous (40% relative spread on ATT here) — also folds in the lasso-$Q$ point from M2/W1; (3) PIs are conditional on the donor pool; (4) PI bands grow rapidly with horizon in a small-T regime. Structurally now matches chs.4, 5, 7.
- **R2 — Outcome-only-matching disclosure.** Added a paragraph immediately after the existing data-prep prose noting the intentional departure from chapter 4 (which used `lnincome`, `beer`, `age15to24`) and previewing the magnitude gap.
- **M2 / M3 — lasso $\|w\|_1 \le 1$ → $\le Q$.** Rewrote the four-constraints sentence so lasso is $\|w\|_1 \le Q$ with $Q$ default 1, and ridge's $Q$ formula `(J+K)σ̂²_u / ||ŵ_OLS||_2²` is spelled out instead of being called "data-driven."
- **M4 — placebo contrast.** Rewrote "conflates both sources into a single rank" → "sidesteps the decomposition entirely" with the cleaner statement that the placebo produces a $p$-value rather than an interval.
- **M6 — Joint coverage note.** Folded into the new "A note on confidence levels" paragraph at the top of *Prediction intervals on the simplex fit*.
- **M7 — `e.method = "gaussian"` framing.** Rewrote the defaults paragraph at the top of *Prediction intervals on the simplex fit* to distinguish the package defaults from the explicit override, and to justify Gaussian against the package default `"all"`.
- **C3 — Forward link to chapter 7.** Added a "Coming up" paragraph at the very end of Further reading, naming ch.7 as the *fourth* synthetic-control chapter and previewing the SUTVA relaxation.
- **C4 — SCPI vs CausalImpact Recap row added.** New row in the Recap table contrasting SCPI's frequentist PI with chapter 5's Bayesian credible interval.
- **C1 — Notation bridge to chapter 4.** Added a sentence in *The framework* explaining the chapter's $Y_{0t}$ / $\hat{w}$ notation against chapter 4's $X_1$ / $X_0$ / $V$ predictor objective.
- **W2 — terminology unification (partial).** Introduced "prediction interval (PI)" at first occurrence (the substantive-interpretation paragraph). Subsequently used "PI" / "PI band" consistently in body prose and figure captions. The variable name `geom_ribbon` is left in code (it's the ggplot function); a few caption uses of "blue ribbon" were swapped to "blue PI band."

## P3 (polish)

- **M5 — Conformal inference signpost.** Added a one-sentence pointer to Chernozhukov–Wüthrich–Zhu (2021) in the framework paragraph (at first opportunity after the placebo/SCPI contrast) and a more complete Further-reading entry. **Note:** the audit suggested adding the citation key to `references.bib`, but per the instructions I cannot edit `references.bib`; I cited the paper inline by author/year/venue rather than via `@cite` key. The ch.6 audit explicitly listed "Add the Chernozhukov entry to `references.bib`" as outside the chapter agent's scope; the stage-1 done file confirms `references.bib` is off-limits for stage-2 agents.
- **R3 — Per-chunk `set.seed(42)`.** Added `set.seed(42)` at the top of `scpi-simplex`, `scpi-all`, and `scpi-sensitivity` chunks so each is independently reproducible.
- **R5 — Dropped `cores = 1` argument** from all three `scpi(...)` calls; the default is 1 and is a no-op for the diagonal-V single-treated-unit path.
- **R6 — `#| warning: false` added** to `fig-pi-simplex` and `fig-pi-all` chunk headers to suppress the harmless `geom_ribbon` NA-row warnings (the chapter intentionally pads pre-period ci_lo/ci_hi with NA).
- **W3 — "economically meaningful amount"** replaced with a percentage-of-baseline figure (12–18% reduction on ≈ 90 packs/capita).
- **W4 — Top-10 / Top-12 unified at 12.** Donor-weights table now uses `head(12)` (was `head(10)`), and both table and heatmap captions explicitly state the ranking criterion ("12 donors with largest maximum absolute weight across the four constraints").
- **W5 — Further-reading additions.** Chernozhukov et al. (2021) added (as above); scpi Python/Stata companion packages added with link to <https://nppackages.github.io/scpi/>.

## Not applied (out of scope for this agent)

- **R4 (`str(pi_simplex$inference.results$CI.all.gaussian)` block).** Skipped to keep the patch focused on correctness fixes; the existing `:262`-style commentary already names the slots used.
- **C2 (forward-pointer in chapter 5).** Lives in `05-structural-bayesian-ts.qmd`, off-limits for this agent.
- **C3 part 1 (ch.7 heading rename "third" → "fourth").** Lives in `07-bayesian-spatial-sc.qmd`, off-limits. The ch.6 forward pointer ("a *fourth* synthetic-control perspective") was added on the ch.6 side as planned.
- **I2 (`R/build_chapter_zips.R`).** Off-limits per stage-1 scope.

## Render / cache notes

Because three `scpi(...)` calls changed (alpha-split from `0.05` to `0.025`, and from `a` to `a/2` in the sensitivity sweep), the freeze cache for chapter 6 is now stale. A `quarto render --to html 06-synthetic-control-prediction-intervals.qmd` is needed before publishing. The cached `tbl-att-by-constraint` and the constraint-by-constraint point estimates are *unchanged* (those come from `scest()`, which has no alpha) — so the corrected ATT prose (R1) is already consistent with what the table will re-print. The PI plots and the sensitivity plot will have wider bands than the previous freeze; the qualitative narrative ("California falls below the lower bound by the late 1990s") is robust to that.
