# Audit: Chapter 8 — Staggered Differences-in-Differences (`08-staggered-did.qmd`)

## Summary

Chapter 8 is the Part-II opening chapter and the case-study seam from
Proposition 99 to the Callaway-Sant'Anna minimum-wage county panel. The
overall arc — TWFE strawman → group-time ATT(g,t) → cohort/event
aggregation → conditional DiD with three estimators → HonestDiD
sensitivity — is well-chosen and pedagogically clean. Prose is crisp,
the four-way reconciliation callout works, and cited numbers match
cached chunk outputs to the digit.

However the chapter has one **load-bearing methodological bug** that
inverts the headline conclusion of its final section. The bridge
helper in `R/honest_did.R:36–37` uses `n = N·T` (panel rows) instead
of `n = N` (units) when forming the influence-function variance,
shrinking `Var(beta_hat)` by a factor of `T² = 25` on this panel.
With the correct `n`, the Mbar = 0 CI for ATT(e=0) is `(−0.040, −0.007)`
(matching `did::aggte` exactly), not the published `(−0.027, −0.020)`,
and the relative-magnitude breakdown is **below Mbar = 0.5**, not the
"≈ 1" the chapter advertises in three places (lines 339, 352–356,
365–366). Substantively, the on-impact effect of −0.024 is fragile
to a pre-trend violation half the size of the *largest observed*
pre-trend — which itself is statistically significant at −0.034
(event time −3) and goes unflagged.

Secondary issues: a small cohort/filter inconsistency in the data
prose (line 46 vs the code at line 95), one `aggte()` aggregator
mislabelled as a simple mean, and several pedagogical hooks the
chapter could keep but does not — the visible pre-trend in cohort
2006, a "what `'group'` vs `'simple'` actually aggregates" callout,
and an explicit notational handshake to Ch. 9.

## Strengths

- The Part-I → Part-II case-study switch is framed deliberately and
  motivated by a methodological need (`08:43–49`): "Staggered DiD
  requires *variation in treatment timing*, which a single-treated-state
  panel cannot provide." That sentence does heavy lifting and earns it.
- The TWFE → CS reconciliation lands as a numerical surprise: the
  chapter quotes −0.038 (TWFE) and −0.057 (CS overall) and explicitly
  attributes the gap to Goodman-Bacon contamination (`08:198–202`).
  Both numbers verify against the freeze cache exactly.
- The four-estimator robustness table (`08:tbl-conditional`) is
  set up as a *design* sensitivity check, then explicitly contrasted
  with HonestDiD's *assumption* sensitivity check at `08:309–311`.
  That distinction is exactly the right pedagogical move and rarely
  made even at the textbook level.
- `R/honest_did.R` correctly drops the universal-base reference
  period (event time −1) before passing to HonestDiD, correctly
  computes pre/post counts from the remaining grid, and correctly
  matches the `smoothness` vs `relative_magnitude` branch to
  `createSensitivityResults` vs `…_relativeMagnitudes`.
- All six citation keys (`callaway2021difference`,
  `goodmanbacon2021difference`, `sun2021estimating`,
  `rambachan2023more`, `dechaisemartin2020twoway`,
  `callaway2022handbook`) resolve in `references.bib:155–222`.
- Cohort sizes claimed in the prose verify against the data:
  filter Step 1+2 yields 1,417 / 102 / 226 counties for G ∈ {0,
  2004, 2006}, totalling 1,745 — exact match with `08:104–106`.
- Figure / table captions follow the Quarto-native
  `tbl-cap` / `fig-cap` + `label:` convention (CLAUDE.md rule).
  No `title=` is passed to `gt_pretty()`. Caption numbering and
  cross-references will work.
- Chapter is wired into `_quarto.yml:35` and into the per-chapter
  zip bundler at `R/build_chapter_zips.R:14, 91–96` — both the
  `data/cs_minwage.rds` payload and the `R/honest_did.R` bridge
  ride along in `chapter-08.zip`.

## Methodology

### M1. `R/honest_did.R:36–37` — wrong `n`, breaks HonestDiD inference numerically (**load-bearing**)

