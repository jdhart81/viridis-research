# P1 statement proposal (context for the agent)

**Label: ASSUMED.** This document is a plan. It is not a sealed statement or a
proof. Only the files in `lean/ViridisStatements/` that are listed in
`statements/registry.json` are sealed.

## Model and conventions

- A raster is a finite set `B ⊆ ℤ × ℤ` of barrier pixels. Pixel `(i, j)` is the
  closed unit square `[i, i+1] × [j, j+1]`.
- `K B` is the union of the closed squares of `B`, counted as a cubical
  complex: `V` distinct lattice points, `E` distinct unit edges and `F = |B|`
  squares, with `χ = V − E + F` computed in `ℤ`.
- Barrier connectivity is 8-adjacency: pixels sharing an edge or a corner.
  Non-barrier connectivity is 4-adjacency: pixels sharing an edge. This is the
  standard (8,4) pairing of digital topology, under which the Jordan property
  holds.
- The complement is `ℤ² \ B`. Exactly one of its 4-components is infinite. A
  component is enclosed when it is finite. The empty raster has C8 = 0,
  χ = 0 and no enclosed components.

## The ladder

1. **L1, bit-quad count (`P1.BitQuad`).** Pad `B` with the empty exterior and
   look at every 2×2 window, each centred on a lattice point. `Q₁` counts
   windows with one barrier pixel, `Q₃` windows with three, and `Q_D` windows
   with exactly two diagonally opposite pixels. Then `4χ = Q₁ − Q₃ − 2·Q_D`.
   Proof idea: `4F = Σ_v n(v)`, `2E = Σ_v arms(v)` and `V = Σ_v 1`, where each
   sum runs over the vertices of `K B`. So `4χ = Σ_v (4 − 2·arms(v) + n(v))`,
   and the summand takes the values 1, 0, −2, −1 and 0 on the pattern classes
   one pixel, adjacent pair, diagonal pair, three pixels and four pixels. The
   identity has been checked by brute force on all 65,536 subsets of a 4×4 box
   and on 20,000 random rasters up to 7×7. That check is evidence, not a proof.
2. **L2, single-pixel insertion (`P1.Insertion`).** Adding one barrier pixel
   `p ∉ B` leaves `enclosed − C8 + χ` unchanged. The change in χ is local
   (L1 restricted to the four windows around `p`). The changes in C8 and in
   enclosed components need a careful nonlocal argument: two 8-components
   merging through `p` can create a new enclosed region. Do not assume this
   from a picture.
3. **L3, bridge (`P1.Bridge`).** Induct on `|B|` from the empty raster using L2.

## How the bridge connects to *Trees Cannot Cut*

`context/DualCorridor.lean` assumes `FaceCount`: the compartment count equals
circuit rank plus one for a corridor graph. On rasters, L3 replaces that
assumption with a theorem about `C8 − χ`. A paper built on L3 must say
precisely which raster-to-graph correspondence it uses. The gap between the
cubical complex and the corridor graph's circuit rank is real: the 2×2 block
negative control shows it.
