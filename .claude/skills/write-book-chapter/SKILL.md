---
name: write-book-chapter
description: >-
  Author a new method chapter for the "Comparative Causal Metrics" Quarto book
  (this repo) in the established house style, then keep the whole book in sync:
  chapter numbering (append or insert+renumber), _quarto.yml, the preface
  (index.qmd), chapter 1's roadmap table and decision-tree mermaid, the README,
  references.bib, the per-chapter download bundles (R/build_chapter_zips.R), and
  the neighbour-chapter cross-references. Renders the chapter live until clean,
  then commits and publishes. Use whenever the user wants to add, insert, or
  draft a chapter for this book.
---

# Write a book chapter

This skill writes a new **method chapter** for *Comparative Causal Metrics*
(`/Users/carlosmendez/Documents/GitHub/ccm`) and synchronises every other file
the new chapter touches. The book is a Quarto book in R; see the project
`CLAUDE.md` for the publishing rules (HTML auto-publishes; never run a bare
`quarto render`; PDF only on request; no EPUB; no CI).

The chapter must be **highly pedagogical and easy to read: short, clear
sentences; one idea per sentence.** Every chapter follows one fixed template and
one fixed notation system. Do not invent a new structure — match the existing
chapters exactly.

## Reference files — read these before writing

Open and follow all three. They are the source of truth for this skill.

1. `references/house-style.md` — voice, the bold lead-in labels, the book-wide
   notation table, the colour palette, the transparent ggplot theme block, chunk
   conventions, citation/figure/table rules, and the anti-bug rules distilled
   from `audit/`.
2. `references/chapter-skeleton.qmd` — the canonical section order, annotated.
   Copy this and fill it in; do not reorder sections.
3. `references/integration-checklist.md` — every file to update for a new
   chapter, the **append vs. insert+renumber** procedures, and the
   render → commit → publish steps.

Also skim one existing chapter end-to-end before writing (e.g.
`02-interrupted-time-series.qmd` for a Part I single-unit method, or
`08-staggered-did.qmd` for a Part II panel method) so the new chapter reads like
a sibling, not a stranger.

## Workflow

Work through the phases in order. Do not skip the outline checkpoint (Phase 2).

### Phase 0 — Intake

From the user's brief, determine:

- **Method** and its **R package(s)**.
- **Dataset**: an existing one (`data/proposition99.rds` for Part I single
  treated unit; `data/cs_minwage.rds` for Part II staggered adoption) or a
  **new** dataset the user supplies/points to.
- **Placement**: *append* as the new last method chapter, or *insert* at a
  specific position. The user usually states this; if not, infer from where the
  method fits the book's arc and confirm at Phase 2.
- **Part**: Part I (single-unit, Proposition 99 case study) or Part II
  (staggered adoption, minimum-wage panel). The dataset usually settles this. A
  chapter that crosses the I↔II seam needs the "Part begins here" callout (see
  house style).

The brief is typically partial ("method + package"). Fill gaps yourself and
**flag every assumption** at the Phase 2 checkpoint.

### Phase 1 — Research and resolve gaps

- Confirm the R package's real API. Check `renv.lock` to see if the package is
  already pinned. If it is **new**, plan to `renv::install("pkg")` then
  `renv::snapshot()` (per `CLAUDE.md`), and add it to `DESCRIPTION`'s manifest.
- Gather **verified, real citations** (use web search/fetch — do not invent
  bib data): the method's seminal paper, the R package, and 1–2 tutorials or
  surveys. Capture author, year, venue, volume/issue/pages, and a URL/DOI.
  Match the BibTeX style already in `references.bib`.
- Decide the chapter's worked estimand. In Part I it is the ATT on California,
  1989–2000, expressed as an imputed `$\widehat{Y_{1t}(0)}$`. In Part II it is
  the staggered-adoption ATT(g, t) family on the minimum-wage panel.

### Phase 2 — Outline checkpoint (required)

Present a short outline to the user and **wait for approval**:

- Section list (from the skeleton) and the one-line "idea" of each method
  variant the chapter will cover.
- The **identification assumption** in one sentence.
- Dataset and the specific subset/transformation used.
- Key equations written in the book's notation (see the notation table).
- The exact list of references to add to `references.bib`.
- Placement and the **renumber impact** (which files/chapters get renamed).
- Any assumptions you made filling gaps in the brief.

