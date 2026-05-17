# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A **Quarto book** ("Comparative Causal Metrics") authored in R and published to GitHub Pages. It is not an R package — `DESCRIPTION` exists only as a human-readable dep manifest so RStudio's "Install Dependencies" button works. Do not treat it as CRAN-bound.

The book is **in progress**: ch. 1 (Introduction) and ch. 2 (Interrupted Time Series) are drafted with live R chunks against the Proposition 99 dataset; ch. 3–6 are still stubs with `eval: false`. See `README.md` for the current status table.

## Common commands

```bash
# One-time setup after cloning
Rscript install_packages.R       # bootstraps renv + writes renv.lock

# In an R session on subsequent pulls
renv::restore()                   # sync local library to renv.lock

# Local authoring
quarto preview                                       # hot-reload preview in browser
quarto render --to html                              # default — only output we ship
quarto render --to html 04-basic-diff-in-diff.qmd    # single-chapter iteration

# Publish HTML (manual, no CI). After any .qmd edit, run these two:
quarto render --to html
quarto publish gh-pages --no-prompt --no-render      # reuses _book/ from the render above

# PDF: on-demand only, when the user explicitly asks
quarto render --to pdf                               # needs TinyTeX; Quarto prompts on first run
```

`quarto publish gh-pages` switches to a temporary `gh-pages` worktree, copies `_book/` into it, force-pushes to `gh-pages` on `origin`, and returns to the working branch.

## Architecture notes

- **`_quarto.yml`** is the source of truth for chapter ordering, theming (`cosmo` light / `darkly` dark), and the configured output formats (HTML and PDF — EPUB has been removed). New chapters must be added to the `chapters:` list there, not just dropped in the directory.
- **`execute: freeze: auto`** in `_quarto.yml` caches chunk output in `_freeze/`. The cache is gitignored; expect first renders on a clean checkout to be slower.
- **Chapter stubs use `#| eval: false`** on R chunks so the book renders before analyses are written. When you actually implement a chapter, remove `eval: false` chunk-by-chunk as the code becomes runnable — flipping a whole file at once can break the build on a single bad chunk.
- **Preface and references** (`index.qmd`, `references.qmd`) use a top-level `# Heading {.unnumbered}` instead of a YAML `title:` field. That is what keeps them out of the chapter numbering. Don't "fix" them into the YAML-title style.
- **Citations** go in `references.bib` (BibTeX). They render with the APA 7 style from `apa.csl` and appear automatically on the References page — there is nothing to wire up per-citation.
- **Theming overrides** live in `custom.css`, loaded by the HTML format only.

## Publishing workflow (HTML auto-publishes; PDF on demand; no EPUB)

**The website at <https://quarcs-lab.github.io/ccm/> must stay in sync with `main`.** Every time a `.qmd` is modified, re-render HTML and re-publish:

```bash
quarto render --to html
quarto publish gh-pages --no-prompt --no-render
```

The `--no-render` flag on `publish` reuses the freshly built `_book/`, so HTML chunks only execute once. Do this proactively at the end of any session that edits a `.qmd` — the user should never have to ask.

**Hard rules:**

1. **HTML is the only format that auto-publishes.** Always pass `--to html` to `quarto render`. Never run a bare `quarto render` — it would silently rebuild PDF too and trigger a TinyTeX install on machines that don't already have it.
2. **PDF builds only when the user explicitly asks.** `pdf:` is kept in `_quarto.yml` so the format remains available, but the default render path skips it. Do not "be helpful" by including PDF in a routine republish.
3. **EPUB is removed.** Do not re-add the `epub:` block to `_quarto.yml` or `epub` to the `downloads:` list. The user does not need EPUB.
4. **No CI.** The `.github/workflows` directory was intentionally removed (commits `7880ce4`, `04dde43`). All publishing is local. Do not add a render-and-deploy workflow without asking — the local-only flow is a deliberate choice driven by reproducibility friction with `renv` in CI (see commits `57eb87d`, `8369059`, `cd179e3` for the abandoned CI debugging trail).

**On a fresh checkout**, the first `quarto render --to html` is slow because `execute: freeze: auto` has no cache yet. Subsequent renders only re-execute chunks whose source has changed.

## Dependencies

Pinned in `renv.lock` at **R 4.5.2** with 146 packages. The high-level deps a chapter is likely to use:

- Authoring: `knitr`, `rmarkdown`, `tidyverse`, `scales`, `gt`, `modelsummary`
- Methods: `fixest` (DiD / two-way FE), `tidysynth` + `Synth` (synthetic control), `CausalImpact` + `bsts` (Bayesian structural TS), `rdrobust` (RD), `segmented` + `nlme` (interrupted TS)

If you add a package, install it via `renv::install("pkg")` then `renv::snapshot()` so `renv.lock` updates.
