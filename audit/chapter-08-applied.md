# Chapter 8 — audit application report

Target: `/Users/carlosmendez/Documents/GitHub/ccm/08-staggered-did.qmd`
Stage-1 inputs honoured: `R/honest_did.R` already fixed (Stage 1B), bib already extended (`roth2023whats`), no edits outside the target chapter.

## Edits applied

All P1, P2, and P3 items from `audit/chapter-08.md` were applied. The chapter was not re-rendered (HTML render is the user's call); the freeze cache will be invalidated on next render because `R/honest_did.R` has changed since the last freeze.

### P1 — load-bearing

1. **HonestDiD prose rewritten to reflect corrected breakdown $\bar M \le 0.5$**
   - `fig-honest` caption (file line 379): "breakdown $\bar M$ — the value at which the CI first contains zero — is below 0.5, reflecting the visible pre-trend in cohort 2006."
   - Post-figure paragraph (file lines 392–409): rewritten to say the breakdown lies in $(0, 0.5]$, the on-impact effect is fragile to even a fraction of the cohort-2006 pre-trend, and to reframe HonestDiD as the bridge from CS point estimate to honest sensitivity — strengthening the pedagogical thrust.
   - Recap callout (file lines 418–425): the "breakdown $\bar M$ near 1.0 → strong robustness" line was replaced with "HonestDiD sensitivity is *fragile*: breakdown $\bar M$ below 0.5… the on-impact effect would not survive even half the observed pre-trend violation."

2. **Cohort-2006 pre-trend flagged** (file lines 189–197): new paragraph after `tbl-attgt` naming $ATT(2006, 2003) \approx -0.034$ (SE 0.013, $t \approx -2.7$), and using it as the motivation for the sensitivity analysis later. This is the bridge from "look at the cells" to "now we need a sensitivity tool" that the audit (M2) noted was missing.

3. **Overall-ATT prose aligned with `type = "group"` code** (file lines 205–213): rewritten to describe the cohort-then-cross-cohort aggregation (the @callaway2021difference recommended summary), explicitly contrasted with `type = "simple"`, with the cohort-2004-has-4-post-cells / cohort-2006-has-2 detail that makes the distinction concrete.

4. **Cohort-filter intro reconciled with the two-step filter** (file line 53): added "(after dropping a small late-2007 cohort; see Setup)" to the chapter intro so the prose at line 53 matches the code at lines 100–106.

### P2 — supporting

5. **Goodman-Bacon vs dCDH separated into two clauses** (file lines 27–35): the chapter now distinguishes Goodman-Bacon's *forbidden-comparison* 2×2 decomposition from dCDH's *strictly-negative-weights* result under heterogeneity, with both citations doing their own work.

6. **Forward bridge to Ch.9 added** (file lines 435–445): closing paragraph of the Recap callout names parallel trends as the assumption every method in this chapter leans on, writes the IFE counterfactual model, and points to matrix completion / IFEct in Ch.9 as the next move. Aligns with `09:5–13`'s backward reference.

7. **Sun-Abraham forward reference dropped from the intro** (file lines 40–47): the intro now mentions "two companion ideas" (DR DiD + Rambachan-Roth) and demotes Sun-Abraham to a one-line pointer with a `@roth2023whats` review citation. The chapter doesn't run `fixest::sunab()` so this prevents the dangling promise the audit flagged at X6. Sun-Abraham is kept in `## Further reading` as the right home for an unused method reference.

8. **Parallel-trends assumption statement inserted** (file lines 161–167): one-sentence statement of conditional parallel trends right after the $ATT(g,t)$ estimand, closing the gap between defining $Y(\infty)$ and using $G = 0$ to identify it.

9. **Smoothness vs relative-magnitudes contrast added** (file lines 347–355): two-sentence paragraph naming both restrictions, when each is appropriate, and explicitly justifying the relative-magnitudes choice via the visible cohort-2006 pre-trend.

10. **Notation through-line for $Y(\infty)$** (file lines 156–159): per `NOTATION-RENAME-PLAN.md`, added the "(equivalent to $Y_{it}(0)$ used in Part I — Callaway-Sant'Anna write $\infty$ to emphasise that the unit is *never* treated, not merely *not-yet* treated)" parenthetical at first occurrence.

11. **Lowercase $y_{it}$ → uppercase $Y_{it}$** (file line 22): the TWFE equation was the one place in the chapter using lowercase $y$. Now uppercase, matching the book-wide convention.

### P3 — polish

12. **Section title** (file line 5): "When Basic DiD breaks" → "When TWFE breaks under staggered adoption", more accurate to what the chapter argues.

13. **`set.seed(42)` comment** (file line 71): added the inline hygiene comment per audit C3 so readers don't mistake the chapter for bootstrap-based.

14. **Inline panel-size prose** (file lines 111–113): "8725 rows on 1745 counties" → "8725 rows = 1745 counties × 5 years", removing the parse ambiguity the audit flagged at S2.

15. **`roth2023whats` added to Further reading** (file lines 474–476): "is a recent review-style synthesis covering staggered DiD, event studies, sensitivity analysis, and the relationships between them."

16. **Exercise 1 extended with the bias caveat** (file lines 484–488): per audit M7, the prompt now asks readers to articulate what assumption about not-yet-treated counties they are now relying on, not just why the SE shrinks.

## Not applied (and why)

- **C4** (refactor the three `att_gt` calls into a `purrr::map`): audit explicitly labelled this a suggestion, not a defect; left as-is for copy-paste readability.
- **R/honest_did.R fix**: out of scope (already done in Stage 1B; explicit constraint in agent brief).

## Verification

- All `#| label:` conventions preserved byte-for-byte.
- `grep` confirms no remaining lowercase `y_{it}` in the chapter.
- Citation keys used in new prose (`roth2023whats`, `callaway2021difference`, `goodmanbacon2021difference`, `dechaisemartin2020twoway`, `sun2021estimating`, `rambachan2023more`, `callaway2022handbook`) all present in `references.bib` per Stage-1 report.
- Numerical claims in prose continue to match cached chunk outputs *except* for the HonestDiD numbers, whose new (corrected) values will materialise on the next render — exactly as the agent brief specified.

## Recommended next step (user's call)

```bash
quarto render --to html 08-staggered-did.qmd
quarto publish gh-pages --no-prompt --no-render
```

The first command will re-execute the HonestDiD chunk against the fixed helper, producing the new $\bar M \le 0.5$ breakdown numbers that the rewritten prose now anticipates.
