# Stage 1A — references.bib audit fixes — DONE

Scope: `references.bib` only. No other files touched.

## (a) Keys added (7 new entries)

Note: the task brief listed 8 keys to add, but `liu2024practical` already existed in `references.bib` (lines 260–270 of the pre-edit file). So 7 new entries were appended; final count is 27 existing + 7 new = **34 entries** (verified by `grep -E '^@[a-z]+\{[a-z]' references.bib | wc -l`).

- `cardkrueger1994minimum` — Card & Krueger (1994), *American Economic Review* 84(4), 772–793.
- `bertrand2004how` — Bertrand, Duflo & Mullainathan (2004), *QJE* 119(1), 249–275, doi:10.1162/003355304772839588.
- `scott2014predicting` — Scott & Varian (2014), *IJMMNO* 5(1–2), 4–23, doi:10.1504/IJMMNO.2014.059942.
- `wagner2002segmented` — Wagner, Soumerai, Zhang & Ross-Degnan (2002), *J. Clinical Pharmacy and Therapeutics* 27(4), 299–309, doi:10.1046/j.1365-2710.2002.00430.x.
- `vanbuuren2011mice` — van Buuren & Groothuis-Oudshoorn (2011), *JSS* 45(3), 1–67, doi:10.18637/jss.v045.i03.
- `george1997approaches` — George & McCulloch (1997), *Statistica Sinica* 7(2), 339–373.
- `roth2023whats` — Roth, Sant'Anna, Bilinski & Poe (2023), *J. Econometrics* 235(2), 2218–2244, doi:10.1016/j.jeconom.2023.03.008.

(Eighth task-brief key `liu2024practical` was already present — no action.)

## (b) Entries fixed

1. **`callaway2022handbook`** — converted from `@article` to `@incollection`. Added `booktitle = {Handbook of Labor, Human Resources and Population Economics}`, `editor = {Zimmermann, Klaus F.}`, `address = {Cham}`, `pages = {1--61}`, `doi = {10.1007/978-3-319-57365-6_352-1}`, `note = {Handbook chapter}`. Kept `publisher = {Springer}`. The DOI/URL point to the live Springer reference work entry; pages are the first-online preprint range (the entry is a live reference work entry that is updated rather than paginated in a print volume).
2. **`causalimpact-pkg`** — added `year = {2014}` (initial Google open-source release year of CausalImpact).
3. **`brodersen-causalimpact-talk`** — added `year = {2015}` (YouTube talk on the package, ~1 year after release).
4. **`fpp3-pkg`** — added `year = {2020}` (initial CRAN release of the `fpp3` companion package to the 3rd ed. textbook). Also brace-protected `fpp3` in the title.
5. **`dunford2024tidysynth`** — title field: `tidysynth` → `{tidysynth}` (prevents APA CSL sentence-case mangling to "Tidysynth").
6. **`cattaneo2025scpi`** — title field: `scpi` → `{scpi}` (same fix).

Orphan entries (`abadie2003economic`, `bai2003inferential`, `fpp3-pkg`): retained per task instructions; they may be cited by later stages.

## (c) Placeholders / fields where canonical metadata was not confirmable from web sources

- **`callaway2022handbook` pages.** The Springer reference work entry is a "live" online entry (DOI `10.1007/978-3-319-57365-6_352-1` — the `-1` suffix indicates the versioned live entry); it does not have stable print pagination. Used `pages = {1--61}` matching the pre-print page count from the arXiv submission (arXiv:2203.15646). If a stable Springer print-version pagination becomes available, this should be updated.
- **`causalimpact-pkg` year.** The R package has no single canonical release year (it has been continuously maintained on Google's repo since 2014). Used 2014 per task instructions. Could plausibly be updated to a later CRAN-snapshot year if the chapter prefers.
- **`brodersen-causalimpact-talk` year.** The YouTube talk page is the canonical source; the public talk on the package was given in 2014 by Brodersen at Google but the recording's most-cited posting is from 2015. Used 2015 per task instructions; either 2014 or 2015 is defensible.
- **`fpp3-pkg` year.** Used 2020 per task instructions (initial CRAN release of the `fpp3` data package companion to the 3rd-ed. textbook).
- **`scott2014predicting` issue.** The Inderscience page (paywalled / blocked by WebFetch) and Google Research summary list issue as "5(1/2)" (combined 1–2 double issue). Used `number = {1--2}` for APA-friendly rendering.
- **`george1997approaches`.** JSTOR page returned 403 to WebFetch but the journal-issue-page metadata is widely cited as *Statistica Sinica* 7(2), 339–373. Issue `2` is what every secondary source reports; flagged here as derived from the bibliographic record rather than direct publisher confirmation.

## Verification

```
$ grep -E '^@[a-z]+\{[a-z]' references.bib | wc -l
34

$ grep -cE '^\s*year\s*=' references.bib
34          # every entry has a year line

$ grep -o '{' references.bib | wc -l   # 327
$ grep -o '}' references.bib | wc -l   # 327   (braces balance)
```

All 34 entries have a `year` field. Braces balance. No other files modified.
