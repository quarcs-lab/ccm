# Chapter 11 — References audit

Scope audited:

- Bibliography source: `/Users/carlosmendez/Documents/GitHub/ccm/references.bib` (27 entries)
- References page: `/Users/carlosmendez/Documents/GitHub/ccm/references.qmd`
- Style: `/Users/carlosmendez/Documents/GitHub/ccm/apa.csl` (APA 7th)
- Rendered output: `/Users/carlosmendez/Documents/GitHub/ccm/_book/references.html` (24 rendered entries)
- In-text citations: `/Users/carlosmendez/Documents/GitHub/ccm/index.qmd` and `01-introduction.qmd` through `10-gsynth.qmd`

## Summary

The references system is **functionally healthy**. There are **no broken `[?]` citations** on the live site: every key cited in a chapter resolves to a `references.bib` entry. The Quarto plumbing (`references.qmd`, `_quarto.yml` bibliography + CSL) is correctly wired and APA 7 rendering works.

The issues found are bibliography hygiene rather than rendering breakage:

- **3 dead entries** in `references.bib` are never cited and add ~25 lines of dead weight: `abadie2003economic`, `bai2003inferential`, `fpp3-pkg`.
- **1 entry is mis-typed**: `callaway2022handbook` is declared `@article` but is actually a handbook chapter. This is the only entry whose APA rendering is visibly degraded (no editors, no chapter pages, the handbook is italicised as if it were a journal).
- **3 entries lack a `year` field** and render as "(n.d.)" in the APA output: `causalimpact-pkg`, `brodersen-causalimpact-talk`, `fpp3-pkg`. The first two are cited; the third is unused but should be repaired or removed.
- **2 entries are missing `volume`/`number`/`pages`** that the journal does provide: `sakaguchi2026spatial` (forthcoming, partly understandable) and `brodersen2015inferring` (issue number missing).

In-text citation totals after de-duplication: **24 unique citation keys** spread across 10 chapters. `index.qmd` contains no `@`-citations. The grep pulled exactly one Quarto cross-reference that is **not** a citation (`@tbl-attgt` at `08-staggered-did.qmd:176`); it has been excluded from the count.

## Missing bib entries (rendered as `[?]`)

| Cite-key | Chapter:line | Likely intended reference |
|----------|--------------|---------------------------|
| — | — | **None.** Every `@key` used in `index.qmd` and `01-…` through `10-…` resolves to an entry in `references.bib`. The rendered `_book/references.html` shows 24 `csl-entry` divs (the 24 cited keys) and zero `[?]` placeholders. |

## Unused bib entries

These keys exist in `references.bib` but never appear in any `.qmd`. They produce no output (CSL only renders cited keys) but bloat the source file:

1. **`abadie2003economic`** (`references.bib:5–13`) — Abadie & Gardeazabal, *AER* 2003, Basque Country. Historically the first synthetic-control paper; could plausibly be cited in `01-introduction.qmd` or `04-classical-synthetic-control.qmd` as the methodological antecedent of `abadie2010synthetic`. Either cite it or remove.
2. **`bai2003inferential`** (`references.bib:224–234`) — Bai, *Econometrica* 2003, inferential theory for factor models. The factor-model background entry for chapter 9; the chapter currently cites only `bai2009panel`. Either cite it in chapter 9 or remove.
3. **`fpp3-pkg`** (`references.bib:89–93`) — `fpp3` R-package landing page. The ITS chapter (`02-interrupted-time-series.qmd`) cites the book (`hyndman2021forecasting`) but never the package. Either cite it in chapter 2 alongside `hyndman2021forecasting` or remove.

## Malformed bib entries

| Key | Location | Issue |
|-----|----------|-------|
| `callaway2022handbook` | `references.bib:215–222` | **Wrong entry type.** Declared `@article` but is a chapter in the Springer *Handbook of Labor, Human Resources, and Population Economics*. Should be `@incollection` with `booktitle`, `editor`, and `pages`. APA 7 expects "Author. (Year). Chapter title. In Editor (Ed.), *Book title* (pp. xx–yy). Publisher." — the current render is "Callaway, B. (2022). Difference-in-differences for policy evaluation. *Handbook of Labor, Human Resources, and Population Economics*." with no editors, no chapter pages, no publisher line (the `publisher = {Springer}` field is silently dropped because `@article` does not consume it). Also missing `volume`, `number`, `pages`. |
| `causalimpact-pkg` | `references.bib:83–87` | **Missing `year`.** Renders as "Brodersen, K. H., & Hauser, A. (n.d.)." Cited at `05-structural-bayesian-ts.qmd:197`. Suggest `year = {2024}` (or whatever year matches the package page snapshot used). |
| `brodersen-causalimpact-talk` | `references.bib:95–100` | **Missing `year`.** Renders as "Brodersen, K. H. (n.d.)." Cited at `05-structural-bayesian-ts.qmd:196`. The YouTube video has a publication year — add it. |
| `fpp3-pkg` | `references.bib:89–93` | **Missing `year`** (and unused — see above). |
| `sakaguchi2026spatial` | `references.bib:102–109` | **Missing `volume`, `number`, `pages`.** Year is `2026` (forthcoming/in-press). APA 7 renders as "Sakaguchi, S., & Tagawa, H. (2026). … *The Econometrics Journal*." with no volume/issue/pages — readable but incomplete. Once the article is officially paginated, fill in these fields. If still in-press at render time, consider `note = {Advance online publication}` per APA 7. |
| `brodersen2015inferring` | `references.bib:37–45` | **Missing `number`.** *Annals of Applied Statistics* uses issue numbers; the chosen volume 9 page range (247–274) is in 9(1). Currently renders as "9, 247–274." instead of "9(1), 247–274." Minor but inconsistent with the other AAS-style entries that include `number`. |

