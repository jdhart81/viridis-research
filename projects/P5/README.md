# P5 · Intelligence Bound audit: compensation, ceilings and the unrestricted axiom

Two statements in early Viridis Lean sources say more in their names and comments than their
formal text supports. A review of the research corpus on 2026-11-11 found both by reading the
sources. Neither finding has been checked by the Lean kernel. P5 does that, in the open, and
replaces the prose with exact statements.

## Finding 1: a historical axiom is inconsistent

`Gaia_Intelligence_Theorem.lean` (January 2026, SHA-256 `37c017145dcf…2098c4`) declares:

```lean
axiom intelligence_bound :
  ∀ (dI_dt P D k_B T : ℝ),
  k_B > 0 → T > 0 → P ≥ 0 → D ≥ 0 → D ≤ 1 →
  dI_dt ≤ max_bit_rate P k_B T * D
```

The rate `dI_dt` is quantified over all real numbers with no condition tying it to a physical
system. Take `dI_dt = 1`, `P = 0`, `D = 0`, `k_B = T = 1`: every guard holds and the conclusion
is `1 ≤ 0`. So the axiom as written is false, and a Lean environment that assumes it is
inconsistent. No declaration in that file uses the axiom and no other file in the corpus imports
it. This concerns that exact text. It is not a statement about the Intelligence Bound as a
physical conjecture, which needs a model of the system whose rate is being bounded.

## Finding 2: `no_finite_compensation` proves that finite compensation exists

`Non_Substitutability_Complete.lean` (SHA-256 `8b1194634…bee273`) introduces this theorem with
the words "there is no finite power increase ΔP that can fully compensate". Its formal text is:

```lean
theorem no_finite_compensation (c : PhysicalConstants)
    {P D ΔD : ℝ} (hP : P > 0) (hD : D > 0) (hΔD : ΔD > 0) (hΔD' : ΔD < D) :
    let required_ΔP := P * ΔD / (D - ΔD)
    intelligence_bound c (P + required_ΔP) (D - ΔD) = intelligence_bound c P D
```

It says that the finite increase `P·ΔD/(D − ΔD)` restores the bound exactly. Three different
facts are mixed in the surrounding prose, and P5 keeps them apart:

1. **Interior.** After a partial loss `0 < ΔD < D`, a finite power restores the capacity.
2. **Divergence.** The power needed grows without limit as the loss approaches the whole of `D`.
3. **Complete loss.** At `D = 0` no power restores a positive capacity.

What actually limits compensation in the interior is a **power ceiling**: with at most `P_max`
available, the capacity can be restored exactly when `ΔD ≤ D·(1 − P/P_max)`.

## What P5 will and will not establish

P5 seals and proves two statements about the capacity algebra `cap = P·D/C`. They are elementary;
they are corrections, not new theorems.

They do **not** show that any agent will preserve biodiversity. A capacity upper bound does not
say that the bound is attained, that more capacity serves the agent's goal, that biodiversity is
the only source of the relevant information, or that preservation is the best action once costs
and alternatives are counted. Those need an explicit decision model and evidence, and are not
part of this project.

## Tasks

- **P5-T001** proposes the two statements. Each is sealed only by Justin's decision.
- **P5-T002** proves `P5.UnrestrictedBoundFalse`.
- **P5-T003** proves `P5.CompensationUnderCeiling`.

The source files are quoted, not copied; their hashes identify the exact versions reviewed.
