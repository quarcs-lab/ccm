# Audit: Chapter 1 — Introduction (`01-introduction.qmd`)

## Summary

Chapter 1 is doing a lot of conceptual work — defining the potential-outcomes
vocabulary, the ATT estimand, a method-to-imputation lookup table, and a
decision tree that indexes the rest of the book — and most of that work is
done well. The Neyman-Rubin setup is clean, the "every method is a way to
impute $Y(0)$" framing is genuinely good, and the cached chunk outputs
agree with the prose claims about the naive estimate (Intercept = 98.98,
$\hat\tau_{\text{naive}} = -27.02$). But the chapter has one **factually
wrong didactic table** (the missing-data table on lines 38–47 quotes
numbers that don't match `data/proposition99.rds`), one **methodological
miscategorisation in the decision tree** (ch. 7 is placed under
"Frequentist + tidy code" when it is explicitly Bayesian), and one
**rendering bug** (a stray `theme_minimal()` on line 216 overrides the
transparent house theme set on lines 146–156, so `fig-raw-series` renders
with a white background that clashes with darkly mode and with the rest of
the book). There are also smaller issues: the SUTVA assumption is never
named, $\widehat{Y(0)}$ in the imputation table conflates conditional
expectation with point prediction, and the prose oversells how "wildly"
OLS SEs differ from HAC in the naive regression.

## Strengths

- The "causal inference as a missing-data problem" framing (lines 17–49)
  is the right mental model and is presented before any formulas. Holland
  (1986) is correctly invoked for the fundamental problem.
- The notation $Y_{it}(d)$, $D_{it}$, $\tau_{it}$, ATE, ATT (lines 23–75)
  is exactly the notation chs. 2–10 reuse. No drift was found between
  ch. 1 and ch. 2's opening (`02-interrupted-time-series.qmd:1–60`).
- The post-period window definition $t^\* = 1988$, $T_{\text{post}} = 12$
  (line 75) is precise and matches the actual data (1989–2000 inclusive).
- The "each method imputes $\widehat{Y(0)}$ differently" table
  (lines 83–97) is a strong pedagogical move and is repeated implicitly
  in later chapters. The math for each row is correct.
- The mermaid decision tree is structurally well-designed (one binary
  question per node) and the cost annotation under each leaf is exactly
  the right thing to surface for a methods book.
- Setup chunk is correct: seed is set (`set.seed(42)`, line 142), all
  three packages are pinned in `renv.lock`, transparent-background theme
  is configured for both light and dark sites.
- `tbl-prepost-means` uses the Quarto label/caption convention from
  CLAUDE.md; no stray `gt::tab_header()`.
- All seven citations (`@abadie2010synthetic`, `@bernal2017interrupted`,
  `@odissei2024causalpolicy`, `@callaway2021difference`, `@athey2021matrix`,
  `@xu2017generalized`, `@liu2024practical`) resolve — verified in
  `references.bib:15, 47, 67, 155, 236, 248, 260`.
- Numerical claims that *are* correct: pre-period mean ≈ 116
  (cached gt table: **116.21**, $n = 19$); post-period mean ≈ 60
  (cached gt table: **60.35**, $n = 12$); $\hat\tau_{\text{naive}} \approx
  -27$ (cached coeftest: **-27.0200**); $p < 0.001$ (cached:
  $p = 9.27 \times 10^{-4}$, hairline below the threshold).

## Methodology issues

### M1. `01-introduction.qmd:38–47` — the missing-data didactic table contains four to five wrong numbers

The table is presented as concrete observed data, but five of the eight
non-California values disagree with `data/proposition99.rds`. Live
extraction (`Rscript -e '...'` on the cached `.rds`):

| Cell shown in prose                          | Prose value | Actual value | Off by |
|---------------------------------------------|------------:|-------------:|------:|
| `California` 1995 `cigsale`                  | **64.4**    | **56.4**     | −8.0  |
| `Nevada` 1988 `cigsale`                      | **134.4**   | **142.0**    | +7.6  |
| `Nevada` 1995 `cigsale`                      | **113.0**   | **100.7**    | +12.3 |
| `Utah` 1988 `cigsale`                        | **64.7**    | **55.0**     | +9.7  |
| `Utah` 1995 `cigsale`                        | **55.0**    | **52.0**     | +3.0  |

The California rows for 1988, 1989, and 2000 (90.1, 82.4, 41.6) are
correct. This matters because a reader who reproduces the chapter by
running `prop99 |> filter(state == "Utah", year == 1988)` will see 55,
not 64.7, and lose trust in the rest of the chapter. It's also load-
bearing pedagogically: the table is the chapter's anchor illustration
of the fundamental problem.

**Fix.** Replace the table with the live values. Suggested rewrite of
lines 38–47:

```markdown
| State      | Year | $D_{it}$ | $Y_{it}(0)$ | $Y_{it}(1)$ | Observed |
|------------|-----:|---------:|------------:|------------:|---------:|
| California | 1988 | 0        | 90.1 ✓      | ?           | 90.1     |
| California | 1989 | 1        | **?**       | 82.4 ✓      | 82.4     |
| California | 1995 | 1        | **?**       | 56.4 ✓      | 56.4     |
| California | 2000 | 1        | **?**       | 41.6 ✓      | 41.6     |
| Nevada     | 1988 | 0        | 142.0 ✓     | —           | 142.0    |
| Nevada     | 1995 | 0        | 100.7 ✓     | —           | 100.7    |
| Utah       | 1988 | 0        | 55.0 ✓      | —           | 55.0     |
| Utah       | 1995 | 0        | 52.0 ✓      | —           | 52.0     |
```

Better still: build the table from a small inline R chunk so it can never
drift again:

```{r}
#| label: tbl-fundamental-problem
#| tbl-cap: "The fundamental problem of causal inference: per-capita
#|   cigarette sales for a few cells of the Proposition 99 panel."
prop99 |>
  filter(state %in% c("California", "Nevada", "Utah"),
         year %in% c(1988, 1989, 1995, 2000)) |>
  arrange(state, year) |>
  mutate(D_it = as.integer(state == "California" & year > 1988)) |>
  select(state, year, D_it, cigsale) |>
  gt_pretty(decimals = 1) |>
  cols_label(state = "State", year = "Year",
             D_it = "$D_{it}$", cigsale = "$Y_{it}$ (observed)")
```

### M2. `01-introduction.qmd:79–97` — the imputation table conflates point predictions with conditional expectations, and one cell is mis-specified

Two micro-issues with the "each method imputes $\widehat{Y(0)}$ table":

(a) Line 87 (naive): `$\widehat{Y_{1t}(0)} = \overline{Y}_{1, \text{pre}}$`
is fine as an *imputation rule*, but $\widehat{Y_{1t}(0)}$ depends on
$t$ on the LHS and not on the RHS — this is the *whole* problem with the
naive estimator. That's the point you're making, so consider adding
"(constant in $t$ — that is the problem)" inline so the reader notices
the dimension mismatch.

(b) Line 89 (basic DiD): the formula
`$\widehat{Y_{1t}(0)} = \overline{Y}_{1, \text{pre}} + \big(\overline{Y}_{0, \text{post}} - \overline{Y}_{0, \text{pre}}\big)$`
again has no $t$ on the right. As written, DiD imputes the *single*
post-period average $\overline{Y_1(0)}_{\text{post}}$, not a $t$-indexed
series. Either drop the $t$ subscript on the LHS or replace the RHS so
that it depends on $t$: $\widehat{Y_{1t}(0)} = Y_{1,t^*}(0) +
\big(Y_{0t} - Y_{0,t^*}\big)$ (parallel-trends form, control's deviation
from pre-period).

(c) Line 91 (BSTS): writing $\widehat{Y_{1t}(0)} = \mu_t + \beta^\top x_t$
without hatting either $\mu_t$ or $\beta$ is technically a population
expression. Use $\widehat{Y_{1t}(0)} = \hat\mu_t + \hat\beta^\top x_t$ for
consistency with the other rows.

**Fix.** Add a sentence right above the table (after line 81):
"In every row below, $\widehat{Y(0)}$ should be read as a *point
prediction* of the counterfactual conditional expectation $\mathbb{E}[Y(0)
\mid \text{covariates}]$; the column lists how each estimator builds
that prediction."

### M3. `01-introduction.qmd:111–125` — the mermaid decision tree mis-classifies ch. 7

Node `SCM` (line 121) is labelled "Classical Synthetic Control (ch. 4)
+ prediction intervals via scpi (ch. 6) + spatial spillovers (ch. 7)",
sitting under Q2's *Frequentist + tidy code* branch. But chapter 7 is
explicitly Bayesian — `07-bayesian-spatial-sc.qmd:2` titles it "Bayesian
Spatial Synthetic Control"; the chapter fits a horseshoe prior over
weights and an SAR MCMC sampler. It does not belong in the frequentist
branch.

Compounding this: ch. 6 (`scpi`) is frequentist (prediction intervals
via conformal/finite-sample methods), and ch. 4 is frequentist
(optimisation on the simplex). So the frequentist branch should contain
chs. 4 and 6 only; ch. 7 should either move to the Bayesian branch or
get its own leaf (since it relaxes SUTVA, which neither ch. 4/5/6 do).

**Fix.** Restructure Q2's downstream nodes. Smallest defensible change:

```
Q2 -->|Frequentist + tidy code| SCM["Classical Synthetic Control (ch. 4)<br/>
       + prediction intervals via scpi (ch. 6)<br/><br/>
       Cost: convex-combination of donors must match the<br/>
       treated pre-period"]
Q2 -->|Bayesian + uncertainty bands| Q3{"Do you suspect treatment<br/>
       spills over onto donor states<br/>(violating SUTVA)?"}
Q3 -->|No, SUTVA OK| CI["Structural Bayesian TS (ch. 5)<br/><br/>
       Cost: state-space prior;<br/>
       covariate-set choice affects the estimate"]
Q3 -->|Yes, spillovers likely| SPATIAL["Bayesian Spatial SCM (ch. 7)<br/><br/>
       Cost: horseshoe prior + SAR spatial term;<br/>
       neighbour matrix W must be plausible"]
```

This also reveals ch. 7's identifying value to the reader (SUTVA
relaxation), which the tree currently buries.

