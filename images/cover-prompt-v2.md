# Cover-image prompt for *Comparative Causal Metrics* — **v2 (synthetic-control curves, cool-grey editorial)**

This is the alternative to [`cover-prompt.md`](cover-prompt.md). Both files coexist so you can A/B them in **Gemini Nano Banana 2**.

- **v1** — data-art illustration, deep-navy + warm-amber, two diverging time-series lines.
- **v2 (this file)** — softly luminous, glassmorphic *synthetic-control curves* (treated vs synthetic counterfactual diverging at an intervention) on a soft cool-grey editorial background, anchored in the book's light-theme palette (CausalBlue `#2563eb`, MethodPurple `#7c3aed`, EvidenceGreen `#059669`).

The chosen generation should be saved as `images/cover.jpg` (overwriting the current file); no other repo changes are required.

---

## Primary prompt

> A softly luminous, glassmorphic editorial book-cover illustration, vertical 2:3 portrait composition (~1600×2400 px). Background is a calm cool-grey gradient flowing from `#E5E7EB` near the top down to `#CBD5E1` at the bottom, with a very subtle paper-grain texture across the whole canvas — daylit, editorial, university-press in feel, never sterile. Centered in the lower two-thirds of the canvas, the cover depicts the visual essence of the synthetic-control method: two near-parallel luminous curves flowing from left to right, tracking each other closely through the pre-intervention period, then peeling apart at a thin vertical intervention line that bisects the composition near its midpoint. The upper curve is the "treated" trajectory, rendered as a confident luminous ribbon in CausalBlue `#2563eb` with a soft halo of light around it. The lower curve is the "synthetic counterfactual," rendered as a slightly more translucent ribbon in EvidenceGreen `#059669`, faithfully shadowing the treated curve before the intervention and then continuing its smooth pre-intervention trend past the cutoff — so the widening gap between the two ribbons after the intervention reads as the estimated causal effect. The vertical intervention line is a thin, softly glowing thread in MethodPurple `#7c3aed`, just bright enough to read as a deliberate marker without dominating. Both curves should feel painterly and hand-drawn — like layered translucent glass with internal light, gentle gaussian glow, faint chromatic edges, and slight depth-of-field blur at their farthest ends. No axes, no tick marks, no numeric labels, no legend, no chart frame — the composition reads as a piece of art that *evokes* the canonical synthetic-control plot rather than reproducing one. A soft, almost imperceptible bloom surrounds the divergence area, drawing the eye to the gap. Sparse, low-opacity bokeh particles drift through the cool-grey space to give the cover atmosphere. The upper third of the canvas is reserved as a calm typography zone with generous negative space. Render the following text exactly as written, with crisp kerned letterforms and perfect spelling: the title **Comparative Causal Metrics** as the dominant element in a refined modern serif typeface reminiscent of Source Serif, Tiempos, or Canela, set in title case, in deep slate `#0F172A`; immediately below it the subtitle **An Introduction to Regional Impact Evaluation** in a humanist sans-serif resembling Inter, in medium slate `#475569`, at a noticeably smaller size; and at the very bottom of the cover the author name **Carlos Mendez** in small caps, in the same medium slate, at a modest weight that does not compete with the title. Treat the typography as a primary subject — equal in importance to the data-art motif. Overall mood: contemporary, premium, scholarly, quietly elegant; the visual energy of a serious data-science publication, never a generic AI illustration.

## Negative prompt / things to avoid

- **No branching ribbons, no radial diagrams, no spider webs, no node-and-edge graph networks, no mind-map layouts, no central-hub-with-spokes compositions.** Hard exclusions — both the previous v2 attempt and the current `cover.jpg` had central artwork the user explicitly disliked.
- No map icons, city skylines, mountains, region thumbnails, or any miniature scenes inside the composition.
- No chart axes, tick marks, gridlines, numeric labels, legends, chart frames, or anything that reads as a literally-plotted scientific figure. The curves should *evoke* a synthetic-control plot, not reproduce one.
- No cigarettes, smoke, ashtrays, California silhouettes, flags, or any literal Proposition 99 / public-health imagery.
- No human figures, faces, hands, or silhouettes.
- No neon tubes, no laser beams, no lens flares, no sci-fi HUD overlays, no holographic UI panels.
- No watermarks, signatures, "bestseller" badges, mock awards, sticker shapes, dog-eared corners, page-curl effects.
- No misspellings, no paraphrased title or subtitle, no invented taglines, no embedded labels on the curves (no words like "TREATED" / "SYNTHETIC" / "COUNTERFACTUAL" / "INTERVENTION" written inside the artwork). If the model cannot render the text cleanly, leave the typography zone empty rather than producing garbled letters.

## Iteration tips

Re-run the same primary prompt; if the result needs a nudge, append **one** of these sentences:

- **Text is garbled or misspelled** → *"Render the text with crisp, perfectly kerned letterforms; treat the typography as the primary subject and prioritize legibility over decorative flourish."*
- **Curves look too 'neon' / video-game** → *"Render the curves as translucent layered glass with soft internal light and subtle chromatic edges, not as glowing neon tubes; reduce saturation slightly and lean into a quieter, more cinematic glow."*
- **Composition reads too much as a chart** → *"The two curves should feel hand-drawn and painterly with slight imperfection, not mechanically plotted; remove anything that looks like a chart frame, axis, or grid; the divergence should feel like a moment in a painting, not a data point."*
- **Curves don't read as parallel-then-divergent** → *"Both curves must track each other almost exactly through the left two-thirds of the canvas, then split cleanly at the vertical intervention line so the widening gap on the right reads unmistakably."*
- **Palette has drifted** → *"Hold strictly to this palette: background gradient `#E5E7EB` → `#CBD5E1`, treated curve in `#2563eb`, synthetic counterfactual curve in `#059669`, intervention line in `#7c3aed`, title in `#0F172A`, subtitle and author in `#475569`. No other hues."*
- **Cover feels flat or sterile** → *"Add a sparse drift of soft pale-blue bokeh particles through the cool-grey space — small, out of focus, very low opacity — just enough to give the cover atmosphere without warming the palette."*

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

### Why this palette

The three accent hexes (`#2563eb`, `#7c3aed`, `#059669`) are the **light-theme variants of the book's own design tokens**, defined in `custom.css:10–12`. The cool-grey background pairs naturally with them and mirrors how the book renders in its default `cosmo` light theme (`_quarto.yml:39`), so the cover feels like a continuation of the book's interior rather than a separate piece of art bolted onto the front.