The bridge computes the influence-function variance as

```r
n <- length(es$DIDparams$data[[es$DIDparams$idname]])
V <- t(es$inf.function$dynamic.inf.func.e) %*%
     es$inf.function$dynamic.inf.func.e / n / n
```

`es$DIDparams$data[[idname]]` is the panel **id column** — its length
is the total number of unit-period rows, not the number of units.
On this panel `length(...) = 8725 = 1745 · 5`, while the
influence-function matrix `es$inf.function$dynamic.inf.func.e` has
`nrow = 1745` (one row per unit). Dividing by `n² = (N·T)²` instead
of `(N)²` shrinks the resulting `V` by `T² = 25`.

Numerical reproduction (run against the actual chapter pipeline):

| event time `e` | `did::aggte` SE | `sqrt(diag(V_chap))` (buggy) | `sqrt(diag(V_units))` (correct) |
|---|---|---|---|
| 0 | 0.0090 | 0.0018 | 0.0088 |
| 1 | 0.0205 | 0.0041 | 0.0200 |
| 2 | 0.0232 | 0.0046 | 0.0226 |

The "correct" column matches `did` to three significant figures. The
"buggy" column is what HonestDiD currently consumes.

Downstream effect — Mbar = 0 robust CI for ATT(e=0):

- **Published** (`tbl-honest`, Mbar = 0): `(−0.0269, −0.0202)`
- **Correct** (this audit, units `n`): `(−0.0402, −0.0067)`

The published Mbar = 0 CI is impossibly narrower than the analytic
`did` CI `att.egt[0] ± 1.96·se.egt[0] = −0.0235 ± 1.96·0.0090 =
(−0.0411, −0.0058)`. That mismatch is a direct fingerprint of the bug.

Downstream effect — relative-magnitude breakdown (the chapter's
headline robustness claim):

| Mbar | Published CI (`tbl-honest`) | Correct CI | Crosses 0? |
|---|---|---|---|
| 0   | (−0.027, −0.020) | (−0.040, −0.007) | no / no |
| 0.5 | (−0.034, −0.011) | (−0.049,  0.003) | no / **yes** |
| 1   | (−0.034, −0.002) | (−0.062,  0.016) | no / yes |
| 1.5 | (−0.034,  0.008) | (−0.078,  0.032) | yes / yes |
| 2   | (−0.034,  0.019) | (−0.093,  0.048) | yes / yes |

With the correct `n`, the breakdown is **somewhere in (0, 0.5]** — not
the "≈ 1" advertised at `08:339`, `08:352–356`, and `08:365–366`. The
intuitive interpretation flips: the conclusion does *not* survive even
a fraction of the largest observed pre-trend.

**Fix:** in `R/honest_did.R:36`, replace

```r
n <- length(es$DIDparams$data[[es$DIDparams$idname]])
```

with

```r
n <- nrow(es$inf.function$dynamic.inf.func.e)
```

This is the convention in Pedro Sant'Anna's reference helper at
<https://github.com/pedrohcgs/CS_RR> (which the file's header
correctly cites as its source). After the fix, the prose at
`08:339`, `08:352–356`, and the Recap callout at `08:365–366` need
to be updated to the honest answer (breakdown ≤ 0.5; on-impact
effect is fragile to even half the largest observed pre-trend).
The `0.024 → 0.13` event-study magnitudes are unaffected — those
come from `did::aggte` directly.

### M2. `08:154–161` — pre-trend in cohort 2006 is statistically significant and never flagged

From the cached `tbl-attgt`:

```
G = 2006, t = 2003:  ATT = −0.0341 (SE 0.0125)  → t ≈ −2.7
G = 2006, t = 2004:  ATT = −0.0167 (SE 0.0087)  → t ≈ −1.9
```

And from `tbl-cs-event`:

```
e = −3:  ATT(e) = −0.0341 (SE 0.0122)  → t ≈ −2.8
e = −2:  ATT(e) = −0.0167 (SE 0.0081)  → t ≈ −2.1
```

