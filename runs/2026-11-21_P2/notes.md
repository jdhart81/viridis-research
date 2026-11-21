# P2-T015 lab notebook (2026-11-21): prove sealed P2.Tempo

## Start
- Sealed statement inputs/statements/P2.Tempo.lean read. Prior runs: no Aristotle projects pending.
- Paper copied from runs/2026-11-20_P2 and extended.
- Sealed module sha256 a966ef3b...2179 verified against task prompt. inputs/context/STATEMENT_PROPOSAL.md still absent.

## Proof (out/proofs/P2.Tempo.lean, 127 lines)
- Strategy (from the T014 scratch derivation): substitute h = s^2, n = r^2 with s = sqrt h, r = sqrt n.
  Lemmas: optimum_sq (sqrt(s^2/r^2) = s/r via Real.sqrt_div', Real.sqrt_sq), floor_sq (2 sqrt(s^2 r^2) = 2sr),
  gap (Sigma t - floor = (s - r t)^2/t), norm_eq_cosh (both cosh orientations via Real.cosh_log + field_simp),
  core (all six parts for s^2, r^2), main (rewrite h = sqrt h ^ 2, n = sqrt n ^ 2 back).
- Part (1): directly from StrictConvexOn definition; subst b = 1 - a; reduce to harmonic part; key identity
  (a h/x + b h/y)(a x + b y) = h + h a b (x-y)^2/(xy).
- Part (6) iff: via tax = normalizedCost and parts (3)/(4) rather than cosh injectivity.
- Failures on the way: (a) `Sigma` ambiguous with _root_.Sigma after `open` -> fully qualified;
  (b) field_simp closed one cosh goal so `ring` errored "No goals" -> `try ring`.
- viridis-lean-check out/proofs/P2.Tempo.lean P2.Tempo: PASSED, axioms Classical.choice, Quot.sound, propext.

## Aristotle
- Not used; no project IDs. Nothing pending from prior runs.

## Paper
- Retitled as the Tempo re-certification note; new abstract (contains the required scope sentence, the retired
  Comparator receipt with no source on file, and that the cost model and coefficients are user-declared inputs).
- New section sec:tempoproof (theorem, structure, key lemmas in listings, process); status table, results, Tempo
  scope paragraph (declared inputs, stewardship outcomes, retired receipt), reproducibility, changelog updated.
- latexmk -pdf builds in /tmp/ptex with no errors or undefined references.

## Open questions / next steps
- Byte-level copy of the deposited StewardshipTempo.lean still not obtained (see T014 notes).
- Unit inconsistency of h, n in registry still to flag.