### M4. `01-introduction.qmd:17–77` — SUTVA is never named

The chapter introduces $Y_{it}(d)$, the fundamental problem, ITE, ATE,
and ATT, but never names the **stable unit treatment value assumption**
that licenses writing $Y_{it}(d)$ in the first place. Ch. 7 leans on
SUTVA explicitly (`07-bayesian-spatial-sc.qmd:7`) — and the whole point
of ch. 7 is to *relax* it. If SUTVA isn't named in ch. 1, ch. 7's
contribution lands without a foothold.

**Fix.** After the potential-outcomes definition (around line 30), add
one short paragraph:

> "Writing $Y_{it}(1)$ and $Y_{it}(0)$ as well-defined quantities
> implicitly assumes the **stable unit treatment value assumption
> (SUTVA)**: state $i$'s potential outcomes depend only on its own
> treatment status, not on what other states are doing. SUTVA is
> harmless for many policies; for tobacco taxes on the California
> border it is exactly the assumption that chapter 7 will relax."

### M5. `01-introduction.qmd:247` — "wildly overconfident" overstates the HAC vs OLS gap

The prose says "a classical OLS standard error would be wildly
overconfident here." Re-running the same model:

```
HAC (vcovHAC) SE on prepostPost = 5.30
NeweyWest    SE on prepostPost = 8.32
Classical OLS SE on prepostPost = 4.34
```

