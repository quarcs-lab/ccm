# Comparative Causal Metrics

**An Introduction to Regional Impact Evaluation**

Source for the Quarto book by Carlos Mendez. Built with **R + Quarto**, published to GitHub Pages via Quarto's built-in local-render workflow (`quarto publish gh-pages`).

- 📖 Read online: <https://quarcs-lab.github.io/ccm/>
- 📄 PDF: optional download link in the book's navbar (rebuilt on demand)
- 🐙 Source: <https://github.com/quarcs-lab/ccm>

---

## Project status

**Stage:** ten method chapters drafted with live R, organised in two parts. **Part I (chs. 1–7)** uses the Proposition 99 cigarette-tax dataset for the canonical single-treated-unit setting (chapter 7 additionally pulls in the Sakaguchi & Tagawa spatial dataset shipped alongside its replication helpers). **Part II (chs. 8–10)** switches to the Callaway-Sant'Anna minimum-wage county panel for staggered-adoption methods. Preface and introduction now reflect the full scope; per-chapter exercises remain on the to-do list.

| # | Chapter | File | Status |
|---|---|---|---|
| — | Preface | `index.qmd` | first draft (two-part scope; all methods listed) |
| 1 | Introduction | `01-introduction.qmd` | first draft (live R; Prop 99 example; two-part roadmap) |
| 2 | Interrupted Time Series | `02-interrupted-time-series.qmd` | first draft (live R; growth-curve + ARIMA) |
| 3 | Basic Differences-in-Differences | `03-basic-diff-in-diff.qmd` | first draft (live R; CA vs Nevada) |
| 4 | Classical Synthetic Control | `04-classical-synthetic-control.qmd` | first draft (live R; full tidysynth pipeline) |
| 5 | Structural Bayesian Time Series | `05-structural-bayesian-ts.qmd` | first draft (live R; CausalImpact + BSTS) |
| 6 | Synthetic Control with Prediction Intervals | `06-synthetic-control-prediction-intervals.qmd` | first draft (live R; `scpi` package; simplex / lasso / ridge / OLS weights) |
| 7 | Bayesian Spatial Synthetic Control | `07-bayesian-spatial-sc.qmd` | first draft (live R; Rcpp + SAR; Sakaguchi & Tagawa replication) |
| 8 | Staggered Differences-in-Differences | `08-staggered-did.qmd` | first draft (live R; Callaway-Sant'Anna ATT(g,t), Sun-Abraham event study, Rambachan-Roth sensitivity) |
| 9 | Matrix Completion and Interactive Fixed Effects | `09-matrix-completion-and-ife.qmd` | first draft (live R; `fect` package; IFE + MC vs Callaway-Sant'Anna) |
| 10 | Generalized Synthetic Control | `10-gsynth.qmd` | first draft (live R; factor model on never-treated controls) |
| — | References | `references.qmd` | auto-rendered from `references.bib` (~35 entries) |

**Infrastructure (complete):**

- [x] Quarto book project with HTML (auto-published) + LaTeX PDF (on demand)
- [x] Dark/light theme toggle (`cosmo` / `darkly`) with custom CSS palette
- [x] `renv.lock` pinning 146 R packages at R 4.5.2 for reproducibility
- [x] Bibliography wired in (`references.bib` + `apa.csl`)
- [x] Cover image and favicon
- [x] Live site on GitHub Pages via `quarto publish gh-pages`
- [x] Per-chapter `.zip` download bundles built by `R/build_chapter_zips.R` (pre-render hook); appear inside the `</> Code` dropdown on every numbered chapter

**What the drafted chapters contain.** Chapters 1–7 share the cached Proposition 99 dataset (`data/proposition99.rds`) and target the ATT on California, 1989–2000. Chapter 1 frames the potential-outcomes problem, walks the decision tree, and runs a naive pre-post strawman. Chapters 2–7 each take one method family — ITS (growth-curve + ARIMA), single-control DiD, classical Synthetic Control with placebo permutation, CausalImpact / BSTS, frequentist prediction intervals via `scpi`, and Bayesian spatial SCM with horseshoe priors and a SAR spillover term — and report the ATT against the same canonical case study. Chapters 8–10 switch to the Callaway-Sant'Anna minimum-wage panel (`data/cs_minwage.rds`; 1,745 US counties × 2003–2007, multiple adoption cohorts) and develop staggered-adoption estimators: group-time ATT(g,t) à la Callaway-Sant'Anna with Sun-Abraham event studies and Rambachan-Roth sensitivity, matrix completion and interactive fixed effects via `fect`, and generalized synthetic control projecting treated units onto factors estimated from never-treated controls. All chunks render live.

**Next:**

- Per-chapter exercises.
- Cross-method comparison chapter — bring the ten ATT estimates onto one forest plot and discuss the disagreements.

---

## Project structure

```
ccm/
├── _quarto.yml                                      # Book config (HTML auto-publishes; PDF on demand)
├── index.qmd                                        # Preface (unnumbered)
├── 01-introduction.qmd                              # Part I — single treated unit (Proposition 99)
├── 02-interrupted-time-series.qmd
├── 03-basic-diff-in-diff.qmd
├── 04-classical-synthetic-control.qmd
├── 05-structural-bayesian-ts.qmd
├── 06-synthetic-control-prediction-intervals.qmd
├── 07-bayesian-spatial-sc.qmd
├── 08-staggered-did.qmd                             # Part II — staggered adoption (minimum-wage panel)
├── 09-matrix-completion-and-ife.qmd
├── 10-gsynth.qmd
├── references.qmd                                   # Bibliography target (unnumbered)
├── references.bib                                   # BibTeX entries
├── apa.csl                                          # Citation style (APA 7)
├── custom.css                                       # Theme palette and overrides
├── data/                                            # Cached datasets used by chapters
│   ├── proposition99.rds                            #   Part I — 39 states × 1970-2000
│   └── cs_minwage.rds                               #   Part II — Callaway-Sant'Anna county panel
├── R/                                               # Helpers sourced from chapter setup chunks
│   ├── table_helpers.R                              #   gt_pretty() + ms_pretty() for tables
│   ├── build_chapter_zips.R                         #   pre-render hook → downloads/chapter-NN.zip
│   └── honest_did.R                                 #   Rambachan-Roth sensitivity helpers (ch. 8)
├── images/                                          # Cover, favicon, figures
├── DESCRIPTION                                      # Human-readable dep manifest
├── install_packages.R                               # One-time renv bootstrap
├── renv.lock                                        # Pinned R deps
└── _book/                                           # Render output (gitignored)
```

## Local setup

### 1. Install Quarto

<https://quarto.org/docs/get-started/>

### 2. Install R packages (one-time)

```bash
Rscript install_packages.R
```

This installs `renv`, then bootstraps the project library and writes `renv.lock`. Commit `renv.lock` after it's generated.

On subsequent sessions:

```r
renv::restore()
```

### 3. Preview locally

```bash
quarto preview
```

Opens the book in your browser with hot-reload.

### 4. Render HTML

```bash
quarto render --to html
```

Outputs land in `_book/`. PDF is **on demand only** — run `quarto render --to pdf` when you actually need it. EPUB is no longer produced.

## Publishing

The book is published manually via Quarto's built-in `gh-pages` target — no CI. The standard two-command flow keeps the live site in sync with `main`:

```bash
quarto render --to html
quarto publish gh-pages --no-prompt --no-render
```

`--no-render` reuses the freshly built `_book/`, so HTML chunks only execute once. The publish step then:

1. Switches to a temporary `gh-pages` worktree.
2. Copies `_book/` into it.
3. Force-pushes the rendered output to the `gh-pages` branch on `origin`.
4. Returns to your working branch.

GitHub Pages serves the `gh-pages` branch at the root path. The first publish requires an empty `gh-pages` branch to exist on the remote and Pages to be configured (`Source: gh-pages` `/`) — both already done in this repo. Subsequent publishes are one command.

> **Tip:** if `git push` fails inside `quarto publish` with `HTTP 400`, bump git's HTTP post buffer once:
> ```bash
> git config http.postBuffer 524288000
> ```

## Writing chapters

Each chapter is a `.qmd` file with R code chunks:

```` markdown
---
title: "Chapter title"
---

## Section

Some prose. Cite like this: [@abadie2003economic].

```{r}
library(tidyverse)
# code
```
````

Add bibliography entries to `references.bib`. They appear on the **References** page automatically.

The preface (`index.qmd`) and references (`references.qmd`) use a top-level `# Heading {.unnumbered}` instead of a YAML `title:` field, so they appear in the sidebar without a chapter number.

## License

MIT — see [LICENSE](LICENSE).
