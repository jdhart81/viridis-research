# Statement proposals for P10

Two statements, one Lean module each, about real numbers and finite sums, self-contained over
Mathlib. Keep every definition inside the statement's own namespace.

Throughout: `ι` is a type of activities with `DecidableEq ι`, `s : Finset ι`, `a : ι → ℝ` the
activity amounts and `f : ι → ℝ` the emission factors. Definition: total (s) (a f) : ℝ :=
∑ i ∈ s, a i * f i.

## P10.InventoryPartition

Statement: a conjunction of four parts.

1. Scope partition. For every `scope : ι → Fin 3`:
   total s a f = ∑ j : Fin 3, total (s.filter (fun i => scope i = j)) a f.
2. Additivity. For disjoint s and t: total (s ∪ t) a f = total s a f + total t a f.
3. Sign and monotonicity. If 0 ≤ a i and 0 ≤ f i for all i ∈ s then 0 ≤ total s a f. If 0 ≤ a i
   and f i ≤ f' i for all i ∈ s then total s a f ≤ total s a f'.
4. Unit scaling. For every real u: total s a (fun i => u * f i) = u * total s a f.

Hints: `Finset.sum_fiberwise` (or `Finset.sum_fiberwise_of_maps_to`), `Finset.sum_union`,
`Finset.sum_nonneg`, `Finset.sum_le_sum`, `Finset.mul_sum`.

Sanity checks to include: two activities, 1000 kWh at 2/5 kg per kWh (scope 2) and 100 L at 27/10
kg per L (scope 1), give 400 + 270 = 670 kg, with scope totals 270, 400 and 0. Negative control to
describe: part 3's monotonicity fails if an amount may be negative (a refund booked as a negative
activity: a = -1, f = 1, f' = 2 gives -1 > -2).

The rationale must say that this is the accounting identity the Ledger applies, and that it
certifies no factor, no activity datum and no scope assignment.

## P10.FactorInterval

Statement: for all `lo hi : ι → ℝ` with lo i ≤ f i ≤ hi i and 0 ≤ a i for every i ∈ s:

1. Bound. total s a lo ≤ total s a f and total s a f ≤ total s a hi.
2. Width. total s a hi - total s a lo = ∑ i ∈ s, a i * (hi i - lo i), and it is non-negative.
3. Tight. Both ends are attained: f = lo and f = hi satisfy the hypotheses.

Sanity checks to include: the two activities above with the grid factor known within
[7/20, 9/20] and the diesel factor exact give the interval [620, 720], width 100. Negative control
to describe: part 1 fails for a negative amount (a = -1, lo = 0, f = 1, hi = 2: total at f is -1,
which is below the total 0 at lo).

The rationale must say that the bounds are inputs, that the interval is a worst case and not a
confidence interval, and that correlated errors between factors are not modelled.
