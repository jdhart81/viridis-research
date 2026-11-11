# Statement proposals for P5

Two statements, one Lean module each. Both are about real numbers only. Keep every definition inside
the statement's own namespace, so the statement does not depend on any historical module.

## P5.UnrestrictedBoundFalse

Mirror the two historical definitions exactly:

    landauerEnergy (kB T : R) : R := kB * T * Real.log 2
    maxBitRate (P kB T : R) : R := P / landauerEnergy kB T

Statement: the unrestricted bound is false.

    not (forall dIdt P D kB T : R,
          kB > 0 -> T > 0 -> P >= 0 -> D >= 0 -> D <= 1 ->
          dIdt <= maxBitRate P kB T * D)

Witness for the proof (not part of the statement): dIdt = 1, P = 0, D = 0, kB = T = 1.

Sanity checks to include in the module: maxBitRate 0 1 1 = 0. Negative control to describe in the
rationale: with the extra hypothesis dIdt <= maxBitRate P kB T * D the implication is trivially
true, which shows that the missing ingredient is a condition tying the rate to a system.

## P5.CompensationUnderCeiling

Definition: cap (P D C : R) : R := P * D / C.

Statement: a conjunction of four parts, each for all real P, D, dD, C with 0 < C, 0 < P,
0 < dD and dD < D (so D - dD > 0).

1. Interior compensation exists and is unique.
   cap (P * D / (D - dD)) (D - dD) C = cap P D C, and for every P',
   cap P' (D - dD) C = cap P D C implies P' = P * D / (D - dD).
2. Ceiling. For every Pmax with P <= Pmax:
   (exists P', P' <= Pmax and cap P' (D - dD) C = cap P D C)  iff  dD <= D * (1 - P / Pmax).
3. Divergence. For 0 < C, 0 < P, 0 < D: for every M there is delta > 0 such that for every dD with
   D - delta < dD and dD < D, the compensating power P * D / (D - dD) exceeds M.
4. Complete loss. For 0 < C, 0 < P, 0 < D and every P': cap P' 0 C = 0 and cap P' 0 C < cap P D C.

Check the algebra of part 2 before proposing: the compensating power is P' = P * D / (D - dD), and
P' <= Pmax is equivalent to P * D <= Pmax * (D - dD), that is dD <= D - P * D / Pmax.

Sanity checks to include: P = D = C = 1, dD = 1/2 needs P' = 2; with Pmax = 2 the ceiling condition
holds with equality (1/2 <= 1 * (1 - 1/2)); with Pmax = 3/2 it fails. Negative control to describe:
dropping P <= Pmax or dD < D from part 2 makes it false; give the counterexample.
