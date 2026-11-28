# Extension statement for P9 (rung: extension)

Queued behind P9.SoilTurnover and P9.EquivalentSoilMass. Proposed by P9-T004 only after both are
PROVEN.

## P9.Reversal

Use the one-pool step of P9.SoilTurnover, restated self-contained. A practice raises the input from
I0 to I1 for m years, starting from the old steady state I0/k, and then the input returns to I0.

Statement: for 0 < k ≤ 1, 0 ≤ I0 ≤ I1 and all m, n:

1. Gain while the practice lasts: stock after m years - I0/k = (1 - (1 - k)^m)·(I1 - I0)/k.
2. Gain n years after it ends: (1 - k)^n·(1 - (1 - k)^m)·(I1 - I0)/k.
3. The remaining gain is non-negative, never above the gain at the end of the practice, and tends
   to 0 as n grows when k < 1 (state the limit with `Filter.Tendsto`); for k = 1 it is 0 after one
   year.

Check before proposing: part 1 is the closed form of P9.SoilTurnover with input I1 started at I0/k
(gap I0/k - I1/k); part 2 is the closed form with input I0 started from the part 1 stock.

Sanity check: k = 1/2, I0 = 1, I1 = 2, m = 2 gives a gain of 3/2 at the end of the practice and
3/4 one year later. Negative control: with I1 < I0 the "gain" is negative, so part 3's sign claim
needs I0 ≤ I1.

The rationale must say that this is the model's answer to the permanence question and certifies no
permanence period, buffer pool or credit.
