# P1-T003 lab notebook (2026-11-09)

Task: prove sealed P1.Insertion (L2). Session start 17:46 UTC, budget 140 min.

## Session start
- Prior runs: no Aristotle project IDs ever created (API key failures). Nothing pending.
- Starting point: out/proofs/P1.Insertion.lean copied from 2026-11-08 (1607 lines, no gaps,
  no Candidate.main). Only open piece: SEnc B p -> JoinLR B p (equivalently enc <= C8 - euler).

## Log
- 17:50 Aristotle: `aristotle list` -> "Invalid Aristotle API key" again. No project created.
- 18:15 Plan for the missing direction (SEnc -> JoinLR), by contrapositive: let C be the
  8-component of SE in B. If W, SW are not in C, then no barrier pixel other than C is
  8-adjacent to C, and p touches C only at the corner SE. Follow the crack boundary of C
  (cracks (c,d), c in C, c+d not in C; deterministic (8,4) successor `next` with explicit
  left inverse `prev`, so `next` permutes the finite crack set). The orbit of the crack
  (SE, west) returns to itself; its last element before returning is (SE, north) (by
  injectivity), and the only step that passes through p is (SE, north) -> (SE, west). So the
  outside pixels give a free 4-path S -> ... -> E avoiding p; E has a free ray. No topology
  beyond a finite permutation is needed.
- 18:00 Generic crack lemmas compiled standalone (/tmp scratch): `next` (successor: diagonal
  pixel in C -> turn outward; side pixel in C -> straight; else turn inward), `prev`,
  `next_mem`, `prev_next` (left inverse on cracks), `orbit` (self-map of a finite set with a
  left inverse: the orbit of x0 returns, with a minimal period). Pitfall: hypotheses with
  unreduced projections `((c1,c2),d1,d2).1` need `dsimp only` before `omega`; membership of
  re-arranged coordinates handled by a helper `mc : (a,b) ∈ C → a = a' → b = b' → (a',b') ∈ C`.
- 18:03 `crack_step`, `crack_escape`, `join_of_senc`, `main` compiled.
  `viridis-lean-check out/proofs/P1.Insertion.lean P1.Insertion` -> PASSED (preview), axioms
  Classical.choice, Quot.sound, propext. ~50 s.
- 18:06 Added `bridge_eq : (enclosed B : ℤ) = C8 B - euler B` for every finite B (the equation
  of P1.Bridge, unconditional now). Still PASSED.

## Status
- out/proofs/P1.Insertion.lean: `Candidate.main : ViridisStatements.P1.Insertion.Statement`,
  ~1950 lines, no gaps, standard axioms only, viridis-lean-check PASSED (preview).
- Key idea of the last step (worth reusing for P1.Bridge clause (1) and anything Jordan-like):
  the (8,4) crack-successor map is injective on cracks (explicit left inverse), so orbits are
  cycles in a finite set; the step before returning to the start crack is forced by
  injectivity; local analysis shows only one transition passes through p.

## Aristotle project IDs
- None. API key invalid again on 2026-11-09 (`aristotle list`).

## Next steps
1. P1-T004 (P1.Bridge): the equation is `bridge_eq` in this file; clause (1) (finitely many
   enclosed components) is `finite_enclosed`. Check the exact sealed form of P1.Bridge first.
2. The file is long (one 1950-line module); consider splitting helper lemmas if a future
   statement needs them.
- 18:09 Paper updated: new title and abstract, new Section "A proof of L2, part 2: escape along
  the crack boundary" (sec:crack) with a listing of the key lemmas, Table 1 row 5, limitations,
  reproducibility, changelog. Compiles with latexmk -pdf; I compiled it in a scratch copy so
  that no build files are left in out/paper.
  Dropped the 2026-11-08 empirical claim C2: its script and results are not in this package,
  and the proof does not need them.
- Paper-only negative result (not formalised): filling the free pixels of S's component one at
  a time with induction on its size fails on annular components. Filling any pixel of an
  annulus around a one-pixel island merges the island with the outer barrier. This is why the
  crack-orbit argument was used.
- Session ended early (~25 min used of 140) because the task was complete. P1-T004 is a separate
  task and was not started.
