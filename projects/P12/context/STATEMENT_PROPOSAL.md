# Statement proposals for P12

Two statements, one Lean module each, about real numbers and finite sums, self-contained over
Mathlib. Keep every definition inside the statement's own namespace.

## P12.StoichiometricCeiling

Definition: gain (r N Cpot : ℝ) : ℝ := min Cpot (r * N).

Statement: a conjunction of four parts, each for all real r, N, Cpot, d with 0 < r, 0 ≤ N,
0 ≤ Cpot and 0 ≤ d.

1. Ceiling. gain r N Cpot ≤ r * N and gain r N Cpot ≤ Cpot.
2. Marginal bound. 0 ≤ gain r (N + d) Cpot - gain r N Cpot and
   gain r (N + d) Cpot - gain r N Cpot ≤ r * d.
3. Nitrogen-limited. If r * (N + d) ≤ Cpot then gain r (N + d) Cpot - gain r N Cpot = r * d.
4. Saturated. If Cpot ≤ r * N then gain r (N + d) Cpot = gain r N Cpot.

Check before proposing: min is monotone in each argument and 1-Lipschitz; in part 3 both values are
the second argument; in part 4 both are Cpot.

Sanity checks to include: r = 30, N = 2, Cpot = 100 gives 60; adding d = 1 gives 90 (exactly
r·d more); adding d = 3 gives 100 (capped, 40 < r·d = 90). Negative control to describe: part 2's
lower bound fails for d < 0 (removing nitrogen lowers the gain), which is why d ≥ 0 is assumed.

The rationale must say that a fixed C:N ratio and a sharp minimum are assumptions, and that r, N
and Cpot are field inputs.

## P12.PoolStoichiometry

`ι` is a type of pools (wood, foliage, litter, soil) with `DecidableEq ι`, `s : Finset ι`,
`N r : ι → ℝ`. Definition: carbon s N r : ℝ := ∑ i ∈ s, r i * N i.

Statement: a conjunction of two parts.

1. Bound. If 0 ≤ N i and 0 ≤ r i ≤ rmax for every i ∈ s, then
   carbon s N r ≤ rmax * ∑ i ∈ s, N i, and 0 ≤ carbon s N r.
2. Transfer. For lo ≠ hi in s and every δ, moving δ of nitrogen from lo to hi
   (N' = N with N' lo = N lo - δ and N' hi = N hi + δ, written with `Function.update`) gives
   carbon s N' r - carbon s N r = (r hi - r lo) * δ.

Hints: `Finset.sum_le_sum`, `Finset.mul_sum`, `Finset.sum_erase`, `Function.update_apply`.

Sanity checks to include: wood (ratio 300, N = 1) and soil (ratio 12, N = 10) hold 300 + 120 = 420;
moving 1/10 from soil to wood adds (300 - 12)·(1/10) = 144/5. Negative control to describe: part 1
fails if a pool may hold negative nitrogen (one pool with N = -1 and r = 0, another with N = 1 and
r = rmax = 1: carbon is 1 but rmax times the total is 0).

The rationale must say that moving nitrogen between pools is bookkeeping in the model and that the
statement says nothing about how fast, or whether, nitrogen moves in a real forest.
