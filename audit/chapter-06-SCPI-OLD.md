# Audit: Chapter 6 (`06-synthetic-control-prediction-intervals.qmd`)

## Summary

Chapter 6 is the strongest of the four "uncertainty for synthetic control" chapters in conception: it pairs the SCPI prediction-interval decomposition (in-sample weight uncertainty + out-of-sample shocks) with a four-way constraint sweep (simplex / lasso / ridge / OLS), and uses the constraint sweep to argue robustness of both the point estimate and the inferential conclusion. The prose is clean, the math is well-typeset, and the seven captioned outputs are all wired through Quarto-native `tbl-`/`fig-` labels correctly.

However, there is one **headline numerical bug** that the chapter must fix before re-publishing: the prose and Recap claim the four-constraint ATTs span "$-15$ to $-22$" and that the simplex point ATT is "≈ $-19.5$ packs". The cached `tbl-att-by-constraint` (verified in `_freeze/06-synthetic-control-prediction-intervals/execute-results/html.json`) actually shows simplex = **−11.11**, lasso = **−15.28**, ridge = **−15.77**, ols = **−14.24** — i.e. a range of roughly $-11$ to $-16$, not $-15$ to $-22$, and a simplex ATT roughly **7 packs smaller in magnitude** than the recap claims. This is the kind of error a reader will spot the moment they scroll down to the table; the chapter currently cannot be republished without correcting it. The simplex ATT here is also visibly inconsistent with chapter 4's $-18.85$ — a cross-chapter discrepancy that the chapter never acknowledges, even though one of its declared goals is to "ask a sharper question than chapter 4 could."

Beyond the numbers, the chapter is missing the **"Common pitfall"** section that every other Part I chapter (4, 5, 7) carries — the pitfall is hinted at in a Recap-table row but never gets a proper subsection. The framework derivation has one small algebraic slip (the formula on line 21 mixes $\tau_t$ and the synthetic-vs-treated gap), the lasso $Q$ is hard-coded as 1 when scpi treats it as tunable, and the link between the chapter's framework and the placebo / conformal alternatives flagged in the audit brief is never made explicit. None of these is blocking, but most are cheap to add and would substantially sharpen the chapter for the rigorous-undergrad audience.

## Strengths

- **Excellent opening hook.** The first three paragraphs (`06-synthetic-control-prediction-intervals.qmd:5–11`) cleanly motivate a *third* SC chapter — Fisher-rank vs Bayesian credible vs frequentist prediction interval — and immediately preview the constraint-sweep payoff. This is the right level of "why bother" for an advanced-undergrad reader and matches the framing the audit brief calls for.
- **Decomposition is stated in math.** The two-component error decomposition $u_t + e_t$ (`:21–24`) — in-sample weight uncertainty plus out-of-sample disturbance — is laid out in a centred equation with under-braces. That is the conceptual heart of SCPI and the chapter does not shortchange it.
- **Substantive interpretation of "what does the band cover?" is correct.** `:25` and the Recap row at `:427` both make the right point: a PI band covers the *synthetic counterfactual*, "significance" means the observed series leaves the band. This is the most common SCPI misreading and the chapter handles it head-on.
- **Constraint sweep is a genuine pedagogical lever.** Running `scest()` four times with one swapped argument (`:99–103`) is the cleanest possible demonstration that constraint choice drives weight sparsity and counterfactual shape. The heatmap (`fig-weights-heatmap`) is the right visualization for that point.
- **Quarto wiring is correct.** Every output uses `tbl-<slug>` / `fig-<slug>` labels with captions (`:110–111`, `:143–144`, `:175–176`, `:222–223`, `:265–266`, `:320–321`, `:380–381`), per the CLAUDE.md table/figure rule. No stale `title=` / `subtitle=` arguments to `gt_pretty()`.
- **`set.seed(42)` is set in setup** (`:37`), which is the right place for reproducibility given that `scpi` simulates `sims = 200` draws for in-sample uncertainty.
- **Both citations resolve.** `@cattaneo2021prediction` and `@cattaneo2025scpi` exist in `references.bib:26` and `:102`-area respectively, with the correct author lists and DOIs. The chapter correctly cites Cattaneo–Feng–Titiunik (2021, JASA) for the *method* and Cattaneo–Feng–Palomba–Titiunik (2025, JSS) for the *software*.
- **Sensitivity-to-confidence-level analysis** (`:351–417`) is the right additional robustness check and the nested-bands plot is a clean visualization choice.

## Methodology issues

### M1. `06-synthetic-control-prediction-intervals.qmd:21` — the error-decomposition equation is algebraically wrong

The chapter writes the decomposition as

