# P5-T003 lab notebook (2026-11-19)

Task: prove sealed `P5.CompensationUnderCeiling` (sha256 ff09ca9e…ab763b, sealed by D-020).

Pending Aristotle projects from prior runs: none (2026-11-13 and 2026-11-14 notes list none).

## Log
- Read sealed module, README excerpt, prior notes (2026-11-14).
- Wrote `proofs/P5.CompensationUnderCeiling.lean` with four lemmas (`interior`, `ceiling`,
  `divergence`, `complete_loss`) and `main` as their conjunction.
  - interior: `div_mul_cancel₀`; uniqueness via `div_left_inj'` and `eq_div_iff`.
  - ceiling: Pmax > 0 from 0 < P ≤ Pmax; rewrite `dD ≤ D(1−P/Pmax)` as `P·D ≤ Pmax·(D−dD)`
    (field_simp + le_div_iff₀ + nlinarith); forward direction uses uniqueness from part 1,
    backward uses the witness P·D/(D−dD) with div_le_iff₀.
  - divergence: δ = P·D/(|M|+1); lt_div_iff₀ twice, nlinarith.
  - complete_loss: simp [cap]; positivity.
- `viridis-lean-check`: PASSED (preview) on the first attempt; axioms propext, Classical.choice, Quot.sound.
  No Aristotle jobs submitted (not needed).
- Carried `proofs/P5.UnrestrictedBoundFalse.lean` forward unchanged from 2026-11-14; re-checked: PASSED (preview).
  Listed as claim C2 so the paper's statements about Finding 1 stay backed.
- Paper: retitled to cover both corrections; Finding 1 condensed; new Section on Finding 2 quotes
  `no_finite_compensation` (from context/README.md), shows P + PΔD/(D−ΔD) = PD/(D−ΔD), states the
  theorem, includes the four Lean lemmas in a listings block, worked examples for each fact, a table,
  negative controls, the economic reading, and a "what is not shown" section.
- Added refs: Dasgupta & Heal 1974 (doi 10.2307/2296369) and Solow 1974 (doi 10.2307/2296370), both
  confirmed by WebSearch (RePEc/OUP listings). Cited only for the essential-vs-substitutable vocabulary.
- Paper compiles with latexmk -pdf in /tmp (no build artefacts in out/), no warnings.
- run.json: C1 formal (CompensationUnderCeiling), C2 formal (UnrestrictedBoundFalse). announcement.md written.

## Failed approaches
- None; first proof attempt passed.

## Open questions
- Corpus-dependence claim for intelligence_bound still not machine-checked (needs historical files).
- Which conclusions survive for other functional forms (e.g. P^a D^b, or f(P)·D with bounded f — with
  bounded f even the interior compensation can fail, which would be worth stating formally).

## Next steps
- See run.json next_steps. P5 core tasks done; possible follow-ups: generalised functional forms,
  well-posed successor bound proposal.
