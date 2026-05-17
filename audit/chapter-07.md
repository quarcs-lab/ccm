# Audit: Chapter 07 — Bayesian Spatial Synthetic Control

File audited: `/Users/carlosmendez/Documents/GitHub/ccm/07-bayesian-spatial-sc.qmd` (521 lines).
Cross-checked against the rendered `_book/07-bayesian-spatial-sc.html`, the cached `_freeze/07-bayesian-spatial-sc/execute-results/html.json`, and the vendored helpers under `/Users/carlosmendez/Documents/GitHub/ccm/R/scspill/`.

**Cached numerical outputs (ground truth for prose):**

| Quantity                            | Cached value                |
|-------------------------------------|-----------------------------|
| Stage 1 ATT (classical SCM)         | -18.46                      |
| Stage 2 ATT (Bayesian HS)           | -15.84, CrI [-21.76, -9.48] |
| Stage 3 ATT (Bayesian Spatial SAR)  | -16.59, CrI [-16.78, -16.39]|
| Posterior mean ρ                    | 0.223                       |
| ESS(ρ)                              | 2.9                         |
| Active donors (Stage 1 / 2 / 3)     | 4 / 23 / 23                 |
| Nevada spillover                    | -3.75 packs/capita          |
| Next-largest spillover (Idaho/Utah) | -0.228 packs/capita         |
| Nevada / Idaho ratio                | ≈ 16.4x                     |

---

## 1. Methodology

**Strengths.** The Mermaid three-stage pipeline (lines 20–32) is a strong visual scaffold; the prose explicitly motivates each relaxation (simplex at Stage 2, SUTVA at Stage 3); the ESS-too-low caveat is given its own callout-warning (lines 357–361) with a concrete remedy (`MCMC_ITER = 100000L`); and the cross-stage comparison table is the right closing move.

**Issues.**

1. **The SAR likelihood is mis-stated — the chapter's "spatial lag" equation is not the model the code fits.** Lines 313–317 give:
   $$Y_{c,t} = \rho W Y_{c,t} + X_{c,t}\beta + Y_c^{\text{lag}}\alpha + \varepsilon_t.$$
   The "$Y_c^{\text{lag}}\alpha$" term reads as a **temporal** lag of donor outcomes weighted by α, but the C++ kernel at `R/scspill/20_mcmc.cpp:254–255` builds `A_const = W + w * alpha.t()` and fits `(I - ρ A) Y_{c,t} = X_t β + Λ F_t + u_t`. Rearranging:
   $$Y_{c,t} = \rho W Y_{c,t} + \rho \, w \, (\alpha^\top Y_{c,t}) + X_{c,t}\beta + \Lambda F_t + u_t.$$
   The third term is **not** a time lag; it is the cross-coupling that propagates the treated unit's outcome into the donor pool via California's contiguity row `w` (this is the Sakaguchi-Tagawa identification trick — the same α from Stage 2 plays double duty as the spatial-feedback weights). The chapter also silently drops the dynamic-factor term $\Lambda F_t$ even though it passes `p_factors = 1L` to `sc_spillover()` at line 333. Both of these are first-order misrepresentations.
   - `07-bayesian-spatial-sc.qmd:315`: replace the equation with
     $$(I - \rho W - \rho\, w\,\alpha^\top)\, Y_{c,t} \,=\, X_{c,t}\beta + \Lambda F_t + \varepsilon_t,$$
     and add one paragraph below explaining the three coefficients: $\rho W Y_{c,t}$ is donor-to-donor spillover; $\rho w (\alpha^\top Y_{c,t})$ is the donor-pool's joint reaction relayed through California's neighbours; $\Lambda F_t$ is a $p=1$ latent dynamic factor capturing unobserved common shocks; $\varepsilon_t$ is i.i.d. noise. State that the same α from Stage 2 enters here — it is **not** re-estimated jointly with ρ (Step 2 of the sampler conditions on $\hat\alpha$ from Step 1; see `R/scspill/10_sc_spillover.R:78–82`).

