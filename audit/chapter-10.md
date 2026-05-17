# Audit: Chapter 10 — Generalized Synthetic Control (`10-gsynth.qmd`)

## Summary

Chapter 10 is the last drafted chapter and the focused single-estimator companion to chapter 9. It is well-organised: hook → window-and-data → factor-grid → diagnostic plots → implicit weights → cumulative effects → reconciliation callout → common pitfall → further reading → exercises. The methodology section opens cleanly with the IFE counterfactual equation, names the **parallel-factors** identifying assumption, distinguishes it from parallel trends, and correctly positions gsynth as a generalisation of classical SC.

However, the chapter has **two showstopper bugs in the rendered output** that I verified directly against the frozen `_freeze/10-gsynth/execute-results/html.json`:

1. **The implicit-weights table renders as literally "Table has no data"** (`_freeze/.../html.json` div `raojrpglwb`), and the inline-prose claim "the donor pool is large (`r length(control_ids)` never-treated counties)" prints **"(0 never-treated counties)"** in `_book/10-gsynth.html`. Root cause: in `gsynth` 1.4.0, `gsynth::gsynth()` is a thin shim that delegates to `fect::fect()`, and the returned `wgt.implied` matrix has **no rownames or colnames**. So `colnames(W)` and `rownames(W)` are `NULL`, every downstream subset is empty, and the entire chunk degenerates silently.
2. **The cumulative-ATT table renders with an empty body** (div `ovkzargohm`, header row only, zero data rows) and the corresponding figure is a flat dashed line at zero with no axis ticks (`_freeze/10-gsynth/figure-html/fig-cumulative-1.png` — verified). Root cause: `out$est.att` has rownames `"-4","-3", …, "4"` (**event time**), not calendar years; the chunk does `est_att$year <- as.integer(rownames(est_att))` and then `filter(year >= 2004)`, which empties everything.

Both bugs are mechanical and fixable in <15 minutes each, but they completely hollow out two of the five teaching sections (donor weights, cumulative effects) and one of the chapter's headline reconciliation claims. They almost certainly slipped through because the chunks throw no error and produce a non-empty (but vacuous) figure.

Beyond the two showstoppers there are: (a) one **chapter-numbering mismatch** that attributes the doubly-robust DiD to chapter 9 when it lives in chapter 8 (lines 408, 449, 476 — actually 476 is correct, 408 and 449 are wrong); (b) the IC table's **"IC-selected" framing** is misleading because the global minimum is at *r* = 0 and the chapter manually overrides to *r* ≥ 1 without flagging that this isn't IC selection; (c) the **gap-plot and counterfactual-plot x-axes show event time, not calendar year**, even though `xlab = "Year"` is passed and the caption says "Year"; (d) the **factors plot shows two curves** (one for FE/`force = "two-way"`, one for the latent factor) but the caption insists "With $r^* = 1$ a single curve is shown"; (e) untracked `10-gsynth_files/` and `10-gsynth_cache/` directories exist at the repo root — they are correctly covered by `.gitignore` (`*_files/`, `*_cache/`) so no gitignore change is needed, but the local artifacts can be removed to keep the working tree clean.

Citations (`@xu2017generalized`, `@bai2003inferential` implicitly via the Bai-Ng IC) are present in `references.bib`. Seeds are set both globally (`set.seed(42)`, line 72) and inside `gsynth()` (line 199). The chunk that builds `fit_grid` is cached (`cache: true`, line 187) so re-renders are fast. No deprecation warnings observed.

## Strengths

