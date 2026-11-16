# P3-T003 lab notebook (2026-11-16)

Task: prove sealed statement P3.CascadedRecovery (sealed by D-012, sha256 a4e3f3c2...).

## Session start
- Prior runs: no Aristotle project IDs pending (2026-11-05 submission failed, 2026-11-15 did not use it).
- Paper copied from 2026-11-15 run as a starting point.

## Proof (out/proofs/P3.CascadedRecovery.lean)
- Helpers: factor_nonneg / factor_le_one (each 1 - r i in [0,1]); subprod_le_one / subprod_nonneg
  (Finset.prod_le_one, Finset.prod_nonneg on any Finset); split (Finset.mul_prod_erase);
  lower_bound (Finset.prod_const + Fintype.card_fin, then Finset.prod_le_prod).
- Part 3 (iSup): case n = 0 by simp (both sides 1); n > 0: le_ciSup with
  (Set.finite_range r).bddAbove, ciSup_le h1 (needs Nonempty (Fin n)), then lower_bound.
- Parts 4, 5: split off j; for 5 split k off the erase-j product as well; nlinarith.
- viridis-lean-check: PASSED (preview) on first attempt; axioms propext, Classical.choice, Quot.sound.

## Aristotle
- Not used this session (not needed). No project IDs. None pending.

## Paper
- out/paper/main.tex rewritten as a note on CascadedRecovery (model, theorem, human proof,
  full Lean listing, settled / not settled, reproducibility, changelog).
- refs.bib unchanged (4 refs); each re-confirmed by WebSearch this session (DOIs match).
- Compiles with latexmk -pdf in a clean scratch dir; no warnings.

## Open questions / next steps
- Coupling of cascade to loop model (effective recovery 1 - virginShare) - not sealed.
- Correlated stages: model assumes independence; real cascades may do worse than the product.
- Next tasks: RecoveryWorkFloor, CyclicSymbiosis proofs.
