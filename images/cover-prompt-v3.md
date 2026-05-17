# Cover-image prompt for *Comparative Causal Metrics* — **v3 (Nano Banana Pro, refined navy/amber)**

This is the third prompt in the set, designed for **Gemini 3 Pro Image (Nano Banana Pro / "nano banana 2")**. It refines the v1 direction — deep navy + warm amber, painterly diverging time-series curves — rather than departing from it.

- **v1** ([`cover1-prompt.md`](cover1-prompt.md)) — original navy/amber draft. Produced the current `cover.jpg`.
- **v2** ([`cover-prompt-v2.md`](cover-prompt-v2.md)) — cool-grey glassmorphic alternative. Not adopted.
- **v3 (this file)** — same navy/amber spirit as v1, refined for Nano Banana Pro: more pronounced treated-vs-counterfactual divergence so the causal effect reads at thumbnail size, stronger typography presence, richer cinematic atmosphere (subtle grain, particle drift, depth-of-field), and a thin glowing vertical intervention line that quietly nods to ITS / RDD as well as synthetic control.

The chosen generation should be saved as `images/cover.jpg` (overwriting the current file); no other repo changes are required — the cover is already wired up at `_quarto.yml:22` and displayed in the preface via `index.qmd:3`.

---

## Primary prompt

> An elegant editorial book-cover illustration, vertical 2:3 portrait composition at 1600×2400 px. A deep, atmospheric night-navy background flowing from `#0B1A2B` at the top to `#13243C` at the bottom, enriched with very subtle film grain and a faint, barely perceptible horizontal coordinate-plane texture — atmospheric, scholarly, never schematic. Across the lower two-thirds of the canvas, two painterly hand-drawn curves travel from left to right and meet a thin, softly glowing vertical "intervention" line that bisects the composition near its midpoint. Through the pre-intervention region the two curves track each other almost exactly, like a confident ink study; at the intervention line they cleanly split, opening a generous and unmistakable widening gap that reads as the estimated causal effect even at thumbnail size. The upper curve is a luminous off-white "counterfactual" trajectory that continues its smooth ascending trend past the cutoff. The lower curve is a warm amber-gold "treatment" trajectory (around `#E8A23B`) that bends decisively downward after the cutoff. Both curves feel like layered translucent glass with internal light — soft halos, slight chromatic edges, gentle depth-of-field blur at their farthest ends, no neon, no laser-beam quality. A soft indigo bloom surrounds the divergence area; a sparse drift of low-opacity pale-blue bokeh particles gives the canvas atmosphere without warming the palette. No axes, no tick marks, no numbers, no legend, no annotations, no chart frame — the composition evokes a synthetic-control plot rather than reproducing one. The upper third of the canvas is reserved as a calm typography zone with generous negative space. Render the following text exactly as written, with crisp kerned letterforms and perfect spelling: the title **Comparative Causal Metrics** as the dominant element in a refined modern serif typeface reminiscent of Source Serif, Tiempos, or Canela, set in title case, in luminous off-white; immediately below it the subtitle **An Introduction to Regional Impact Evaluation** in a humanist sans-serif resembling Inter, in a softer warm-grey at a noticeably smaller size; and at the very bottom of the cover the author name **Carlos Mendez** in small caps, in the same warm-grey, at a modest weight that does not compete with the title. Treat typography as a primary subject — equal in importance to the data-art motif. Overall mood: contemporary, premium, scholarly, quietly cinematic — the visual energy of a serious university-press monograph or a Pelican / Princeton-style data-science publication, never a generic AI illustration.

## Negative prompt / things to avoid

