# Chapter 2 audit — Interrupted Time Series

File: `02-interrupted-time-series.qmd` (224 lines).
Cached freeze: `_freeze/02-interrupted-time-series/execute-results/{html,tex,epub}.json` and `figure-html/{fig-its-growth-1.png, fig-its-arima-1.png}`.
Published HTML: `_book/02-interrupted-time-series.html` (built from the same freeze).

## Summary

The chapter is pedagogically well structured: a clear hook, parallel "idea / equation / code / reading the output / pitfall" treatment of two ITS variants, and a closing comparison that motivates the rest of Part I. Notation is consistent with chapter 1 ($Y_{1t}$, $Y_{1t}(0)$, ATT) and the closing paragraph signposts chapters 3-5 correctly.

**However the chapter currently does not run.** The cached freeze and the published HTML both show that `report(fit_arima)` returns `Model: NULL model` and `mean(ce_arima)` returns `[1] NA`. The prose then asserts that AICc "typically selects `ARIMA(1, 2, 0)`" and that the ATT is "around $+4.5$ packs" — neither of which is visible to a reader of the rendered book. The disagreement the chapter is *built around* is therefore a phantom: the linear-growth ATT shows as `-28.27868`, but the ARIMA half shows no model, no forecast, and an `NA` ATT, while the figure caption promises a "dashed counterfactual" that does not appear in `fig-its-arima` (only the observed series is visible). I reproduced this locally (R 4.5.2, fable 0.5.0, tsibble 1.2.0): the call `ARIMA(cigsale, ic = "aicc")` raises the warning `1 error encountered for timeseries` and silently produces a `<NULL model>`. With the explicit spec `ARIMA(cigsale ~ pdq(1,2,0))` the fit succeeds and yields exactly the model and ATT (+4.55) the prose describes. This is the single most important issue in the chapter.

Secondary findings: the chapter never states the ITS identification assumption as a labelled assumption; it shows zero residual diagnostics (no ACF, no Ljung-Box, no `gg_tsresiduals()`); the ARIMA forecast variance is never used to attach a prediction interval to the counterfactual, even though `fable::forecast()` produces one for free; and a centred index `year0` is introduced in setup but never used in any model. Cross-chapter transitions are fine outward (ch. 2 → 3) and weak inward (ch. 3 has no opening reference back to "ITS is fragile, so we now add a control state").

## Strengths

- Clear hook in §1 (`:7-14`) that frames the two-model design and explicitly tells the reader that the disagreement is the point.
- Symmetric structure for the two methods — same `idea / equation / code / reading / pitfall` skeleton — makes the comparison easy to follow.
- Notation (`Y_{1t}`, `Y_{1t}(0)`, `T_{post}`, `t^*`, ATT) matches ch. 1 exactly. ATT formulas at `:78` and `:148` mirror the ATT definition in `01-introduction.qmd:73` correctly.
- Plain-English unpacking of $p$, $d$, $q$ at `:152` is well pitched for the mixed undergraduate audience.
- Closing paragraph (`:213-219`) explicitly names *why* the two answers disagree (level vs. acceleration extrapolation) and explicitly hands off to chs. 3, 4, 5. The "Where this leaves us" sentence is the strongest pedagogical move in the chapter.
- `fig-its-growth` (the cached PNG) reads cleanly in both site themes; the transparent-background theme set at `:32-42` is consistent with the rest of the book.
- Citations in "Further reading" (`:223-224`) resolve: `bernal2017interrupted` is in `references.bib:47` and `hyndman2021forecasting` is at `:58`.

## Methodology issues

