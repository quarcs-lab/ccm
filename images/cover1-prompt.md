# Cover-image prompt for *Comparative Causal Metrics*

Use this prompt with **Gemini Nano Banana 2** to generate the front cover. The chosen generation should be saved as `images/cover.jpg` (overwriting the current file); no other repo changes are required.

---

## Primary prompt

> An abstract data-art illustration designed as an editorial book cover, vertical 2:3 portrait composition (~1600×2400 px). Deep navy and indigo background (around `#0B1A2B` to `#13243C`), enriched with a very subtle film-grain texture and faint, barely-visible horizontal grid lines suggesting a coordinate plane — atmospheric, never schematic. Across the lower two-thirds of the canvas, two flowing time-series curves move from left to right and meet a thin, glowing vertical "intervention" line that bisects the composition near its midpoint. Before the intervention, both curves trend gently upward in near-parallel; after the intervention, a luminous off-white "counterfactual" line continues its smooth ascending trajectory, while a warm amber-gold "treatment" line (around `#E8A23B`) bends decisively downward, opening a widening gap. A soft indigo glow surrounds the divergence area, drawing the eye to the gap between the two lines. The curves should feel painterly and hand-drawn rather than plotted — confident strokes, slight imperfection, no axes, no tick marks, no numbers, no legend, no annotations. The upper third of the canvas is reserved as a clean, uncluttered typography zone with generous negative space. Render the following text exactly as written, with crisp kerned letterforms, perfect spelling, and no extra words: the title **Comparative Causal Metrics** as the dominant element in a modern serif typeface reminiscent of Source Serif or Tiempos, set in title case; immediately below it the subtitle **An Introduction to Regional Impact Evaluation** in a smaller humanist sans-serif resembling Inter; and at the very bottom of the cover the author name **Carlos Mendez** in small caps, sized modestly so it does not compete with the title. Overall mood: scholarly, contemporary, confident, and quietly elegant — closer to a university-press monograph or a serious data-journalism cover than to a stock illustration or generic AI artwork. Treat the typography as a primary subject, equal in importance to the data-art motif.

## Negative prompt / things to avoid

- No chart axes, tick marks, numeric labels, legends, gridlines that look like a real plot, or dataset annotations.
- No cigarettes, smoke, ashtrays, California silhouettes, maps, flags, or any literal Proposition 99 / public-health imagery.
- No human figures, faces, hands, or silhouettes.
- No watermarks, signatures, page-curl effects, dog-eared corners, "bestseller" badges, sticker shapes, or mock award seals.
- No misspellings, no paraphrased title or subtitle, no invented tagline. If the model cannot render the text cleanly, leave the typography zone empty rather than producing garbled letters.
- No stock-illustration tropes: no glowing lightbulbs, no jigsaw pieces, no clip-art arrows, no generic "AI" neural-network motifs.

## Iteration tips

Re-run the same prompt; if the result needs a nudge, append one of these as an extra sentence:

- **Text is garbled or misspelled** → append: *"Render the text with crisp, perfectly kerned letterforms; treat the typography as the primary subject and prioritize legibility over decorative flourish."*
- **Lines look too much like a chart** → append: *"The two curves should feel hand-drawn and painterly, with slight ink-bleed and subtle imperfection, not mechanically plotted."*
- **Palette drifts away from navy/amber** → append: *"Hold strictly to this palette: background `#0B1A2B` deepening to `#13243C`, counterfactual line in luminous off-white, treatment line in warm amber `#E8A23B`. No other hues."*
- **Composition feels crowded** → append: *"Leave the upper third of the canvas almost entirely empty around the title; the data-art motif must stay in the lower two-thirds."*
- **Tone feels too commercial / sci-fi** → append: *"Aim for a university-press monograph aesthetic; restrained, scholarly, no neon, no glow effects beyond a soft indigo halo at the divergence."*

## After you pick a generation

1. Export at 1600×2400 (or larger) as a JPG.
2. Save it to this directory, overwriting the existing file:
   ```
   images/cover.jpg
   ```
3. Re-render and publish using the project's standard flow (see `CLAUDE.md`):
   ```bash
   quarto render --to html
   quarto publish gh-pages --no-prompt --no-render
   ```

The cover is wired up at `_quarto.yml:22` and displayed in the preface via `index.qmd:3`, so no source edits are needed — just dropping in the new JPG is enough.
