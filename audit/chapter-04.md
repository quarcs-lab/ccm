# Chapter 4 Audit — Classical Synthetic Control

File: `/Users/carlosmendez/Documents/GitHub/ccm/04-classical-synthetic-control.qmd` (367 lines)
Built artifact reviewed: `/Users/carlosmendez/Documents/GitHub/ccm/_book/04-classical-synthetic-control.html`
Cached chunks: `_freeze/04-classical-synthetic-control/execute-results/{html,tex,epub}.json`

## 1. Headline verdict

The chapter is in solid shape — methodology is correct, the canonical ADH (2010) Proposition 99 replication lands almost exactly on the published numbers, and the prose narrative is clear. The two-track exposition (donor weights vs V-matrix weights) is well done. The main fixable issues are (a) **three deprecation / "ignoring unknown labels" stderr leaks** from `tidysynth` plot helpers that bleed into the rendered HTML (Phase 1 flagged two — there is in fact a third); (b) one **stale chapter cross-reference** ("RDD chapter" no longer exists); (c) one **theme inconsistency** in the V-matrix bar chart; and (d) a few **content gaps** — no leave-one-out / in-time-placebo robustness check, and the "Common pitfall" callout only covers V-matrix interpretation, missing the canonical convex-hull / extreme-weights pitfalls. None of these change the substantive conclusions.

## 2. Numbers vs the published paper

Verified against cached HTML output, side by side with ADH (2010) Table 1 / Table 2:

| Quantity | Chapter | ADH 2010 (published) | Match? |
|---|---|---|---|
| 1989–2000 average ATT (packs/capita) | −18.85 (line 214, 251, 354) | ≈ −19 (Fig. 2; their Table 4 reports −19 packs over 1989–2000) | yes, within rounding |
| Utah donor weight | 0.342 | 0.334 | yes |
| Nevada donor weight | 0.238 | 0.234 | yes |
| Montana donor weight | 0.209 | 0.199 | yes |
| Colorado donor weight | 0.149 | 0.164 | yes |
| Connecticut donor weight | 0.062 | 0.069 | yes |
| MSPE ratio rank | 1 of 39, p ≈ 0.026 (line 297) | 1 of 39 (Fig. 6 in ADH) | yes |
| Synthetic California 1988 cigsale | 91 vs CA 90.1 (HTML balance table) | tight pre-period match in ADH Table 1 | yes |

The point estimate and donor weights are within sampling / IPOP-tolerance noise of the published replication. The chapter is faithful to ADH (2010).

## 3. Issues by severity

### Critical — must fix before next publish

**3.1 — Three stderr / deprecation warnings leak into rendered HTML.** Phase 1 noted two; there are actually three. The hook for fixing all of them is the same: set `#| warning: false` on the offending chunks (these warnings originate inside the `tidysynth` package, so we cannot fix them at the source).

- `04-classical-synthetic-control.qmd:217–222` — chunk `fig-sc-trends` (`plot_trends(prop99_syn)`). Rendered HTML (line 1753): *"Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0 … the deprecated feature was likely used in the tidysynth package."*
- `04-classical-synthetic-control.qmd:243–249` — chunk `fig-sc-differences` (`plot_differences(prop99_syn)`). Rendered HTML (line 2311): *"Ignoring unknown labels: colour : "", linetype : ""."*
- `04-classical-synthetic-control.qmd:301–307` — chunk `fig-sc-mspe-ratio` (`plot_mspe_ratio(prop99_syn)`). Rendered HTML (line 2926): *"Ignoring unknown labels: colour : ""."*

**Concrete edit (all three chunks):** add `#| warning: false` to each chunk header. Example for `fig-sc-trends`:

```r
```{r}
#| label: fig-sc-trends
#| fig-cap: "Synthetic Control: California (observed) vs synthetic California (weighted donor combination)."
#| fig-width: 8
#| fig-height: 5
#| warning: false
plot_trends(prop99_syn)
```
```

Suppressing warnings here is justified — they're upstream package noise, not authored code. (Alternative: set `knitr::opts_chunk$set(warning = FALSE)` for the chapter in the `setup` chunk on line 51, since the `fit-syn` chunk already uses `warning: false` precisely for this reason. A chapter-wide flag is cleaner than three per-chunk flags.)

**3.2 — Stale "RDD chapter" reference.** `04-classical-synthetic-control.qmd:76` reads *"Unlike the ITS, RDD, and DiD chapters …"* but the RDD-in-time chapter was deleted from the book (git status shows `D 03-rd-in-time.qmd`; `_quarto.yml` no longer lists it). Concrete edit: replace **"ITS, RDD, and DiD chapters"** with **"ITS and DiD chapters"**.

### Major — fix soon

