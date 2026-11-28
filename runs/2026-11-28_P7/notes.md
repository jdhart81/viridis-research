# P7-T002 lab notebook (2026-11-28)

Task: prove sealed statement P7.HabitatThreshold (sha256 378845bc...1e8, sealed by D-027).
Prior runs: 2026-11-27_P7 (P7-T001, proposals only). Aristotle: no projects pending from prior
runs; none submitted tonight (not needed).

## Main task
- Wrote out/proofs/P7.HabitatThreshold.lean following the sketch from P7-T001 next_steps.
  Helper lemmas: growth_factor (unfold; field_simp; ring), below, above (rewrite with the
  factorisation, then mul_pos / mul_neg_of_pos_of_neg with linarith side goals). Part 4 by
  linarith both ways. Part 5 by div_lt_div_of_pos_left and div_lt_div_of_pos_right.
- `viridis-lean-check out/proofs/P7.HabitatThreshold.lean P7.HabitatThreshold`:
  PASSED (preview), axioms Classical.choice, Quot.sound, propext. Passed on first attempt.
- Observation: hypothesis `0 < e` is used only in part 3 (to get p* < h) and part 5.
  Parts 1, 2 and 4 need only `0 < c` (part 4 needs neither).

## Frontier duty: M-Nucleation
No test plan proposed tonight. What we checked (metadata and search snippets only; no data file
was opened):
- Dryad doi:10.5061/dryad.s7h44j1gc (the candidate flagged by P7-T001). The proxy refused the
  page. Per the search snippet it is tree richness and recruitment 16-18 yr after restoration,
  sampled once (Jun-Jul 2022) at Las Cruces. It has no time series of island size.
- Dryad doi:10.5061/dryad.cfxpnvxjp (same Costa Rica experiment). Its snippet lists
  canopy_cover.csv and says the nuclei spread beyond the planted area. The data are canopy cover
  at sampling points, not the area of each island over time. The planted islands come in only
  three sizes (4x4, 8x8, 12x12 m), and the snippet suggests all of them expanded. That is
  consistent with M-Nucleation for any n* below the smallest island, so it cannot come out
  CONTRADICTED on the premise's main content (a sign switch at one critical size). Dryad is
  also refused by the proxy, so the URL may not be fetchable by the verifier.
- Zenodo 4974518 (Corbin, Robinson, Hafkemeyer, Handel; New Jersey landfill). All 16 planted
  plots are 10x10 m, resampled once in 2010-11. There is no spread of initial sizes, so it
  cannot locate a threshold.
Why no plan: the premise fixes the functional form of an unobservable free energy, and its
testable content is a single sign change in cluster growth at n*. A deciding dataset needs
cluster size (tree count or canopy area) at two or more times, across initial sizes that
bracket the claimed n*. We found none we could name with a fetchable URL and a known schema.
Next lead: published LiDAR or drone canopy work on the Costa Rica islands (Zahawi et al.), and
any Zenodo mirror of it, which may give the area of each island over time.

## Open questions
- Should a later statement add p <= 1, h <= 1? Not needed for the algebra.
- Next mathematical step, if wanted: a statement about solutions (logistic ODE
  dp/dt = c p (p* - p) has the closed form solution; convergence to max(p*,0)). That would need
  a new sealed statement and is out of scope for P7-T002.

## Next steps
- P7-T003: prove P7.SpeciesArea (hints in prior run.json next_steps).
