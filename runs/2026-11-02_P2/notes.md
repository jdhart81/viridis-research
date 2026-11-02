# P2-T005 lab notebook (2026-11-02): re-certify the Harmonization market-clearing core

## Start
- Target: sealed `P2.Harmonization`, sha256 48934ecb...3dd7 (verified locally).
- Canon source context/GaianHarmonization.lean sha256 cfdead65...0aec, matches SOURCES.sha256.
- Prior runs (11-01, 10-31, 10-30): no Aristotle projects pending.
- Sealed module is byte-identical to the 2026-10-30 proposal `proposals/P2.Harmonization.lean`
  (diff empty).

## What was done
- Wrote `proofs/P2.Harmonization.lean`, a restructured port of the canon proofs:
  - `sum_inv_pos`: ∑ 1/a > 0 via `Finset.sum_pos` on index 0 (needs N > 0).
  - `sum_br`: ∑ br lam = ∑ b − lam·∑ 1/a (`Finset.sum_sub_distrib`, `Finset.mul_sum`, `mul_one_div`).
  - `market_clears`: `sum_br`, unfold lamStar, `div_mul_cancel₀`, `ring`.
    (Canon used two `simp +decide` calls with `mul_comm`/`mul_left_comm` soup.)
  - `equimarginal`: a i·(xStar i − b i) = −lamStar, by `field_simp; ring`.
  - `pointwise`: (a/2)(x*−b)² − lam(y−x*) ≤ (a/2)(y−b)², `rw [← equimarginal]` then nlinarith
    with hint a·(y−x*)² ≥ 0.
  - `strong_duality`: sum `pointwise`, price terms sum to −lam·(X − X) = 0 by feasibility and
    `market_clears`. (Canon used `convert ... using 1; simp +decide; exact Or.inr ...`.)
- `viridis-lean-check out/proofs/P2.Harmonization.lean P2.Harmonization` -> PASSED (preview),
  axioms Classical.choice, Quot.sound, propext. First attempt.
- Cross-check (scratch /tmp/canon, not in out/): canon theorems `ght_market_clears`,
  `ght_equimarginal`, `ght_strong_duality_decentralized_eq_centralized` pasted verbatim
  (against the sealed defs) + a `main` combining them also pass viridis-lean-check.

## Observations (not sealed claims; checked locally with `lean`, scratch files)
- Part (2) holds without `0 < N` (N = 0: `simp [J]` closes, both sides 0). Part (1) does need it
  (sealed module's own negative control).
- Positivity of curvatures matters for (2): N=2, a=(0,1), b=(0,0), X=1 gives (Lean 1/0=0)
  xStar=(0,1), J=1/2 > J(1,0)=0 with (1,0) feasible. Checked by norm_num.
- Only `0 ≤ a i` is used in `pointwise` plus `a i ≠ 0` in `equimarginal`.
- Not sealed: uniqueness of the minimiser, equimarginal identity as a statement, the canon's
  `ght_scalar_price_minimal_sufficient` (trivial ∃), IB bandwidth, wu-wei robustness ratios,
  and the deferred primal–dual Lyapunov convergence.

## Aristotle
- Not used; no project IDs.

## Next steps
- See run.json next_steps: remaining 13 kernels; Harmonization follow-ups (uniqueness,
  tâtonnement convergence) if the live kernel relies on them; code conformance.