1. **`02-interrupted-time-series.qmd:160-165` — the auto-ARIMA call does not produce a model.** With `fable` 0.5.0 / R 4.5.2, `ARIMA(cigsale, ic = "aicc")` returns a `NULL model` (a warning is emitted, then silently swallowed by the suppression at `:156-157`). The cached `report(fit_arima)` output is literally:

   ```
   Series: cigsale
   Model: NULL model
   NULL model
   ```

   and `mean(ce_arima)` is `[1] NA`. The prose at `:167` ("AICc typically selects `ARIMA(1, 2, 0)`") and at `:205` ("around $+4.5$ packs") describes a model that the rendered chapter never displays. **Fix:** drop `ic = "aicc"` (fable's `ARIMA()` already uses AICc by default and the bare `ARIMA(cigsale)` call *also* fails on this 19-observation series — see point 2). Replace with an explicit spec, e.g. `model(timeseries = ARIMA(cigsale ~ pdq(1,2,0) + PDQ(0,0,0)))`, which I verified fits and yields `ATT = 4.549`, matching the chapter's claim. Then change the framing from "AICc selects" to "the AICc-minimising order on the pre-period is (1,2,0); we fit that explicitly". Removing `#| message: false` / `#| warning: false` from the chunk header would also surface fitting problems instead of hiding them.

2. **`02-interrupted-time-series.qmd:18, 144, 160` — overstated claim about AICc auto-search.** The chapter twice describes `fable::ARIMA(..., ic = "aicc")` as searching `(p,d,q)` and picking the minimiser. In practice fable's stepwise search on this short series (19 pre-period years) plus the *default* `PDQ()` seasonal search fails: even `ARIMA(cigsale)` with no extra arguments returns a `<NULL model>` warning. **Fix:** be honest about what the package does. Either (a) constrain to non-seasonal with `PDQ(0,0,0)` and `stepwise = FALSE`, document the search range, and report the actual selected order; or (b) explain that the chapter picks `(1,2,0)` by hand to illustrate the "double-differenced acceleration" extrapolation that AICc would prefer on this series, then verify the choice with a small grid (also a teaching opportunity).

3. **`02-interrupted-time-series.qmd:5-15, 64, 136` — ITS identification assumption is never stated as an assumption.** The chapter talks about "extrapolation" but never writes the single sentence "ITS identifies the ATT under the assumption that the pre-period DGP $f(\cdot)$ for $Y_{1t}(0)$ would have continued into the post-period absent the treatment". Chapter 1 sets a precedent by labelling assumptions (e.g. the parallel-trends assumption in ch. 3 is named explicitly at `03-basic-diff-in-diff.qmd:9`). **Fix:** add a one-line **"Identification."** bold-led sentence early in §1 ("ITS recovers the ATT only if the *same* stochastic process that generated 1970-1988 California would have generated 1989-2000 California absent Proposition 99"), then refer back to it in the closing §6.

4. **`02-interrupted-time-series.qmd:154-177, 181-203` — no residual diagnostics anywhere.** The chapter loads `feasts` ("for time-series diagnostics", `:18`) but never calls `gg_tsresiduals()`, `ACF()`, or `features(..., ljung_box, ...)`. For an ITS chapter that hinges on the credibility of an extrapolation, this is the single biggest methodological omission. Showing the linear-trend residuals' ACF would also visualise *why* OLS on a trended short series is fragile (the residuals are heavily autocorrelated). **Fix:** add a small chunk after `:165` with `fit_arima |> gg_tsresiduals()` and a Ljung-Box test (`augment(fit_arima) |> features(.innov, ljung_box, lag = 5, dof = 1)` — I verified this returns `lb_stat = 5.61, p = 0.230`, which the chapter can read as "residual autocorrelation does not reject white noise, but the *out-of-sample* extrapolation still bends pathologically — diagnostics are necessary but not sufficient"). That tightens the methodological argument considerably.

5. **`02-interrupted-time-series.qmd:169-177, 181-203` — ARIMA forecast variance is computed but discarded.** `fable::forecast()` returns a distributional column (`cigsale` is a `<dist>`), from which 80/95 % prediction intervals come for free (`hilo(fcasts)`). Instead the chapter strips it (`fcasts$.mean`) and plots only the point forecast. The chapter's punch line — "the ARIMA counterfactual is a *doomsday* trajectory" — is far more believable with a 95 % band that shows the trajectory's uncertainty as it stretches out 12 years. **Fix:** swap `geom_line` for `autoplot(fcasts, prop99_ts)`, or build the ribbon manually with `hilo(fcasts, level = c(80, 95)) |> unpack_hilo(...)` and `geom_ribbon`. This is a 5-line change with high pedagogical payoff: at $h = 12$, the 95 % band on an ARIMA(1,2,0) of a doubly-differenced series will be enormous and will *visually* make the point that "in-sample fit does not constrain out-of-sample uncertainty".

6. **`02-interrupted-time-series.qmd:82-91` — linear-trend SE is not HAC.** Chapter 3 (`03-basic-diff-in-diff.qmd:243-244, :247`) explicitly applies `sandwich::vcovHAC` to a 10-period regression with the argument "short time series typically exhibit autocorrelation". Chapter 2 fits a 19-period regression with the same problem but uses default OLS SEs in `ms_pretty()`. The $p < 10^{-5}$ claim at `:93` is likely too small. **Fix:** pass `vcov = sandwich::vcovHAC` to `ms_pretty()` (the helper at `R/table_helpers.R:37, :44` already takes a `vcov=` argument), or — more honestly — say that the slope point estimate is fine for ITS but the standard error question is the wrong one because ITS uncertainty is dominated by out-of-sample forecast variance, not in-sample fit SE.

7. **`02-interrupted-time-series.qmd:209-211` — pitfall is phrased correctly but the diagnosis is incomplete.** The "AICc minimises *in-sample* fit" sentence is right, but the deeper reason ARIMA(1,2,0) misbehaves here is structural: double differencing removes two integration orders, so the model has no level anchor and any noise in the last few pre-period observations gets extrapolated as a permanent change in slope. (The end of the pre-period is 1985 = 103, 1986 = 99.7, 1987 = 97.5, 1988 = 90.1 — i.e. the slope itself is accelerating downward in the final three years.) **Fix:** add one sentence: "More technically: with $d = 2$ the model has no mean reversion, so the *slope* implied by the last few pre-period observations becomes the permanent slope of the forecast. With only three observations defining that slope (1986-1988), the forecast is extremely sensitive to the pre-period endpoint."

## Code & reproducibility issues

1. **`02-interrupted-time-series.qmd:155-165, 169-177` — cached output disagrees with prose.** The cached `_freeze/.../html.json` shows `Model: NULL model` and `mean(ce_arima) = NA`. The prose claims `(1,2,0)` and `+4.5`. The published HTML at `_book/02-interrupted-time-series.html:1151-1152, :1167` shows the broken output. Fix per Methodology #1, then re-run `quarto render --to html` to refresh the freeze, and the per-chapter download ZIP rebuilt by `R/build_chapter_zips.R` will also be repaired.

2. **`02-interrupted-time-series.qmd:181-203` — `fig-its-arima` has a legend entry for a line it does not draw.** Because `fcasts$.mean` is all-NA in the cached run, `geom_line(aes(y = counterfactual, ...), na.rm = TRUE)` plots nothing. The legend still shows "ARIMA counterfactual" with no swatch (verified in `_freeze/.../figure-html/fig-its-arima-1.png`). Fixing the ARIMA fit fixes this automatically; no separate change needed.

3. **`02-interrupted-time-series.qmd:59` — `year0` is computed and described but never used.** Introduced at `:59`, advertised at `:45` and `:62` ("any model fit on the pre-period extrapolates naturally across `year0 > 0`"), then ignored. The actual regression at `:86` fits `cigsale ~ year`, and the ARIMA call uses tsibble's built-in `year` index. **Fix:** either remove the `mutate(year0 = ...)` and trim the prose, or actually use it in the OLS — `lm(cigsale ~ year0, ...)` — which would centre the intercept on 1989 and make the regression table easier to read for the audience.

4. **`02-interrupted-time-series.qmd:28` — `set.seed(42)` is set but nothing in the chapter is stochastic.** `lm()` and `fable::ARIMA()` with deterministic optimisation are both reproducible without a seed. Harmless, but if the fix to issue Methodology #1 brings in `stepwise = FALSE`, the seed is still irrelevant (the search is deterministic). Either keep it as boilerplate or drop it; just don't oversell it.

5. **`02-interrupted-time-series.qmd:31, :127, :202` — `theme_set()` is overridden by `+ theme_minimal()` inside each plot.** The chapter sets a custom transparent-background theme at `:32-42` and then both `ggplot` calls append `+ theme_minimal()`, which silently undoes the transparent background and the `#94a3b8` axis colour. (Check the cached PNGs: they have a white panel background, which is the `theme_minimal()` default, not the transparent background the setup chunk asked for.) **Fix:** drop the trailing `theme_minimal()` from `:127` and `:202`; the global `theme_set()` already handles it.

6. **`02-interrupted-time-series.qmd:99` — `predict()` on a `tsibble`-derived `as_tibble()` works, but `predict(fit_growth, newdata = prop99_ts)` at `:115` is called on a `tsibble`.** That happens to work because `predict.lm` coerces, but it is fragile; if a future tsibble version restricts coercion it will silently break. **Fix:** `predict(fit_growth, newdata = as_tibble(prop99_ts))` at `:115`.

7. **`02-interrupted-time-series.qmd:156-157` — `#| message: false` and `#| warning: false` on the `fit-arima` chunk hid the very warning that explains the bug.** During authoring this is the wrong default. **Fix:** at minimum, remove `warning: false` from that chunk so future renders break loudly if the search fails.

## Cross-chapter consistency issues

1. **`02-interrupted-time-series.qmd:7, :130, :219` vs `01-introduction.qmd:259, :87-88` — references to "chapter 1" are correct.** The renumbering of `03-rd-in-time.qmd` → deleted has been propagated. The roadmap in ch. 1 (`:259`) and the row labels in ch. 1's estimator table (`:87-88`) both correctly point at chapter 2 as ITS.

2. **`03-basic-diff-in-diff.qmd:1-12` — no inward transition from ch. 2.** Chapter 3 opens straight into "DiD picks one control state". A single sentence linking back to ch. 2's punch line would close the loop: "Chapter 2 ended with two ITS variants giving wildly different answers because *neither used information outside California*. The simplest fix is to pair California with a single comparison state and call the gap a counterfactual." **Fix:** add that sentence as the first paragraph of `03-basic-diff-in-diff.qmd` §1.

3. **`02-interrupted-time-series.qmd:219` — the outward transition mentions chapters 3, 4, 5 but skips chapter 6 (scpi) and chapter 7 (Bayesian spatial SC).** Given that the chapter's main complaint is "ITS does not give a credible uncertainty estimate", chapter 6 (which is specifically about *prediction intervals* on synthetic control) is the most natural follow-up to issue Methodology #5. **Fix:** extend the closing sentence to "...chapter 6 attaches prediction intervals to the synthetic-control point estimate, which is the natural counterpart to the ARIMA forecast band we declined to compute here".

4. **`02-interrupted-time-series.qmd:215` — "AICc-selected ARIMA(1,2,0)".** This claim depends on the auto-search actually running. Until Methodology #1 is fixed, the rendered book shows `NULL model` here, so the cross-chapter consistency claim ("AICc selected") is unsupported. After the fix, switch to "the AICc-minimising non-seasonal order on this 19-observation series is ARIMA(1,2,0); we fit that order explicitly" — that is honest and matches what the code will do.

5. **Notation.** $Y_{it}$ vs $Y_{1t}$: ch. 1 uses the general index $Y_{it}$ (`01-introduction.qmd:25-30`) and the chapter-specific $Y_{1t}$ for California (`:73-75`). Ch. 2 only uses $Y_{1t}$ (consistent with ch. 1's California specialisation). The prompt's expectation of "uses $\tau$" is met by ch. 1 only — ch. 2 never writes $\tau$, using `ATT_{ITS-growth}` and `ATT_{ITS-ARIMA}` instead. That is fine and arguably clearer, but worth noting in case the audit standard is "every chapter uses $\tau$ at least once". If so, one sentence in §6 ("the two ITS estimators give $\tau_{ITS-growth} = -28.3$ and $\tau_{ITS-ARIMA} = +4.5$") would tie the notation together.

## Writing & structure issues

1. **`02-interrupted-time-series.qmd:130-134, :209-211` — there are two "common pitfall" boxes (one per method) but no chapter-level recap.** The closing §6 functions as both recap and segue, which is fine, but a one-line bullet-list "**Recap.**" at the end of §6 mirroring the recap line at `03-basic-diff-in-diff.qmd:141` would tighten the rhetorical structure across chapters.

2. **`02-interrupted-time-series.qmd:88-91` — `ms_pretty()` is called with `coef_map=` but no caption.** Per `CLAUDE.md` the caption mechanism is `tbl-cap:` in the chunk header — that *is* present at `:84`, so this is fine. Just confirming, because the chapter does not pass `title=` to `ms_pretty()` (correctly).

3. **`02-interrupted-time-series.qmd:106` — claim "the dashed counterfactual continues the gentle pre-period decline".** Fine for the growth-curve plot (the dashed line is gentle), but the figure actually extrapolates the dashed line *backward* to 1970 as well (the dashed line spans the full 1970–2000 range, not just $\ge 1989$). That is a minor cosmetic mismatch with the prose's "extrapolated to 2000". **Fix:** in the growth-curve plot at `:113-127`, mask `counterfactual` to `year >= 1989` (or use two `geom_line` calls — one for in-sample fit, one for extrapolation), so the reader sees the visual distinction between *fit* and *extrapolation*.

4. **`02-interrupted-time-series.qmd:18` — "tsibble for time-indexed data frames" is fine, but the sentence buries the fact that the rest of the chapter depends on `as_tsibble()`.** Consider promoting the sentence "ITS in this chapter is a fable workflow: fit on a tsibble-filtered pre-period, forecast h years out, average the gap" to its own line for navigability.

5. **`02-interrupted-time-series.qmd:223-224` — "Further reading" has two entries; one more for short-pre-period ARIMA caveats would help.** The prompt mentions Wagner. The Bernal-Cummins-Gasparrini reference at `:223` already covers the practitioner side. Wagner et al. (2002), "Segmented regression analysis of interrupted time series studies in medication use research", J. Clin. Pharm. Ther., is the canonical companion. It is *not* currently in `references.bib`. **Fix:** add Wagner 2002 to `references.bib` and cite it here as the segmented-regression complement to Bernal.

6. **`02-interrupted-time-series.qmd:14` — "The two estimates disagree dramatically, and the disagreement is the lesson."** This is the chapter's thesis. Good. But the rendered chapter does not currently exhibit the disagreement (one of the two ATTs is `NA`). Once the ARIMA fix lands, the thesis is restored.

## Prioritized fix list

### P1 (must-fix before next render — chapter currently does not show its central claim)

- **Fix the ARIMA fit.** Replace `:160-162` with `model(timeseries = ARIMA(cigsale ~ pdq(1,2,0) + PDQ(0,0,0)))`. Re-run `quarto render --to html` and `quarto publish gh-pages --no-prompt --no-render` so the published book and the chapter-2 download ZIP both stop showing `Model: NULL model` and `[1] NA`. (Verified locally: this yields `report()` text matching the prose and `mean(post - .mean) = 4.549`.) See Methodology #1, Code #1, Code #2.
- **Stop hiding warnings on the ARIMA chunk.** Remove `#| warning: false` at `:157` so failures are visible. See Code #7.
- **State the identification assumption explicitly.** One bold "**Identification.**" sentence early in §1 saying the pre-period DGP must continue into the post-period absent treatment. See Methodology #3.

### P2 (improves credibility and pedagogy substantially)

- **Add residual diagnostics.** A `gg_tsresiduals(fit_arima)` plot and a Ljung-Box test after `:165`, ideally before the "we then forecast 12 years out" paragraph. See Methodology #4.
- **Show ARIMA prediction intervals.** Replace the `.mean`-only forecast plot at `:181-203` with one that adds an 80/95 % ribbon from `hilo(fcasts)`. Makes the "doomsday counterfactual" framing visceral. See Methodology #5.
- **Fix the dangling `year0`.** Either use it in the OLS at `:86` or remove its setup at `:59` and the prose at `:45, :62`. See Code #3.
- **Add Wagner et al. (2002) to the bibliography and cite it in Further Reading.** See Writing #5.
- **Add the inward transition in ch. 3.** A one-sentence opening that says "ch. 2's ITS gave two estimates and could not arbitrate between them — that motivates bringing in a control state". Edit lives in `03-basic-diff-in-diff.qmd:5-9`, not in ch. 2. See Cross-chapter #2.

### P3 (polish)

- **HAC SEs (or a deliberate decision not to use them) for the linear-trend table.** See Methodology #6.
- **Trim the redundant `+ theme_minimal()` at `:127, :202`** so the global transparent theme applies. See Code #5.
- **Mask the dashed growth-curve line to the post-period (or split fit vs extrapolation).** See Writing #3.
- **Sharpen the "ARIMA misbehaves" pitfall** with the "$d=2$ has no level anchor" sentence at `:209-211`. See Methodology #7.
- **Add a one-line `**Recap.**`** at the end of §6 to mirror ch. 3's structure. See Writing #1.
- **Drop the `set.seed(42)` at `:28`** (no stochastic step in the chapter) or leave as boilerplate but do not mention it. See Code #4.
- **Optionally extend the closing handoff at `:219`** to also name chapter 6 (prediction intervals) and chapter 7 (Bayesian spatial). See Cross-chapter #3.