2. **Priors on ρ, σ², β are nowhere stated.** The chapter writes out the horseshoe hierarchy for α (line 197) but the Stage-3 priors are silent. The code uses:
   - $\rho \sim$ Uniform on the spectral-bounded interval $\big({-}0.95/\rho_{\max}(W),\,0.95/\rho_{\max}(W)\big)$ (`R/scspill/20_mcmc.cpp:223–224`, with the explicit `logprior_rho` term commented out at `R/scspill/20_mcmc.cpp:452–453`, leaving a flat prior on the support).
   - $\sigma^2 \sim$ InverseGamma($a_0=1, b_0=1$) (`R/scspill/20_mcmc.cpp:436`; the chapter passes the default).
   - $\beta$ — improper flat prior plus a tiny ridge $s^2 \cdot 10^{-6}$ for numerical stability (`R/scspill/20_mcmc.cpp:418`).
   - `07-bayesian-spatial-sc.qmd:317`: add a "Priors at a glance" inline list immediately after the equation: *"Priors used: $\rho \sim$ Uniform on the stability interval $(-0.95/\rho_{\max}(W), \, 0.95/\rho_{\max}(W))$; $\sigma^2 \sim$ InverseGamma(1, 1); $\beta$ flat with a $10^{-6}$ ridge for numerical stability; α inherits its Stage-2 horseshoe hierarchy (fixed at its Step-1 posterior mean during Step 2)."*

3. **The horseshoe is stated correctly but the implementation differs from the textbook form, and the chapter does not flag this.** Line 197 writes the Carvalho-Polson-Scott parametrisation with two half-Cauchies. The C++ Gibbs at `R/scspill/20_mcmc.cpp:125–160` implements the **Makalic-Schmidt 2015** auxiliary-variable form (inverse-gamma latents `nu_sigma_i`, `nu_tau`), which is *equivalent in distribution* but easier to sample. Pedagogically fine, but worth one parenthetical so a reader who tries to read the C++ does not panic when they cannot find a half-Cauchy.
   - `07-bayesian-spatial-sc.qmd:197`: append the sentence: *"The C++ sampler uses the equivalent Makalic-Schmidt (2015) auxiliary-variable parametrisation — same posterior, easier conditionals."*

4. **The chapter never names the two-step sampling structure as a limitation.** `sc_spillover()` runs Step 1 (sample α with horseshoe) and Step 2 (sample ρ holding α fixed at $\hat\alpha$) — it does not sample α and ρ jointly (`R/scspill/10_sc_spillover.R:70–82, 101–117`). This **plug-in approximation** is standard practice but should be flagged: posterior uncertainty in α does not propagate into the ρ posterior, which is one structural reason the Stage-3 CrI is artificially narrow on top of the low-ESS reason.
   - `07-bayesian-spatial-sc.qmd:319`: replace "runs both MCMC samplers (horseshoe α then SAR ρ) and post-processes the per-state spillover effects in one call" with: *"runs the two MCMC samplers sequentially — first horseshoe α (Step 1), then SAR ρ holding α fixed at its Step-1 posterior mean $\hat\alpha$ (Step 2) — and post-processes the per-state spillover effects in one call. **This is a plug-in approximation, not a fully joint posterior**: uncertainty in α does not propagate into the ρ posterior, which is one of two structural reasons the Stage-3 credible interval below is artificially narrow (the other being the low effective sample size for ρ at tutorial scale)."*

5. **No MCMC diagnostics for α are shown, and only a single ESS scalar is shown for ρ.** The chapter does not display a traceplot, a Geweke z, or an R̂ for any parameter, even though `R/scspill/04_utils_diagnostics.R` exposes a `diagnostics.scspill()` method that produces exactly this. The chapter only prints ESS(ρ) (line 339) and lets it speak for itself. A reader can see *that* the chain is bad but not *how* bad — and the chapter never confirms the α chain is healthy at 5,000 iterations.
   - `07-bayesian-spatial-sc.qmd:353`: add a chunk after the Stage-3 print:
     ```r
     #| label: fig-trace-rho
     #| fig-cap: "Traceplot of ρ over the 2,500 post-burn iterations. At tutorial scale the chain visibly fails to mix — the visual diagnosis behind ESS = 2.9."
     #| fig-width: 8
     #| fig-height: 3
     tibble(iter = seq_along(fit_sar$rho_draws), rho = fit_sar$rho_draws) |>
       ggplot(aes(iter, rho)) +
       geom_line(color = "#6a9bcc", linewidth = 0.4) +
       labs(x = "Iteration (post-burn)", y = expression(rho))
     ```
     A traceplot is the *single most important* MCMC diagnostic and the chapter cannot honestly tell readers "raise iterations" without showing them the visual it would fix.

