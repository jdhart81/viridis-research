import Mathlib
import ViridisStatements.P2.Harmonization

namespace Candidate

open ViridisStatements.P2.Harmonization

/-- The sum of reciprocal curvatures is positive when `N > 0` and all `a i > 0`. -/
theorem sum_inv_pos {N : ℕ} (a : Fin N → ℝ) (hN : 0 < N) (ha : ∀ i, 0 < a i) :
    0 < ∑ i, 1 / a i :=
  Finset.sum_pos (fun i _ => one_div_pos.mpr (ha i)) ⟨⟨0, hN⟩, Finset.mem_univ _⟩

/-- Aggregate best response is linear in the price: `∑ br lam = ∑ b − lam · ∑ 1/a`. -/
theorem sum_br {N : ℕ} (a b : Fin N → ℝ) (lam : ℝ) :
    (∑ i, br a b lam i) = (∑ i, b i) - lam * ∑ i, 1 / a i := by
  unfold br
  rw [Finset.sum_sub_distrib, Finset.mul_sum]
  congr 1
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [mul_one_div]

/-- Market clearing (canon `ght_market_clears`). -/
theorem market_clears {N : ℕ} (a b : Fin N → ℝ) (hN : 0 < N) (ha : ∀ i, 0 < a i) (X : ℝ) :
    (∑ i, br a b (lamStar a b X) i) = X := by
  rw [sum_br]
  unfold lamStar
  rw [div_mul_cancel₀ _ (sum_inv_pos a hN ha).ne']
  ring

/-- Equimarginal principle (canon `ght_equimarginal`): `a i · (xStar i − b i) = −lamStar`. -/
theorem equimarginal {N : ℕ} (a b : Fin N → ℝ) (ha : ∀ i, 0 < a i) (X : ℝ) (i : Fin N) :
    a i * (xStar a b X i - b i) = - lamStar a b X := by
  unfold xStar br
  field_simp [(ha i).ne']
  ring

/-- Pointwise supporting-line inequality for one agent's quadratic dissipation. -/
theorem pointwise {N : ℕ} (a b : Fin N → ℝ) (ha : ∀ i, 0 < a i) (X : ℝ) (y : Fin N → ℝ)
    (i : Fin N) :
    (a i / 2) * (xStar a b X i - b i) ^ 2 + (- lamStar a b X) * (y i - xStar a b X i)
      ≤ (a i / 2) * (y i - b i) ^ 2 := by
  rw [← equimarginal a b ha X i]
  nlinarith [mul_nonneg (ha i).le (sq_nonneg (y i - xStar a b X i))]

/-- Strong duality / welfare theorem (canon
`ght_strong_duality_decentralized_eq_centralized`). -/
theorem strong_duality {N : ℕ} (a b : Fin N → ℝ) (hN : 0 < N) (ha : ∀ i, 0 < a i) (X : ℝ)
    (y : Fin N → ℝ) (hy : (∑ i, y i) = X) :
    J a b (xStar a b X) ≤ J a b y := by
  have hsum := Finset.sum_le_sum fun i (_ : i ∈ Finset.univ) => pointwise a b ha X y i
  have hx : (∑ i, xStar a b X i) = X := market_clears a b hN ha X
  have hzero : (∑ i, (- lamStar a b X) * (y i - xStar a b X i)) = 0 := by
    rw [← Finset.mul_sum, Finset.sum_sub_distrib, hy, hx, sub_self, mul_zero]
  rw [Finset.sum_add_distrib, hzero, add_zero] at hsum
  exact hsum

theorem main : ViridisStatements.P2.Harmonization.Statement := by
  intro N a b hN ha X
  exact ⟨market_clears a b hN ha X, fun y hy => strong_duality a b hN ha X y hy⟩

end Candidate