OLS underestimates the HAC SE by ~18% (5.30 / 4.34 - 1), not "wildly".
The NeweyWest SE *is* substantially larger (8.32 vs 4.34 ≈ 92% gap), so
"wildly" is defensible only against `NeweyWest`, not `vcovHAC`.

**Fix.** Either soften the adjective ("noticeably overconfident") or
use `NeweyWest` (a more common short-time-series default) and keep the
adjective. The latter is the better teaching choice — `NeweyWest` is what
most applied papers cite — but it would shift the reported $p$-value
from 0.0009 to 0.012, which is still significant at 5% and arguably more
honest about $T = 10$.

## Code & reproducibility issues

### C1. `01-introduction.qmd:216` — stray `theme_minimal()` clobbers the transparent house theme

The setup chunk on lines 146–156 sets a custom transparent-background
theme via `theme_set(...)`. The `fig-raw-series` ggplot on lines 202–216
then appends `+ theme_minimal()` as its last line, which **resets** the
plot's theme back to ggplot2's stock `theme_minimal` (white panel and
background, dark text). The cached output confirms this:

`_freeze/01-introduction/figure-html/fig-raw-series-1.png` renders with a
white panel and the default axis-text colour — visibly different from
every figure in chs. 2+ that respect the transparent theme.

In dark mode (`darkly`), the figure has a near-white slab in the middle
of an otherwise dark page. This is the only figure in ch. 1 and it's the
first figure the reader sees in the whole book.

