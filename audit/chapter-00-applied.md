# Chapter 00 (Preface) — applied audit report

Target file: `index.qmd`

## Items completed

### P1 — must fix

- **W1**: Fixed stale GitHub URL — `github.com/cmg777/ccm` → `github.com/quarcs-lab/ccm` in the "How to read this book" section. Anchor text also tightened to "[on GitHub]" (addresses I2 in passing).
- **W2**: Resolved roadmap inconsistency — kept the "Chapters 1–7" framing on the Part I intro line and prepended a new bullet "**Introduction** — the potential-outcomes vocabulary and a naive pre-post strawman estimate." to the Part I list, so the bullet count now matches the chapter range.

### P2 — pedagogical completeness

- **W3**: Added a new `### Who this book is for` subsection naming the audience (advanced undergrads, master's students, and early-career researchers in econometrics / public policy / spatial economics) and the R + intro econometrics prerequisites. The subsection sits between "About this book" and the Part I block, as suggested.
- **W4 / C1**: Added a one-sentence gloss of the ATT in the Part I intro paragraph ("compares California's observed cigarette sales after the policy against what they *would have been* without it") with an explicit forward pointer to chapter 1.
- **W6**: Added a "Readers new to causal inference should start with chapter 1, which lays out the potential-outcomes vocabulary and a decision tree…" sentence at the top of "How to read this book".
- **W7 / C2**: Expanded Acknowledgments to credit Abadie-Diamond-Hainmueller (`@abadie2010synthetic`) for the Prop 99 panel and Callaway-Sant'Anna (`@callaway2021difference`) for the minimum-wage county panel, plus the open-source maintainers of `tidysynth`, `Synth`, `CausalImpact`, `bsts`, `scpi`, `did`, `HonestDiD`, `fect`, and `gsynth`.
- **W8**: Added a `## License` section. Per Stage 1 (the `_quarto.yml` page-footer landed dual-license CC-BY 4.0 for text + MIT for code), the preface section now mirrors that: CC-BY 4.0 for prose, MIT for code, with a link to the repo `LICENSE`.

### P3 — polish

- **W5**: Softened the PDF claim. The old "the entire book is available as a PDF download in the navbar" sentence is replaced with "An on-demand PDF build of the book may also be available from the navbar; because PDFs are rebuilt only on request, the live PDF can lag a few commits behind the HTML site." This is consistent with the CLAUDE.md on-demand-only PDF rule.
- **W9**: Added a `## How to cite` section with a copy-pasteable APA-style citation pointing at `https://quarcs-lab.github.io/ccm/`.
- **I2**: Anchor text upgraded from bare "GitHub" to "[on GitHub]" while fixing the URL.

### Notation rename plan

Verified — preface introduces no math symbols, so `audit/NOTATION-RENAME-PLAN.md` does not bind here. No changes needed.

### Preserved per the constraints

- `# Preface {.unnumbered}` heading style retained (not switched to YAML title).
- Cover image (`images/cover1wide.jpg`) reference left untouched.
- No code chunks added.
- Prose voice preserved ("*Comparative Causal Metrics* is an introduction to…").

## Items not completed

- **C3 (optional polish)**: Bullet capitalisation was left in sentence case (e.g. "Interrupted time series", "Classical synthetic control"). The audit flagged this as a style choice rather than a bug, and harmonising bullets to title-case would touch every chapter title's wording in the sidebar for consistency, which is out of scope for a single-file edit.

No P1 or P2 items were skipped.
