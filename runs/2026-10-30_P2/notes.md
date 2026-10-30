# P2-T002 lab notebook (2026-10-30)

## Start
- Task: propose sealed statements P2.Restoration, P2.Afforestation, P2.Harmonization.
- Canon sources hashed; all four match context/SOURCES.sha256.
- `context/STATEMENT_PROPOSAL.md` (mentioned in the prompt) is NOT present in inputs/context.
  Proceeded from the task brief and the format of the sealed P2.CarbonContinuity module.
- Prior run 2026-10-29_P2: no Aristotle projects, nothing pending.

## What was produced
- `proposals/P2.Restoration.{lean,md}`: restates `critical_nucleus` ∧ `barrier_half_identity`
  (ForestNucleation.lean, sha256 667a826a...ec28132). Definitions rStar, G verbatim.
- `proposals/P2.Afforestation.{lean,md}`: restates
  `establishment_efficiency_cubic_in_drive_over_tension` ∧ `seeding_efficiency_eq_cos2_theta`
  (AfforestationStewardship.lean, sha256 3ebe33bf...9526f). Definitions eff, nStar verbatim,
  plus abbreviation `eta` (unfolds to the canon expression). Universe-polymorphic (`Type*`), as canon.
- `proposals/P2.Harmonization.{lean,md}`: restates `ght_market_clears` ∧
  `ght_strong_duality_decentralized_eq_centralized` (GaianHarmonization.lean, sha256
  cfdead65...110aec). Definitions br, J, lamStar, xStar verbatim; `g` omitted (unused).
- Each `Statement` is a conjunction; each conjunct keeps exactly its canon theorem's hypotheses.
- Sanity examples via norm_num/simp (decide is not applicable over ℝ), with negative controls.

## Checks done
- All three compile with `lean` (pinned toolchain). Engine denylist (`source_violations`) clean.
- Local probe: built oleans in scratch, ran 28 one-shot tactics after `(try unfold Statement)`
  (rfl trivial decide simp simp_all norm_num aesop tauto omega linarith nlinarith positivity grind
  ring field_simp ring_nf norm_cast assumption contradiction constructor infer_instance
  exact_mod_cast intro intros bound gcongr split_ands polyrith). None closed any proposal.
  Gotcha: the local olean dir must be PREPENDED to LEAN_PATH, else
  /opt/viridis/sealed-olean shadows the ViridisStatements package root.
- Universe-polymorphism test: `theorem main : Statement` with `Statement.{u_1}` elaborates and
  generalises the universe; the verifier template `theorem viridis_statement_match : Statement :=
  Candidate.main` therefore should work too (tested the analogous pattern locally).
- Private feasibility: ported canon proofs close all three proposals; axioms
  [propext, Classical.choice, Quot.sound]. NOT claimed as proofs. Sketches for the proof tasks:
  - Restoration: key identity `G rStar - G r = Δμ*(r-rStar)^2*(r+rStar/2)` by
    `unfold G rStar; field_simp; ring`; max by nlinarith on that; uniqueness by mul_eq_zero cases;
    half identity `unfold G rStar; field_simp; ring`.
  - Afforestation: part 1 `unfold eff; ring`; part 2 `unfold eta; refine ⟨by positivity, ?_⟩;
    exact div_le_one_of_le₀ (by nlinarith [abs_le.mp (abs_real_inner_le_norm n m)]) (by positivity)`.
  - Harmonization: clearing: rewrite `x / S / a i = x / S * (1 / a i)`, `simp only
    [Finset.sum_sub_distrib, this, ← Finset.mul_sum]; field_simp; ring` using S ≠ 0 from
    Finset.sum_pos. Duality: equimarginal `a i * (xStar i - b i) = -lamStar` by
    `field_simp [(ha i).ne']; ring`; pointwise tangent inequality by nlinarith; sum with
    Finset.sum_le_sum, then rewrite Σ(y - xStar) = X - X = 0.

## Findings / open questions for Justin
- Canon `seeding_efficiency_eq_cos2_theta` proves only 0 ≤ η ≤ 1; docstring's "η = 1 iff parallel"
  and "1-η = sin²Θ" are NOT proved. Proposal restates the bound only. If the kernel relies on
  the equality case, that needs a new statement.
- Hypotheses kept for faithfulness although unnecessary in Lean: half identity at Δμ = 0;
  all positivity hypotheses of the cubic law; n, m ≠ 0 in the alignment bound.
- Seal Afforestation polymorphic (faithful) or at `Type` (mild weakening)? Proposed polymorphic.
- `context/STATEMENT_PROPOSAL.md` referenced by the prompt is missing from inputs.
- Kernel runtime IDs / TypeScript sources for these three kernels were not in inputs; rationale
  describes the decisions from canon text and brief only.
- `broadcast_suboptimal` (Restoration file) not included; candidate future statement.

## Aristotle
- None used tonight; no project IDs. Nothing pending from prior runs.

## Next steps
- After sealing: proof tasks for P2.Restoration / Afforestation / Harmonization using sketches above.
