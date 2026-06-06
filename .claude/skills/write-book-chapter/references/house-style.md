# House style — Comparative Causal Metrics

The book teaches modern causal-inference methods through one running case study
per part. Every chapter is a thin, well-explained wrapper around one R package
applied to a shared dataset, and reports the same estimand. Disagreements between
methods on the same data *are the lesson of the book* — say so, chapter to chapter.

This file is the style contract. Match it exactly; readers should not be able to
tell which chapter was written when.

---

## 1. Voice and sentence style

- **Short, declarative sentences. One idea per sentence.** This is the top
  priority. If a sentence has two clauses joined by "and" that could stand
  alone, split it.
- Plain English first, then formalism. Define every symbol the first time it
  appears, in words, before or right after the equation.
- Present tense, active voice. "ITS drops the comparison unit." Not "the
  comparison unit is dropped by ITS."
- Address the reader directly but sparingly ("Read the diagnostic three ways.").
- Name the lesson out loud. Chapters frequently end a passage with a one-line
  moral ("the disagreement *is* the lesson"; "single-model ITS is fragile").
- Honest about limits. Every method gets a clear statement of what it cannot do
  and what assumption it rests on. Never oversell an estimate.
- British/American spelling: the book mixes "neighbour"/"-ise" with American
  terms. Don't crusade either way; match the surrounding chapter.

### Bold lead-in labels

Paragraphs are frequently introduced by a short **bold label** followed by a
period. Reuse this exact inventory; do not invent new ones casually:

- **The idea.** — plain-English intuition that opens each method section.
- **The equation.** — introduces the display math for that method.
- **What X means in plain English.** — unpacks notation (e.g. ARIMA(p,d,q)).
- **Why X.** — justifies a modelling choice (e.g. "Why d = 2 for this series.").
- **Reading the output.** — interprets the numbers the code just produced.
- **Common pitfall.** — closes a method section with the failure mode.
- **Identification.** — the one paragraph stating what makes the estimate causal.
- **Reading the diagnostic / A note on standard errors / Where this leaves us /
  The disagreement / Recap.** — discussion-section labels.

---

## 2. Fixed chapter structure

Use `chapter-skeleton.qmd`. Section order (all `##` unless noted):

1. YAML front matter — **only** `title: "Chapter Title"`. Nothing else. (The
   preface and references pages use `# Heading {.unnumbered}` instead; method
   chapters never do.)