$$\tau_t \;-\; \hat{\tau}_t \;=\; \underbrace{(w^* - \hat{w})^\top Y_{0t}}_{\text{in-sample error } u_t} \;+\; \underbrace{e_t}_{\text{out-of-sample error}}.$$

But the left-hand side `\tau_t - \hat\tau_t` is the *error in estimating the treatment effect*, not the *error in estimating the counterfactual*. The SCPI paper (Cattaneo, Feng, Titiunik 2021, eqs. 5–6) actually decomposes

$$Y_{1t}(0) - \widehat{Y_{1t}(0)} \;=\; (w^* - \hat{w})^\top Y_{0t} \;+\; e_t,$$

i.e. the counterfactual prediction error. Since $\hat\tau_t = Y_{1t} - \widehat{Y_{1t}(0)}$ and $\tau_t = Y_{1t} - Y_{1t}(0)$, the LHS as written ($\tau_t - \hat\tau_t$) does equal $\widehat{Y_{1t}(0)} - Y_{1t}(0)$ — which is the negative of the SCPI decomposition. The sign is flipped relative to the standard statement, and that makes the under-brace label "in-sample error $u_t$" coincidentally land on the wrong side: $u_t$ in the SCPI paper is defined as $(w^* - \hat{w})^\top Y_{0t} + e_t$ for one definition and as just $(w^* - \hat{w})^\top Y_{0t}$ for another — the chapter's labelling is one of those two conventions but the LHS doesn't match it.

**Fix:** rewrite the equation as

```
$$Y_{1t}(0) - \widehat{Y_{1t}(0)} \;=\; \underbrace{(w^* - \hat{w})^\top Y_{0t}}_{\text{in-sample error}} \;+\; \underbrace{e_t}_{\text{out-of-sample error}}.$$
```

and then add one sentence: "Since $\hat\tau_t = Y_{1t} - \widehat{Y_{1t}(0)}$, the same error decomposition translates directly into a prediction interval for $\hat\tau_t$." This keeps the prose around the equation (which is fine) and corrects only the LHS.

### M2. `06-synthetic-control-prediction-intervals.qmd:105` — lasso constraint is stated as $\|w\|_1 \le 1$, but $Q$ is tunable

Line 105 writes the lasso constraint as "lasso ($\|w\|_1 \le 1$, no sign restriction)". `scpi`'s actual lasso constraint is $\|w\|_1 \le Q$ where $Q$ defaults to 1 but is user-settable (verified in `?scpi::scpi`, "If `name == 'lasso'` then $\|w\|_1 \leq Q$, where Q is by default equal to 1 but it can be provided as an element of the list"). The audit brief explicitly flags this: "lasso: ‖W‖₁ ≤ Q". Hard-coding $Q = 1$ in the mathematical statement, when the surrounding text positions the constraint families as "the four classical optimisation problems", obscures the tuning-parameter role and misleads readers who then go to `scpi` documentation.

**Fix:** rewrite line 105 to

> "...lasso ($\|w\|_1 \le Q$ with $Q$ a tuning parameter, default $Q = 1$ in `scpi`), ridge ($\|w\|_2 \le Q$ with $Q$ chosen from the data as $(J + K)\hat\sigma_u^2 / \|\hat{w}_{\rm OLS}\|_2^2$), and OLS (unconstrained)."

This both fixes the lasso statement and elevates the data-driven nature of ridge's $Q$ from the parenthetical "data-driven $Q$" to an explicit formula, which is useful for readers who want to understand why ridge "behaves" in the comparison.

### M3. `06-synthetic-control-prediction-intervals.qmd:105` — ridge constraint omits the "data-driven $Q$" formula and could be misread as squared L2

The chapter writes the ridge constraint as "$\|w\|_2 \le Q$ with data-driven $Q$" — the L2 norm, not the squared L2 norm. This matches `scpi`'s actual implementation ($\|w\|_2 \leq Q$, verified in `?scpi::scpi`). Note that the audit brief's framing — "ridge: ‖W‖₂² ≤ Q" — is *not* the form scpi uses; the chapter's $\|w\|_2 \leq Q$ statement is the correct one for this package and should be kept. The issue is only that "data-driven $Q$" is too vague — see M2 above for the suggested expansion.

### M4. `:24` — placebo test is described as "conflating both sources into a single rank"

The chapter contrasts SCPI with the chapter-4 placebo test by saying "The placebo test in chapter 4 conflates both sources into a single rank." This is slightly misleading: the Fisher-exact MSPE-ratio test in chapter 4 doesn't conflate $u_t$ and $e_t$ — it never models them. The placebo test asks "is California's pre-vs-post MSPE ratio extreme relative to placebo states?", which is a permutation-distribution argument that bypasses the $u_t / e_t$ decomposition entirely. Saying "conflates" implies the placebo is doing something *worse* with the decomposition; the cleaner phrasing is that the placebo *avoids* the decomposition and is therefore agnostic to which source dominates, at the cost of producing a rank rather than an interval.