- **Hook positions the chapter against the whole arc** (lines 5–18): four prior chapters named, each by what it asked of the data, then gsynth slotted in as the SCM-meets-DiD method. This is the kind of cross-chapter scaffolding the preface promised.
- **Identification statement is crisp and correct** (lines 35–40): "parallel factors, not parallel trends … unobserved shocks affecting treated and never-treated units must load on the same low-rank factor structure $f_t$." That is exactly Xu (2017)'s assumption.
- **Window-change rationale is explicit** (lines 42–47): cohort 2004 has 3 pre-periods, cohort 2006 has 5, hence `min.T0 = 3`. Reader can replicate the decision.
- **Learning-mode caveat callout** (lines 49–59) is prominent, names the four specific knobs (`nboots`, factor grid, parallel, bootstrap type), and explicitly tells the reader point estimates are unchanged. This is the right tone.
- **Notation matches chapter 9 exactly:** $\lambda_i$ and $f_t$ are reused (line 27 in ch.10 vs line 25 in ch.09). The reader who came from ch.9 reads ch.10 fluently.
- **Tibble-vs-data.frame footgun documented** (lines 92–96): "`gsynth()` expects a base `data.frame` — passing a tibble silently breaks its internal indexing — so we cast with `as.data.frame()`." This is exactly the kind of practitioner-level note that justifies the book.
- **CV-vs-IC framing** (lines 176–181): the chapter explains *why* CV is turned off (rolling-window CV needs more pre-periods than this panel has) and falls back to IC. Reader understands the choice.
- **Common-pitfall section** (lines 432–449) names three concrete diagnostics: pre-treatment fit, IC across $r$, and the convex-hull check in the loadings plot. The triple is well-chosen and aligned with the failure modes Xu and Liu/Wang/Xu warn about.
- **Exercises are method-substantive**, not busy-work: extend the grid (Ex 1), drop covariates (Ex 2), reconcile against ch.8's DR estimate (Ex 3), flip to research-grade compute (Ex 4). Ex 4 is the right way to teach the "learning-mode" caveat by inversion.
- **Reproducibility hygiene:** `set.seed(42)` is set globally **and** passed as `seed = 42` inside `gsynth()` (line 199). `cache: true` on the expensive grid (line 187) keeps re-renders fast.
- **Freeze cache is healthy.** `_freeze/10-gsynth/execute-results/html.json` exists with the seven expected figure-html PNGs.

## Methodology issues

### M1. `10-gsynth.qmd:27–33` — projection step is mentioned but not spelled out

The equation on line 27 is correct and the prose "then projecting each treated unit onto the estimated factor space to impute its $Y_{it}(0)$" (lines 30–31) is gestural rather than precise. For the audience the brief calls "mixed undergrad-friendly but rigorous," the two-step procedure should be made explicit in one or two extra lines, because *this is the move that distinguishes gsynth from any other IFE estimator*. Concretely:

> gsynth's two-step procedure:
>
> 1. **Fit IFE on never-treated.** Estimate $(\hat\alpha, \hat\xi, \hat\beta, \hat F)$ on the $G = 0$ subpanel by alternating SVD/OLS until convergence.
> 2. **Project treated units onto $\hat F$.** For each treated unit $i$, regress its pre-treatment residuals $Y_{it} - \hat\alpha_i - \hat\xi_t - X_{it}'\hat\beta$ (over $t < T_i$) on $\hat F$ to recover $\hat\lambda_i$. The counterfactual at any post-period $t$ is then $\hat Y_{it}(0) = \hat\alpha_i + \hat\xi_t + \hat\lambda_i'\hat f_t + X_{it}'\hat\beta$.

Without the second step's OLS-on-$\hat F$ description, a reader cannot tell why pre-treatment depth is required (it's the number of equations in the projection regression), and the "needs enough pre-treatment depth to identify factors" line in the recap callout (line 420) is left without a mechanism.

**Fix:** insert a 4–5-line numbered list after line 33 that walks through the two estimation steps explicitly.

### M2. `10-gsynth.qmd:222–238` — "IC-selected rank" is not actually IC-selected

The IC table (verified frozen output, div `oeuycrinwz`) shows:

| r | ATT     | S.E.   | IC      | sigma2 |
|---|---------|--------|---------|--------|
| 0 | −0.0468 | 0.0081 | −2.6303 | 0.0192 |
| 1 | −0.0958 | 0.0254 | −1.6265 | 0.0140 |

The IC global minimum is at *r* = 0. The chunk at lines 222–225 nonetheless picks *r* = 1 by filtering `r >= 1` first:

```r
candidate <- ic_tbl |> filter(r >= 1)
r_star    <- candidate$r[ which.min(candidate$IC) ]
```

The chapter acknowledges this on lines 228–236 ("Read literally, the IC table's global minimum is at $r = 0$") but then frames the result as the "IC-selected rank" in the recap (line 402) and the "factor-augmented" headline ATT. This is a meaningful conceptual gap: the rank selection is **not** IC-driven — it is a pedagogical override to keep a factor model on stage. Calling it "IC-selected" muddies the methodological story the rest of the chapter sells.

**Fix options (one of):**

- **(a) Honest relabel.** Replace "IC-selected" with "pedagogical override: smallest non-zero rank" everywhere the phrase appears (line 402 and the callout context). Add a sentence to the callout: "By the strict IC criterion, the data prefer the no-factor model; we showcase $r = 1$ because the factor mechanism is the chapter's subject. In a real application you would report the $r = 0$ estimate alongside or instead."
- **(b) Run a real selection.** Use `r = c(0, 5)` with `CV = TRUE` on a panel with enough pre-periods (i.e., keep `min.T0` set to allow only cohort 2006, which has 5 pre-periods, then `cv.nobs` can be set lower) and let CV pick. The point estimate will move, but the methodological story will be honest.

