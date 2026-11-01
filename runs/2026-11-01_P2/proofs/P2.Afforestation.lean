import Mathlib
import ViridisStatements.P2.Afforestation

namespace Candidate

open ViridisStatements.P2.Afforestation

/-- Part 1 (canon `establishment_efficiency_cubic_in_drive_over_tension`):
scaling the drive by `t` multiplies seeding efficiency by `t^3`. -/
theorem eff_cubic (a σ Δμ C t : ℝ) :
    eff a σ (t * Δμ) C = t ^ 3 * eff a σ Δμ C := by
  unfold eff
  ring

/-- Part 2 (canon `seeding_efficiency_eq_cos2_theta`): `0 ≤ η ≤ 1` by Cauchy–Schwarz. -/
theorem eta_mem_unit {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (n m : E) : 0 ≤ eta n m ∧ eta n m ≤ 1 := by
  unfold eta
  refine ⟨by positivity, ?_⟩
  apply div_le_one_of_le₀ _ (by positivity)
  have h := abs_real_inner_le_norm n m
  have h2 : |inner ℝ n m| ^ 2 ≤ (‖n‖ * ‖m‖) ^ 2 :=
    pow_le_pow_left₀ (abs_nonneg _) h 2
  rw [sq_abs, mul_pow] at h2
  exact h2

theorem main : ViridisStatements.P2.Afforestation.Statement := by
  refine ⟨fun a σ Δμ C t _ _ _ _ => eff_cubic a σ Δμ C t, ?_⟩
  intro E _ _ n m _ _
  exact eta_mem_unit n m

end Candidate
