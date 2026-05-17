# Audit: Preface (`index.qmd`)

## Summary

The preface is short (38 lines), well-written, and correctly structured as a Quarto unnumbered preface. The two-part scoping (Prop 99 single-treated unit vs Callaway-Sant'Anna staggered panel) is crisp and the per-method bullet lists are accurate. However, it has one **broken-link bug** (GitHub URL points to the wrong account), one **roadmap omission** (chapter 1 is silently dropped from Part I's bullet list), and several pedagogical gaps that matter for an advanced-undergrad audience: no audience statement, no prerequisites, no pointer to the introduction chapter's vocabulary, no citation guidance, no license note, and an acknowledgments section that thanks no one and credits no datasets. There is also a fragile claim that the PDF is "available in the navbar" — true today, but CLAUDE.md flags PDF as on-demand only, so the live-site link can be stale.

## Strengths

- Heading style is correct: `# Preface {.unnumbered}` (CLAUDE.md rule). Renders as `<h1 class="unnumbered">Preface</h1>` (verified in `_book/index.html:465`).
- Cover image (`images/cover1wide.jpg`) renders with alt-text and `.preview-image` class, which feeds Open Graph / Twitter cards correctly.
- The two-part structure (`Part I — One region, one shock` / `Part II — Many regions, staggered adoption`) is genuinely informative phrasing — much better than a flat method list.
- Each Part I bullet (lines 13–18) names the method AND the modelling principle (e.g. "extrapolating California's pre-period trajectory forward"). That's the right level of specificity for a preface.
- Line 11 correctly defines the ATT estimand and the post-period window (1989–2000) up front.
- The `.zip` download story (line 34) is described accurately and matches the JS injection in `_quarto.yml:67-99`.

## Writing & structure issues

### W1. `index.qmd:32` — wrong GitHub URL (broken link bug)

The preface says `[GitHub](https://github.com/cmg777/ccm)`, but `_quarto.yml:20` declares `repo-url: https://github.com/quarcs-lab/ccm`, the live site is at `https://quarcs-lab.github.io/ccm/`, and `README.md` line 9 lists `https://github.com/quarcs-lab/ccm` as the canonical source. The `cmg777` URL is the author's personal mirror (acknowledged on line 38) or the older incarnation referenced in the companion project — either way the preface points readers to the wrong repo.

**Fix:** change the link target to `https://github.com/quarcs-lab/ccm`.

### W2. `index.qmd:13–18` — chapter 1 is missing from the Part I roadmap

The preface says "Chapters 1–7 evaluate California's 1989 Proposition 99 cigarette tax" (line 11) and then lists six method bullets (lines 13–18), one per chapter — but those six bullets correspond to chapters **2–7**. Chapter 1 (`01-introduction.qmd`, title "Introduction"), which sets up the potential-outcomes framework and runs the naive pre-post strawman, is silently dropped. A reader counting bullets vs the "Chapters 1–7" claim will be confused.

**Fix:** either (a) prepend a bullet — `**Introduction** — the potential-outcomes vocabulary and a naive pre-post strawman estimate.` — or (b) rephrase line 11 to "Chapters 2–7 evaluate ... after chapter 1 introduces the potential-outcomes vocabulary."

### W3. `index.qmd:5–28` — no audience or prerequisites statement

The book is pitched (in the user-supplied audit brief) at "mixed undergrad-friendly but rigorous (advanced undergrads through early-career researchers)", but the preface never says so. It also never tells readers what they should already know (R basics, OLS / fixed effects, ideally one semester of econometrics). A reader landing on the live site at `quarcs-lab.github.io/ccm/` has no way to self-select.

**Fix:** add a short subsection between "About this book" and the Part I block, e.g.:

```markdown
### Who this book is for

The book is written for advanced undergraduates, master's students,
and early-career researchers who already know basic R (`tidyverse`-style
data wrangling, fitting `lm()`) and one semester of econometrics
(OLS, fixed effects, standard errors). No prior exposure to
causal inference is assumed — chapter 1 introduces the potential-outcomes
framework from scratch.
```

### W4. `index.qmd:11` — `ATT` is used before it is defined

