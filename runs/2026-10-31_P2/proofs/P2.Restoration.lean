import Mathlib
import ViridisStatements.P2.Restoration

namespace Candidate

open ViridisStatements.P2.Restoration

/-- The critical radius is positive for positive parameters. -/
lemma rStar_pos (Δμ a σ : ℝ) (hΔμ : 0 < Δμ) (ha : 0 < a) (hσ : 0 < σ) :
    0 < rStar Δμ a σ := by
  unfold rStar
  positivity

/-- `a σ = (3/2) Δμ rStar` whenever `Δμ ≠ 0`. -/
lemma aσ_eq (Δμ a σ : ℝ) (hΔμ : Δμ ≠ 0) :
    a * σ = 3 / 2 * Δμ * rStar Δμ a σ := by
  unfold rStar
  field_simp

/-- Key factorisation: `G(rStar) - G(r) = Δμ (r - rStar)^2 (r + rStar/2)`. -/
lemma key_identity (Δμ a σ r : ℝ) (hΔμ : Δμ ≠ 0) :
    G Δμ a σ (rStar Δμ a σ) - G Δμ a σ r =
      Δμ * (r - rStar Δμ a σ) ^ 2 * (r + rStar Δμ a σ / 2) := by
  unfold G
  rw [aσ_eq Δμ a σ hΔμ]
  ring

/-- Half-barrier identity (holds for any `Δμ`, but stated as in the canon). -/
lemma barrier_half (Δμ a σ : ℝ) (hΔμ : 0 < Δμ) :
    G Δμ a σ (rStar Δμ a σ) = (1 / 2) * Δμ * (rStar Δμ a σ) ^ 3 := by
  unfold G
  rw [aσ_eq Δμ a σ hΔμ.ne']
  ring

theorem critical_nucleus (Δμ a σ : ℝ) (hΔμ : 0 < Δμ) (ha : 0 < a) (hσ : 0 < σ) :
    0 < rStar Δμ a σ ∧
    (∀ r : ℝ, 0 ≤ r → G Δμ a σ r ≤ G Δμ a σ (rStar Δμ a σ)) ∧
    (∀ r : ℝ, 0 ≤ r → G Δμ a σ r = G Δμ a σ (rStar Δμ a σ) → r = rStar Δμ a σ) := by
  have hs := rStar_pos Δμ a σ hΔμ ha hσ
  refine ⟨hs, fun r hr => ?_, fun r hr h => ?_⟩
  · have hk := key_identity Δμ a σ r hΔμ.ne'
    have : 0 ≤ Δμ * (r - rStar Δμ a σ) ^ 2 * (r + rStar Δμ a σ / 2) := by positivity
    linarith
  · have hk := key_identity Δμ a σ r hΔμ.ne'
    rw [h, sub_self] at hk
    have h2 : 0 < r + rStar Δμ a σ / 2 := by positivity
    have h3 : (r - rStar Δμ a σ) ^ 2 = 0 := by
      rcases mul_eq_zero.mp hk.symm with h4 | h4
      · rcases mul_eq_zero.mp h4 with h5 | h5
        · exact absurd h5 hΔμ.ne'
        · exact h5
      · exact absurd h4 h2.ne'
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h3
    linarith

theorem main : ViridisStatements.P2.Restoration.Statement :=
  ⟨fun Δμ a σ hΔμ ha hσ => critical_nucleus Δμ a σ hΔμ ha hσ,
   fun Δμ a σ hΔμ => barrier_half Δμ a σ hΔμ⟩

end Candidate