I recommend (a) — it requires no recompute and turns the section into an honest worked example of *what IC says vs what a researcher might choose anyway*.

### M3. `10-gsynth.qmd:175–181` — the `cv.nobs = 8` arithmetic uses legacy defaults

The chapter writes "gsynth's default rolling-window CV needs `min.T0 + cv.nobs = 8` pre-treatment periods per treated cohort." Since the chunk also sets `min.T0 = 3`, the user-facing constraint is actually $3 + 3 = 6$ (with the new `fect::fect`-backed default of `cv.nobs = 3`). The number "8" comes from the legacy `gsynth` defaults (`min.T0 = 5`, `cv.nobs = 3`). The conclusion ("which we do not have") is still correct, but the arithmetic is internally inconsistent with the chunk's own arguments two pages later.

**Fix:** rewrite as:

> Cross-validation in `gsynth`'s rolling-window scheme needs at least `min.T0 + cv.nobs` pre-treatment periods per treated cohort — with the package defaults, eight. Even with the lower `min.T0 = 3` we set below, the binding constraint (six pre-periods per cohort) still exceeds what cohort 2004 has available, so CV would silently drop that cohort. Disabling CV and selecting the factor count by information criterion sidesteps the cohort loss.

### M4. `10-gsynth.qmd:5–18` — no explicit framing of gsynth as a *generalisation* of classical SC (ch.4)

The hook names "Chapter 4 (classical SCM) hand-built a weighted donor average for a single treated unit" and "[gsynth] sits at the intersection of SCM and panel DiD" (line 20). But the audit brief flags that the **gsynth-as-generalisation-of-SC** link should be made explicit, and it currently isn't. A reader who only read ch.4 should be told *what gsynth gives them that ch.4 didn't*:

- ch.4 picks one set of donor weights to match a single treated unit's pre-treatment outcome path;
- gsynth replaces "donor weights" with "factor loadings" — each treated unit's counterfactual is a low-rank reconstruction from the factor space estimated on never-treated controls;
- the implicit-weights matrix `out$wgt.implied` is *exactly* the gsynth analogue of the synthetic control weight vector $W$ from ch.4 — see the §"Implied donor weights" section (line 306).

The last bullet is the most important — it is the bridge that makes the §"Implied donor weights" section legible to a reader who came in through Part I.

**Fix:** add a single paragraph after line 23 ("Like staggered DiD, it accommodates many treated units adopting at different times.") explicitly threading the SC inheritance:

> Why call it *generalised* synthetic control? Because the classical SC weight vector $W$ of chapter 4 — chosen to match California's pre-treatment trajectory — is the rank-1 limit of gsynth when there is exactly one treated unit, one factor, and the loading is constrained to lie in the simplex. gsynth drops both restrictions: it allows many treated units, an estimated factor count, and unrestricted loadings. The implicit-weight matrix we look at in §"Implied donor weights" below is the literal analogue of $W$, one column per treated unit.

### M5. `10-gsynth.qmd:288, 293` — factors-plot caption is wrong, loadings-plot caption is borderline

The factors plot (`_freeze/10-gsynth/figure-html/fig-gsynth-factors-1.png`, verified) shows **two** curves: one labelled "0" (the two-way FE component, in grey) and one labelled "1" (the estimated latent factor, in orange). The caption (line 277) reads "With $r^* = 1$ a single curve is shown." That contradicts what the reader sees on the page.

**Fix:** rewrite the caption to acknowledge the two-line layout `plot.gsynth(type = "factors")` produces:

> Estimated latent factor(s) $f_t$ over time. The orange line is the single estimated factor ($r^* = 1$). The grey line marked "0" is the time fixed effect $\xi_t$ that `force = "two-way"` adds alongside the factor; gsynth's default plot draws both for context. Shape of the orange curve captures the unobserved time-varying shock the factor model is using to explain co-movement in the never-treated panel.

For the loadings plot caption (line 293), the rendered figure shows a 2×2 panel matrix (FE × Factor 1 density on the diagonals; the bottom-left scatter is FE-loading on x-axis, Factor-1-loading on y-axis). The caption's "concentration of treated loadings inside the cloud of control loadings" is the right substantive reading of the bottom-left scatter, but a reader looking at the figure won't immediately see *which* panel the caption is describing. Add one clause: "(specifically, the bottom-left scatter, which crosses the FE loading on the x-axis with the Factor 1 loading on the y-axis)."

