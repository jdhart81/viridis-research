import Mathlib

/-!
# P2 · re-certification: Decision-information capacity (the conditional Intelligence Bound)

The live Viridis OS Decision-information capacity kernel caps the rate at which a decision
process can gain predictive information about a system by the smaller of a data ceiling
`ρ · B` and a thermodynamic ceiling `P / (kB · T · ln 2)`. Its formal backing is the conditional
Intelligence Bound of `P0_IntelligenceBound_COMPILED.lean` in the archived canon
(github.com/jdhart81/viridis-canon, commit 80d32904d751b45f415e23f872510cc2eddca3ff, sha256
3f192275ee326f0fb2cf2dca3b4d97146044b3b12fca28ff18e07914fb4d9130): the core theorem
`intelligence_bound` and its three parts `thermodynamic_bound_lemma`,
`landauer_dissipation_bound` and `data_bound_lemma_conditional`. This module restates those
four theorems over the same definitions, restricted to the definitions they need. Nothing is
imported from or copied wholesale out of the canon file.

Definitions (as in the canon, all values in `ENNReal`):
* `mutualInformation μ X Y = KL(P_{X,Y} ‖ P_X ⊗ P_Y)` and `shannonEntropy μ X = I(X; X)`;
* a `Process Ω State` is a map `Ω → ℝ≥0 → State`, and `trajectory X t` is its restriction to
  `[0, t]` (product σ-algebra on paths);
* `cumulativePredictiveInformation μ X O t τ = I(X_{[0, t+τ]}; O_{[0, t]})`;
* `intelligenceCreationRate = limsup_{t→∞} I_t(τ) / t`;
* `observationBandwidth = limsup_{t→∞} H(O_{[0,t]}) / t`;
* `predictiveRichness = limsup_{t→∞} I_t(τ) / H(O_{[0,t]})`;
* `SatisfiesLandauerLimit μ X O τ P T kB` is the predicate `P ≥ İ · kB T ln 2`.

**The Landauer limit is a hypothesis.** `SatisfiesLandauerLimit` (and, in part 3, the pair of
hypotheses `P ≥ erasureRate · kB T ln 2` and `erasureRate ≥ İ`) is assumed, never proved. This
module does not show that any physical system satisfies it. Without such a hypothesis tying the
rate to a system the bound is false (see the sealed `P5.UnrestrictedBoundFalse`).

`Statement` is the conjunction of:
1. (`intelligence_bound`, the core) for a probability measure, `kB, T > 0`, the Landauer
   hypothesis, finite bandwidth and `ρ ≤ 1`: `İ ≤ min (ρ · B) (P / (kB T ln 2))`;
2. (`thermodynamic_bound_lemma`) for `kB, T > 0` and the Landauer hypothesis:
   `İ ≤ P / (kB T ln 2)`;
3. (`landauer_dissipation_bound`) if `P ≥ erasureRate · kB T ln 2` and `erasureRate ≥ İ`, then
   `P ≥ İ · kB T ln 2`;
4. (`data_bound_lemma_conditional`) for a probability measure, finite bandwidth and finite
   richness: `İ ≤ ρ · B`.
-/

namespace ViridisStatements.P2.DecisionInformationCapacity

open MeasureTheory ProbabilityTheory InformationTheory Filter

/-- Mutual information `I(X; Y) = KL(P_{X,Y} ‖ P_X ⊗ P_Y)` under `μ` (canon
`mutualInformation`). -/
noncomputable def mutualInformation {Ω A B : Type*} [MeasurableSpace Ω] [MeasurableSpace A]
    [MeasurableSpace B] (μ : Measure Ω) (X : Ω → A) (Y : Ω → B) : ENNReal :=
  klDiv (μ.map (fun ω => (X ω, Y ω))) ((μ.map X).prod (μ.map Y))

/-- Shannon entropy as self-information, `H(X) = I(X; X)` (canon `shannonEntropy`). -/
noncomputable def shannonEntropy {Ω A : Type*} [MeasurableSpace Ω] [MeasurableSpace A]
    (μ : Measure Ω) (X : Ω → A) : ENNReal :=
  mutualInformation μ X X