Both pre-treatment cells reject the null of parallel trends at
conventional levels. The chapter's caption (`08:156`) says
"Pre-treatment cells should hover near zero if parallel trends
holds; post-treatment cells are the effects we want" — and then
does not say that one of them clearly does not. This is the very
reason HonestDiD is being applied in the next section; not naming
it leaves the reader without the bridge between "look at the cells"
and "now we need a sensitivity tool". It also makes M1 above worse
pedagogically: the *largest observed pre-trend* of −0.034 is
*bigger in absolute value than the on-impact ATT of −0.024*, which
is exactly why an honest Mbar = 1 confidence interval must
contain zero.

**Fix:** after `08:172` (the gt_pretty call for `tbl-attgt`), add a
2–3 sentence paragraph along the lines of:

> "Cohort 2006 carries a visible pre-trend: ATT(2006, 2003) ≈ −0.034
> with SE 0.013 (t ≈ −2.7). The 2006 counties were already on a
> downward log-employment path relative to never-treated counties
> three years before their state raised the minimum wage. That
> violation is roughly the same magnitude as the on-impact effect,
> which is what motivates the sensitivity analysis in the next
> section."

This also rescues the broader narrative: the corrected Mbar ≤ 0.5
breakdown becomes *expected*, not surprising.

### M3. `08:180–184` — overall ATT mislabelled as a simple time-weighted mean

The prose at `08:180–184` describes the overall ATT as: "*across
treated counties and across the time they had been treated for, what
is the average effect?*" That is what `aggte(..., type = "simple")`
computes — an average of all post-treatment ATT(g, t) cells weighted
by their group sizes. But the code at `08:188` uses
`aggte(attgt, type = "group")`, which (per `?did::aggte`) computes
`mean_g ( cohort_g_average_of_post_treatment_ATTs )` and then averages
those across cohorts. They differ when cohorts have different
post-treatment horizons (here cohort 2004 has 4 post cells and cohort
2006 has 2 post cells, so they do differ).

The published `overall.att = −0.0571` is in fact the `type = "group"`
value, not the `type = "simple"` value. The prose answers the wrong
question by one word.

**Fix:** rewrite `08:180–184` to:

> "The **overall ATT** averages each cohort's post-treatment ATT(g, t)
> values into a single cohort-specific summary, then averages those
> across cohorts weighted by cohort size. It answers: *across treated
> cohorts, what is the average post-treatment effect on a typical
> treated county?* This is the @callaway2021difference recommended
> summary; it differs from a plain mean of post-treatment cells
> (`type = "simple"`) when cohorts have different horizons."

### M4. `08:24–31` — Goodman-Bacon and de Chaisemartin–d'Haultfœuille are conflated as the same critique

The paragraph cites both papers for the "negative weights" claim. They
overlap but are not identical: Goodman-Bacon's decomposition expresses
TWFE as a weighted average of 2×2 DiDs, with weights that can be
non-monotone (and the *forbidden comparison* is the
already-treated-vs-newly-treated one). de Chaisemartin–d'Haultfœuille
prove that under heterogeneity TWFE weights can be **strictly negative**
in a different decomposition. The chapter elides which paper provides
which guarantee. This is minor for the working stats reader but matters
for a Part II opener that introduces both citations.

**Fix:** split `08:27–31` into two sentences:

> "The Goodman-Bacon decomposition shows $\hat\beta$ is a weighted
> average of 2×2 DiDs in which already-treated units serve as controls
> for later-treated units — the *forbidden comparison*
> [@goodmanbacon2021difference]. de Chaisemartin and d'Haultfœuille
> further prove that under treatment-effect heterogeneity some of those
> implicit weights can be *strictly negative*, so $\hat\beta$ need not
> even be a convex average of the underlying ATTs
> [@dechaisemartin2020twoway]. Either way, when treatment effects grow
> over time — the textbook policy story — the sign of $\hat\beta$ is
> no longer a reliable summary."

### M5. `08:39–41`, `08:307–315` — HonestDiD's two restrictions are named but the contrast is not drawn

