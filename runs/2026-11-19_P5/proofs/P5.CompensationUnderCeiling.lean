import Mathlib
import ViridisStatements.P5.CompensationUnderCeiling

namespace Candidate

open ViridisStatements.P5.CompensationUnderCeiling

/-- Interior: the power `P·D/(D − dD)` restores the capacity, and it is the only one. -/
theorem interior (P D dD C : ℝ) (hC : 0 < C) (hP : 0 < P) (hdD : 0 < dD) (hlt : dD < D) :
    cap (P * D / (D - dD)) (D - dD) C = cap P D C ∧
    ∀ P' : ℝ, cap P' (D - dD) C = cap P D C → P' = P * D / (D - dD) := by
  have hpos : 0 < D - dD := by linarith
  refine ⟨?_, ?_⟩
  · unfold cap
    rw [div_mul_cancel₀ _ hpos.ne']
  · intro P' h
    unfold cap at h
    rw [div_left_inj' hC.ne'] at h
    rw [eq_div_iff hpos.ne', h]

/-- Ceiling: compensation within `Pmax` is possible iff `dD ≤ D·(1 − P/Pmax)`. -/
theorem ceiling (P D dD C Pmax : ℝ) (hC : 0 < C) (hP : 0 < P) (hdD : 0 < dD) (hlt : dD < D)
    (hPmax : P ≤ Pmax) :
    (∃ P' : ℝ, P' ≤ Pmax ∧ cap P' (D - dD) C = cap P D C) ↔ dD ≤ D * (1 - P / Pmax) := by
  have hpos : 0 < D - dD := by linarith
  have hM : 0 < Pmax := lt_of_lt_of_le hP hPmax
  -- `dD ≤ D·(1 − P/Pmax)` is equivalent to `P·D ≤ Pmax·(D − dD)`.
  have key : dD ≤ D * (1 - P / Pmax) ↔ P * D ≤ Pmax * (D - dD) := by
    have : D * (1 - P / Pmax) = (Pmax * D - P * D) / Pmax := by
      field_simp
    rw [this, le_div_iff₀ hM]
    constructor <;> intro h <;> nlinarith
  rw [key]
  constructor
  · rintro ⟨P', hP', h⟩
    obtain ⟨-, huniq⟩ := interior P D dD C hC hP hdD hlt
    have he := huniq P' h
    rw [he, div_le_iff₀ hpos] at hP'
    exact hP'
  · intro h
    refine ⟨P * D / (D - dD), ?_, (interior P D dD C hC hP hdD hlt).1⟩
    rw [div_le_iff₀ hpos]
    exact h

/-- Divergence: the compensating power exceeds any bound as `dD → D⁻`. -/
theorem divergence (P D C : ℝ) (_hC : 0 < C) (hP : 0 < P) (hD : 0 < D) (M : ℝ) :
    ∃ δ : ℝ, 0 < δ ∧ ∀ dD : ℝ, D - δ < dD → dD < D → M < P * D / (D - dD) := by
  have hPD : 0 < P * D := mul_pos hP hD
  have hA : 0 < |M| + 1 := by positivity
  refine ⟨P * D / (|M| + 1), div_pos hPD hA, ?_⟩
  intro dD h1 h2
  have hpos : 0 < D - dD := by linarith
  have hsmall : D - dD < P * D / (|M| + 1) := by linarith
  rw [lt_div_iff₀ hA] at hsmall
  rw [lt_div_iff₀ hpos]
  have hM : M ≤ |M| := le_abs_self M
  nlinarith [abs_nonneg M]

/-- Complete loss: at `D = 0` every power gives capacity `0 < cap P D C`. -/
theorem complete_loss (P D C : ℝ) (hC : 0 < C) (hP : 0 < P) (hD : 0 < D) (P' : ℝ) :
    cap P' 0 C = 0 ∧ cap P' 0 C < cap P D C := by
  have h0 : cap P' 0 C = 0 := by simp [cap]
  refine ⟨h0, ?_⟩
  rw [h0]
  unfold cap
  positivity

theorem main : ViridisStatements.P5.CompensationUnderCeiling.Statement :=
  ⟨fun P D dD C hC hP hdD hlt => interior P D dD C hC hP hdD hlt,
   fun P D dD C Pmax hC hP hdD hlt hPmax => ceiling P D dD C Pmax hC hP hdD hlt hPmax,
   fun P D C hC hP hD M => divergence P D C hC hP hD M,
   fun P D C hC hP hD P' => complete_loss P D C hC hP hD P'⟩

end Candidate