## Code & reproducibility issues

### C1. `10-gsynth.qmd:314–333` — implicit-weights chunk silently produces "Table has no data"

**This is the showstopper bug** I named in the Summary. The chunk does:

```r
W <- out$wgt.implied
treated_ids <- colnames(W)      # NULL in gsynth 1.4.0
control_ids <- rownames(W)      # NULL in gsynth 1.4.0
top_treated <- treated_ids[order(-apply(W, 2, max))[1:5]]   # NULL[...]
```

I verified by re-fitting locally:

```
> dim(fit$wgt.implied)
[1] 1417  328
> head(rownames(fit$wgt.implied))
NULL
> head(colnames(fit$wgt.implied))
NULL
```

In `gsynth` 1.4.0, `gsynth::gsynth()` is a thin shim that delegates to `fect::fect()` (see `gsynth::gsynth` source — 41 lines, of which the body is a single `fect::fect(...)` call). The new `fect`-backed implementation drops the row/column names. So `top_treated` collapses to a zero-length character vector, `map_dfr()` returns an empty tibble, and `gt_pretty()` prints `Table has no data`. The downstream prose on lines 334–340 then quotes `r length(control_ids)` and prints **"(0 never-treated counties)"**.

**Fix:** recover the names from `out$Y.tr` (treated outcomes) and `out$Y.co` (control outcomes), which still carry id columns. Concretely, replace lines 317–319 with:

```r
W <- out$wgt.implied
# gsynth 1.4.0 (which delegates to fect 2.x) drops row/col names on wgt.implied;
# recover them from the treated/control id vectors the fit stores.
rownames(W) <- as.character(out$id.co)   # never-treated county ids
colnames(W) <- as.character(out$id.tr)   # treated county ids
treated_ids <- colnames(W)
control_ids <- rownames(W)
```

(If `out$id.co` / `out$id.tr` are not exposed under those names — verify by `names(out)`; alternative is `setdiff(unique(mw_df$id[mw_df$treat == 0]), unique(mw_df$id[mw_df$treat == 1]))` for controls.)

After the fix, re-render and the table populates with the top-5 donor counties per treated unit and `length(control_ids)` becomes 1417 (matches the 1417 control rows in the cohort table).

### C2. `10-gsynth.qmd:357–377` — cumulative-effects chunk silently produces an empty table and a flat-line figure

The chunk does:

```r
est_att <- as.data.frame(out$est.att)
est_att$year <- as.integer(rownames(est_att))
cumu_df <- est_att |> arrange(year) |> filter(year >= 2004) |> ...
```

In `gsynth` 1.4.0, `rownames(out$est.att)` is **event-time labels** (`"-4", "-3", "-2", "-1", "0", "1", "2", "3", "4"`), not calendar years. Verified locally:

```
> rownames(fit$est.att)
[1] "-4" "-3" "-2" "-1" "0"  "1"  "2"  "3"  "4"
```

So `as.integer(rownames(...))` yields `{-4, …, 4}`, the `filter(year >= 2004)` clause drops everything, `cumu_df` is empty, the `gt_pretty()` table renders header-only (div `ovkzargohm`, body length 0), and `ggplot` draws nothing on `fig-cumulative-1.png` except the dashed zero line (I verified the PNG by reading it; it shows axis grid + dashed zero ref line and no data layer).

