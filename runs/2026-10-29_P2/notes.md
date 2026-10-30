# P2-T001 lab notebook (2026-10-29)

## Summary
- Target: sealed `P2.CarbonContinuity` (statement sha256 a5a6e8c6...ffded, verified locally).
- Canon source `context/CarbonContinuity_canon.lean` sha256 899d3bb1...a77fc1, matches SOURCES.sha256.
- Ported canon `carbon_continuity_threshold_sufficient` / `_necessary` / `_iff` to the sealed
  definitions (`Sustainable`, `stepLiving`, `stepDurable`). Local `viridis-lean-check`: PASSED
  (preview), axioms propext, Classical.choice, Quot.sound. First attempt passed.

## Changes vs canon
- Witness `(L, D) = (r, 1 - a)` unchanged. Living step closed by `nlinarith` (it is an identity;
  canon used `le_of_eq (by ring)`).
- In necessity, the step from h3 to h4 uses `linarith` (linear after ring normalisation) instead of
  `nlinarith`.
- Dropped the hypotheses that are not needed: helper lemmas use only a < 1, d < 1 (necessity) and
  a < 1, r > 0 (sufficiency). `main` takes 0 ≤ a, 0 ≤ d, p > 0 and discards them. This is an
  observation about the proof, not a sealed claim.
- Canon corollaries (boundary stationarity, strict growth, nonvacuity) are not part of the sealed
  statement and were not ported. Sanity examples in the sealed module cover nonvacuity.

## Aristotle
- None used, so no project IDs. No prior runs, so nothing was pending.

## Open questions / next steps
- Multi-cycle persistence (iterating the map) is not in the sealed statement. The current
  theorem is about one cycle, but since the map is monotone on positive vectors, a non-shrinking
  vector stays non-shrinking under iteration. That could become a future sealed statement.
- Next task in P2 order: Restoration, then Afforestation (context/AfforestationStewardship.lean).
