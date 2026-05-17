# Stage 1 — Shared prep complete

This consolidates the three Stage-1 agent reports (`STAGE1A-DONE.md`, `STAGE1B-DONE.md`, `STAGE1C-DONE.md`). Stage 2 chapter agents should treat the items below as **already landed** and write chapters that depend on these changes.

## Bibliography (`references.bib`)

7 new entries added (8th, `liu2024practical`, was already present):

| Cite key | Resolves to | Used by (chapter agent) |
|---|---|---|
| `cardkrueger1994minimum` | Card & Krueger 1994 AER min wage | C3 (basic DiD) |
| `bertrand2004how` | Bertrand-Duflo-Mullainathan 2004 QJE | C3 (basic DiD; HAC/clustering discussion) |
| `scott2014predicting` | Scott & Varian 2014 BSTS | C5 (BSTS) |
| `wagner2002segmented` | Wagner et al. 2002 segmented ITS | C2 (ITS) |
| `vanbuuren2011mice` | mice JSS paper | C5 (BSTS; mice imputation) |
| `george1997approaches` | George-McCulloch 1997 spike-and-slab | C5 (BSTS; spike-and-slab) |
| `roth2023whats` | Roth-Sant'Anna-Bilinski-Poe 2023 | C8 (staggered DiD; review) |

Already in bib:
- `liu2024practical` (Liu-Wang-Xu 2024 fect) — chapter agents can cite freely.

Other bib changes:
- `callaway2022handbook` retyped from `@article` to `@incollection` (with editors, booktitle, pages).
- Years added to `causalimpact-pkg` (2014), `brodersen-causalimpact-talk` (2015), `fpp3-pkg` (2020).
- Brace-protected lowercase package names in `dunford2024tidysynth`, `cattaneo2025scpi`, `fpp3-pkg`.
- Orphan entries (`abadie2003economic`, `bai2003inferential`, `fpp3-pkg`) retained — chapter agents may cite them if useful.

**Total bib entry count: 34.** Chapter agents can rely on every cite key listed above resolving.

## R helpers

### `R/honest_did.R` — IMPORTANT for C8

Line 36 fixed: `n` is now `nrow(es$inf.function$dynamic.inf.func.e)` (units, ~1745) instead of `length(es$DIDparams$data[[idname]])` (panel rows, ~8725). The variance was previously off by a factor of T² = 25.

**Consequence for the ch.8 agent (C8):** when the chapter re-renders, the HonestDiD breakdown `\bar M` will change from "≈ 1" to **between 0 and 0.5**. Prose at `08-staggered-did.qmd:339, 352–356, 365–366` must be rewritten. The CS analytic CI and Mbar=0 CI will now agree.

### `R/scspill/41_robustness_check.R` — Relevant for C7

Four bare-global references replaced with the argument names `W_raw`, `w_raw` (lines 38–40, 53, 176–177, 428–429). The audit listed three; agent caught a fourth at line 53. C7's robustness check chunks should now work without depending on globals.

### `R/scspill/22_mcmc_sar.R` — Important for C7

Line 43: `sar_full_sampler_cpp` → **`sar_full_sampler_cpp_step2`** (note: the audit suggested `sar_full_sampler_step2_cpp` with wrong suffix order; the real export is `sar_full_sampler_cpp_step2` per `R/scspill/20_mcmc.cpp:179`).

**Note for C7:** `sar_gibbs_sampler()` in this same file is still dead code — even with the symbol fix, the R argument order doesn't match the C++ signature. If C7 wants to revive it, mention this to the user but don't attempt the fix in this pass.

### `R/scspill/02_utils_data_prep.R`

Added a comment noting `scspill_prep()` is an unused tutorial-extension hook.

## Infrastructure

### `_quarto.yml`

- Added `date-modified: last-modified` to the `book:` block.
- Added a 3-column `page-footer` under `format.html` with copyright, dual-license note (MIT + CC-BY 4.0), book URL, GitHub repo link, and "Last updated" rendered from `{{< meta date-modified >}}`.
- The existing `include-after-body` JS (chapter-zip dropdown injection) was preserved byte-for-byte.

### `install_packages.R`

Synced with `DESCRIPTION` `Imports:`. Added: `did`, `HonestDiD`, `DRDID`, `fect`, `twfeweights`, `BMisc`, `pte`, `patchwork`. `gsynth` was already present.

### `README.md`

Line 30: `~24 entries` → `~35 entries`. (Actual is 34; close enough.)

### Cleanup (deletions)

- `_freeze/06-bayesian-spatial-sc/` — DELETED (orphan from rename)
- `_freeze/07-synthetic-control-prediction-intervals/` — DELETED (orphan from rename)
- `10-gsynth_files/` — DELETED (loose render byproduct)
- `10-gsynth_cache/` — DELETED (loose render byproduct)

These were not git-tracked. Local cleanup only.

## What Stage 2 chapter agents should NOT touch

Off-limits for all chapter agents:
- `references.bib`
- `_quarto.yml`
- `install_packages.R`
- `README.md`
- Any file under `R/`
- Any other chapter's `.qmd`
- The `_freeze/` cache

Stage 2 agents may only edit their own assigned `.qmd` file and write their own `audit/chapter-NN-applied.md` report.