2. `## Learning objectives` — a numbered list of 3–4 objectives. Each objective
   is two sentences: *what the reader will do*, then *why it matters / what it
   buys them*. (See `02`'s objectives for the pattern.)
3. *(Part-seam only)* a `::: {.callout-note appearance="simple"}` block titled
   **"Part II begins here."** when the chapter opens a new part. See §9.
4. `## The <method> idea` (or "When TWFE breaks…", etc.) — conceptual intro.
   Opens with a **callback to the previous chapter by name and number**. Lists
   the variants the chapter will fit. Ends with an **Identification.** paragraph.
5. `## Setup and data` — a **Packages.** paragraph, the setup chunk, a
   **Dataset.** paragraph, and the data-load chunk. See §5–§6.
6. One `## <Method variant>` section per estimator, each using the **The idea /
   The equation / [code] / Reading the output / Common pitfall** rhythm.
7. `## What the … estimates tell us` (or similar) — cross-variant discussion;
   reconcile the numbers; **close with a hand-off to the next chapter by name
   and number**. End with a **Recap.** sentence.
8. `## Key takeaways` — three bolded groups: **Methods:**, **Lessons:**,
   **Caveats:**, each a short bullet list. See §10.
9. `## Further reading` — annotated bibliography bullets. See §8.
10. `## Exercises` — 4–5 graduated exercises, each with a collapsible solution.
    See §11.

---

## 3. Notation (book-wide — enforce to avoid collisions)

The organising symbol of the whole book is the **imputed counterfactual**
`$\widehat{Y_{1t}(0)}$`. Every method is presented as a different way to build
it; then `ATT = observed − imputed`. Keep this through-line visible.

| Symbol | Meaning | Notes |
|---|---|---|
| `$Y_{it}(0)$`, `$Y_{it}(1)$` | Potential outcomes for unit `i` at time `t` | Collapse `i → 1` for the single treated unit (California); signal the substitution once. |
| `$Y_{it}$` | Observed outcome | **Uppercase `Y` always.** Never lowercase `y_{it}`. |
| `$\widehat{Y_{1t}(0)}$` | The imputed counterfactual | The book's centrepiece symbol. Use it in the chapter and in chapter 1's roadmap row. |
| `$\tau$`, `$\widehat{\tau}_{\text{method}}$` | Treatment effect / estimator | `$\tau$` is **reserved for treatment effects book-wide.** Subscript the method: `\widehat{\tau}_{\text{ITS-lin}}`, `\widehat{\tau}_{\text{DiD}}`, `\widehat{\tau}_{\text{CS}}`. Never reuse `τ` for a hyperparameter. |
| ATT, ATE | `E[Y(1)−Y(0) | D=1]`, `E[Y(1)−Y(0)]` | The book targets the **ATT**. |
| ATT(g, t) | Group-time ATT for cohort `g` at time `t` | Part II. Event time `e = t − g`. |
| `$D_{it}$` | Treatment indicator | Defined in ch. 1. |
| `$t^*$` | Last pre-period time (the cutoff) | e.g. `t^* = 1988` for Prop 99. |
| `$\alpha_i$`, `$\xi_t$` (or `$\gamma_t$`) | Unit / time fixed effects | `\alpha_i` = unit FE in Part II factor models. |
| `$\lambda_i$`, `$f_t$` | Factor loading / latent factor | `\lambda_i` = **loadings**. |
| `$w_j$`, `$w$` | Donor weights | Reserve `w` for donor-weight vectors. |
| `$W$` | A matrix | Spatial adjacency (ch. 7) — keep `W` for that only. |
| `$X_1$, $X_0$` | Predictor matrices | Treated / donor predictors (synthetic-control style). |

**Collision rule.** If your method genuinely needs one of `τ, λ, α, w, W` for
something else (a shrinkage scale, a penalty, an adjacency), **rename it** (e.g.
horseshoe scale `\sigma_\tau` or `\tau_{HS}`; nuclear-norm penalty `\eta` or
`\lambda_{MC}`) and add a one-line gloss where it first appears. The audit
(`audit/cross-cutting-notation-arc.md`) treats these collisions as P1 bugs.

Math delimiters: inline `$...$`; display `$$...$$`. Use `\text{}` for words
inside math, `\widehat{}` for hats on multi-symbol terms, `\approx` for reported
numbers, the lag operator `L` for time-series models.

---

## 4. Inline numbers — never hardcode

**Every numeric value in prose must come from live R**, via an inline call or a
small `#| echo: false` "stats" chunk that defines variables the prose then
references. This is the book's defence against prose-vs-output drift (the most
common bug class in `audit/AUDIT.md`).

Common patterns lifted from the chapters:

```markdown
The estimate is $\widehat{\tau} \approx `r sprintf("%.1f", its_lin_estimate)`$ packs.
... about `r round(naive_pre, 1)` packs/capita ...
... $p \approx `r sprintf("%.3f", nw_p)`$ ...
... a `r sprintf("%+.1f", its_arima_estimate)` (signed) estimate ...
... `r round(abs(its_lin_estimate - its_arima_estimate))` packs apart ...
```

Pattern: compute the quantity in a labelled chunk, then either reference the
object inline or precompute scalars in an `#| echo: false` chunk (e.g.
`naive-stats`, `arima-ljung-stats`) and reference those. Format with `sprintf`
(`"%.1f"`, `"%+.1f"`, `"%.2f"`, `"%.3f"`, `"%.0f"`) or `round()`.

---

## 5. Code-chunk conventions

- Global config (in `_quarto.yml`): `code-fold: true`, `code-tools: true`,
  `code-copy: hover`. So every chunk is folded by default.
