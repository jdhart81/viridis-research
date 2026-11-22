# Statement proposals for P7

Two statements, one Lean module each, about real numbers only, self-contained over Mathlib. Keep
every definition inside the statement's own namespace.

## P7.HabitatThreshold

Definitions: growth (c e h p : ℝ) : ℝ := c * p * (h - p) - e * p, and
pstar (c e h : ℝ) : ℝ := h - e / c.

Statement: a conjunction of five parts, each for all real c, e, h with 0 < c and 0 < e.

1. Factorisation. For every p: growth c e h p = c * p * (pstar c e h - p).
2. Below the threshold. If h ≤ e / c, then for every p with 0 < p: growth c e h p < 0.
3. Above the threshold. If e / c < h, then 0 < pstar c e h, pstar c e h < h,
   growth c e h (pstar c e h) = 0, for every p with 0 < p and p < pstar c e h: 0 < growth c e h p,
   and for every p with pstar c e h < p: growth c e h p < 0.
4. Levins rule. e / c < h ↔ 1 - h < 1 - e / c. (1 − e/c is the equilibrium occupancy at h = 1, so
   the population persists exactly while the destroyed fraction 1 − h is below it.)
5. Monotone threshold. For every c' with c < c': e / c' < e / c. For every e' with e < e':
   e / c < e' / c.

Check the algebra before proposing: c·p·(h − p) − e·p = c·p·(h − e/c − p) because c ≠ 0. In part 2,
p* ≤ 0 < p gives p* − p < 0. In part 3, p > p* > 0 so c·p > 0.

Sanity checks to include: c = 2, e = 1, h = 1 gives pstar = 1/2 and growth at p = 1/4 equal to 1/8;
with h = 1/2 the growth at p = 1/4 is −1/8. Negative control to describe: without 0 < p, part 2 is
false (growth is 0 at p = 0).

The rationale must say that the statement is about the sign of the growth term, not about solutions
of dp/dt = growth, and that c, e and h are field inputs.

## P7.SpeciesArea

Use real powers (`Real.rpow`, written a ^ z for real a and z).

Statement: a conjunction of four parts, each for all real z with 0 < z and z ≤ 1.

1. Retained fraction bound. For every a with 0 ≤ a and a ≤ 1: a ≤ a ^ z and a ^ z ≤ 1.
2. Strict gain. If z < 1, then for every a with 0 < a and a < 1: a < a ^ z.
3. Monotone. For all a, b with 0 ≤ a and a ≤ b: a ^ z ≤ b ^ z.
4. Area needed. For every s with 0 ≤ s and s ≤ 1: (s ^ (1 / z)) ^ z = s and s ^ (1 / z) ≤ s.

Hints: `Real.rpow_le_rpow_of_exponent_ge`, `Real.rpow_lt_rpow_of_exponent_gt`,
`Real.rpow_le_rpow`, `Real.rpow_mul`, `Real.rpow_one`.

Sanity checks to include: z = 1/2, a = 1/4 gives a ^ z = 1/2; z = 1/2, s = 1/2 gives area fraction
1/4. Negative control to describe: part 1 fails for z > 1 (z = 2, a = 1/2: a ^ z = 1/4 < 1/2).

The rationale must say that S = k·A^z is assumed, that the constant k cancels in every part, and
that the statement says nothing about extinction debt, which species are lost, or any value of z.
