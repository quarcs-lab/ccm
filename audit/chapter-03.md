# Audit: Chapter 3 — Basic Differences-in-Differences (`03-basic-diff-in-diff.qmd`)

## Summary

A short (145-line), tightly written 2×2 DiD chapter that delivers the intended pedagogical payload: a hand-picked single control (Nevada) collapses the DiD contrast and motivates the move to Synthetic Control in chapter 4. The 2×2 mermaid grid, the regression form, and the numerical hand-off to ch. 4 are all internally consistent: I re-fit `lm(cigsale ~ state * prepost)` on the 20-row California-Nevada panel and reproduced every prose number to two decimals — CA pre = 99.0, CA post = 72.0, NV pre = 143.1, NV post = 121.8, DiD = -5.68 packs, HAC SE = 5.39, p = 0.31, prepostPost main = -21.34. The Mermaid arithmetic (-27.0) - (-21.3) = -5.7 also matches the regression's interaction up to rounding.

The chapter has six material issues, in roughly decreasing order of severity: **(M1)** the parallel-trends assumption is invoked four times but never *tested* — and a formal slope test on the 1984–1988 pre-window actually *rejects* parallel trends at p = 0.024 (HAC), which strengthens the chapter's own conclusion but is silently omitted; **(M2)** the chapter's central inferential choice — HAC standard errors via `sandwich::vcovHAC` — is misjustified and arguably wrong on a 2-unit, 20-observation panel without state fixed effects; **(M3)** there is **no formal regression-form equation** ($Y_{it} = \alpha + \beta_1 \mathrm{Post}_t + \beta_2 \mathrm{Treat}_i + \tau (\mathrm{Post}\times\mathrm{Treat}) + u_{it}$) — the chapter shows the change-of-changes identity and the R formula but never writes the population model the audit brief asked for; **(C1)** the ggplot at line 134 overrides the carefully-set transparent `theme_set()` with a bare `theme_minimal()`, breaking dark-theme rendering for the headline parallel-trends figure; **(X1)** the chapter never mentions that this is the *canonical 2×2 pre/staggered* DiD and that staggered-adoption needs Callaway–Sant'Anna (ch. 8) — the "Further reading" paragraph alludes to it but the chapter body has no forward link, while ch. 1 already promises one; **(W1)** the missing "common pitfall" about *clustered SEs being degenerate with two units* is exactly the trap the audit brief warned about, and the chapter currently steers a reader straight toward the wrong fix (the Further-reading paragraph praises `fixest::feols` "with cluster-robust SEs" without warning that you cannot cluster by state when you only have two states).

Several smaller issues (citation gaps, missing hook section, no explicit cross-link to ch. 4's "many Nevadas weighted" framing, ch. 2's misleading promise that ch. 3 uses "the other 38 states") round out the list. None is a blocker — the chapter is fundamentally sound — but most are one-paragraph or one-line fixes that materially raise the pedagogical bar.

## Strengths

- **The 2×2 Mermaid grid (lines 19–39)** is genuinely excellent pedagogy: the four cell means, the two within-state Δ's, and the final DiD are all on one diagram and all consistent with the regression below. Cross-references are correct (`#| label: fig-did-22-grid` per CLAUDE.md's Quarto-caption convention).
- **Verified arithmetic.** Every numeric claim in the prose (lines 24–32, 112, 141) reproduces from a clean re-fit: DiD = -5.679999 ≈ -5.68; HAC SE = 5.3929 ≈ 5.39; prepostPost = -21.34; intercept = 143.10; stateCalifornia = -44.12; t-stat for the interaction = -1.05, p = 0.308. The Mermaid's NV post mean of 121.8 rounds from 121.76. All consistent.
- **Releveling Nevada as the reference factor (line 86)** is the right call so that the `stateCalifornia:prepostPost` coefficient lands directly on the DiD ATT. The narrative at lines 73 and 93 explains why explicitly, which is a real teaching win.
- **The hand-off to ch. 4 at line 141** is well-phrased ("instead of one control state, blend many states into a weighted 'synthetic California'") and lines up with how ch. 4 introduces itself ("a *weighted combination* of donor states", `04-classical-synthetic-control.qmd:7`).
- **CLAUDE.md conventions are respected:** `gt_pretty`/`ms_pretty` from `R/table_helpers.R` is sourced (line 54), the regression table uses `#| label: tbl-fit-did` + `#| tbl-cap:` (lines 96–97) instead of `title=`, and the Mermaid block uses `%%| label:` + `%%| fig-cap:`.
- **Common-pitfall + Recap blocks** (lines 139, 141) are present and substantive — they correctly identify the single-similar-control trap and explicitly say "the lesson is *not* that DiD is broken", which is exactly the framing the book needs to motivate ch. 4 without breeding cynicism.

