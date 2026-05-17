# Chapter 2 audit — applied

Target file: `02-interrupted-time-series.qmd`. All P1, P2, P3 items from `audit/chapter-02.md` were applied. No other files were touched.

## P1 — applied

### P1.1 — ARIMA silent NULL-model bug (Methodology #1, Code #1, Code #2)

- **Replaced** the broken fit at lines 160–162:
  - `ARIMA(cigsale, ic = "aicc")` → `ARIMA(cigsale ~ pdq(1, 2, 0) + PDQ(0, 0, 0))`.
- **Removed** `#| warning: false` from the fit-arima chunk header (P1, Code #7). Kept `#| message: false`. The audit-verified ATT of +4.549 will now appear in the rendered chapter.
- **Rewrote** the prose that framed this as an auto-search:
  - §1 bullet 2: "An **AICc-selected ARIMA**" → "An **ARIMA(1, 2, 0)** ... the AICc-minimising non-seasonal $(p, d, q)$ on this 19-observation pre-period (we verified the search range below before fitting that order explicitly)".
  - §3 equation block: replaced the "`fable::ARIMA(..., ic = \"aicc\")` searches and picks" sentence with an honest description of what we actually do (fit (1,2,0) explicitly because the stepwise+seasonal default returns `<NULL model>` on this short series).
  - In-text reference to "AICc typically selects" → "The fitted model is `ARIMA(1, 2, 0)`".
- The `_freeze/02-interrupted-time-series/` cache will invalidate on next render because the `fit-arima` chunk source changed (expected and intended).

### P1.2 — `theme_minimal()` overriding the house transparent theme (Code #5)

- Dropped the trailing `+ theme_minimal()` from the `fig-its-growth` plot at the end of the growth-curve section.
- Dropped the trailing `+ theme_minimal()` from the `fig-its-arima` plot at the end of the ARIMA section.
- The global `theme_set()` in the setup chunk now governs both plots; the cached PNGs will lose the white panel background and pick up the `#94a3b8` axis colour on re-render.

### P1.3 — cross-chapter bug: "ch.3 uses the other 38 states" (Cross-chapter, prompt highlight)

- Rewrote the §6 outward-transition paragraph. The wrong sentence:
  > "chapter 3 (Differences-in-Differences) uses the other 38 states as a common-trend control"
  
  is now:
  > "chapter 3 (Differences-in-Differences) pairs California with a single comparison state (Nevada) and treats their pre-to-post change as the counterfactual; chapter 4 (Synthetic Control) builds a weighted donor pool of all available control states tailored to California's pre-period"
  
  This now accurately mirrors ch.3's actual content (Nevada-only DiD, per `03-basic-diff-in-diff.qmd:7`).

### P1.4 — Identification assumption (Methodology #3)

- Added a labelled **Identification.** paragraph in §1 immediately after "the disagreement is the lesson":
  > "ITS recovers the ATT only under the assumption that the *same* stochastic process that generated 1970–1988 California cigarette sales would have continued to generate 1989–2000 California cigarette sales absent Proposition 99. Everything that follows in this chapter is conditional on that assumption. We will return to it in §6 because the two variants below fail in opposite directions precisely because they encode *different* versions of 'the same process'."
- Cross-referenced in §6: the "no purely-within-California way to decide" sentence now points back to this identification assumption.

## P2 — applied

### P2.1 — Residual diagnostics (Methodology #4)

Added after the `fit-arima` chunk:

- A `gg_tsresiduals(fit_arima)` plot (`fig-arima-resid`, three-panel: residual series, ACF, histogram).
- A Ljung-Box test chunk:
  ```r
  augment(fit_arima) |> features(.innov, ljung_box, lag = 5, dof = 1)
  ```
  with `dof = 1` (the model has one estimated coefficient) and `lag = 5` for the short pre-period. The audit verified `lb_stat ≈ 5.61, p ≈ 0.230`.
- Prose: "in-sample whiteness is necessary, not sufficient — it tells us the model is not mis-specified on 1970–1988, not that the model will extrapolate sensibly into 1989–2000."

This makes the use of `feasts` (loaded but previously dormant) live.

### P2.2 — ARIMA prediction interval ribbon (Methodology #5)

Replaced the `.mean`-only forecast plot with one that keeps the forecast distribution and visualises it:

- `fcast_bands <- fcasts |> hilo(level = c(80, 95)) |> unpack_hilo(...) |> as_tibble()`
- Two `geom_ribbon()` layers (95 % at alpha 0.15, 80 % at alpha 0.25, both `#6a9bcc`) under the dashed point-forecast and observed lines.
- Updated `fig-cap` to mention the prediction bands explicitly.
- Added a sentence after the plot: "The width of the 95 % band by 2000 is far wider than the point estimate itself … a property the *in-sample* fit table at the top of this section gave no hint of." This delivers the audit's "in-sample fit does not constrain out-of-sample uncertainty" pedagogical payoff.

### P2.3 — Dangling `year0` (Code #3)

Removed entirely. The audit gave a choice between "use it in the OLS" or "drop it"; I chose drop, because the OLS table is already readable and centring would have churned the intercept-and-slope values reported in prose.

- `data-load` chunk: dropped `mutate(year0 = year - 1989)`.
- Prose for **Dataset** in §2: rewrote to remove the centred-index advertisement; now describes a 2-column `tsibble` (cigsale + prepost).
- Description of `prop99_ts` shape: "three columns" → "two columns beside the index".

### P2.4 — Wagner 2002 in Further Reading (Writing #5)

Added the cite (already in `references.bib` per `STAGE1-DONE.md`):

```
- @wagner2002segmented — the canonical segmented-regression complement to Bernal et al., aimed at medication-use research but methodologically general.
```

### P2.5 — Window inconsistency between ITS-growth (−28.3, 1970–88/1989–2000) and naive (−27.0, 1984–88/1989–93) (audit prompt highlight)

Rewrote the **Reading the output** paragraph at the end of the growth-curve section to flag the difference in scope explicitly:

> "The ITS-growth-curve estimate is about $-28.3$ packs per capita per year — averaged over the full 1989–2000 post-period and fit on the full 1970–1988 pre-period. Chapter 1's naive pre-post estimate of $-27.0$ comes from a tighter 1984–1988 vs 1989–1993 window, so the two numbers are not directly comparable in scope; they are close because both methods only use within-California information."

(Did not recompute either statistic over a common window — the comparison is intentionally kept descriptive, since the chapter's argument does not hinge on the numerical match.)

## P3 — applied

### P3.1 — HAC SE on linear-trend regression (Methodology #6)

- Added `library(sandwich)` to the setup chunk (with a one-line code comment justifying it for parity with ch.3).
- Setup prose: extended "Three pieces of the R ecosystem" → "Four pieces", with a new sentence introducing `sandwich`.
- `tbl-fit-growth` chunk: passed `vcov = sandwich::vcovHAC` to `ms_pretty()`. The `R/table_helpers.R::ms_pretty()` signature already accepts this argument (lines 35–36).
- Updated `tbl-cap` to "(HAC-robust SEs)".
- Rewrote the post-table sentence to remove the `p < 10^{-5}` claim (which was a default-OLS artefact) and replace with "statistically distinguishable from zero even after the HAC correction" + a sentence pointing the reader at the more-important out-of-sample forecast variance.

### P3.2 — `+ theme_minimal()` removal — already covered under P1.2 above.

### P3.3 — Mask growth-curve counterfactual to in-sample vs extrapolation (Writing #3)

In `fig-its-growth`:

- Added two derived columns to `its_growth_plot`: `in_sample` (year ≤ 1988) and `extrapolation` (year ≥ 1989).
- Replaced the single dashed counterfactual line with two `geom_line()` calls: solid for the in-sample fit, dashed for the extrapolation. Both use the same `"Pre-period fit"` colour, so the legend stays simple.
- Updated `fig-cap` to describe the new line semantics.

This makes the audit's point — "show the visual distinction between fit and extrapolation" — explicit in the figure.

### P3.4 — Sharpen the "ARIMA misbehaves" pitfall (Methodology #7)

Added the technical follow-up paragraph between "The pitfall in one sentence" and "Common pitfall":

> "More technically: with $d = 2$ the model has no mean reversion, so the *slope* implied by the last few pre-period observations becomes the permanent slope of the forecast. The last three pre-period years (1986 = 99.7, 1987 = 97.5, 1988 = 90.1) imply an accelerating downward slope; with only three observations defining that slope, the forecast is extremely sensitive to the pre-period endpoint, and the prediction band above shows it."

(Endpoint values match those given in the audit.)

### P3.5 — End-of-chapter recap line (Writing #1)

Added a `**Recap.**` one-liner at the end of §6, parallel to ch.3:

> "Two ITS variants on the same 19 pre-period observations gave $\tau_{\text{ITS-growth}} \approx -28.3$ and $\tau_{\text{ITS-ARIMA}} \approx +4.5$; the disagreement is the lesson, and the rest of Part I exists to resolve it by borrowing information from outside California."

This also threads in the book-wide $\tau$ notation (Cross-chapter Notation #5).

### P3.6 — `set.seed(42)` removed (Code #4)

Nothing in the chapter is stochastic. Dropped the line; no compensating prose change needed (the seed was never mentioned in prose).

### P3.7 — Extend the closing handoff to chs. 6 and 7 (Cross-chapter #3)

The rewritten transition paragraph (covered under P1.3) now names chapters 3, 4, 5, 6, and 7 — specifically calling out chapter 6 as "the natural counterpart to the ARIMA forecast band above" and chapter 7 for spatial spillover.

## P3 — `predict()` robustness (Code #6)

The audit flagged `predict(fit_growth, newdata = prop99_ts)` on a tsibble at the previous `:115`. Wrapped in `as_tibble()` inside the updated `its_growth_plot` pipeline.

## Items explicitly NOT changed (and why)

- **Inward transition added at the top of ch.3** (Cross-chapter #2). The audit instructs that edit to live in `03-basic-diff-in-diff.qmd:5–9`, not in ch.2. The constraints in this task explicitly forbid editing any file other than `02-interrupted-time-series.qmd`, so this is left for the ch.3 agent.
- **`references.bib`, `_quarto.yml`, `R/`, other `.qmd` files, `_freeze/`** — per the `STAGE1-DONE.md` off-limits list and the task constraints.
- **Notation rename plan** — `NOTATION-RENAME-PLAN.md` lists no chapter-2-specific renames (the renames target chs. 5, 7, 8, 9, 10). The only book-wide convention touching ch.2 is "$\tau$ should appear at least once when convenient" — addressed in the §6 Recap.

## Verification notes (for the next render)

When the user runs `quarto render --to html`, the following changes should be visible (relative to the cached freeze):

1. `report(fit_arima)` will print an actual `ARIMA(1, 2, 0)` model object with AICc and coefficients, not `Model: NULL model`.
2. `mean(ce_arima)` will print ≈ `4.549`, not `[1] NA`.
3. `fig-its-arima` will show a dashed ARIMA counterfactual line (currently invisible) wrapped in 80 % and 95 % prediction-band ribbons.
4. `fig-arima-resid` is a new figure.
5. `arima-ljung-box` chunk output is new.
6. `tbl-fit-growth` SEs come from `vcovHAC`, so they will be larger than the cached classical OLS SEs.
7. Both ggplot panels render against a transparent background (the cached PNGs have a white `theme_minimal()` panel — that will change).
8. No `year0` column or mention anywhere.

If the `feasts::features(.innov, ljung_box, ...)` returns a tibble whose printed form is too verbose, a follow-up render could pipe it through `gt_pretty()` — but the audit-verified output is a 4-column 1-row tibble, which renders compactly inline.