The chapter mentions both "smoothness" and "relative-magnitude" bounds
(at lines 401–402 and as exercise 3 at lines 420–423) but only ever
applies the relative-magnitude one. The relative-magnitudes restriction
(Δ^RM(Mbar)) compares the *largest* post-treatment violation to the
*largest* pre-treatment violation; the smoothness restriction (Δ^SD(M))
bounds *second differences* of pre-trends. Knowing which restriction
makes sense is a substantive choice (RM is more useful when there's
*any* visible pre-trend; SD is useful when pre-trends look like
near-linear drift). The chapter picks one without saying why.

**Fix:** between `08:311` and `08:315`, add:

> "HonestDiD ships two restrictions: a *smoothness* bound that
> requires post-treatment violations to be a smooth continuation of
> pre-treatment ones (`Δ^SD(M)`, capping the second differences), and
> a *relative-magnitudes* bound that requires the post-treatment
> violation to be at most $\bar M$ times the largest pre-treatment
> violation (`Δ^RM(\bar M)`). With a visibly non-linear pre-trend
> like the one in cohort 2006 above, the relative-magnitudes bound is
> the natural choice; we use it below."

### M6. `08:140–152` — ATT(g,t) defined against `Y_{it}(\infty)` but never-treated comparison group is justified by analogy

The estimand at `08:146` is written as
`E[Y_{it}(g) − Y_{it}(\infty) | G_i = g]`, with `Y(\infty)` denoting
the never-treated potential outcome. Then `08:150–152` says: "estimates
each of these from a clean 2×2 DiD using only cohort g and an
appropriate comparison group (here, the never-treated G = 0), so no
contamination from already-treated units sneaks in."

The link from the *estimand* (`Y(\infty)` is a potential outcome)
to the *estimator* (using `G = 0` units to identify it) is what
*parallel trends* buys you. The chapter never explicitly says "the
identification assumption is that, conditional on `G = g`, the trend
in `E[Y_{it}(\infty)]` is the same across cohorts and the never-treated
pool." A one-sentence statement of the assumption right after the
estimand is conventional in the C-S exposition and would close the gap
between defining `Y(\infty)` and using `G = 0` to identify it.

**Fix:** insert after `08:148` (before the `att_gt` call):

> "Identification relies on **parallel trends**: conditional on $G_i = g$,
> the never-treated potential outcome $E[Y_{it}(\infty)]$ trends the
> same way for the treated cohort and the never-treated pool. Under
> that assumption, `att_gt` estimates each $ATT(g,t)$ from a clean 2×2
> DiD between cohort $g$ and the $G = 0$ units, with no
> already-treated units used as controls."

### M7. `08:413–415` — the SE-shrinkage hint for `notyettreated` is correct but incomplete

Exercise 1 says "the standard error usually *shrinks* under this
alternative." True, because the not-yet-treated comparison pool is
larger. But the trade-off — *bias* under cross-cohort heterogeneity if
already-treated-but-not-yet-newly-treated units have anticipation or
spillover effects, plus the loss of the "clean controls" interpretation
the chapter just defended — is not flagged. For an exercise the reader
will actually attempt, the bias/variance trade-off is the point.

**Fix:** extend the exercise prompt to: "...Explain why the standard
error usually *shrinks* under this alternative, and what assumption
about not-yet-treated counties you are now relying on to make their
comparison valid."

## Code & reproducibility

### C1. `R/honest_did.R:36` — see **M1** (the load-bearing bug)

The single-line fix is `n <- nrow(es$inf.function$dynamic.inf.func.e)`.
After the fix, run `quarto render --to html 08-staggered-did.qmd` to
refresh the freeze cache and propagate the corrected `tbl-honest` /
`fig-honest` outputs.

### C2. `08:43–49` vs `08:84–87, 94–99` — the data-filter prose disagrees with itself

Line 46 says: "cohorts $G \in \{0, 2004, 2006\}$". Line 84–87 then
correctly explains that the source filter keeps `G \in \{0, 2004,
2006, 2007\}` and *then* the working sample drops `G == 2007`. The
intro at line 46 should match the working-sample state, or it should
foreshadow the two-step filter.