6. **The Stage-3 spillover narrative is metaphorically loose.** Line 389 says: *"The framework computes the average post-treatment effect on each donor by forward-simulating the SAR DGP with and without California's treatment, integrating over the posterior draws of ρ."* This is not what `compute_cf_and_spill()` does. The code at `R/scspill/10_sc_spillover.R:129–141` applies the **closed-form identification formulas (5)(6)** of Sakaguchi-Tagawa: $Y_c^{cf} = (I - \rho A)^{-1}[(I - \rho W) Y_c - \rho w Y_0]$, then `spill = Y_c - Y_c^{cf}`. No forward simulation occurs.
   - `07-bayesian-spatial-sc.qmd:389`: rewrite as *"The framework recovers the per-donor counterfactual outcome in closed form by applying the Sakaguchi-Tagawa identification formula to each posterior draw of ρ: $Y_c^{cf} = (I - \rho A)^{-1}\big[(I - \rho W) Y_c - \rho\, w\, Y_0\big]$, where $A = W + w\,\alpha^\top$. The per-donor spillover is then $Y_c - Y_c^{cf}$, averaged over draws."*

7. **The prior-predictive section omits its own headline.** Line 422 says *"Before reading Stage 3 as a posterior, we want to confirm that the prior specification is compatible with what the data actually look like."* Good motivation. But the four statistics in the figure are introduced only by name (`yc_mean`, `spatial_quadratic`, `ac1`, `pve_pc1`) with no definition. A reader does not know what `spatial_quadratic` means (it is the Moran-like quadratic form $\text{tr}(Y_c^\top W Y_c) / NT_0$; see `R/scspill/41_robustness_check.R:323`), nor what `pve_pc1` measures, nor *why* these four were picked.
   - `07-bayesian-spatial-sc.qmd:425`: add two sentences before the chunk: *"We focus on four summary statistics: **donor mean** (level), **spatial $Y'WY/NT_0$** (the quadratic form whose magnitude is the textbook Moran-like measure of how strongly neighbours co-move), **lag-1 autocorrelation** (does the prior generate AR(1)-shaped donor series?), and **PC1 variance share** (how strongly is the simulated panel dominated by one common factor?). Together they pin down the prior's behaviour on the dimensions that matter for an SCM fit: level, spatial structure, persistence, and low-rank dependence."*

8. **"Common pitfall" section is missing.** Chapters 2–5 each have one. The closest ch.7 offers is the ESS callout. Given how many ways this pipeline can fail silently (low ESS, plug-in α, gfortran toolchain, single-chain run), an explicit pitfall section would be valuable.
   - Add a section between "Cross-stage comparison" and "Recap" titled "Common pitfall: tutorial-scale MCMC and the credibility of credible intervals", consolidating the ESS warning, the plug-in-α point (issue 4), and a sentence on chain count ("`sc_spillover()` runs a single chain; for paper-grade work run 3–4 chains and compute R̂").

---

## 2. Code & reproducibility

1. **The `_freeze/06-bayesian-spatial-sc/` cache directory is orphaned and should be deleted.** The chapter was renamed from `06-bayesian-spatial-sc.qmd` to `07-bayesian-spatial-sc.qmd` in commit `1718668`, and the corresponding freeze cache was rebuilt under `_freeze/07-bayesian-spatial-sc/`. The old `_freeze/06-bayesian-spatial-sc/` still exists (created May 17 20:00), with the same content hash (`81db26d5d8b120aac9a9159fba3a2222`) as the new one. Since `_freeze/` is gitignored this does not pollute the repo, but on a working checkout it costs disk and is one more thing to think about. Phase-1 noted exactly this.
   - Action: `rm -rf /Users/carlosmendez/Documents/GitHub/ccm/_freeze/06-bayesian-spatial-sc/`. (No `.qmd` edit needed.)