## Methodology issues

### M1. `03-basic-diff-in-diff.qmd:9, 116` — parallel-trends assumption is asserted and visualised but never formally tested, and a formal test would actually reject it

Parallel trends is named at line 9 ("**parallel trends**: California and Nevada would have moved on parallel paths") and again at line 116 ("DiD rests entirely on the **parallel-trends** assumption"). The chapter then performs a *visual* inspection via `fig-did-parallel-trends` and leans on the post-1989 Nevada decline as evidence the assumption fails. But the relevant assumption is about the *pre-period* trends — not the post-period — and the chapter never runs the simple slope-difference test that the audit brief calls "the formal trend test".

I re-fit `lm(cigsale ~ state * year, data = pre)` on the 1984–1988 pre-window (the same window the 2×2 grid uses):

```
                       Estimate Std. Error t value Pr(>|t|)
stateCalifornia:year  -4.6300     1.5371   -3.01    0.024  (HAC)
```

So the *pre-period* California–Nevada divergence is -4.63 packs/year, *and* significant at p = 0.024 even with HAC SEs. California was declining ~4.6 packs/year *faster* than Nevada *before* Proposition 99 — i.e. pre-trends formally diverge in the direction that would bias the DiD ATT *toward zero* if naively applied, which is exactly the qualitative bias the chapter ends up diagnosing. This is *load-bearing* — it converts the chapter's central diagnosis from "Nevada has its own decline (visible in the plot)" into "California was already separating from Nevada *before* the policy (testable, reject)".

**Fix:** add a short chunk after the visual at line 135, before the "common pitfall":

```r
#| label: tbl-pretrends
#| tbl-cap: "Formal pre-trends test: California × year on 1984–1988 (HAC SEs)."
pre_window <- prop99_did |> filter(prepost == "Pre")
fit_pre <- lm(cigsale ~ state * year, data = pre_window)
ms_pretty(list("Pre-trend test" = fit_pre),
          vcov     = sandwich::vcovHAC,
          coef_map = c("stateCalifornia:year" = "Δ slope (CA − NV)"),
          notes    = "If parallel trends held, this coefficient should be ≈ 0.")
```

Then add one sentence: "The pre-trend slope difference is -4.6 packs/year with HAC p = 0.024 — even *before* 1989 California was diverging from Nevada in the direction Proposition 99 would later push, so the parallel-trends assumption is rejected by the data itself."

### M2. `03-basic-diff-in-diff.qmd:45, 93, 109` — HAC standard errors via `sandwich::vcovHAC` are the wrong inferential tool for a 2×2 DiD on a balanced two-state panel

The chapter justifies HAC three times (lines 45, 93, 109): "with only ten years on each unit, the residuals are heavily autocorrelated and the textbook OLS SEs would understate the uncertainty". This blends two different concerns and lands on the wrong instrument:

1. `sandwich::vcovHAC` is a *Newey-West-style* HAC estimator designed for **a single time series** (or pooled cross-section with a *time* index). On a 20-row panel stacked as `(NV 1984, NV 1985, …, NV 1993, CA 1984, …, CA 1993)`, `vcovHAC` will treat *neighbouring rows as time-adjacent*, which means it will use the Nevada–California *cross-state* boundary observations (e.g. NV-1993 next to CA-1984) as if they were one year apart. That is not autocorrelation correction — it is meaningless mixing of two independent time series. Whether this is what the code actually does depends on the `order.by=` argument, which is not passed; the default uses row order.
2. The *correct* concern on a panel with serially-correlated within-unit shocks is the Bertrand–Duflo–Mullainathan (2004) clustered-by-state SE. But with only **two clusters** (CA, NV), the cluster-robust variance is degenerate — the asymptotic theory requires $G \to \infty$ and at $G = 2$ the estimator is a single 2×2 outer product. Stata and R will both happily compute a number, but it is uninterpretable.
3. The *honest* answer on a 2×2 DiD is that **classical inference on the DiD coefficient is unavailable** on this panel size. The point estimate is what it is; the chapter's job is to say so, not to paper over it with HAC.