**Fix:** rewrite `:24` as

> "The placebo test in chapter 4 sidesteps the decomposition entirely — it ranks California against permuted-treatment states without modelling $u_t$ or $e_t$ — and so produces a $p$-value rather than an interval. `scpi` quantifies the two error sources separately and reports an interval $[\hat\tau_t - L, \, \hat\tau_t + U]$ with finite-sample coverage."

### M5. The chapter never compares SCPI with conformal inference

The audit brief lists "Is the comparison with placebo/conformal inference made?" as a methodology check. The placebo comparison is made (in M4, imperfectly); the **conformal** comparison is not made at all. This matters because Chernozhukov–Wüthrich–Zhu (2021), Chernozhukov–Wüthrich–Zhu (2025), and the `cfDID`/conformal-SC literature provide a competing frequentist-coverage framework for synthetic control inference, and a reader who finishes this chapter will have no idea that alternative exists. One paragraph in the "Why a third SC chapter?" section, or as a "Further reading" bullet, is enough.

**Fix:** add a sentence to `:11` after the `@cattaneo2025scpi` citation: "A parallel frequentist-coverage literature builds prediction intervals via *conformal inference* (Chernozhukov, Wüthrich & Zhu 2021), which trades the parametric in-sample / out-of-sample decomposition for distribution-free quantile guarantees; see Further reading." Then add the Chernozhukov reference to `references.bib` and to the Further-reading list at `:431–436`.

### M6. `:262` — the "Gaussian-method 95% PI" loses the joint-confidence-level subtlety

Line 262 says the inference block carries "the Gaussian-method 95% prediction-interval lower (`CI.all.gaussian[, 1]`) and upper (`CI.all.gaussian[, 2]`) bounds for each post-period year." This is fine but glosses over a subtle issue that the *Sensitivity* section at `:353` then suddenly invokes: the band built from `u.alpha = 0.05` and `e.alpha = 0.05` is **not** a 95% PI in the usual sense — it is conservative at level $1 - (u.alpha + e.alpha) = 0.90$ by a Bonferroni-style union bound on the two error sources. The Sensitivity section labels the bands "$1 - (u_\alpha + e_\alpha)$" which is consistent with this reading, but earlier the chapter (`:262`, `:266`, `:321`, the Recap row at `:426`) calls the same band "95%". That mismatch will confuse a careful reader.

The `scpi` package's own conventions are arguably to blame, but the chapter should explain the convention once and stick with it.

**Fix:** after `:259`, add

> "**A note on confidence levels.** Setting `u.alpha = 0.05` and `e.alpha = 0.05` yields a band that is *jointly* conservative at level $1 - (u_\alpha + e_\alpha) = 90\%$ by a Bonferroni-style union bound: the two error sources are bounded separately at 95% each. We follow the JSS-paper convention and call this the '95% band' throughout, but the sensitivity analysis later in the chapter sweeps the joint level $1 - (u_\alpha + e_\alpha)$ directly."

Then either keep the "95% PI" shorthand throughout (with a footnote) or switch all four "95%" instances to "joint 90%" — but pick one.

### M7. `:240` — `e.method = "gaussian"` is presented as a "JSS-paper recommendation" but is actually a *choice*

Line 240 lists `e.method = "gaussian"` among "the JSS-paper recommendations". `scpi`'s package default is `e.method = "all"` (verified in `?scpi::scpi`), which fits Gaussian, location-scale, *and* quantile-regression bounds and stores all three. The JSS replication script does showcase `"gaussian"` for the Prop 99 illustration, so "JSS-paper recommendation" is not technically false, but a reader who searches the help page will see a different default and be confused.

**Fix:** rewrite `:240` as

> "The argument settings below — `u.order = 1`, `u.lags = 0`, `e.order = 1`, `e.lags = 0`, `u.missp = TRUE`, `u.sigma = "HC1"`, `sims = 200` — are the package defaults. We override `e.method = "gaussian"` (the package default is `"all"`, which computes Gaussian, location-scale, and quantile-regression bounds simultaneously) because the Gaussian conditional subgaussian bound is the version proved in @cattaneo2021prediction and is the simplest to interpret for a single-treated-unit panel."

## Code & reproducibility issues

### R1. `:222–234` — the cached ATT table contradicts the prose claims (numerical bug)

This is the single most important issue in the chapter. The Recap (`:424`) claims the simplex point ATT is "≈ $-19.5$ packs/capita per year" and (`:425`, `:236`) that all four ATTs land "between roughly $-15$ and $-22$". The actual cached values in `_freeze/06-synthetic-control-prediction-intervals/execute-results/html.json` (the `tbl-att-by-constraint` HTML payload, lines 1244–1259 of the freeze) are:

| Constraint | ATT  | Min gap | Max gap |
|-----------|------|---------|---------|
| simplex   | **−11.11** | −18.65 | −4.30 |
| lasso     | **−15.28** | −23.89 | −6.19 |
| ridge     | **−15.77** | −23.22 | −4.81 |
| ols       | **−14.24** | −20.39 | −5.00 |

So:
- The ATT range is **$-11$ to $-16$** (not $-15$ to $-22$).
- The simplex ATT is **$-11.11$** (not $-19.5$).
- The pre-vs-post *gap range* across all constraints is roughly $-24$ to $-4$ — and that gap range, *not* the ATT range, is plausibly where the "$-15$ to $-22$" figure on `:236` came from (some of the per-year max gaps approach $-24$; some min gaps approach $-4$). The prose has confused average gaps with year-by-year gaps.

**Fix (mandatory before next publish).** Three coordinated edits:

1. `:236` — replace "All four estimators place the ATT between roughly $-15$ and $-22$ packs/capita per year." with: **"All four estimators place the average post-period gap between roughly $-11$ and $-16$ packs/capita per year, with year-by-year gaps as deep as $-24$ in the late 1990s."**
2. `:424` (Recap, "What is the simplex point ATT?") — replace "≈ $-19.5$ packs/capita per year, 1989–2000" with **"≈ $-11.1$ packs/capita per year, 1989–2000 (outcome-only matching; cf. chapter 4's $-18.85$ with predictor-augmented matching)."**
3. `:425` (Recap, "Does the ATT survive the constraint choice?") — replace "between roughly $-15$ and $-22$ packs" with **"between roughly $-11$ and $-16$ packs"**.

After these edits, also re-render and confirm the `tbl-att-by-constraint` payload still matches.

### R2. `:54` — outcome-only matching breaks comparability with chapter 4 without saying so

The data-prep paragraph at `:54` justifies outcome-only matching (no `lnincome`, `beer`, `age15to24`) on the grounds that those covariates "carry many NAs in the early pre-period and would force row deletions that bias the donor pool". That is correct as far as it goes, but it has a major downstream consequence the chapter never names: **chapter 4 uses those covariates as predictors** (via `tidysynth::synthetic_control() |> generate_predictor(...)`), and that is one large driver of the simplex-ATT gap between the two chapters ($-18.85$ in ch. 4 vs $-11.11$ here). A reader who notices the discrepancy — and they will, once R1 above is fixed — has no story for it.

**Fix:** add a sentence to `:54` after the covariate explanation:

> "This is an intentional departure from chapter 4, which used `lnincome`, `beer`, and `age15to24` as auxiliary predictors via `tidysynth::generate_predictor()`. The covariate-rich match in chapter 4 produces a tighter pre-period fit (and a more negative simplex ATT of $-18.85$); outcome-only matching here is more conservative and more honest about the missing-data structure. We return to this comparison in the Recap."

Then in the Recap-table simplex-ATT row, add the parenthetical "cf. chapter 4's $-18.85$ with predictor-augmented matching" (already proposed in R1).

### R3. `:37` — `set.seed(42)` is set globally but `scpi` may have its own internal RNG

`scpi` simulates `sims = 200` draws inside `quantify in-sample uncertainty`. The package's behavior is to honour the ambient R RNG state, so `set.seed(42)` at chunk-top does make the four `scpi(...)` calls reproducible *as a sequence* — but if the `scpi-all` chunk (`:298`) ever re-runs in isolation (which happens during preview / `freeze: auto` invalidation of just that one chunk), the seed will have advanced unpredictably from where `pi_simplex` left it and the prediction-interval bounds will shift slightly between renders. This is a low-probability annoyance, not a correctness bug, but it can produce confusing "why did the band move?" diffs in `_freeze/`.

**Fix:** add a `set.seed(42)` inside the `scpi-simplex` chunk (after `:246`), the `scpi-all` chunk (after `:301`), and the `scpi-sensitivity` chunk (after `:358`). One line each. This makes every chunk independently reproducible.

### R4. `:269`, `:303`, `:325` — `pi_simplex$inference.results$CI.all.gaussian` accessor pattern is undocumented

The code reaches into `$inference.results$CI.all.gaussian` directly three times. This works (verified in the freeze cache), but `scpi` also exposes a tidy `summary()` accessor and a `scplot()` method. For pedagogical clarity, a one-liner showing what `CI.all.gaussian` actually is would help. The chapter mentions the slot name on `:262` but never shows its structure.

**Fix:** after `:262`, add a tiny code block (a few lines, not a full chunk) showing the structure:

````markdown
```{r}
#| label: pi-simplex-inspect
str(pi_simplex$inference.results$CI.all.gaussian)
```
````

or, alternatively, replace the raw-slot pattern with `summary(pi_simplex)` once and unpack the printout.

### R5. `:325`, `:351` — `cores = 1` is suboptimal and slows the chapter render

All three `scpi()` calls pass `cores = 1`. On the reviewer's machine this builds `scpi_fits` (4 fits) and `sens_fits` (4 fits) serially. `scpi` honours `cores` only when the V matrix is non-diagonal, which is *not* the case here (the chapter uses the default diagonal V via `scdata`'s single-treated-unit path), so `cores = 1` vs higher values is in fact a no-op for the simulation step — but it is also misleading to readers who think they can speed the chapter up by raising it. Either drop the `cores` argument entirely (let it default to 1) or add a one-sentence note.

**Fix:** drop `cores = 1` from the three `scpi(...)` calls at `:258`, `:313`, `:373`. The default is already 1 and the explicit argument suggests there is a tuning knob worth turning when, for this dataset, there isn't.

### R6. `_freeze/.../html.json` carries a `geom_ribbon` warning that should be silenced

The frozen `fig-pi-simplex` cell emits a `Warning: Removed 19 rows containing missing values or values outside the scale range (geom_ribbon())` (frozen at line 1328 of `html.json`), and `fig-pi-all` emits the same warning with 88 rows. These are expected — the chapter intentionally pads `ci_lo` / `ci_hi` with `NA` over the pre-period (`:277`, `:332`) so the ribbon only draws post-1989 — but the warning shows up in the rendered HTML and looks like a bug.

**Fix:** add `#| warning: false` to the `fig-pi-simplex` chunk header at `:265` and the `fig-pi-all` chunk header at `:320`. The other warnings the chapter doesn't want are already suppressed at the file's chunk headers; these two were missed.

### R7. `:367` — `e.alpha = a, u.alpha = a` doubles the alpha sweep

The sensitivity sweep sets `e.alpha = a` AND `u.alpha = a` to the same `a`. Combined with the union-bound interpretation flagged in M6, this means the labelled "80% / 90% / 95% / 99%" bands actually correspond to joint coverage of $1 - 2a$ — i.e. **60% / 80% / 90% / 98%**, not 80/90/95/99. The figure caption at `:381` and `:393` consequently mislabel the bands. The plot in `fig-sensitivity` shows clearly nested bands so the visual argument survives, but the numerical labels are off by a Bonferroni factor.

**Fix:** either
- (a) keep the band-construction logic and relabel `paste0(100 * (1 - alpha_levels), "%")` → `paste0(100 * (1 - 2 * alpha_levels), "%")` at `:376` and `:393` and the legend at `:412–413`, *and* update the caption at `:381` to "Nested bands at 60%, 80%, 90%, 98% joint coverage"; or
- (b) keep the labels at 80/90/95/99 but use `u.alpha = a/2, e.alpha = a/2` at `:371` so that the joint level is exactly $1 - a$. Option (b) is cleaner and preserves the figure's intended message.

## Cross-chapter consistency issues

### C1. Notation mismatch with chapter 4 — `Y_{1t}(0)`, `Y_{0t}`, `w`

Chapter 4 (`04-classical-synthetic-control.qmd:33–45`) uses:
- $X_1$, $X_0$ for *predictors* (treated, donor)
- $w^*$ for the simplex-optimal weights
- $\widehat{Y_{1t}(0)} = \sum_{j} w_j^* Y_{jt}$

Chapter 6 uses:
- $Y_{1t}$ for the treated outcome (no $X$)
- $Y_{0t}$ for the $J$-vector of donor outcomes
- $\hat{w}$ for fitted weights, $w^*$ for the "true" weights

These are *not in conflict* (chapter 6 is outcome-only, so it never needs the $X$/predictor symbol), but a reader paging from chapter 4 to chapter 6 has to mentally re-key the same letters. The transition is silent.

**Fix:** in `:15–17`, add a one-sentence bridge: "In chapter 4's notation we would write $\widehat{Y_{1t}(0)} = \sum_j \hat{w}_j Y_{jt}$ with the V-weighted predictor objective. Chapter 6 omits the predictor matrix $X$ entirely (see Setup) and so works directly with donor outcomes $Y_{0t}$." This is also where the R2 cross-chapter-comparability note about predictor-augmented vs outcome-only matching can be reinforced.

### C2. The transition *into* the chapter (from chapter 5, BSTS) is missing

`05-structural-bayesian-ts.qmd`'s last paragraph (verified, last 30 lines) closes with a Recap on CausalImpact's credible interval, but nothing forward-points to chapter 6. Chapter 6's opening at `:7–9` reaches back to chapter 4 (Fisher rank) and chapter 5 (Bayesian credible), which is good, but a one-sentence "in chapter 7 we will see a Bayesian *spatial* extension that also relaxes SUTVA" forward-pointer is missing too — see C3.

