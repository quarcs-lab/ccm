# Audit — Comparative Causal Metrics

Audit of the in-progress Quarto book *Comparative Causal Metrics* (preface + 10 method chapters + references), conducted against the working tree at commit `1718668` (branch `main`, 2026-05-17) and the live site at <https://quarcs-lab.github.io/ccm/>. The audit covered methodology, code/reproducibility (cache vs prose, freeze cache vs `_book/` HTML), cross-chapter notation, narrative arcs, bibliography, theming, and infrastructure. Full per-chapter reports live in `audit/chapter-*.md`; this file synthesizes and prioritizes them.

---

## 1. Executive summary

The book is fundamentally sound — methodology is correct in every chapter, prose is good, Quarto plumbing is correctly wired, and the running case studies are coherent. But several **load-bearing bugs** currently leak into the rendered HTML and a few **statistical/data errors** misstate headline conclusions. Top-10 issues, ranked by severity × scope × ease of fix:

| #  | Issue (one-sentence) | File / chapter | Priority |
|----|---------------------|----------------|----------|
| 1  | Ch.2 auto-`ARIMA(cigsale, ic = "aicc")` silently returns a `NULL model`; the chapter's central two-estimator disagreement is invisible on the live site (cached `[1] NA` ATT). | `02-interrupted-time-series.qmd:160–165` | **P1** |
| 2  | `R/honest_did.R:36` uses panel rows (`N·T`) instead of units (`N`) for the influence-function variance, shrinking SEs by `T²=25` and inverting ch.8's HonestDiD breakdown story (Mbar ≤ 0.5, not ≈ 1). | `R/honest_did.R:36`; ch.8 narrative | **P1** |
| 3  | Ch.10 implicit-weights table renders as literally "Table has no data" and the prose prints "(0 never-treated counties)" — `gsynth 1.4.0` returns unnamed `wgt.implied`. | `10-gsynth.qmd:314–333` | **P1** |
| 4  | Ch.10 cumulative-ATT table is empty and `fig-cumulative` is a flat zero line — chunk filters event-time labels as if they were calendar years. | `10-gsynth.qmd:357–377` | **P1** |
| 5  | Ch.1's didactic missing-data table on `01-introduction.qmd:38–47` has 5 numerically wrong cells vs `data/proposition99.rds`. | `01-introduction.qmd:38–47` | **P1** |
| 6  | Ch.6 prose and Recap quote simplex ATT ≈ `-19.5` and constraint range `-15` to `-22`, but the cached table is `-11.11` and range `-11` to `-16`. | `06-synthetic-control-prediction-intervals.qmd:236, 424, 425` | **P1** |
| 7  | Ch.6 sensitivity sweep mislabels Bonferroni-corrected bands: `e.alpha = u.alpha = a` gives joint coverage `1 − 2a` but the legend says `1 − a`. | `06-…:367, 376, 393, 412–413` | **P1** |
| 8  | Preface GitHub link points at `cmg777/ccm` instead of `quarcs-lab/ccm`; chapter 1 is silently dropped from the Part I bullet list. | `index.qmd:32, 13–18` | **P1** |
| 9  | Three `tidysynth` deprecation / "ignoring unknown labels" warnings leak into rendered ch.4 HTML. | `04-classical-synthetic-control.qmd:217–222, 243–249, 301–307` | **P1** |
| 10 | Ch.7 SAR likelihood equation does not match the C++ kernel — third term is mis-labelled as a *temporal* lag when it is the cross-coupling that propagates California's outcome into the donor pool. | `07-bayesian-spatial-sc.qmd:313–317` | **P1** |

After (1)–(10), the next-tier list contains: notation collisions of `λ`, `τ`, `α`, `W` (§2.6), the Part-I→Part-II narrative seam (§2.7), the missing common-pitfall and forward-pointer sections (§2.8), bibliography hygiene (§2.9), and the live-site footer gap.

---

## 2. Cross-cutting findings

### 2.1 Code-execution bug — ch.2 ARIMA returns NULL

`02-interrupted-time-series.qmd:160–165` calls `ARIMA(cigsale, ic = "aicc")` on the 19-observation pre-period. With `fable` 0.5.0 / R 4.5.2 this silently produces `<NULL model>` because the seasonal-order search fails on the short series. The cached `_freeze/02-…/execute-results/html.json` and `_book/02-…html:1151` both display `Model: NULL model` and `mean(ce_arima) = [1] NA`. The chapter's headline disagreement (`-28.3` linear-growth vs `+4.5` ARIMA) is therefore invisible to a reader of the published site. The `#| warning: false` on the chunk hides the underlying warning.

**Fix.** Replace with an explicit spec: `model(timeseries = ARIMA(cigsale ~ pdq(1,2,0) + PDQ(0,0,0)))`. Drop `warning: false` from the chunk so future renders break loudly. Re-render and re-publish. (Verified locally: explicit spec yields ATT = 4.549, matching the prose.)

Priority: **P1**. Source: `audit/chapter-02.md` §Methodology #1; cross-cutting notes.

### 2.2 Statistical bug — `R/honest_did.R:36` wrong `n`

The bridge to `HonestDiD::createSensitivityResults_relativeMagnitudes` computes the influence-function variance with `n <- length(es$DIDparams$data[[es$DIDparams$idname]])`, which is `N·T = 8725` on the CS minwage panel. The correct divisor is the number of units `N = 1745` (i.e., `nrow(es$inf.function$dynamic.inf.func.e)`). The current `V` is shrunk by `T² = 25`.

Reproduction (audit recomputed against the live pipeline):

| event `e` | `did::aggte` SE | buggy SE | corrected SE |
|---|---|---|---|
| 0 | 0.0090 | 0.0018 | 0.0088 |
| 1 | 0.0205 | 0.0041 | 0.0200 |
| 2 | 0.0232 | 0.0046 | 0.0226 |

Downstream, the published Mbar = 0 CI for ATT(e = 0) is `(−0.027, −0.020)`; the correct CI matching `did::aggte` is `(−0.040, −0.007)`. The relative-magnitudes breakdown drops from "≈ 1" (chapter narrative at `08:339, 352–356, 365–366`) to somewhere in **(0, 0.5]** — i.e., the on-impact effect does **not** survive even half the largest observed pre-trend, which is consistent with the unflagged statistically-significant cohort-2006 pre-trend (`08:154`, ATT(2006, 2003) = −0.034, t ≈ −2.7).

**Fix.** `R/honest_did.R:36`: `n <- nrow(es$inf.function$dynamic.inf.func.e)`. Then rewrite the ch.8 HonestDiD narrative to acknowledge the visible pre-trend and the fragility of the on-impact effect.

Priority: **P1**. Source: `audit/chapter-08.md` §M1.

### 2.3 Live-site rendering bugs — ch.10 empty tables and flat-zero figure

Both confirmed against `_freeze/10-gsynth/execute-results/html.json` and the on-disk PNG `figure-html/fig-cumulative-1.png`:

- `10-gsynth.qmd:314–333` (implicit-weights chunk): `gsynth 1.4.0` is now a thin shim around `fect::fect`, which drops row/column names on `out$wgt.implied`. `colnames(W)` and `rownames(W)` are `NULL`, `top_treated <- treated_ids[…][1:5]` is zero-length, and the `gt_pretty` call renders `Table has no data`. The follow-up prose at `10-gsynth.qmd:334–340` then prints `(0 never-treated counties)`. **Fix:** recover names from `out$id.tr` / `out$id.co` (or from the data frame's never-treated id set) before subsetting.
- `10-gsynth.qmd:357–377` (cumulative-ATT chunk): `rownames(out$est.att)` is event-time labels (`"-4" … "4"`); the chunk reads them as years and `filter(year >= 2004)` empties everything. The figure renders as axes plus a dashed zero reference line and no data layer. **Fix:** use event time directly (`event_time = as.integer(rownames(est_att))`, `filter(event_time >= 0)`, plot vs event time, update caption).

Priority: **P1**. Source: `audit/chapter-10.md` §C1, §C2.

### 2.4 Data-accuracy bug — ch.1 missing-data table

`01-introduction.qmd:38–47` displays five wrong values vs `data/proposition99.rds`:

| Cell | Prose | Actual |
|------|------:|-------:|
| CA 1995 | 64.4 | 56.4 |
| NV 1988 | 134.4 | 142.0 |
| NV 1995 | 113.0 | 100.7 |
| UT 1988 | 64.7 | 55.0 |
| UT 1995 | 55.0 | 52.0 |

This is the chapter's anchor illustration of the fundamental problem; any reader running `filter(state == "Utah", year == 1988)` will see the discrepancy.

**Fix.** Replace static markdown table with a small live R chunk fed by `prop99 |> filter(...)`. Source: `audit/chapter-01.md` §M1.

### 2.5 Prose-vs-cache mismatches

Three distinct cases:

- **Ch.6 numerical mismatch (P1).** `06-…:236, 424, 425` claim simplex ATT ≈ `-19.5` and range `-15` to `-22`. The cached `tbl-att-by-constraint` shows simplex = **-11.11**, lasso = -15.28, ridge = -15.77, ols = -14.24 — range `-11` to `-16`. The `-15` to `-22` figures appear to confuse average gaps with per-year max gaps. Fix the three Recap cells and add a one-sentence reconciliation against ch.4's `-18.85` (driven by outcome-only vs predictor-augmented matching). Source: `audit/chapter-06.md` §R1.
- **Ch.5 CI / prose mismatches (P1/P2).** `05-…:171` claims the cumulative CI `[-383, +68]` "includes zero only at the very upper edge" — zero is in fact well inside the band. `05-…:153` says posterior SD ≈ 11; it is closer to 9.6. The `-21` packs / 97% claim at `05-…:157` is asserted but never reproduced in any chunk (the chapter only fits the with-covariates variant). Source: `audit/chapter-05.md` §3.
- **Ch.7 narrative claims (P2/P3).** "Active-donor count rises monotonically" (`07-…:482, 501`) is false — counts are 4, 23, 23 (Stage 3 conditions on Stage 2's α̂). "Nevada is the dominant spillover-receiver by an order of magnitude" (`07-…:420`) understates: the ratio is 16× (caption already says so). Source: `audit/chapter-07.md` §4.4, §4.5.

### 2.6 Bonferroni labelling error in ch.6 sensitivity sweep

`06-…:367` sets `e.alpha = a` AND `u.alpha = a` and labels the resulting bands "80% / 90% / 95% / 99%". By the joint-coverage union bound (which the chapter itself invokes for the 95% band at `06-…:259` and at `06-…:353`), these correspond to joint coverage `1 − 2a`, i.e., **60% / 80% / 90% / 98%**. The legend and the figure caption (`06-…:381, 393, 412–413`) are off by a factor of 2.

**Fix (cleaner).** Use `u.alpha = a/2, e.alpha = a/2` so labels are correct as stated. Alternative: relabel as 60/80/90/98 throughout.

Priority: **P1**. Source: `audit/chapter-06.md` §R7.

### 2.7 Preface — stale link, missing chapter 1

- `index.qmd:32` links `github.com/cmg777/ccm` (the author's personal mirror). The canonical repo is `github.com/quarcs-lab/ccm` (per `_quarto.yml:20` and `README.md:9`). Update.
- `index.qmd:11, 13–18` advertises "Chapters 1–7" but the six bullets that follow correspond to chapters 2–7; chapter 1 is silently omitted. Add an Introduction bullet or rephrase to "Chapters 2–7…after chapter 1 introduces the potential-outcomes vocabulary."

Priority: **P1** (both). Source: `audit/chapter-00-preface.md` §W1, §W2.

### 2.8 Notation collisions across chapters

The cross-cutting notation audit (`audit/cross-cutting-notation-arc.md` §1) identifies four collisions, all P1:

| Symbol | Conflict | Recommended convention |
|---|---|---|
| **τ** | Ch.1, 3, 6, 10 use it for the *treatment-effect* estimator/estimand; `07-…:197` redefines it as the horseshoe *global* scale hyperparameter. | Keep τ for treatment effects book-wide; rename ch.7's horseshoe scale to `τ_HS` or `σ_τ`. |
| **λ** | Triply overloaded: factor loading `λ_i` (chs.9, 10, `01:96`), MC nuclear-norm penalty (`09:159, 226, 301`), horseshoe local scale `λ_j` (`07:197`). Worst inside ch.9, where `λ_i' f_t` (line 25) and `lambda.cv` (line 230) appear nine lines apart with no notation note. | Keep `λ_i` for loadings; rename ch.9's MC penalty to `η` (or print `λ_{MC}` consistently) and add a one-line glossary note where the penalty is first introduced. Rename horseshoe local to `λ_{j,HS}`. |
| **α** | Ch.7 uses `α` for *donor weights* (horseshoe-prior sample); chs.9, 10 use `α_i` for *unit fixed effects*. | Keep `α_i` for unit FE in Part II; rename ch.7's donor weights to `w` to match chs.4, 6. |
| **W / w** | `w` is donor weights in chs.4, 6; `W` is the 38×38 *spatial adjacency* in ch.7; `W` is the *gsynth implicit-weight matrix* in ch.10. | Reserve `w` for donor-weight vectors; keep `W` for spatial adjacency only in ch.7; rename ch.10's `wgt.implied` to `Ω` in prose (keep the R variable). |

A single Notation appendix at the front (or front-matter table) listing each symbol with its global meaning and any chapter-local override would let the book function as a reference. Currently each chapter is internally consistent but the cross-chapter map is in the reader's head.

Secondary P2 inconsistencies: lowercase `y_{it}` in chs.5, 8 vs uppercase elsewhere; the "every method imputes `Ŷ(0)`" through-line is broken in chs.7 (writes `Y_{c,pre} α`) and 8 (writes `Y_{it}(∞)` per Callaway-Sant'Anna convention).

Source: `audit/cross-cutting-notation-arc.md` §1.

### 2.9 Narrative seams and forward signposts

**The Part-I → Part-II seam is one-sided.** Ch.7's closing (`07-…:506–513`) contains zero mention of staggered adoption, the dataset switch, or chs.8–10. Ch.8 opens (`08-…:7–49`) with all the cross-chapter prep work. Fix: add a closing paragraph to ch.7 ("Where this case study ends, and where Part II begins") announcing (i) the seven Prop 99 chapters all converged on `-15` to `-19` packs, (ii) ch.8 onward leaves Prop 99 for the CS minwage county panel, (iii) the ATT(g, t) framework generalises the ATT-on-California estimand.

**Duplicate heading.** Both `06-…:5` and `07-…:5` use `## Why a third synthetic-control chapter?` verbatim. Ch.7 is the *fourth* SC-flavoured chapter and should be renamed.

**Five chapters end without a next-chapter signpost** (chs.4, 5, 6, 8, 9). Recommend one closing sentence each, mirroring ch.2's "Where this leaves us":

| Chapter | Missing forward link | What it should say |
|---|---|---|
| 4 | → chs.6, 7 | The SCM family extends in two directions: prediction intervals (ch.6) and spatial spillovers (ch.7). Currently only forwards to ch.5. |
| 5 | → ch.6 | The credible interval is Bayesian; the natural follow-up is a frequentist prediction interval, which ch.6 builds. |
| 6 | → ch.7 | The fourth SC perspective relaxes SUTVA via a spatial-autoregressive donor DGP. |
| 8 | → ch.9 | TWFE/CS/DR all rest on parallel trends; ch.9 relaxes that via a low-rank factor model. |
| 9 | → ch.10 | The IFE-and-MC family is broad; ch.10 zooms in on `gsynth` as a focused single-estimator walkthrough. |

**Other gaps.** Ch.5 never contrasts BSTS's spike-and-slab weights against ch.4's simplex weights even though that contrast is exactly what motivates a second SC-flavoured chapter (`audit/chapter-05.md` §Methodology #2). Ch.3 has no inward callback to ch.2's punchline.

Priority: **P2** across the board; ch.7 closing paragraph is **P1** because it carries the Part-I → Part-II seam. Source: `audit/cross-cutting-notation-arc.md` §2; per-chapter audits.

### 2.10 Theming regressions — `theme_minimal()` clobbers transparent house theme

Four chapters set a transparent-background `theme_set(...)` in their setup chunk and then append `+ theme_minimal()` at the end of a ggplot, which **replaces** the active theme entirely and restores ggplot2's default white panel/background. In dark mode (`darkly`) this produces a near-white slab in the middle of a dark page. Affected:

- `01-introduction.qmd:216` — `fig-raw-series` (the first figure of the book).
- `02-interrupted-time-series.qmd:127, 202` — both `fig-its-growth` and `fig-its-arima`.
- `03-basic-diff-in-diff.qmd:133–134` — the headline parallel-trends figure.
- `04-classical-synthetic-control.qmd:187` — the V-matrix bar chart `fig-sc-predictor-weights`.

**Fix.** Delete the trailing `+ theme_minimal()` from each plot. The global `theme_set()` already supplies the right base.

Priority: **P1** for chs.1 and 4 (visible on the live site in dark mode); **P2** for chs.2, 3.

Source: per-chapter audits (`chapter-01.md` §C1, `chapter-02.md` §Code 5, `chapter-03.md` §C1, `chapter-04.md` §3.3).

### 2.11 Bibliography gaps and hygiene

Bibliography is functionally healthy — no `[?]` placeholders on the live site, all 24 cited keys resolve, APA 7 rendering works. But:

| Issue | Detail | Priority |
|---|---|---|
| `callaway2022handbook` mis-typed | Declared `@article`, is actually a handbook chapter (`@incollection`). The rendered entry silently drops publisher/editors/chapter pages. `references.bib:215–222`. | **P1** |
| 3 entries lack `year` | `causalimpact-pkg`, `brodersen-causalimpact-talk`, `fpp3-pkg` render as "(n.d.)" on the live References page. | **P1** |
| 3 orphan entries | `abadie2003economic`, `bai2003inferential`, `fpp3-pkg` are in `references.bib` but never cited. README claims "~24 entries"; bib has 27; 24 are cited (matches the rendered page). Either cite or remove. | **P2** |
| Missing canonical citations | Card-Krueger (1994), Bertrand-Duflo-Mullainathan (2004), Wagner et al. (2002), Scott-Varian (2014), van Buuren & Groothuis-Oudshoorn (2011), George-McCulloch (1997), Chernozhukov-Wüthrich-Zhu (2021), Roth-Sant'Anna-Bilinski-Poe (2023). All flagged by per-chapter audits as natural citations for chs.3, 5, 6, 8. | **P2** |
| `sakaguchi2026spatial` lacks volume/number/pages | Forthcoming; add `note = {Advance online publication}`. | **P3** |
| `brodersen2015inferring` lacks `number` | AAS uses issue numbers; renders `9, 247–274` instead of `9(1), 247–274`. | **P3** |
| Package-name capitalisation | `dunford2024tidysynth` and `cattaneo2025scpi` render as "Tidysynth" / "Scpi" because titles lack double-brace protection. | **P3** |

Source: `audit/chapter-11-references.md`.

### 2.12 Three deprecation warnings in rendered ch.4 HTML

Phase 1 flagged two; the audit found a third. All originate inside `tidysynth`, not authored code, so can be suppressed at the chunk level:

- `04-…:217–222` (`fig-sc-trends`) — *"Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0"* (rendered `_book/04-…html:1753`).
- `04-…:243–249` (`fig-sc-differences`) — *"Ignoring unknown labels: colour : "", linetype : ""."* (`_book/04-…html:2311`).
- `04-…:301–307` (`fig-sc-mspe-ratio`) — *"Ignoring unknown labels: colour : ""."* (`_book/04-…html:2926`).

**Fix.** Add `#| warning: false` to each chunk header, or set chapter-wide in the setup chunk (`04-…:51`). Source: `audit/chapter-04.md` §3.1.

### 2.13 Reproducibility — ch.5 seed narration is wrong

`05-…:126` says "Reset the seed so the BSTS MCMC draws are reproducible." This is incorrect: `CausalImpact:::ConstructModel` hard-codes `bsts(..., seed = 1, ...)` so the MCMC is deterministic regardless of `set.seed(42)`. The `set.seed(42)` at `05-…:55` governs only the `mice` random-forest imputation. Fix the comment and move the seed reset *before* the `mice()` call. Source: `audit/chapter-05.md` §Methodology 7.

Several chapters also set `set.seed(42)` defensively in pipelines with no stochastic step (chs.2, 3, 4, 8) — harmless but worth a one-line comment so readers don't misread.

### 2.14 Infrastructure drift

- **`install_packages.R` vs `DESCRIPTION` drift.** Bootstrap script lists 24 packages; `DESCRIPTION` lists 37 (adds `did`, `HonestDiD`, `DRDID`, `fect`, `panelView`, etc.). Intentional per CLAUDE.md (renv.lock is the true pin source), but unsynced. Add a `README.md` / CLAUDE.md note that the bootstrap is the *minimum* and renv.lock is the *complete* manifest, or sync.
- **Stale `_freeze/` orphans.** `_freeze/06-bayesian-spatial-sc/` and `_freeze/07-synthetic-control-prediction-intervals/` are leftovers from the pre-rename numbering; content hashes match the renamed equivalents. Safe to `rm -rf` (gitignored).
- **Loose render artifacts.** `10-gsynth_files/` and `10-gsynth_cache/` exist at repo root; ch.10 audit confirms they are covered by `.gitignore` `*_files/` and `*_cache/` patterns. Safe to delete locally; will be re-created and stay ignored.
- **README inconsistency.** README.md claims `~24 entries` in references.bib; actual is 27 (24 cited keys after the orphan trim recommended in §2.11). Update README to match post-fix state.
- **Live-site footer missing.** No copyright, license badge, "last updated" / build timestamp on the rendered HTML. Add via `_quarto.yml` `format.html.include-after-body` or a small footer partial.

Priority: **P3** across the board (none blocking).

### 2.15 Recurring per-chapter patterns

- **Common-pitfall sections are inconsistent.** Chs.4, 5, 7 have proper `**Common pitfall.**` callouts; ch.6 has the pitfall hinted at in a Recap row only; ch.8 has a full section; chs.1, 3 have one-sentence pitfalls. Adopt a consistent template (a short bulleted callout block) and apply book-wide.
- **`Ŷ(0)` thesis breaks in Part II.** Ch.1 sells "every method imputes `Ŷ(0)`" as the book's organising principle (`01:79–97, 99`). Chs.7, 8 break the thread by writing `Y_{c,pre} α` and `Y_{it}(∞)` respectively. Either rebind explicitly or write `Ŷ(0)` once in each chapter as the bridge.
- **Window inconsistencies.** Ch.2 compares an ITS fit on 1970–1988 to ch.1's naive estimate on 1984–1993 as if they were comparable (`02-…:130`). Part II uses 2003–2007 in ch.8 and 2001–2007 in chs.9, 10; the ch.10 recap then reconciles four numbers fit on two different windows without saying so.
- **Headline numbers are sometimes asserted but not extracted.** Ch.9 never prints a numeric ATT (only gap plots); ch.7 Stage 3 ATT is described as "between the other two" without a stable inline figure; ch.5's `-13` (with covariates) vs `-21` (without) split is invisible in the recap.

---

## 3. Chapter-by-chapter audit

### Preface — `index.qmd`
**Status:** Short, well-structured, but two P1 issues plus several pedagogical gaps for the stated audience.

**Top issues**
- **P1** `index.qmd:32` — broken GitHub link (`cmg777/ccm` → `quarcs-lab/ccm`). [chapter-00 §W1]
- **P1** `index.qmd:11, 13–18` — Part I roadmap claims "Chapters 1–7" but lists only six method bullets (chs.2–7); chapter 1 is silently dropped. Add an Introduction bullet or rephrase. [§W2]
- **P2** No audience or prerequisites statement; "Who this book is for" subsection missing. [§W3]
- **P2** ATT is used at line 11 without a one-sentence gloss or forward link to ch.1. [§W4, §W6]
- **P2** Acknowledgments thanks no one and credits no datasets (no Abadie-Diamond-Hainmueller, no Callaway-Sant'Anna). [§W7]
- **P2** No License section. README has MIT but the web preface never mentions it. [§W8]
- **P2** Preface thesis statement ("disagreement is the lesson") is missing — appears only at `01-…:274`. [cross-cutting §2.b]

**Quick wins (P3)**
- Soften the "PDF in the navbar" claim given CLAUDE.md's on-demand-only PDF rule (`index.qmd:32`). [§W5]
- Add a `## How to cite` block. [§W9]
- Replace bare "GitHub" anchor text with descriptive text. [§I2]

### Chapter 1 — `01-introduction.qmd`
**Status:** Doing important conceptual work well; one P1 data bug, one P1 theme bug, one P1 decision-tree mis-classification.

**Top issues**
- **P1** `01-…:38–47` — five wrong values in the missing-data didactic table vs `data/proposition99.rds` (see §2.4 above). [chapter-01 §M1]
- **P1** `01-…:216` — `+ theme_minimal()` clobbers the chapter's transparent house theme on the first figure of the book. Delete the line. [§C1]
- **P1** `01-…:121` — decision-tree leaf `SCM` puts chs.4, 6, **and 7** under "Frequentist + tidy code", but ch.7 is explicitly Bayesian. Restructure Q2's downstream nodes so ch.7 lands under a Bayesian branch (or its own SUTVA-relaxation leaf). [§M3]
- **P2** SUTVA is never named (`01-…:17–77`), even though ch.7 leans on it explicitly. Add one sentence after the potential-outcomes definition. [§M4]
- **P2** Imputation table at `01-…:79–97` conflates point predictions with conditional expectations and has subscript inconsistencies on naive and DiD rows. [§M2]
- **P2** Prose says HAC vs OLS is "wildly overconfident" but the actual gap is ~18% with `vcovHAC`; "wildly" is defensible only against `NeweyWest`. Match estimator to adjective. [§M5, §C2]
- **P2** `naive-prepost` chunk has no `tbl-` label or caption (CLAUDE.md convention violation). [§C3]

**Quick wins (P3)** Reorder paragraphs 1 and 2 of the hook. Inline the 116.21 → 60.35 arithmetic. Expand "Common pitfall" into 3–4 bullets. Annotate "Further reading" with categories. Lift `theme_set` + `dev.args` into `R/setup_theme.R` to stop the duplication across chapters.

### Chapter 2 — `02-interrupted-time-series.qmd`
**Status:** Well structured, but the chapter's central claim is currently invisible on the live site.

**Top issues**
- **P1** `02-…:160–165` — `ARIMA(cigsale, ic = "aicc")` returns `NULL model`; ATT prints as `NA`; the dashed "ARIMA counterfactual" in `fig-its-arima` is empty. See §2.1 above. [chapter-02 §Methodology #1, §Code #1, #2]
- **P1** `02-…:156–157` — `#| warning: false` hides the warning that explains the bug. Drop it. [§Code #7]
- **P2** ITS identification assumption is never stated as a *labelled* assumption. One bold "**Identification.**" sentence. [§Methodology #3]
- **P2** Zero residual diagnostics anywhere — `feasts` is loaded but `gg_tsresiduals()` / Ljung-Box never called. [§Methodology #4]
- **P2** ARIMA forecast variance is computed (it's in the `<dist>` column) but discarded; a 95% PI ribbon would make the "doomsday counterfactual" framing visceral. [§Methodology #5]
- **P2** `02-…:127, 202` — trailing `+ theme_minimal()` clobbers the transparent theme. [§Code #5]
- **P2** `year0` is set up at `02-…:59` and never used. [§Code #3]
- **P2** Missing inward callback in ch.3 to ch.2's punchline; outward handoff at `02-…:219` skips ch.6 even though ch.6 directly answers ch.2's "no credible uncertainty" complaint. [§Cross-chapter #2, #3]

**Quick wins (P3)** Add Wagner et al. (2002) to bib + Further Reading. HAC SE on the linear-trend regression (or a deliberate decision not to). Mask growth-curve dashed line to post-period. Sharpen ARIMA pitfall with "$d=2$ has no level anchor".

### Chapter 3 — `03-basic-diff-in-diff.qmd`
**Status:** Short, tight, numerically sound; six material issues, all one-paragraph fixes.

**Top issues**
- **P1** `03-…:134` — trailing `+ theme_minimal()` clobbers transparent theme on the headline parallel-trends figure. [chapter-03 §C1]
- **P1** Parallel-trends assumption is asserted four times but never *tested*. A formal slope test on 1984–1988 actually rejects: `stateCalifornia:year = -4.63`, HAC p = 0.024. Add a `tbl-pretrends` chunk. [§M1]
- **P2** HAC standard errors on a 2-unit panel are misjustified — `vcovHAC` treats stacked panel as one time series; clustering on 2 clusters is degenerate (Bertrand-Duflo-Mullainathan). Rewrite the inference paragraph honestly. [§M2]
- **P2** The canonical population regression `Y_{it} = α + β₁ Post + β₂ Treat + τ(Post × Treat) + u` is never written down — only the R formula `state * prepost`. [§M3]
- **P2** `references.bib` is missing `cardkrueger1994minimum` and `bertrand2004how`. [§C2]
- **P2** No forward link to ch.8 (staggered DiD), despite ch.1's promise; "many Nevadas weighted" hand-off is one connector short. [§X1, §X3]
- **P2** Common-pitfall section names one pitfall (single similar control) but misses two more important ones for this chapter: clustering with G=2 is degenerate, and Nevada is itself in California's TV/price corridor. [§W1]

**Quick wins (P3)** Add a hook tying back to ch.2's punchline. Trim the editorialising figure caption at line 120. Quantify Nevada's adjacency. Annotate `set.seed(42)` as hygiene-only.

### Chapter 4 — `04-classical-synthetic-control.qmd`
**Status:** Solid; methodology correct, numbers within rounding of ADH (2010). Main fixable issues are warning leaks and one stale cross-reference.

**Top issues**
- **P1** Three `tidysynth` warnings leak into rendered HTML at `04-…:217–222, 243–249, 301–307`. Add `#| warning: false` per chunk (or chapter-wide). [chapter-04 §3.1]
- **P1** `04-…:76` — stale "RDD chapter" reference (`03-rd-in-time.qmd` was deleted; ch.3 is now Basic DiD). [§3.2]
- **P1** `04-…:187` — `+ theme_minimal()` on V-matrix bar chart `fig-sc-predictor-weights` clobbers the chapter theme. [§3.3]
- **P2** No leave-one-out / in-time-placebo robustness check. ADH 2010 Fig. 3 / Table 3 do this; at minimum mention both in Further Reading or add a leave-one-out for Utah. [§3.4]
- **P2** "Common pitfall" callout covers only V-matrix interpretation. Missing: convex-hull / interpolation bias, sparse-extreme weights, donor-pool contamination. [§3.5]
- **P3** `04-…:157, 355` — "Western/sunbelt" mislabels Mountain-West states. [§3.6]
- **P3** Recap says five donor states, table shows eight (`head(8)`). [§3.7]
- **P3** `mean(sc_post$dif)` echoes a raw numeric instead of a sentence — use inline `r round(...)`. [§3.8]

**Quick wins (P3)** Cross-chapter handoff to ch.5 could be one sentence fuller. Drop or comment `set.seed(42)`.

### Chapter 5 — `05-structural-bayesian-ts.qmd`
**Status:** Pedagogically clear but missing a name for its central regularisation device (spike-and-slab) and several methodological hooks.

**Top issues**
- **P1** Spike-and-slab prior is never mentioned even though it is how `CausalImpact` handles `p >> n` (194 columns, 19 pre-period years). Add one paragraph after `05-…:17`. [chapter-05 §Methodology 1]
- **P1** `05-…:171` — "cumulative CI includes zero only at the very upper edge" is wrong; zero is well inside `[-383, +68]`. [§Code 3]
- **P1** `05-…:157` — the `-21` packs / 97% claim is asserted but no chunk runs the no-covariates fit. Either reproduce or remove. [§Code 4]
- **P2** `05-…:126` — seed-narration comment is wrong (BSTS hard-codes `seed = 1` internally). Fix the comment and move `set.seed(42)` before the `mice()` call. [§Methodology 7]
- **P2** No inclusion-probability figure (the closest analogue to ch.4's donor-weights table). Add `plot(impact_full$model$bsts.model, "coefficients")`. [§Methodology 5]
- **P2** No MCMC convergence check, no traceplot. Asymmetric caution against $m=1$ imputation. [§Methodology 6]
- **P2** Comparison to classical SC is implicit; never spells out simplex (ch.4) vs spike-and-slab (here) as the prior contrast. [§Methodology 2]
- **P2** Credible vs confidence interval is mentioned once at `05-…:9` and never developed. [§Methodology 3]
- **P2** No transition out to ch.6 (frequentist PI is the natural follow-up). [§Cross-chapter 3]
- **P2** Bib missing: `scott2014predicting`, `vanbuuren2011mice`, `george1997approaches`. [§Bibliography]

**Quick wins (P3)** Hook is functional but cold; consider a one-sentence narrative opener. Posterior SD ≈ 11 (line 153) is closer to 10. Add a "do not read inclusion probability as a causal weight" pitfall.

### Chapter 6 — `06-synthetic-control-prediction-intervals.qmd`
**Status:** Strongest of the four "uncertainty for SC" chapters in conception; one P1 numerical bug, one P1 sensitivity-labeling bug, plus missing common-pitfall section.

**Top issues**
- **P1** `06-…:236, 424, 425` — simplex ATT ≈ `-19.5` and range `-15` to `-22` are wrong. Cached values are `-11.11` (simplex) and range `-11` to `-16`. See §2.5 above. [chapter-06 §R1]
- **P1** `06-…:21` — error-decomposition equation LHS is `τ_t − τ̂_t` but should be `Y_{1t}(0) − Ŷ_{1t}(0)`; sign is flipped relative to SCPI paper. [§M1]
- **P1** Sensitivity sweep mislabels Bonferroni-corrected bands (60/80/90/98 ≠ 80/90/95/99). Fix `e.alpha = a/2, u.alpha = a/2` or relabel. See §2.6. [§R7]
- **P1** Duplicate heading with ch.7 — both use `## Why a third synthetic-control chapter?` at `:5`. Rename ch.7 to "fourth". [§C3]
- **P2** Lasso constraint stated as `‖w‖₁ ≤ 1` but `scpi`'s actual is `‖w‖₁ ≤ Q` with Q tunable. Same with ridge data-driven Q formula. [§M2, §M3]
- **P2** Outcome-only matching at `06-…:54` breaks comparability with ch.4 (which uses `lnincome`, `beer`, `age15to24`) without saying so — that asymmetry drives the simplex-ATT gap from `-18.85` to `-11.11`. Add one sentence. [§R2]
- **P2** No `## Common pitfall` section (structurally out of step with chs.4, 5, 7). Add. [§W1]
- **P2** Joint-coverage / Bonferroni note missing before the "95% PI" label first introduced at `:262`. [§M6]
- **P2** `e.method = "gaussian"` is presented as "JSS-paper recommendation" but is an override (package default is "all"). [§M7]
- **P2** Conformal-inference alternative (Chernozhukov-Wüthrich-Zhu 2021) is never mentioned. [§M5]
- **P2** No Recap row contrasting SCPI PI with ch.5's credible interval — the chapter's own setup framing. [§C4]

**Quick wins (P3)** Add `set.seed(42)` inside each `scpi(...)` chunk for independent reproducibility. Drop redundant `cores = 1`. Silence `geom_ribbon` NA warnings. Replace "economically meaningful amount" with percentage-of-baseline. Unify donor-count between table (10) and heatmap (12).

### Chapter 7 — `07-bayesian-spatial-sc.qmd`
**Status:** Ambitious, well-structured; one P1 equation bug, multiple cross-chapter narrative issues, and the Part-I → Part-II seam.

**Top issues**
- **P1** SAR likelihood at `07-…:313–317` mis-states the model — the third term reads as a temporal lag but the C++ kernel at `R/scspill/20_mcmc.cpp:254–255` builds `A = W + w α'`, so the actual model is `(I − ρW − ρ w α') Y_{c,t} = X_{c,t} β + Λ F_t + ε_t`. Also silently drops the `Λ F_t` term despite `p_factors = 1L`. See §2.10 above. [chapter-07 §Methodology 1]
- **P1** `07-…:5` — heading `## Why a third synthetic-control chapter?` is identical to ch.6's. Rename to "fourth". [§Cross-chapter 1]
- **P1** `07-…:7` — opening narrative skips ch.6 entirely. Add one sentence between the ch.5 and "Both treat..." sentences. [§Cross-chapter 2]
- **P1** Missing Part-I → Part-II handoff at chapter end. The Prop 99 case study closes here without acknowledging the dataset switch. See §2.9. [§Cross-chapter 3]
- **P1** `07-…:482, 501` — "active-donor count rises monotonically" is false (4, 23, 23). [§Writing 4]
- **P2** Priors on `ρ, σ², β` are nowhere stated even though the chapter writes out the horseshoe hierarchy on α. [§Methodology 2]
- **P2** Two-step sampling structure (Step 2 holds α fixed at α̂) is a *plug-in approximation* and should be flagged — one structural reason the Stage-3 CrI is artificially narrow. [§Methodology 4]
- **P2** No MCMC diagnostics shown beyond a single ESS scalar; add a `ρ` traceplot. [§Methodology 5]
- **P2** `07-…:389` says the framework "forward-simulates" the SAR DGP, but the code uses a closed-form Sakaguchi-Tagawa identification formula. [§Methodology 6]
- **P2** `07-…:355` — "bounded clearly away from zero" is not supported at ESS = 2.9. [§Code 6]
- **P2** macOS gfortran shim at `07-…:79–89` is Intel-only; add `/opt/homebrew/Cellar/gcc/*/lib/gcc/*` glob for Apple Silicon. [§Code 2]
- **P2** Notation collision with ch.4 (both use `w` for different objects); see §2.6. [§Cross-chapter 4]
- **P2** Common-pitfall section is missing. [§Methodology 8]
- **P3** Out-of-chapter: `R/scspill/41_robustness_check.R` references globals `W` and `w` where it should reference arguments `W_raw`, `w_raw` (multiple sites: lines 38–40, 176–177, 428–429). Latent bug. Also `R/scspill/22_mcmc_sar.R:43` calls a non-existent C++ function.

**Quick wins (P3)** Define the four prior-predictive statistics in prose. "Order of magnitude" → "≈16×". Annotate `MCMC_ITER` / `MCMC_BURN` with rescale instructions. Add Makalic-Schmidt 2015 parenthetical.

### Chapter 8 — `08-staggered-did.qmd`
**Status:** Strong opener for Part II with one load-bearing statistical bug.

**Top issues**
- **P1** `R/honest_did.R:36` — wrong `n` (panel rows vs units). See §2.2. Inverts the chapter's HonestDiD breakdown story from "Mbar ≈ 1, conclusion robust" to "Mbar ≤ 0.5, conclusion fragile". [chapter-08 §M1]
- **P1** `08-…:339, 352–356, 365–366` — narrative depends on the buggy breakdown; rewrite to reflect Mbar ≤ 0.5 and the visible cohort-2006 pre-trend. The fix *strengthens* the chapter: pre-trend visible → HonestDiD confirms fragility → narrative coherent. [§M1, §S3]
- **P2** `08-…:154–161` — cohort-2006 pre-trend ATT(2006, 2003) = `-0.034` (t ≈ -2.7) is statistically significant and unflagged. Add a 2–3 sentence paragraph after `tbl-attgt`. [§M2]
- **P2** `08-…:180–184` — prose describes "overall ATT" as a simple time-weighted mean, but the code uses `aggte(type = "group")` which is cohort-then-cross-cohort. [§M3]
- **P2** `08-…:46` — cohort list disagrees with code (intro says `{0, 2004, 2006}`, code filters `{0, 2004, 2006, 2007}` then drops 2007). [§C2]
- **P2** `08-…:37–38` — Sun-Abraham is named as a "companion idea" but never actually run. Drop the forward-reference or add a `fixest::sunab()` chunk. [§X6]
- **P2** `08-…:148` — parallel-trends assumption not explicitly stated next to the estimand. [§M6]
- **P2** No forward link to ch.9 at chapter end. [§X5]

**Quick wins (P3)** Annotate `set.seed(42)` as hygiene only. Extend Exercise 1's prompt with the bias trade-off when using `notyettreated` controls. Add Roth-Sant'Anna-Bilinski-Poe (2023) to Further Reading. Rename `## When Basic DiD breaks` to `## When TWFE breaks under staggered adoption`.

### Chapter 9 — `09-matrix-completion-and-ife.qmd`
**Status:** Methodological turning point of Part II; well-written but four substantive issues including no headline number reported.

**Top issues**
- **P1** `09-…:270–280` — "IFEct vs MC compared" prose talks as if a non-trivial factor model was fit, but CV picked `r = 0`, meaning IFEct collapsed to TWFE. Add a paragraph after `tbl-cv` acknowledging the finding and rewrite the comparison. [chapter-09 §M1]
- **P1** Chapter never reports a numeric ATT for either method — only gap plots. Add a `tbl-att` chunk extracting `out_ife$att.avg` and `out_mc$att.avg`. Without this, the planned cross-method comparison chapter cannot include ch.9. [§M4, cross-cutting §3.c]
- **P2** `09-…:77–84` — `min.T0` framing of the window-change argument is imprecise; `min.T0` is a user-set threshold, and the rank constraint is `r < T0` per unit, not "r = 0 when min.T0 = 1". [§M2]
- **P2** `lemp ~ D` formula omits the `lpop + lavg_pay` covariates that ch.10 (same panel) includes; equation also omits the `X β` term. Reconcile or explain. [§M3]
- **P2** Within-chapter `λ` collision: `λ_i` (loading vector) and `λ` (MC penalty) appear on adjacent screens with no glossary note. See §2.6. [§X1]
- **P2** `09-…:129–134` — `panelview()` silently subsamples 500 of 1,745 counties; ch.10 passes `display.all = TRUE`. Pick one. [§C1]
- **P2** Borderline-identifiability callout (`09-…:282–290`) is placed *after* the comparison section as a postscript. Move to before `## Estimating with FECT`. [§W2]
- **P2** No Exercises section, breaking symmetry with chs.8 and 10. [§W1]
- **P2** No forward link to ch.10. [§X3]

**Quick wins (P3)** Rename file title to "Interactive Fixed Effects and Matrix Completion" (body order). Add IFEct attribution `@liu2024practical` at `09-…:33`. Add gsynth / MCPanel pointers to Further Reading. State the MC objective `‖Y_{obs} − Ŷ(0)‖_F² + λ ‖Ŷ(0)‖_*` explicitly.

### Chapter 10 — `10-gsynth.qmd`
**Status:** Last drafted chapter; two showstopper rendering bugs plus several smaller issues.

**Top issues**
- **P1** `10-…:314–333` — implicit-weights table renders "Table has no data" and prose prints "(0 never-treated counties)". See §2.3. [chapter-10 §C1]
- **P1** `10-…:357–377` — cumulative-ATT table empty and `fig-cumulative` is a flat zero line. See §2.3. [§C2]
- **P1** `10-…:408, 449` — misattributes doubly-robust DiD to "chapter 9" (it lives in chapter 8). Line 476 is correct. [§X1]
- **P1** `10-…:288, 293` — factors-plot caption insists "a single curve is shown" but the figure shows two (FE + Factor 1). [§M5]
- **P2** `10-…:222–238` — "IC-selected rank" framing is misleading: IC global minimum is `r = 0`, the chapter filters to `r ≥ 1`. Relabel as "pedagogical override: smallest non-zero rank" and add one transparent sentence. [§M2]
- **P2** Gap and counterfactual plots show event-time x-axis but the axis title (passed via `xlab = "Year"`) says "Year". Either relabel as "Event time" or post-process. [§C3]
- **P2** `10-…:175–181` — `cv.nobs = 8` arithmetic uses legacy defaults (current `fect`-backed gsynth default is `cv.nobs = 3`, so the constraint is `3 + 3 = 6`, not 8). [§M3]
- **P2** Hook lists chs.4, 7, 8, 9 but omits chs.5, 6; the gsynth-as-generalisation-of-ch.4 link could be made explicit. [§M4, §X2]
- **P2** No forward link to a cross-method comparison chapter. [§X3]
- **P2** `@bai2003inferential` cited only by parenthetical name in `tbl-cap`, not as `[@bai2003inferential]`. [§X5]

**Quick wins (P3)** `inference = "nonparametric"` is silently converted to `"bootstrap"` — clarify in prose. Rename `## Recap` to `## Reconciliation`. Add gsynth vignette + 2017 *Political Analysis* replication archive to Further Reading. Clean up `10-gsynth_files/` and `10-gsynth_cache/` locally (already gitignored).

### References — `references.qmd` + `references.bib`
**Status:** Functionally healthy (no `[?]` placeholders); see §2.11 for the full priority list.

**Top issues**
- **P1** `callaway2022handbook` mis-typed as `@article` (should be `@incollection`); APA renders without editors/publisher. [chapter-11 §P1]
- **P1** 3 entries lack `year`, render as "(n.d.)": `causalimpact-pkg`, `brodersen-causalimpact-talk`, `fpp3-pkg`.
- **P2** 3 orphans (`abadie2003economic`, `bai2003inferential`, `fpp3-pkg`); either cite or remove.
- **P2** Add missing canonical citations identified by per-chapter audits (Card-Krueger, Bertrand-Duflo-Mullainathan, Wagner, Scott-Varian, mice, George-McCulloch, Chernozhukov-Wüthrich-Zhu, Roth-Sant'Anna-Bilinski-Poe).
- **P3** `sakaguchi2026spatial` missing volume/number/pages (forthcoming).
- **P3** `brodersen2015inferring` missing `number = {1}`.
- **P3** Package-name title casing in `dunford2024tidysynth`, `cattaneo2025scpi`.

---

## 4. Proposed cross-method comparison chapter

The book currently has 10 method chapters but no synthesis chapter, even though the cross-cutting report flags this gap and the README promises it explicitly. The ch.10 audit (`audit/chapter-10.md` §"What a cross-method comparison chapter should cover") and the cross-cutting audit (`audit/cross-cutting-notation-arc.md` §3.c) already sketched proposals; consolidated here.

**Working title.** Chapter 11 — Comparing methods.

**File.** `11-comparison.qmd` (append to `_quarto.yml:chapters` and to `R/build_chapter_zips.R:chapters`).

**Structure.**

1. **Hook (1 paragraph).** Restate the book's central thesis from `01-…:274` and the Preface fix in §2.9: *"Each method estimates the same ATT from a different data source and a different identifying assumption; the disagreements between estimators on the same dataset are the lesson of this book."* Promise that this chapter brings the ten estimates onto two forest plots and one decision tree.

2. **Method taxonomy.** A table that cross-references each method (chs.2–10) on dimensions: target estimand (single-treated ATT vs ATT(g, t)); counterfactual construction (donor weights / forecast / low-rank imputation / nuclear-norm completion); identifying assumption (pre-treatment fit / no structural break / parallel trends / parallel factors / low rank); what it relaxes vs the previous chapter; inference type (placebo / posterior / clustered / bootstrap / prediction interval); computational cost; when to prefer. One row per chapter; one column per dimension. This is the page a reader pins to the wall.

3. **Prop 99 head-to-head.** Forest plot of headline ATTs across chs.1, 2 (both ITS variants), 3, 4, 5 (with-covariates and cigsale-only), 6 (simplex + 3 constraint variants), 7 (Stage 1 / Stage 2 / Stage 3). Gather numbers from `_freeze/<chapter>/execute-results/html.json` and assemble into a single `tibble`. **Three Part-I chapters need a stable inline headline ATT before this can be built** (cross-cutting §3.c):
   - Ch.5: pick one canonical headline (currently `-13` with-covariates vs `-21` cigsale-only).
   - Ch.7: extract a numeric Stage 3 ATT into the recap (currently "between the other two").
   - Ch.9 (for Part II forest plot): extract `out_ife$att.avg` and `out_mc$att.avg`.

4. **CS minwage head-to-head.** Forest plot of headline ATTs across ch.8 (TWFE / CS overall / DR conditional / event-study e=0 / event-study e=+3), ch.9 (IFEct / MC — once §4.3 is done), ch.10 (gsynth r=0 / gsynth r=1). Add the gsynth-r=0 figure that ch.10 already prints inline (`-0.047`, within sampling error of TWFE).

5. **Decision flowchart (Mermaid).** Rebuild and extend `01-…:105–125`, fixing the ch.1 audit's M3 ch.7-placement issue (ch.7 must move from the frequentist branch). Branching on: single unit vs panel; staggered or not; missing data; suspected spillovers; want credible vs prediction interval. Each leaf points to one chapter.

6. **"Where methods agree, where they disagree, why."** Prose grounded in the two forest plots. Likely takeaways: methods agree on direction and order of magnitude on Prop 99 (`-15` to `-19` excluding the deliberately-wrong ITS-ARIMA and the deliberately-wrong DiD-vs-Nevada); they disagree on uncertainty in ways that map onto the assumptions in the taxonomy table; Part II reveals that even within "parallel trends" vs "parallel factors", the data sometimes prefer the simpler model (IFEct collapsing to TWFE).

7. **Common pitfall.** Reading the forest plot as if methods were unbiased estimators of the same true number when in fact each estimator targets a slightly different population quantity under a slightly different identifying assumption.

8. **Exercises.** Match chs.8 and 10's structure: at least 3 exercises that have the reader (a) re-fit one Part-II method on the wider 2001–2007 window to harmonise with ch.8, (b) add a method this chapter didn't fit (e.g. `fixest::sunab` on the CS panel), (c) build the forest plot from the freeze cache themselves.

9. **Further reading.**

**Bibliography additions this chapter will need (not yet in `references.bib`).**

- Roth, J., Sant'Anna, P. H. C., Bilinski, A., & Poe, J. (2023). What's trending in difference-in-differences? *Journal of Econometrics* — canonical landscape review for Part II.
- Imbens, G. (2024) panel-methods review (forthcoming Handbook chapter) — landscape review for the cross-method comparison.
- Possibly Wager & Athey (2018) and Chernozhukov et al. (2018) double-machine-learning, depending on how broad the taxonomy gets.

---

## 5. Proposed structural changes

Synthesizing the per-chapter and cross-cutting audits, six book-level structural recommendations emerge.

### 5.1 Glossary / Notation appendix
**Justification.** `λ` is overloaded three ways across chs.7, 9; `τ` collides between chs.1/6 and ch.7; `α` collides between ch.7 and chs.9/10; `W`/`w` collides across chs.4, 6, 7, 10. See §2.8 and `audit/cross-cutting-notation-arc.md` §1. Each chapter is internally consistent but the cross-chapter map currently lives in the reader's head.
**Form.** A single unnumbered page at the front matter (or an appendix) listing each symbol with its global meaning and any chapter-local override. Reader can flip back when chs.7, 9 introduce conflicting bindings.

### 5.2 "How to read this book" expansion in the preface
**Justification.** Preface lacks audience / prerequisites / forward-link-to-ch.1 (chapter-00 §W3, §W6). Preface thesis ("disagreement is the lesson") is missing (`cross-cutting-notation-arc.md` §2.b).
**Form.** Add `### Who this book is for` (advanced undergrads through early-career researchers, R + econometrics prerequisites) and a closing thesis sentence to the "How to read" paragraph.

### 5.3 Potential-outcomes primer section in ch.1
**Justification.** Ch.1 introduces `Y_{it}(d), D_{it}, ATT` but never names SUTVA (chapter-01 §M4) — which then leaves ch.7's headline contribution ("relax SUTVA") without an anchor. Imputation table conflates point predictions with conditional expectations (chapter-01 §M2).
**Form.** A short subsection between "Causal inference as a missing-data problem" and "Setup and data" that names SUTVA, formalises the conditional-expectation framing of `Ŷ(0)`, and adds the missing pitfalls (ATE vs ATT, never-treated states observe `Y(0)`, treated states do not observe `Y(0)`).

### 5.4 Inference appendix
**Justification.** Each chapter discusses inference in isolation (placebo permutation in ch.4; posterior credible intervals in chs.5, 7; HAC SEs in chs.1, 2, 3; SCPI prediction intervals in ch.6; cluster-robust SEs in ch.8; HonestDiD bounds in ch.8; bootstrap in chs.9, 10). The reader sees seven inference recipes but never the comparison.
**Form.** A short appendix `inference-toolkit.qmd` (or a new chapter 11.5) consolidating: HAC / cluster-robust / Fisher placebo / posterior credible / SCPI prediction / conformal / bootstrap. One paragraph per technique. Useful as a reference and as the inferential half of the proposed cross-method chapter §4.

### 5.5 Live site footer
**Justification.** Phase 1 noted missing footer; live site has no copyright, license, "last updated" timestamp. Combined with chapter-00 §W8 (license note absent from preface) and chapter-00 §W9 (no "how to cite").
**Form.** Add via `_quarto.yml format.html.include-after-body` a small footer partial that prints (a) `© <year> Carlos Mendez`, (b) MIT license badge linking to `LICENSE`, (c) a build timestamp injected from `Sys.time()` at render. One ~20-line HTML/JS block.

### 5.6 Consistent Common-Pitfall template
**Justification.** Chs.4, 5, 7 have proper Common-pitfall callouts; ch.6 lacks a section (only a Recap-table row); ch.8 has a full section; chs.1, 3 have one-sentence pitfalls. Per-chapter audits flag this for ch.1 (§W4), ch.6 (§W1), and implicitly for ch.10 (§W5 overlaps with Recap).
**Form.** A standard template — `## Common pitfall` heading, 2–4 pitfalls with bold subhead each, one sentence per pitfall — applied uniformly across chapters. Ch.6 needs the section added; chs.1, 3 expand the existing one-sentence pitfall into the template form.

---

## 6. Prioritized punch list

Three tables. Each row: chapter/file | line(s) | description | fix sketch | source audit file.

### P1 — must fix (data, code, numerical bugs, broken renders)

| #  | File | Line(s) | Description | Fix sketch | Source |
|----|------|---------|-------------|------------|--------|
| 1  | `02-interrupted-time-series.qmd` | 160–165, 156–157 | `ARIMA(ic = "aicc")` returns NULL; prose disagreement invisible on live site | Replace with explicit `pdq(1,2,0) + PDQ(0,0,0)`; drop `warning: false` | chapter-02 §M1, §C7 |
| 2  | `R/honest_did.R` | 36 | Uses `N·T` rows instead of `N` units → SEs shrunk by `T²=25`; inverts ch.8 HonestDiD story | `n <- nrow(es$inf.function$dynamic.inf.func.e)` | chapter-08 §M1 |
| 3  | `08-staggered-did.qmd` | 339, 352–356, 365–366 | HonestDiD narrative claims breakdown `≈ 1` (depends on #2 bug) | Rewrite to Mbar ≤ 0.5; name the cohort-2006 pre-trend | chapter-08 §M1, §S3 |
| 4  | `10-gsynth.qmd` | 314–333 | Implicit-weights table renders "Table has no data" | Recover names from `out$id.tr`/`out$id.co` before subsetting `wgt.implied` | chapter-10 §C1 |
| 5  | `10-gsynth.qmd` | 357–377 | Cumulative-ATT table empty, `fig-cumulative` flat zero | Use event-time labels (`as.integer(rownames(est_att))`, `filter(event_time >= 0)`) | chapter-10 §C2 |
| 6  | `10-gsynth.qmd` | 408, 449 | Mis-attributes DR DiD to "chapter 9" (lives in ch.8) | s/chapter-9/chapter-8/ | chapter-10 §X1 |
| 7  | `10-gsynth.qmd` | 288, 293 | Factors-plot caption "a single curve is shown" — figure shows two | Rewrite caption to acknowledge FE line + factor line | chapter-10 §M5 |
| 8  | `01-introduction.qmd` | 38–47 | 5 wrong values in missing-data didactic table vs `data/proposition99.rds` | Replace static markdown with live R chunk built from `prop99` | chapter-01 §M1 |
| 9  | `01-introduction.qmd` | 216 | `theme_minimal()` clobbers transparent house theme on first figure of book | Delete trailing `+ theme_minimal()` | chapter-01 §C1 |
| 10 | `01-introduction.qmd` | 121 | Decision-tree leaf `SCM` places ch.7 under "Frequentist + tidy code"; ch.7 is Bayesian | Restructure Q2 — ch.7 to Bayesian branch or its own SUTVA leaf | chapter-01 §M3 |
| 11 | `04-classical-synthetic-control.qmd` | 217–222, 243–249, 301–307 | Three `tidysynth` warnings leak into rendered HTML | `#| warning: false` on each chunk (or chapter-wide) | chapter-04 §3.1 |
| 12 | `04-classical-synthetic-control.qmd` | 76 | Stale "RDD chapter" reference (`03-rd-in-time.qmd` deleted) | s/"ITS, RDD, and DiD chapters"/"ITS and DiD chapters"/ | chapter-04 §3.2 |
| 13 | `04-classical-synthetic-control.qmd` | 187 | `theme_minimal()` clobbers transparent theme on V-matrix bar chart | Delete trailing `+ theme_minimal()` | chapter-04 §3.3 |
| 14 | `03-basic-diff-in-diff.qmd` | 133–134 | `theme_minimal()` clobbers transparent theme on headline parallel-trends figure | Delete trailing `+ theme_minimal()` | chapter-03 §C1 |
| 15 | `06-synthetic-control-prediction-intervals.qmd` | 236, 424, 425 | Prose claims simplex ATT `-19.5`, range `-15` to `-22`; cached is `-11.11`, range `-11` to `-16` | Rewrite three lines to match cached values; add ch.4 reconciliation | chapter-06 §R1 |
| 16 | `06-…prediction-intervals.qmd` | 21 | Error-decomposition LHS sign flipped (`τ_t − τ̂_t` should be `Y_{1t}(0) − Ŷ_{1t}(0)`) | Rewrite equation, add bridge sentence to `τ̂` | chapter-06 §M1 |
| 17 | `06-…prediction-intervals.qmd` | 367, 376, 393, 412–413 | Sensitivity bands mislabeled by Bonferroni factor of 2 | Use `u.alpha = a/2, e.alpha = a/2` so labels are 80/90/95/99 | chapter-06 §R7 |
| 18 | `06-…prediction-intervals.qmd` + `07-bayesian-spatial-sc.qmd` | 5 (both) | Duplicate `## Why a third synthetic-control chapter?` heading | Rename ch.7 to "fourth"; rewrite opening to acknowledge ch.6 | chapter-06 §C3, chapter-07 §1, §2 |
| 19 | `07-bayesian-spatial-sc.qmd` | 313–317 | SAR likelihood equation does not match C++ kernel — third term mis-labelled as time lag | Rewrite as `(I − ρW − ρ w α') Y = X β + Λ F + ε`; explain cross-coupling | chapter-07 §Methodology 1 |
| 20 | `07-bayesian-spatial-sc.qmd` | end of file | Missing Part-I → Part-II handoff (closes Prop 99 case study) | Add closing section "Where this case study ends, and where Part II begins" | chapter-07 §Cross-chapter 3 |
| 21 | `07-bayesian-spatial-sc.qmd` | 482, 501 | "Active-donor count rises monotonically" — counts are 4, 23, 23 | s/"rises monotonically"/"jumps once and then stays flat by construction"/ | chapter-07 §Writing 4 |
| 22 | `05-structural-bayesian-ts.qmd` | 11–17 | Spike-and-slab prior — the chapter's central regularisation device — never named | Add one paragraph after `:17` introducing SSVS, `expected.model.size = 3`, inclusion probabilities | chapter-05 §Methodology 1 |
| 23 | `05-structural-bayesian-ts.qmd` | 171 | "Cumulative CI includes zero only at the very upper edge" — zero is well inside `[-383, +68]` | Rewrite to "zero is comfortably inside the band" | chapter-05 §Code 3 |
| 24 | `05-structural-bayesian-ts.qmd` | 157 | `-21 / 97%` no-covariates fit asserted but no chunk reproduces it | Add `tbl-causalimpact-nocov` chunk; or remove the claim | chapter-05 §Code 4 |
| 25 | `09-matrix-completion-and-ife.qmd` | 270–280 | "IFEct vs MC compared" prose talks as if a non-trivial factor model was fit, but `r = 0` | Add a paragraph after `tbl-cv`; rewrite the comparison | chapter-09 §M1 |
| 26 | `09-matrix-completion-and-ife.qmd` | end | No numeric ATT reported for either method (only gap plots) | Add `tbl-att` chunk extracting `out_ife$att.avg`, `out_mc$att.avg` | chapter-09 §M4 |
| 27 | `index.qmd` | 32 | GitHub link points at `cmg777/ccm` (author's personal mirror) | Change to `quarcs-lab/ccm` | chapter-00 §W1 |
| 28 | `index.qmd` | 11, 13–18 | Part I roadmap claims "Chapters 1–7" but lists only chs.2–7 (omits ch.1) | Add Introduction bullet, or rephrase to "Chapters 2–7 after ch.1 introduces…" | chapter-00 §W2 |
| 29 | `references.bib` | 215–222 | `callaway2022handbook` mis-typed as `@article` | Change to `@incollection`, add `booktitle`, `editor`, `pages` | chapter-11 §P1 |
| 30 | `references.bib` | 83–87, 95–100 | `causalimpact-pkg` and `brodersen-causalimpact-talk` lack `year` (render "(n.d.)") | Add `year = {2024}` to each (or correct year) | chapter-11 §P1 |

### P2 — should fix (methodology gaps, missing references, structural issues)

| #  | File | Line(s) | Description | Fix sketch | Source |
|----|------|---------|-------------|------------|--------|
| P2-1  | `01-introduction.qmd` | 17–77 | SUTVA never named; ch.7's contribution lands without an anchor | Add 1 paragraph after potential-outcomes definition | chapter-01 §M4 |
| P2-2  | `01-introduction.qmd` | 79–97 | Imputation table conflates point prediction with conditional expectation; subscript mismatches on naive + DiD rows | Add 1-sentence preface; hat the BSTS parameters | chapter-01 §M2 |
| P2-3  | `01-introduction.qmd` | 244, 247 | HAC vs OLS "wildly overconfident" claim is only true vs `NeweyWest` | Switch to `NeweyWest` and keep the adjective | chapter-01 §M5, §C2 |
| P2-4  | `01-introduction.qmd` | 235–245 | `naive-prepost` chunk lacks `tbl-` label/caption (CLAUDE.md violation) | Promote to `tbl-naive-prepost` with `ms_pretty(vcov = NeweyWest)` | chapter-01 §C3 |
| P2-5  | `02-interrupted-time-series.qmd` | 5–15 | Identification assumption not stated | Add bold "**Identification.**" sentence | chapter-02 §Methodology 3 |
| P2-6  | `02-interrupted-time-series.qmd` | 154–177 | Zero residual diagnostics | Add `gg_tsresiduals()` + Ljung-Box after `:165` | chapter-02 §Methodology 4 |
| P2-7  | `02-interrupted-time-series.qmd` | 181–203 | ARIMA forecast variance computed but discarded | Add 80/95% PI ribbon via `hilo(fcasts)` | chapter-02 §Methodology 5 |
| P2-8  | `02-interrupted-time-series.qmd` | 127, 202 | Trailing `theme_minimal()` clobbers transparent theme | Delete both | chapter-02 §Code 5 |
| P2-9  | `02-interrupted-time-series.qmd` | 59 | `year0` set up but never used | Use it in OLS or remove | chapter-02 §Code 3 |
| P2-10 | `03-basic-diff-in-diff.qmd` | 9, 116 | Parallel trends asserted but never tested; formal test rejects (HAC p = 0.024) | Add `tbl-pretrends` chunk on 1984–1988 sub-window | chapter-03 §M1 |
| P2-11 | `03-basic-diff-in-diff.qmd` | 45, 93, 109 | HAC SE misjustified on 2-unit panel | Rewrite inference paragraph honestly (HAC + clustering both imperfect at G=2) | chapter-03 §M2 |
| P2-12 | `03-basic-diff-in-diff.qmd` | 11–16 | Canonical DiD population regression never written down | Add `Y = α + β₁ Post + β₂ Treat + τ(Post × Treat) + u` equation | chapter-03 §M3 |
| P2-13 | `03-basic-diff-in-diff.qmd` | 145 | No forward link to ch.8 (staggered DiD), despite ch.1 promising one | Rewrite Further Reading with ch.8 link + Card-Krueger + BDM | chapter-03 §X1 |
| P2-14 | `03-basic-diff-in-diff.qmd` | 139 | Common pitfall covers only "single similar control"; clustering-with-G=2 and Nevada-exogeneity missing | Add 2 more pitfalls | chapter-03 §W1 |
| P2-15 | `04-classical-synthetic-control.qmd` | 254–279 | Leave-one-out / in-time-placebo robustness checks missing | Add leave-one-out for Utah; mention in-time placebo | chapter-04 §3.4 |
| P2-16 | `04-classical-synthetic-control.qmd` | 195 | Common pitfall covers only V-matrix; missing convex-hull / extreme weights / donor contamination | Add 3 pitfalls | chapter-04 §3.5 |
| P2-17 | `04-classical-synthetic-control.qmd` | 361 | Only forwards to ch.5; ch.4 → chs.6, 7 missing | Add 1 sentence | cross-cutting §4 |
| P2-18 | `05-structural-bayesian-ts.qmd` | 126 | Seed comment claims `set.seed(42)` makes MCMC reproducible — `bsts` hard-codes `seed = 1` | Rewrite comment; move seed before `mice()` | chapter-05 §Methodology 7 |
| P2-19 | `05-structural-bayesian-ts.qmd` | 149 | No inclusion-probability figure (ch.4 analogue) | Add `plot(bsts.model, "coefficients")` chunk + 2–3 sentences | chapter-05 §Methodology 5 |
| P2-20 | `05-structural-bayesian-ts.qmd` | 113 | No MCMC convergence check | Add traceplot + ESS sentence | chapter-05 §Methodology 6 |
| P2-21 | `05-structural-bayesian-ts.qmd` | 40 | Comparison to classical SC (simplex vs spike-and-slab priors) never explicit | Add 1 sentence | chapter-05 §Methodology 2 |
| P2-22 | `05-structural-bayesian-ts.qmd` | 193 | No transition out to ch.6 | Add 1 sentence | chapter-05 §Cross-chapter 3 |
| P2-23 | `06-…prediction-intervals.qmd` | 54 | Outcome-only matching breaks comparability with ch.4 without saying so | Add 1 sentence reconciling | chapter-06 §R2 |
| P2-24 | `06-…prediction-intervals.qmd` | 105 | Lasso constraint stated as `‖w‖₁ ≤ 1`; scpi uses `‖w‖₁ ≤ Q` with Q tunable | Rewrite with explicit Q | chapter-06 §M2 |
| P2-25 | `06-…prediction-intervals.qmd` | 259 | No joint-coverage / Bonferroni note before first "95% PI" label | Add 1 paragraph | chapter-06 §M6 |
| P2-26 | `06-…prediction-intervals.qmd` | 240 | `e.method = "gaussian"` labeled "JSS recommendation" — is actually an override | Rewrite to "we override default `'all'`" | chapter-06 §M7 |
| P2-27 | `06-…prediction-intervals.qmd` | 417 | No `## Common pitfall` section (structurally out of step) | Add section with 2 pitfalls | chapter-06 §W1 |
| P2-28 | `06-…prediction-intervals.qmd` | 11 | Conformal-inference alternative never mentioned | Add 1 sentence + bib | chapter-06 §M5 |
| P2-29 | `06-…prediction-intervals.qmd` | 421 | Recap row contrasting SCPI PI with ch.5 credible interval missing | Add row | chapter-06 §C4 |
| P2-30 | `07-bayesian-spatial-sc.qmd` | 317 | Priors on `ρ, σ², β` not stated | Add "Priors at a glance" inline list | chapter-07 §Methodology 2 |
| P2-31 | `07-bayesian-spatial-sc.qmd` | 319 | Two-step plug-in α structure not named as a limitation | Rewrite to flag plug-in approximation | chapter-07 §Methodology 4 |
| P2-32 | `07-bayesian-spatial-sc.qmd` | 353 | No traceplot for ρ | Add `fig-trace-rho` chunk | chapter-07 §Methodology 5 |
| P2-33 | `07-bayesian-spatial-sc.qmd` | 389 | "Forward-simulates the SAR DGP" — actually closed-form Sakaguchi-Tagawa | Rewrite | chapter-07 §Methodology 6 |
| P2-34 | `07-bayesian-spatial-sc.qmd` | 355 | "ρ̂ bounded clearly away from zero" — not at ESS = 2.9 | Soften prose | chapter-07 §Code 6 |
| P2-35 | `07-bayesian-spatial-sc.qmd` | 80 | macOS gfortran shim is Intel-only | Extend glob to `/opt/homebrew/Cellar/gcc/*` | chapter-07 §Code 2 |
| P2-36 | `07-bayesian-spatial-sc.qmd` | 124 | `w` collides with ch.4's `w` (donor weights vs spatial contiguity row) | Add notation note | chapter-07 §Cross-chapter 4 |
| P2-37 | `07-bayesian-spatial-sc.qmd` | between "Cross-stage" and "Recap" | Common pitfall section missing | Add section | chapter-07 §Methodology 8 |
| P2-38 | `08-staggered-did.qmd` | 154–161 | Cohort-2006 pre-trend ATT(2006, 2003) = −0.034, t ≈ −2.7 unflagged | Add 2–3 sentence paragraph after `tbl-attgt` | chapter-08 §M2 |
| P2-39 | `08-staggered-did.qmd` | 180–184 | Overall ATT mislabeled as simple time-weighted mean (code uses `type = "group"`) | Rewrite | chapter-08 §M3 |
| P2-40 | `08-staggered-did.qmd` | 46 | Cohort list disagrees with code | Add "(after dropping 2007 cohort, see Setup)" | chapter-08 §C2 |
| P2-41 | `08-staggered-did.qmd` | 37 | Sun-Abraham named as "companion" but never run | Drop forward-ref OR add `sunab` chunk | chapter-08 §X6 |
| P2-42 | `08-staggered-did.qmd` | 148 | Parallel trends not stated next to estimand | Add 1 sentence | chapter-08 §M6 |
| P2-43 | `08-staggered-did.qmd` | after 377 | No forward link to ch.9 | Add bridge paragraph | chapter-08 §X5 |
| P2-44 | `09-matrix-completion-and-ife.qmd` | 77–84 | `min.T0` framing imprecise; rank constraint is `r < T0` per unit | Rewrite paragraph | chapter-09 §M2 |
| P2-45 | `09-matrix-completion-and-ife.qmd` | 25, 188, 209 | `lemp ~ D` formula omits `lpop + lavg_pay`; ch.10 includes them | Either include covariates or add 1-sentence reconciliation | chapter-09 §M3 |
| P2-46 | `09-matrix-completion-and-ife.qmd` | 160 | `λ_i` (loading) vs `λ` (MC penalty) collision unflagged | Add 1-line glossary note | chapter-09 §X1 |
| P2-47 | `09-matrix-completion-and-ife.qmd` | 129–134 | `panelview()` subsamples 500 of 1,745 counties silently | Pass `display.all = TRUE` or annotate caption | chapter-09 §C1 |
| P2-48 | `09-matrix-completion-and-ife.qmd` | 282–290 | Short-panel callout placed after comparison (postscript) | Move to before `## Estimating with FECT` | chapter-09 §W2 |
| P2-49 | `09-matrix-completion-and-ife.qmd` | end | No Exercises section | Add 3 exercises | chapter-09 §W1 |
| P2-50 | `09-matrix-completion-and-ife.qmd` | end | No forward link to ch.10 | Add 1 sentence | chapter-09 §X3 |
| P2-51 | `10-gsynth.qmd` | 27–33 | gsynth's two-step procedure mentioned but not spelled out | Add numbered list | chapter-10 §M1 |
| P2-52 | `10-gsynth.qmd` | 222–238 | "IC-selected rank" misleading (IC min is r=0; chapter filters `r ≥ 1`) | Relabel "pedagogical override" + transparency sentence | chapter-10 §M2 |
| P2-53 | `10-gsynth.qmd` | 255, 270 | Gap and counterfactual x-axes show event time; axis title says "Year" | s/"Year"/"Event time"/ | chapter-10 §C3 |
| P2-54 | `10-gsynth.qmd` | 175–181 | `cv.nobs = 8` arithmetic uses legacy defaults | Rewrite to current `cv.nobs = 3` default | chapter-10 §M3 |
| P2-55 | `10-gsynth.qmd` | 5–23 | Hook omits chs.5, 6; gsynth-as-generalisation-of-ch.4 link not explicit | Add 1 paragraph and family table | chapter-10 §M4, §X2 |
| P2-56 | `references.bib` | various | Orphans (3): `abadie2003economic`, `bai2003inferential`, `fpp3-pkg` | Cite or remove | chapter-11 §P2 |
| P2-57 | `references.bib` | missing | Card-Krueger, BDM, Wagner, Scott-Varian, mice, George-McCulloch, CWZ, Roth et al. | Add 8 entries | per-chapter audits |
| P2-58 | `_quarto.yml` + new file | — | No cross-method comparison chapter (README promises one) | Draft `11-comparison.qmd` per §4 | cross-cutting §3.c |
| P2-59 | `index.qmd` | various | No "Who this book is for" / no ATT gloss / no forward link to ch.1 / no License section | Multiple edits per chapter-00 §W3, §W4, §W6, §W8 | chapter-00 |
| P2-60 | Live site | footer | Missing copyright, license badge, build timestamp | Add `format.html.include-after-body` footer partial | Phase 1 |

### P3 — nice-to-have (polish, theming, additional exercises)

| #  | File | Line(s) | Description | Source |
|----|------|---------|-------------|--------|
| P3-1  | `01-introduction.qmd` | 75 | Recentred-year-index note for chs.2, 4 | chapter-01 §X1 |
| P3-2  | `01-introduction.qmd` | 75 | "Unit i = 1 is notation, code uses `state == 'California'`" parenthetical | chapter-01 §X2 |
| P3-3  | `01-introduction.qmd` | 7–15 | Reorder first 2 paragraphs so Prop 99 puzzle lands first | chapter-01 §W1 |
| P3-4  | `01-introduction.qmd` | 189 | Inline 116.21 → 60.35 arithmetic | chapter-01 §W3 |
| P3-5  | `01-introduction.qmd` | 251 | Expand Common Pitfall into 3–4 bullets | chapter-01 §W4 |
| P3-6  | `01-introduction.qmd` | 276–284 | Annotate Further Reading bullets with categories | chapter-01 §W5 |
| P3-7  | `01-introduction.qmd` | 133–157 | Lift `theme_set` + `dev.args` into `R/setup_theme.R` | chapter-01 §C4 |
| P3-8  | `01-introduction.qmd` | 101–127 | Rename "Which method when?" → "Choosing a method" | chapter-01 §W2 |
| P3-9  | `02-interrupted-time-series.qmd` | 86–91 | HAC SE on linear-trend regression | chapter-02 §Methodology 6 |
| P3-10 | `02-interrupted-time-series.qmd` | 113–127 | Mask growth-curve dashed line to post-period | chapter-02 §Writing 3 |
| P3-11 | `02-interrupted-time-series.qmd` | 209–211 | Sharpen "ARIMA misbehaves" pitfall with "d=2 has no level anchor" | chapter-02 §Methodology 7 |
| P3-12 | `02-interrupted-time-series.qmd` | end of §6 | Add `**Recap.**` bullet matching ch.3's structure | chapter-02 §Writing 1 |
| P3-13 | `02-interrupted-time-series.qmd` | 28 | Drop or annotate `set.seed(42)` (no stochastic step) | chapter-02 §Code 4 |
| P3-14 | `02-interrupted-time-series.qmd` | 219 | Extend closing handoff to name chs.6, 7 | chapter-02 §Cross-chapter 3 |
| P3-15 | `03-basic-diff-in-diff.qmd` | 7 | Add hook tying back to ch.2 | chapter-03 §W2 |
| P3-16 | `03-basic-diff-in-diff.qmd` | 120 | Trim editorialising figure caption | chapter-03 §W3 |
| P3-17 | `03-basic-diff-in-diff.qmd` | 73 | Quantify Nevada's adjacency claim | chapter-03 §M4 |
| P3-18 | `03-basic-diff-in-diff.qmd` | 56 | Annotate `set.seed(42)` as hygiene-only | chapter-03 §C3 |
| P3-19 | `03-basic-diff-in-diff.qmd` | 42 | Orphan paragraph between sections | chapter-03 §W5 |
| P3-20 | `03-basic-diff-in-diff.qmd` | 16 | Reconnect to ch.1's `Ŷ_{1t}(0)` notation | chapter-03 §X4 |
| P3-21 | `03-basic-diff-in-diff.qmd` | section order | Reorder: visual diagnostic *before* fit (design call) | chapter-03 §W4 |
| P3-22 | `02-interrupted-time-series.qmd` | 219 | Fix stale "uses the other 38 states" promise about ch.3 (ch.2 edit) | chapter-03 §X2 |
| P3-23 | `04-classical-synthetic-control.qmd` | 157, 355 | "Western/sunbelt" → "Mountain-West" | chapter-04 §3.6 |
| P3-24 | `04-classical-synthetic-control.qmd` | 134–142 | Recap says 5 donors; table prints 8 (`head(8)`) | chapter-04 §3.7 |
| P3-25 | `04-classical-synthetic-control.qmd` | 211, 214, 354 | Hard-coded `-18.85` should be inline `r round(mean(sc_post$dif), 2)` | chapter-04 §3.8 |
| P3-26 | `04-classical-synthetic-control.qmd` | 59 | Drop or comment `set.seed(42)` | chapter-04 §3.10 |
| P3-27 | `04-classical-synthetic-control.qmd` | 158 | "Less than 9%" — say "*four non-lagged* covariates" explicitly | chapter-04 §3.11 |
| P3-28 | `05-structural-bayesian-ts.qmd` | 83, 92, 179 | Name `mice(m=1)` as "*single* random-forest imputation" explicitly | chapter-05 §Methodology 8 |
| P3-29 | `05-structural-bayesian-ts.qmd` | 153 | "Posterior SD ≈ 11" closer to 10 | chapter-05 §Code 2 |
| P3-30 | `05-structural-bayesian-ts.qmd` | 179 | Add "inclusion probability ≠ causal weight" pitfall | chapter-05 §Writing 4 |
| P3-31 | `05-structural-bayesian-ts.qmd` | 195–197 | Thin Further Reading (3 entries); add Scott-Varian, mice, George-McCulloch | chapter-05 §Writing 5 |
| P3-32 | `06-…prediction-intervals.qmd` | 11, 436 | Add CWZ 2021 conformal pointer + Stata/Python `scpi` companion | chapter-06 §M5, §W5 |
| P3-33 | `06-…prediction-intervals.qmd` | 246, 301, 358 | Add `set.seed(42)` inside each scpi chunk | chapter-06 §R3 |
| P3-34 | `06-…prediction-intervals.qmd` | 258, 313, 373 | Drop redundant `cores = 1` | chapter-06 §R5 |
| P3-35 | `06-…prediction-intervals.qmd` | 265, 320 | Silence `geom_ribbon` NA warnings | chapter-06 §R6 |
| P3-36 | `06-…prediction-intervals.qmd` | 236 | Replace "economically meaningful amount" with %-of-baseline | chapter-06 §W3 |
| P3-37 | `06-…prediction-intervals.qmd` | 111, 144 | Unify donor count between table (10) and heatmap (12) | chapter-06 §W4 |
| P3-38 | `06-…prediction-intervals.qmd` | terminology | Unify "PI" / "band" / "ribbon" | chapter-06 §W2 |
| P3-39 | `06-…prediction-intervals.qmd` | 262 | Show `str(pi_simplex$inference.results$CI.all.gaussian)` | chapter-06 §R4 |
| P3-40 | `06-…prediction-intervals.qmd` | 15–17 | Add 1-sentence notation bridge to ch.4 | chapter-06 §C1 |
| P3-41 | `07-bayesian-spatial-sc.qmd` | 420 | "Order of magnitude" → "≈16× the next-largest" | chapter-07 §Writing 5 |
| P3-42 | `07-bayesian-spatial-sc.qmd` | 197 | Note Makalic-Schmidt 2015 parametrisation | chapter-07 §Methodology 3 |
| P3-43 | `07-bayesian-spatial-sc.qmd` | 425 | Define 4 prior-predictive statistics in prose | chapter-07 §Methodology 7 |
| P3-44 | `07-bayesian-spatial-sc.qmd` | 51–52 | Annotate `MCMC_ITER` / `MCMC_BURN` with rescale instructions | chapter-07 §Code 5 |
| P3-45 | `07-bayesian-spatial-sc.qmd` | 268, 307 | Surface "only Nevada's interval excludes zero" outside fig caption | chapter-07 §Writing 3 |
| P3-46 | `07-bayesian-spatial-sc.qmd` | 511 | Rephrase Recap row with units explicit | chapter-07 §Writing 6 |
| P3-47 | `07-bayesian-spatial-sc.qmd` | 5–9 | "Tutorial scale" appears 5×; replace 2 with concrete "5,000-iteration" | chapter-07 §Writing 9 |
| P3-48 | `R/scspill/41_robustness_check.R` | 38–40, 176–177, 428–429 | Functions read globals `W`, `w` instead of arguments `W_raw`, `w_raw` | chapter-07 §Code 3 |
| P3-49 | `R/scspill/22_mcmc_sar.R` | 43 | `sar_gibbs_sampler` calls non-existent `sar_full_sampler_cpp` | chapter-07 other 3 |
| P3-50 | `_freeze/` | — | Remove orphans `_freeze/06-bayesian-spatial-sc/`, `_freeze/07-synthetic-control-prediction-intervals/` | Phase 1 |
| P3-51 | repo root | — | Delete loose `10-gsynth_files/` and `10-gsynth_cache/` (gitignored already) | chapter-10 §C5 |
| P3-52 | `08-staggered-did.qmd` | 5 | Rename "When Basic DiD breaks" → "When TWFE breaks under staggered adoption" | chapter-08 §S1 |
| P3-53 | `08-staggered-did.qmd` | 27–31 | Split Goodman-Bacon vs de Chaisemartin–d'Haultfœuille critiques | chapter-08 §M4 |
| P3-54 | `08-staggered-did.qmd` | 39–41, 307–315 | Contrast smoothness vs relative-magnitudes restrictions | chapter-08 §M5 |
| P3-55 | `08-staggered-did.qmd` | 415 | Extend Exercise 1 with bias trade-off for not-yet-treated controls | chapter-08 §M7 |
| P3-56 | `08-staggered-did.qmd` | 405 | Add Roth-Sant'Anna-Bilinski-Poe 2023 to Further Reading | chapter-08 §S5 |
| P3-57 | `08-staggered-did.qmd` | 64 | Annotate `set.seed(42)` as hygiene-only | chapter-08 §C3 |
| P3-58 | `09-matrix-completion-and-ife.qmd` | 154–160 | Make MC objective explicit: `‖Y_obs − Ŷ(0)‖²_F + λ ‖Ŷ(0)‖_*` | chapter-09 §M5 |
| P3-59 | `09-matrix-completion-and-ife.qmd` | 2 | Rename file title to "Interactive Fixed Effects and Matrix Completion" (body order) | chapter-09 §W3 |
| P3-60 | `09-matrix-completion-and-ife.qmd` | 113 | Back-reference to ch.8's data section for `lemp` definition | chapter-09 §W4 |
| P3-61 | `09-matrix-completion-and-ife.qmd` | 124–135 | Suppress `panelview` stderr (`message: false`, `warning: false`) | chapter-09 §C2 |
| P3-62 | `09-matrix-completion-and-ife.qmd` | 170–172 | Justify `r = 0:2` grid relative to `min.T0` | chapter-09 §C4 |
| P3-63 | `09-matrix-completion-and-ife.qmd` | 33 | Add `@liu2024practical` to IFEct attribution | chapter-09 §X4 |
| P3-64 | `09-matrix-completion-and-ife.qmd` | 319 | Add gsynth / MCPanel pointers + ch.10 forward in Further Reading | chapter-09 §W5 |
| P3-65 | `10-gsynth.qmd` | 194 | Note that `inference = "nonparametric"` is silently aliased to `"bootstrap"` | chapter-10 §C4 |
| P3-66 | `10-gsynth.qmd` | section name | Rename `## Recap` → `## Reconciliation` | chapter-10 §W1 |
| P3-67 | `10-gsynth.qmd` | 451–462 | Add gsynth vignette + 2017 *Political Analysis* replication archive | chapter-10 §W2 |
| P3-68 | `10-gsynth.qmd` | 206 | Cite `[@bai2003inferential]` properly in tbl-cap (not just "Bai 2003") | chapter-10 §X5 |
| P3-69 | `10-gsynth.qmd` | 431 | Add back-reference to ch.4 in Further Reading | chapter-10 §X3 |
| P3-70 | `references.bib` | 102–109 | `sakaguchi2026spatial` missing volume/number/pages | chapter-11 §P2 |
| P3-71 | `references.bib` | 37–45 | `brodersen2015inferring` missing `number = {1}` | chapter-11 §P2 |
| P3-72 | `references.bib` | various | Package names sentence-cased (`Tidysynth`, `Scpi`) — protect with `{{...}}` | chapter-11 §P3 |
| P3-73 | `install_packages.R` vs `DESCRIPTION` | — | Document the drift (intentional per CLAUDE.md but unstated) | Phase 1 |
| P3-74 | `README.md` | — | "~24 entries" claim — actual 27 (24 cited); update post-orphan-trim | Phase 1 |
| P3-75 | Notation appendix | new file | Add front-matter glossary of symbols (see §5.1) | cross-cutting §1 |
| P3-76 | Preface | — | Add closing thesis sentence ("disagreement is the lesson") | cross-cutting §2.b |
| P3-77 | `_quarto.yml` and chapters | — | Add closing forward-pointer sentence to each of chs.4, 5, 6, 8, 9 | cross-cutting §2.c |
| P3-78 | All Part-I chapters | — | Window inconsistencies (1970–2000 vs 1984–1993) annotated as a methodological lever | cross-cutting §3.a |
| P3-79 | Inference appendix | new file | Consolidate placebo / posterior / HAC / MCMC / bootstrap inference patterns | §5.4 |

---

## Appendix: how to read the per-chapter reports

The per-chapter reports under `audit/` contain the line-precise evidence behind every claim in this synthesis:

- `audit/chapter-00-preface.md` — preface (`index.qmd`)
- `audit/chapter-01.md` — Introduction
- `audit/chapter-02.md` — Interrupted Time Series
- `audit/chapter-03.md` — Basic Differences-in-Differences
- `audit/chapter-04.md` — Classical Synthetic Control
- `audit/chapter-05.md` — Structural Bayesian Time Series
- `audit/chapter-06.md` — Synthetic Control with Prediction Intervals
- `audit/chapter-07.md` — Bayesian Spatial Synthetic Control
- `audit/chapter-08.md` — Staggered Differences-in-Differences
- `audit/chapter-09.md` — Matrix Completion and Interactive Fixed Effects
- `audit/chapter-10.md` — Generalized Synthetic Control
- `audit/chapter-11-references.md` — References / bibliography hygiene
- `audit/cross-cutting-notation-arc.md` — notation, narrative arc, case-study coherence

Each per-chapter report follows the same structure: Summary → Strengths → Methodology issues → Code & reproducibility issues → Cross-chapter consistency → Writing & structure → Prioritized fix list. Section IDs (e.g. `§M1`, `§C2`, `§W4`) referenced in this synthesis correspond to those per-chapter section headers. The cross-cutting report follows: Notation map → Narrative arc → Case-study coherence → Cross-references → Decision-tree consistency → Priorities.

When in doubt about a claim in this synthesis, follow the `[Source]` pointer in the relevant table cell or section to the line-precise evidence in the per-chapter report.