**Fix:** at `08:46`, replace "with cohorts $G \in \{0, 2004, 2006\}$
indexing..." with "with cohorts $G \in \{0, 2004, 2006\}$ (after
dropping a small late-2007 cohort, see Setup) indexing..."

### C3. `08:64` — `set.seed(42)` is set but no chunk in the chapter is stochastic

`did::att_gt` with the analytic asymptotic SE (the default) is
deterministic. So is `fixest::feols`. The HonestDiD relative-magnitude
CIs are computed on a deterministic grid (`gridPoints = 10^3`).
Setting the seed costs nothing but should not mislead the reader
into thinking output is bootstrap-based.

**Fix:** keep the seed for hygiene, but add a one-line comment:
`set.seed(42)  # all chunks below are analytically deterministic; this is just hygiene`. Or move the seed into the (currently absent)
bootstrap version of `att_gt` if you ever add one as a sensitivity.

### C4. `08:269–288` — three near-identical `att_gt()` calls; consider a helper

The three conditional `att_gt` invocations differ only in
`est_method`. They are 6 lines each, repeated three times. For an
audience that may copy-paste, that is fine; but a `purrr::map` over
`c("reg", "ipw", "dr")` would model good R style. Not a defect, a
suggestion.

### C5. `R/honest_did.R:54–59` — argument names match HonestDiD's API

I verified that `betahat`, `sigma`, `numPrePeriods`, `numPostPeriods`,
`alpha`, `Mvec`, `Mbarvec`, `method`, `bound`, `monotonicityDirection`,
`biasDirection`, `parallel`, `gridPoints`, `grid.ub`, `grid.lb` all
match the current `HonestDiD::createSensitivityResults` and
`...relativeMagnitudes` signatures (HonestDiD ≥ 0.2.5). No deprecation
issues.

There is **no** call to `BMisc::makeSEResults` in the chapter or in
`R/honest_did.R`. The audit brief asked me to verify that plumbing;
the answer is that it is not used — the bridge talks directly to
HonestDiD via the influence-function matrix that `did::aggte` exposes.
This is the right design.

### C6. `08:127, 269–288` — `fixest` / `did` arguments are current

`feols(... | id + year, data = ..., cluster = "id")` uses no
deprecated arguments. `did::att_gt(...)` likewise uses the supported
keywords (`yname`, `tname`, `idname`, `gname`, `xformla`,
`control_group`, `base_period`, `est_method`, `data`). Verified
against `did 2.1.x` documentation.

### C7. Reproducibility check

I re-ran the full chapter pipeline against `data/cs_minwage.rds` and
confirmed every cached number cited in prose:

- `08:104`: `nrow(data2) = 8725` ✓
- `08:105`: `n_distinct(id) = 1745` ✓
- `08:136`: TWFE coef ≈ −0.038 ✓ (-0.0383)
- `08:199`: CS overall ATT ≈ −0.057 ✓ (-0.0571, SE 0.0084)
- `08:224`: e=+3 effect ≈ −0.13 ✓ (-0.1311)
- `08:364`: DR conditional ATT ≈ −0.065 ✓ (-0.0646)
- `08:365`: on-impact ATT ≈ −0.024 ✓ (-0.0235)

Only the HonestDiD numbers (Mbar > 0 CIs and the implied breakdown)
fail to reproduce under the correct `n` — see **M1**.

## Cross-chapter consistency (the Part-I → Part-II seam)

### X1. `08:5–14` — the Part-I close-out is well done

The opening paragraph reaches back to chapter 3's −5.7 packs-per-capita
DiD on Proposition 99 and names *why* it underperformed (Nevada is
adjacent and absorbs the same secular forces). This is the right
two-sentence recap; it does not require the reader to re-open
chapter 3.

### X2. `08:15–22` — the structural pivot is correctly motivated

The transition from "one treated unit, one control" to "many cohorts
adopting at different times" is named explicitly. The TWFE equation is
written down. This is the structural move from Part I to Part II
and the chapter does not bury it.

### X3. `08:43–49` — the **dataset switch** is justified by a methodological need