**Fix (minor):** at the end of chapter 5, add a one-line "Next: chapter 6 builds a frequentist prediction interval for the same synthetic-control estimator." This is technically an edit to chapter 5, not chapter 6, but it closes the loop.

### C3. No outward transition to chapter 7 (Bayesian spatial SC)

Chapter 7 opens with `## Why a third synthetic-control chapter?` (`07-bayesian-spatial-sc.qmd:5`) — **identical heading to chapter 6's opening** (`06-synthetic-control-prediction-intervals.qmd:5`). Two consecutive chapters cannot both be "the third synthetic-control chapter". From the reader's vantage point chapter 7 is actually the *fourth*. Chapter 7 also explicitly frames itself as the SUTVA-relaxation chapter, but chapter 6 never hands the baton across — there is no closing "next chapter relaxes SUTVA" sentence.

**Fix:** two coordinated edits:
1. **Chapter 7, `:5`** — rename `## Why a third synthetic-control chapter?` to `## Why a fourth synthetic-control chapter?` and update its opening paragraph to acknowledge chapter 6 alongside chapters 4 and 5. (This edit is *outside* the scope of the chapter-6 audit but is logged here because both chapters share the same opening heading — a reader will notice immediately.)
2. **Chapter 6, after the Further reading list at `:436`** — add a one-line "Coming up" pointer:

   > "Chapter 7 builds a *fourth* synthetic-control perspective: a Bayesian horseshoe-prior weight model coupled with a spatial-autoregressive donor DGP. That chapter is the first in the book that relaxes the stable-unit-treatment-value assumption (SUTVA) — donors are allowed to be themselves affected by California's policy."

### C4. The chapter never engages with the "Bayesian credible vs frequentist PI" comparison it sets up

Lines 7–9 motivate the chapter as the *frequentist* answer to chapter 5's *Bayesian credible interval* construction. But neither the chapter body nor the Recap returns to this contrast. A reader who finishes chapter 6 has no answer to "OK, so when should I prefer SCPI's PI vs CausalImpact's credible interval, given that the headlines look similar?".

**Fix:** add a Recap row (`:421` table) at the end:

```
| How does this differ from chapter 5's credible interval? | SCPI's PI has finite-sample frequentist coverage and is a statement about the synthetic counterfactual; CausalImpact's credible interval is a posterior probability statement about the parameter, conditioned on the prior. They tend to agree when the BSTS prior is uninformative and the SCPI in-sample uncertainty term dominates. |
```

### C5. Chapter 4's `-18.85` ATT and chapter 6's `-11.11` simplex ATT need a one-sentence reconciliation

See R1 and R2. The numerical gap between chapter 4's simplex result and chapter 6's simplex result is large (≈ 7 packs) and is driven by (a) predictor-augmented vs outcome-only matching, (b) `tidysynth` vs `scpi` solver, (c) `scpi`'s `constant = TRUE` intercept. The chapter currently cannot answer "why are the two simplex ATTs different?" because it never poses the question.

**Fix:** the Recap-row edit proposed in R1 ("cf. chapter 4's $-18.85$ with predictor-augmented matching") is the minimum acceptable disclosure. A fuller treatment would be one short paragraph at the end of the *Donor weights side-by-side* section, between `:140` and `:142`.

## Writing & structure issues

### W1. No `## Common pitfall` section — chapter is structurally out of step with chs. 4, 5, 7

Chapters 4 (`:195`), 5 (`:173`), and 7 (`:` — implicit in the recap) all carry an explicit `## Common pitfall` section or a clearly demarcated callout. Chapter 6 has *one row* in the Recap table (`:429`) flagging "Adding covariates with NAs forces row deletions that bias the donor pool", but no standalone section. The audit brief explicitly lists `## Common pitfall` as a structural expectation.

**Fix:** add a `## Common pitfall` section between *Sensitivity to confidence level* and *Recap* (i.e. after `:417`). Two pitfalls worth naming:

```markdown
## Common pitfall

**Reading the band as a confidence interval for the treatment effect.** An scpi prediction interval covers the *synthetic counterfactual* $\widehat{Y_{1t}(0)}$ — it tells you the range of values the synthetic-California series could plausibly take if you re-ran the donor-weight estimator on a parallel pre-period draw. The treatment effect $\hat\tau_t = Y_{1t} - \widehat{Y_{1t}(0)}$ then "matters" when observed California leaves the band: that is the inferential statement. Reading the band as a $\pm$ on the *effect size* (the way one would read an OLS confidence interval on a regression coefficient) is wrong, and it is the most common misuse of the package in applied work.

**Hard-coding the lasso $Q$ without checking sensitivity.** The chapter's lasso fits use scpi's default $Q = 1$, which is what gives lasso and simplex such similar weight vectors (lasso = "L1 ball of radius 1"; simplex = "L1 ball of radius 1, restricted to the non-negative orthant"). Pushing $Q$ above 1 lets lasso assign weight outside the simplex on either side and changes the picture. A serious lasso analysis would sweep $Q$ over a grid; we keep $Q = 1$ for comparability with the simplex.
```