/-- A stochastic process: sample point → time → state (canon `Process`). -/
def Process (Ω State : Type) : Type := Ω → NNReal → State

/-- The path of `X` on `[0, t]` (canon `trajectory`). Paths carry Mathlib's product
σ-algebra `MeasurableSpace.pi`, the instance the canon declares. -/
def trajectory {Ω State : Type} (X : Process Ω State) (t : NNReal) :
    Ω → (Set.Icc (0 : NNReal) t → State) :=
  fun ω => (fun (s : Set.Icc (0 : NNReal) t) => X ω s)

/-- Cumulative predictive information `I_t(τ) = I(X_{[0, t+τ]}; O_{[0, t]})` (canon
`cumulativePredictiveInformation`). -/
noncomputable def cumulativePredictiveInformation {Ω State : Type} [MeasurableSpace Ω]
    [MeasurableSpace State] (μ : Measure Ω) (X : Process Ω State)
    (O : Process Ω State) (t τ : NNReal) : ENNReal :=
  mutualInformation μ (trajectory X (t + τ)) (trajectory O t)

/-- Intelligence creation rate `İ(τ) = limsup_{t→∞} I_t(τ) / t` (canon
`intelligenceCreationRate`). -/
noncomputable def intelligenceCreationRate {Ω State : Type} [MeasurableSpace Ω]
    [MeasurableSpace State] (μ : Measure Ω) (X : Process Ω State)
    (O : Process Ω State) (τ : NNReal) : ENNReal :=
  Filter.limsup (fun t : NNReal =>
    cumulativePredictiveInformation μ X O t τ / t) Filter.atTop

/-- Observation entropy `H(O_{[0,t]})` (canon `observationEntropy`). -/
noncomputable def observationEntropy {Ω State : Type} [MeasurableSpace Ω]
    [MeasurableSpace State] (μ : Measure Ω) (O : Process Ω State)
    (t : NNReal) : ENNReal :=
  shannonEntropy μ (trajectory O t)

/-- Observation bandwidth `B = limsup_{t→∞} H(O_{[0,t]}) / t` (canon
`observationBandwidth`). -/
noncomputable def observationBandwidth {Ω State : Type} [MeasurableSpace Ω]
    [MeasurableSpace State] (μ : Measure Ω) (O : Process Ω State) : ENNReal :=
  Filter.limsup (fun t : NNReal => observationEntropy μ O t / t) Filter.atTop

/-- Predictive richness `ρ(τ) = limsup_{t→∞} I_t(τ) / H(O_{[0,t]})` (canon
`predictiveRichness`). -/
noncomputable def predictiveRichness {Ω State : Type} [MeasurableSpace Ω]
    [MeasurableSpace State] (μ : Measure Ω) (X : Process Ω State)
    (O : Process Ω State) (τ : NNReal) : ENNReal :=
  Filter.limsup (fun t : NNReal =>
    cumulativePredictiveInformation μ X O t τ /
    observationEntropy μ O t) Filter.atTop

/-- **Hypothesis, not a theorem.** The Landauer limit as a predicate on a process pair:
`P ≥ İ · kB · T · ln 2` (canon `SatisfiesLandauerLimit`). Nothing in this module proves it for
any physical system. -/
def SatisfiesLandauerLimit {Ω State : Type} [MeasurableSpace Ω]
    [MeasurableSpace State] (μ : Measure Ω) (X : Process Ω State)
    (O : Process Ω State) (τ : NNReal) (P T kB : NNReal) : Prop :=
  (P : ENNReal) ≥ intelligenceCreationRate μ X O τ *
    ENNReal.ofReal ((kB : ℝ) * (T : ℝ) * Real.log 2)

/-- Part 1, the core (canon `intelligence_bound`): under the Landauer hypothesis, finite
bandwidth and `ρ ≤ 1`, `İ ≤ min (ρ · B) (P / (kB T ln 2))`. -/
def CoreBound : Prop :=
  ∀ {Ω State : Type} [MeasurableSpace Ω] [MeasurableSpace State]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X : Process Ω State) (O : Process Ω State) (τ : NNReal) (P T kB : NNReal),
    0 < kB → 0 < T →
    SatisfiesLandauerLimit μ X O τ P T kB →
    observationBandwidth μ O ≠ ⊤ →
    predictiveRichness μ X O τ ≤ 1 →
    intelligenceCreationRate μ X O τ ≤
      min (predictiveRichness μ X O τ * observationBandwidth μ O)
        (ENNReal.ofReal ((P : ℝ) / ((kB : ℝ) * (T : ℝ) * Real.log 2)))

