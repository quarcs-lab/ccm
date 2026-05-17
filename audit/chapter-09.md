# Audit: Chapter 9 — Matrix Completion and Interactive Fixed Effects (`09-matrix-completion-and-ife.qmd`)

## Summary

Chapter 9 is the methodological turning point of Part II: it relaxes parallel trends by modelling $Y(0)$ with a low-rank factor structure, and demonstrates two implementations of that idea (IFEct, MC) on the Callaway-Sant'Anna minimum-wage panel via `fect`. The chapter is well-written, the prose is concise, and the short-panel caveat callout (`09-matrix-completion-and-ife.qmd:282–290`) is exactly the kind of honesty the book promised. The cohort table, panel-view, and twin counterfactual / event-study figures form a clean storyboard.

There are, however, four issues that should be fixed before a clean reader pass: (1) the chapter's empirical headline contradicts its own framing — the CV-selected rank is **r = 0**, meaning IFEct has collapsed to TWFE, but the prose and the "IFEct vs MC compared" section talk as if a non-trivial factor model was fit; (2) the `min.T0` framing in the data-window paragraph mis-describes the rank-cap mechanism; (3) the `lemp ~ D` formula omits the `lpop + lavg_pay` covariates that the model expression $Y_{it}(0) = \alpha_i + \xi_t + \lambda_i' f_t + \varepsilon_{it}$ implicitly allows and that the sibling chapter (`10-gsynth.qmd`) does include — and the asymmetry is not acknowledged; (4) no headline ATT number is ever printed, so the qualitative claim "both point downward; both sit in the same neighbourhood" is unverifiable from the page itself. A handful of smaller issues round it out: a `lambda` notation collision inside the chapter (loading vector vs MC penalty), a missing `display.all = TRUE` on `panelview()` (silently subsampling 500 of 1,745 counties), an absent Exercises section that breaks symmetry with chapters 8 and 10, and a couple of cross-chapter cross-references that would make the place of this chapter clearer.

The methodology, citations, seeds, and freeze cache are otherwise solid.

## Strengths

- **Hook works.** The opening section (`09-matrix-completion-and-ife.qmd:5–44`) reframes the chapter as a relaxation of the assumption ch.8 leaned on, motivates the factor structure with concrete substantive content (industry mix, demographics), and lands the two-estimator preview cleanly.
- **The factor model is written cleanly** with the exact two-way-FE-plus-interaction form `09-matrix-completion-and-ife.qmd:25`, which matches the `force = "two-way"` argument used in both `fect()` calls. No FE / no-FE inconsistency.
- **All four key citations are present in `references.bib`:** `@bai2009panel` (lines 272–282), `@xu2017generalized` (236–246), `@athey2021matrix` (248–258), `@liu2024practical` (260–270). The pairing of `@bai2009panel; @xu2017generalized` for IFEct on line 33 is the right attribution.
- **Honest borderline-identifiability callout** (`09-matrix-completion-and-ife.qmd:282–290`): explicit T=7, 3 pre-periods, capped rank ≤ 2, plus the "*not* run them rather than hand-pick a rank" line. This is the right tone for a teaching book.
- **Reproducibility.** `set.seed(42)` is set globally (line 58) **and** passed inside both `fect()` calls (lines 200 and 220). Since `fect` does parametric/nonparametric bootstrap, both seeds matter — the chapter gets it right.
- **Freeze cache is healthy.** `_freeze/09-matrix-completion-and-ife/execute-results/html.json` exists, hash `928d6b75...`, with `dim(mw) = 12215 × 21` and rendered values `r = 0` and `lambda = 0.0007` printed in `_book/09-matrix-completion-and-ife.html`.
- **Window change is consciously explained.** Lines 77–84 walk the reader through *why* 2003 (ch.8) is too short for factor identification and *why* the window had to widen — a model of cross-chapter scaffolding.
- **Common-pitfall callout** (`09-matrix-completion-and-ife.qmd:310–317`) flags the right failure mode (over-fitting masquerading as identification) and applies it to both methods symmetrically.
- **`patchwork` composition** on `09-matrix-completion-and-ife.qmd:262` gives the reader a 2×2 grid that lines IFEct against MC on equal footing.

