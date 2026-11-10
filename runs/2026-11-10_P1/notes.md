# P1-T004 lab notebook (2026-11-10)

Task: prove sealed P1.Bridge (L3). Budget 140 min.

## Session start
- Prior runs: no Aristotle project was ever created (the API key was invalid on 2026-11-04, -08 and -09),
  so no projects are pending. I did not submit an Aristotle job tonight because none was needed.
- Starting point: inputs/prior_runs/2026-11-09_P1/proofs/P1.Insertion.lean (1948 lines,
  PASSED for P1.Insertion). It already contains `finite_enclosed` (clause 1 of P1.Bridge) and
  `bridge_eq` (clause 2), stated over the P1.Insertion definitions.

## Log
- Compared the definitions in statements/P1.Bridge.lean and statements/P1.Insertion.lean
  (namespace to `def Statement`). They are identical character for character, except that
  P1.Insertion also defines `invariant`, and the two `Statement` docstrings differ.
- Adapted the file: `import ViridisStatements.P1.Bridge`, `open ViridisStatements.P1.Bridge`,
  restated `invariant` and the L2 statement (`InsStatement`) locally in `Candidate`, and
  renamed the six internal uses of `Statement` to `InsStatement`. L2 is now `Candidate.insertion`, and
  `Candidate.main : P1.Bridge.Statement := fun B => ⟨finite_enclosed B, bridge_eq B⟩`.
  `finite_enclosed` is stated as `Finite {c // IsEnclosed c}` and is accepted for the
  `Set.Finite` clause of the statement as is (the two are definitionally equal).
- `viridis-lean-check out/proofs/P1.Bridge.lean P1.Bridge` -> PASSED (preview). Axioms:
  Classical.choice, Quot.sound, propext. About 41 s. The first attempt passed.

## What this does and does not discharge (for the paper)
- Discharges: the raster form of the duality step. On every finite raster, the number of
  bounded compartments equals C8 - chi(K B). With no assumption, this is the raster counterpart of
  "compartments = rank H1 + 1", with C8 - chi in place of rank H1.
- Does NOT discharge the hypothesis `FaceCount` in DualCorridor.lean as stated. FaceCount
  concerns an abstract SimpleGraph G and its graph circuit rank. The following are not proved:
  (a) a correspondence between a corridor graph and a raster with circuitRank G = C8 - chi
      (false for the 8-adjacency graph of the raster itself: the 2x2 block has circuit rank 3 and C8 - chi 0);
  (b) the identification C8 - chi = b1(K B) (homology is not used anywhere);
  (c) "exactly one unbounded 4-component", which total compartments = enc + 1 requires;
  (d) the landscape boundary anchor C ∪ ∂Ω (the bridge works in all of Z^2, with no window).

## Next steps
1. (c) is easy: every pixel outside the bounding box reaches the frame. It would be a new sealed statement
   (e.g. P1.Unbounded: exactly one infinite component, or `faces = enc + 1`).
2. A raster-to-graph statement: for a corridor graph rasterised with "thick" edges (or for the
   crack/cubical 1-skeleton graph of K B), the graph circuit rank equals C8 - chi. This is the remaining
   link to FaceCount. It is a candidate statement for P1-T005.
3. Windowed version (complement inside a rectangle Ω with the boundary as barrier) for ∂Ω anchoring.

## Later in the session
- Added `free_adj`, `row_reach`, `col_reach`, `unique_unbounded` (exactly one infinite
  component) and `card_components` (total number of components = C8 - euler + 1, with the components finite).
  Took two compile iterations. Fixed: subtype-coercion equality in `free_adj`, `Finset.finite_toSet`
  on a `let` box, `classical` for `Equiv.sumCompl`. viridis-lean-check is still PASSED. `#print axioms`
  (in a /tmp copy) for insertion, unique_unbounded and card_components gives propext, Classical.choice and
  Quot.sound.
- Paper: new title and abstract; new Section "A proof of L3 and what it discharges" (sec:l3), covering the
  statement, the proof sketch, the total count, and what FaceCount needs that is discharged or not discharged;
  updated limitations, reproducibility and changelog. Compiled with latexmk -pdf in /tmp/pb (no build files in out/).
- Aristotle: not used tonight, so there are no project IDs.