**Fix.** Delete line 216 (`theme_minimal()`). The figure will then
inherit the theme set on lines 146–156.

### C2. `01-introduction.qmd:244` — `coeftest(..., vcov. = vcovHAC)` uses an unconventional default; consider `NeweyWest`

`sandwich::vcovHAC` defaults to Andrews (1991) bandwidth selection with a
quadratic-spectral kernel. `sandwich::NeweyWest` is the more familiar
default in economics teaching and gives a substantially different SE
here (8.32 vs 5.30 — see M5). Either is *correct*; the issue is that
the prose on line 247 then claims OLS is "wildly overconfident", which
is true only against NeweyWest. Match the SE estimator to the prose
adjective.

**Fix.** Either keep `vcovHAC` and soften the prose (per M5), or switch
to `NeweyWest`:

```r
coeftest(fit_prepost, vcov. = NeweyWest)
```

### C3. `01-introduction.qmd:235–245` — naive-prepost chunk lacks a `tbl-` label and caption

The chunk emits a `coeftest` text-mode table but is labelled
`naive-prepost` (no `tbl-` prefix and no `tbl-cap`). It therefore cannot
be cross-referenced and has no caption in the rendered HTML
(`_book/01-introduction.html:2144`). This is a CLAUDE.md convention
violation ("every chunk that emits a table uses `#| label: tbl-<slug>`
plus `#| tbl-cap`").

**Fix.** Promote the chunk to a captioned table using `ms_pretty`:

```{r}
#| label: tbl-naive-prepost
#| tbl-cap: "Naive pre/post OLS regression of California's per-capita
#|   cigarette sales on a Pre/Post indicator, 1984-1993 window. SEs are
#|   HAC-robust (Newey-West)."
fit_prepost <- lm(cigsale ~ prepost,
                  data = prop99_cali |> filter(year > 1983, year < 1994))
ms_pretty(list("California (1984-1993)" = fit_prepost),
          vcov = NeweyWest,
          coef_map = c("(Intercept)" = "Pre-period mean (Intercept)",
                       "prepostPost" = "Post - Pre (treatment effect)"))
```

This is exactly the case `ms_pretty` was built for and gives a
captioned, cross-referenceable, dark-mode-safe table — which the rest
of the book uses.

### C4. `01-introduction.qmd:133–157` — `dev.args` set inside the chapter chunk overrides any project-level setting

`knitr::opts_chunk$set(dev.args = list(bg = "transparent"))` is set
inside the chapter's setup chunk (line 144). It works, but it has to be
duplicated in every chapter (and **is**, in ch. 2's
`02-interrupted-time-series.qmd:30`). Worth lifting to a single
`R/setup_theme.R` that every chapter `source()`s, since `theme_set` is
also identical across chapters. Not blocking — but the duplication will
multiply as later chapters drift.

**Fix (optional, P3).** Move the theme + `dev.args` block into a helper
file in `R/` and `source("R/setup_theme.R")` from each chapter's setup.

## Cross-chapter consistency issues

### X1. `01-introduction.qmd:75` — the per-period subscript convention ($t^\* = 1988$) is set here but not consistently reused

Ch. 1 fixes the convention: $t^\* = 1988$ (last pre-period year), so the
post-period is $t > t^\*$. Ch. 2 then introduces `year0 = year - 1989`
(centred at the *first post-period year*) without flagging that this is
the same break. A footnote in ch. 1 anchoring "we will sometimes
recentre year so the policy lands at zero" would prevent the reader from
wondering which year is the cutoff.

**Fix.** After line 75 add: "Some chapters (chs. 2, 4) recentre the
year index so $t = 0$ at the *first* post-period year (1989). The break
itself is the same: pre-period is $\{t : t \le 1988\}$ throughout."

### X2. `01-introduction.qmd:69–77` — ATT formula uses unit index $i = 1$ for California, but the dataset's `state` column is a factor with no index 1

The ATT formula on line 73 writes "unit $i = 1$ denotes California".
That's notationally fine, but the chapter never instantiates this in
code; `prop99 |> filter(state == "California")` is used. Ch. 8 will need
a numeric unit index for the staggered-DiD estimators (Callaway-Sant'Anna
expects `idname`). A one-line "we'll refer to California as unit 1 in
notation, but in code we use `state == 'California'`" parenthetical
would close the loop.

**Fix (P3).** Add an inline parenthetical after the ATT formula:
"In code we identify California by name (`state == 'California'`); the
$i = 1$ index is purely notational here."

### X3. `01-introduction.qmd:121` — the decision-tree leaf for SCM names chs. 4, 6, 7 jointly, but the prose roadmap on lines 261–264 keeps them separate

The mermaid leaf bundles three chapters into one node. The roadmap then
restores their distinct identities. That's defensible *if* the leaf
text makes clear the three chapters share a common engine but layer on
different enhancements (uncertainty / spillovers). Currently the leaf
just lists them. Combined with M3 (ch. 7 doesn't actually belong here),
splitting the leaf is the right fix.

## Writing & structure issues

### W1. `01-introduction.qmd:7–15` — hook is good but buries the engagement question for one paragraph

The "How do you measure the causal effect of a policy when you cannot
randomise?" opening is a strong hook. Then paragraph 2 (lines 9, 11–15)
shifts to "this book is a tour" and the Prop 99 case study lands in
paragraph 3. The reader's attention dips between the hook and the
concrete number (116 → 60 packs). Consider promoting the 116-to-60
sentence one paragraph earlier so the policy stakes anchor before the
methodological tour.

**Fix.** Swap paragraphs 2 and 3 (i.e., move lines 11–15 in front of
line 9). The book-tour paragraph then reads as the response to the
Prop 99 puzzle, not as a meta-statement that precedes it.

### W2. `01-introduction.qmd:101–127` — section title "Which method when?" is too informal for a methods book

The rest of the chapter uses noun phrases ("Causal inference as a
missing-data problem", "Setup and data", "Roadmap of the book"). "Which
method when?" reads like a slide title.

**Fix.** Rename to **"A decision tree for choosing a method"** or
**"Choosing a method"**. The mermaid diagram and the discussion below
already deliver on the title; the heading just needs to match.

### W3. `01-introduction.qmd:189` — pre/post drop quoted as "48%" without showing the arithmetic

The chapter says "a within-state drop of roughly 56 packs, or 48% of
the pre-period mean". The number is right (115.99 → 60.40 ⇒ 47.9%) but
the reader has to take it on trust. For a teaching chapter, a one-line
in-prose calculation helps:

> "From 116.21 (1970–1988) to 60.35 (1989–2000) is a drop of 55.86
> packs, or 48.1% of the pre-period mean."

**Fix (P2).** Use the gt-rendered cached numbers (116.21, 60.35) and
include the arithmetic inline.

### W4. `01-introduction.qmd:251` — "Common pitfall" is one sentence; it deserves a fuller list

The chapter opens with a Common Pitfall section heading that fires only
once (line 251). For a chapter that is the *notation anchor* for the
whole book, a fuller list of pitfalls would pay off:

- Confusing pre-post difference with a causal effect (already there).
- Forgetting that the ATT is not the ATE.
- Reading $Y(0)$ for a treated unit as observable.
- Reading "we observe one potential outcome" as "we observe a treated
  outcome" (the never-treated states observe $Y(0)$).

**Fix (P2).** Expand the "Common pitfall" paragraph into a 3–4 bullet
"Common pitfalls when reading this book" callout. The other chapters
can then reference it.

### W5. `01-introduction.qmd:276–284` — "Further reading" mixes original sources with practitioner tutorials without flagging which is which

Six of seven citations are original methodology papers; one
(`@odissei2024causalpolicy`) is a workshop. The reader can't tell from
the list which is foundational vs which is a tutorial they should read
first.

**Fix (P3).** Annotate each bullet with a one-word category:

> - @abadie2010synthetic — *original method* — synthetic-control on Prop 99.
> - @bernal2017interrupted — *tutorial* — ITS for public-health interventions.
> - @odissei2024causalpolicy — *workshop* — the ODISSEI source for our running example.
> - @callaway2021difference — *original method* — staggered DiD (ch. 8).
> - @athey2021matrix — *original method* — matrix completion (ch. 9).
> - @xu2017generalized — *original method* — generalized SCM (ch. 10).
> - @liu2024practical — *practical guide* — counterfactual estimators for TSCS.

## Prioritized fix list

### P1 (must fix before re-publishing)

1. **M1** — Fix the five wrong numbers in the missing-data table on
   `01-introduction.qmd:38–47`. Either substitute correct values from
   `data/proposition99.rds` (90.1, 82.4, 56.4, 41.6 for California;
   142.0/100.7 for Nevada; 55.0/52.0 for Utah) or replace the static
   markdown table with a small R chunk that builds it from the data.
2. **C1** — Delete the stray `theme_minimal()` on
   `01-introduction.qmd:216`. The first figure of the book currently
   ignores the house theme.
3. **M3** — Rework the mermaid decision tree to stop placing ch. 7
   ("Bayesian Spatial SCM") under the *Frequentist* branch
   (`01-introduction.qmd:121`).

### P2 (should fix in the same pass)

4. **M2** — Tighten the imputation table on lines 79–97: add the "point
   prediction" preface, drop or fix the $t$ subscripts on lines 87 and
   89, and hat the BSTS parameters on line 91.
5. **M4** — Name SUTVA after the potential-outcomes definition (~line 30)
   so ch. 7's relaxation has somewhere to land.
6. **M5 / C2** — Reconcile the "wildly overconfident" prose on line 247
   with the actual HAC vs OLS gap. Recommended: switch
   `coeftest(..., vcov. = NeweyWest)` on line 244 and keep the
   adjective.
7. **C3** — Promote the `naive-prepost` chunk to `tbl-naive-prepost`
   with `ms_pretty(..., vcov = NeweyWest)` and a `tbl-cap`. (Matches
   CLAUDE.md convention and the rest of the book.)
8. **W2** — Rename section "Which method when?" to "Choosing a method".

### P3 (nice to have)

9. **X1** — Add a one-line note about the recentred year index used in
   chs. 2, 4 (around line 75).
10. **X2** — Inline parenthetical clarifying "unit $i = 1$" is notation,
    not code (around line 75).
11. **W1** — Reorder the first two paragraphs of the chapter so the
    Prop 99 puzzle lands before the book-tour paragraph.
12. **W3** — Inline the 116.21 → 60.35 arithmetic on line 189.
13. **W4** — Expand "Common pitfall" into a 3–4 bullet list on line 251.
14. **W5** — Annotate each "Further reading" bullet with a category.
15. **C4** — Lift the duplicated `theme_set` + `dev.args` setup into
    `R/setup_theme.R` so chs. 1, 2, 3, … don't have to repeat it.
