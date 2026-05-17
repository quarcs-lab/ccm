# Notation rename plan — shared convention for Stage 2 chapter agents

This is the canonical notation convention all chapter agents must apply. It resolves the four collisions identified in `audit/AUDIT.md` §2.8 and `audit/cross-cutting-notation-arc.md` §1.

## Book-wide conventions

| Symbol | Reserved meaning (book-wide) |
|---|---|
| $Y_{it}$ | Observed outcome (always uppercase $Y$) |
| $Y_{it}(0), Y_{it}(1)$ | Potential outcomes |
| $\widehat{Y_{it}(0)}$ | Estimated counterfactual |
| $D_{it}$ | Treatment indicator |
| $\tau, \tau_{it}, \mathrm{ATT}, \mathrm{ATT}(g, t)$ | Treatment effect / treatment-effect estimands |
| $i$ | Unit index |
| $t$ | Time index |
| $g$ | Cohort / adoption-year index (Part II only) |
| $\alpha_i$ | Unit fixed effect (Part II, chs.9, 10) |
| $\lambda_i$ | Factor loading (chs.9, 10) |
| $f_t$ or $F_t$ | Factor score (chs.9, 10) |
| $w, w_j$ | Donor-weight vector / element (SCM family: chs.4, 6, 7) |
| $W$ | Spatial adjacency matrix (ch.7 only); also informal "implicit weights" matrix as discussed below |
| $\rho$ | Spatial autocorrelation parameter (ch.7) |
| $\overline{M}$ | HonestDiD breakdown magnitude (ch.8) |

## Chapter-local overrides (renames to apply)

### Ch.07 (`07-bayesian-spatial-sc.qmd`)

- **Horseshoe global scale**: rename `\tau` → `\tau_{\mathrm{HS}}` everywhere in prose. The treatment-effect $\tau$ never appears in this chapter, but the rename eliminates the collision a reader would otherwise carry forward.
- **Horseshoe local scale**: rename `\lambda_j` → `\lambda_{j,\mathrm{HS}}` everywhere in prose.
- **Donor weights**: rename `\alpha` → `w` (lowercase, matching chs.4, 6) so the symbol matches the SCM family. The unit-FE $\alpha_i$ is then free for use later. Note: this is a **prose** rename; the R variable `alpha` in `R/scspill/*.R` need not change (helper code is opaque to the reader). If the chapter prints the alpha vector via prose (e.g., "α̂ = …"), relabel to "ŵ = …".
- **Spatial adjacency**: keep $W$ for the 38×38 adjacency matrix; this remains.

### Ch.09 (`09-matrix-completion-and-ife.qmd`)

- **MC nuclear-norm penalty**: rename $\lambda$ (the penalty) → $\eta$ everywhere in prose. At first introduction, add a parenthetical "(written as `lambda` in the `fect` API and sometimes as $\lambda_{\mathrm{MC}}$ in the matrix-completion literature)" so a reader following Athey et al. is not confused.
- **Factor loading $\lambda_i$**: keep as-is. The collision in ch.9 was that the same symbol $\lambda$ meant two things nine lines apart; once the MC penalty is renamed $\eta$ there is no more collision.

### Ch.10 (`10-gsynth.qmd`)

- **Implicit-weights matrix**: in **prose** call it $\Omega$ (Omega) — "the implicit-weights matrix $\Omega$". In R code keep the variable named `W` or `wgt.implied` (matches gsynth output), but in figure axes and table captions write $\Omega$ to avoid colliding with ch.7's spatial-adjacency $W$.
- **Factor loading $\lambda_i$ and factor $F_t$**: keep as-is, matches ch.9.

### Chs.05, 08 — lowercase $y$ fix

- Anywhere the chapter writes $y_{it}$ (lowercase), change to $Y_{it}$ (uppercase) to match the book-wide convention.

### Ch.07 / Ch.08 — $\widehat{Y(0)}$ through-line

- Ch.07 currently writes counterfactuals as `Y_{c,\mathrm{pre}} \alpha`. Add a parenthetical "(this is $\widehat{Y_{c,t}(0)}$ in the book-wide notation)" at first occurrence.
- Ch.08 follows Callaway-Sant'Anna and writes $Y_{it}(\infty)$ for the never-treated potential outcome. Add a parenthetical "(equivalent to $Y_{it}(0)$ used in Part I)" at first occurrence in the chapter.

## How chapter agents should apply this

1. In the **setup section** of the chapter, no notation glossary is needed (the book-level glossary in the preface will eventually carry that — deferred to a future session).
2. At **first occurrence** of each renamed symbol in the chapter prose, write the new symbol and (parenthetically) note the literature-standard symbol it replaces. Example for ch.07: "the horseshoe global scale $\tau_{\mathrm{HS}}$ (often written $\tau$ in the horseshoe literature)…"
3. Use **search-and-replace within the chapter** only for unambiguous prose math. Code chunks and R variable names do not change.
4. If the rename creates an awkward sentence, prefer prose clarity over rigid substitution — the goal is to remove cross-chapter symbol collisions, not to rewrite the math.

## What is NOT changing in this pass

- $i$, $t$, $g$, $\tau$, $\mathrm{ATT}$, $D_{it}$, $Y_{it}$, $Y_{it}(0)/Y_{it}(1)$ — these are already consistent book-wide.
- $\rho$ — used only in ch.7 (spatial autocorrelation); no collision since ch.2 uses $\phi, \theta$ for AR/MA parameters.
- $\overline{M}$ — used only in ch.8.
- A book-wide **Notation appendix** is recommended in `audit/AUDIT.md` §5.1 but is deferred to a later session; this pass only applies the per-chapter renames.