2. **The macOS gfortran shim at lines 79–89 is fragile and does not cover Apple Silicon.** The probe `Sys.glob("/usr/local/Cellar/gcc/*/lib/gcc/*")` is Intel-Homebrew only. On Apple Silicon (M1/M2/M3) the path is `/opt/homebrew/Cellar/gcc/*/lib/gcc/*` (or `/opt/homebrew/lib/gcc/current` for the symlinked layout). On a fresh M-series Mac the `length(brew_libs) >= 1L` test fails, the shim is skipped, and `Rcpp::sourceCpp()` then fails on `-lemutls_w`. On Linux and Windows the outer `Sys.info()[["sysname"]] == "Darwin"` correctly short-circuits, so those platforms are fine.
   - `07-bayesian-spatial-sc.qmd:80`: extend the glob list to cover both layouts:
     ```r
     brew_libs <- c(
       Sys.glob("/usr/local/Cellar/gcc/*/lib/gcc/*"),    # Intel Homebrew
       Sys.glob("/opt/homebrew/Cellar/gcc/*/lib/gcc/*"), # Apple Silicon Homebrew
       Sys.glob("/opt/homebrew/lib/gcc/current")          # symlinked layout
     )
     ```
   - `07-bayesian-spatial-sc.qmd:73–74`: also rewrite the prose paragraph above the chunk to be explicit that the shim is a **best-effort fallback** and that readers on M-series Macs without `/opt/gfortran` (the CRAN-blessed location) or any Homebrew gcc will need to install gfortran manually before the chunk will succeed. Suggested wording: *"If neither `/opt/gfortran/` nor a Homebrew `gcc` install is present, the chunk silently skips the override and `Rcpp::sourceCpp()` will fail at link time with `-lemutls_w`. The fix in that case is to install gfortran from <https://mac.r-project.org/tools/> (the CRAN-blessed toolchain) or via Homebrew (`brew install gcc`)."*

3. **`prior_predictive()` and its siblings read globals when they should read arguments.** In `R/scspill/41_robustness_check.R:428–429` the function body calls `row_normalize(W)` and `as.numeric(w)` — referencing global symbols `W` and `w`, **not** the function arguments `W_raw` and `w_raw`. The same bug exists in `run_mcmc_for_posterior` (lines 38–40) and `prior_sensitivity` (lines 176–177). The chapter "works" only because lines 109–111 of the .qmd happen to define globals named `W` and `w`; on any other call site this would silently fit the wrong model.
   - `R/scspill/41_robustness_check.R:428–429`: replace with `W_use <- row_normalize(W_raw)` and `w_use <- as.numeric(w_raw)`. Same fix at lines 38–40 and 176–177.
   - Not strictly a chapter bug, but worth flagging because the chapter currently masks it.

4. **Seeds are set well; nothing to change.** `set.seed(SEED)` is called at chunk setup (line 54), again before Stage 2 (line 222), and `seed = SEED` is passed into `sc_spillover()` which calls `set.seed(seed)` internally (`R/scspill/10_sc_spillover.R:32`). The prior-predictive call also passes `seed = SEED` (line 444). Reproducibility is solid.

5. **`MCMC_ITER` and `MCMC_BURN` should be defined together with a comment on why both are 5,000 / 2,500.** At present line 51–52 reads `MCMC_ITER <- 5000L; MCMC_BURN <- 2500L`. A 50% burn-in is unusually aggressive — it implicitly trusts the chain to have converged by iteration 2,500, which the ESS = 2.9 result then disproves. The callout-warning fixes this for the reader but the constants themselves should carry a `#` comment of their own so the next maintainer does not silently bump only one of the two.
   - `07-bayesian-spatial-sc.qmd:51–52`: add an inline comment: `MCMC_ITER  <- 5000L   # tutorial scale; raise to 100000L for paper-grade ρ ESS` and `MCMC_BURN  <- 2500L   # half of MCMC_ITER; bump to 50000L when MCMC_ITER hits 100000L`.