- **No branching ribbons, no radial diagrams, no spider webs, no node-and-edge graph networks, no mind-map layouts, no central-hub-with-spokes compositions.** Hard exclusions — past attempts that drifted into this territory were rejected.
- No map icons, city skylines, mountains, region thumbnails, or any miniature scenes inside the composition.
- No chart axes, tick marks, gridlines that read as a real plot, numeric labels, legends, chart frames, or anything that looks like a literally-plotted scientific figure. The curves should *evoke* a synthetic-control plot, not reproduce one.
- No cigarettes, smoke, ashtrays, California silhouettes, flags, or any literal Proposition 99 / public-health imagery.
- No human figures, faces, hands, or silhouettes.
- No neon tubes, no laser beams, no lens flares, no sci-fi HUD overlays, no holographic UI panels.
- No watermarks, signatures, "bestseller" badges, mock award seals, sticker shapes, dog-eared corners, page-curl effects.
- No misspellings, no paraphrased title or subtitle, no invented taglines, no embedded labels on the curves (no words like "TREATED" / "COUNTERFACTUAL" / "INTERVENTION" written inside the artwork). If the model cannot render the typography cleanly, leave the typography zone empty rather than producing garbled letters.
- No stock-illustration tropes: no glowing lightbulbs, no jigsaw pieces, no clip-art arrows, no generic neural-network motifs.

## Iteration tips

Re-run the same primary prompt; if the result needs a nudge, append **one** of these sentences:

- **Text is garbled or misspelled** → *"Render the text with crisp, perfectly kerned letterforms; treat the typography as the primary subject and prioritize legibility over decorative flourish."*
- **Divergence is too subtle / hard to read at thumbnail size** → *"Open the gap between the off-white counterfactual and the amber treatment curve much more decisively after the intervention line — the widening separation must be the first thing the eye notices, unmistakable even when the cover is shown at 200 px wide."*
- **Curves look too 'neon' / video-game** → *"Render the curves as translucent layered glass with soft internal light and subtle chromatic edges, not as glowing neon tubes; reduce saturation slightly and lean into a quieter, more cinematic glow."*
- **Composition reads too much as a chart** → *"The two curves should feel hand-drawn and painterly with slight ink-bleed and subtle imperfection, not mechanically plotted; remove anything that looks like a chart frame, axis, or grid; the divergence should feel like a moment in a painting, not a data point."*
- **Curves don't read as parallel-then-divergent** → *"Both curves must track each other almost exactly through the left two-thirds of the canvas, then split cleanly at the vertical intervention line so the widening gap on the right reads unmistakably."*
- **Typography sits too small or feels secondary** → *"Scale the title up so it commands the upper third of the canvas; the title is the hero, the data-art motif is its quiet companion below. Subtitle and author remain noticeably smaller and softer."*
- **Palette has drifted** → *"Hold strictly to this palette: background gradient `#0B1A2B` → `#13243C`, counterfactual curve in luminous off-white, treatment curve in warm amber `#E8A23B`, intervention line a thin soft indigo glow, title in off-white, subtitle and author in warm pale grey. No other hues."*
- **Cover feels flat or sterile** → *"Add a sparse drift of soft pale-blue bokeh particles through the navy space — small, out of focus, very low opacity — and gentle film grain across the whole canvas, just enough to give the cover cinematic atmosphere without busying the composition."*
- **Intervention line is too prominent / too dim** → *"The vertical intervention line should be a thin, softly luminous thread — bright enough to read as a deliberate marker dividing pre and post, but never a strong vertical bar that competes with the curves."*

## After you pick a generation

1. Export at 1600×2400 (or larger) as a JPG.
2. Save it to this directory, **overwriting** the existing file:
   ```
   images/cover.jpg
   ```
3. Re-render and publish using the project's standard flow (see `CLAUDE.md`):
   ```bash
   quarto render --to html
   quarto publish gh-pages --no-prompt --no-render
   ```

The cover is wired up at `_quarto.yml:22` and displayed in the preface via `index.qmd:3`, so no source edits are needed — dropping in the new JPG is enough.

---

### Why this palette and motif

The navy/amber palette continues the v1 direction the user already validated in the current `cover.jpg` — a quietly cinematic, university-press feel rather than a bright web-app aesthetic. The single diverging-curves motif is the most iconic visual in causal inference and remains legible at any size; it resonates with **every** chapter in the book (ITS, RDD-in-time, DiD, synthetic control, BSTS) even though it most literally evokes the synthetic-control plot. The thin vertical intervention line is a deliberate second beat: it marks the temporal cutoff that ITS, BSTS, and RDD-in-time all share, so the cover quietly nods to the full methodological suite without slipping into a busy multi-motif collage.
