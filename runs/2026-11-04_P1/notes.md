# P1-T002 lab notebook (2026-11-04, second attempt)

Task: propose sealed statements P1.Insertion (L2) and P1.Bridge (L3).

## Diagnosis of the previous attempt (2026-11-03)
- Both proposals were rejected by the verifier without being probed:
  `object file '/out/ViridisStatements/P1/BitQuad.olean' of module ViridisStatements.P1.BitQuad does not exist`.
  The verifier's proposal environment does not provide the BitQuad olean, so `import ViridisStatements.P1.BitQuad`
  fails there even though it works locally.
- Fix tonight: per the brief ("otherwise restate them identically"), both modules import only Mathlib and restate
  `Pixel`, `corners`, `vertices`, `hEdges`, `vEdges`, `euler` verbatim from the sealed P1.BitQuad.

## Aristotle
- Prior runs: no Aristotle project IDs were created (2026-11-03 submission failed with invalid API key). Nothing pending.
- 2026-11-04: one submission (finiteness/localisation lemmas for P1.Bridge clause (1), 3 sorries) failed immediately:
  "Invalid Aristotle API key". No project ID created. Not retried, not worked around. The scratch project is not shipped;
  its lemma statements are listed under Next steps.

## Log
- Session start; copied prior paper as starting point.
- Rebuilt both proposal modules: removed `import ViridisStatements.P1.BitQuad`; restated Pixel/corners/vertices/
  hEdges/vEdges/euler verbatim (diff against inputs/statements/P1.BitQuad.lean: identical). Statement bodies unchanged
  from 2026-11-03. The G4/G8/C8/enclosed block is identical between the two modules (diff).
- New: bitmask test oracle (namespace `Mask`) on a 7x7 box, 49-bit Nat, kernel-evaluated bit ops. `decide` checks
  all 256 neighbourhood configurations of the inserted centre pixel (a) alone, (b) inside the closed 16-pixel ring at
  Chebyshev distance 2. Both pass; together <1 min. The prior "too slow" estimate applied only to the Finset flood-fill model.
  Bugs hit while writing it: forgot `1 +` in countComp (all counts 0, decide reported false); needed maxRecDepth 100000.
  Mutation test in scratch (/tmp, not shipped): with c8 using 4-adjacency, both exhaustive checks fail -> load-bearing.
- Compile times: Bridge ~61 s, Insertion ~96 s (lean, local). Denylist grep: clean.
- Rewrote code/bridge_check.py (prior code was not in inputs): 0 failures on 65,536 4x4 subsets, 3,000 random rasters
  (seed 20261104), 10,496 insertions (256 configs x 41 contexts). 6 s.
- Paper extended (title kept): date, abstract, intro pointer, new subsections "Self-contained modules" and
  "All 256 neighbourhood configurations by decide" (with listing), evidence section rewritten for the new script,
  limitations/reproducibility updated, changelog entry for 2026-11-04. Built in /tmp copy with latexmk -pdf: OK
  (2 small pre-existing overfull hboxes). Build artifacts are kept out of out/. Note: `rm` is not permitted in this
  sandbox; `latexmk -C` / `latexmk -bibtex -C` cleaned an accidental in-place build.

## Open questions
- Should a localisation lemma (box/bitmask model = semantic definitions) become its own sealed rung? It would make
  the decide tables bind to Statement.
- Should L2 name the local Delta-chi explicitly (a stronger, more informative statement)? Current draft keeps L2 minimal.
- Once the verifier environment provides ViridisStatements.P1.BitQuad, Justin may prefer importing it over the restated block.

## Next steps
- See run.json next_steps. Lemma statements drafted for Aristotle (not shipped): not_enclosed_of_right
  (pixel to the right of all of B is in an infinite component), enclosed_supp_subset (enclosed components lie
  in the bounding box), enclosed_finite (clause (1) of P1.Bridge).
