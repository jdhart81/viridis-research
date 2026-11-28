# Extension statement for P12 (rung: extension)

Queued behind P12.StoichiometricCeiling and P12.PoolStoichiometry. Proposed by P12-T004 only after
both are PROVEN.

## P12.DeliveryNetBenefit

A delivery adds nitrogen D ≥ 0 to a stand, of which the fraction ρ ∈ [0, 1] is retained in new
biomass; delivering it emits e ≥ 0 carbon per unit of nitrogen delivered (in the same carbon units).
Use the gain function of P12.StoichiometricCeiling, restated self-contained.

Statement: for 0 < r, 0 ≤ N, 0 ≤ Cpot, 0 ≤ D, 0 ≤ ρ ≤ 1 and 0 ≤ e, with
net := gain r (N + ρ * D) Cpot - gain r N Cpot - e * D:

1. Ceiling. net ≤ (r * ρ - e) * D.
2. Nitrogen-limited case. If r * (N + ρ * D) ≤ Cpot then net = (r * ρ - e) * D, so with 0 < D the
   benefit is positive exactly when e < r * ρ.
3. Saturated case. If Cpot ≤ r * N then net = - e * D: delivery to a stand that is not
   nitrogen-limited only emits.

Check before proposing: parts 1 to 3 follow from parts 2 to 4 of P12.StoichiometricCeiling with
d = ρ·D.

Sanity check: r = 30, ρ = 1/2, e = 3, N = 2, Cpot = 100, D = 2 gives net = 30 - 6 = 24 =
(15 - 3)·2. Negative control: with ρ = 0 (nothing retained) the net is -e·D whatever r is.

The rationale must say that retention, the C:N ratio and the delivery emission factor are field
inputs, and that no aircraft, delivery or carbon outcome is certified. Cite project P10 for how the
delivery emissions would be accounted.