6. **The cached number `Posterior mean rho: 0.223 | ESS(rho) = 2.9` flatly contradicts a phrase in the prose.** Line 355 reads: *"The posterior mean $\hat\rho$ is bounded clearly away from zero — moderate spatial autocorrelation, as the cross-border intuition predicts."* With ESS = 2.9, $\hat\rho = 0.223$ is **not** bounded "clearly" away from zero — the chain has barely moved from its starting value of 0.0 (see `R/scspill/20_mcmc.cpp:234`). The honest reading is: *"the chain has wandered slightly into positive territory but with this little effective information we cannot say whether ρ is bounded away from zero."* The callout that follows three lines later concedes the issue for the *interval*, but the prose still asserts a *point* claim that is not supported.
   - `07-bayesian-spatial-sc.qmd:355`: replace with: *"The posterior mean $\hat\rho \approx 0.223$ is positive (consistent with the cross-border intuition that neighbours co-move), but at ESS = 2.9 the chain has barely moved from its starting value of 0; the magnitude of $\hat\rho$ should not be over-read at tutorial scale. The callout below explains how to recover the publication-grade $\hat\rho$."*

---

## 3. Cross-chapter consistency

1. **The chapter is mis-numbered in its own opening heading.** Line 5 reads `## Why a third synthetic-control chapter?` — this is **identical** to the opening heading of chapter 6 (`06-synthetic-control-prediction-intervals.qmd:5`, also `## Why a third synthetic-control chapter?`). Both can't be right: ch.6 is the third SC-adjacent chapter (after ch.4 classical and ch.5 BSTS), and ch.7 is the fourth. The auditor's prompt explicitly says "fourth SC chapter". This is a clear copy-paste from ch.6 that escaped the rename and the freshly-drafted preceding chapter.
   - `07-bayesian-spatial-sc.qmd:5`: rename to `## Why a fourth synthetic-control chapter?` and adjust the next paragraph to acknowledge ch.6.

2. **The opening narrative skips chapter 6 entirely.** Line 7 reads: *"Chapter 4 fit a classical Synthetic Control: donor weights live on the simplex... Chapter 5 borrowed donor information in a different way — through a Bayesian structural time-series model. Both treat the donor states' outcomes as unaffected by California's policy."* Chapter 6 (synthetic control with prediction intervals via `scpi`) is invisible in this lineage, even though it is the immediately-preceding chapter and also uses the simplex+SUTVA setup. A reader who arrives in order is left wondering whether ch.6 was for some reason not on the SC trajectory.
   - `07-bayesian-spatial-sc.qmd:7`: insert one sentence after the chapter-5 reference: *"Chapter 6 then put a finite-sample frequentist prediction interval around the classical fit and relaxed the simplex to lasso / ridge / OLS — but, like chapters 4 and 5, retained SUTVA."* Then the next sentence ("Both treat the donor states' outcomes as unaffected...") becomes "All three treat..." to match.

