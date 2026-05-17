# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A **Quarto book** ("Comparative Causal Metrics") authored in R and published to GitHub Pages. It is not an R package — `DESCRIPTION` exists only as a human-readable dep manifest so RStudio's "Install Dependencies" button works. Do not treat it as CRAN-bound.

The book is **in progress**: ten method chapters are drafted with live R, organised in two parts. **Part I (chs. 1–7)** runs the canonical Proposition 99 single-treated-unit case study; **Part II (chs. 8–10)** switches to the Callaway-Sant'Anna minimum-wage county panel for staggered-adoption methods. No `eval: false` stubs remain. The preface (`index.qmd`) is drafted. A planned cross-method comparison chapter is still to do. See `README.md` for the current chapter table.

## Common commands

```bash
# One-time setup after cloning
Rscript install_packages.R       # bootstraps renv + writes renv.lock

# In an R session on subsequent pulls
renv::restore()                   # sync local library to renv.lock

# Local authoring
quarto preview                                       # hot-reload preview in browser
quarto render --to html                              # default — only output we ship
quarto render --to html 03-basic-diff-in-diff.qmd    # single-chapter iteration

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
- **Preface and references** (`index.qmd`, `references.qmd`) use a top-level `# Heading {.unnumbered}` instead of a YAML `title:` field. That is what keeps them out of the chapter numbering. Don't "fix" them into the YAML-title style.
- **Table rendering** is centralised in `R/table_helpers.R`, sourced from each chapter's setup chunk (`source("R/table_helpers.R")`). It exports two thin wrappers: `gt_pretty()` for data-frame / tibble output and `ms_pretty()` for regression models (built on `modelsummary`, accepts a `vcov=` function for HAC SEs). Both apply a clean academic look with a transparent background so tables read in both cosmo (light) and darkly (dark) themes.
- **Table captions follow Quarto convention, not gt:** every chunk that emits a table uses `#| label: tbl-<slug>` plus `#| tbl-cap: "..."`. Do *not* pass `title=` / `subtitle=` to `gt_pretty()` / `ms_pretty()` — that bypasses Quarto's caption numbering and cross-references. The same rule for figures (`#| label: fig-<slug>` + `#| fig-cap`), including Mermaid blocks (use `%%| label:` / `%%| fig-cap:` inside the block).
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

### Per-chapter download bundles

Every `quarto render` triggers the `R/build_chapter_zips.R` pre-render hook (registered under `project: pre-render:` in `_quarto.yml`). The hook rebuilds `downloads/chapter-{01..10}.zip` — self-contained Quarto bundles a reader can unzip and render via `quarto render <chapter>.qmd` with no `renv` and no repo clone. Quarto copies `downloads/` into `_book/downloads/` because it's listed under `project: resources:`. The `downloads/` directory is gitignored — the zips are derived artifacts. The download link appears as the last item inside the **"</> Code" dropdown menu** in the upper-right of each chapter; it is injected at runtime by the JS in `format.html.include-after-body` in `_quarto.yml` for any page whose filename starts with `NN-` (so `index.qmd` and `references.qmd` correctly get nothing). If you add a new content chapter, the only manual step is appending its filename to the `chapters` vector in `R/build_chapter_zips.R` — no per-chapter `.qmd` edit is needed.

## Dependencies

Pinned in `renv.lock` at **R 4.5.2** with 146 packages. The high-level deps a chapter is likely to use:

- Authoring: `knitr`, `rmarkdown`, `tidyverse`, `scales`, `gt`, `modelsummary`
- Part I (Prop 99): `fpp3` / `forecast` (ITS), `fixest` (basic DiD), `tidysynth` + `Synth` (classical synthetic control), `CausalImpact` + `bsts` (Bayesian structural TS), `scpi` (synthetic control with prediction intervals), `Rcpp` + the bundled `R/scspill/` helpers (Bayesian spatial SCM)
- Part II (CS minwage panel): `did` + `HonestDiD` (staggered DiD with Rambachan-Roth sensitivity), `fect` + `panelView` (matrix completion and interactive fixed effects), `gsynth` (generalized synthetic control)

If you add a package, install it via `renv::install("pkg")` then `renv::snapshot()` so `renv.lock` updates.
