import Mathlib

/-!
# P5 · The unrestricted Intelligence Bound postulate is false as written

`Gaia_Intelligence_Theorem.lean` (January 2026, SHA-256 `37c017145dcf…2098c4`) declares a
postulate `intelligence_bound` quantifying the rate `dI_dt` over *all* reals, with no hypothesis
tying it to any system. This module restates the two historical definitions over Mathlib only
(same algebra, nothing imported or copied from the historical file) and states that the
universally quantified bound is false.

Definitions (mirroring the historical ones):
* `landauerEnergy kB T = kB · T · log 2`;
* `maxBitRate P kB T = P / landauerEnergy kB T`.

`Statement`: it is not the case that for all reals `dIdt P D kB T` with
`kB > 0`, `T > 0`, `P ≥ 0`, `0 ≤ D ≤ 1` we have `dIdt ≤ maxBitRate P kB T · D`.

A witness (not part of the statement) is `dIdt = 1`, `P = 0`, `D = 0`, `kB = T = 1`.

The statement concerns that exact formal text. It says nothing about the Intelligence Bound as a
physical conjecture, which needs a model of the system whose rate is bounded, and nothing about
whether any agent preserves biodiversity.
-/

noncomputable section

namespace ViridisStatements.P5.UnrestrictedBoundFalse

/-- Landauer energy per bit, `kB · T · ln 2` (mirrors the historical `landauer_energy`). -/
def landauerEnergy (kB T : ℝ) : ℝ := kB * T * Real.log 2

/-- Maximal bit rate at power `P`, `P / (kB · T · ln 2)` (mirrors the historical
`max_bit_rate`). -/
def maxBitRate (P kB T : ℝ) : ℝ := P / landauerEnergy kB T

/-- **Proposed sealed target `P5.UnrestrictedBoundFalse`.** The historical postulate, with the rate
quantified over all reals, is false. -/
def Statement : Prop :=
  ¬ (∀ dIdt P D kB T : ℝ,
      kB > 0 → T > 0 → P ≥ 0 → D ≥ 0 → D ≤ 1 →
      dIdt ≤ maxBitRate P kB T * D)

/-! ## Sanity checks -/

/-- At zero power the maximal bit rate is zero. -/
example : maxBitRate 0 1 1 = 0 := by
  simp [maxBitRate]

/-- The Landauer energy at `kB = T = 1` is `ln 2 > 0`. -/
example : 0 < landauerEnergy 1 1 := by
  simp [landauerEnergy, Real.log_pos one_lt_two]

/-- The witness `dIdt = 1, P = 0, D = 0, kB = T = 1` meets every guard and violates the
conclusion: the bound evaluates to `0` and `1 ≤ 0` fails. -/
example : (1 : ℝ) > 0 ∧ (1 : ℝ) > 0 ∧ (0 : ℝ) ≥ 0 ∧ (0 : ℝ) ≥ 0 ∧ (0 : ℝ) ≤ 1 ∧
    ¬ ((1 : ℝ) ≤ maxBitRate 0 1 1 * 0) := by
  norm_num

/-- The guards and the arithmetic core of the witness, checked by `decide` on natural numbers:
every guard holds and the conclusion `1 ≤ 0 · 0` fails. -/
example : (0 < 1 ∧ 0 < 1 ∧ 0 ≤ 0 ∧ 0 ≤ 1) ∧ ¬ (1 ≤ 0 * 0) := by
  decide

/-- Negative control: once the rate is tied to the bound by hypothesis, the implication is
trivially true. The missing ingredient in the historical postulate is exactly such a condition. -/
example : ∀ dIdt P D kB T : ℝ,
    kB > 0 → T > 0 → P ≥ 0 → D ≥ 0 → D ≤ 1 →
    dIdt ≤ maxBitRate P kB T * D → dIdt ≤ maxBitRate P kB T * D :=
  fun _ _ _ _ _ _ _ _ _ _ h => h

/-- Negative control: a nonpositive rate never violates the bound when `P, D ≥ 0` and
`kB, T > 0`; so a counterexample needs a positive rate exceeding the capacity. -/
example : ∀ dIdt P D kB T : ℝ,
    kB > 0 → T > 0 → P ≥ 0 → D ≥ 0 → dIdt ≤ 0 →
    dIdt ≤ maxBitRate P kB T * D := by
  intro dIdt P D kB T hkB hT hP hD hr
  have hL : 0 < landauerEnergy kB T := by
    unfold landauerEnergy
    exact mul_pos (mul_pos hkB hT) (Real.log_pos one_lt_two)
  have : 0 ≤ maxBitRate P kB T * D :=
    mul_nonneg (div_nonneg hP hL.le) hD
  linarith

end ViridisStatements.P5.UnrestrictedBoundFalse