Line 11 ends with "...reports the average treatment effect on the treated (ATT) between 1989 and 2000." The acronym is expanded in place, which is fine, but a reader who has not yet hit chapter 1 has no anchor for *what* an ATT is or *why* it is the target rather than the ATE. This is the only piece of technical vocabulary in the whole preface, so a one-sentence gloss is cheap.

**Fix:** append to line 11: "...— that is, how California's cigarette sales after the policy compare against what they would have been *without* it. Chapter 1 makes this missing-counterfactual logic precise." This also creates the forward link to chapter 1 that W6 calls out.

### W5. `index.qmd:32` — fragile claim about the PDF

Line 32 says "the entire book is available as a PDF download in the navbar." `_quarto.yml:24` does have `downloads: [pdf]`, so the navbar entry exists. But per `CLAUDE.md` ("PDF builds only when the user explicitly asks ... Do not 'be helpful' by including PDF in a routine republish"), the PDF is *not* rebuilt with every HTML publish. Readers who click the navbar PDF link can therefore land on a stale build (or a 404 if no PDF has ever been published).

**Fix:** soften the claim. E.g. "An on-demand PDF build is available from the navbar `</> Code` menu; it may lag a few commits behind the HTML site." Alternatively, drop the PDF sentence entirely and lean on the per-chapter `.zip` story in the next paragraph.

### W6. `index.qmd:30–34` — no forward link to chapter 1

"How to read this book" tells readers chapters are sequential and self-contained, but never says "start with chapter 1, which introduces the potential-outcomes framework and the decision tree that organises the whole book." Chapter 1 contains a full decision-tree mermaid diagram (`01-introduction.qmd:105-119`) that *is* the book's spine — the preface should advertise it.

**Fix:** add at the end of line 32: "Readers new to causal inference should start with chapter 1, which lays out the potential-outcomes vocabulary and a decision tree that maps each data situation to the appropriate method in this book."

### W7. `index.qmd:36–38` — Acknowledgments thanks no one and credits no datasets

The current Acknowledgments is a single sentence pointing at the *Mastering Causal Metrics* sibling repo. It does not thank any reviewer, collaborator, student, or funder, and — more visibly — it does not credit the two case-study datasets that the entire book depends on: Abadie, Diamond & Hainmueller (2010) for the Prop 99 panel, and Callaway & Sant'Anna for the minimum-wage county panel. Both are cited inside chapters (and live in `references.bib`), but the preface is the conventional place to flag dataset provenance.

**Fix:** expand to three to four sentences, e.g.:

```markdown
This book builds on the infrastructure of the companion project
[*Mastering Causal Metrics*](https://github.com/cmg777/intro2causal)
and on a long tradition of applied econometric scholarship.
The Proposition 99 panel used throughout Part I was assembled by
@abadie2010synthetic; the staggered-adoption minimum-wage panel
in Part II is the county-level dataset packaged with the
`did` R package by @callaway2021difference. I am grateful to
the open-source maintainers of `tidysynth`, `Synth`, `CausalImpact`,
`bsts`, `scpi`, `did`, `HonestDiD`, `fect`, and `gsynth` — every
chapter is a thin wrapper around their work.
```

### W8. Missing — no License section

The preface never tells readers under what terms they can reuse the code or prose. `README.md:167-169` says MIT and a `LICENSE` file exists at the repo root, but a casual reader of the web book never sees the README. Conventional book prefaces include a one-line license note.

**Fix:** add a short final section before or after Acknowledgments:

```markdown
## License

The text of this book and all R code are released under the
MIT License — see [LICENSE](https://github.com/quarcs-lab/ccm/blob/main/LICENSE).
You are free to reuse, adapt, and redistribute the material with attribution.
```

### W9. Missing — no "How to cite" guidance

For a book aimed partly at early-career researchers, a one-line citation example is conventional and frictionless to add.

**Fix:** after the License block, add:

```markdown
## How to cite

> Mendez, C. (2026). *Comparative Causal Metrics: An Introduction to
> Regional Impact Evaluation*. <https://quarcs-lab.github.io/ccm/>
```

## Cross-chapter consistency issues

### C1. `index.qmd:11` — vocabulary mismatch with chapter 1

The preface says the methods "report the average treatment effect on the treated (ATT)" — singular. But chapter 1 (`01-introduction.qmd:77`) introduces $\text{ATT}(g, t)$ for the Part II staggered-adoption case, and the preface itself acknowledges this on line 22 ("a family of cohort-specific ATTs indexed by adoption year"). The wording on line 11 should at least hint that "ATT" generalises in Part II.

