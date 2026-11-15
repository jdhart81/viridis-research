# P3-T002 lab notebook (2026-11-15)

Task: prove sealed statement P3.LoopMassBalance (sealed by D-011, sha256 f0063459...).

## Session start
- Prior run 2026-11-05_P3: no Aristotle project IDs pending (submission failed with invalid
  API key, no project created). Nothing to fetch.
- Followed the proof sketch from the prior notes.

## Proof (out/proofs/P3.LoopMassBalance.lean)
- `gap_succ`: one-step recursion S(t+1)-S* = ρ(S(t)-S*), by `field_simp; ring` using 1-ρ ≠ 0.
- `gap_closed`: induction on t.
- `stock_tendsto`: `tendsto_pow_atTop_nhds_zero_of_lt_one`, `.mul_const`, `.add_const`, then
  `Tendsto.congr'` with the closed form.
- `cumulative_eq`: `simp [Finset.sum_const, nsmul_eq_mul]; ring`.
- `main`: bounds on V by `mul_nonneg`/`nlinarith`; StrictAntiOn by `nlinarith` with T·D > 0.
- `viridis-lean-check` result: PASSED (preview) on the first attempt; axioms
  propext, Classical.choice, Quot.sound.
- Aristotle not used (not needed).

## What it settles / does not
- Settles: accounting identities of the one-material loop model. Says nothing about any measured
  recovery rate, retention or demand.

## Paper
- out/paper/main.tex is narrowed to a short note on LoopMassBalance, per the brief. It has the
  model, the theorem, a human-readable proof, the full Lean file in a listings block, a
  settled/not-settled section and a changelog. The other three proposals are mentioned only in
  the changelog and background.
- refs.bib has 4 references, each confirmed by WebSearch this session: Geissdoerfer et al. 2017,
  Chertow 2000, mathlib 2020 and de Moura & Ullrich 2021, all with DOIs. I dropped the two Zenodo
  canon refs because this note does not use them, and they were not re-checked.
- The paper compiles with latexmk in a clean scratch copy, with no warnings and no overfull
  boxes. I could not render the PDF visually (no pdftoppm).

## Aristotle
- Not used this session; no project IDs. None pending from prior runs.

## Open questions / next steps
- Stock-limited variant (recovery capped by the available stock) as a possible follow-up
  statement.
- Next tasks: CascadedRecovery, RecoveryWorkFloor, CyclicSymbiosis proofs (sketches in the
  2026-11-05 notes).