"Staggered DiD requires variation in treatment timing, which a
single-treated-state panel cannot provide" (`08:43–44`). That single
sentence does the seam's hardest job: it tells the reader the case
study is changing *because the method demands it*, not for narrative
convenience. Keep it.

### X4. Notation: `g` (cohort) and `Mbar` (HonestDiD breakdown) don't collide

- `g` (cohort) and `G` (cohort label as a column in the data) are
  introduced fresh at `08:144–146`. Part I never used `g` or `G` for
  anything else (Prop 99 chapters used `j` for donors and `i` for
  units).
- `\bar M` (HonestDiD breakdown) is introduced at `08:314–315` and
  doesn't clash with `M` from chapter 7's spatial-SC `M` (which was
  the number of donor units in `08-staggered-did`'s sibling Part-II
  chapters and was never used in Ch.7 as `\bar M`).
- $ATT$, $ATT(g,t)$, and $ATT(e)$ are used consistently. The chapter
  is careful to distinguish "overall" from "dynamic" aggregators.

### X5. Forward link to Ch. 9 — **missing handshake**

Ch. 9 opens (`09:5–13`) by referencing Ch. 8 explicitly:

> "Chapter 8 squeezed every drop of usable signal out of the
> Callaway-Sant'Anna minimum-wage panel under one identifying
> assumption: parallel trends."

But Ch. 8 ends with `## Further reading` and never tells the reader
that parallel trends is *the* assumption that Ch. 9 will relax via
factor structure. A one-line bridge in Ch. 8 closes the loop and makes
the Ch. 9 opening feel like a continuation rather than a non-sequitur.

**Fix:** at the end of `## Recap` (after `08:377`), add a short bridge
paragraph:

> "Every method in this chapter — TWFE, $ATT(g,t)$, conditional
> DiD, even HonestDiD's bounds — leans on **parallel trends** as
> the identifying assumption. The next chapter relaxes that
> assumption by modelling $Y_{it}(0)$ with an *interactive
> fixed-effects* factor structure: $Y_{it}(0) = \alpha_i + \xi_t +
> \lambda_i' f_t + \varepsilon_{it}$. Two estimators (matrix
> completion and IFEct) implement that idea on the same panel."

### X6. `08:34–41` — the Sun-Abraham mention is dangling

`sun2021estimating` is cited in the intro (`08:37–38`) as one of "three
companion ideas", but the chapter never actually runs a Sun-Abraham
estimator. No `fixest::sunab()` chunk appears. Either (a) drop the
forward reference and only mention Sun-Abraham in `## Further reading`,
or (b) add a brief Sun-Abraham robustness chunk next to the CS event
study to deliver on the promise.

**Fix (cheaper):** change `08:37–38` to: "Along the way we look at two
companion ideas: the doubly-robust DiD estimator from
@callaway2021difference, and the Rambachan-Roth sensitivity analysis...".
Then in `## Further reading` (`08:394–397`), keep the existing
Sun-Abraham citation — that's the right home for a method this
chapter doesn't run.

## Writing & structure

### S1. `08:5` — the section title "When Basic DiD breaks" understates the chapter

The chapter is about TWFE failing under staggered adoption, not about
the 2×2 DiD of chapter 3 (which is unbiased on its own narrow problem
— it just lacked power). "Basic DiD" is therefore a bit of a strawman.

**Fix:** rename the section to "When TWFE breaks under staggered
adoption" or "When pooled DiD breaks". Less catchy, more accurate.

### S2. `08:104–106` — inline R numbers in prose are fine but the formatting is awkward

```
The working panel has `r nrow(data2)` rows on
`r length(unique(data2$id))` counties, balanced across the
2003–2007 window.
```

This renders as `8725 rows on 1745 counties`. A reader skimming might
read `1745 counties balanced across 2003–2007` and wonder if 1745 is
counties or county-years. The cohort-count table (`tbl-cohort-counts`)
that follows clarifies; still, a small parenthetical helps.

**Fix:** "The working panel has `r nrow(data2)` rows = `r length(unique(data2$id))`
counties × 5 years, balanced across the 2003–2007 window."