### W2. `:240` (and `:262`, `:266`, `:295`, `:321`, `:381`) — overload of the word "interval"

The chapter uses "prediction interval", "PI", "band", "ribbon" interchangeably. This is fine in informal speech but mixed in mathematical writing. Pick one (recommend "prediction interval", abbreviated "PI" after first definition) and use it consistently. The current pattern is:

- "prediction interval" (full): `:9`, `:11`, `:23`, `:25`, `:240`, `:262`, `:266`, `:321`, `:381`, `:423`, `:427`
- "PI": `:295`, `:414` (legend label "PI level")
- "band": `:353`, `:417`, `:489` (Recap mismatch)
- "ribbon": `:283`, `:321`, `:340`

**Fix:** introduce "prediction interval (PI)" once after first use at `:11`, then use "PI" or "PI band" thereafter. Replace "ribbon" with "PI band" everywhere except in the geom-layer code itself (`geom_ribbon` is the ggplot function name and should stay).

### W3. `:236` — "an economically meaningful amount" is editorially soft and ungrounded

The closing sentence of *Synthetic counterfactuals across constraints* is "Whatever one believes about the simplex, Proposition 99 reduced California cigarette sales by an economically meaningful amount." The phrase "economically meaningful" is doing work here that is not earned — the chapter never anchors a magnitude (e.g. "$-11$ packs/capita per year on a baseline of $\approx 90$ packs is a 12% reduction").

**Fix:** rewrite as: "On a baseline of $\approx 90$ packs/capita per year, an average post-period gap of $-11$ to $-16$ packs corresponds to a $\approx 12$–$18\%$ reduction. Whatever one believes about the simplex, Proposition 99 reduced California cigarette sales by an economically meaningful share of pre-policy consumption." (Note: this also benefits from the R1 numerical fix.)

### W4. `:111`, `:144` — table and figure captions hard-code "Top 10 / Top 12" without a methodological justification

The donor-weights table shows the top 10 states by `pmax(abs(simplex), abs(lasso), abs(ridge), abs(ols))`; the heatmap shows top 12. The rationale is "show the donors that *some* constraint cares about". This is fine, but the captions don't say *what* ordering criterion was used, and 10-vs-12 between adjacent outputs reads as arbitrary.

