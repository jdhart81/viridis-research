# P7-T001 lab notebook (2026-11-27)

Task: propose sealed statements P7.HabitatThreshold and P7.SpeciesArea.
Prior runs: none. Aristotle: no projects pending from prior runs, and none submitted tonight.
This is a proposal task and no proof is claimed.

## Frontier duty: test plan for M-Nucleation (not proposed)

No plan was registered. Reasons:
- The premise is a functional form for an unobservable establishment free energy,
  G = -dmu*n + a*sigma*n^(2/3). Its testable consequence is a critical cluster size: planted
  clusters below n* shrink, and those above it grow.
- The best public outcome data we found (not opened, only metadata viewed) is Zahawi, Holl,
  Cole and Reid 2013, J. Appl. Ecol. 50:88-96, doi:10.1111/1365-2664.12014, Zenodo record
  4731126 (files species_list_2014.csv, tree_recruits-2007-2013.csv and a ReadMe; the Dryad
  mirror doi:10.7291/D11681 was refused by the proxy). It records **natural recruits** per
  island and plot for three planted island sizes (4x4, 8x8, 12x12 m). It does not record
  whether planted clusters grew or shrank. A rise in recruit density with island size fits many
  mechanisms (perch attraction, shading, edge effects), so no outcome there could contradict the
  nucleation form specifically. A plan built on it could not come out CONTRADICTED for the right
  reason.
- Writing analysis code against an unopened file schema would also risk NOT_ESTIMABLE by
  construction.
- What would decide it: a dataset of planted cluster canopy area or tree count over time,
  covering initial sizes that span the predicted n*, with a test of whether the sign of size
  change switches at a single threshold. A candidate source to check next session is the Holl
  lab's 16-18 yr follow-up (Dryad doi:10.5061/dryad.s7h44j1gc). We have not yet confirmed it
  measures island expansion or contraction.

## Main task: what was done

1. Read README.md and STATEMENT_PROPOSAL.md. Wrote both modules exactly to the spec.
   - HabitatThreshold: defs `growth` and `pstar` in the namespace, with a five-part
     conjunction, each part for all c e h with 0 < c and 0 < e.
   - SpeciesArea: a four-part conjunction over rpow, with `a ^ z` written inline (an earlier
     draft used wrapper defs keptSpecies/areaNeeded; we removed them to match the spec
     literally).
2. Checked the "check before proposing" notes by hand (written out in each .md).
3. Truth check: wrote scratch proofs of both exact Statement texts in /tmp (outside out/, not
   claimed). Both compiled. Lessons for the proof tasks:
   - `Real.rpow_le_rpow_of_exponent_ge` needs `0 < x` in the pinned Mathlib; use the primed
     `Real.rpow_le_rpow_of_exponent_ge'` (0 <= x, 0 <= z) to cover a = 0 and s = 0.
   - HabitatThreshold part 1: `unfold growth pstar; field_simp; ring`. Parts 2/3: rewrite
     with the factorisation, then `nlinarith`/`positivity` with `mul_pos hc hp`. Part 5:
     `div_lt_div_of_pos_left he hc hc'` and `div_lt_div_of_pos_right he' hc`.
4. Probe check: `norm_num`, `simp`, `aesop`, `decide`, `grind`, `positivity` and `linarith`
   (after `unfold Statement`) each FAIL on both statements, so both are non-trivial targets.
5. Sanity checks: `decide` cannot evaluate reals or rpow, so examples use `norm_num` (plus
   `Real.rpow_mul` and `Real.rpow_natCast`). Witnesses and negative controls are as specified.
   We added one extra control: e = 0 breaks the strict monotonicity in part 5.
6. References verified via Crossref. A first guess at Lande 1987's DOI was wrong
   (10.1086/284749 is Kingsolver 1987). We corrected it to 10.1086/284734.

## Open questions
- HabitatThreshold does not require p <= 1 or h <= 1. The algebra does not need them, so we
  left them out. Justin may prefer them for interpretability; adding them would only weaken
  the statement.
- SpeciesArea part 3 carries `z <= 1` although monotonicity holds for any z >= 0. It is kept
  for uniformity with the spec.

## Next steps
- After sealing: P7-T002 and P7-T003 (sketches above and in run.json next_steps).
- Frontier duty for M-Nucleation: look for cluster-size time-series data.