**Fix:** rewrite the justification at lines 45 and 93–94, and the table note at line 109. Concretely, replace line 93–94's "We pair the OLS coefficients with HAC-robust standard errors via `sandwich::vcovHAC` because we have ten years on each unit and the residuals are serially correlated." with:

> "OLS standard errors on a 2×2 DiD are tricky. The textbook OLS SEs assume i.i.d. errors, which fails because within-state residuals are serially correlated. The standard fix — clustering by state (Bertrand-Duflo-Mullainathan 2004) — is **degenerate with only two clusters**, since the cluster-robust variance estimator requires the number of clusters to grow. We report HAC-robust SEs via `sandwich::vcovHAC` as a transparent compromise: they correct for within-state autocorrelation by treating the stacked panel as a long time series. The qualitative reading — that the -5.68 DiD is statistically indistinguishable from zero — survives every reasonable choice; readers should treat the p-value as a rough heuristic, not a hypothesis test."

Add the Bertrand-Duflo-Mullainathan citation to `references.bib` (it is currently missing — see C2 below).

### M3. `03-basic-diff-in-diff.qmd:11–16, 41` — the regression-form population model is never written down

The chapter writes the change-of-changes *identity* at line 15 and the R *formula* `cigsale ~ state * prepost` at lines 41 and 93–94, but the **population regression** that the audit brief asked for explicitly —

$$Y_{it} = \alpha + \beta_1 \mathrm{Post}_t + \beta_2 \mathrm{Treat}_i + \tau (\mathrm{Post}_t \times \mathrm{Treat}_i) + u_{it}$$

— never appears. A reader who is not already fluent in R formula syntax has to translate `state * prepost` mentally into the four-coefficient model, and a reader who *is* fluent benefits from seeing $\tau$ named so that the chapter has a symbol to point at when it says "DiD estimate".

**Fix:** between line 16 and line 17, add:

```markdown
The regression form is

$$Y_{it} = \alpha + \beta_1 \mathrm{Post}_t + \beta_2 \mathrm{Treat}_i + \tau \, (\mathrm{Post}_t \times \mathrm{Treat}_i) + u_{it},$$

where $\mathrm{Treat}_i = 1$ for California and 0 for Nevada, and $\mathrm{Post}_t = 1$ for $t \ge 1989$. The interaction coefficient $\tau$ is the DiD ATT — algebraically identical to the change-of-changes identity above, but in a form that gives us a standard error.
```

Then at line 112, change "The interaction coefficient `stateCalifornia:prepostPost`" to "The interaction coefficient $\hat\tau$ (R name: `stateCalifornia:prepostPost`)" so the symbol and the R name connect.

### M4. `03-basic-diff-in-diff.qmd:7, 73, 137` — "Nevada is a hand-picked neighbour" is asserted but never grounded in the dataset

The chapter calls Nevada "geographically and demographically adjacent" (line 7) and "geographically and culturally adjacent" (line 137), and at line 73 it says "Nevada is the hand-picked control, chosen as a geographically and demographically adjacent state". But adjacency is asserted, not shown — a Utah, Arizona, or Oregon reader has no way to know why Nevada and not them. More importantly, the *teaching* point — "a neighbour inherits the same secular forces" — would be sharper if it were *quantified*: e.g. "Nevada and California share a 600-km border, Lake Tahoe straddles it, and ~30% of Nevada's population lives in Reno/Las Vegas, both of which are within California's TV-advertising reach." Without that, "adjacent" is a vibe rather than a teaching claim.

**Fix:** at line 73, insert one sentence after "chosen as a geographically and demographically adjacent state": "(Reno and Las Vegas both sit inside California's media market and share its retail-price corridor; Nevada was also one of the donor states with non-zero weight in Abadie, Diamond & Hainmueller's synthetic California — see chapter 4.)" This forward-links to ch. 4 and also previews why "many Nevadas weighted" is the principled fix.

## Code & reproducibility issues

### C1. `03-basic-diff-in-diff.qmd:134` — `theme_minimal()` inside the plot silently overrides the chapter's transparent `theme_set()`

