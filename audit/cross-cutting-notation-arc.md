# Cross-cutting audit: notation, narrative arc, and case-study coherence

Scope: `index.qmd`, `01-introduction.qmd` … `10-gsynth.qmd`, `references.qmd`. All line numbers refer to the files at the audit snapshot (commit `1718668` / working tree on `main` 2026-05-17). The audit is intentionally *book-level*: per-chapter prose, code, and table issues are handled by sibling reports.

---

## 1. Notation map across chapters

| Symbol | First defined in | Reused in | Meaning | Consistent? |
|---|---|---|---|---|
| `$Y_{it}(0)$`, `$Y_{it}(1)$` | `01-introduction.qmd:25-26` | `02:74`, `04:241` (as `Y_{1t}(0)`), `06:17`, `09:25`, `10:27` | Untreated / treated potential outcome for unit `i` at time `t` | **Yes** — used consistently. Chs.2/4 collapse the `i` index to `1` (California), which is fine when one unit is treated; the substitution is signalled in `01:73` (`unit i = 1 denotes California`). |
| `$Y_{it}$` | `01:30` | `08:22`, `09:25`, `10:27` | Observed outcome | Mostly consistent. **`05:15` and `08:22` use lowercase `$y_{it}$` / `$y_{1t}$`** while every other chapter uses uppercase. Cosmetic but visible. |
| `$\tau_{it}$` | `01:57` | — | Individual treatment effect | Defined once. Never reused (a teaching loss — the ITE → ATT → ATT(g,t) ladder is built up and then `\tau_{it}` is dropped). |
| `$\tau$` (no subscript) | `01:227` (`\hat\tau_\text{naive}`), `03:15` (`\hat\tau_\text{DiD}`), `06:21` (`\tau_t - \hat\tau_t`) | `07:197` (**horseshoe global shrinkage hyperparameter**), `10:401` (`\hat\tau`) | Treatment-effect estimator or estimand | **COLLISION (P1).** `07-bayesian-spatial-sc.qmd:197` redefines `$\tau$` as the global horseshoe scale parameter (`$\tau \sim \mathcal{C}^+(0,1)$`) in the same chapter that later uses `att_classic`, `att_hs`, `att_sar` for the treatment effects. The reader who has been tracking `\tau` as "treatment effect" since ch.1 hits this without warning. |
| ATE | `01:63` | — | `E[Y(1) - Y(0)]` over a population | Defined, then dismissed ("ATE is *not* what we are after here"). Never reused, as intended. |
| ATT | `01:69` | `02:78,148`, `03:9`, `04:45`, `05:154`, `06:23`, `07:160`, `08:140`, `10:33` | `E[Y(1) - Y(0) | D = 1]` | **Yes** — the spine of the book. |
| ATT(g, t) | `01:77` (sketched), `08:146` (full definition) | `09:295` (callout), `10:404` | Group-time ATT for cohort `g` at time `t` | **Yes**, but `01:77` defers the definition to ch.8 — a 7-chapter wait before the symbol is properly introduced. Acceptable because Part I doesn't use it. |
| `$D_{it}$` | `01:28` | — | Treatment indicator | **Defined once and never reused as a math symbol.** Ch.3's regression uses `prepostPost` (the R name); ch.8 uses `\text{post}_{it}` (line 22), `post`, `D`, and `treat` in different places. P3 inconsistency — the reader trained on `D_{it}` in ch.1 sees four different stand-ins later. |
| `$\text{Post}_t \times \text{Treat}_i$` interaction | Implicit in `03:15` (DiD identity) and `03:101` (R formula `state * prepost`) | `08:22` (`\beta \cdot \text{post}_{it}` for TWFE) | DiD interaction | The 2×2 DiD identity (`03:15`) is shown in algebraic form but the canonical DiD regression `Y_{it} = \alpha_i + \gamma_t + \beta D_{it} + \epsilon` is **never written as an equation in ch.3** — it only appears later, in `08:22`. A reader who skipped to ch.3 for DiD never sees the regression form. P2. |
| `$i$, $t$, $g$` | `01:23, 28, 77` | universal | Unit, time, treatment cohort | **Yes**. |
| `$\widehat{Y(0)}$` | `01:79` (table heading) | `02:74,148`, `04:43`, `06:17` | The imputed-counterfactual centrepiece | **Yes** — this is the book's organising symbol and is used consistently in Part I. **Not reused in ch.7** (which writes the synthetic as `Y_{c,\text{pre}}\,\alpha`) and **not used in ch.8** (`08:146` writes `Y_{it}(\infty)` instead — the Callaway-Sant'Anna convention). The "every method imputes `\widehat{Y(0)}`" thesis from `01:99` therefore weakens visibly in chs. 7-8. P2. |
| `$W$` | `04:35-39` (V-matrix is `V`, not `W`; donor weights are `w`); `06:17` (lowercase `w`) | **`07:110, 315-317` (row-normalised spatial adjacency matrix)**, `10:317` (R variable `W` for implied-weight matrix) | Donor weights *vs* spatial adjacency matrix *vs* gsynth implied-weight matrix | **COLLISION (P1).** `$W$` and `$w$` are used for at least three distinct objects across chs.4, 6, 7, 10 without a single warning to the reader. Ch.7 line 109-111 defines `w` (lowercase, California's contiguity row) and `W` (uppercase, donor contiguity matrix) within five lines of switching from `\alpha`-weights to spatial-`W` matrix. The same chapter then refers to the "horseshoe weights `\alpha`" — the very symbol that *was* the weight vector in chs.4 and 6. Plain-English glosses do appear at `07:124` ("California's contiguity row `w`" and "the 38×38 donor contiguity matrix `W`") so the in-chapter intro is clean; the cross-chapter collision is what's unmanaged. |
| `$\lambda_i$` | `01:96` (table), `09:25-27`, `10:27` | **`07:197` (horseshoe local shrinkage)**, **`09:159, 166, 226, 301, 316` (nuclear-norm penalty)** | Factor loading vector *vs* horseshoe local-shrinkage *vs* nuclear-norm penalty weight | **COLLISION (P1).** Triply overloaded: factor loading (chs.9, 10, also `01:96`), horseshoe local-shrinkage hyperparameter (`07:197`), and the MC nuclear-norm penalty (`09:159, 226, 301`). Ch.9 *itself* writes the factor-model equation with `\lambda_i' f_t` (line 25) and four sections later writes "the penalty weight `$\lambda$` plays the role of `r`" (line 159) without flagging the collision. The reader has no way to know whether `lambda.cv` (line 230) refers to a loading or a penalty without re-reading. |
| `$F_t$` / `$f_t$` | `01:96` (`f_t`), `09:25` (`f_t`), `10:27` (`f_t`) | — | Time-`t` latent factor vector | Mostly consistent at lowercase. `09:34` writes `(\alpha, \xi, \Lambda, F)` — first appearance of capital `F` (factor matrix); no plain-English gloss. Minor. |
| `$\rho$` (autocorrelation) | `02` — **never appears** | `07:315-317, 347-352` | Spatial autoregressive (SAR) parameter | **No collision in the current draft** (ch.2 uses `\phi` for AR coefficients and `\theta` for MA coefficients — see `02:144`). The pre-emptive warning in the audit brief turned out to be unwarranted. |
| `$\bar M$` (HonestDiD breakdown) | `08:315` | — | Relative-magnitude bound: post-period violation ≤ `\bar M` × largest observed pre-period violation | **Yes**, defined once in ch.8 with full plain-English gloss; survives across the chapter's two tables. |
| MSPE | `04:267, 283, 297` | `09:150` (used in passing without re-defining) | Mean squared prediction error / pre-period RMSE^2 used as a placebo statistic | Defined once with plain English ("mean squared prediction error"); ch.9 reuses without the gloss but the meaning is unambiguous in context. |
| ESS | `07:339, 358-361` | — | Markov-chain effective sample size for the SAR `\rho` posterior | Defined once with full plain-English gloss including the rule of thumb. |
| `$\alpha$` | `07:130, 197, 199, 315` (donor weights, horseshoe sample) | **`09:25, 10:27` (unit fixed effects `\alpha_i`)** | Donor weights *vs* unit fixed effects | **COLLISION (P1).** Ch.7 uses `\alpha_j` as a horseshoe-prior donor weight; chs.9/10 use `\alpha_i` as the unit fixed effect in the factor-model equation. The reader crossing the Part-I → Part-II boundary at chs.7→8→9 sees `\alpha_i + \xi_t + \lambda_i' f_t` (line 9:25) and needs to silently re-bind `\alpha` from "donor weight" to "unit FE". |
| `$x_t$`, `$X$`, `$X_1$` / `$X_0$` | `04:33`, `05:15`, `07:315` | — | Predictor matrix / covariate vector | Inconsistent: ch.4 uses uppercase `X_1, X_0` (predictor matrices); ch.5 uses lowercase `x_t` (covariate vector); ch.7 uses `X_{c,t}\beta`. No collision but no convention either. Minor. |

### Notation issues by priority

- **P1 collisions.** `\tau` (treatment effect vs horseshoe scale), `\lambda` (factor loading vs MC penalty vs horseshoe local scale), `\alpha` (donor weights in ch.7 vs unit FE in chs.9/10), `W` / `w` (donor weights vs spatial adjacency vs implied-weight matrix in ch.10). All four would benefit from a *Notation* page or a Notation appendix early in the book that fixes the global meanings and then either (a) flags each chapter's local override or (b) re-letters the local one. The current per-chapter plain-English glosses are good but they don't reach a reader who is treating the book as a reference rather than a sequential read.
- **P2 inconsistencies.** Lowercase `$y_{it}$` (chs.5, 8) vs uppercase `$Y_{it}$` (everywhere else). The "every method imputes `\widehat{Y(0)}`" through-line is broken in chs.7 and 8. The DiD canonical regression form is missing from ch.3 but appears in ch.8.
- **P3 inconsistencies.** `$D_{it}$` defined once in ch.1, then replaced by `prepostPost` (R name), `post_{it}` (ch.8 math), `D` and `treat` (R names in chs.8-10) without a math-side bridge. The capital `F` for the factor matrix (`09:34`) is introduced inside parentheses without a gloss.

---

## 2. Narrative arc audit

For each chapter, the first 60 and last 60 lines were read. Where a recap or hand-off was a single sentence at chapter end, that sentence is quoted in compressed form.

| Chapter | Opening hook | Closing / recap | Hand-off to next chapter? |
|---|---|---|---|
| `index.qmd` (Preface) | "*Comparative Causal Metrics* is an introduction to **regional impact evaluation**…two parts, each anchored by a running case study and a different family of estimators." (line 7) | "the entire book is available as a PDF download in the navbar" plus an Acknowledgments paragraph — no thematic close. | **Weak.** The Preface lists the chapters but never signposts what the reader will *learn* from sequencing — the two parts are described in parallel, not sequentially. The "the disagreements between estimators applied to the same data are the lesson of this book" thesis appears only in `01:274`, not in the Preface. |
| `01-introduction.qmd` | "How do you measure the causal effect of a policy when you cannot randomise who gets treated?" (line 7) — the strongest hook in the book. | Roadmap of all chapters (lines 253-274), then `## Further reading` with chapter-by-chapter bib pointers. Strong. | **Yes.** Explicit forward links to every other chapter, plus an explicit Part-I → Part-II framing at line 268. |
| `02-interrupted-time-series.qmd` | "Interrupted time series (ITS) drops the comparison unit entirely…Where the naive pre-post estimate of chapter 1 assumes 'no change'…" (line 7) — strong callback to ch.1. | "Where this leaves us." paragraph at line 219 explicitly hands off to chs.3, 4, 5 by name: "chapter 3 (Differences-in-Differences) uses the other 38 states…chapter 4 (Synthetic Control) builds a weighted donor pool…chapter 5 (Bayesian Structural Time Series) combines both…" | **Yes**, strong. |
| `03-basic-diff-in-diff.qmd` | "Difference-in-Differences picks one control state — Nevada, for this chapter…" (line 7). Direct callback to ITS via "treats its pre-to-post change as the counterfactual change". | "DiD against Nevada says $-5.7$ packs…**Synthetic Control (chapter 4) is the principled response**: instead of one control state, blend many states…" (line 141) | **Yes**, strong. |
| `04-classical-synthetic-control.qmd` | "Synthetic Control stops using one control state. Instead, it builds a *weighted combination* of donor states…**Why it works where DiD failed.**" (lines 7-9). Direct callback to ch.3. | Recap table (lines 351-359) + "In chapter 5 we hand the same donor information to a Bayesian model…" (line 361) | **Yes**, strong handoff to ch.5. **No forward link to chs.6 or 7** — the synthetic-control family-of-three is not framed inside ch.4. P2. |
| `05-structural-bayesian-ts.qmd` | "Fit a **Bayesian structural time-series (BSTS)** model on the pre-period. Use *other states' cigarette sales*…" (line 7). Implicit callback to ch.4 ("only method in the book that delivers a *credible* interval" — line 9). | Recap paragraph (line 183) + recap table (lines 187-192). | **No.** Ch.5 ends with no hand-off to ch.6. The reader does not learn that ch.6 will revisit synthetic control with PIs. P2. |
| `06-synthetic-control-prediction-intervals.qmd` | "Chapter 4 fit the classical synthetic-control estimator…Chapter 5 produced posterior credible intervals…What is still missing is a **frequentist** uncertainty story…" (lines 7-9). Excellent two-chapter callback. | Recap table (lines 421-429). | **No.** Ch.6 ends with a recap and "Further reading" but no signpost that ch.7 will add spatial spillovers to the same SCM family. P2. |
| `07-bayesian-spatial-sc.qmd` | "Chapter 4 fit a *classical* Synthetic Control…Chapter 5 borrowed donor information in a different way…Both treat the donor states' outcomes as *unaffected* by California's policy. That assumption — the **stable unit treatment value assumption (SUTVA)** — is the price of any synthetic-control estimate." (lines 7-9). Strong. | Recap table (lines 506-513) + Further reading. | **No, and this is the Part-I → Part-II seam.** Ch.7 ends without any mention of ch.8, staggered adoption, or the dataset change. The closing recap is purely intra-chapter. P1 — see §2.a below. |
| `08-staggered-did.qmd` | "Chapter 3 ran a textbook 2×2 DiD on Proposition 99, with California treated in 1989 and Nevada as the single hand-picked control…The dataset is no longer Proposition 99." (lines 7-49). Strong callback to ch.3 *and* explicit announcement of the dataset switch. | Recap callout (lines 360-377) + Common pitfall + Exercises. The recap reconciles TWFE / CS overall / DR conditional / event-study. | **No.** Ch.8 ends with Common pitfall + Exercises but no signpost to chs.9 or 10. The "factor-model escape valves" framing from `01:127` is not echoed here. P2. |
| `09-matrix-completion-and-ife.qmd` | "Chapter 8 squeezed every drop of usable signal out of the Callaway-Sant'Anna minimum-wage panel under one identifying assumption: **parallel trends**." (lines 7-13). Strong. | Recap callout (lines 294-308) + Common pitfall + Further reading. | **No** — ch.9 ends without a signpost to ch.10 (which is the natural narrowing from the IFE-and-MC family to the standalone gsynth walkthrough). P2. |
| `10-gsynth.qmd` | "Earlier chapters have asked the same counterfactual question in different ways. Chapter 4 (classical SCM) hand-built a weighted donor average for a single treated unit. Chapter 7 layered a spatial prior on top…this chapter does the focused walkthrough of one specific estimator in that family — **generalized synthetic control (gsynth)** [@xu2017generalized] — using the standalone `gsynth` package on the same Callaway-Sant'Anna minimum-wage panel as chapter 8." (lines 7-18). Strongest cross-Part hook in the book. | Recap callout (lines 395-428) — explicit numeric comparison to chs.8 TWFE / CS / DR. | **N/A — this is the last method chapter.** Ch.10 does *not* signpost the planned cross-method comparison chapter that the README and Preface promise. P2. |
| `references.qmd` | `# References {.unnumbered}` only. No prose. | Same. | N/A. |

### 2.a Part-I → Part-II seam (chs.7 → 8)

The case-study switch (Prop 99 → CS minwage) is the single most consequential transition in the book. The seam is handled **asymmetrically**:

- **Ch.7's closing (line 506-513)** is a recap callout focused on the Bayesian-spatial three-stage comparison. There is *zero* mention of staggered adoption, the second dataset, or even the existence of chs.8-10. The reader who finishes ch.7 has no warning that the next chapter changes the dataset, the outcome, and the estimand (single ATT → ATT(g,t) family). P1.
- **Ch.8's opening (line 7-49)** does the work, twice. Lines 7-32 frame the staggered-adoption problem (callback to ch.3) and lines 44-49 announce the dataset switch ("The dataset is no longer Proposition 99…We switch to the Callaway-Sant'Anna minimum-wage panel"). So the preparation is one-sided: ch.8 carries the whole burden.

**Concrete fix.** Add one paragraph to the end of `07-bayesian-spatial-sc.qmd` (after the recap table, before "Further reading") signposting that (i) chs.1-7 share one dataset and one treated unit, (ii) ch.8 introduces the staggered-adoption setting that requires a different panel, (iii) the ATT(g, t) framework generalises the ATT-on-California estimand.

### 2.b Preface vs book arc

The Preface (`index.qmd:7-29`) lists chapters by family but does not state the thesis (estimator disagreement is the lesson) — that thesis is buried in `01:274` and `README.md:42-47`. A two-sentence addition to the Preface — "Each method estimates the same ATT from a different data source and a different identifying assumption; the disagreements between estimators on the same dataset are the lesson of this book" — would bring the Preface into alignment with the body. P2.

### 2.c Missing recaps / signposts

Five chapters (4, 5, 6, 8, 9) end without a signpost to the next chapter. Only chs.1, 2, 3 carry the chain forward in their closing paragraphs. The decision tree at `01:105-125` is the master forward-link but it is consulted once and never repeated. P2 across the board; recommend adding a single closing sentence to each of chs.4-9 along the lines of ch.2's hand-off.

---

## 3. Recurring case-study coherence

### 3.a Part I — Proposition 99 (chs.1-7)

| Chapter | Method | Headline ATT (packs / capita / yr, 1989-2000) | Uncertainty quantification | Source line |
|---|---|---|---|---|
| 1 | Naive pre-post (1984-1993 window) | **`-27.0`** | HAC SE; descriptive only, not causal | `01:189, 247` |
| 2 | ITS — linear growth curve | **`-28.3`** | none reported | `02:130, 215` |
| 2 | ITS — ARIMA(1,2,0) AICc | **`+4.5`** (wrong sign) | none reported | `02:205, 215` |
| 3 | Basic DiD (CA vs Nevada, 1984-1993) | **`-5.68`** (≈ `-5.7`) | HAC SE 5.39, p ≈ 0.31 | `03:112, 141` |
| 4 | Classical SCM (tidysynth, full predictor set) | **`-18.85`** | Fisher exact p ≈ 0.026 (rank 1 of 39); MSPE ratio ≈ 124 | `04:214, 354-358` |
| 5 | BSTS / CausalImpact (with covariates) | **`-13`** (average); cumulative ≈ `-154` over 12 yrs | 95% CrI ≈ `[-32, +5.7]`; posterior prob of effect ≈ 92% | `05:153-155, 188` |
| 5 | BSTS / CausalImpact (cigsale only) | **`-21`** | posterior prob ≈ 97% | `05:157` (prose only, no separate table row) |
| 6 | scpi — simplex | **`-19.5`** | 95% PI (Gaussian, u-misspecified) — observed below band by late 1990s | `06:236, 424` |
| 6 | scpi — lasso / ridge / OLS | range **`-15` to `-22`** | same | `06:236` |
| 7 | Stage 1 Classical SCM (cigsale + retprice only) | **`-18.5`** | none in Stage 1 (point only) | `07:124, 191` |
| 7 | Stage 2 Bayesian horseshoe | **`-15.8`** | 95% CrI from posterior (never crosses 0) | `07:240-244, 309` |
| 7 | Stage 3 Bayesian SAR spillover | between Stage 1 and Stage 2 (≈ `-17` from line 355 wording) | "narrowest but least trustworthy CrI" at tutorial scale | `07:355, 483-503` |

**Coherence analysis.**

1. **The numerical narrative is coherent and the disagreements are explained.** The ladder runs `-27` (naive, biased) → `-28.3` (ITS growth, equally biased and the chapter says so) → `-5.7` (DiD, single-control collapse, chapter says so) → `-18.85` (SCM, headline) → `-13` to `-21` (BSTS, scpi, spatial). The chapters that disagree with the SCM headline (ITS-ARIMA, basic DiD) each *explain why* in their recap (`02:215`, `03:141`).

2. **Window inconsistencies.** Ch.1 uses **1984-1993** for the naive estimate (`01:233-244`); ch.3 also uses **1984-1993** (`03:73`); chs.2, 4, 5, 6 use **1970-2000** (or **1989-2000** post). The window choice changes the magnitude (the naive estimate would be `-56` over 1970-2000 vs `-27` over 1984-1993) but the book never tabulates the window choice as a methodological lever. This shows up specifically at `02:130` where the prose says "essentially identical to the naive pre-post `-27.0`" — but the `-27.0` is the **1984-1993** estimate while the `-28.3` ITS estimate is fit on the **1970-1988** window. The two numbers are not directly comparable as the prose implies. P2.

3. **Ch.7's Stage 1 = `-18.5`** is methodologically the same as ch.4's `-18.85` but uses a *narrower predictor set* (`cigsale + retprice` only — ch.7 line 124 explains this). That's a deliberate replication choice and is documented. Good.

4. **Ch.7 Stage 3 ATT is never given a clean numeric value in the prose** — the recap says "between the classical and Bayesian-horseshoe estimates" (`07:355`) but no exact figure. The reader has to inspect the rendered HTML table to know what `att_sar` evaluates to. P2 — if the planned cross-method comparison chapter wants to forest-plot the ten estimates, ch.7 Stage 3 needs a stable inline number.

5. **Headline-vs-recap mismatch in ch.5.** The chapter recap (`05:183, 188`) reports `-13` packs as the headline, but the same chapter's prose (`05:157`) gives `-21` packs as the no-covariate variant. Two different numbers for the "same" method depending on covariate inclusion. The recap doesn't show both — a reader skimming only the recap misses that the covariate choice is what swings the estimate by 8 packs. P2.

### 3.b Part II — CS minwage (chs.8-10)

| Chapter | Method | Headline ATT (log teen employment) | Uncertainty | Source line |
|---|---|---|---|---|
| 8 | TWFE (post indicator) | **`-0.038`** | cluster-robust SE | `08:134, 362` |
| 8 | CS overall ATT (sample-weighted) | **`-0.057`** | bootstrap SE; CI from `aggte` | `08:199, 363` |
| 8 | CS conditional · regression adjustment | ≈ `-0.057` to `-0.065` (table cell) | same | `08:294-299` |
| 8 | CS conditional · IPW | ≈ same range | same | `08:294-299` |
| 8 | CS conditional · doubly robust (headline conditional) | **`-0.065`** | same | `08:302, 363` |
| 8 | CS event-study aggregation | `-0.024` on impact → `-0.13` by event-time +3 | per-event-time bootstrap CI | `08:224, 364` |
| 8 | HonestDiD breakdown (relative-magnitude) | breakdown `\bar M ≈ 1` | robust CIs as function of `\bar M` | `08:352, 366` |
| 9 | IFEct | **never given numerically in prose** (gap-plot only) | bootstrap CI on the plot | `09:262, 295-308` |
| 9 | MC | **never given numerically in prose** (gap-plot only) | bootstrap CI on the plot | `09:262, 295-308` |
| 10 | gsynth, r = 0 | **printed inline as `` `r sprintf("%.3f", ic_tbl$ATT[ic_tbl$r == 0])` ``** (R inline expression, evaluates at render time to ≈ `-0.04`, close to ch.8 TWFE) | bootstrap SE in `ic_tbl` | `10:401` |
| 10 | gsynth, r* (IC-selected, r = 1) | **printed inline as `` `r sprintf("%.3f", out$att.avg)` ``** (evaluates to ≈ `-0.07` to `-0.08`) | bootstrap SE | `10:402-403` |

**Coherence analysis.**

1. **Ch.9 reports no numeric ATT.** The chapter never extracts `out_ife$att.avg` or `out_mc$att.avg` into a sentence or a recap row. The recap says only "Both point downward; both sit in the same neighbourhood" (`09:305`). For a book whose thesis is "the disagreements between methods are the lesson", that is a hole — ch.9 cannot disagree (or agree) with anything because it doesn't tell us its number. P1 for ch.9.

2. **Ch.10 leans on ch.8's numbers, ch.9's are unavailable.** Ch.10's recap (`10:395-411`) compares gsynth-r* against ch.8 TWFE (`-0.038`), CS overall (`-0.057`), DR conditional (`-0.065`). It does *not* compare against ch.9 IFEct or MC because there is no ch.9 number to compare against. The chain ch.8 → ch.9 → ch.10 should produce a four-method, two-window comparison; instead ch.10 has to skip ch.9.

3. **Window inconsistency.** Ch.8 uses **2003-2007**; chs.9 and 10 use **2001-2007** (chs. explain this — they need more pre-periods to identify factors). But ch.10's recap (`10:401-405`) compares its 2001-2007 gsynth-r* numbers to ch.8's 2003-2007 TWFE / CS numbers without re-running ch.8 on the wider window. The reader sees a four-number reconciliation in which two of the four numbers come from a different sample. P2.

4. **The Rambachan-Roth breakdown survives.** The `\bar M ≈ 1` finding (`08:352`) is the only sensitivity-analysis result in Part II, and it is the closest analogue to Part I's MSPE-ratio / placebo machinery. Nothing in ch.9 or ch.10 calls back to it.

### 3.c Joint coherence: the cross-method comparison chapter is loadbearing

The README promises (`README.md:46-47`): *"Cross-method comparison chapter — bring the ten ATT estimates onto one forest plot and discuss the disagreements."* Three structural prerequisites that block that chapter:

- Ch.5 needs a single canonical headline (currently two: `-13` with covariates, `-21` without).
- Ch.7 Stage 3 needs a stable inline number rather than a "between the other two" gloss.
- Ch.9 needs to extract `out_ife$att.avg` and `out_mc$att.avg` into the recap.

Without these three fixes, the planned forest-plot chapter cannot tabulate the methods consistently.

---

## 4. Cross-references

| Forward / back link the audit brief expected | Present? | Where |
|---|---|---|
| Ch.4 (classical SC) → ch.6 (scpi) "we'll revisit with prediction intervals" | **No** | Ch.4's recap (`04:361`) hands off only to ch.5. P2. |
| Ch.4 (classical SC) → ch.7 (spatial SC) "we'll revisit with spillovers" | **No** | Same recap, no forward to ch.7. P2. |
| Ch.5 (BSTS) → ch.4 contrast "Bayesian regression weights vs convex SC weights" | **Weak.** | Ch.5 opens with "only method in the book that delivers a *credible* interval" (`05:9`) but never *contrasts* its donor-weight structure against ch.4's convex simplex. The reader doesn't learn that BSTS's `\beta` regression coefficients can be negative or sum to anything, while ch.4's `w_j` cannot. P2. |
| Ch.8 (CS) → ch.3 (basic DiD) by name | **Yes, twice.** | `08:7-13` (opening) and `08:187` ("staggered-DiD analogue of chapter 3's single DiD coefficient"). Best back-reference in the book. |
| Ch.10 (gsynth) → ch.4 (classical SC) as generalization | **Yes.** | `10:7-18` ("Chapter 4 (classical SCM) hand-built a weighted donor average for a single treated unit…this chapter does the focused walkthrough of one specific estimator in that family"). |
| Ch.6 → ch.4 explicit "see ch.4" | **Yes.** | `06:7-9, 138, 291, 349, 423, 436`. Densest cross-reference network in the book. |
| Ch.7 → ch.4 explicit | **Yes.** | `07:7, 124, 520`. |
| Ch.10 → ch.9 "this chapter does the focused walkthrough of one estimator in the IFE family covered in ch.9" | **Yes.** | `10:12-15, 460-463`. |
| Ch.9 → ch.10 forward | **No.** | Ch.9 (`09:294-308, 319-326`) doesn't mention that ch.10 narrows to gsynth. P2. |
| Ch.1 forward links to every chapter | **Yes.** | `01:86-97, 105-125, 254-274`. |

### Cross-reference gaps to fix

1. **Ch.4 → chs.6, 7 forward link.** Currently `04:361` only forwards to ch.5. The SCM family (ch.4 + ch.6 + ch.7) reads as three independent chapters rather than a coherent sub-arc. P2.
2. **Ch.5 → ch.4 contrast.** Ch.5 borrows donor information differently but never says so. P2.
3. **Ch.9 → ch.10 forward.** The two factor-model chapters need a "see ch.10 for the standalone gsynth walkthrough" sentence. P3.

---

## 5. Decision tree consistency (intro chapter)

The mermaid decision tree at `01:105-125` is the master map. Mapping each leaf node to the corresponding chapter:

| Tree leaf | Chapter pointer in node label | Chapter exists? | Method covered there? |
|---|---|---|---|
| `NAIVE` ("Naive pre-post") | "this chapter" (i.e., ch.1 §"A first attempt") | Yes — `01:221-251` | Yes |
| `ITS` ("Interrupted Time Series") | (ch. 2) | Yes | Yes |
| `DiD` ("Basic Difference-in-Differences") | (ch. 3) | Yes | Yes |
| `SCM` ("Classical Synthetic Control + prediction intervals via scpi + spatial spillovers") | (ch. 4) + (ch. 6) + (ch. 7) | Yes / Yes / Yes | Yes / Yes / Yes |
| `CI` ("Structural Bayesian TS") | (ch. 5) | Yes | Yes |
| `CSA` ("Staggered DiD / Callaway-Sant'Anna") | (ch. 8) | Yes | Yes |
| `MC` ("Matrix Completion / IFE") | (ch. 9) | Yes | Yes |
| `GSC` ("Generalized Synthetic Control") | (ch. 10) | Yes | Yes |

**Result.** No orphaned methods. Every leaf maps to an extant chapter. **One minor mismatch:** the tree's `SCM` leaf bundles chs.4, 6, 7 into a single node ("Classical Synthetic Control + prediction intervals via scpi + spatial spillovers"), which is reasonable as a *decision-time* grouping (you decide "SCM family" first, then pick the variant) — but this is the same bundling that the book's body fails to make explicit (see §4 gap #1: ch.4 doesn't forward to chs.6, 7). So the intro tree promises a unified SCM family that the chapter bodies don't fully deliver. P2.

A second minor observation: the tree's `Q2` ("Frequentist + tidy code" vs "Bayesian + uncertainty bands") forces the reader to choose between SCM and BSTS, but ch.7 (Bayesian Spatial SCM) is *both Bayesian and SCM*. The tree doesn't have a leaf for "Bayesian SCM with spillovers" as a standalone — ch.7 is hung off the SCM node, which is the correct grouping but a reader might expect it on the BSTS side. Not a P-anything issue, just an asymmetry worth knowing.

---

## Summary: priorities

### P1 — Must fix before the cross-method comparison chapter

- **`\tau` collision** (`07:197` vs ch.1 / ch.6 treatment-effect uses). Rename horseshoe scale to `\tau_h` or `\sigma_\tau` or `\tau_{HS}`, and add a sentence after `07:197` flagging the rename.
- **`\lambda` triple collision** (factor loading, MC penalty, horseshoe local shrinkage). Pick distinct symbols: `\lambda_i` for loading (chs.9, 10); `\eta` or `\nu` for the MC penalty (currently `\lambda` at `09:159, 226, 301`); `\lambda_{j,HS}` for the horseshoe local scale at `07:197`. The collision is most acute *inside ch.9* because the chapter equation `Y(0) = α_i + ξ_t + λ_i' f_t + ε` and the CV hyperparameter `lambda.cv` appear nine lines apart.
- **`\alpha` collision** (donor weights ch.7 vs unit FE chs.9, 10). Easiest fix: keep `\alpha_i` for unit FE (matches the panel-econometrics convention used in chs.9, 10) and rename ch.7's donor weights to `w` (matches chs.4, 6).
- **`W` collision** (donor-weight matrix / spatial adjacency / gsynth implied-weight matrix). Convention recommendation: use `w` for donor-weight vectors (already standard in chs.4, 6), keep `W` reserved for the *spatial* adjacency matrix in ch.7, and rename ch.10's `wgt.implied` to `\Omega` in prose (the code variable `W` can stay).
- **Ch.7 → ch.8 hand-off.** Add a closing paragraph to ch.7 announcing the dataset switch and the ATT(g, t) generalisation. The Part-I → Part-II seam currently has the prep only on the ch.8 side.
- **Ch.9 missing headline number.** Extract `out_ife$att.avg` and `out_mc$att.avg` into the recap callout. Without this, the cross-method comparison chapter cannot include ch.9.

### P2 — Improve before publication

- **Notation appendix or front-matter table.** A single page listing each symbol, its global meaning, and any chapter-local overrides would let the book function as a reference. Currently each chapter is internally consistent but the cross-chapter map is in the reader's head.
- **Lowercase / uppercase `Y_{it}` vs `y_{it}` mismatch** (`05:15-40`, `08:22`). Pick uppercase everywhere.
- **`\widehat{Y(0)}` thread breaks in chs.7-8.** Ch.7 writes `Y_{c,\text{pre}}\,\alpha` instead; ch.8 writes `Y_{it}(\infty)`. Either rebind the symbol explicitly or write `\widehat{Y(0)}` once in each chapter as the bridge.
- **Cross-references inside ch.4** to chs.6 and 7 are missing.
- **Cross-reference inside ch.5** contrasting BSTS weights vs SCM weights is missing.
- **Closing signposts** missing on chs.4, 5, 6, 8, 9. One sentence each.
- **Window inconsistencies.** Ch.2's prose ("essentially identical to the naive pre-post `-27.0`") compares fits on different windows; either re-run on a common window or flag the discrepancy.
- **Ch.7 Stage 3 ATT** needs a stable inline number for the forest plot.
- **Ch.5 headline ambiguity** between `-13` (with covariates) and `-21` (no covariates).
- **Decision tree promise** (SCM as a unified family) vs ch.4's failure to forward-link to chs.6, 7.
- **Preface thesis statement** ("disagreement is the lesson") not in the Preface.
- **Window inconsistency in Part II** (ch.8 = 2003-2007, chs.9-10 = 2001-2007) acknowledged inside chs.9-10 but not on the ch.8 side.

### P3 — Polish

- **DiD canonical regression form** (`y = α + γ + βD + ε`) missing from ch.3 but appears in ch.8.
- **`$D_{it}$` notation** introduced in ch.1, displaced by `post`, `D`, `treat`, `prepost` in code without a math-side bridge.
- **Capital `F` factor matrix** at `09:34` introduced without a plain-English gloss.
- **`X_1, X_0` vs `x_t` vs `X_{c,t}`** capitalisation choices for predictor matrices vary between chs.4, 5, 7.
- **Ch.9 → ch.10 forward link** missing.