**3.3 — `theme_minimal()` clobbers the chapter theme on `fig-sc-predictor-weights`.** `04-classical-synthetic-control.qmd:187`. The chapter sets a transparent / grey-text theme via `theme_set(theme_minimal(...) + theme(...))` in the setup chunk (lines 63–73), but the V-matrix bar chart appends `+ theme_minimal()` at the end of its pipeline, **overwriting** the chapter's customised theme. In dark mode this means white background panel + dark axis text that won't read. Concrete edit: delete the trailing `+ theme_minimal()` on line 187 — the chapter-wide `theme_set` already supplies the right base.

**3.4 — No leave-one-out / in-time-placebo robustness check.** The task brief explicitly asks whether *in-time* and *in-space* placebos are present. The chapter does the **in-space** placebo (the donor-as-treated permutation, §"Inference via placebo permutation" lines 254–279), which is the headline robustness story. But it does **not** include:

  - A **leave-one-donor-out** check (refit removing each of the five high-weight states and showing the ATT is stable). ADH 2010 Fig. 3 / Table 3 do this and it is a load-bearing robustness result.
  - An **in-time placebo** (a "backdated treatment" check that pretends 1978 was the intervention year — should produce a gap near zero).

These don't both need to be in-chapter; **at minimum, mention both in the "Further reading" or recap as the natural next robustness checks**, with a one-line description. Even better, add a short "Robustness" subsection between §4.11 (MSPE) and §4.12 (Inspecting the nested object) that does the leave-one-out for the single highest-weight donor (Utah) — three lines of code with `dataprep`-style donor filtering before re-running the pipeline.

**3.5 — "Common pitfall" callout is incomplete.** Only one pitfall appears, on V-matrix interpretation (line 195). The classical synthetic-control pitfalls that an undergrad audience should be warned about are:

  - **Interpolation bias / convex hull.** If the treated unit's predictors lie outside the convex hull of the donor predictors, `tidysynth` will silently extrapolate — and the optimal weights will pile onto two or three extreme donors. (See ADH 2015; Abadie 2021, p. 408.)
  - **Sparse / extreme weights.** A weight vector concentrated on 2–3 donors is fragile to leave-one-out perturbations.
  - **Donor-pool contamination.** If a donor state was also treated (e.g., raised cigarette taxes during 1989–2000), its inclusion biases the synthetic counterfactual toward the treated condition. ADH's own analysis excludes states that adopted large tax hikes in the post-period.

Concrete edit: add a second `**Common pitfall.**` paragraph either at the end of §"Donor weights and predictor weights" or in a new short §"What can go wrong" before the recap, covering the three above. Two-sentence treatments of each are enough.

### Minor — quick polish

**3.6 — "Western/sunbelt" mislabels four Mountain-West states.** Lines 157 and 355 describe Utah, Nevada, Montana, Colorado as *"Western/sunbelt"*. Sunbelt conventionally refers to AZ/NM/TX/FL/CA/GA/SC (low-latitude warm-climate states). Four of the five donors are **Mountain West**, not sunbelt. Concrete edit: replace *"Western/sunbelt"* with *"Mountain-West"* in both places.

**3.7 — Recap row about donor states says "five" but the donor table prints eight.** The donor-weights table (lines 134–142) does `head(8)`. The recap row (line 355) and the §"Donor weights" prose (line 157) correctly point out that essentially only five states get non-trivial weight. This is internally consistent but a reader skimming the table sees eight rows. Concrete edit: optional — change `head(8)` to `head(5)` (the bottom three rows are noise, the prose only refers to the top five), or add a one-line comment in the code block that the bottom three are near-zero.

**3.8 — `mean(sc_post$dif)` prints a raw numeric, not a sentence.** Line 211 outputs `[1] -18.84561` as a code-block console echo. The prose immediately below (line 214) reads "*The Synthetic Control ATT is approximately $-18.85$ packs/capita …*". An inline R reference would tie the prose to the live computation. Concrete edit: optional — replace line 214's hard-coded `$-18.85$` with `` `r round(mean(sc_post$dif), 2)` `` (use `format()` if you need a fixed two-decimal display), so the prose number can't drift away from the computation. The recap row on line 354 should be updated identically.

**3.9 — Nested-tibble introspection block.** The §"Inspecting the nested tidysynth object" section (lines 311–347) is pedagogically *useful*, not distracting — it makes the point that `tidysynth` objects are tidy all the way down, unlike the original `Synth::dataprep` S4 objects. The italicised aside on line 315 explaining why the chunk intentionally uses the default tibble printer is a nice touch. **Keep as is.**

**3.10 — `set.seed(42)` on line 59 is harmless but uninformative.** `kernlab::ipop` (the QP solver underlying `tidysynth::generate_weights`) is deterministic, as is the placebo refit loop. No randomness is consumed in the chapter. Not a bug — but if a reader copies the seed-setting habit assuming reproducibility hinges on it, they'll be misled. Concrete edit: optional — drop the `set.seed(42)` line, or add a one-line comment that it's there for consistency with other chapters rather than required by this pipeline.