Lines 60–70 establish a careful `theme_set(theme_minimal(base_size = 12) + theme(plot.background = element_rect(fill = "transparent", …)))` so that the headline parallel-trends figure reads in both the `cosmo` (light) and `darkly` (dark) site themes per CLAUDE.md's theming rule. But then at line 134, the ggplot call ends with `+ theme_minimal()`, which **replaces** the active theme entirely and restores the default white panel/plot background — exactly the failure mode the transparent setup was designed to prevent.

Other chapters in the book do this correctly. ITS (`02-interrupted-time-series.qmd:202`) calls `theme_minimal()` at the *end* with the same bug; the SC chapter (`04-classical-synthetic-control.qmd`) lets `theme_set()` handle styling and does not re-add a theme.

**Fix:** delete `+\n  theme_minimal()` at lines 133–134 (the trailing `+ theme_minimal()` line). The active `theme_set()` will take over and the figure will render with a transparent background on both site themes.

### C2. `references.bib` — `Bertrand-Duflo-Mullainathan (2004)` and `Card-Krueger (1994)` are not in the bibliography

The audit brief asked me to "verify cites (Card-Krueger, Bertrand-Duflo-Mullainathan)". Neither key exists in `references.bib` (`grep -i -E "(card|krueger|bertrand|duflo|mullainathan)" references.bib` returns nothing). The chapter currently cites only `@bernal2017interrupted` at line 145, which is an ITS tutorial — not a DiD reference at all. The two canonical DiD references for an undergrad-friendly book are:

- **Card & Krueger (1994)** — *American Economic Review* 84(4): 772–793 — the canonical applied DiD paper (NJ vs PA minimum-wage / fast-food). This is what most readers will have heard of.
- **Bertrand, Duflo & Mullainathan (2004)** — *Quarterly Journal of Economics* 119(1): 249–275 — the paper that demonstrated DiD inference is broken without cluster-robust SEs.

Both are load-bearing for the chapter: Card-Krueger is the textbook example any reader will recognise (and the "minimum-wage" pivot in Part II is a thematic callback), and Bertrand-Duflo-Mullainathan is *the* reason M2 above matters and the chapter's HAC choice needs justification.

**Fix:** add two `@article` entries to `references.bib`:

```bibtex
@article{cardkrueger1994minimum,
  title   = {Minimum Wages and Employment: A Case Study of the Fast-Food Industry in New Jersey and Pennsylvania},
  author  = {Card, David and Krueger, Alan B.},
  journal = {American Economic Review},
  volume  = {84},
  number  = {4},
  pages   = {772--793},
  year    = {1994}
}

@article{bertrand2004how,
  title   = {How Much Should We Trust Differences-in-Differences Estimates?},
  author  = {Bertrand, Marianne and Duflo, Esther and Mullainathan, Sendhil},
  journal = {Quarterly Journal of Economics},
  volume  = {119},
  number  = {1},
  pages   = {249--275},
  year    = {2004}
}
```

Then rewrite the "Further reading" block at line 145 to cite both — see X1 below for the full proposal.

### C3. `03-basic-diff-in-diff.qmd:56` — `set.seed(42)` is set but the chapter has no stochastic step

The chapter loads no Monte Carlo, no bootstrap, no `tidysynth` placebos, and no Bayesian sampler — the only computations are deterministic OLS on a 20-row tibble and a deterministic mean plot. The `set.seed(42)` is harmless cargo-culted from the other chapters, but it is misleading to a reader who is taught to look for *what* it makes reproducible.

**Fix:** either (a) drop line 56, or (b) keep it and add a one-line comment: `# set.seed not strictly needed here — OLS and means are deterministic — but kept for consistency with the rest of the book.` Option (b) is probably less disruptive.

### C4. Cached output verification

I cross-checked the prose numbers against a fresh `Rscript`-driven re-fit on `data/proposition99.rds` (no rendering of the qmd):

| Claim | Source line | Reproduced | Match? |
|---|---|---|---|
| CA pre = 99.0 | line 24 | 98.98 | ✓ |
| CA post = 72.0 | line 25 | 71.96 | ✓ |
| NV pre = 143.1 | line 28 | 143.10 | ✓ |
| NV post = 121.8 | line 29 | 121.76 | ✓ |
| Δ CA = -27.0 | line 24 | -27.02 | ✓ |
| Δ NV = -21.3 | line 28 | -21.34 | ✓ |
| DiD = -5.7 / -5.68 | lines 31, 112 | -5.68 | ✓ |
| HAC SE = 5.39 | line 112 | 5.3929 | ✓ |
| p = 0.31 | line 112 | 0.3079 | ✓ |
| prepostPost = -21.34 | line 112 | -21.34 | ✓ |
| stateCalifornia = -44.12 | (implicit) | -44.12 | ✓ |