/-- Part 2 (canon `thermodynamic_bound_lemma`): under the Landauer hypothesis,
`İ ≤ P / (kB T ln 2)`. -/
def ThermodynamicBound : Prop :=
  ∀ {Ω State : Type} [MeasurableSpace Ω] [MeasurableSpace State]
    (μ : Measure Ω) (X : Process Ω State) (O : Process Ω State) (τ : NNReal)
    (P T kB : NNReal),
    0 < kB → 0 < T →
    SatisfiesLandauerLimit μ X O τ P T kB →
    intelligenceCreationRate μ X O τ ≤
      ENNReal.ofReal ((P : ℝ) / ((kB : ℝ) * (T : ℝ) * Real.log 2))

/-- Part 3 (canon `landauer_dissipation_bound`): a Landauer floor on an erasure rate that is at
least `İ` gives `P ≥ İ · kB T ln 2`. -/
def LandauerDissipationBound : Prop :=
  ∀ {Ω State : Type} [MeasurableSpace Ω] [MeasurableSpace State]
    (μ : Measure Ω) (X : Process Ω State) (Y : Process Ω State) (τ : NNReal)
    (P T kB : NNReal) (erasureRate : ENNReal),
    (P : ENNReal) ≥ erasureRate * ENNReal.ofReal ((kB : ℝ) * (T : ℝ) * Real.log 2) →
    erasureRate ≥ intelligenceCreationRate μ X Y τ →
    (P : ENNReal) ≥ intelligenceCreationRate μ X Y τ *
      ENNReal.ofReal ((kB : ℝ) * (T : ℝ) * Real.log 2)

/-- Part 4 (canon `data_bound_lemma_conditional`): with finite bandwidth and finite richness,
`İ ≤ ρ · B`. -/
def DataBound : Prop :=
  ∀ {Ω State : Type} [MeasurableSpace Ω] [MeasurableSpace State]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X : Process Ω State) (O : Process Ω State) (τ : NNReal),
    observationBandwidth μ O ≠ ⊤ →
    predictiveRichness μ X O τ ≠ ⊤ →
    intelligenceCreationRate μ X O τ ≤
      predictiveRichness μ X O τ * observationBandwidth μ O

/-- **Proposed sealed target `P2.DecisionInformationCapacity`.** The conditional Intelligence
Bound and its three parts, each with exactly the canon hypotheses; the Landauer limit enters
only as the hypothesis `SatisfiesLandauerLimit` (parts 1, 2) or as the explicit erasure-rate
floor (part 3). -/
def Statement : Prop :=
  CoreBound ∧ ThermodynamicBound ∧ LandauerDissipationBound ∧ DataBound

/-! ## Sanity checks

Witness: a constant process on a one-point sample space. Under the Dirac measure every mutual
information is `KL(δ ‖ δ ⊗ δ) = KL(δ ‖ δ) = 0`, so the rate, bandwidth and richness are all `0`,
and every hypothesis of the core is satisfiable at once (with `P = 0`). -/

/-- The constant process `X ω t = 0` on `Unit`. -/
def constProc : Process Unit ℕ := fun _ _ => 0

/-- A one-point mutual information is zero: `I(X; Y) = 0` for any `X Y` on `Unit` under `δ`. -/
example {A B : Type} [MeasurableSpace A] [MeasurableSpace B] [MeasurableSingletonClass A]
    [MeasurableSingletonClass B] (X : Unit → A) (Y : Unit → B) :
    mutualInformation (Measure.dirac ()) X Y = 0 := by
  unfold mutualInformation
  rw [Measure.map_dirac (measurable_of_finite _), Measure.map_dirac (measurable_of_finite _),
    Measure.map_dirac (measurable_of_finite _), Measure.dirac_prod_dirac]
  exact klDiv_self _

