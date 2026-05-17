# Chapter 1 — applied changes

All P1, P2, and P3 items from `audit/chapter-01.md` were applied to `01-introduction.qmd`. No other files were touched.

## P1 — must fix (3/3 done)

### P1.M1 — missing-data didactic table corrected (lines 40–49)

Five wrong values replaced with the audit-verified values from `data/proposition99.rds`:

| Cell | Old | New |
|---|---:|---:|
| California 1995 cigsale | 64.4 | **56.4** |
| Nevada 1988 cigsale | 134.4 | **142.0** |
| Nevada 1995 cigsale | 113.0 | **100.7** |
| Utah 1988 cigsale | 64.7 | **55.0** |
| Utah 1995 cigsale | 55.0 | **52.0** |

Kept the static markdown table (rather than refactoring to an R chunk) so it stays a *didactic* illustration with the ✓ / **?** / — annotations the prose calls out. The correct California rows (90.1, 82.4, 41.6) were preserved.

### P1.C1 — stray `theme_minimal()` removed from `fig-raw-series` (was line 216)

The trailing `+ theme_minimal()` after the `labs(...)` call was deleted. The ggplot now inherits the transparent house theme set in the setup chunk, so the figure renders correctly in both cosmo (light) and darkly (dark) themes — and stops being a near-white slab on a dark page.

### P1.M3 — mermaid decision tree restructured (around lines 109–132)

The Q2 → SCM leaf used to bundle chs. 4, 6, and 7 under the *Frequentist + tidy code* branch, miscategorising ch. 7 (which is Bayesian). Restructured to:

- `Q2 -->|Frequentist + tidy code| SCM` now lists **only chs. 4 + 6** (both frequentist).
- `Q2 -->|Bayesian + uncertainty bands| Q3` introduces a new SUTVA question.
- `Q3 -->|No, SUTVA OK| CI` → BSTS (ch. 5).
- `Q3 -->|Yes, spillovers likely| SPATIAL` → Bayesian Spatial SCM (ch. 7).

This both fixes the methodological miscategorisation and surfaces ch. 7's identifying contribution (SUTVA relaxation).

## P2 — should fix in the same pass (5/5 done)

### P2.M2 — imputation table tightened (lines 83–101)

- Added a preface sentence above the table: "In every row, $\widehat{Y_{1t}(0)}$ should be read as a *point prediction* of the counterfactual conditional expectation $\mathbb{E}[Y_{1t}(0) \mid \text{covariates}]$; the column lists how each estimator builds that prediction."
- Naive row: appended "(constant in $t$ — that is the problem)".
- Basic DiD row: replaced with the parallel-trends form $\widehat{Y_{1t}(0)} = Y_{1, t^*} + (Y_{0t} - Y_{0, t^*})$ so the RHS now depends on $t$.
- BSTS row: hatted both parameters → $\widehat{Y_{1t}(0)} = \hat\mu_t + \hat\beta^\top x_t$.
- SCM row: changed summation index from $i$ to $j$ ($w_j^*\, Y_{jt}$) — $i$ is reserved book-wide for the unit index and $i = 1$ is California, so the previous `\sum_i w_i^* Y_{it}` was a collision.

### P2.M4 — SUTVA named (new paragraph after line 32)

After the potential-outcomes definition, added: "Writing $Y_{it}(1)$ and $Y_{it}(0)$ as well-defined quantities implicitly assumes the **stable unit treatment value assumption (SUTVA)**: state $i$'s potential outcomes depend only on its own treatment status, not on what other states are doing. SUTVA is harmless for many policies; for tobacco taxes on the California border it is exactly the assumption that chapter 7 will relax." This gives ch. 7 a foothold.

### P2.M5 / C2 — switched to `NeweyWest`, kept the "wildly overconfident" adjective

Took the audit's recommended path: replaced `coeftest(fit_prepost, vcov. = vcovHAC)` with the `ms_pretty(..., vcov = NeweyWest, ...)` call (also accomplishing C3). Updated the prose:

- "small ($p < 0.001$)" → "still small enough to reject the null at 5% ($p \approx 0.01$)" — consistent with the audit's reported NeweyWest result.
- "a classical OLS standard error would be wildly overconfident here" → "the classical OLS standard error is about half the Newey-West value here, so it would be wildly overconfident" — names the gap explicitly, keeps the adjective defensible (~92% gap vs `NeweyWest`).