Numbers are sound; the prose-vs-output integrity is the strongest part of the chapter.

## Cross-chapter consistency issues

### X1. `03-basic-diff-in-diff.qmd:145` — no explicit forward link to chapter 8 on staggered DiD, despite chapter 1 promising one

Chapter 1 (`01-introduction.qmd:77`) tells readers explicitly: "Under staggered adoption (Part II), different units begin treatment at different dates, so the ATT becomes a *family* of cohort-by-time effects $\mathrm{ATT}(g, t)$ … Chapter 8 unpacks this." Chapter 1 line 95 names "Staggered DiD / Callaway-Sant'Anna (ch. 8)" in the imputation-method table.

So a reader who walks from ch. 1 into ch. 3 has been promised that ch. 3 covers the *single-treated-unit / single-shock* DiD and that ch. 8 will revisit DiD in the staggered case. Chapter 3 fulfils its half of that promise but *never closes the loop*: the "Further reading" paragraph at line 145 mentions Callaway-Sant'Anna in passing as "modern multi-period DiD with staggered adoption" but does not actually say "see chapter 8" or "we revisit this in chapter 8 with a different dataset". A reader who skips ch. 1 has no idea this chapter is one half of a two-part DiD treatment.

**Fix:** replace line 145 with:

```markdown
This chapter is the **canonical 2×2 / single-shock DiD**: one treated unit (California), one control unit (Nevada), one pre-period, one post-period. **Chapter 8 (Part II)** revisits DiD in the *staggered-adoption* setting — many treated units that switch at different dates — using the Callaway–Sant'Anna group-time ATT estimator [@callaway2021difference], the Sun–Abraham interaction-weighted estimator [@sun2021estimating], and the Rambachan–Roth honest-DiD sensitivity bounds [@rambachan2023more] on a Callaway-Sant'Anna minimum-wage county panel. The two chapters together cover the modern DiD toolkit.

**Classical references.** @cardkrueger1994minimum is the textbook applied 2×2 DiD (New Jersey vs Pennsylvania minimum wage and fast-food employment). @bertrand2004how is the seminal warning that DiD standard errors are biased toward zero under residual autocorrelation — the reason this chapter's inference choice (M2) is non-trivial. @bernal2017interrupted is the practitioner reference for parallel-trends *visual* diagnostics. For modern multi-period DiD with staggered adoption, `did` (Callaway–Sant'Anna) and `fixest::feols` (two-way fixed effects with cluster-robust SEs) are the standard R workhorses.
```

This (a) names the chapter type explicitly ("2×2 / single-shock"), (b) forward-links to ch. 8 with the three Part-II key papers, all of which are already in `references.bib`, and (c) folds in Card-Krueger and Bertrand-Duflo-Mullainathan from C2.

### X2. `02-interrupted-time-series.qmd:219` — ch. 2 promises ch. 3 "uses the other 38 states as a common-trend control", but ch. 3 uses only Nevada

This is a ch. 2 issue, not a ch. 3 issue, but it makes ch. 3 look like a downgrade of what was promised. Chapter 2's "Where this leaves us" paragraph (line 219) says: "chapter 3 (Differences-in-Differences) uses the other 38 states as a common-trend control; chapter 4 (Synthetic Control) builds a weighted donor pool tailored to California's pre-period". A reader who lands in ch. 3 expecting all 38 control states gets one control state. The ch. 4 description in the same paragraph ("weighted donor pool") is correct, but ch. 3 reads as if ch. 2 mis-summarised it.

**Fix in `02-interrupted-time-series.qmd:219`:** change "chapter 3 (Differences-in-Differences) uses the other 38 states as a common-trend control" to "chapter 3 (Differences-in-Differences) uses a hand-picked neighbour state (Nevada) as a common-trend control, exposing why a single similar control is fragile".

### X3. `03-basic-diff-in-diff.qmd:141` — the "many Nevadas weighted" framing the audit brief named is implicit but never said out loud