## Methodology issues

### M1. `09-matrix-completion-and-ife.qmd:270–280` — the "IFEct vs MC compared" claim is contradicted by the actual `r.cv = 0`

This is the most serious issue in the chapter. The cached output of `tbl-cv` (verified at `_book/09-matrix-completion-and-ife.html` line containing `r = 0`) reports:

| Method | CV-selected |
|--------|-------------|
| IFEct  | r = 0       |
| MC     | lambda = 0.0007 |

When IFEct's cross-validation picks `r = 0`, **the factor term $\lambda_i' f_t$ drops out** and IFEct collapses to plain two-way fixed effects. That is exactly the corner case the chapter itself names on line 165 ("the $r = 0$ corner of IFEct"). So the empirical reality is that on this panel, with this window, CV cannot find evidence of a low-rank latent factor that two-way FE doesn't already absorb.

But the prose on `09-matrix-completion-and-ife.qmd:272–280` reads as if IFEct fit a non-trivial factor model:

> "Two estimators that disagree about the identifying assumption — an explicit linear factor model vs. an approximately low-rank $Y(0)$ matrix — point to the same sign and the same order of magnitude on this panel."

If IFEct is at `r = 0`, the "explicit linear factor model" is *not what was fit*. The chapter is comparing TWFE-on-fect's-bootstrap-machinery to MC, not IFE to MC. This needs an explicit acknowledgement, and ideally a one-sentence interpretation: either "the panel is too short for CV to detect a latent factor" or "factor structure beyond two-way FE is not detectable here, which is itself a finding."

**Fix:** add a short paragraph immediately after `tbl-cv` (between lines 233 and 235), something like:

> Note the IFEct selection: CV picks $r = 0$, which means IFEct on this panel collapses to two-way fixed effects — there is no detectable low-rank latent factor beyond the unit and year effects. This is not a bug, it is a finding: with $T = 7$ and 3 pre-periods on the shorter cohort, CV is conservative and refuses to credit a factor it cannot validate out-of-sample. The MC fit, by contrast, lands on a small but non-zero nuclear-norm penalty ($\lambda = 0.0007$), so MC retains a regularised low-rank deviation from TWFE.

Then rewrite the first sentence of the comparison section to say "*in principle* an explicit linear factor model vs. an approximately low-rank matrix" rather than implying a non-trivial factor was actually estimated.

### M2. `09-matrix-completion-and-ife.qmd:77–84` — the `min.T0` framing of the window-change argument is imprecise

The data-window paragraph says:

> "Chapter 8's 2003-2007 window leaves the 2004 cohort with only one pre-period, which would force `min.T0 = 1` and cap the rank at zero — collapsing IFEct back to TWFE."

Two problems here:

1. **`min.T0` is a *user-set* sample-inclusion threshold, not a quantity forced by the data.** `min.T0 = k` tells `fect` "drop treated units with fewer than k pre-treatment periods." If you set `min.T0 = 2` on ch.8's window, the 2004 cohort with one pre-period is *dropped*, not forced. The sentence reads as if the data picks `min.T0` for you.
2. **The relevant rank constraint is `r < T0` (per-unit), not "rank = 0 when min.T0 = 1."** For a treated unit with one pre-period, IFEct can identify at most `r = 0` factors *for that unit*. So the right framing is: keeping 2004 in the sample on the 2003–2007 window forces `r = 0` for that cohort.

**Fix:** rewrite the second half of that paragraph to:

> "Chapter 8's 2003-2007 window leaves the 2004 cohort with only one pre-period (year 2003). To keep that cohort in the IFE sample we would need `min.T0 = 1`, which in turn caps the identifiable rank at zero — collapsing IFEct back to TWFE. Widening to 2001-2007 gives 2004 three pre-periods (2001-2003), so we can set `min.T0 = 2` and let CV search over $r \in \{0, 1, 2\}$."

That also forecloses M1's surprise: with the rank ceiling honestly stated at 2 (not "up to T/2"), the `r = 0` outcome reads as the conservative end of a *small* search grid, not a failure.