**3.11 — V-matrix percentages in prose vs table.** Line 158: *"`cigsale_1975` and `cigsale_1980` together get roughly 88% of the predictor weight"* — verified: 0.468 + 0.412 = 0.880. Line 158: *"The four behavioural and demographic covariates get less than 9% combined."* — the table shows lnincome 0.055, retprice 0.020, age15to24 0.007, beer 0.001-ish, sum ≈ 0.083, plus cigsale_1988 0.037 = 0.120. The "less than 9%" claim *excludes* `cigsale_1988`, which is correct in context but a hurried reader might not notice. Concrete edit: optional — say "**the four non-lagged covariates** get less than 9% combined" to be explicit that `cigsale_1988` is excluded.

## 4. Cross-chapter consistency

- **Hand-off from ch.3** (`03-basic-diff-in-diff.qmd:144`) is clean — DiD chapter ends with *"Synthetic Control (chapter 4) is the principled response: instead of one control state, blend many states into a weighted 'synthetic California'"*. Chapter 4's opening on line 7–9 echoes that framing directly. Good.
- **Hand-off to ch.5** (`04-classical-synthetic-control.qmd:361`) is one sentence: *"In chapter 5 we hand the same donor information to a Bayesian model …"*. Chapter 5 opens with a complementary framing (BSTS counterfactual decomposition). Consistent. Could be slightly fuller — one sentence on *why* a Bayesian credible interval is a substantive upgrade rather than a methodological tangent — but acceptable as-is.
- **Notation.** Chapter 2 introduces $Y_{1t}$, $\widehat{Y_{1t}(0)}$, $t^*$, ATT (lines 70–78). Chapter 4 reuses exactly that notation on lines 33–45. No conflict. The introduction of $X_1$, $X_0$, $V$, $w$, $\mathcal{W}$ is new to this chapter but standard.
- **Dataset framing.** Line 76 emphasises that, unlike earlier chapters, this one uses the full 39-state panel — that's a useful and accurate signal, modulo the RDD reference (issue 3.2).
- **Citations.** `@abadie2010synthetic` (the JASA paper) is cited on lines 214, 365 and resolves correctly in `references.bib:15–24`. `@abadie2021using` (JEL review) cited on line 366, resolves at `references.bib:26–35`. `@dunford2024tidysynth` cited on line 367, resolves at `references.bib:75–81`. All three are wired up correctly. **No missing citations.**

## 5. Code reproducibility & freeze cache

- `_freeze/04-classical-synthetic-control/execute-results/html.json` is present, so on a fresh render Quarto will reuse the cached chunk outputs and not re-run the IPOP solver (which is the slow stage). The numerical claims in §2 of this audit are read straight from that cached HTML — they will not drift on the next render.
- The `freeze: auto` policy in `_quarto.yml:9–10` means the cache will invalidate the moment any chunk source changes. Edits 3.1 (adding `warning: false`), 3.3 (removing `theme_minimal()`), 3.4 (new robustness chunk), 3.7 (`head(5)`), 3.8 (inline R reference) will each trigger a re-execution of the affected chunk. Total cost on a warm render: ≈ 30–60 s for the `fit-syn` chunk if it gets touched, < 5 s for the plot chunks.
- The pipeline chaining `synthetic_control() |> generate_predictor() |> ... |> generate_weights() |> generate_control()` (lines 93–125) is correct and follows the canonical tidysynth recipe from the package vignette. `generate_placebos = TRUE` is set, which is necessary for the placebo / MSPE-ratio inference downstream. `optimization_window = 1970:1988` correctly uses the full pre-period for fit (not just 1980:1988 used for predictor averaging) — this is a subtle but correct choice.

## 6. Suggested edit order (smallest blast radius first)

1. Issue 3.1 — add `warning: false` to three chunks (or set chapter-wide in the setup chunk). Removes all three stderr leaks from rendered HTML.
2. Issue 3.2 — one-word fix: drop "RDD," from line 76.
3. Issue 3.3 — delete `+ theme_minimal()` from line 187.
4. Issue 3.6 — replace "Western/sunbelt" with "Mountain-West" on lines 157 and 355.
5. Issue 3.5 — add a 2–3 sentence "Common pitfalls" block on convex hull / extreme weights / donor-pool contamination.
6. Issue 3.4 — add a "Robustness" subsection with a leave-one-out check on Utah (or a one-paragraph pointer to the canonical ADH 2010 checks if a code addition is too costly).
7. Items 3.7, 3.8, 3.10, 3.11 — minor polish, do at leisure.

After 1–3 the chapter will render cleanly (no warning leaks, no theme glitch). 4–6 are quality / completeness improvements. After all of 1–6, re-render with `quarto render --to html` and re-publish via `quarto publish gh-pages --no-prompt --no-render` per CLAUDE.md.