All curly braces balance (open = close = 241 across the file). No malformed accent escapes detected — `Cl{\'e}ment` and `D'Haultf{\oe}uille` in `dechaisemartin2020twoway` are well-formed LaTeX. No duplicate keys.

## APA 7 rendering check

Spot-checked five entries against `_book/references.html`. APA 7 expects: Author (Year). Title. *Journal/Book* (italic), *volume*(issue), pages. DOI/URL.

| Cite-key | Rendered output (abridged) | Pass/Fail | Notes |
|----------|----------------------------|-----------|-------|
| `abadie2010synthetic` | `_book/references.html:460–465` — "Abadie, A., Diamond, A., & Hainmueller, J. (2010). Synthetic control methods… *Journal of the American Statistical Association*, *105*(490), 493–505. [url]" | **Pass** | All APA 7 elements present (3 authors, year, sentence-case title, italic journal, italic volume, issue, pages, URL). |
| `callaway2021difference` | `_book/references.html:502–506` — "Callaway, B., & Sant'Anna, P. H. C. (2021). Difference-in-differences with multiple time periods. *Journal of Econometrics*, *225*(2), 200–230. [doi]" | **Pass** | Complete. |
| `brodersen2015inferring` | `_book/references.html:486–491` — "Brodersen, K. H., Gallusser, F., Koehler, J., Remy, N., & Scott, S. L. (2015). … *Annals of Applied Statistics*, *9*, 247–274. [url]" | **Partial fail** | Missing issue number — renders `9, 247–274` instead of `9(1), 247–274`. Author list, year, title, journal, volume, pages, URL all correct. |
| `xu2017generalized` | `_book/references.html:569–573` — "Xu, Y. (2017). Generalized synthetic control method: Causal inference with interactive fixed effects models. *Political Analysis*, *25*(1), 57–76. [doi]" | **Pass** | Complete. |
| `carvalho2010horseshoe` (chapter 7) | `_book/references.html:507–511` — "Carvalho, C. M., Polson, N. G., & Scott, J. G. (2010). The horseshoe estimator for sparse signals. *Biometrika*, *97*(2), 465–480. [doi]" | **Pass** | Complete. (`sakaguchi2026spatial`, also cited in ch. 7, would fail this check — missing volume/issue/pages — see Malformed table.) |

Additional observation while reading the rendered list: `dunford2024tidysynth` renders the package name with **sentence-case** capitalisation (`Tidysynth — a tidy implementation…`) because the title field is not protected with extra braces. `cattaneo2025scpi` likewise renders as `Scpi:`. APA 7 sentence-case is the default, but for software/package names this looks wrong. Wrap the package name in extra braces, e.g., `title = {{tidysynth} --- A tidy implementation…}` and `title = {{scpi}: Uncertainty quantification…}`, to preserve the lowercase package name. (Not strictly malformed — it is a CSL-style choice — but worth flagging.)

## `references.qmd` structure

**Pass.** File content matches the CLAUDE.md convention exactly:

```
# References {.unnumbered}

::: {#refs}
:::
```

Quarto correctly injects the generated bibliography into the `{#refs}` div, and the section is unnumbered (no chapter number prefix on the rendered page).

## Prioritized fix list

### P1 — visible defects in the rendered references page

1. **Convert `callaway2022handbook` from `@article` to `@incollection`** with `booktitle = {Handbook of Labor, Human Resources, and Population Economics}`, `editor = {…}`, `pages = {…}`, keeping `publisher = {Springer}` (now consumed). Currently renders as a journal article and loses the publisher and editor information. `references.bib:215–222`.
2. **Add `year` to `causalimpact-pkg`** (`references.bib:83–87`) and `brodersen-causalimpact-talk` (`references.bib:95–100`). Both render as "(n.d.)" on the live site — visible in chapter 5's reading list as "Brodersen, K. H. (n.d.). …". Cited at `05-structural-bayesian-ts.qmd:196–197`.

### P2 — bibliography hygiene

3. **Remove or cite the three orphan entries**: `abadie2003economic`, `bai2003inferential`, `fpp3-pkg`. The Abadie–Gardeazabal Basque paper and the Bai 2003 factor-theory paper are natural citations to add in ch. 1/4 and ch. 9 respectively; the `fpp3-pkg` entry is redundant with `hyndman2021forecasting` and can be deleted (or added beside it in `02-interrupted-time-series.qmd:224`).
4. **Add `number = {1}` to `brodersen2015inferring`** for consistency with other AAS-style entries (`references.bib:37–45`).
5. **Fill in `volume`/`number`/`pages` for `sakaguchi2026spatial`** once the article finalises (or add `note = {Advance online publication}` if still in-press at render time). `references.bib:102–109`.

### P3 — cosmetic / style

6. **Protect package names from sentence-casing** in `dunford2024tidysynth` and `cattaneo2025scpi` titles by wrapping the package token in extra braces (`{{tidysynth}}`, `{{scpi}}`). Avoids "Tidysynth" / "Scpi" capitalisation in the rendered list.
7. **Verify author rendering of `dechaisemartin2020twoway`** — APA reorders the "de" particle correctly ("Chaisemartin, C. de, & D'Haultfœuille, X."), which is APA-compliant but sometimes flagged by readers as a typo. No action needed; just confirming the audit reviewed it.
