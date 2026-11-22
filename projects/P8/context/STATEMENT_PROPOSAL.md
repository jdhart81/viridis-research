# Statement proposals for P8

Two statements, one Lean module each, about real numbers only, self-contained over Mathlib. Keep
every definition inside the statement's own namespace.

## P8.LandEquivalentRatio

`s` is a `Finset ι` of components; M Y : ι → ℝ.
Definition: ler (s) (M Y) : ℝ := ∑ i ∈ s, Y i / M i.

Statement: a conjunction of four parts, each assuming 0 < M i and 0 ≤ Y i for all i ∈ s.

1. Least matching land. For every a : ι → ℝ with Y i ≤ a i * M i for all i ∈ s:
   ler s M Y ≤ ∑ i ∈ s, a i. And the allocation a i := Y i / M i satisfies Y i ≤ a i * M i for all
   i ∈ s with ∑ i ∈ s, a i = ler s M Y.
2. Mosaic null. For every w : ι → ℝ with ∑ i ∈ s, w i = 1: if Y i = w i * M i for all i ∈ s, then
   ler s M Y = 1.
3. Land saving. If 1 < ler s M Y, then 0 < 1 - 1 / ler s M Y, 1 - 1 / ler s M Y < 1, and
   1 - 1 / ler s M Y = (ler s M Y - 1) / ler s M Y.
4. Ceiling. If Y i ≤ M i for all i ∈ s, then ler s M Y ≤ s.card.

Check before proposing: in part 1, Y i ≤ a i * M i with M i > 0 gives Y i / M i ≤ a i, and summing
gives the bound (a i ≥ 0 is not needed). In part 2, Y i / M i = w i because M i ≠ 0.

Sanity checks to include: two components with M = (4, 2) and Y = (3, 1) give LER = 3/4 + 1/2 = 5/4
and a land saving of 1/5. Negative control to describe: part 2 needs ∑ w i = 1; with Y = M on two
components (w = (1, 1)) the LER is 2.

The rationale must say that LER compares land only, with yields as field inputs measured under the
same management, and that LER > 1 does not say the mixture is more valuable.

## P8.LightBudget

Definitions, for real kt Lt kc Lc:
tau := Real.exp (-(kt * Lt)), sigma := Real.exp (-(kc * Lc)),
treeI := 1 - tau, cropUnder := tau * (1 - sigma), cropAlone := 1 - sigma,
total := treeI + cropUnder.

Statement: a conjunction of four parts, each for all real kt, Lt, kc, Lc with 0 ≤ kt, 0 ≤ Lt,
0 ≤ kc, 0 ≤ Lc.

1. Budget identity. total = 1 - Real.exp (-(kt * Lt + kc * Lc)).
2. Bounds. 0 ≤ treeI, 0 ≤ cropUnder, total < 1, treeI ≤ total and cropAlone ≤ total.
3. Shading. cropUnder = tau * cropAlone and cropUnder ≤ cropAlone.
4. More tree leaf area. For every Lt' with Lt ≤ Lt': the crop's interception with Lt' is at most its
   interception with Lt, and the total with Lt' is at least the total with Lt.

Check the algebra before proposing: (1 − τ) + τ(1 − σ) = 1 − τσ and τσ = exp(−(kt·Lt + kc·Lc)).
cropAlone ≤ total because 1 − σ ≤ 1 − τσ when 0 < τ ≤ 1 and σ > 0.

Hints: `Real.exp_add`, `Real.exp_pos`, `Real.exp_le_one_iff`, `Real.exp_le_exp`.

Sanity check to include: kt * Lt = 0 gives tau = 1, treeI = 0 and cropUnder = cropAlone. Negative
control to describe: with a negative kt the bound treeI ≥ 0 fails.

The rationale must say that the two layers are assumed horizontally uniform with the trees wholly
above the crop, that Beer–Lambert interception is assumed, and that k and L are field inputs.
