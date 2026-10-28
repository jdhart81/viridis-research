# P1-T001 lab notebook (2026-10-27)

## Outcome
`proofs/P1.BitQuad.lean` proves `ViridisStatements.P1.BitQuad.Statement`.
`viridis-lean-check proofs/P1.BitQuad.lean P1.BitQuad` gave PASSED (preview), with axioms
propext, Classical.choice and Quot.sound. It is 159 lines and compiles in about 10 s.

## Approach (worked)
1. `card_filter_shift`: if i and j are inverse maps of Z^2 and j(S) is a subset of V, then
   |{v in V : i v in S}| = |S| (via `Finset.card_nbij'`). `sum_ind_shift` is the same
   statement as an indicator sum (`Finset.sum_boole`).
2. Eight instances with V = vertices B: four for B (window bits a,b,c,d), two for hEdges
   (right and left arm), two for vEdges (up and down arm). Side conditions come from small
   lemmas: pixel corners and edge endpoints are vertices.
3. `key`: 4*euler B = sum over v of (4 - 2*arms + n), via sum_add/sub_distrib, mul_sum and ring.
4. Pointwise: rewrite the edge memberships with `mem_hEdges`/`mem_vEdges`
   (e in hEdges iff e in B or (e1, e2-1) in B, and similarly for vEdges). Unfold
   windowCount/isDiagonal/bits, split on the 4 membership props (16 cases), then `simp_all`.

## What failed and what I learned
- The local identity over all 16 Bool patterns is FALSE. On the empty window, LHS = 4 and
  RHS = 0. `decide` reported this correctly. Fix: lemma `window_nonempty` (every vertex is
  a corner of some pixel, so its window has at least one pixel).
- `rw [mem_hEdges]` inside an `if` fails because the motive is not type correct (the
  Decidable instance depends on the proposition). Use `simp only` instead.

## Aristotle
No Aristotle jobs were submitted; none were needed. There are no pending project IDs, and
no prior runs existed.

## Open questions / next steps
- P1-T002: propose L2 (P1.Insertion) and L3 (P1.Bridge). L1 gives a local Delta-chi over
  the 4 windows at the corners of p. The hard part is the change in C8 and in enclosed
  components.
- The 4-connected variant (+2 QD) is not formalised.
