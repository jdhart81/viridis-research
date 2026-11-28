# Statement proposals for P11

Two statements, one Lean module each, about real numbers only, self-contained over Mathlib. Keep
every definition inside the statement's own namespace.

## P11.WaterBalance

`P E Q S : ℕ → ℝ` are precipitation, evaporation, runoff and storage per period.

Statement: for all P, E, Q, S with S (i + 1) = S i + P i - E i - Q i for every i, and every n:

1. Telescoping. S n - S 0 = ∑ i ∈ Finset.range n, (P i - E i - Q i).
2. Closure. If S n = S 0 then ∑ i ∈ Finset.range n, Q i =
   ∑ i ∈ Finset.range n, P i - ∑ i ∈ Finset.range n, E i.
3. Runoff bound. If S 0 ≤ S n and 0 ≤ E i for every i < n, then
   ∑ i ∈ Finset.range n, Q i ≤ ∑ i ∈ Finset.range n, P i.
4. Runoff ratio. Under the hypotheses of part 3 and 0 < ∑ i ∈ Finset.range n, P i, the ratio
   (∑ Q) / (∑ P) is at most 1.

Hints: `Finset.sum_range_succ_sub_sum`, `Finset.sum_range_induction`, `Finset.sum_sub_distrib`.

Sanity checks to include: three periods with P = 10, 8, 6, E = 4, 4, 4, Q = 5, 4, 3 from S 0 = 20
end at S 3 = 20: storage is unchanged, and total runoff 12 equals total precipitation 24 minus
total evaporation 12, as part 2 says.
Negative control to describe: part 3 fails when storage falls (S 0 = 10, P = 5, E = 0, Q = 8 gives
S 1 = 7 and runoff 8 > 5).

The rationale must say that the balance is an accounting identity, that it estimates no term, and
that the runoff bound needs storage not to fall over the period.

## P11.BudykoFu

Use real powers (`Real.rpow`). Definition: fu (φ w : ℝ) : ℝ := 1 + φ - (1 + φ ^ w) ^ (1 / w).

Statement: a conjunction of four parts, each for all real φ, w with 0 ≤ φ and 1 ≤ w.

1. Non-negative. 0 ≤ fu φ w.
2. Energy limit. fu φ w ≤ φ.
3. Supply limit. fu φ w ≤ 1.
4. No evaporation at w = 1. fu φ 1 = 0.

Check before proposing: part 2 is 1 ≤ (1 + φ^w)^(1/w), from 1 ≤ 1 + φ^w; part 3 is
φ ≤ (1 + φ^w)^(1/w), from φ^w ≤ 1 + φ^w; part 1 is (1 + φ^w)^(1/w) ≤ 1 + φ, which is
1 + φ^w ≤ (1 + φ)^w, the superadditivity of t ↦ t^w on [0, ∞) for w ≥ 1. Hints to check against
the pinned Mathlib: `Real.add_rpow_le_rpow_add`, `Real.rpow_le_rpow`, `Real.rpow_natCast`,
`Real.rpow_mul`.

Sanity checks to include: φ = 1, w = 2 gives fu = 2 - √2, which lies in [0, 1]; φ = 0 gives
fu = 0 for every w ≥ 1. Negative control to describe: part 1 fails for w = 1/2 (below the range):
φ = 1 gives 2 - 2^2 = -2.

The rationale must say that Fu's curve is an assumed empirical form, that w and φ are catchment
inputs, and that the statement says nothing about how land cover changes w.
