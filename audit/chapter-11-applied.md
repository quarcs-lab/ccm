# Chapter 11 — References: applied changes

Target file: `/Users/carlosmendez/Documents/GitHub/ccm/references.qmd`

## Audit triage

The chapter-11 audit (`audit/chapter-11-references.md`) found that **every P1, P2, and P3 item targets `references.bib`, not `references.qmd`**. Per `audit/STAGE1-DONE.md`, all of those bibliography-level fixes have already been applied in Stage 1:

- P1.1 `callaway2022handbook` retyped to `@incollection` with editors/booktitle/pages — done in Stage 1.
- P1.2 `year` added to `causalimpact-pkg` (2014) and `brodersen-causalimpact-talk` (2015) — done in Stage 1.
- P2.3 orphan entries (`abadie2003economic`, `bai2003inferential`, `fpp3-pkg`) retained for possible reuse, with `fpp3-pkg` now carrying a `year` — done in Stage 1.
- P2.4 `number = {1}` on `brodersen2015inferring` — Stage 1 scope (`references.bib`).
- P2.5 `sakaguchi2026spatial` volume/issue/pages — Stage 1 scope (deferred until article finalises).
- P3.6 brace-protected package names in `dunford2024tidysynth`, `cattaneo2025scpi`, `fpp3-pkg` — done in Stage 1.
- P3.7 `dechaisemartin2020twoway` — no action needed per audit.

The audit explicitly notes:

> **`references.qmd` structure: Pass.** File content matches the CLAUDE.md convention exactly.

So no structural changes are needed in `references.qmd`. The 4-line stub is preserved.

## Change applied

Added a single two-sentence preamble between the `# References {.unnumbered}` heading and the `::: {#refs}` block, per the audit's optional-polish suggestion. The preamble:

1. Tells the reader the page is the consolidated index of all in-text citations.
2. Points them to each chapter's "Further reading" section for curated entry points.
3. Names the rendering style (APA 7), which matches `apa.csl` configured in `_quarto.yml`.

No inline citations were added — the auto-generated `::: {#refs}` block remains the single source of rendered references, as Quarto requires.

## Final file content

```
# References {.unnumbered}

The bibliography below collects every in-text citation across the book. Each chapter's "Further reading" section provides curated entry points; this page is the consolidated index, rendered in APA 7 style.

::: {#refs}
:::
```

## Constraints honoured

- Edited only `references.qmd`.
- Preserved the `# References {.unnumbered}` heading style.
- Preserved the `::: {#refs} :::` block verbatim.
- Kept the change minimal (one short paragraph) consistent with this being a trivial chapter.
