# P3-T004 lab notebook (2026-11-17)

Task: prove sealed statement P3.RecoveryWorkFloor (sealed by D-013, sha256 5f5a53ef...).

## Session start
- Prior runs checked for pending Aristotle projects: none pending (2026-11-05 submission failed,
  2026-11-15 and 2026-11-16 did not use Aristotle).
- Paper started from 2026-11-16 run's main.tex.

## Proof (out/proofs/P3.RecoveryWorkFloor.lean)
- First attempt (direct: div_le_iff0 + two mul_le_mul_of_nonneg_right + nlinarith; attainment by
  div_nonneg + field_simp + ring) PASSED viridis-lean-check (preview) immediately.
- Restructured so the floor is derived from a restated Run-163 chain, per the brief
  ("building on target_requires_supply"): uniform_efficiency_bound -> target_requires_supply
  (T/emax <= wf + wr) -> freshFloor_eq ((T - emax*wr)/emax = T/emax - wr, field_simp) -> floor
  (linarith). Attainment unchanged. Re-checked: PASSED (preview); axioms propext,
  Classical.choice, Quot.sound.
- Run-163 file cannot be imported (only Mathlib + sealed module allowed), so its two lemmas are
  restated over the sealed `useful` with the same proofs.
- Observation: hypotheses 0 <= ef, 0 <= er are unused in part 1; 0 <= wr is unused in part 2
  (wr >= 0 IS used in part 1: with wr < 0 and er < emax the bound can fail).

## Aristotle
- Not used this session (not needed). No project IDs. None pending.

## Open questions / next steps
- Remaining P3 statement: P3.CyclicSymbiosis (hardest; sketch in 2026-11-05 notes).
- Possible extension (not sealed): per-source caps (ef <= emax_f, er <= emax_r) giving
  wf >= (T - emax_r*wr)/emax_f; and coupling wr to the loop model (wr = r*D).

## Paper
- out/paper/main.tex rewritten as a note on RecoveryWorkFloor (model, theorem, human proof with
  hypothesis-usage remark, full Lean listing, settled / not settled incl. "not a Landauer bound,
  not from the Intelligence Bound", reproducibility, changelog).
- refs.bib: 4 prior refs kept; added Landauer 1961 (doi:10.1147/rd.53.0183, confirmed by
  WebSearch) and Run-163 Zenodo record (doi:10.5281/zenodo.22736716, confirmed by WebFetch:
  "A Useful-Dissipated Work Ledger Note for Staged Ecopoiesis", J. D. Hart, 2026-09-13).
- Compiles with latexmk -pdf in a clean scratch dir; 0 overfull boxes, no warnings.
