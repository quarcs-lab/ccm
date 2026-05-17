# Comparative Causal Metrics

**An Introduction to Regional Impact Evaluation**

Source for the Quarto book by Carlos Mendez. Built with **R + Quarto**, deployed to GitHub Pages via GitHub Actions.

- 📖 Read online: <https://quarcs-lab.github.io/ccm/>
- 📄 PDF & EPUB: download links in the book's navbar
- 🐙 Source: <https://github.com/quarcs-lab/ccm>

---

## Project structure

```
ccm/
├── _quarto.yml                       # Book config (HTML + Typst PDF + EPUB)
├── index.qmd                         # Preface
├── 01-introduction.qmd
├── 02-interrupted-time-series.qmd
├── 03-rd-in-time.qmd
├── 04-classical-synthetic-control.qmd
├── 05-structural-bayesian-ts.qmd
├── references.qmd                    # Bibliography target
├── references.bib                    # BibTeX entries
├── apa.csl                           # Citation style (APA 7)
├── custom.css                        # Theme palette and overrides
├── images/                           # Cover, favicon, figures
├── DESCRIPTION                       # Human-readable dep manifest
├── install_packages.R                # One-time renv bootstrap
├── renv.lock                         # Generated after first install
└── .github/workflows/publish.yml     # CI: render + publish to gh-pages
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

### 4. Full render (HTML + PDF + EPUB)

```bash
quarto render
```

Outputs land in `_book/`.

## Deployment

Push to `main`. The workflow in `.github/workflows/publish.yml`:

1. Sets up Quarto, R, and restores `renv.lock`.
2. Renders all formats.
3. Publishes `_book/` to the `gh-pages` branch via `quarto-actions/publish@v2`.

GitHub Pages must be configured to serve from the `gh-pages` branch (Settings → Pages → Source: `gh-pages` / `(root)`). The first successful workflow run creates the branch.

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

## License

MIT — see [LICENSE](LICENSE).
