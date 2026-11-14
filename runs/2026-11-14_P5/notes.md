# P5-T002 lab notebook (2026-11-14)

Task: prove sealed `P5.UnrestrictedBoundFalse` (sha256 3b83eb37…0a95d, sealed by D-019).

Pending Aristotle projects from prior runs: none (P5-T001 submitted none). No Aristotle jobs submitted
this session: the proof is a one-line instantiation and did not need one.

## Log
- Read the sealed module, README.md, STATEMENT_PROPOSAL.md, prior run (2026-11-13_P5) notes/paper/run.json.
- Wrote `proofs/P5.UnrestrictedBoundFalse.lean`:
  - `bound_zero_power`: `maxBitRate 0 kB T * D = 0` by `simp [maxBitRate]` (0 / x = 0 in Lean).
  - `main`: `intro h`, specialise at dIdt=1, P=0, D=0, kB=T=1, rewrite with `bound_zero_power`,
    close `¬ (1:ℝ) ≤ 0` with `norm_num`.
  - `bound_proves_anything`: explosion — with the unrestricted bound as hypothesis, any `p : Prop`
    follows (`absurd h main`). Illustrates the inconsistency point in the paper.
- `viridis-lean-check` result: PASSED (preview), axioms propext, Classical.choice, Quot.sound.
  First attempt passed; no failed attempts.
- Note: the witness uses P = 0, which makes the bound 0 regardless of the Lean convention x/0 = 0
  (the denominator kB·T·ln 2 = ln 2 ≠ 0 here anyway). A witness with P > 0 also exists (any dIdt
  above P/(kB T ln 2)·D), so the falsity does not hinge on a degenerate guard.
- Paper: extended the prior note into a correction note centred on Finding 1; Finding 2
  (CompensationUnderCeiling) is kept as a conjecture pending P5-T003.
- Paper compiles with latexmk -pdf (built in /tmp, no artefacts in out/). refs.bib unchanged from prior run (DOIs confirmed there).
- run.json: C1 formal (P5.UnrestrictedBoundFalse), C2 conjecture (CompensationUnderCeiling); announcement.md written.

## Open questions
- The claim "no declaration in the reviewed corpus depends on the axiom" is from the 2026-11-11 reading
  of the corpus (README), not machine-checked here; a future task could check it with
  `#print axioms` on each historical declaration if the historical files are made available.

## Next steps
- P5-T003: prove P5.CompensationUnderCeiling (routes in 2026-11-13 notes: field_simp; div_le_iff₀ +
  nlinarith; δ = P*D/(|M|+1); simp + positivity).