Use `AskUserQuestion` (or a plain numbered list) for choices. Do not start
writing the full chapter until the outline is approved.

### Phase 3 — Write the chapter `.qmd`

Copy `references/chapter-skeleton.qmd` to the correct filename (see Phase 4 for
the number) and fill it in following `references/house-style.md`. Non-negotiables:

- Setup chunk sources `R/table_helpers.R` and sets the transparent ggplot theme
  verbatim from the house style.
- **Every reported number comes from inline R** (`` `r sprintf(...)` ``), never
  hardcoded prose. This is the single most important rule — it is what prevents
  the prose-vs-cache drift catalogued in `audit/AUDIT.md`.
- Tables via `gt_pretty()` / `ms_pretty()`; captions via `#| tbl-cap`, never
  `title=`. Figures via `#| fig-cap`. Use the book's colour palette.
- Notation matches the book-wide table; if the method needs a symbol that
  collides (`τ`, `λ`, `α`, `w`/`W`), rename it and add a one-line gloss.
- Open with a callback to the previous chapter by name and number; close with a
  hand-off to the next chapter (or, for the last method chapter, to the planned
  cross-method comparison chapter).
- Include all template sections: Learning objectives, the "… idea" + an
  **Identification** paragraph, Setup and data, the per-method sections (**The
  idea / The equation / Reading the output / Common pitfall**), a discussion
  section, **Key takeaways** (grouped Methods / Lessons / Caveats), **Further
  reading** (annotated), and graduated **Exercises** with collapsible solutions.

### Phase 4 — Integrate (full sync)

Follow `references/integration-checklist.md` exactly. In brief, for an **append**
you add the new files/entries; for an **insert at position N** you first
`git mv` every later `NN-*.qmd` up by one (highest number first) and rewrite all
cross-references, then add. Files to touch: `_quarto.yml`,
`R/build_chapter_zips.R` (+ a data-shipping branch if the dataset is new),
`index.qmd`, `01-introduction.qmd` (roadmap table row, decision-tree mermaid
node + edges, "Roadmap of the book" Part list, Further reading),
`README.md` (chapter table, prose, project-structure tree), `references.bib`,
the **previous** chapter (closing hand-off) and the **next** chapter (opening
callback), and `data/` if a new dataset is introduced.

### Phase 5 — Render and fix until clean

```bash
quarto render --to html NN-your-chapter.qmd   # iterate on the single chapter
quarto render --to html                        # full book, for cross-references
```

- If a render fails on a missing package, `renv::install()` it, `renv::snapshot()`,
  then re-render.
- Iterate until: no errors; **no warnings leak into the HTML** (do not silence
  them with `warning: false` on modelling chunks — fix the cause); no `NA` inline
  numbers; no empty tables; no flat-zero figures.
- Run the self-audit in `references/integration-checklist.md` (notation, inline
  numbers, captions/labels, opening callback + closing hand-off, cross-reference
  numbers all correct after any renumber).

### Phase 6 — Commit and publish

Per the user's standing choice for this skill: render, commit, **and** publish.

```bash
quarto render --to html
quarto publish gh-pages --no-prompt --no-render
```

For git: if on the default branch `main`, create a feature branch first, commit
all changed/renamed files there (end the message with the
`Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>` trailer),
then publish. Because `CLAUDE.md` requires the live site to stay in sync with
`main`, tell the user to merge the branch into `main` (or offer to). Never run a
bare `quarto render` and never add PDF/EPUB to the routine publish.

## Definition of done

- New `NN-*.qmd` renders live with no errors/warnings and reads in the house
  style (short sentences, all template sections, inline numbers).
- Numbering is consistent everywhere; if inserted, every renamed chapter and
  every cross-reference was updated.
- `_quarto.yml`, `R/build_chapter_zips.R`, `index.qmd`, `01-introduction.qmd`,
  `README.md`, and `references.bib` all reflect the new chapter.
- Neighbour chapters have the callback/hand-off paragraphs; Part-seam callout
  added if the chapter crosses Part I↔II.
- Full book rendered, committed on a branch, and published to `gh-pages`; user
  reminded to merge to `main`.