### P2.C3 — `naive-prepost` chunk promoted to `tbl-naive-prepost` with `tbl-cap`

Chunk label is now `tbl-naive-prepost`; added a `tbl-cap` describing the regression and the SE estimator. Output is built via `ms_pretty(list("California (1984-1993)" = fit_prepost), vcov = NeweyWest, coef_map = c(...))`. CLAUDE.md table-convention compliance restored.

### P2.W2 — section heading renamed

"## Which method when?" → "## Choosing a method".

## P3 — nice to have (6/6 done)

### P3.X1 — recentred year-index note (after line 77)

Added: "Some chapters (chs. 2, 4) recentre the year index so $t = 0$ at the *first* post-period year (1989). The break itself is the same: pre-period is $\{t : t \le 1988\}$ throughout." This pre-empts the `year0 = year - 1989` recentre that ch. 2 (line 45) introduces.

### P3.X2 — inline parenthetical on "unit $i = 1$" (in line 77)

After the ATT formula, added inline: "where unit $i = 1$ denotes California (in code we identify California by name with `state == "California"`; the $i = 1$ index is purely notational here)".

### P3.W1 — first two paragraphs reordered

The "Two running case studies" / Prop 99 / 116-to-60 paragraph now precedes the meta "this book is a guided tour" paragraph. The hook (paragraph 1) → puzzle (paragraph 2) → response/tour (paragraph 3) flow is now intact.

### P3.W3 — pre/post arithmetic inlined (line 196)

Rewrote: "California's average per-capita cigarette sales fell from **116.21** packs (1970–1988) to **60.35** packs (1989–2000) — a within-state drop of 55.86 packs, or 48.1% of the pre-period mean." Numbers match the cached gt output of `tbl-prepost-means` to two decimals.

### P3.W4 — "Common pitfall" expanded to a 4-bullet list (lines 261–266)

Replaced the single-sentence pitfall with the four bullets the audit suggested: (i) within-state pre-post ≠ causal effect; (ii) ATT ≠ ATE; (iii) $Y_{it}(0)$ for treated units is never observed, always imputed; (iv) "one potential outcome" ≠ "treated outcome" — donor pools observe $Y_{it}(0)$.

### P3.W5 — Further reading annotated by category (lines 293–299)

Each bullet now carries a one-word tag (*original method* / *tutorial* / *workshop* / *practical guide*) and a parenthetical chapter pointer where applicable, so readers can tell foundational papers from tutorials at a glance.

## P3 items NOT applied (deferred by the audit's own scope)

- **C4** — lifting the duplicated `theme_set` + `dev.args` block to `R/setup_theme.R`. The audit marked this P3 / optional and the task constraints explicitly forbid editing files under `R/`. Left in place.

## Notation cross-checks against `NOTATION-RENAME-PLAN.md`

- $Y_{it}$ (uppercase) used throughout — no lowercase $y_{it}$ collisions in this chapter.
- $D_{it}$, $\tau_{it}$, ATT, ATT(g, t) match the book-wide conventions.
- $w_j$ used in the SCM row (matches the SCM-family convention in chs. 4, 6, 7).
- $\alpha_i$ / $\lambda_i$ / $f_t$ used in the MC/IFE row (matches ch. 9 / ch. 10 conventions).
- $\widehat{Y_{1t}(0)}$ used consistently across the imputation table.

## Cross-chapter hand-off check (ch. 1 → ch. 2)

Ch. 2's setup (`02-interrupted-time-series.qmd:45`) introduces `year0 = year - 1989`, recentred at the first post-period year. Ch. 1's new note (P3.X1) now flags this in advance so the reader doesn't lose the cutoff. SUTVA is named in ch. 1 (P2.M4) so ch. 7 has a foothold; ch. 2 doesn't depend on SUTVA per se. The fundamental-problem framing (every method imputes $Y(0)$) is reused verbatim by ch. 2's opening paragraph.

## Files edited

- `/Users/carlosmendez/Documents/GitHub/ccm/01-introduction.qmd` (only)

## Files NOT edited (per task constraints)

- `references.bib`, `_quarto.yml`, any other `.qmd`, any file under `R/`, `_freeze/`.

## Render note

Several chunks (`fig-raw-series`, `tbl-naive-prepost`) had their source modified, so their cached output in `_freeze/01-introduction/` will be auto-invalidated on the next `quarto render --to html`. The data-load and `tbl-prepost-means` chunks are unchanged and will reuse the freeze cache.