3. **No hand-off to Part II / chapter 8 at the chapter's end.** This is the **last Part-I chapter**: chapter 8 switches dataset (CS minwage), case study (1,745 counties × 5 years), and methodological family (staggered DiD), per `CLAUDE.md` lines 9 and 75. The chapter ends after "Further reading" with no indication that the reader is about to leave the Proposition 99 case study they have been working with for six chapters. Chapter 6's own ending also has no Part-II hand-off, so this is consistent within the current state of the book, but ch.7 is the *right* place for the hand-off to live since ch.7 closes Part I.
   - Add a new section between "Recap" and "Further reading" titled "Where this case study ends, and where Part II begins":
     > *"This is the last chapter that works the Proposition 99 case study. Across seven chapters we have asked the same question — did California's 1989 tobacco tax reduce per-capita cigarette consumption? — under progressively weaker assumptions: an interrupted time series (ch.2), a 2×2 difference-in-differences (ch.3), classical synthetic control on the simplex (ch.4), a Bayesian structural time-series counterfactual (ch.5), a frequentist prediction interval around the SC fit (ch.6), and finally a Bayesian spatial relaxation of both the simplex and SUTVA (this chapter). The headline survives every reframe: the estimated ATT is consistently between roughly $-15$ and $-19$ packs per capita, and never crosses zero. The headline survives because Proposition 99 is a single-treated-unit case with a clean pre-period and one large, sharp policy break. Most real-world policy data is messier: many units adopt at different dates, treatment effects evolve, and parallel-trends violations need to be diagnosed rather than assumed away. Part II (chapters 8–10) leaves Proposition 99 behind and picks up the **Callaway-Sant'Anna minimum-wage county panel** (1,745 US counties × 2003–2007, three adoption cohorts), where the methods we have used so far either fail outright (one treated unit ≠ staggered cohorts) or scale awkwardly. Chapter 8 starts there with the modern staggered-DiD toolkit."*

4. **Notation collision with chapter 4.** Chapter 4 (`04-classical-synthetic-control.qmd:33–39`) uses lowercase **$w$** for the *vector of donor weights* on the simplex; chapter 7 uses lowercase **$w$** for *California's contiguity row* in the 38-state adjacency, and uses **$\alpha$** for the vector of donor weights instead. The two are semantically completely different objects, but both live on $\mathbb{R}^{38}$ and both are denoted $w$ across the book. A careful reader comparing the two chapters will get confused.
   - `07-bayesian-spatial-sc.qmd:124`: when `w` and `W` are introduced, add one sentence: *"A notation note: in chapter 4, lowercase $w$ denoted the simplex-constrained donor weights; in this chapter, donor weights are written $\alpha$ (to match @sakaguchi2026spatial), and lowercase $w$ is reused for California's row in the 38-state contiguity matrix. The two objects are different despite sharing a name."*

5. **Notation collision with chapter 5 (less severe).** Chapter 5 uses $\beta$ for the BSTS regression coefficients on donor states; chapter 7 reuses $\beta$ for the SAR coefficient on `retprice` only (a length-1 vector here, since `X = c("retprice")`). The chapter does not say what $\beta$ is anywhere in the text. The equation at line 315 introduces $X_{c,t}\beta$ without saying $X$ contains retail price.
   - `07-bayesian-spatial-sc.qmd:315`: in the sentence describing the equation (line 317), make $X$ explicit: replace "and on covariates ($X = \text{retprice}$ here)" with "and on covariates **$X_{c,t}$** — in this fit the single donor-side covariate is retail cigarette price, so $\beta$ is a scalar".

6. **The Mermaid diagram refers to "Sakaguchi & Tagawa pipeline" by name (line 22), but the in-text first reference (line 11) uses `@sakaguchi2026spatial`.** Consistent, but the reader who sees the diagram first has the name before the citation. Minor — leave alone.

---

## 4. Writing & structure

1. **Missing "common pitfall" section.** See methodology issue 8. Recommended position: between "Cross-stage comparison" and "Recap".

2. **No concept-pair cards.** `custom.css:227–235` defines a `.concept-pair` two-column grid class, but no chapter uses it yet. The prompt explicitly flags this. Two natural concept-pair candidates for ch.7: (a) "Classical SCM vs Horseshoe SCM" and (b) "SUTVA imposed vs SUTVA relaxed". Adding them is optional; if added, position them inside Stage 2 (after line 309) and Stage 3 (after line 355). Not blocking.

3. **The teaser "Most donors hug zero; Nevada is the only top weight whose interval excludes zero" (line 268, fig caption) is more interesting than the surrounding prose lets on.** The Stage-2 narrative on lines 307–309 says "the donor pool broadens dramatically" and gives an active-donor count — but it never returns to the *credible-interval* finding that even with 23 donors carrying mass, only **one** has an interval excluding zero. That is the strongest empirical signal in Stage 2 and deserves its own sentence outside the figure caption.
   - `07-bayesian-spatial-sc.qmd:307`: extend the paragraph: *"...the data do not strongly insist on a four-donor synthetic. Note also which donor's interval excludes zero: only Nevada's. Twenty-three donors carry posterior mean mass, but **only one** is statistically distinguishable from a no-contribution donor — which foreshadows the Stage-3 finding that the spillover concentrates almost entirely on Nevada."*