Ch. 4's opening (`04-classical-synthetic-control.qmd:7–9`) frames SC as "a *weighted combination* of donor states" and "instead of one neighbour, a *data-driven blend* of many neighbours". Ch. 3's hand-off at line 141 says "blend many states into a weighted 'synthetic California'". That is *almost* the right phrase but is one connector away from the audit brief's framing: "many Nevadas weighted." Adding that phrase explicitly would close the loop.

**Fix:** at line 141, change "blend many states into a weighted 'synthetic California'" to "blend many Nevada-like states into a *weighted* synthetic California — the optimisation picks the weights so the analyst no longer has to hand-pick the control".

### X4. Notation consistency with ch. 1 is OK but could be tightened

Ch. 1 uses $Y_{it}(0)$, $Y_{it}(1)$, $D_{it}$, $\tau_{it}$, ATT, $t^* = 1988$. Ch. 3 uses $\bar Y_{\text{CA,post}}$, $\bar Y_{\text{NV,post}}$ etc. for the change-of-changes identity (correct) but never reconnects to the $Y_{it}(0)$ notation from ch. 1 even though the ch. 1 imputation-table row (line 89) literally writes the DiD imputation as $\widehat{Y_{1t}(0)} = \overline{Y}_{1,\text{pre}} + (\overline{Y}_{0,\text{post}} - \overline{Y}_{0,\text{pre}})$.

**Fix:** at the end of the "change-of-changes identity" section (after line 16), add: "In the chapter 1 notation, this is the imputation $\widehat{Y_{1t}(0)} = \overline{Y}_{1,\text{pre}} + (\overline{Y}_{0,\text{post}} - \overline{Y}_{0,\text{pre}})$ — California's pre-period mean plus Nevada's pre-to-post change."

## Writing & structure issues

### W1. `03-basic-diff-in-diff.qmd:139` — the "Common pitfall" block lands on the wrong pitfall

The "Common pitfall" block at line 139 is about *picking a single similar control by hand*. That is a fine pitfall, but it duplicates the recap of the same paragraph (both line 139 and line 141 essentially say "one neighbour is fragile"). The audit brief asked specifically about two other pitfalls that the chapter does not flag: (a) **clustering with two units is degenerate** (M2 above), and (b) **treating Nevada as exogenous when it is itself a small open economy with price/advertising spillovers from California**.

**Fix:** keep the current pitfall but add a second one immediately below it, exactly where the audit brief suggested:

```markdown
**A second pitfall.** Clustering standard errors *by state* on a two-state panel. The cluster-robust variance estimator [@bertrand2004how] requires the number of clusters to grow; at $G = 2$ it collapses to a single 2×2 outer product and is uninterpretable. Software will compute a number; do not trust it. With only two units, accept that classical inference on the DiD coefficient is unavailable and let the point estimate carry the argument.

**A third pitfall.** Treating Nevada as causally exogenous. Nevada borders California on a 600-km stretch, sits inside California's TV-advertising and retail-price corridor, and inherits its anti-smoking media spillovers. The "control" is not policy-untreated in the deep sense — only in the narrow sense of not having passed Proposition 99 itself.
```

### W2. `03-basic-diff-in-diff.qmd:5` — the chapter has no hook before the methodology

Every other Part-I chapter opens with one or two sentences that *set up the question* before diving into "the [method] idea". Ch. 1 opens with "How do you measure the causal effect of a policy when you cannot randomise". Ch. 2 opens with "Interrupted time series (ITS) drops the comparison unit entirely. The counterfactual is built from the **treated unit's own pre-period dynamics**". Ch. 4 opens with "Synthetic Control stops using one control state".

Chapter 3 jumps straight into "Difference-in-Differences picks one control state — Nevada, for this chapter — and treats its pre-to-post change as the counterfactual change California would have experienced". That sentence is correct but lacks a *connection* to ch. 2's punchline.

**Fix:** insert one sentence at the very top of "The DiD idea" (line 7):

```markdown
Chapter 2 showed that any within-unit method — growth curve, ARIMA — is fragile because the counterfactual is identified only by an assumption the data cannot verify. DiD borrows strength from *outside* California by adding one control unit, and replaces an extrapolation assumption with a comparability assumption.
```

