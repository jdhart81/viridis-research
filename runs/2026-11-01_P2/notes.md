# P2-T004 lab notebook (2026-11-01): re-certify the Afforestation seeding core

## Start
- Target: sealed `P2.Afforestation`, sha256 2fc1cbb0...59436 (verified locally). Byte-identical to
  the 2026-10-30 proposal `proposals/P2.Afforestation.lean` (diff empty).
- Canon source context/AfforestationStewardship.lean sha256 3ebe33bf...9526f, matches
  context/SOURCES.sha256.
- Prior runs (10-31, 10-30, 10-29): no Aristotle projects, nothing pending.
- `context/STATEMENT_PROPOSAL.md` still absent from inputs/context (third session running).

## What was done
- Wrote `proofs/P2.Afforestation.lean`, a restructured port of the canon proofs:
  - `eff_cubic` (no hypotheses): `unfold eff; ring`. Holds for all reals, incl. a*σ = 0 (x/0 = 0
    on both sides scales consistently since ring normalises division as multiplication by inverse).
  - `eta_mem_unit` (no `n ≠ 0`, `m ≠ 0`): `0 ≤` by positivity; `≤ 1` via `div_le_one_of_le₀`,
    squaring `abs_real_inner_le_norm` with `pow_le_pow_left₀`, then `sq_abs`, `mul_pow`.
    The canon used `nlinarith` here; I replaced it by an explicit squaring step.
  - `main` instantiates both, discarding the hypotheses.
- `viridis-lean-check out/proofs/P2.Afforestation.lean P2.Afforestation` -> PASSED (preview),
  axioms Classical.choice, Quot.sound, propext. Passed on the first attempt.
- Cross-check (scratch in /tmp, not in out/): canon proofs pasted verbatim (`unfold eff; ring;`
  and `refine' ... nlinarith ...`) into a Candidate file also pass viridis-lean-check. So the
  archived proof still replays under v4.28.0 / Mathlib 8f9d9cff.
- Universe polymorphism: the sealed `Statement` quantifies over `E : Type*`; the polymorphic
  candidate `main` matches it (statement-match stage passed).

## Observations (not sealed claims)
- All hypotheses of both parts are unused: helper lemmas are proved without them (they are in the
  submitted file, so this is machine-checked as part of the candidate's elaboration, but not a
  sealed statement). For n = 0 or m = 0, eta = 0/0 = 0 in Lean.
- Canon name `seeding_efficiency_eq_cos2_theta` over-promises: only the [0,1] bound is proved.
  Equality case (eta = 1 iff parallel) is not sealed.

## What the theorem does NOT settle
- Parameter values a, σ, Δμ, C; the CNT model's adequacy for seeding; whether "efficiency =
  C/n*" is the right ranking criterion; the equality case of η; the remaining canon results
  (site-prep 8x lever in general, homogeneous-limit identity, sower IB ceiling); code conformance.

## Aristotle
- Not used; no project IDs.

## Next steps
- P2-T005 (Harmonization) using the 10-30 sketch.
- Consider proposing a statement for the η equality case (η = 1 iff n, m linearly dependent) and
  the general σ-halving 8x lever if the live kernel relies on them.