### M3. `09-matrix-completion-and-ife.qmd:25` and `09-matrix-completion-and-ife.qmd:188, 209` — the model equation omits covariates, and so does the `fect()` formula, but ch.10 includes them

The chapter writes the counterfactual model as

$$Y_{it}(0) = \alpha_i + \xi_t + \lambda_i' f_t + \varepsilon_{it}$$

with **no $X_{it}'\beta$ term**, and the corresponding `fect()` calls use `lemp ~ D` (no covariates). Sibling chapter `10-gsynth.qmd:189` uses `lemp ~ treat + lpop + lavg_pay` on the same panel.

Two things to fix:

1. **Internal cross-reference.** A reader who has skimmed ch.1's roadmap (`01-introduction.qmd:96`) sees $\widehat{Y_{it}(0)} = \alpha_i + \xi_t + \lambda_i^\top f_t$ — covariate-free, matching ch.9. But ch.10 includes covariates. Without a one-liner explaining the choice, ch.9 and ch.10 look like they disagree about the model.
2. **Pedagogical opportunity missed.** The whole point of `fect` is that you *can* add covariates to either method. A no-covariate baseline plus a covariate-augmented robustness check would be a natural exercise.

**Fix (minimal):** add a sentence after the model equation on line 25:

> "We write the model without observable covariates for simplicity, but `fect()` accepts a covariate matrix (e.g. `lemp ~ D + lpop + lavg_pay`); chapter 10 uses that extension on the same panel."

Or rewrite the equation as $Y_{it}(0) = \alpha_i + \xi_t + \lambda_i' f_t + X_{it}'\beta + \varepsilon_{it}$, set $X = \emptyset$ in the chapter, and explain.

### M4. `09-matrix-completion-and-ife.qmd:270–280` — no numeric ATT is reported, only plots

The "compared" section makes a quantitative claim ("same sign and the same order of magnitude") but the chapter never prints an estimated ATT for either method. The only ATT-flavoured output is the right-hand event-study panels in `fig-ife-mc`. There is no numeric table the way ch.8 has for its event-study aggregations and ch.10 has for the headline `att.avg`.

This is the difference between a teaching chapter and a research chapter — a one-row-per-method numeric table is cheap and makes the "same neighbourhood" claim falsifiable.

**Fix:** add a chunk between `fig-ife-mc` and the comparison section, e.g.:

````r
```{r}
#| label: tbl-att
#| tbl-cap: "Average ATT (post-treatment) under IFEct and MC, with bootstrap 95% CIs."
tibble(
  Method = c("IFEct", "MC"),
  ATT    = c(out_ife$att.avg, out_mc$att.avg),
  `SE`   = c(out_ife$est.avg[1, "S.E."], out_mc$est.avg[1, "S.E."]),
  `CI lo`= c(out_ife$est.avg[1, "CI.lower"], out_mc$est.avg[1, "CI.lower"]),
  `CI hi`= c(out_ife$est.avg[1, "CI.upper"], out_mc$est.avg[1, "CI.upper"])
) |>
  gt_pretty(decimals = 4)
```
````

