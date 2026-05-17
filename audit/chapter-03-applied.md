# Chapter 3 — Applied audit changes

Target file: `03-basic-diff-in-diff.qmd` (single-file scope respected; no other files touched).
Cite keys used (all verified present in `references.bib`): `cardkrueger1994minimum`, `bertrand2004how`, `bernal2017interrupted`, `callaway2021difference`, `sun2021estimating`, `rambachan2023more`.

## P1 — load-bearing fixes

| Audit ID | Action taken | Location |
|---|---|---|
| **M1** | Added a new `#| label: tbl-pretrend` chunk that fits `cigsale ~ state * year` on the 1984–1988 pre-window and prints the four coefficients via `ms_pretty()` with HAC SEs. Followed by a sentence reporting the slope-difference estimate $-4.63$ packs/year, HAC $p \approx 0.024$, and explicitly stating the pre-trends assumption is *rejected* — strengthening the chapter's thesis. | New chunk after the `fig-did-parallel-trends` plot. |
| **M2** | Rewrote the HAC justification in three places: (a) the "Packages" paragraph in Setup now defers to the Fit section instead of asserting that HAC is the right fix; (b) the "Fit and HAC inference" section now has an explicit "Standard errors on a 2×2 panel are tricky" subsection that names the BDM2004 cluster-degeneracy problem (G=2), names the `vcovHAC` cross-state row-boundary limitation, and frames HAC as a *transparent compromise* not a textbook fix; (c) the "Common pitfall" block now carries the second pitfall (clustering at G=2). All three uses cite `@bertrand2004how`. | Setup §, Fit § (new bolded paragraph), Recap § (new "second pitfall" block). |
| **M3** | Added the explicit population regression $Y_{it} = \alpha + \beta_1 \mathrm{Post}_t + \beta_2 \mathrm{Treat}_i + \tau (\mathrm{Post} \times \mathrm{Treat}) + u_{it}$ right after the change-of-changes identity, with $\mathrm{Treat}_i$ and $\mathrm{Post}_t$ defined and $\tau$ named as the DiD ATT. The "Reading the output" prose now refers to $\hat\tau$ (R name: `stateCalifornia:prepostPost`). | "The change-of-changes identity" §; "Reading the output". |
| **C1** | Removed the trailing `+ theme_minimal()` from the ggplot at the visual-diagnostic chunk so the chapter's transparent `theme_set()` is no longer overridden. | `fig-did-parallel-trends` chunk. |

## P2 — structural and citation fixes

| Audit ID | Action taken |
|---|---|
| **X1** | Rewrote "Further reading" to forward-link to chapter 8 explicitly, naming it as the *staggered-adoption* counterpart. Cites Callaway-Sant'Anna [@callaway2021difference], Sun-Abraham [@sun2021estimating], and Rambachan-Roth [@rambachan2023more] for ch. 8, plus @cardkrueger1994minimum and @bertrand2004how as the classical-DiD references. Card-Krueger is also cited in the opening paragraph as the canonical DiD example. |
| **W1** | Added "A second pitfall" (clustering with G=2) and "A third pitfall" (Nevada is not exogenous — 600-km border, California TV media spillovers) right after the existing "Common pitfall" block. |
| **W2** | Added a one-sentence hook at the top of "The DiD idea" tying the chapter back to ch. 2's punchline: "any within-unit method is fragile because the counterfactual is identified only by an assumption the data cannot verify". |
| **W3** | Trimmed the editorialising figure caption — now reads "California vs Nevada, 1970–2000 cigarette sales per capita. Pre-policy years are to the left of the dashed line." The conclusion stays in the prose. |
| **X3** | Reworded the ch. 4 hand-off in the Recap to use the audit-suggested "many Nevadas weighted" framing. |
| **X4** | Added one sentence connecting the change-of-changes identity to ch. 1's $\widehat{Y_{1t}(0)} = \overline{Y}_{1,\text{pre}} + (\overline{Y}_{0,\text{post}} - \overline{Y}_{0,\text{pre}})$ notation. |

## P3 — polish

| Audit ID | Action taken |
|---|---|
| **M4** | Quantified Nevada's adjacency in the Dataset paragraph: Reno and Las Vegas inside California's media market, retail-price corridor, and Nevada being a non-zero-weight donor in Abadie-Diamond-Hainmueller's synthetic California (with forward link to ch. 4). |
| **C3** | Added a clarifying comment above `set.seed(42)` noting it is not strictly needed (OLS and means are deterministic) but is kept for book-wide consistency. |
| **W5** | Folded the orphan paragraph "The arithmetic is literally what the regression below computes…" into the opening sentence of "The model" subsection in the Fit section. The 2×2 grid block now ends cleanly without a transitional paragraph. |

## Items intentionally NOT changed in this pass

- **X2** (ch. 2's stale promise that ch. 3 uses "the other 38 states") — out of scope (ch. 2 edit). Will need to be raised separately for chapter 2.
- **W4** (reorder Visual diagnostic *before* Fit and HAC inference) — the audit explicitly flags this as a design call for the author rather than a mechanical fix. Left as-is. The formal pre-trends test now sits inside the Visual diagnostic section, which partially addresses the spirit of W4 (the diagnostic is now substantive enough that a reader sees the assumption fail *before* reading the recap).
- Bibliography keys: all four required keys (`cardkrueger1994minimum`, `bertrand2004how`, `callaway2021difference`, `sun2021estimating`, `rambachan2023more`, `bernal2017interrupted`) confirmed present in `references.bib` per Stage 1 hand-off. No bib edits attempted (out of scope).

## Verification

- All Quarto chunk labels follow CLAUDE.md convention: `tbl-pretrend` + `tbl-cap`, `tbl-fit-did` + `tbl-cap`, `fig-did-parallel-trends` + `fig-cap`, `fig-did-22-grid` + `fig-cap` (Mermaid).
- `ms_pretty()` is called twice (existing `tbl-fit-did`, new `tbl-pretrend`); both pass `vcov = sandwich::vcovHAC` and `coef_map`, never `title=`.
- The existing `tbl-fit-did` chunk is untouched, so its freeze cache remains valid.
- The new `tbl-pretrend` chunk uses the same `prop99_did` tibble already bound in `data-load`, so it composes cleanly without re-reading data.
- The `theme_minimal()` override is the only ggplot in the chapter; removing it leaves the active transparent `theme_set()` in control for both site themes (cosmo / darkly).

## Numerical claims to re-verify on next render

The new prose asserts a slope difference of $-4.63$ packs/year and HAC $p \approx 0.024$. These come from the audit's re-fit on the 1984–1988 California-Nevada pre-window. They will render fresh from the new `tbl-pretrend` chunk; if the numbers shift after `quarto render --to html`, the surrounding sentence needs updating.

The existing numerical claims in the chapter (CA pre 99.0, CA post 72.0, NV pre 143.1, NV post 121.8, DiD $-5.68$, HAC SE $5.39$, $p \approx 0.31$) were verified by the audit and are unchanged.
