# Audit applied — Chapter 07 (Bayesian Spatial Synthetic Control)

Target file edited: `/Users/carlosmendez/Documents/GitHub/ccm/07-bayesian-spatial-sc.qmd` (only file touched).

Cross-references:
- Source audit: `audit/chapter-07.md`
- Stage 1 prep: `audit/STAGE1-DONE.md` (R helpers already fixed; SAR symbol is `sar_full_sampler_cpp_step2`)
- Notation plan: `audit/NOTATION-RENAME-PLAN.md`

## Edits applied (by audit priority)

### P1 / HIGH

1. **SAR likelihood equation fixed (audit Methodology #1).** Line ~321–325 (formerly 313–317). Replaced the misleading "$Y_c^{\text{lag}}\alpha$" temporal-lag form with the actual model implemented in `R/scspill/20_mcmc.cpp:254–255`:
   $$(I - \rho W - \rho\, w\, w^{\top})\, Y_{c,t} \,=\, X_{c,t}\,\beta \,+\, \Lambda F_t \,+\, \varepsilon_t.$$
   Added a three-sentence breakdown of each structural term (donor-to-donor spillover, cross-coupling that propagates the donor pool's joint reaction through California's neighbours, $p=1$ latent dynamic factor capturing common shocks). Explicitly stated that the same $w$ from Stage 2 plays double duty as the spatial-feedback weights. Restored the dropped $\Lambda F_t$ term. Noted that $\beta$ is a scalar because $X$ contains retail price only.

2. **Heading rename + chapter-6 acknowledgement (audit Cross-chapter #1 + #2).** Line 5 now reads `## Why a fourth synthetic-control chapter?`. Opening paragraph now includes a sentence about chapter 6 ("Chapter 6 then put a finite-sample frequentist prediction interval around the classical fit and relaxed the simplex to lasso / ridge / OLS — but, like chapters 4 and 5, retained SUTVA"), and the next sentence reads "All three treat..." rather than "Both treat..." for arithmetic consistency.

3. **Part-I → Part-II hand-off section added (audit Cross-chapter #3).** New section `## Where this case study ends, and where Part II begins` between Recap and Further reading. Two paragraphs: (i) names all seven Prop 99 chapters and the −15 to −19 packs convergence, (ii) explains why Prop 99 worked (single treated unit, clean break) and announces the switch to the CS minwage panel and the ATT(g,t) framework as a generalisation of the ATT-on-California estimand.

4. **"Rises monotonically" claim fixed (audit Writing #4).** Two places:
   - Cross-stage table caption now reads "jumps from 4 to 23 between Stage 1 and Stage 2 and then stays at 23 in Stage 3, because Stage 3 conditions on Stage 2's w-hat (plug-in approximation)".
   - Cross-stage bullet rewritten as "Active-donor count jumps once" with the same plug-in explanation.

5. **Priors at a glance added (audit Methodology #2).** New paragraph after the SAR equation listing the four priors: $\rho$ uniform on the spectral-bounded stability interval, $\sigma^2 \sim \mathrm{InverseGamma}(1,1)$, $\beta$ flat with $10^{-6}$ ridge, and $w$ inherits the Stage-2 horseshoe (fixed at $\widehat{w}$ during the SAR step).

6. **gfortran shim extended for Apple Silicon (audit Code #2).** Lines 80–84 now probe three layouts in order: `/usr/local/Cellar/gcc/*/lib/gcc/*` (Intel), `/opt/homebrew/Cellar/gcc/*/lib/gcc/*` (Apple Silicon), `/opt/homebrew/lib/gcc/current` (symlinked layout). The prose above the chunk now describes the shim explicitly as "best-effort fallback" and explains the user remedy (CRAN gfortran from <https://mac.r-project.org/tools/> or `brew install gcc`) when no Homebrew gcc exists.

7. **Plug-in approximation named (audit Methodology #4).** The `sc_spillover()` paragraph now spells out the two-step sequential structure (Step 1 horseshoe for $w$, then Step 2 SAR $\rho$ holding $w$ fixed at $\widehat{w}$) and explicitly labels it a "plug-in approximation, not a fully joint posterior" with one of two structural reasons the Stage-3 CrI is artificially narrow.

8. **ρ̂ "bounded clearly away from zero" softened (audit Code #6).** Line 367 now reads: $\hat\rho \approx 0.223$ is positive (consistent with cross-border intuition), but at ESS = 2.9 the chain has barely moved from its starting value of 0; the magnitude should not be over-read at the 5,000-iteration run.

9. **Forward-simulating prose corrected (audit Methodology #6).** The spillover paragraph at the start of "Spillover effects on donor states" now explains that the framework uses the **closed-form Sakaguchi-Tagawa identification formula** to recover the per-donor counterfactual: $Y_c^{cf} = (I - \rho A)^{-1}[(I - \rho W) Y_c - \rho\, w\, Y_0]$, with $A = W + w w^{\top}$. Explicitly states "no forward simulation is involved — the model is identified in closed form, so we evaluate, we do not simulate forward".

10. **Notation renames applied (NOTATION-RENAME-PLAN ch.7).**
    - Horseshoe global scale: $\tau \to \tau_{\mathrm{HS}}$ at the Stage-2 prior equation. First-occurrence parenthetical added: "often written plain $\tau$ in the horseshoe literature".
    - Horseshoe local scale: $\lambda_j \to \lambda_{j,\mathrm{HS}}$ at the same equation. Parenthetical explains it's distinct from a factor-loading $\lambda_i$.
    - Donor weights: $\alpha \to w$ in prose. Stage-1 classical-SCM minimisation equation now uses $\widehat{w}$. Stage-2 horseshoe equation uses $w_j$. Stage-3 SAR equation uses $w$. Cross-stage and pitfall paragraphs use $w$ / $\widehat{w}$ throughout. R variables (`alpha_draws_hs`, `alpha_summary`, `fit_sar$alpha_draws`) are left untouched per the plan.
    - Added a notation note in the setup section (after data introduction) that explains the dual use of lowercase $w$ in this chapter (donor weights and California's contiguity row), names the Sakaguchi-Tagawa convention, and previews the $\tau_{\mathrm{HS}}$ / $\lambda_{j,\mathrm{HS}}$ subscripts.
    - Stage-1 equation explicitly noted as "this is $\widehat{Y_{c,t}(0)}$ in the book-wide notation" (NOTATION plan §"$\widehat{Y(0)}$ through-line").

### P2 / MEDIUM

11. **ρ traceplot added (audit Methodology #5).** New `fig-trace-rho` chunk inserted after the ESS callout, before `fig-stage3-paths`. Caption explains a healthy chain would look like white-noise oscillation around a stationary mean; this one drifts in long slow excursions. Uses the cached `fit_sar$rho_draws`. (α-diagnostics were not added separately; the audit's call for richer α-diagnostics was deemed lower priority than the traceplot for ρ.)

12. **Makalic-Schmidt parenthetical added (audit Methodology #3).** Inline after the horseshoe equation: "The C++ sampler uses the equivalent Makalic-Schmidt (2015) auxiliary-variable parametrisation — same posterior, easier conditionals."

13. **Common-pitfall section added (audit Methodology #8).** New `## Common pitfall: tutorial-scale MCMC and the credibility of credible intervals` section between "Cross-stage comparison" and "Recap". Three numbered points: ESS in single digits, plug-in $w$ removes a second uncertainty source, single-chain run (so no $\hat R$ available). Concludes with the discipline-on-intervals message and reiterates that the point estimate is robust.

14. **Stage-2 narrative extended on Nevada CrI (audit Writing #3).** The "donor pool broadens dramatically" paragraph now closes with: "Twenty-three donors carry posterior mean mass, but only one is statistically distinguishable from a no-contribution donor — which foreshadows the Stage-3 finding that the spillover concentrates almost entirely on Nevada."

### P3 / LOW

15. **Notation note for w/W (audit Cross-chapter #4).** Folded into the broader notation paragraph after the data section (line ~130). The dual use of $w$ (donor weights vs. contiguity row) is described explicitly.

16. **"Order of magnitude" → "more than an order of magnitude (≈16×)" (audit Writing #5).** Line 449 prose now reads "by more than an order of magnitude (≈16× the next-largest)".

17. **Four prior-predictive statistics defined (audit Methodology #7).** Two-sentence definition paragraph added before the `prior-predictive` chunk: donor mean (level), spatial $Y'WY/NT_0$ (Moran-like quadratic), lag-1 autocorrelation (AR(1) persistence), PC1 variance share (low-rank dependence).

18. **Recap row units explicit (audit Writing #6).** Spillover row now reads "mean post-1988 spillover ≈ −3.75 packs/capita on Nevada".

19. **`MCMC_ITER` / `MCMC_BURN` comments (audit Code #5).** Inline comments added: `# tutorial scale; raise to 100000L for paper-grade rho ESS` and `# half of MCMC_ITER; bump to 50000L when MCMC_ITER hits 100000L`.

20. **"Tutorial scale" repetition softened (audit Writing #9).** Two of the prior occurrences replaced with "5,000-iteration run" / "this 5,000-iteration run": the ρ̂ prose (line 367) and the traceplot caption. Four remaining instances retained for anchor consistency, including the `MCMC_ITER` comment, the callout title, the cross-stage table caption (already rewritten), the plug-in paragraph, and the new pitfall section title.

## Audit items NOT applied (and why)

- **Code #1 — Delete `_freeze/06-bayesian-spatial-sc/` orphan.** Per `STAGE1-DONE.md` this was already deleted in Stage 1 ("Cleanup (deletions)" section). Nothing to do; mentioned for completeness.
- **Code #3 — Fix `R/scspill/41_robustness_check.R` globals.** Already done in Stage 1B (per `STAGE1-DONE.md`); also explicitly out of scope per task constraints ("DO NOT touch `R/scspill/*`").
- **Other #3 — Fix `R/scspill/22_mcmc_sar.R:43` symbol.** Already done in Stage 1B (renamed to `sar_full_sampler_cpp_step2`); also out of scope.
- **Writing #2 — Concept-pair cards using `.concept-pair`.** Marked optional/non-blocking by the audit. Skipped to keep the diff focused on substantive corrections; the chapter is already dense.
- **Writing #7 — Optional extra recap row for ρ point estimate.** Marked optional by the audit. Skipped — the current recap already captures the headline points and adding a "what does ρ measure" row would duplicate the SAR-equation prose.
- **Writing #8 — Optional cosmetic `glue()` `\n` cleanup.** Marked optional. Skipped — `glue()` honours `\n` in HTML output and the current behaviour is correct.
- **Other #2 (out-of-chapter) — Dead `scspill_prep()` in `R/scspill/02_utils_data_prep.R`.** Flagged in Stage 1B with a comment; nothing to do here.

## Cache invalidation expected

Most of the prose changes are commentary outside chunks, but a few changes will not invalidate the cache because they are purely textual:
- Stage-1 / Stage-2 / Stage-3 equation prose updates do not touch chunks.
- The new `fig-trace-rho` chunk introduces a new chunk label and **will be a fresh execution** on next render. It depends only on the cached `fit_sar$rho_draws`, so it adds no additional MCMC cost.
- The gfortran-shim glob extension changes the chunk source, which will invalidate the `vendor-load` chunk's freeze entry, triggering a recompile of the two `Rcpp::sourceCpp()` calls on the next render. This is expected and unavoidable given the audit's fix.
- The `MCMC_ITER` / `MCMC_BURN` comment additions change the `setup` chunk source and will invalidate downstream MCMC chunks. The MCMC samplers will rerun (~1–3 min) on the next render.
- The `Stage 3 ATT widens roughly linearly post-1988` figure caption is untouched, so the corresponding chunk stays cached.

Overall expectation: next render compiles the C++ kernels (~30 s) and re-runs the Gibbs sampler (~1–3 min), then everything downstream re-uses the cached posterior draws.

## Notation invariants preserved

- $W$ remains the 38×38 spatial adjacency matrix only in this chapter.
- $\rho$ stays the SAR autocorrelation parameter.
- $w$ now uniformly means "donor weights" in math, with the contiguity-row reuse flagged explicitly at first introduction.
- $\tau_{\mathrm{HS}}$, $\lambda_{j,\mathrm{HS}}$ free up $\tau$ for treatment-effect use (book-wide) and $\lambda_i$ for factor loading (chs.9, 10).
- All R variable names left untouched (`alpha_draws_hs`, etc.).