**Fix:** keep event time, *or* map event time back to calendar years. The cleaner option is event time (it's what the gap plot already uses, and it matches `_freeze/.../fig-gsynth-gap-1.png`, which has x-axis −4 to +4):

```r
est_att <- as.data.frame(out$est.att)
est_att$event_time <- as.integer(rownames(est_att))

cumu_df <- est_att |>
  arrange(event_time) |>
  filter(event_time >= 0) |>   # post-treatment periods only
  mutate(
    cum_att    = cumsum(ATT),
    cum_se     = sqrt(cumsum(`S.E.`^2)),
    `CI lower` = cum_att - 1.96 * cum_se,
    `CI upper` = cum_att + 1.96 * cum_se
  ) |>
  transmute(`Event time`       = event_time,
            `ATT (period)`     = ATT,
            `Cumulative ATT`   = cum_att,
            `Cum. S.E.`        = cum_se,
            `CI lower`,
            `CI upper`)

gt_pretty(cumu_df, decimals = 4)
```

And in the `ggplot()` call, replace `aes(x = Year, ...)` with `aes(x = \`Event time\`, ...)`, and the figure caption "since the earliest treatment onset (year 2004)" should become "since treatment onset (event time 0)". This also fixes the conceptual mismatch with the gap plot, which already uses event time.

### C3. `10-gsynth.qmd:255–256, 270` — `plot.gsynth(type = "gap" | "counterfactual")` ignores `xlab = "Year"` and shows event time

Both the gap plot (`fig-gsynth-gap-1.png`) and the counterfactual plot (`fig-gsynth-counterfactual-1.png`) render with x-axis `-4, -2, 0, 2, 4` — event time, not calendar year — even though both chunks pass `xlab = "Year"`. Verified by reading the PNGs. The `plot.gsynth()` method does honour the `xlab` *label* (so the axis title reads "Year") but does **not** convert the x-axis values to calendar years. The result is misleading: the axis title says "Year" and the ticks show "−4 −2 0 2 4".

**Fix (two options):**

- **(a) Honest labelling.** Change `xlab = "Year"` to `xlab = "Event time (years since treatment)"` in both chunks (lines 255 and 270). This is the cheapest fix and matches what the figure actually shows.
- **(b) Force calendar-year axis.** Pass `axis.adjust = TRUE` or post-process the ggplot returned by `plot.gsynth()` to override the x-axis scale. This is fiddly and probably not worth it for a teaching chapter.

I recommend (a). It also makes the cumulative-effects chunk fix in C2 (also event-time-based) consistent with the gap and counterfactual plots.

### C4. `10-gsynth.qmd:194` — `inference = "nonparametric"` is silently converted to `"bootstrap"`

In the new `gsynth` 1.4.0 → `fect` 2.x flow, the line `if (inference == "nonparametric") { inference <- "bootstrap" }` runs unconditionally in `gsynth::gsynth()` (verified by reading the source). The user-facing argument `inference = "nonparametric"` still works (no warning) but is essentially a documentation alias for `"bootstrap"`. This is benign — but if the chapter wants to be precise, the chunk argument could be changed to `inference = "bootstrap"` to match what `fect` actually does. Otherwise leave a one-line note that gsynth historically used `"nonparametric"` as the keyword for what `fect` now calls `"bootstrap"`.

**Fix:** optional. Either change `inference = "nonparametric"` → `inference = "bootstrap"` on line 194, or add a sentence near it: "We pass the legacy gsynth keyword `nonparametric`; internally the new gsynth backend translates this to `fect`'s `bootstrap` vartype."

### C5. Repo hygiene — stray `10-gsynth_files/` and `10-gsynth_cache/` at repo root

Phase-1's finding is **confirmed**: both directories exist at `/Users/carlosmendez/Documents/GitHub/ccm/10-gsynth_files/` and `/Users/carlosmendez/Documents/GitHub/ccm/10-gsynth_cache/`, sitting next to `10-gsynth.qmd`. They are **untracked** (`git ls-files` returns nothing) and **correctly ignored** by `.gitignore` lines 9–10 (`*_files/`, `*_cache/`) — verified via `git check-ignore -v`. So **no `.gitignore` edit is needed**.

These are local render byproducts produced when `quarto render --to html` runs **outside** the freeze-cache path (e.g., when chunk-level `cache: true` is hit). The directories are safe to delete; they will be re-created by the next render and stay ignored. No action required on the chapter source.

**Recommendation:** delete them locally with `rm -rf 10-gsynth_files/ 10-gsynth_cache/` to keep the working tree tidy. No change to `.gitignore` needed.

### C6. `10-gsynth.qmd:62, 72, 199` — seed hygiene is good but worth documenting

Seeds are set in three places: `set.seed(42)` globally (line 72), `seed = 42` inside `gsynth()` (line 199), and the `nboots = 100` bootstrap inherits the in-call seed. This is correct. One small note: if the reader bumps `nboots = 100` to `nboots = 1000` per Ex 4, the seed remains `42`, so the result is exactly reproducible — that's worth a sentence in Ex 4 ("the seed = 42 inside the gsynth call ensures your bootstrap CIs are reproducible across `nboots` levels").

## Cross-chapter consistency

### X1. `10-gsynth.qmd:408, 449` — doubly-robust DiD belongs to chapter 8, not chapter 9

Line 408: "within sampling error of the **chapter-9 staggered-DiD estimates**" — but the staggered-DiD estimates (TWFE, CS, IPW, DR) are all in chapter **8** (`08-staggered-did.qmd`). Chapter 9 is the IFE/MC chapter and does not run a DiD-family estimator.

Line 449: "such as the **chapter-9 doubly-robust DiD**" — same misattribution. The DR DiD is the four-row `tbl-cap` table in `08-staggered-did.qmd` (line 265).

Line 476 (Exercise 3) correctly says "chapter 8 ($-0.065$)".

**Fix:** change "chapter-9" → "chapter-8" on lines 408 and 449.

### X2. `10-gsynth.qmd:5–23` — Part II positioning is fine; Part I positioning is thin

The hook (lines 5–18) lists Chapters 4, 7, 8, 9 — but skips chapters 5 (BSTS) and 6 (scpi), which together with chapter 7 are the three single-treated-unit chapters of Part I that gsynth most directly extends to multiple treated units. This isn't strictly wrong (gsynth is closest in spirit to ch.4), but since the brief flags "what cross-method reconciliation does it provide back to ch.05 (BSTS), ch.06 (scpi), ch.07 (spatial)?" as a question I should answer, it's worth noting that *the chapter currently provides essentially none*. Chapter 5 (BSTS) and chapter 6 (scpi) are never mentioned. Chapter 7 (spatial) is mentioned in one phrase ("Chapter 7 layered a spatial prior on top") and never returned to.

A clean addition would be a closing paragraph in the §"Where gsynth fits" section that explicitly tables the family relationships:

| Method     | Counterfactual is …                          | Treated units | Identifying assumption       |
|------------|----------------------------------------------|---------------|------------------------------|
| Classical SC (ch.4)  | Donor-weight average                | 1             | Pre-treatment fit            |
| BSTS (ch.5)          | Time-series forecast                | 1             | No post-period structural break in controls |
| scpi (ch.6)          | Donor-weight average + PI           | 1             | SC + asymptotics             |
| Spatial SC (ch.7)    | Donor-weight average + spatial smoothing | 1        | SC + spatial prior           |
| Staggered DiD (ch.8) | TWFE / cohort-time averages         | many          | Parallel trends              |
| IFEct / MC (ch.9)    | Low-rank imputation                 | many          | Parallel factors / low rank  |
| **gsynth (ch.10)**   | Low-rank imputation + projection    | many          | Parallel factors             |

This single table also pays back the Part II framing and sets up the planned cross-method comparison chapter (see closing paragraph below).

### X3. `10-gsynth.qmd:431, 460` — § "Further reading" and § "Common pitfall" both point only forward

The §"Further reading" (lines 451–462) names `@xu2017generalized` and the `fect` tutorial — both right. It mentions chapter 9. It does **not** point readers back to chapter 4 (Abadie SC), even though gsynth is conceptually a direct generalisation. A one-line addition would close the loop: "Chapter 4's classical SC is the single-treated-unit, simplex-loading, rank-1 special case of what gsynth fits here — re-read §4 with the loading equation $\hat Y_{it}(0) = \hat\lambda_i'\hat f_t$ in mind and the connection becomes mechanical."

### X4. Notation match with chapter 9 is good

Both chapters use $\lambda_i$ (loading) and $f_t$ (factor), and both write the IFE equation as $Y_{it}(0) = \alpha_i + \xi_t + \lambda_i' f_t + (\cdot)$. The covariate term differs (ch.10 has $X_{it}'\beta$, ch.9 doesn't), but that asymmetry is explained — ch.9's audit (W2) already flagged the missing covariates as a ch.9 issue, not a ch.10 one. **No fix required.**

### X5. `references.bib` — `@xu2017generalized` is correctly cited

Verified: lines 236–246 of `references.bib` contain the entry. Ch.10 cites it on line 16 (`[@xu2017generalized]`) and line 453 (`@xu2017generalized is the canonical reference`). Renders correctly in `_book/10-gsynth.html`. **No fix.**

The closely related `@bai2003inferential` (lines 224–234 of `references.bib`) is referenced only by parenthetical name in the tbl-cap ("The IC (Bai 2003)") rather than by `[@bai2003inferential]`. This is a missed citation — the IC the table is reporting is the Bai-Ng IC, and the entry is in the bib. Replacing "Bai 2003" with "[@bai2003inferential]" in the `tbl-cap` on line 206 would make the citation render on the References page.

## Writing & structure

### W1. `10-gsynth.qmd:393–428` — the "Recap" callout is strong but mis-titled

The §"Recap" heading is one line above a callout that is itself titled "The estimators reconciled." Most other chapters in the book use **"Reconciliation"** or **"What we learned"** as the section heading and reserve the in-callout title for the takeaway. The current double-title is slightly redundant.

**Fix:** rename the section from `## Recap` to `## Reconciliation`. The callout's internal title "The estimators reconciled" then flows from the section heading rather than restating it.

### W2. `10-gsynth.qmd:451–462` — § "Further reading" misses two natural pointers

Currently only `@xu2017generalized` and the `fect/06-gsynth.html` URL are named. Two additions would round it out:

- **The `gsynth` package vignette / GitHub page** (`https://yiqingxu.org/packages/gsynth/`), since the chapter still uses the standalone `gsynth` package and its API differs subtly from `fect`'s in ways the reader will run into.
- **The 2017 *Political Analysis* article's online replication archive**, if you want to send curious readers to the original Xu code rather than the `fect` re-implementation.

### W3. No "Key concepts at a glance" section

The recent commit `1718668` ("Remove 'Key concepts at a glance' section from ch.7") suggests the book is dropping that section pattern. Chapter 10 doesn't have one either, which is consistent. **No action needed** — but if the cross-method comparison chapter (see below) restores the pattern, ch.10's analogue would be: "rank $r$, factor $f_t$, loading $\lambda_i$, implicit weight, parallel-factors assumption, IC vs CV selection."

### W4. `10-gsynth.qmd:464–482` — Exercises are well-pitched

All four exercises are tied to a concrete chunk in the chapter and to a verifiable claim. Exercise 4 ("flip to research-grade") is especially valuable because it inverts the learning-mode caveat without making the reader sit through the slow render in the live book. **No change needed.**

### W5. `10-gsynth.qmd:430–449` — § "Common pitfall" overlaps with § "Recap"

The three diagnostics named in §"Common pitfall" (pre-treatment fit, IC sensitivity, convex hull) are also alluded to in the recap callout. This is fine — repetition aids retention — but if you want to economise, move the convex-hull bullet from "Recap" to "Common pitfall" only.

## File-by-file paths referenced

- `/Users/carlosmendez/Documents/GitHub/ccm/10-gsynth.qmd` — the chapter source under audit.
- `/Users/carlosmendez/Documents/GitHub/ccm/09-matrix-completion-and-ife.qmd:25` — IFE equation that ch.10 reuses; notation matches.
- `/Users/carlosmendez/Documents/GitHub/ccm/08-staggered-did.qmd:134, 199, 361–363` — the "$-0.038$ / $-0.057$ / $-0.065$" numbers ch.10's recap quotes; confirmed in ch.8 source.
- `/Users/carlosmendez/Documents/GitHub/ccm/04-classical-synthetic-control.qmd` — the chapter ch.10 should point back to as the rank-1 special case of gsynth.
- `/Users/carlosmendez/Documents/GitHub/ccm/references.bib:236–246` — `@xu2017generalized` (canonical reference, correctly cited).
- `/Users/carlosmendez/Documents/GitHub/ccm/references.bib:224–234` — `@bai2003inferential` (present in bib, only referenced parenthetically in the chapter).
- `/Users/carlosmendez/Documents/GitHub/ccm/references.bib:260–270` — `@liu2024practical` (companion to `fect`, not yet cited in ch.10).
- `/Users/carlosmendez/Documents/GitHub/ccm/R/table_helpers.R` — `gt_pretty()` used at lines 125, 218, 332, 376; usage correct.
- `/Users/carlosmendez/Documents/GitHub/ccm/_freeze/10-gsynth/execute-results/html.json` — frozen output verified; size 65 KB; contains the four `gt_table` divs (`qeayjdrzqo`, `oeuycrinwz`, `raojrpglwb`, `ovkzargohm`) and confirms tables 2 (weights) and 3 (cumulative) render empty.
- `/Users/carlosmendez/Documents/GitHub/ccm/_freeze/10-gsynth/figure-html/fig-cumulative-1.png` — verified as a flat zero-line figure with no data layer (consequence of C2).
- `/Users/carlosmendez/Documents/GitHub/ccm/_freeze/10-gsynth/figure-html/fig-gsynth-gap-1.png` — verified as event-time x-axis (−4 to +4), confirms C3.
- `/Users/carlosmendez/Documents/GitHub/ccm/_freeze/10-gsynth/figure-html/fig-gsynth-factors-1.png` — verified as two-curve plot (FE + Factor 1), confirms M5.
- `/Users/carlosmendez/Documents/GitHub/ccm/_book/10-gsynth.html` — rendered output confirms the prose "donor pool is large (0 never-treated counties)" and the empty "Table has no data" in the implicit-weights section.
- `/Users/carlosmendez/Documents/GitHub/ccm/10-gsynth_files/` and `/Users/carlosmendez/Documents/GitHub/ccm/10-gsynth_cache/` — exist at repo root, untracked, correctly ignored by `.gitignore` `*_files/` and `*_cache/` (no gitignore change needed; safe to `rm -rf`).
- `/Users/carlosmendez/Documents/GitHub/ccm/.gitignore:9–10` — the `*_files/` and `*_cache/` patterns that already cover C5.

---

## What a cross-method comparison chapter should cover, building on what ch.10 already does

Chapter 10 is the **last drafted chapter** and the book currently has no cross-method comparison chapter wired into `_quarto.yml`. The natural shape of that chapter — call it **`11-comparison.qmd`** — falls out of what ch.10's recap callout (lines 393–428) already sketches in miniature. The chapter should do three things ch.10 starts but cannot finish in-scope.

**First**, build the family table (X2 above) into a full **two-page taxonomy** that crosses (i) target estimand (single-treated ATT vs many-treated ATT or ATT(g,t)), (ii) counterfactual construction (donor weights / forecast / low-rank imputation / nuclear-norm completion), (iii) identifying assumption (pre-treatment fit / no structural break / parallel trends / parallel factors / low rank), (iv) uncertainty quantification (placebo / posterior / clustered / bootstrap / prediction-interval), (v) software (`tidysynth`, `Synth`, `CausalImpact`, `bsts`, `scpi`, `scspill`, `did`, `HonestDiD`, `fect`, `gsynth`). This is the table the preface promised in spirit but never built. Each row is one chapter; each column is one design dimension. The reader who has worked through Parts I and II finally sees the seven methods on the same axes, and the comparison stops being implicit in the prose and becomes a single page they can pin to a wall.

**Second**, run a **head-to-head numerical reconciliation on the Prop 99 panel** (Part I's shared dataset). Every Part I chapter produced a point estimate for California's smoking-rate ATT — the natural comparison chapter would re-fit Synth (ch.4), CausalImpact (ch.5), scpi (ch.6), spatial-SC (ch.7), and, importantly, **a single-treated-unit gsynth fit on Prop 99 that ch.10 deliberately did not run** (because ch.10's framing committed to the CS minwage panel). Plot all five point estimates with their respective uncertainty intervals on one canvas. The natural narrative payoff: "the methods agree on direction and on order of magnitude; they disagree on uncertainty in ways that map exactly onto the assumptions in the taxonomy above." This is the cross-method reconciliation ch.10 keeps gesturing at and Part I never delivers.

**Third**, run a **head-to-head numerical reconciliation on the CS minwage panel** (Part II's shared dataset) — TWFE (ch.8), CS overall ATT (ch.8), DR conditional ATT (ch.8), IFEct (ch.9), MC (ch.9), gsynth-IC (ch.10), gsynth-rank-0-TWFE-equivalent (ch.10). This is the closing flourish: seven point estimates in a single forest plot, all on the same dataset, with the identifying assumption named under each row. Ch.10's recap callout already prints four of these seven (TWFE, CS, DR, gsynth $r^* = 1$) — the comparison chapter would extend that to all seven and add the gsynth $r = 0$ baseline (which ch.10 reports as ATT ≈ $-0.047$, ie a third value within sampling error of TWFE).

The chapter should close with a **decision flowchart** (a Mermaid block, given the book already wires Mermaid in `_quarto.yml`) that walks a reader through "if you have one treated unit and a long pre-period → ch.4 or ch.5; if you have one treated unit and a short pre-period → ch.6; if you have spatially-correlated outcomes and one treated unit → ch.7; if you have many treated units adopting at the same time → ch.8; if you have many treated units adopting at different times and parallel trends look plausible → ch.8 CS or DR; if parallel trends are doubtful and pre-period is long → ch.9 IFEct or ch.10 gsynth; if pre-period is very short → ch.9 MC; if you want valid prediction intervals → ch.6 or ch.7." That diagram is the practical answer to the question "which method should I run?" — and it is the synthesis ch.10's recap callout points at but cannot achieve within its own scope.

If only one of these three pieces fits — pick the head-to-head numerical reconciliation on the CS minwage panel, since it leverages exactly the cached fits ch.8, ch.9, ch.10 already produce and would re-render in under a minute on a warm freeze cache.
