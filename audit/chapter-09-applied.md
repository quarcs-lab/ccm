# Chapter 9 — Applied audit fixes

Target file edited: `09-matrix-completion-and-ife.qmd`.

All P1, P2, P3 items from `audit/chapter-09.md` have been applied,
together with the chapter-9 notation rename from
`audit/NOTATION-RENAME-PLAN.md` (MC nuclear-norm penalty
$\lambda \to \eta$ in prose; factor loading $\lambda_i$ kept).

## Changes by audit item

### P1 / M1 — CV-selected `r = 0` acknowledged honestly

Rewrote the entire **IFEct and MC compared** section. The new
opening paragraph states explicitly that CV selects $r = 0$,
explains that this collapses IFEct to two-way fixed effects on this
panel, and frames the contrast as "TWFE-style imputation vs.
nuclear-norm penalised imputation, not factor models vs. matrix
completion". The follow-up paragraph uses *in principle* hedging
and points out that agreement is meaningful precisely because MC's
relaxation of parallel trends is small here.

Also added the same finding to the Recap callout: the IFEct bullet
now says "Here CV picks $r = 0$, so IFEct collapses to two-way
fixed effects — a finding, not a bug."

### P1 / M2 — `min.T0` framing corrected

Rewrote the data-window paragraph to make clear that:

- `min.T0 = k` is the **user-set** sample-inclusion threshold
  (drops treated units with fewer than k pre-periods), not a
  quantity forced by the data;
- the actual rank constraint is $r < T_0$ per cohort (recovering
  $r$ factors on a treated unit needs at least $r + 1$
  pre-periods for that unit);
- keeping 2004 in the IFE sample on ch.8's 2003-2007 window would
  require `min.T0 = 1`, which caps that cohort's rank at zero.

The new paragraph also adds the line-precise back-reference
`08-staggered-did.qmd:99` to ch.8's window filter (closes audit
X2).

### P2 / M3 — `fect` formula vs ch.10 asymmetry acknowledged

