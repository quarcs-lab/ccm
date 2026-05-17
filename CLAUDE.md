# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A **Quarto book** ("Comparative Causal Metrics") authored in R and published to GitHub Pages. It is not an R package — `DESCRIPTION` exists only as a human-readable dep manifest so RStudio's "Install Dependencies" button works. Do not treat it as CRAN-bound.

The book is in the **scaffolding stage**: chapter `.qmd` files are stubs with section outlines and `eval: false` R chunks. The infrastructure (theming, renv, bibliography, publish workflow) is complete.

## Common commands

```bash
# One-time setup after cloning
Rscript install_packages.R       # bootstraps renv + writes renv.lock

# In an R session on subsequent pulls
renv::restore()                   # sync local library to renv.lock

# Local authoring
quarto preview                    # hot-reload preview in browser
quarto render                     # full HTML + PDF + EPUB build into _book/

# Render a single chapter (faster iteration)
quarto render 04-basic-diff-in-diff.qmd

# Publish (manual, no CI)
quarto publish gh-pages --no-prompt
```

`quarto publish gh-pages` re-renders, force-pushes to the `gh-pages` branch, and returns to the working branch. PDF output requires LaTeX — Quarto will prompt to install TinyTeX on first PDF render.

## Architecture notes

- **`_quarto.yml`** is the source of truth for chapter ordering, theming (`cosmo` light / `darkly` dark), and the three output formats (HTML / PDF / EPUB). New chapters must be added to the `chapters:` list there, not just dropped in the directory.
- **`execute: freeze: auto`** in `_quarto.yml` caches chunk output in `_freeze/`. The cache is gitignored; expect first renders on a clean checkout to be slower.
- **Chapter stubs use `#| eval: false`** on R chunks so the book renders before analyses are written. When you actually implement a chapter, remove `eval: false` chunk-by-chunk as the code becomes runnable — flipping a whole file at once can break the build on a single bad chunk.
- **Preface and references** (`index.qmd`, `references.qmd`) use a top-level `# Heading {.unnumbered}` instead of a YAML `title:` field. That is what keeps them out of the chapter numbering. Don't "fix" them into the YAML-title style.
- **Citations** go in `references.bib` (BibTeX). They render with the APA 7 style from `apa.csl` and appear automatically on the References page — there is nothing to wire up per-citation.
- **Theming overrides** live in `custom.css`, loaded by the HTML format only.

## No CI — publishing is local

The `.github/workflows` directory was intentionally removed (commits `7880ce4`, `04dde43`). All publishing happens from a developer's machine via `quarto publish gh-pages`. Do not add a render-and-deploy workflow without asking — the local-only flow is a deliberate choice driven by reproducibility friction with `renv` in CI (see commits `57eb87d`, `8369059`, `cd179e3` for the abandoned CI debugging trail).

## Dependencies

Pinned in `renv.lock` at **R 4.5.2** with 146 packages. The high-level deps a chapter is likely to use:

- Authoring: `knitr`, `rmarkdown`, `tidyverse`, `scales`, `gt`, `modelsummary`
- Methods: `fixest` (DiD / two-way FE), `tidysynth` + `Synth` (synthetic control), `CausalImpact` + `bsts` (Bayesian structural TS), `rdrobust` (RD), `segmented` + `nlme` (interrupted TS)

If you add a package, install it via `renv::install("pkg")` then `renv::snapshot()` so `renv.lock` updates.