4. **"Active-donor count rises monotonically" is false as printed.** Line 482 (tbl-cap) and line 501 (prose bullet) both claim *strictly monotone* growth, but the cached cross-stage table has active-donor counts 4, 23, 23. The Stage-2 → Stage-3 transition is **flat**, not rising. (This is unsurprising: Step 2 conditions on $\hat\alpha$ from Step 1, so the active-donor count is *identical* by construction. The chapter should not have framed it as a trend.)
   - `07-bayesian-spatial-sc.qmd:482`: replace `"rises monotonically"` with `"jumps from 4 to 23 between Stage 1 and Stage 2 and then stays at 23 in Stage 3, because Stage 3 conditions on Stage 2's α̂"`.
   - `07-bayesian-spatial-sc.qmd:501`: rewrite the bullet correspondingly: *"**Active-donor count jumps once.** Heavier-tailed priors admit more donors with non-trivial mass (4 → 23 between Stage 1 and Stage 2); the Stage 3 count is identical to Stage 2 by construction (the SAR step holds α fixed at its Stage-2 posterior mean)."*

5. **"Nevada is the dominant spillover-receiver by an order of magnitude" understates the result.** Line 420 says "an order of magnitude", which means ~10×. The actual ratio (Nevada / Idaho) is **16×** (cached: -3.75 / -0.228). The table caption (line 393) already says "16×" correctly; the prose should match.
   - `07-bayesian-spatial-sc.qmd:420`: change "by an order of magnitude" to "by more than an order of magnitude (≈16× the next-largest)".

6. **Recap row "Where does the spillover land?" reports `≈ -3.75` packs but the chapter never spells out the units explicitly there.** The number `-3.75` reads as a scalar; it would help to write `≈ -3.75 packs/capita on Nevada` for parallel structure with the other rows.
   - `07-bayesian-spatial-sc.qmd:511`: rephrase as `Almost entirely on Nevada (mean post-1988 spillover ≈ -3.75 packs/capita); other donors are an order of magnitude smaller.`

7. **No prose interpretation of the ρ̂ point estimate in the recap.** The recap row "What is the chapter's caveat?" mentions ESS, but a separate row clarifying *"What does ρ measure, and what is the headline estimate?"* would round out the table. Optional.

8. **Two-line `glue()` output uses a literal `\n` (lines 119–120 and again 348).** This works (R `glue` honours `\n`), but in HTML output the line break renders as a normal whitespace in code-output blocks. Not wrong, just slightly noisy. Optional cosmetic change: split into two `glue()` calls and emit them on separate lines.

9. **The phrase "tutorial scale" appears five times across the chapter (lines 360, 482, 502, 512, and the parent prompt itself).** It is a useful anchor but starts to read like a hedge after the third repetition. Consider replacing two of the five instances with "5,000-iteration run" or similar concrete reference.

---

## 5. Other observations