Per the explicit constraint in the agent brief ("update prose
numbers OR keep the no-covariates call and document the
asymmetry — choose whichever requires less prose rewriting"), I
**kept** `lemp ~ D` and documented the asymmetry. Specifically:
the model equation in the intro now has the sentence

> "We write the model without observable covariates for
> simplicity, but `fect()` accepts a covariate matrix $X_{it}$ —
> e.g. `lemp ~ D + lpop + lavg_pay` — and chapter 10 exercises
> exactly that extension on the same panel."

Exercise 2 also asks the reader to add `lpop + lavg_pay` and
compare. Cached chunk outputs (`r.cv = 0`, `lambda.cv = 0.0007`)
are therefore preserved verbatim; no prose numbers needed
updating.

### P2 / M4 — numeric `tbl-att` chunk added

Inserted a new `tbl-att` chunk between `fig-ife-mc` and the
"IFEct and MC compared" section. It reads `out_ife$att.avg`,
`out_mc$att.avg`, and the corresponding `est.avg[1, "S.E."]`,
`CI.lower`, `CI.upper` slots — column names match the audit's
suggestion and the `fect` return-object structure. The "IFEct and
MC compared" section now cross-references `@tbl-att`.

### P2 / W1 — Exercises section added

Three exercises appended after `## Further reading`, matching the
recommendation in audit W1 and the symmetry with ch.8/ch.10:

1. Re-fit IFEct with `r = 0:3`, inspect MSPE, decide whether CV
   ever picks rank > 0.
2. Add `lpop + lavg_pay` covariates, compare against `@tbl-att`.
3. Tighten the window to `year >= 2002`, watch when the MC
   counterfactual visibly breaks.

### P2 / W2 — short-panel callout moved to front

The `callout-warning` block ("the rank/penalty selected by CV is
borderline-identifiable, $T = 5$ becomes numerically delicate, the
honest move is to not run them") is now the **first** element
under `## Estimating with FECT`, immediately before the rank-grid
discussion. The original placement (after the IFEct-vs-MC
comparison) has been removed. The callout title is now "**The
short-panel caveat (read first)**" and ends with "Everything in
the rest of this chapter should be read with this caveat in mind."

### P2 — `liu2024practical` cited at first mention of `fect`

Two cite-key additions:

- The IFEct bullet (formerly `[@bai2009panel; @xu2017generalized]`)
  is now `[@bai2009panel; @xu2017generalized; @liu2024practical]`
  (closes audit X4 — Liu et al. is the canonical `fect`
  reference).
- The first prose mention of the package ("Yiqing Xu's `fect`
  package") is now `` Yiqing Xu's `fect` [@liu2024practical]
  package ``.

### P2 — notation rename $\lambda \to \eta$ for the MC penalty

Applied per `NOTATION-RENAME-PLAN.md`. Every prose occurrence of
$\lambda$ that referred to the MC nuclear-norm weight is now
$\eta$. First-occurrence parenthetical added (line 186-189):

> "The penalty weight $\eta$ (written as `lambda` in the `fect`
> API and sometimes as $\lambda_{\mathrm{MC}}$ in the
> matrix-completion literature; we use $\eta$ in prose to avoid
> confusion with the unit-level loading vector $\lambda_i$ from
> IFEct) plays the role of $r$ and is again chosen by
> cross-validation."

Specific lines updated (per audit list):

- Line 25 — no rename needed (this is the model equation; the
  $\lambda_i$ here is the loading, which stays).
- Line ~159 — original `$\lambda$` for MC penalty → `$\eta$`,
  plus the new MC objective equation
  $\min \|\,Y_\mathrm{obs} - \widehat{Y(0)}\,\|_F^2 + \eta\,\|\widehat{Y(0)}\|_*$
  (closes audit M5).
- Line ~165 — `$\lambda \to \infty$` → `$\eta \to \infty$`.
- Line ~226 / `tbl-cv` caption — `$\lambda$` →
  `$\eta$ (returned by fect as lambda.cv)`. The displayed string
  in the table body is now `eta = 0.0007` (instead of
  `lambda = 0.0007`).
- Line ~301 / common-pitfall section — `choosing $\lambda$ too
  small` → `choosing $\eta$ too small`.
- Recap bullet — `nuclear-norm penalty $\lambda$` → `nuclear-norm
  penalty $\eta$`.

The R code (`out_mc$lambda.cv`) is **not** changed — it is a
`fect` field name. Only the displayed `sprintf` string and prose
math are renamed.

### P2 / M5 — MC nuclear-norm motivation strengthened

Added the explicit objective
$\min_{\widehat{Y(0)}} \|\,Y_\mathrm{obs} - \widehat{Y(0)}\,\|_F^2 + \eta\,\|\widehat{Y(0)}\|_*$
plus the two limiting regimes ($\eta \to 0$: interpolate;
$\eta \to \infty$: collapse to a constant) — per audit M5's
suggested sentence.

### P2 / C1, C2 — `panelview` chunk fixes

The `fig-panelview` chunk now:

- has `#| message: false` and `#| warning: false` (matches the two
  `fect` chunks and ch.10's `fig-panelview-status`);
- passes `display.all = TRUE` (matches `10-gsynth.qmd:146`);
- bumps `fig-height` from 5 to 6 to fit all 1,745 counties;
- caption now ends with "All 1,745 counties are shown." so the
  reader is not surprised by a denser figure.

### P2 / C4 — rank-grid justification

The paragraph above the two `fect` calls now states the rule
explicitly:

> "The identification rule is that recovering $r$ factors on a
> treated unit requires at least $r + 1$ pre-periods for that
> unit; with `min.T0 = 2` the *effective* ceiling is $r = 1$. We
> let CV search up to $r = 2$ only to verify it does not get
> fooled into climbing past the ceiling."

### P2 / X1 — within-chapter $\lambda$ collision resolved

Solved structurally by the $\lambda \to \eta$ rename. The first
occurrence of $\eta$ carries an explicit parenthetical naming the
collision and the literature alternatives, so the audit's
"light-touch glossary note" is incorporated directly into the
prose.

### P2 / X2 — ch.8 line-precise back-reference

The data-window paragraph now reads
`Chapter 8's 2003-2007 ``data2`` window (see ``08-staggered-did.qmd:99``)`,
matching the audit recommendation exactly.

### P2 / X3 — forward pointer to ch.10

End of the intro now closes with:

> "Chapter 10 then does the deep dive on one specific member of
> this family — generalized synthetic control via the `gsynth`
> package — using the same panel."

The same pointer is repeated more briefly at the end of `## Further
reading`.

### P2 / X4 — IFEct attribution corrected

Cite chain on the IFEct bullet is now
`[@bai2009panel; @xu2017generalized; @liu2024practical]`. Liu et
al. doing the heavy lifting (the `fect` algorithm itself) is now
explicitly attributed.

### P2 / W4 — `lemp` back-reference

The sentence introducing `lemp` is now "log teen employment; see
chapter 8 for full data provenance" so readers who entered ch.9
via search are pointed at ch.8 for the variable definition.

### P2 / W5 — Further reading additions

`## Further reading` now also mentions:

- `MCPanel` package (`<https://github.com/susanathey/MCPanel>`) as
  the canonical reference implementation of matrix completion;
- explicit forward pointer to ch.10.

### P3 / W3 — title reordered to body order

The YAML title is now `"Interactive Fixed Effects and Matrix
Completion"`. Body order has IFE first (lines 33, 144, 187, …),
which now matches.

## What was NOT changed (and why)

- **C3 (cache: true on fect chunks).** Audit flagged this as
  "minor convenience" with an explicit "either choice is
  defensible". I left it on freeze-only — matches the existing
  ch.9 style, smaller repo footprint, no `_cache/` to gitignore.
- **The covariate decision (M3).** Per the brief's explicit
  guidance to choose the option requiring less prose rewriting, I
  kept `lemp ~ D` and documented the asymmetry rather than
  rerunning the chapter with covariates. This preserves the freeze
  cache (`r.cv = 0`, `lambda.cv = 0.0007`) and the rendered HTML
  values.
- **R helper files.** Off-limits per Stage-1 instructions.
- **References.bib, _quarto.yml, install_packages.R.** Off-limits
  per Stage-1 instructions.

## Render impact

The freeze cache (`_freeze/09-matrix-completion-and-ife/…`) for
the two `fect` fits remains valid — the formula, data, and seeds
are unchanged. The two newly-added chunks (the `tbl-att` chunk;
the still-cached `tbl-cv` with its renamed `eta = %.4f` sprintf)
will execute on the next render, reading the cached `out_ife` and
`out_mc` objects. The renamed sprintf string in `tbl-cv` will
re-render its single output cell (the chunk identity changes), but
no `fect()` call needs to re-fit. The `fig-panelview` chunk now
has `display.all = TRUE` and a new fig-height; it will re-execute,
which is cheap.

The user can re-publish with the standard
`quarto render --to html` + `quarto publish gh-pages --no-prompt
--no-render` workflow documented in `CLAUDE.md`.
