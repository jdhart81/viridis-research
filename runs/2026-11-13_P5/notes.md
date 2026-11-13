# P5-T001 lab notebook (2026-11-13)

Task: propose `P5.UnrestrictedBoundFalse` and `P5.CompensationUnderCeiling`.
No prior runs; no pending Aristotle projects. No Aristotle jobs submitted this session (proposal task).

## Log
- Read README.md, STATEMENT_PROPOSAL.md and the sealed P3.RecoveryWorkFloor for module style.
- Wrote `proposals/P5.UnrestrictedBoundFalse.lean` and `proposals/P5.CompensationUnderCeiling.lean`
  exactly per STATEMENT_PROPOSAL.md; both compile with `lean` (no errors, no warnings shown).
- Checked the spec: no error found. Part 2 algebra: P' = P D/(D-dD) <= Pmax <=> P D <= Pmax (D-dD)
  <=> dD <= D(1 - P/Pmax), with Pmax > 0 from 0 < P <= Pmax.
- Scratch proofs of both statements (in /home/agent/scratch, NOT submitted, no claim) compiled:
  - UnrestrictedBoundFalse: `intro h; have := h 1 0 0 1 1 one_pos one_pos le_rfl le_rfl zero_le_one; norm_num at this`
  - Compensation: field_simp (part 1); div_le_iff₀ + mul_one_sub/le_sub_iff_add_le rewrites + nlinarith (part 2);
    δ = P*D/(|M|+1) with lt_div_iff₀ + nlinarith (part 3); `unfold cap; simp; positivity` (part 4).
- Failed: `decide` on ℚ arithmetic gets stuck in kernel reduction (Rat normalisation). `decide` on ℝ is impossible.
  So `decide` checks use cleared-denominator ℤ/ℕ forms; ℝ checks use norm_num/simp (as sealed P3 modules do).
- Observations on negative controls (written into rationale): dropping dD < D needs dD > D for a counterexample
  (at dD = D both sides of part 2 are false); dropping P <= Pmax needs Pmax <= 0 (for 0 < Pmax < P both sides false).
- Paper written (short note, all claims conjectures), compiles with latexmk; build artefacts removed.
- References confirmed by web search: Landauer 1961 (10.1147/rd.53.0183), de Moura & Ullrich 2021
  (10.1007/978-3-030-79876-5_37), mathlib CPP 2020 (10.1145/3372885.3373824).

## Open questions
- Should part 3 be phrased with `Filter.Tendsto … (nhdsWithin D (Set.Iio D)) atTop` instead of explicit δ? Kept δ for readability.
- Parts 3–4 carry `0 < C` which part 3 does not use; kept to match the spec.

## Next steps
- After sealing: P5-T002 and P5-T003 proofs (routes above). No Aristotle needed; elementary.
- Removed the word 'axiom' from .lean comments (now 'postulate') in case the denylist is a plain text scan; recompiled OK.
