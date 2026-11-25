# P6-T003 lab notebook (2026-11-25)

Task: prove sealed statement P6.SingleFailureRobust (sha256 f7c92557...; sealed by D-025).

## Start of session
- Prior runs 2026-11-24_P6 (T002) and 2026-11-23_P6 (T001) submitted no Aristotle jobs; none pending.
- No Aristotle jobs submitted this session.

## Main task
- Wrote out/proofs/P6.SingleFailureRobust.lean. `viridis-lean-check` PASSED on the second attempt
  (axioms Classical.choice, Quot.sound, propext). Only the verifier awards PROVEN.
- First attempt failures: (1) `Walk.cons h _` gives `G.Adj u w`, needed `G.mem_edgeSet.mpr h`;
  (2) rewriting `← patchCount_eq` also hit `Nat.card G.edgeSet` (patchCount is a plain Fintype.card),
  fixed by passing both count bridges as hypotheses to omega.
- Proof route (as predicted by T002): by contradiction m < n; with n <= m+1 (Mathlib
  `Connected.card_vert_le_card_edgeSet_add_one`) get m+1 = n, so G is a tree
  (`isTree_iff_connected_and_card`); n >= 2 gives two distinct vertices and a walk between them whose
  first dart is an edge; every tree edge is a bridge (`isAcyclic_iff_forall_edge_isBridge`, `isBridge_iff`),
  contradicting connectivity after deleting it.
- Attainment witnesses: the proof file also contains `triangle_attains` and `cycle4_attains`
  (closed by `decide` after unfolding SurvivesSingleFailure), restating the module's sanity examples.

## Frontier duty: test plan for M-Nucleation
- Proposed plan out/plans/P6-NucleationIslandSize (PLAN.md, code/analyze.py, data/design.json, fixtures).
- Outcome data: Zenodo record 4731126 (Zahawi, Holl, Cole, Reid; DOI 10.7291/D11681, CC0),
  file tree_recruits-2007-2013.csv. Only the record page and the ReadMe (column codes) were read; data not opened.
  datadryad.org was refused by the proxy; zenodo.org works.
- Test: site-level log ratio of per-m^2 density of seedlings alive in 2013, large vs small islands; bootstrap CI.
  SUPPORTED if CI lower > 0 and monotone S<M<L in means; CONTRADICTED if CI upper < 0; else NOT_SUPPORTED.
- Fixtures: supported -> SUPPORTED, contradicted -> CONTRADICTED (checked locally in temp dirs).
- Caveats: (a) severity: a search summary of the 2013 abstract (large > small recruit density) was seen,
  so SUPPORTED is likely; analysis differs (seedlings only, 2013 survivors, no edge buffer, site log ratios).
  (b) island count per size (2 each) recalled, not confirmed; only ratios matter if counts are equal.
  (c) Tests only the size-scaling consequence, not the nucleation mechanism or n*; disperser attraction
  is a rival explanation of the same ordering.

## Premise reviews
- P6.MinimalNetwork: independent reading, no premises (pure graph theory; module disclaims real-world claims).
- P6.SingleFailureRobust: no premises, same reasoning.

## Paper
- out/paper/main.tex extended from the T002 paper; compiles with latexmk -pdf (6 pages); build files removed.
- Added the informal placement observation (m = n robust iff Hamiltonian cycle); NOT formalised.

## Open questions / next steps
- Formalise the placement observation as a future proposal?
- P6-T004: SerialParallel.