(Exact column names depend on `fect`'s return object; verify against `out_ife$est.avg` in a console session.)

### M5. `09-matrix-completion-and-ife.qmd:154–160` — MC's nuclear-norm story is correct but slightly under-motivated for an undergraduate reader

The MC section says nuclear-norm regularisation is "the convex relaxation of 'low rank' the same way $\ell_1$ is the convex relaxation of 'sparse'." That is correct, but a mixed-undergrad reader who has not done convex optimisation has nothing to anchor it to — $\ell_1$ may itself be opaque. One additional sentence makes it land:

> "Concretely: minimise $\| Y_{obs} - \hat Y(0) \|_F^2 + \lambda \, \| \hat Y(0) \|_*$ over $\hat Y(0)$, where $\| \cdot \|_*$ is the sum of singular values. As $\lambda \to 0$ the fit interpolates the observed cells; as $\lambda \to \infty$ all singular values shrink to zero and $\hat Y(0)$ collapses to a constant."

That gives the reader (a) the actual objective, (b) the two limiting regimes, and (c) the bridge to MC's hyperparameter being a continuous knob rather than the integer rank IFE uses.

## Code & reproducibility issues

### C1. `09-matrix-completion-and-ife.qmd:129–134` — `panelview()` silently subsamples 500 of 1,745 counties

The panel has 1,745 unique counties (verified by `length(unique(mw$id))`). `panelview` defaults to displaying at most 500 units and prints the stderr message

> "If the number of units is more than 500, we randomly select 500 units to present. You can set 'display.all = TRUE' to show all units."

(visible in the cached output, `_freeze/09-matrix-completion-and-ife/execute-results/html.json` under `cell-output-stderr`). The chapter does not pass `display.all = TRUE`, does not mention the subsampling in `fig-panelview`'s caption, and a curious reader will see the message without context.

Ch.10 (`10-gsynth.qmd:146`) does pass `display.all = TRUE` — so the two chapters render the *same* panel differently.

**Fix:** either pass `display.all = TRUE` (and bump `fig-height` if needed) to match ch.10, or keep the subsample and add a sentence to the caption: "Plot shows a random subsample of 500 of the 1,745 counties; the staggered-adoption structure is the same on the full panel."

### C2. `09-matrix-completion-and-ife.qmd:124–135` — `#| message: false` / `#| warning: false` are missing on the `fig-panelview` chunk

The two `fect()` chunks (lines 183–202 and 204–222) suppress messages and warnings, but the `fig-panelview` chunk does not. The two stderr messages from `panelview` ("more than 300...gridOff = TRUE", "more than 500...randomly select 500") leak into the rendered page. Compare with ch.10 (`10-gsynth.qmd:140–141`), which suppresses both.

**Fix:** add `#| message: false` and `#| warning: false` chunk options between lines 127 and 128, matching the style used by the `fect` fits below.

### C3. `09-matrix-completion-and-ife.qmd:183–222` — neither `fect` chunk is `cache: true`

Ch.10's gsynth fit (`10-gsynth.qmd:187`) uses `#| cache: true` for the model fits. Ch.9 relies entirely on Quarto's freeze. Freeze is fine for the standard `quarto render` flow, but a user editing a single chunk (say, fixing a `cv.nobs` value) will trigger a full re-fit of *both* `fect` calls every time the chunk changes — and with `nboots = 50` plus `parallel = TRUE`, that is a 30-60-second penalty per iteration.

This is a minor convenience issue rather than a correctness one, and there is an argument for keeping it freeze-only (smaller repo footprint, no `_cache/` to gitignore). Either choice is defensible — flagging only because the sibling chapter chose differently.

### C4. `09-matrix-completion-and-ife.qmd:170–172` — `r = 0:2` rank grid is stated but not justified relative to `min.T0`

The prose says "any $r$ larger than that would be statistical fantasy" (`09-matrix-completion-and-ife.qmd:171`), where "that" presumably refers to `min.T0 = 2`. Two clarifications would help:

1. State the rule explicitly: "we need at least `r + 1` pre-periods to identify `r` factors on a treated unit, so with `min.T0 = 2` we have a theoretical ceiling of `r = 1` — we let CV search up to `r = 2` only to verify it doesn't get fooled into climbing."
2. Currently CV picks `r = 0`. If you keep `r = 0:2` even though the *effective* ceiling is 1, say so. That also retroactively reinforces M1's point — CV chose the most conservative option in a small grid.

## Cross-chapter consistency

### X1. `09-matrix-completion-and-ife.qmd:25, 27` vs `07-bayesian-spatial-sc.qmd:197` — `lambda` is overloaded across chapters and within ch.9 itself

Three uses of $\lambda$ in the book so far:

- `07-bayesian-spatial-sc.qmd:197`: $\lambda_j$ is the **horseshoe-prior local scale** (a positive scalar per coefficient).
- `09-matrix-completion-and-ife.qmd:25, 27, 144, 298`: $\lambda_i$ is the **factor loading vector** for unit $i$ (a vector of length $r$).
- `09-matrix-completion-and-ife.qmd:160, 226, 301`: $\lambda$ (no subscript) is the **MC nuclear-norm penalty weight** (a positive scalar).

Cross-chapter clash (ch.7 vs ch.9) is acceptable — readers don't carry priors across chapters this far apart. The **within-chapter** clash on ch.9 is more concerning: $\lambda_i$ (loadings) and $\lambda$ (penalty) appear on adjacent pages and on the same screen in the `tbl-cv` chunk, which prints "lambda = 0.0007" (the penalty) right after a section that talked about "loading vector $\lambda_i$".

**Fix (light touch):** add a one-line glossary note where the penalty is first introduced (line 160):

> "We will use $\lambda$ without a subscript for the MC penalty to avoid confusion with the unit-level loading vector $\lambda_i$ from IFEct."

That at least flags the collision rather than letting the reader work it out from context.

### X2. `09-matrix-completion-and-ife.qmd:77–84` — window change from ch.8 (2003–2007) to ch.9 (2001–2007) is explained well but does not name ch.8 line-precisely

The paragraph correctly motivates the wider window. It would help to add a parenthetical pointer:

> "Chapter 8's `data2` filter (2003–2007, see `08-staggered-did.qmd:99`) leaves..."

A line-precise back-reference is what advanced-undergrad readers actually need when they re-open the previous chapter to check.

### X3. `09-matrix-completion-and-ife.qmd:5–44` — the intro doesn't preview ch.10

The chapter is the family introduction to interactive fixed effects — both `fect::ife` and `gsynth` belong to the same model class. But the intro doesn't say "chapter 10 zooms in on one estimator in this family (`gsynth`)" the way `10-gsynth.qmd:5–18` says "chapter 9 introduces the IFE family." The cross-reference is asymmetric.

**Fix:** add a sentence at the end of the intro (after line 44):

> "Chapter 10 does the deep dive on one specific member of this family — generalized synthetic control via the `gsynth` package — using the same panel."

### X4. `09-matrix-completion-and-ife.qmd:33` — IFEct attribution conflates two distinct papers

The line cites IFEct as `[@bai2009panel; @xu2017generalized]`. That is *almost* right but slightly mis-attributes:

- @bai2009panel introduced the IFE estimator as a *regression* with interactive fixed effects (no treatment-imputation step).
- @xu2017generalized introduced `gsynth` — the IFE-as-counterfactual-imputation approach. That's what ch.10 covers.
- IFEct *the algorithm in `fect`* is from `@liu2024practical` (which `fect` itself cites as the canonical reference).

So the right attribution chain on line 33 is `[@bai2009panel; @xu2017generalized; @liu2024practical]`, with `@liu2024practical` doing the heavy lifting. The current citation already cites `@liu2024practical` on line 31 for the two-views framing, so just adding it to line 33 is enough.

## Writing & structure

### W1. `09-matrix-completion-and-ife.qmd:1–326` — no Exercises section, breaking symmetry with ch.8 and ch.10

The two surrounding chapters end with an `## Exercises` section (`08-staggered-did.qmd:411`, `10-gsynth.qmd:464`). Ch.9 ends at `## Further reading` (line 319). For a teaching book, the missing exercises section is noticeable.

Three natural exercises, all using objects the chapter has already created:

**Fix:** append before EOF:

````markdown
## Exercises

1. Re-fit `out_ife` with `r = 0:3` (raising the search ceiling above
   the theoretical `min.T0` bound) and inspect `out_ife$MSPE`. Does
   CV ever pick a rank above 0 on this panel? What does that tell
   you about the data?
2. Add the two-covariate extension `lemp ~ D + lpop + lavg_pay` to
   both `fect()` calls, refit, and compare the ATT trajectory. Does
   conditioning on log population and log average pay move the gap
   plot meaningfully?
3. Re-fit `out_mc` on a tighter window (`year >= 2002`) so cohort
   2004 has 2 pre-periods instead of 3. At what window does the MC
   counterfactual visibly break (sharp pre-trend in the gap plot)?
````

That also closes the symmetry hole with chapters 8 and 10.

### W2. `09-matrix-completion-and-ife.qmd:282–290` — the short-panel callout is good but its placement is wrong

The callout is placed *after* the "IFEct vs MC compared" section, which reads as a postscript. Because the borderline-identifiability point shapes *every* result in the chapter, it should live near the top — preferably right before `## Estimating with FECT` (between lines 167 and 168), framing the section, or as a `callout-warning` on the model section.

**Fix:** move the callout block (lines 282–290) to right before line 168 (`## Estimating with FECT`). The current location can be a one-sentence callback like "Returning to the short-panel caveat above: …".

### W3. `09-matrix-completion-and-ife.qmd:5–44` — title vs first-section-heading mismatch is minor but worth a fix

Title (`09-matrix-completion-and-ife.qmd:2`) is "Matrix Completion and Interactive Fixed Effects", which puts MC first; the chapter then discusses IFE first throughout (lines 33, 144, 187, 249, 298). Order in the title is reversed from order in the body.

**Fix:** rename the file's title to `"Interactive Fixed Effects and Matrix Completion"` for body-order match. The filename can stay `09-matrix-completion-and-ife.qmd` (filenames in this book are descriptive, not authoritative — see CLAUDE.md's note on the rename from `04-` to `03-`).

