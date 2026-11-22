# P2-T006 lab notebook (2026-11-22): propose P2.DecisionInformationCapacity and P2.MultiRingAlignment

## Start (07:30 UTC)
- Read inputs/context/README.md, MRAB.lean, P0_IntelligenceBound_COMPILED.lean, SOURCES.sha256.
- `projects/P5/README.md` named in the brief is not in the sandbox; used the sealed P5 statements
  (inputs/statements/P5.UnrestrictedBoundFalse.lean, P5.CompensationUnderCeiling.lean) as the record of the P5 finding.
- inputs/context/STATEMENT_PROPOSAL.md still absent (as in prior runs).
- Prior runs: no Aristotle projects pending.
- Paper copied from runs/2026-11-21_P2.

## Drafting (07:32-07:40 UTC)
- out/proposals/P2.MultiRingAlignment.lean: five canon defs restated verbatim (kappa, Dbar, alignFactor,
  baseRate, mrabBound); Statement = conjunction of the four canon theorems with canon hypotheses.
  Compiles. Failure on the way: `decide` over ℚ does not reduce (Rat normalisation is well-founded
  recursion), so decide-checks use cleared denominators over ℕ; real-valued checks use norm_num.
- out/proposals/P2.DecisionInformationCapacity.lean: restated only the defs the four theorems need
  (mutualInformation, shannonEntropy, Process, trajectory, cumulativePredictiveInformation,
  intelligenceCreationRate, observationEntropy, observationBandwidth, predictiveRichness,
  SatisfiesLandauerLimit). Dropped: BoundedMemory, phase-transition defs, scenario defs, hypotheses
  predicates (not needed). The canon's explicit `instance ... := MeasurableSpace.pi` on path space is
  not redeclared: Mathlib's `MeasurableSpace.pi` instance is found automatically and is the same term.
  Failure: `ℝ≥0∞` notation needs `open scoped ENNReal`; switched to `ENNReal`.
- Private feasibility (in /tmp, NOT submitted, NOT a claim): ports of canon proofs onto the restated defs
  compile for both Statements under the pinned toolchain. Canon proof of `eventually_finite_entropy`
  broke under the new Mathlib (simp_all shape changed); rewrote via `Filter.le_limsup_of_frequently_le`.
  `ENNReal.limsup_mul_le'` argument order differs from what the canon's `apply_rules` found; fine.
- Witness example: constant process on Unit under Dirac measure has rate 0 (map_dirac, dirac_prod_dirac,
  klDiv_self), so all core hypotheses hold at P = 0.

## Probes (07:40-07:45 UTC)
- Harness: append `example : Statement := by unfold Statement; <tac>` to a copy of each module (in /tmp), compile.
  19 tactics: rfl, decide, simp, norm_num, aesop, linarith, nlinarith, positivity, grind, tauto, omega, simp_all,
  trivial, exact?, norm_num [defs], simp_all [defs], grind [defs], constructor <;> aesop,
  refine ⟨?_,?_,?_,?_⟩ <;> simp_all [defs].
- P2.MultiRingAlignment: 0/19 closed (the four-way split + simp_all closes parts 3 and 4 but not 1, 2).
- P2.DecisionInformationCapacity: 0/19 closed. Logs inspected: genuine unsolved-goal failures, not import errors.

## Findings
- MRAB docstring overreach: "adding rings can only shrink the joint budget" is not what mrab_bound_le_baseRate says
  (it compares at the same K); counterexample is a module example (D=(1/4) -> (1/4,1), c all 1).
- IB units: klDiv is natural-log, so rates are nats; Landauer factor kB T ln 2 is per bit.
- IB entropy-as-self-information is ⊤ for atomless real laws (diagonal argument; not formalised).
- All eight canon theorems restated faithfully; no nearest-faithful substitute needed.

## Paper
- Retitled; new abstract; intro + background paragraphs; new Section "The Intelligence Bound kernels: two
  proposals (P2-T006)"; results bullets; table rows; IB scope paragraph; limitations; reproducibility; changelog.
- New refs, both confirmed via WebSearch: Landauer 1961 (10.1147/rd.53.0183), Cover & Thomas 2006 (10.1002/047174882X).
- latexmk -pdf builds (outdir /tmp/ptex) with no errors or undefined refs; a few inherited overfull boxes remain.

## Aristotle
- Not used. No project IDs. Nothing pending.

## Next steps
- See run.json next_steps: proof tasks after sealing; flag the two documentation points to Justin; T007/T008.