**Fix:** see W4 — the suggested rewrite already qualifies the line-11 claim by attaching it to "California 1989–2000", leaving room for line 22's generalisation to land cleanly.

### C2. `index.qmd:36–38` — Part II case study is named on line 22 but not credited in Acknowledgments

The preface invokes "the Callaway-Sant'Anna minimum-wage county panel" on line 22 as if the reader knows what that is. Chapters 8–10 cite `@callaway2021difference` in their bodies. The preface should either (a) drop the proper-noun name on line 22 in favour of a description, or (b) credit Callaway and Sant'Anna in Acknowledgments. Option (b) is the W7 fix.

### C3. `index.qmd:13–18` vs chapter titles — bullet wording matches chapter `## section headers` but not chapter titles exactly

This is **not** a bug, but worth noting: the bullet on line 16 says "Structural Bayesian time series", and the chapter title (`05-structural-bayesian-ts.qmd:2`) is "Structural Bayesian Time Series" — capitalisation differs. The bullet on line 17 says "Synthetic control with prediction intervals" — chapter title is "Synthetic Control with Prediction Intervals". Sentence-case bullets are a defensible style choice; keep them as-is, but if you prefer title-case (matching the sidebar and the chapter `<title>` tags), capitalise the head noun of each bullet.

## Infrastructure issues

### I1. None blocking

- `# Preface {.unnumbered}` — correct per CLAUDE.md "Preface and references ... use a top-level `# Heading {.unnumbered}` instead of a YAML `title:` field." Verified in render at `_book/index.html:465`.
- Cover image path `images/cover1wide.jpg` (line 3) resolves to a real file in `images/`. Note that the navbar / TOC cover injected by the JS in `_quarto.yml:75-81` uses a *different* image (`images/cover1.jpg`); both files exist, so this is intentional, not a bug.
- The preface has no R code chunks, so `freeze: auto` caching and the per-chapter `.zip` build hook don't apply to it.
- The preface is correctly listed first in the `chapters:` array (`_quarto.yml:27`) and is excluded from the per-chapter zip injection because its filename does not start with `NN-` (matches the JS regex on `_quarto.yml:84`).

### I2. `index.qmd:32` — link uses bare anchor text "GitHub"

Minor: the anchor text is just "GitHub" rather than "the project repository" or "the source on GitHub". Search engines and screen readers prefer descriptive anchor text. Combined with the W1 URL fix:

`The full source is available [on GitHub](https://github.com/quarcs-lab/ccm).`

(arguably still bare — but at least the URL is correct.)

## Prioritized fix list

### P1 — must fix before next publish (correctness and broken links)

- **W1** `index.qmd:32` — change `github.com/cmg777/ccm` to `github.com/quarcs-lab/ccm`. (Bug.)
- **W2** `index.qmd:11, 13` — add chapter 1 to the Part I roadmap (either prepend an "Introduction" bullet to lines 13–18, or rephrase line 11 to "Chapters 2–7 ...").

### P2 — should fix soon (pedagogical completeness for the stated audience)

- **W3** Add a `### Who this book is for` subsection naming the audience and the R + econometrics prerequisites.
- **W4** `index.qmd:11` — one-sentence gloss of what an ATT is, with a forward pointer to chapter 1.
- **W6** `index.qmd:32` — add an explicit "start with chapter 1" sentence in "How to read this book".
- **W7** Expand Acknowledgments to credit the Prop 99 data (Abadie, Diamond, Hainmueller) and the minimum-wage panel (Callaway, Sant'Anna), plus the open-source R-package maintainers.
- **W8** Add a `## License` section (MIT, link to the repo `LICENSE`).

### P3 — nice-to-have polish

- **W5** `index.qmd:32` — soften the "PDF in the navbar" claim, given CLAUDE.md's on-demand-only PDF rule.
- **W9** Add a `## How to cite` block with a copy-pasteable citation.
- **C3** Optional: harmonise bullet capitalisation (sentence case vs title case) between the Part I/II bullets and the chapter titles.
- **I2** Replace bare "GitHub" anchor text with something more descriptive.