### W4. `09-matrix-completion-and-ife.qmd:115` — `lemp` and `D` are defined here but the lemma "log teen employment" is introduced as a fait accompli

Chapter 8's data section (`08-staggered-did.qmd:104–116`) describes `lemp` thoroughly. Ch.9 says only "the outcome `lemp` (log teen employment)" on line 113. A one-sentence back-reference would help readers who entered the book at ch.9 (e.g. via a search engine):

> "The outcome `lemp` (log teen employment, see chapter 8 for full data provenance) and the treatment indicator `D` line up with chapter 8's definitions."

### W5. `09-matrix-completion-and-ife.qmd:319–326` — "Further reading" omits the `gsynth` companion documentation and the matrix-completion-with-covariates extension

A reader who finishes this chapter and wants to go deeper has only `@bai2009panel`, `@xu2017generalized`, `@athey2021matrix`, `@liu2024practical`, and the `fect` site. Two cheap additions:

- A line pointing at the next chapter explicitly: "Chapter 10 zooms in on `gsynth`, the IFE estimator implemented in a standalone package."
- A pointer to the `MCPanel` package (Athey et al.'s original implementation of matrix completion), for readers who want to compare `fect::mc` against the canonical implementation.

## File-by-file paths referenced

- `/Users/carlosmendez/Documents/GitHub/ccm/09-matrix-completion-and-ife.qmd` — the chapter source under audit.
- `/Users/carlosmendez/Documents/GitHub/ccm/08-staggered-did.qmd` — cohort filter at line 95, window filter at line 99, Exercises section at line 411.
- `/Users/carlosmendez/Documents/GitHub/ccm/10-gsynth.qmd` — sibling chapter that uses `display.all = TRUE` (line 146), `cache: true` (line 187), `min.T0 = 3` (line 197), and includes covariates in the formula (line 189).
- `/Users/carlosmendez/Documents/GitHub/ccm/01-introduction.qmd:96–97` — the roadmap formulae the chapter must match.
- `/Users/carlosmendez/Documents/GitHub/ccm/07-bayesian-spatial-sc.qmd:197` — competing use of `lambda` (horseshoe).
- `/Users/carlosmendez/Documents/GitHub/ccm/references.bib` — `bai2009panel` (272–282), `xu2017generalized` (236–246), `athey2021matrix` (248–258), `liu2024practical` (260–270); all four key citations present and correctly formed.
- `/Users/carlosmendez/Documents/GitHub/ccm/_freeze/09-matrix-completion-and-ife/execute-results/html.json` — verified hash `928d6b75...`, `dim(mw) = 12215 × 21`, `r.cv = 0`, `lambda.cv = 0.0007`.
- `/Users/carlosmendez/Documents/GitHub/ccm/_book/09-matrix-completion-and-ife.html` — rendered output confirms the same `r = 0` / `lambda = 0.0007` table values.
- `/Users/carlosmendez/Documents/GitHub/ccm/R/table_helpers.R` — `gt_pretty()` used at lines 110 and 232; usage correct.