/-- In the witness the rate is `0`, so the Landauer hypothesis holds even at power `P = 0`. -/
example : intelligenceCreationRate (Measure.dirac ()) constProc constProc 1 = 0 ∧
    SatisfiesLandauerLimit (Measure.dirac ()) constProc constProc 1 0 1 1 := by
  have h0 : ∀ t : NNReal,
      cumulativePredictiveInformation (Measure.dirac ()) constProc constProc t 1 = 0 := by
    intro t
    unfold cumulativePredictiveInformation mutualInformation
    rw [Measure.map_dirac (measurable_of_finite _), Measure.map_dirac (measurable_of_finite _),
      Measure.map_dirac (measurable_of_finite _), Measure.dirac_prod_dirac]
    exact klDiv_self _
  have hr : intelligenceCreationRate (Measure.dirac ()) constProc constProc 1 = 0 := by
    unfold intelligenceCreationRate
    simp only [h0, ENNReal.zero_div]
    exact limsup_const 0
  refine ⟨hr, ?_⟩
  unfold SatisfiesLandauerLimit
  rw [hr, zero_mul]
  exact zero_le _

/-- The thermodynamic factor `kB T ln 2` at `kB = T = 1` is `ln 2`, which is positive, so the
thermodynamic ceiling `P / ln 2` is finite and positive for `P = 1`. -/
example : 0 < ENNReal.ofReal ((1 : ℝ) / ((1 : ℝ) * 1 * Real.log 2)) := by
  rw [ENNReal.ofReal_pos]
  have := Real.log_pos one_lt_two
  positivity

/-- The two ceilings in cleared form, by `decide` over `ℕ`: with `ρ · B = 3` bits per unit
time and thermodynamic ceiling `P / (kB T ln 2) = 12 / 4 = 3`, the bound is `min 3 3 = 3`; at
half the power it is `min 3 1 = 1` (power-limited). -/
example : min (1 * 3) (12 / 4) = (3 : ℕ) ∧ min (1 * 3) (6 / 4) = (1 : ℕ) := by
  decide

/-! ## Negative controls -/

/-- The hypothesis has content: at power `P = 0` with `kB, T > 0`, the Landauer hypothesis
forces the rate to be `0`. -/
example {Ω State : Type} [MeasurableSpace Ω] [MeasurableSpace State] (μ : Measure Ω)
    (X O : Process Ω State) (τ : NNReal)
    (h : SatisfiesLandauerLimit μ X O τ 0 1 1) :
    intelligenceCreationRate μ X O τ = 0 := by
  unfold SatisfiesLandauerLimit at h
  have hK : ENNReal.ofReal ((1 : NNReal) * ((1 : NNReal) : ℝ) * Real.log 2) ≠ 0 := by
    rw [ne_eq, ENNReal.ofReal_eq_zero, not_le]
    have := Real.log_pos one_lt_two
    simpa using this
  have h' : intelligenceCreationRate μ X O τ *
      ENNReal.ofReal (((1 : NNReal) : ℝ) * ((1 : NNReal) : ℝ) * Real.log 2) = 0 := by
    simpa using h
  exact (mul_eq_zero.mp h').resolve_right hK

/-- An infinite rate can never satisfy the Landauer hypothesis at finite power. -/
example (P : NNReal) : ¬ ((P : ENNReal) ≥ ⊤ * ENNReal.ofReal ((1 : ℝ) * 1 * Real.log 2)) := by
  have hK : ENNReal.ofReal ((1 : ℝ) * 1 * Real.log 2) ≠ 0 := by
    rw [ne_eq, ENNReal.ofReal_eq_zero, not_le]
    have := Real.log_pos one_lt_two
    simpa using this
  rw [ENNReal.top_mul hK]
  simp

/-- Without a hypothesis tying the rate to a system, the thermodynamic ceiling is false: the
rate `1` exceeds the ceiling `0 / (kB T ln 2) = 0` at power `0`. This is the unrestricted
reading that `P5.UnrestrictedBoundFalse` refutes. -/
example : ¬ (∀ rate : ENNReal,
    rate ≤ ENNReal.ofReal (((0 : NNReal) : ℝ) / ((1 : ℝ) * 1 * Real.log 2))) := by
  intro h
  have := h 1
  simp at this

end ViridisStatements.P2.DecisionInformationCapacity
