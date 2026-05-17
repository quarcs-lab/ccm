# Audit: Chapter 05 — Structural Bayesian Time Series

File audited: `/Users/carlosmendez/Documents/GitHub/ccm/05-structural-bayesian-ts.qmd` (197 lines).
Cross-checked against `_freeze/05-structural-bayesian-ts/execute-results/html.json` (cached chunk output) and the rendered `_book/05-structural-bayesian-ts.html`.

Cached numerical outputs from the fitted model (used as ground truth below):

| Horizon    | Actual | Prediction              | Absolute effect          | Relative effect            | Posterior p |
|------------|-------:|-------------------------|--------------------------|----------------------------|------------:|
| Average    |  60.4  | 73.2 [54.7, 92.3]       | -12.8 [-31.9, +5.7]      | -15.9% [-34.6%, +10.4%]    | 0.082       |
| Cumulative | 724.2  | 878.1 [656.1, 1107.6]   | -153.9 [-383.4, +68.1]   | -15.9% [-34.6%, +10.4%]    | 0.082       |

Internal package facts that bear on the audit (verified by inspecting `CausalImpact` 's namespace):

- `CausalImpact()` has signature `function(data, pre.period, post.period, model.args, bsts.model, post.period.response, alpha = 0.05)`. **There is no `seed=` argument.**
- Inside `CausalImpact::ConstructModel()`, `bsts(..., seed = 1, ...)` is hard-coded. The global R seed set by `set.seed(42)` therefore does **not** affect the MCMC draws.
- The default static-regression spike-and-slab is configured with `kStaticRegressionExpectedModelSize = 3`, `kStaticRegressionExpectedR2 = 0.8`, `kStaticRegressionPriorDf = 50`, and `bma.method = "SSVS"` (Stochastic Search Variable Selection, i.e. spike-and-slab). None of this is mentioned in the chapter.

---

## 1. Methodology

**Strengths.** The local-level + regression decomposition is stated cleanly (lines 13–17, 40); the mermaid diagram (lines 19–38) is helpful; the chapter is upfront that this is the only method in the book delivering a *credible* interval (lines 9, 183).

**Issues.**

1. **Spike-and-slab prior is never mentioned.** This is the defining feature of CausalImpact's regression component — it is how the package handles having 194 candidate regressors and 19 pre-period observations (`p >> n`). With default `expected.model.size = 3`, the prior expects roughly 3 of the 194 columns to actually contribute; the rest are shrunk toward zero. Without naming this, a reader has no model for *why* `CausalImpact` does not collapse on `p >> n` and no entry point for understanding inclusion probabilities or "average model size" diagnostics that BSTS exposes.
   - `05-structural-bayesian-ts.qmd:11–17`: add one paragraph after the equation introducing the spike-and-slab/SSVS prior on $\beta$, the role of `expected.model.size` (default 3), and what an "inclusion probability" is. Suggested wording: *"Because the donor pool here is 194 columns wide but the pre-period is only 19 years, an unregularised regression is impossible. CausalImpact uses a **spike-and-slab** prior on $\beta$: each coefficient has prior probability $\pi$ of being non-zero (a 'slab') and probability $1 - \pi$ of being exactly zero (the 'spike'). The default expected model size is 3, so the prior strongly favours sparse counterfactuals built from a handful of states. After fitting, each donor has a **posterior inclusion probability** — the share of MCMC iterations in which its coefficient was non-zero — which is the natural Bayesian analogue of the simplex weights from chapter 4."*

2. **Comparison to classical SC (chapter 4) is implicit, never spelled out.** Chapter 4's recap (line 361) hands off to chapter 5 with "we hand the same donor information to a Bayesian model and ask whether a *credible interval* tells the same story", but chapter 5 itself never explicitly contrasts the two priors over $w$ (simplex/non-negative-sum-to-1 in chapter 4 vs spike-and-slab/sparse-regression here). A reader can leave the chapter thinking BSTS is just a more uncertain Abadie-Diamond-Hainmueller.
   - `05-structural-bayesian-ts.qmd:40`: add a sentence at the end of "The model in two pieces": *"This is the same donor-pool idea as classical synthetic control (chapter 4), but with a different prior over the weights: SC constrains $w$ to the unit simplex (non-negative, sum to one); BSTS lets $\beta$ be any sparse real-valued vector under the spike-and-slab prior. SC gives convex weights and a Fisher exact $p$-value from placebo permutation; BSTS gives possibly negative weights and a posterior credible interval. The two estimates do not need to agree, and when they disagree the reason usually lives in this prior choice."*

3. **Credible vs confidence intervals: stated once, never developed.** Line 9 says "a direct probability statement about the parameter — rather than a frequentist confidence band". That is correct but very compressed for an undergrad-friendly chapter. A reader who has not had a Bayesian course will not extract the right intuition.
   - `05-structural-bayesian-ts.qmd:9`: expand into two sentences. Suggested: *"The 95% **credible interval** that CausalImpact reports is a Bayesian object: 'given the model and data, there is a 95% posterior probability that the effect lies in this range'. This is **not** a frequentist 95% confidence interval, which would instead say 'if we re-ran the entire study many times, 95% of the intervals we construct would cover the true effect'. The two answer different questions and they need not coincide numerically."*

4. **The $m = 1$ imputation caveat is well-handled in the pitfall section but never appears at the headline level.** Section "Common pitfall / Example 2" (line 179) does say single imputation under-states uncertainty by 1–3 packs. Good. But the recap row "What is the uncertainty quantification?" (line 189) reports the credible interval $[-32, +5.7]$ as if it were the final number — it is the $m = 1$ number, and the chapter has just told the reader that the honest $m = 5$ band is 1–3 packs wider. The headline numbers on lines 153 and 189 should be flagged with `*` and a footnote.
   - `05-structural-bayesian-ts.qmd:153`: change to `"Average ATT: approximately $-13$ packs/capita (posterior SD ≈ 11), 95% credible interval roughly $[-32, +5.7]$ — see "Common pitfall" below for why this interval is mildly anti-conservative."`
   - `05-structural-bayesian-ts.qmd:189`: add ", widened by 1–3 packs under proper $m \ge 5$ multiple imputation (see pitfall)."

5. **Posterior inclusion probabilities are never inspected.** With a spike-and-slab fit, the most informative diagnostic — and the closest analogue to chapter 4's "synthetic California is 32% Utah + ..." weights table — is the inclusion-probability bar plot `plot(impact_full$model$bsts.model, "coefficients")`. The chapter does not show it. This is a missed teaching opportunity and means the reader has no way to see *which* donor states the Bayesian fit picked, so they cannot compare to the tidysynth weights from chapter 4.
   - Add a new chunk after `tbl-causalimpact` (around `05-structural-bayesian-ts.qmd:149`):
     ```r
     #| label: fig-inclusion
     #| fig-cap: "Posterior inclusion probabilities for the donor regressors. Bars are the share of MCMC iterations in which each donor's coefficient was non-zero; longer bars are 'most-used' donors. The spike-and-slab prior keeps most donors near zero."
     plot(impact_full$model$bsts.model, "coefficients")
     ```
   - Add 2–3 sentences after the figure interpreting the top 5 donors and comparing to the Utah/Nevada/Montana/Colorado/Connecticut weights from chapter 4.

6. **MCMC convergence is never diagnosed.** BSTS uses an MCMC sampler (1,000 iterations by default with no burn-in stripped in the summary), and the chapter does not show a traceplot, an effective sample size, or even acknowledge that the posterior numbers depend on the sampler having converged. For a chapter that warns explicitly about $m=1$ imputation but is silent about MCMC, the asymmetry of caution is striking.
   - `05-structural-bayesian-ts.qmd:113`: in the "**The fit.**" paragraph, after "uses an MCMC sampler under the hood", add: *"By default, CausalImpact runs 1,000 MCMC iterations with the first 100 discarded as burn-in. In production work you should rerun with `model.args = list(niter = 10000)` and inspect `plot(impact_full$model$bsts.model, 'components')` for visual convergence; one short chain on 19 pre-period observations is appropriate for a tutorial but is *not* a convergence check."*

7. **`set.seed(42)` does not do what the chapter claims.** Line 126 says "Reset the seed so the BSTS MCMC draws are reproducible." This is **incorrect**: `CausalImpact:::ConstructModel` calls `bsts(..., seed = 1, ...)` with a hard-coded seed (verified above). The MCMC is reproducible *regardless* of `set.seed(42)` because of that internal seed; conversely, the first `set.seed(42)` at line 55 governs only the random-forest mice imputation, not the BSTS sampler.
   - `05-structural-bayesian-ts.qmd:126–127`: replace the comment with a correct one. Suggested: `# Reset the seed so the mice random-forest draws above are reproducible. # (Note: CausalImpact internally hard-codes seed = 1 for the bsts # sampler, so the MCMC draws are deterministic regardless of this line.)`
   - Better still, move the seed reset *before* the `mice()` call, where it actually has an effect, and leave a one-line note here explaining that the BSTS sampler is internally seeded.

8. **`mice(m = 1, method = "rf")` is not, strictly speaking, "multiple" imputation.** The text on line 83 and the prose comment on line 92 both call it "single random-forest imputation" — correct — but the package noun "MICE" stands for "Multiple Imputation by Chained Equations", so calling `mice()` with `m=1` is a tutorial shortcut. The chapter does acknowledge this on line 179. Consider adding the *name* explicitly: "*single* random-forest imputation, i.e. one draw from what would otherwise be a multiple-imputation procedure".

## 2. Code & reproducibility

1. **Prose numbers match cached output.** All headline numbers on lines 153–155 round correctly to the cached values (-12.8 → -13, [-31.9, 5.7] → [-32, +5.7], -153.9 → -154, 1 - 0.082 = 0.918 → 92%, -15.9% → 16%). No issue.

2. **"Posterior SD ≈ 11" (line 153) is borderline.** From the cached CI half-width of 18.8 packs (= (5.7 - (-31.9))/2 / 1.96 = 18.8 / 1.96 = 9.6), the posterior SD is closer to 9.6 than to 11. Round to 10 for honesty: *"posterior SD ≈ 10"*.

3. **"Includes zero only at the very upper edge" (line 171) is wrong.** The cached cumulative CI is $[-383.4, +68.1]$. Zero is +68.1 above the point estimate of $-153.9$, with the upper bound stretching another 68.1 packs further (cumulative interval half-width ≈ 226). Zero is well inside the band, not at the upper edge.
   - `05-structural-bayesian-ts.qmd:171`: change to *"By 2000 the cumulative effect is roughly $-154$ packs/capita with a 95% credible interval of $[-383, +68]$ — wide enough that zero is comfortably inside the band, which is why the headline posterior probability of a non-zero effect is only ≈ 92%, not the > 99% the eyeball test of the top panel might suggest."*

4. **The $-21$ packs / 97% claim (line 157) is asserted but not reproduced in any chunk.** The chapter says "if we drop the covariates and use only other states' cigarette sales as controls, the point estimate strengthens to around $-21$ packs and the posterior probability rises to ≈ 97%", but no chunk demonstrates this. The recap on line 183 then anchors the headline takeaway on this unverified second number ($-13$ to $-21$ packs). At minimum, add a chunk that actually runs the no-covariates fit so the cache contains both numbers and a reader rendering the book sees a reproducible figure.
   - After `05-structural-bayesian-ts.qmd:157`: add a chunk:
     ```r
     #| label: tbl-causalimpact-nocov
     #| tbl-cap: "CausalImpact with only donor cigsale columns (no imputed covariates)."
     prop99_nocov <- prop99 |>
       filter(!is.na(cigsale)) |>
       pivot_wider(names_from = state, values_from = cigsale, id_cols = year) |>
       relocate(California) |>
       select(-year)
     impact_nocov <- CausalImpact(prop99_nocov, pre.period = pre_idx, post.period = post_idx)
     # ... format and gt_pretty as above
     ```
     Then update the recap numbers on line 183 to whatever the cache actually returns.

5. **`pre_idx` / `post_idx` are correct.** Pre-period: 1970 = row 1, 1988 = row 19; post-period: 1989 = row 20, 2000 = row 31. The wide tibble has 31 rows. Confirmed in the cached output: `[1]  31 195`. No issue.

6. **`set.seed(42)` placement is misleading (see Methodology issue 7).** Functionally the cached output is still reproducible because the internal `seed = 1` in `bsts` does the work, but the *narration* is wrong.

7. **`gt_pretty()` is used without a `decimals=` override.** The `Posterior p` column is already pre-formatted by `sprintf("%.3f", p)` (line 145), so this is fine. No issue.

8. **No `model.args = list(niter = ...)` override.** Default is 1,000 MCMC iterations. With a 195-column donor pool this is on the thin side; flagging this in the convergence note above is sufficient.

## 3. Cross-chapter consistency

1. **Notation.** The chapter uses $y_{1t}$ for California's outcome and $x_t$ for the regressor vector (line 15). Chapter 4 (synthetic control) used unit subscripts on $Y_{it}$ and a weights vector $w$. Chapter 6 uses $Y_{1t}$ and $Y_{0t}$ and weights $\hat w$. The notations are not in conflict (each chapter is internally consistent) but the chapter could help the reader by writing one line equating the BSTS $\beta$ to the SC $w$ for direct comparison — see Methodology issue 2.

2. **Transition in (from chapter 4) is present and good.** Chapter 4 ends (line 361) with "*In chapter 5 we hand the same donor information to a Bayesian model and ask whether a credible interval ... tells the same story.*" No action needed on chapter 4's side.

3. **Transition out (to chapter 6) is missing.** Chapter 5 ends with "Further reading" (line 193). There is no bridge sentence connecting the Bayesian credible interval here to the frequentist prediction-interval story `scpi` will tell in chapter 6. Chapter 6's opener (line 7) refers back to "*Chapter 5 produced posterior credible intervals from a structural Bayesian time-series model*" and asks what is "still missing" — a frequentist uncertainty story — but chapter 5 itself does not set up that question.
   - `05-structural-bayesian-ts.qmd:191` (end of recap table) or as a paragraph just before "Further reading": add *"The credible interval here is a Bayesian object — its width depends on the prior. The natural follow-up question is whether a **frequentist** prediction interval, built without a prior over donor weights, would tell the same story. Chapter 6 answers that with the `scpi` framework of Cattaneo, Feng, and Titiunik, which constructs a finite-sample prediction interval around the *synthetic-control* counterfactual from chapter 4."*

4. **The "only credible interval in the book" claim (lines 9, 183)** is accurate as of the current TOC: chapter 6's `scpi` interval is a prediction interval (frequentist); chapter 7's Bayesian spatial SC also delivers a credible band, but that is a *second* credible-interval chapter. Once chapter 7 is wired in, this claim needs softening to "*one of two* methods in the book that delivers a credible interval". Flag for future revision but not a current bug — chapter 7 has not yet been audited / finalised.

## 4. Writing & structure

1. **Hook.** The chapter opens directly with "Fit a Bayesian structural time-series (BSTS) model on the pre-period." (line 7). Functional but cold. A one-sentence narrative hook — "*Bayesian methods reframe uncertainty as a probability over the answer rather than a probability over hypothetical replications. CausalImpact is the cleanest example in this book.*" — would help. Optional polish.

2. **Section flow.** The eight-section arc (Idea → Model → Setup → Imputation → Fit → Plot → Pitfall → Recap → Further reading) is well-paced. No restructuring needed.

3. **Captioned outputs.** Both figures and the table use the project's required `label`/`fig-cap`/`tbl-cap` conventions per CLAUDE.md. Confirmed correct.

4. **Common pitfall section.** Strong section: the two named failure modes (imputing donor covariates with a model that "sees" California; $m=1$ vs $m=5$ Rubin pooling) are both substantive and well-explained. The only gap is **no pitfall is raised for the spike-and-slab interpretation** — e.g. "do not read posterior inclusion probability as a causal weight; it is a *prior+data* update on which donors help predict California, not on which states are causally similar". This connects directly to chapter 4's pitfall about the V-matrix.
   - `05-structural-bayesian-ts.qmd:179` (after Example 2): add *"**Example 3 — Posterior inclusion probabilities are not causal weights.** As in chapter 4's V-matrix, a donor state with high posterior inclusion probability is one that is *useful for predicting California's pre-period sales*, not one that is *causally similar* to California. The two are correlated but not the same."*
   - Also: add a "no MCMC convergence check" entry (see Methodology issue 6) to the same pitfall section.

5. **Further reading is thin** (3 entries, lines 195–197). Missing two natural citations:
   - **Scott & Varian** — the BSTS package authors, e.g. Scott & Varian (2014) "Predicting the Present with Bayesian Structural Time Series". This is referenced by the prompt and would naturally appear here.
   - **van Buuren & Groothuis-Oudshoorn (2011)** — the `mice` package paper, JSS 45(3). The chapter uses `mice` non-trivially and warns about it, but cites no source.
   - **George & McCulloch (1993, 1997)** on SSVS — the spike-and-slab method.
   - Action: add `@scott2014predicting`, `@vanbuuren2011mice`, and `@george1997approaches` to `references.bib` and cite them in the Further Reading list. Neither key currently exists in `references.bib` (verified by grep).

6. **Recap table** (lines 185–191). Solid. Two issues:
   - The "uncertainty quantification" row should flag the $m=1$ caveat (see Methodology issue 4).
   - The "design-time pitfall" row currently says "*Single-imputation shortcuts on covariates with high missingness; never impute donors using the treated unit*". If pitfall Example 3 is added (Methodology issue / Writing issue 4 above), expand this row: "*Single-imputation shortcuts; never impute donors using the treated unit; do not read inclusion probabilities as causal weights*".

## 5. Bibliography

Verified entries in `references.bib`:
- `@brodersen2015inferring` — present, well-formed.
- `@causalimpact-pkg` — present.
- `@brodersen-causalimpact-talk` — present.

**Missing** (cited or implied by the chapter / by the prompt):
- `scott2014predicting` (Scott & Varian, "Predicting the Present with Bayesian Structural Time Series", *International Journal of Mathematical Modelling and Numerical Optimisation*, 2014) — not in `references.bib`. The `bsts` package is the substrate of CausalImpact and Scott is its author; the chapter mentions `bsts` by name (line 44) but cites no original BSTS paper.
- `vanbuuren2011mice` (van Buuren & Groothuis-Oudshoorn, "mice: Multivariate Imputation by Chained Equations in R", *JSS* 45(3), 2011) — not in `references.bib`. The chapter uses `mice` non-trivially and warns about $m=1$ but cites no source.
- A spike-and-slab / SSVS reference (e.g. George & McCulloch 1993, 1997) — not in `references.bib`. If Methodology issue 1 is addressed (spike-and-slab paragraph), this becomes necessary.

Action: add the three bib entries and cite them in the Further Reading section (lines 195–197). Suggested entries:

```bibtex
@article{scott2014predicting,
  author  = {Scott, Steven L. and Varian, Hal R.},
  title   = {Predicting the present with {Bayesian} structural time series},
  journal = {International Journal of Mathematical Modelling and Numerical Optimisation},
  volume  = {5},
  number  = {1/2},
  pages   = {4--23},
  year    = {2014}
}

@article{vanbuuren2011mice,
  author  = {van Buuren, Stef and Groothuis-Oudshoorn, Karin},
  title   = {{mice}: Multivariate Imputation by Chained Equations in {R}},
  journal = {Journal of Statistical Software},
  volume  = {45},
  number  = {3},
  pages   = {1--67},
  year    = {2011}
}

@article{george1997approaches,
  author  = {George, Edward I. and McCulloch, Robert E.},
  title   = {Approaches for {Bayesian} variable selection},
  journal = {Statistica Sinica},
  volume  = {7},
  number  = {2},
  pages   = {339--373},
  year    = {1997}
}
```

## 6. Prioritised action list

The five edits that most improve the chapter, in priority order:

1. **Name and explain the spike-and-slab prior.** Insert ~1 paragraph after `05-structural-bayesian-ts.qmd:17` introducing SSVS, `expected.model.size = 3`, and posterior inclusion probabilities. *Without this, the chapter does not explain its central regularisation device.* (Methodology issue 1.)

2. **Add an inclusion-probability figure** after `05-structural-bayesian-ts.qmd:149` (`plot(impact_full$model$bsts.model, "coefficients")`), and 2–3 sentences comparing the top donors to chapter 4's Utah/Nevada/Montana/Colorado/Connecticut weights. *Connects BSTS directly to classical SC and makes inclusion probabilities tangible.* (Methodology issue 5.)

3. **Fix the seed-reproducibility narration on `05-structural-bayesian-ts.qmd:126–127`.** The internal `bsts(..., seed = 1, ...)` makes the MCMC deterministic regardless of `set.seed(42)`; the comment as written is incorrect. (Methodology issue 7 / Code issue 6.)

4. **Reproduce the no-covariates fit in code** instead of asserting "$-21$ packs, 97%" on `05-structural-bayesian-ts.qmd:157`, and fix the wrong claim about the cumulative CI on line 171 ("includes zero only at the very upper edge" — zero is well inside the band). (Code issues 3, 4.)

5. **Add a transition out** at the end of the chapter, just before "Further reading" on line 193, bridging the Bayesian credible interval here to the frequentist prediction interval in chapter 6. Also add Scott-Varian, van Buuren-mice, and George-McCulloch citations to `references.bib` and the Further Reading list. (Cross-chapter issue 3 + Bibliography section.)

Total expected length added: ~25–35 lines of prose, 1 code chunk (~10 lines), 3 new bib entries.