**Fix:** unify both at 12 (the heatmap's count) and rewrite the table caption at `:111` as:

> "Donor weights from each of the four scpi weight-constraint families, for the 12 donors with largest maximum absolute weight across the four constraints."

and the heatmap caption at `:144` to match.

### W5. `:435` — Further-reading list is missing the conformal alternative and the SCPI Stata/Python companion

The Further-reading list has four items, all `scpi`-or-tidysynth-internal. Two natural additions:

- **Chernozhukov, Wüthrich & Zhu (2021)** on conformal inference for synthetic control — see M5.
- The **`scpi` Python and Stata implementations**, which are explicitly named in `@cattaneo2025scpi`'s abstract. A reader writing replication code in Python or Stata should know they exist.

**Fix:** add to `:431–436`:

```markdown
- Chernozhukov, V., Wüthrich, K. & Zhu, Y. (2021). An exact and robust conformal inference method for counterfactual and synthetic controls. *Journal of the American Statistical Association*. — A distribution-free frequentist alternative to scpi's parametric in-sample / out-of-sample decomposition.
- The companion **Python (`scpi_pkg`) and Stata (`scpi`)** packages, documented at <https://nppackages.github.io/scpi/>, expose the same API as the R package used in this chapter.
```

Add the Chernozhukov entry to `references.bib`.

### W6. No "key concepts at a glance" or learning-objectives block — but this is intentional per recent commit `1718668`

Commit `1718668` ("Remove 'Key concepts at a glance' section from ch.7") removed that block from chapter 7, so I assume the author has decided against the format. Flagging only so the audit log has a record: chapter 6 also has no such block, which is internally consistent with the rest of the book. **No fix.**

## Infrastructure issues

### I1. None blocking

- The chapter is listed in `_quarto.yml` (verified by the freeze cache existing).
- The freeze cache at `_freeze/06-synthetic-control-prediction-intervals/execute-results/html.json` is current (47KB, all four scpi fits cached).
- The setup chunk sources `R/table_helpers.R` correctly (`:35`) and uses `gt_pretty()` with `decimals = ...` and Quarto-native caption labels — both per CLAUDE.md.
- The chapter does not pass `title=` or `subtitle=` to `gt_pretty()` (CLAUDE.md rule).
- The transparent-background theme block (`:39–51`) matches the style used in chapters 4, 5, 7.
- The 200-simulation budget for `scpi()` is consistent across all three `scpi()` invocations.

### I2. Chapter filename rename will require an update to `R/build_chapter_zips.R`

This file is `06-synthetic-control-prediction-intervals.qmd`. Per CLAUDE.md, "If you add a new content chapter, the only manual step is appending its filename to the `chapters` vector in `R/build_chapter_zips.R`." The git status at the start of this audit shows this filename is **new** (untracked: `?? 06-synthetic-control-prediction-intervals.qmd`). Confirm that `R/build_chapter_zips.R` already has `"06-synthetic-control-prediction-intervals"` (without the `.qmd`) in its `chapters` vector; if not, the per-chapter zip download for this chapter will fail to be built. (This is mechanical, not a chapter-content issue, but it is the single infrastructure step that lives outside the .qmd file.)

**Fix:** verify and, if missing, append the chapter slug to `R/build_chapter_zips.R`'s `chapters` vector.

## Prioritized fix list

### P1 — must fix before next publish (correctness)

- **R1** `:236`, `:424`, `:425` — replace the wrong simplex ATT (≈ $-19.5$) and wrong constraint-ATT range ($-15$ to $-22$) with the actual cached values (simplex $-11.11$; range $-11$ to $-16$). **Highest priority — this is the only outright factual error in the chapter.**
- **M1** `:21` — fix the LHS of the error-decomposition equation (`\tau_t - \hat\tau_t` → `Y_{1t}(0) - \widehat{Y_{1t}(0)}`).
- **R7** `:367`, `:376`, `:381`, `:393`, `:412–413` — the sensitivity sweep's band labels are off by a Bonferroni factor. Either relabel as 60/80/90/98 or use `u.alpha = a/2, e.alpha = a/2`. The latter is cleaner.
- **C5** `:424` — add the one-line reconciliation against chapter 4's `-18.85` (folded into the R1 Recap-row edit).

### P2 — should fix soon (pedagogical clarity and structural consistency)

- **W1** Add a `## Common pitfall` section after `:417`. Two pitfalls (band-as-effect-CI; lasso $Q$ hard-coded).
- **R2** `:54` — add the predictor-augmented-vs-outcome-only sentence reconciling with chapter 4.
- **M2** `:105` — rewrite lasso constraint as $\|w\|_1 \le Q$ with $Q$ default 1; expand the ridge $Q$ description with the data-driven formula.
- **M4** `:24` — rewrite the placebo/SCPI contrast ("conflates" → "sidesteps").
- **M6** `:259` — add the joint-coverage / Bonferroni note before the 95% label.
- **M7** `:240` — clarify that `e.method = "gaussian"` is a chosen override of the package default.
- **C3** `:436` (and chapter 7's heading) — fix the duplicate "Why a third SC chapter?" heading and add a "Coming up" pointer.
- **C4** `:421` — add a Recap row contrasting SCPI's PI with chapter 5's credible interval.
- **C1** `:15–17` — add a one-sentence notation-bridge to chapter 4.
- **W2** unify "prediction interval" / "PI" / "band" / "ribbon" terminology.

### P3 — nice-to-have polish

- **M5** `:11` and `:436` — add a one-sentence pointer to conformal inference (Chernozhukov–Wüthrich–Zhu 2021) in the intro and to Further reading.
- **R3** `:246`, `:301`, `:358` — add `set.seed(42)` inside each `scpi(...)` chunk so individual re-runs are reproducible.
- **R4** `:262` — show `str(pi_simplex$inference.results$CI.all.gaussian)` or replace raw-slot access with `summary()`.
- **R5** `:258`, `:313`, `:373` — drop the redundant `cores = 1` argument.
- **R6** `:265`, `:320` — add `#| warning: false` to silence the `geom_ribbon`-NA warnings.
- **W3** `:236` — replace "economically meaningful amount" with a percentage-of-baseline anchored figure.
- **W4** `:111`, `:144` — unify the table and heatmap at 12 donors and rewrite captions to explain the ranking criterion.
- **W5** `:431–436` — add Chernozhukov et al. (2021) and the scpi Python/Stata companion to Further reading.
- **C2** `05-structural-bayesian-ts.qmd` — add a one-line forward-pointer to chapter 6 (edit lives in chapter 5, not 6).
- **I2** verify the chapter slug is in `R/build_chapter_zips.R`'s `chapters` vector.