- **Label every chunk**: `#| label: descriptive-kebab-name`. Tables use
  `#| label: tbl-<slug>`, figures `#| label: fig-<slug>`, exercises
  `#| label: ex-chNN-0K`.
- **`#| code-summary: "Code: <imperative description>."`** on every shown chunk —
  this is the fold label. Start with `Code: ` then an imperative phrase
  ("Code: Fit the pre-period linear trend and tabulate it with HAC-robust SEs.").
- **Warnings/messages policy.** The setup chunk may use `#| message: false` and
  `#| warning: false` to hide library-load noise only. **Do not** put
  `warning: false` on modelling chunks — a real failure must surface in the HTML.
  If a chunk warns, fix the cause. (Audit issue #1 was a silenced NULL model.)
- Use `#| echo: false` for helper "stats" chunks that only precompute inline
  scalars (no output worth showing).
- Captions: `#| tbl-cap: "..."` and `#| fig-cap: "..."`. Cross-reference with
  `@tbl-slug` / `@fig-slug`. **Never** pass `title=`/`subtitle=` to
  `gt_pretty()`/`ms_pretty()` — that bypasses Quarto numbering.
- Figure sizing: `#| fig-width: 8` and `#| fig-height: 5` are the defaults seen
  across chapters.
- Comment the R itself the way the chapters do: short comments explaining *why*,
  not what; match the surrounding density.

---

## 6. The setup chunk (use verbatim) and palette

Every chapter's first code chunk:

````markdown
```{r}
#| label: setup
#| message: false
#| warning: false
#| code-summary: "Code: Load packages, source table helpers, and set transparent ggplot theme."
library(tidyverse)
# ... method-specific packages ...
source("R/table_helpers.R")

knitr::opts_chunk$set(dev.args = list(bg = "transparent"))

theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.background  = element_rect(fill = "transparent", color = NA),
      panel.background = element_rect(fill = "transparent", color = NA),
      panel.grid.major = element_line(color = "#94a3b8", linewidth = 0.25),
      panel.grid.minor = element_line(color = "#94a3b8", linewidth = 0.15),
      text             = element_text(color = "#94a3b8"),
      axis.text        = element_text(color = "#94a3b8")
    )
)
```
````

The transparent background is what lets tables and plots read on both the
`cosmo` (light) and `darkly` (dark) themes. `R/table_helpers.R` exports
`gt_pretty()` (data frames/tibbles) and `ms_pretty()` (models; accepts `vcov=`
for HAC SEs) — both already transparent-aware.

**Colour palette** (consistent across every figure):

| Hex | Role |
|---|---|
| `#d97757` | Treated / observed series (orange); also the dotted cutoff `geom_vline`. |
| `#6a9bcc` | Counterfactual / synthetic / fitted series (blue); prediction-band ribbons. |
| `#94a3b8` | Grid lines and theme text (slate). |

Conventions: observed series `linewidth = 1.1`; counterfactual dashed
(`linetype = "dashed"`); cutoff `geom_vline(xintercept = t*+0.5, color =
"#d97757", linetype = "dotted", linewidth = 0.7)`; prediction ribbons
`alpha = 0.15` (outer/95%) and `0.25` (inner/80%); `labs(color = NULL)` and
`scale_color_manual(values = c(...))` to label series.

---

## 7. Data loading

Read the cached `.rds`, not a network source:

```r
prop99 <- read_rds("data/proposition99.rds") |> as_tibble()   # Part I
panel  <- read_rds("data/cs_minwage.rds")                      # Part II
```

State the dataset's shape in the **Dataset.** paragraph (rows × cols, treated
unit, cutoff, outcome units). Then build the chapter-specific subset/transform in
the data-load chunk. Pull illustrative data values **from the data live** (a
small `filter()` + table), never transcribe them into a static markdown table
(audit issue #5).

---

## 8. Citations and Further reading

- Cite inline with `[@bibkey]`. Entries live in `references.bib` (BibTeX); they
  render APA-7 via `apa.csl` on the References page automatically — nothing to
  wire per citation.
- Add only **verified** entries (real authors, year, venue, vol/issue/pages,
  URL/DOI). Match the existing entry shape: `@article{key, title = {...{Proper
  Nouns}...}, author = {Last, First and ...}, journal = {...}, volume = {...},
  number = {...}, pages = {...--...}, year = {...}, url = {...}}`. Key format is
  `firstauthorlastnameYYYYkeyword` (e.g. `callaway2021difference`).
- The `## Further reading` section is a bullet list, each item annotated with a
  **type tag**:

  ```markdown
  - @key — *textbook* — one-sentence description of what it is and why it's here.
  - @key — *tutorial* — ...
  - @key — *R package* — the package used in this chapter.
  - @key — *practical guide* — ...
  ```

  Type tags seen in the book: *textbook*, *tutorial*, *R package*,
  *practical guide*, *review*, *paper*. 3–5 items is typical.

---

## 9. Narrative arc and the Part seam

- **Opening callback.** The first paragraph names the previous chapter and what
  it did, then says what this chapter changes. ("Chapter 3 ran a textbook 2×2
  DiD on Proposition 99…").
- **Closing hand-off.** The discussion section ends by naming the next chapter
  and what it will add. For the *last* method chapter, point at the planned
  cross-method comparison chapter instead.
- **Part-seam callout.** A chapter that opens Part II carries this block right
  after Learning objectives:

  ```markdown
  ::: {.callout-note appearance="simple"}
  **Part II begins here.** Chapters 2–7 held the dataset fixed
  (Proposition 99) and varied the estimator. From this chapter forward
  we switch datasets too: a 1,745-county minimum-wage panel with
  *staggered* adoption replaces California's single-shock setting, and
  the toolkit shifts to estimators built for that structure.
  :::
  ```

  And the chapter *before* the seam gains a closing paragraph signposting the
  dataset/estimand change. If your new chapter moves the seam, fix both sides.

---

## 10. Key takeaways block

Three bolded groups, each a short bullet list. Bullets may use inline R numbers.

```markdown
## Key takeaways

**Methods:**

- One or two bullets on the estimator(s) and the R functions used.

**Lessons:**

- The conceptual morals, including the headline ATT (with inline numbers) and the
  cross-method comparison.

**Caveats:**

- The assumptions and failure modes; when not to trust the estimate.
```

---

## 11. Exercises

- 4–5 exercises, **graduated** from a direct re-fit to a stretch task. The last
  is usually titled "Exercise N (stretch): …".
- Common motifs: change the pre-period window; grid-search a tuning parameter;
  diagnose a deliberately mis-specified model; in-time placebo; placebo on an
  untreated unit.
- A short intro paragraph notes the exercises reuse the objects from the setup
  chunks ("nothing needs to be re-loaded").
- Each exercise is a `### Exercise N: Title` heading, a prompt, then a collapsible
  solution:

  ````markdown
  ::: {.callout-tip collapse="true"}
  ## Solution

  ```{r}
  #| label: ex-chNN-0K
  # solution code, reusing setup objects; tables via gt_pretty()
  ```

  One short paragraph interpreting the result and tying it back to the chapter's
  lesson.
  :::
  ````

---

## 12. Anti-bug checklist (from `audit/`)

Before declaring done, confirm:

1. **No hardcoded numbers** in prose — all via inline R (§4). The biggest source
   of past bugs.
2. **No silenced warnings** on modelling chunks (§5); the chapter renders without
   warnings leaking into HTML.
3. **Tables non-empty, figures not flat-zero** in the rendered output — open the
   rendered HTML / freeze JSON and check (audit #3, #4).
4. **Notation has no collisions** with the book-wide table (§3); colliding
   symbols renamed + glossed.
5. **Equation matches the code** — the math you display is the model you fit
   (audit #10).
6. **Data values verified live** against the actual `.rds` (audit #5).
7. **Opening callback + closing hand-off present** (§9); Part-seam callout if the
   chapter crosses I↔II.
8. **Windows/estimands stated** so the headline number is comparable to the
   chapters it is compared against (audit §3 window-inconsistency notes).