### S3. `08:360–377` — the four-way reconciliation callout is right; the breakdown number inside it is wrong

The callout block lines up TWFE, CS overall ATT, DR conditional ATT,
event-study trajectory, and HonestDiD breakdown into a single
"four-estimator agreement" story. The first four lines are correct.
The fifth ("breakdown $\bar M$ near 1.0") is the M1 bug surfaced in
the most prominent location in the chapter. After fixing M1, this
line should read something like:

> "HonestDiD sensitivity is *fragile*: the breakdown $\bar M$ is
> below 0.5, reflecting the visible pre-trend in cohort 2006. The
> point estimate and direction agree across all four estimators,
> but parallel trends does not hold cleanly and the on-impact effect
> would not survive even half the observed pre-trend violation."

Note that flipping this line *strengthens* the chapter pedagogically:
the rest of the chapter has been pointing toward "the pre-trend is
visible," and a sensitivity tool that confirms the worry is exactly
what the section is for. The current text (which papers over the
worry) makes HonestDiD look decorative.

### S4. `08:379–390` — the common-pitfall section is excellent, keep it as is

The "Common pitfall" section names the right pitfall (running TWFE
on staggered data and reporting the coefficient as a clean ATT)
and prescribes the right fix (estimate the primitives, then aggregate
deliberately). No changes needed.

### S5. `08:392–409` — the further-reading list is solid; add the Roth-Sant'Anna survey

Roth, Sant'Anna, Bilinski, and Poe (2023, JoE) is the canonical
review-style overview ("What's trending in difference-in-differences?")
and is the natural pointer for a reader who has finished this chapter
and wants the broader landscape. If not already in `references.bib`,
adding it is one BibTeX entry.

**Fix:** add a sentence at the end of the second paragraph
(`08:404–405`): "@roth2023whats is a recent review-style synthesis
covering staggered DiD, event studies, sensitivity analysis, and
their relationships."

### S6. `08:411–423` — exercises 2 and 3 are solid; exercise 1 needs the bias caveat (see **M7**)

Exercise 2 (`type = "calendar"`) is a good follow-up because it
forces the reader to read the `aggte` documentation. Exercise 3
(smoothness restriction) is a good follow-up because it forces the
reader to think about what restriction is plausible. Both should stay.
Exercise 1's prompt needs the bias-side complement; see **M7**.

## Action checklist (in priority order)

1. **`R/honest_did.R:36`** — fix `n` to `nrow(es$inf.function$dynamic.inf.func.e)`. This is the load-bearing fix; everything else can follow.
2. **`08:329, 339, 352–356, 365–366`** — rewrite the HonestDiD narrative to reflect the corrected breakdown (≤ 0.5, not ≈ 1). The qualitative story shifts from "robust" to "fragile, as expected from the visible pre-trend".
3. **`08:172`** — add a paragraph naming the cohort-2006 pre-trend (sets up the corrected HonestDiD result).
4. **`08:180–184`** — relabel `aggte(type = "group")` correctly (cohort-then-cross-cohort mean, not simple time-and-unit mean).
5. **`08:46`** — fix the cohort list to mention the 2007-cohort drop, OR keep the prose and add a one-line "see Setup" parenthetical.
6. **`08:37–38`** — drop the Sun-Abraham forward-reference (chapter doesn't actually run it), OR add a `fixest::sunab()` chunk.
7. **`08:148`** — add the one-sentence parallel-trends assumption statement.
8. **End of `08:377` (Recap)** — add the Ch. 9 bridge paragraph.
9. **`08:415`** — extend exercise 1's prompt to include the bias trade-off.
10. **`R/honest_did.R:64`** — re-run `quarto render --to html 08-staggered-did.qmd` after the fix, then `quarto publish gh-pages --no-prompt --no-render`.

After these edits the chapter will be both numerically correct and
pedagogically tighter: the visible pre-trend, the sensitivity test,
and the bounded conclusion become a single coherent argument, rather
than a robustness claim that papers over the pre-trend.
