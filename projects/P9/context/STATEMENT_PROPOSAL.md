# Statement proposals for P9

Two statements, one Lean module each, about real numbers only, self-contained over Mathlib. Keep
every definition inside the statement's own namespace.

## P9.SoilTurnover

Definitions: step (k I C : ℝ) : ℝ := C + I - k * C, stock (k I : ℝ) (n : ℕ) (C : ℝ) : ℝ :=
(step k I)^[n] C, and steady (k I : ℝ) : ℝ := I / k.

Statement: a conjunction of four parts, each for all real k, I with 0 < k, k ≤ 1 and 0 ≤ I.

1. Steady state. step k I (steady k I) = steady k I.
2. Closed form. For every n and C: stock k I n C - steady k I = (1 - k) ^ n * (C - steady k I).
3. Monotone approach. For every n and C: |stock k I n C - steady k I| ≤ |C - steady k I|. If
   C ≤ steady k I then stock k I n C ≤ stock k I (n + 1) C and stock k I (n + 1) C ≤ steady k I.
4. Sensitivity. For every I' with I < I': steady k I < steady k I'. For every k' with k < k' and
   0 < I: steady k' I < steady k I.

Check the algebra before proposing: step k I C - I/k = (1 - k)·C + I - I/k and I - I/k =
-(1 - k)·I/k, so the difference is (1 - k)·(C - I/k). In part 3, 0 ≤ 1 - k < 1 gives the bound, and
stock (n + 1) - stock n = k·(I/k - stock n) ≥ 0 while the closed form keeps the sign of C - I/k.

Sanity checks to include: k = 1/2, I = 1 gives steady = 2; from C = 0 the stocks are 1 and 3/2 after
one and two years, and 1 - 2 = (1/2)·(0 - 2). Negative control to describe: part 3 fails for k = 2
(outside the range): from C = 0 with I = 1 the stocks are 1, then 0, so the approach is not
monotone.

The rationale must say that a single pool with constant input and rate is an assumed model, that I
and k are field inputs, and that the statement is about the yearly recursion, not a continuous-time
model.

## P9.EquivalentSoilMass

Definitions: stockFD (c ρ d : ℝ) : ℝ := c * ρ * d (fixed-depth stock: concentration × bulk
density × depth) and stockESM (c ρ0 d : ℝ) : ℝ := c * ρ0 * d (the same soil mass ρ0·d as the
baseline, at the new concentration).

Statement: a conjunction of three parts, each for all real c0, c1, ρ0, ρ1, d.

1. Exact overstatement. (stockFD c1 ρ1 d - stockFD c0 ρ0 d) - (stockESM c1 ρ0 d - stockESM c0 ρ0 d)
   = c1 * d * (ρ1 - ρ0).
2. Compaction overstates. If 0 < c1 and 0 < d, then the overstatement is positive ↔ ρ0 < ρ1, and
   it is zero ↔ ρ1 = ρ0.
3. Loosening understates. If 0 < c1, 0 < d and ρ1 < ρ0, the overstatement is negative.

Check the algebra before proposing: the two stockESM terms share ρ0·d, so the difference is
c1·ρ1·d - c1·ρ0·d.

Sanity checks to include: c0 = c1 = 2 (percent), ρ0 = 6/5, ρ1 = 3/2, d = 30 gives a fixed-depth
"gain" of 18 with no change in concentration, all of it overstatement. Negative control to
describe: part 2 fails without 0 < c1 (with c1 = 0 the overstatement is 0 whatever the densities).

The rationale must say that a uniform profile is assumed, that real profiles vary with depth, and
that the statement does not compute an equivalent-soil-mass correction for measured cores.
