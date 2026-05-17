# Stage 1C — Infrastructure cleanup — DONE

Scope: `_quarto.yml`, `install_packages.R`, `README.md`, and four stale local directories. No other file touched.

## (a) YAML added to `_quarto.yml`

Two edits to `format.html`:

**1. Added `date-modified: last-modified` under `book:` so the footer's `{{< meta date-modified >}}` resolves to the most recent file mtime at render time.**

```yaml
book:
  title: "Comparative Causal Metrics"
  subtitle: "An Introduction to Regional Impact Evaluation"
  author: "Carlos Mendez"
  date: "2026-05-17"
  date-modified: last-modified       # ← new
  date-format: "MMMM D, YYYY [(in progress)]"
```

**2. Added a `page-footer` block under `format.html`, placed between `mermaid:` and the existing load-bearing `include-after-body` JS (which is untouched).**

```yaml
    css: custom.css
    mermaid:
      theme: neutral
    page-footer:
      left: "© 2025–2026 Carlos Mendez · Source code [MIT](https://github.com/quarcs-lab/ccm/blob/main/LICENSE)-licensed; book text [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)."
      center: "[Comparative Causal Metrics](https://quarcs-lab.github.io/ccm/)"
      right: "[GitHub](https://github.com/quarcs-lab/ccm) · Last updated: {{< meta date-modified >}}"
    include-after-body:
      text: |
        <script>
        ...                          # ← unchanged; per-chapter-zip dropdown JS preserved verbatim
```

Notes:
- Left column carries copyright (static "2025–2026" range — no embedded R, matching Quarto's footer-string conventions) and the dual licensing statement requested in the audit (source MIT, prose CC-BY 4.0).
- Right column carries the repo link and a Quarto-native `{{< meta date-modified >}}` shortcode that resolves against `book.date-modified: last-modified`.
- Audit §5.5 also suggested a build timestamp via `Sys.time()`; using Quarto's `last-modified` is the canonical equivalent and avoids stuffing R into YAML.

## (b) Packages added to `install_packages.R`

Reconciled bootstrap vector against `DESCRIPTION` `Imports:`. Eight packages added (block-commented under a `# Part II — staggered DiD, matrix completion, IFE` divider, appended to the existing vector):

| Package        | Where used                                       |
| -------------- | ------------------------------------------------ |
| `did`          | ch.8 Callaway-Sant'Anna ATT(g,t)                 |
| `HonestDiD`    | ch.8 Rambachan-Roth sensitivity                  |
| `DRDID`        | ch.8 doubly-robust DiD backend                   |
| `fect`         | ch.9 matrix completion + interactive FE          |
| `twfeweights`  | ch.8 two-way FE weight diagnostics               |
| `BMisc`        | `did` dependency (made explicit per DESCRIPTION) |
| `pte`          | `did` dependency (made explicit per DESCRIPTION) |
| `patchwork`    | multi-panel ggplot composition                   |

Packages that were already in `install_packages.R` and remain unchanged: `tidyverse`, `fixest`, `modelsummary`, `gt`, `tidysynth`, `Synth`, `CausalImpact`, `bsts`, `segmented`, `nlme`, `rdrobust`, `scpi`, `scales`, `knitr`, `rmarkdown`, `sandwich`, `lmtest`, `broom`, `fpp3`, `glue`, `mice`, `ranger`, `gsynth`, `panelView`.

`renv` is bootstrapped at the top of the script (`requireNamespace("renv") || install.packages("renv")`), so it does not appear in the `pkgs` vector even though `DESCRIPTION` lists it — consistent with the prior structure of the script.

## (c) README lines changed

One line edited:

- **Line 30** (chapter table, references row): `~24 entries` → `~35 entries`. Placeholder per task brief (Stage 1A `STAGE1A-DONE.md` does not yet exist; bib currently has 27 entries pre-Stage-1A, expected to grow past 35 once 1A's additions land).

Chapter table on lines 17–30 was verified against the `.qmd` filenames on disk (`01-introduction.qmd` through `10-gsynth.qmd`, plus `index.qmd` and `references.qmd`). No drift — no further edit needed.

## (d) Directories deleted

```
rm -rf _freeze/06-bayesian-spatial-sc/
rm -rf _freeze/07-synthetic-control-prediction-intervals/
rm -rf 10-gsynth_files/
rm -rf 10-gsynth_cache/
```

Verification:

- `ls _freeze/` now shows only the canonical chapter folders (`01-introduction` … `10-gsynth` plus `site_libs`); the two stale rename-orphans (`06-bayesian-spatial-sc`, `07-synthetic-control-prediction-intervals`) are gone.
- `ls *_files *_cache` at repo root returns "no matches found" — the loose ch.10 render byproducts are gone.

All four directories were local-only / gitignored, so no `git rm` needed and no commit touches them.

## Out of scope (untouched)

No `.qmd` file, no `references.bib`, no `R/` helper, no `DESCRIPTION`, no `.gitignore`, no `renv.lock` was modified by Stage 1C.
