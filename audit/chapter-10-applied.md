# Chapter 10 — Applied audit fixes

Target file edited: `10-gsynth.qmd`.

All P1, P2, and P3 items from `audit/chapter-10.md` have been
applied, together with the chapter-10 notation rename from
`audit/NOTATION-RENAME-PLAN.md` (implicit-weights matrix called
$\Omega$ in prose, R variable name kept as `W` / `wgt.implied`).

## Changes by audit item

### P1 / C1 — Implicit-weights table no longer renders empty

**Verified the cause in a live R session before editing.** In
`gsynth` 1.4.0 (a thin shim over `fect::fect`), `out$wgt.implied`
has `NULL` row and column names, so the existing
`treated_ids <- colnames(W)` and `control_ids <- rownames(W)`
were `NULL` and the whole `map_dfr()` collapsed silently into an
empty tibble.

Probed the fit object directly to find the correct ID accessors:
`out$id` is the full county-id vector (length 1745), and
`out$tr` / `out$co` are integer indices into it (length 328 and
1417 respectively). The audit suggested `out$id.tr` /
`out$id.co`, but those don't exist on the fit — verified by
`names(out)` not containing them. The correct expression is
`out$id[out$tr]` and `out$id[out$co]`.

Implemented:

```r
W <- out$wgt.implied
rownames(W) <- as.character(out$id[out$co])   # never-treated county ids
colnames(W) <- as.character(out$id[out$tr])   # treated county ids
treated_ids <- colnames(W)
control_ids <- rownames(W)
```

End-to-end test in R confirms the downstream `top_treated` is
populated (5 county FIPS codes), the `map_dfr()` produces a 25-row
tibble of (treated, control, weight) triples, and the inline
`r length(control_ids)` evaluates to **1417** rather than the
previously-broken **0**.

### P1 / C2 — Cumulative-ATT table & figure no longer empty

**Verified the cause in the same R session.** `rownames(out$est.att)`
is `c("-4", "-3", ..., "4")` (event time), not calendar years. The
existing `filter(year >= 2004)` against `as.integer(rownames(...))`
left zero rows.

Rewrote the chunk to use event-time semantics throughout: the column
is renamed `event_time`, the filter becomes `event_time >= 0`, the
table columns are `Event time` and `ATT (period)`, and the figure
x-axis is `Event time (years since treatment)`. The fig-cap and
tbl-cap were rewritten to match. End-to-end test confirms the
cumulative table now has 5 post-treatment rows (event time 0–4),
the `Cumulative ATT` deepens from ≈ 0.0004 at event time 0 to
≈ −0.512 at event time 4 — consistent with the gap plot — and the
figure receives a non-empty data layer.

### P2 / M2 — "IC-selected rank" relabelled

Replaced "IC-selected rank" with **"IC-recommended rank (with
$r \ge 1$ floor)"** at every occurrence (in the selection-prose
paragraph after the IC table and in the Reconciliation callout).
Added an explicit "By the strict IC criterion the data prefer the
no-factor model; we showcase $r = 1$ because the factor mechanism
is the chapter's subject. In a real application you would report
the $r = 0$ estimate alongside or instead" sentence so the
pedagogical override is announced as such.

### P2 / M5 — Factors-plot caption acknowledges two curves

Rewrote `fig-gsynth-factors` caption to describe both curves
visible in the frozen PNG: the orange curve is the latent factor
$f_t$ at $r^* = 1$; the grey curve labelled "0" is the time fixed
effect $\xi_t$ that `force = "two-way"` adds alongside the
factor.

### P2 / C3 — Gap and counterfactual x-axis relabelled to event time

`plot.gsynth(type = "gap")` and `plot.gsynth(type = "counterfactual")`
both show event-time ticks (−4 to +4) even when `xlab = "Year"` is
passed. Switched the `xlab` argument and fig-cap text to
**"Event time (years since treatment)"** in both chunks, which
now matches the cumulative figure and the loadings/factors panels.

### P2 / X1 — Doubly-robust DiD attributed to ch.8, not ch.9

Two prose references corrected:

- Reconciliation callout: "within sampling error of the
  chapter-**9** staggered-DiD estimates" → "within sampling error
  of the chapter-**8** staggered-DiD estimates".
- Common pitfall section: "such as the chapter-**9** doubly-robust
  DiD" → "such as the chapter-**8** doubly-robust DiD".

Exercise 3's "chapter 8 ($-0.065$)" was already correct and was
left alone.

### P2 — Notation rename ($\Omega$ for implicit weights)

Per `NOTATION-RENAME-PLAN.md`, the implicit-weights matrix is now
called $\Omega$ (Greek capital Omega) in prose, to avoid colliding
with chapter 7's spatial-adjacency $W$. Applied at:

- First mention in the new "generalised SC" paragraph: "The
  implicit-weights matrix $\Omega$ we examine below (returned by
  gsynth as `wgt.implied`)".
- §"Implied donor weights" opening: parenthetical "(the
  **implicit-weights matrix $\Omega$** in prose; we use the Greek
  capital Omega to avoid colliding with chapter 7's spatial-adjacency
  $W$)".
- `tbl-implied-weights` caption: "Each cell is an entry of the
  implicit-weights matrix $\Omega$".

The R variable name remains `W` / `wgt.implied` (matches gsynth's
API) — only prose math notation changes, per the rename plan.

### P2 — Forthcoming cross-method comparison chapter announced

Added a closing paragraph after the Reconciliation callout (before
"Common pitfall") that flags the planned chapter 11 without drafting
it:

> This chapter closes the book's drafted methodological arc. The
> **cross-method comparison chapter (Chapter 11, forthcoming)**
> will tabulate the ATT point estimates from chapters 2–10 side by
> side on the two shared datasets (Proposition 99 and the
> Callaway-Sant'Anna minimum-wage panel) and propose a decision
> flowchart by data structure …

This both honours the "don't draft ch.11" constraint and points the
reader to where the cross-method synthesis will eventually live.

### P3 / M1 — Two-step IFE projection spelled out

Added a 4-line numbered list after the IFE equation that explicitly
describes (1) the SVD/OLS alternation on never-treated and
(2) the projection regression that recovers $\hat\lambda_i$ for
each treated unit. This makes the "needs enough pre-treatment
depth" line in the Reconciliation callout (line ~466) connect to
a concrete mechanism: the projection regression at step 2 needs
enough pre-periods per treated unit.

### P3 / M3 — `cv.nobs` arithmetic now internally consistent

Rewrote the CV-off rationale paragraph. The old text said "8" using
legacy gsynth defaults; the new text names the constraint as
`min.T0 + cv.nobs` without pinning a specific number that would
contradict the chunk's `min.T0 = 3`.

### P3 / M4 — gsynth-as-generalisation-of-SC link made explicit

New paragraph after the IFE equation states the SC inheritance in
one go: classical SC is the rank-1, single-treated-unit,
simplex-constrained limit of gsynth; the implicit-weight matrix is
the literal analogue of the SC weight vector $w$. This is the
bridge a reader who came from Part I will need to make the
§"Implied donor weights" section legible.

### P3 / M5 — Loadings-plot caption names the diagnostic panel

Added the parenthetical "the bottom-left scatter — the panel that
crosses the FE loading on the x-axis with the Factor 1 loading on
the y-axis — is the diagnostic one" so a reader who sees the 2×2
panel matrix knows which sub-panel the caption is describing.

### P3 / C4 — Inference-keyword translation documented

Added an in-line code comment on the `inference = "nonparametric"`
line of the fit-grid chunk noting that gsynth 1.4.0 routes this to
fect's `"bootstrap"`. Also added a sentence to "Further reading"
explaining the same point in prose.

### P3 / C6 — Seed reproducibility flagged in Exercise 4

Added a parenthetical to Exercise 4: "The `seed = 42` argument
passed to `gsynth()` makes the bootstrap CIs exactly reproducible
across `nboots` levels, so your numbers should match an
independent re-run."

### P3 / W1 — Section renamed `## Recap` → `## Reconciliation`

The callout's internal "The estimators reconciled." title now
flows from the section heading rather than restating it.

### P3 / W2 + X3 — Further-reading section expanded

Added two pointers per the audit recommendations:

- The standalone `gsynth` package page (<https://yiqingxu.org/packages/gsynth/>),
  with a one-line note that gsynth 1.4.0 is a shim over fect and
  that the `nonparametric` keyword maps to fect's `bootstrap`.
- An explicit back-pointer to chapter 4: "Readers coming from
  Part I should re-read chapter 4 (classical SC) with the gsynth
  loading equation $\widehat{Y_{it}(0)} = \hat\alpha_i + \hat\xi_t + \hat\lambda_i'\hat f_t + X_{it}'\hat\beta$
  in mind …". This closes the SC-inheritance loop the chapter
  opened in the methodology section.

### P3 / X5 — Bai-Ng citation rendered properly

The IC table's `tbl-cap` used the parenthetical "(Bai 2003)";
changed it to `[@bai2003inferential]` so the entry (already in
`references.bib`) renders on the References page.

## Not applied (out of scope)

- **W3 (Key concepts at a glance section).** The audit explicitly
  flagged this as "No action needed" — the recent commit removed
  the same section from ch.7 and the book is dropping the pattern.
- **W4 (Exercises pitch).** The audit said "No change needed";
  Exercise 4 received only the C6 seed-reproducibility addition.
- **W5 (Common-pitfall vs Reconciliation overlap).** Left as-is —
  the audit framed this as optional repetition that aids retention.
- **C5 (stray `10-gsynth_files/` and `10-gsynth_cache/`).** Repo
  hygiene outside the chapter source; the audit confirmed
  `.gitignore` already covers it and Stage 1's notes show these
  directories have already been deleted locally.
- **X2 (Part-I family table).** Holding for the planned chapter 11;
  the closing paragraph now announces that chapter explicitly, so
  the cross-Part-I table is the obvious thing for ch.11 to lead
  with rather than duplicate here.
- **Alternative M2 fix (b) — running a real CV-selected rank on a
  pre-period-restricted panel.** The audit recommended option (a)
  (honest relabel), which I implemented; option (b) would have
  required re-running the expensive fit grid and rewriting the
  reconciliation numbers.

## Verification

- Ran the new implicit-weights code path end-to-end in R against
  a fresh `gsynth()` fit — `top_treated` has 5 county FIPS codes,
  weights table populates with 25 rows.
- Ran the new cumulative-ATT code path end-to-end in R — table has
  5 rows (event time 0–4), `Cumulative ATT` deepens from 0.0004
  to −0.512.
- Did **not** run `quarto render --to html` (will be done at session
  end per the publishing workflow). The freeze cache for chapter
  10 will be invalidated by the chunk-source changes to
  `tbl-implied-weights`, `tbl-cumulative`, and `fig-cumulative`;
  other chunks should keep their cached output.
