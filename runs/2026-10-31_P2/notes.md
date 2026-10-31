# P2-T003 lab notebook (2026-10-31): re-certify the Restoration nucleation core

## Start
- Target: sealed `P2.Restoration` (sha256 fd40b113...ccff18, verified locally; identical to the
  2026-10-30 proposal). Canon source context/ForestNucleation.lean sha256 667a826a...ec28132,
  matches context/SOURCES.sha256.
- Prior runs (2026-10-30, 2026-10-29): no Aristotle projects, nothing pending.
- `context/STATEMENT_PROPOSAL.md` is still absent from inputs/context (also noted on 10-30).

## What was done
- Wrote `proofs/P2.Restoration.lean`: a restructured port of the canon proof.
  - `rStar_pos`: `unfold rStar; positivity`.
  - `aσ_eq`: `a*σ = 3/2*Δμ*rStar` for Δμ ≠ 0 (`field_simp`).
  - `key_identity`: `G rStar - G r = Δμ (r - rStar)^2 (r + rStar/2)`: rewrite aσ, then `ring`.
  - `barrier_half`: rewrite aσ, `ring`.
  - `critical_nucleus`: max via positivity + linarith; uniqueness via `mul_eq_zero` case split
    (Δμ ≠ 0, r + rStar/2 > 0), so (r - rStar)^2 = 0.
  - `main` combines them.
- `viridis-lean-check out/proofs/P2.Restoration.lean P2.Restoration` -> PASSED (preview),
  axioms Classical.choice, Quot.sound, propext. Passed on the first attempt.
- Cross-check (scratch, not in out/): the canon proofs `critical_nucleus` and
  `barrier_half_identity` pasted VERBATIM (incl. `refine'`, `grind`) into a Candidate file also
  pass viridis-lean-check under v4.28.0 / Mathlib 8f9d9cff. So the canon proof itself still
  replays; the submitted file is a more readable version with explicit helper lemmas.
- Observation (scratch): the half-barrier identity holds for every Δμ ≠ 0 (`unfold; field_simp; ring`)
  and also at Δμ = 0 (both sides 0 by x/0 = 0), so the `0 < Δμ` hypothesis in part (ii) is unused.
  Kept in the sealed statement for faithfulness; not a claim.

## What the theorem does NOT settle (for the paper)
- Values of Δμ, σ, a; the CNT free-energy form itself; the r = n^(1/3) reparametrisation's
  ecological meaning; Arrhenius rate, T_eco, sigmoid committor, deadlines; the
  `broadcast_suboptimal` seed-allocation result (in canon, not in the sealed statement);
  kernel code conformance (TypeScript source not in inputs).
- Mathematical subtlety: theorem is about the maximiser on r >= 0 in r, equivalently n* = rStar^3
  maximises the n-form on n >= 0 because r -> r^3 is a monotone bijection of [0,∞). This
  equivalence is not part of the sealed statement.

## Aristotle
- Not used; no project IDs.

## Next steps
- P2-T004 / P2-T005 (Afforestation, Harmonization proofs) using sketches in 2026-10-30 notes.
- Consider sealing `broadcast_suboptimal` and an n-form (rpow) version of critical_nucleus if the
  live kernel compares in n directly.
