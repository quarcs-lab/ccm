# Comparative Causal Metrics

**An Introduction to Regional Impact Evaluation**

Source for the Quarto book by Carlos Mendez. Built with **R + Quarto**, published to GitHub Pages via Quarto's built-in local-render workflow (`quarto publish gh-pages`).

- 📖 Read online: <https://quarcs-lab.github.io/ccm/>
- 📄 PDF: optional download link in the book's navbar (rebuilt on demand)
- 🐙 Source: <https://github.com/quarcs-lab/ccm>

---

## Project status

**Stage:** all six method chapters drafted with live R against the Proposition 99 dataset. Preface and cross-method discussion still to do.

| # | Chapter | File | Status |
|---|---|---|---|
| — | Preface | `index.qmd` | stub |
| 1 | Introduction | `01-introduction.qmd` | first draft (live R; Prop 99 example) |
| 2 | Interrupted Time Series | `02-interrupted-time-series.qmd` | first draft (live R; growth-curve + ARIMA) |
| 3 | Regression Discontinuity in Time | `03-rd-in-time.qmd` | first draft (live R; segmented regression) |
| 4 | Basic Differences-in-Differences | `04-basic-diff-in-diff.qmd` | first draft (live R; CA vs Nevada) |
| 5 | Classical Synthetic Control | `05-classical-synthetic-control.qmd` | first draft (live R; full tidysynth pipeline) |
| 6 | Structural Bayesian Time Series | `06-structural-bayesian-ts.qmd` | first draft (live R; CausalImpact + BSTS) |
| — | References | `references.qmd` | 11 entries (Prop 99 sources ported) |

**Infrastructure (complete):**

- [x] Quarto book project with HTML (auto-published) + LaTeX PDF (on demand)
- [x] Dark/light theme toggle (`cosmo` / `darkly`) with custom CSS palette
- [x] `renv.lock` pinning 146 R packages at R 4.5.2 for reproducibility
- [x] Bibliography wired in (`references.bib` + `apa.csl`)
- [x] Cover image and favicon
- [x] Live site on GitHub Pages via `quarto publish gh-pages`

**What the drafted chapters contain:** every method chapter (1–6) is built from the same cached Proposition 99 dataset (`data/proposition99.rds`) with live R code. Chapter 1 frames the potential-outcomes problem, walks the decision tree, and runs a naive pre-post strawman. Chapters 2–6 each take one method family — ITS (growth-curve + ARIMA), RDD on time, single-control DiD, classical Synthetic Control with placebo permutation, and CausalImpact / BSTS — and report the ATT against the same canonical case study. All chunks render live.

**Next:**

- Preface (`index.qmd`) — flesh out the front matter.
- Cross-method comparison chapter — bring all six ATT estimates onto one forest plot and discuss the disagreements.
- Per-chapter exercises.

---

## Project structure

```
ccm/
├── _quarto.yml                       # Book config (HTML + PDF + EPUB)
├── index.qmd                         # Preface (unnumbered)
├── 01-introduction.qmd
├── 02-interrupted-time-series.qmd
├── 03-rd-in-time.qmd
├── 04-basic-diff-in-diff.qmd
├── 05-classical-synthetic-control.qmd
├── 06-structural-bayesian-ts.qmd
├── references.qmd                    # Bibliography target (unnumbered)
├── references.bib                    # BibTeX entries
├── apa.csl                           # Citation style (APA 7)
├── custom.css                        # Theme palette and overrides
├── images/                           # Cover, favicon, figures
├── DESCRIPTION                       # Human-readable dep manifest
├── install_packages.R                # One-time renv bootstrap
├── renv.lock                         # Pinned R deps
└── _book/                            # Render output (gitignored)
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