This makes ch. 3 read as a *response* to ch. 2 rather than a fresh start.

### W3. `03-basic-diff-in-diff.qmd:114–135` — the visual-diagnostic section's figure caption editorialises the conclusion

The caption at line 120 reads: "California vs Nevada, 1970–2000. Nevada is also declining post-1988, so the DiD contrast collapses." The first half ("California vs Nevada, 1970–2000") is a descriptive caption. The second half ("Nevada is also declining post-1988, so the DiD contrast collapses") is the *conclusion* the body text is supposed to draw from the figure. Putting the conclusion in the caption removes the reader's incentive to actually look.

**Fix:** trim the caption to "California vs Nevada, 1970–2000 cigarette sales per capita. Pre-policy years are to the left of the dashed line." and keep the conclusion in the prose at lines 116 and 137 where it currently is.

### W4. No table of section structure / table-of-contents preview

The chapter has six top-level sections (`## The DiD idea`, `## The change-of-changes identity`, `## Setup and data`, `## Fit and HAC inference`, `## Visual diagnostic`, `## Further reading`). For a 145-line chapter this is fine, but the section "Visual diagnostic" comes *after* "Fit and HAC inference" — i.e. the chapter fits the model first and *then* diagnoses whether the assumption holds. Pedagogically this is upside down: a reader sees "the DiD answer is -5.68, p = 0.31" before being told "the assumption underlying that estimate fails". The chapter does eventually deliver the right lesson, but the order primes a reader to mis-read the regression as a real estimate.

**Fix:** consider reordering: `## The DiD idea` → `## The change-of-changes identity` → `## Setup and data` → `## Visual diagnostic` (with the formal pre-trends test from M1) → `## Fit and HAC inference` → `## Recap + further reading`. The diagnostic *first*, then the regression as an illustration of what the bad diagnostic does to the answer. This is a non-trivial restructuring — flag it as a design call for the author rather than a mechanical fix.

### W5. `03-basic-diff-in-diff.qmd:42` — orphan paragraph between sections

Line 42 is a one-line paragraph: "The arithmetic is literally what the regression below computes. In `cigsale ~ state * prepost`, the interaction coefficient `stateCalifornia:prepostPost` *is* the DiD estimate." This is a fine sentence but it sits in no section — it follows the Mermaid block at the end of "The change-of-changes identity" and precedes "## Setup and data". It is doing the work of a transitional paragraph but it is doing it cramped.

**Fix:** either fold this sentence into the closing of the previous paragraph (i.e. promote it to be a line above the Mermaid), or move it to be the opening sentence of "## Fit and HAC inference" where the regression is actually fitted.

## Suggested edit list (in priority order)

1. **M1** — add the formal pre-trends test chunk (`tbl-pretrends`) on the 1984–1988 sub-window; add one sentence interpreting the result.
2. **M2** — rewrite the HAC justification at lines 45 and 93–94 to acknowledge that on a 2×2 panel both HAC and clustering are imperfect; cite Bertrand-Duflo-Mullainathan; add the W1 second/third pitfalls.
3. **C2** — add `cardkrueger1994minimum` and `bertrand2004how` to `references.bib`.
4. **C1** — delete the trailing `+ theme_minimal()` at lines 133–134.
5. **X1** — rewrite "Further reading" (line 145) to forward-link to ch. 8 and fold in the new Card-Krueger / Bertrand-Duflo-Mullainathan citations.
6. **M3** — add the explicit population regression form between lines 16 and 17.
7. **X3** — tighten the "many Nevadas weighted" hand-off at line 141.
8. **W1** — add second/third pitfalls (clustering with G=2; Nevada exogeneity).
9. **W2** — add the one-sentence hook tying back to ch. 2.
10. **W3** — trim the editorialising figure caption at line 120.
11. **X2** — fix ch. 2's stale promise that ch. 3 uses "the other 38 states" (a ch. 2 edit).
12. **X4** — reconnect to ch. 1's $\widehat{Y_{1t}(0)}$ notation after line 16.
13. **M4** — quantify Nevada's adjacency claim at line 73.
14. **C3** — annotate or drop `set.seed(42)` at line 56.
15. **W5** — fold orphan line 42 into a neighbouring section.
16. **W4** — *(optional, larger refactor)* consider reordering the diagnostic before the fit.

Items 1–5 are the load-bearing edits; the remainder polish.