1. **The freeze-cache content hash being identical across `_freeze/06-bayesian-spatial-sc/` and `_freeze/07-bayesian-spatial-sc/` confirms that the chapter rename was a pure file move — no chunk content changed during the rename.** Good. Once the orphan is deleted (issue C2#1), no further integrity check is needed.

2. **The `R/scspill/02_utils_data_prep.R` file defines `scspill_prep()` (singular), which is **never called** anywhere in the chapter or in the rest of `scspill/`.** All call sites use `scspill_prep_X()` from `01_utils.R`. Dead code, fine to leave; flagging for completeness.

3. **`R/scspill/22_mcmc_sar.R` defines `sar_gibbs_sampler()` that calls a C++ function `sar_full_sampler_cpp()` (no `_step2` suffix; `22_mcmc_sar.R:43`) which is **not defined** in either of the compiled `.cpp` files** — both kernels expose `sar_full_sampler_cpp_step2` and `hs_alpha_gibbs_cpp` only. So `sar_gibbs_sampler()` would error if called. The chapter never calls it (only `sc_spillover()` is invoked), so this is latent dead code, but a reader who tries to reuse the helpers will hit a confusing error.
   - `R/scspill/22_mcmc_sar.R:43`: either rename to `sar_full_sampler_cpp_step2` and rework the argument list, or remove the function entirely. Out of scope for the chapter audit but worth noting since `CLAUDE.md` says these helpers are "bespoke" and `scspill` is not on CRAN.

4. **Compile time claim ("~30 s") in line 71 is plausible but architecture-dependent.** On an M-series Mac the two `Rcpp::sourceCpp` calls compile faster (~10–15 s combined); on an older Intel Mac or a Linux laptop they can hit 40–60 s. Not worth changing, but a reader on a slow machine should not feel deceived.

---

## 6. Summary of recommended edits, in priority order

1. **HIGH — Methodology #1.** Fix the SAR likelihood equation at line 315 to reflect the actual model `(I - ρW - ρwα^⊤)Y_{c,t} = X_t β + ΛF_t + ε_t`, and re-explain the third term as cross-coupling (not a time lag).
2. **HIGH — Cross-chapter #1 + #2.** Rename `## Why a third synthetic-control chapter?` → `## Why a fourth synthetic-control chapter?` at line 5 and add the chapter-6 hand-off sentence at line 7.
3. **HIGH — Cross-chapter #3.** Add a "Part-I → Part-II hand-off" section before "Further reading", explicitly bridging the Proposition 99 case study to the CS minwage panel.
4. **HIGH — Writing #4.** Fix the "rises monotonically" claim at lines 482 and 501 — the active-donor count is 4, 23, 23 (flat in the last step).
5. **HIGH — Methodology #2.** Add an explicit "Priors at a glance" inline statement listing the ρ / σ² / β priors used by the C++ kernel.
6. **HIGH — Code #1.** Delete the orphaned `_freeze/06-bayesian-spatial-sc/` directory.
7. **MEDIUM — Code #2.** Extend the macOS gfortran-shim glob to include `/opt/homebrew/Cellar/gcc/*/lib/gcc/*` for Apple Silicon.
8. **MEDIUM — Methodology #4.** Spell out that Step 2 is a **plug-in** approximation (holds α fixed at $\hat\alpha$), and that this is one of two structural reasons for the artificially narrow Stage-3 CrI.
9. **MEDIUM — Methodology #5.** Add a ρ traceplot chunk after the Stage-3 print — the single most important visual MCMC diagnostic.
10. **MEDIUM — Methodology #6.** Fix the "forward-simulating" prose at line 389; the code uses the closed-form Sakaguchi-Tagawa identification formula.
11. **MEDIUM — Code #6.** Soften the prose claim at line 355 — "bounded clearly away from zero" is not supported at ESS = 2.9.
12. **LOW — Cross-chapter #4.** Add a one-sentence notation note when `w` and `W` are introduced (line 124), distinguishing chapter 7's `w` from chapter 4's `w`.
13. **LOW — Writing #5.** "Order of magnitude" → "more than an order of magnitude (≈16×)" at line 420.
14. **LOW — Methodology #7.** Define the four prior-predictive statistics in plain prose at line 425.
15. **LOW — Methodology #8.** Add a "Common pitfall" section between "Cross-stage comparison" and "Recap" consolidating ESS + plug-in + chain-count caveats.
16. **LOW — Methodology #3.** Add a parenthetical noting the Makalic-Schmidt 2015 parametrisation used by the C++ sampler.
17. **LOW — Code #3 (out-of-chapter).** Fix the W/w-vs-W_raw/w_raw bug in `R/scspill/41_robustness_check.R:38–40, 176–177, 428–429`.
18. **LOW — Other #3.** Either fix or delete the broken `sar_gibbs_sampler()` shim at `R/scspill/22_mcmc_sar.R:43`.
