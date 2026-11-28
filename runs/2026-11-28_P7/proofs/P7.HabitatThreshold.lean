import Mathlib
import ViridisStatements.P7.HabitatThreshold

namespace Candidate

open ViridisStatements.P7.HabitatThreshold

/-- Part 1: the growth term factorises through the equilibrium `p* = h - e/c`. -/
theorem growth_factor (c e h : ℝ) (hc : 0 < c) (p : ℝ) :
    growth c e h p = c * p * (pstar c e h - p) := by
  unfold growth pstar
  field_simp
  ring

/-- Part 2: at or below the threshold the growth term is negative for every `p > 0`. -/
theorem below (c e h : ℝ) (hc : 0 < c) (hle : h ≤ e / c) (p : ℝ) (hp : 0 < p) :
    growth c e h p < 0 := by
  rw [growth_factor c e h hc p]
  have hcp : 0 < c * p := mul_pos hc hp
  have hneg : pstar c e h - p < 0 := by unfold pstar; linarith
  exact mul_neg_of_pos_of_neg hcp hneg

/-- Part 3: above the threshold, `0 < p* < h`, `p*` is an equilibrium, and the growth term
points towards `p*` from both sides. -/
theorem above (c e h : ℝ) (hc : 0 < c) (he : 0 < e) (hlt : e / c < h) :
    0 < pstar c e h ∧ pstar c e h < h ∧ growth c e h (pstar c e h) = 0 ∧
      (∀ p : ℝ, 0 < p → p < pstar c e h → 0 < growth c e h p) ∧
      (∀ p : ℝ, pstar c e h < p → growth c e h p < 0) := by
  have hec : 0 < e / c := div_pos he hc
  have hps : 0 < pstar c e h := by unfold pstar; linarith
  refine ⟨hps, ?_, ?_, ?_, ?_⟩
  · unfold pstar; linarith
  · rw [growth_factor c e h hc]; ring
  · intro p hp hpp
    rw [growth_factor c e h hc p]
    exact mul_pos (mul_pos hc hp) (by linarith)
  · intro p hpp
    rw [growth_factor c e h hc p]
    exact mul_neg_of_pos_of_neg (mul_pos hc (by linarith)) (by linarith)

theorem main : ViridisStatements.P7.HabitatThreshold.Statement := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro c e h hc _ p
    exact growth_factor c e h hc p
  · intro c e h hc _ hle p hp
    exact below c e h hc hle p hp
  · intro c e h hc he hlt
    exact above c e h hc he hlt
  · intro c e h _ _
    constructor <;> intro H <;> linarith
  · intro c e hc he
    refine ⟨?_, ?_⟩
    · intro c' hc'
      exact div_lt_div_of_pos_left he hc hc'
    · intro e' he'
      exact div_lt_div_of_pos_right he' hc

end Candidate
