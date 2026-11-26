import Mathlib
import ViridisStatements.P6.SerialParallel

namespace Candidate

open ViridisStatements.P6.SerialParallel

/-- A product of factors in `[0, 1]` is at most any one of its factors. -/
theorem prod_le_factor {ι : Type} (s : Finset ι) (p : ι → ℝ)
    (hp : ∀ i ∈ s, 0 ≤ p i ∧ p i ≤ 1) (j : ι) (hj : j ∈ s) :
    ∏ i ∈ s, p i ≤ p j := by
  classical
  rw [← Finset.mul_prod_erase s p hj]
  have h0 : 0 ≤ p j := (hp j hj).1
  have h1 : ∏ i ∈ s.erase j, p i ≤ 1 :=
    Finset.prod_le_one (fun i hi => (hp i (Finset.mem_of_mem_erase hi)).1)
      (fun i hi => (hp i (Finset.mem_of_mem_erase hi)).2)
  calc p j * ∏ i ∈ s.erase j, p i ≤ p j * 1 := mul_le_mul_of_nonneg_left h1 h0
    _ = p j := mul_one _

theorem serial_le {ι : Type} (s : Finset ι) (p : ι → ℝ)
    (hp : ∀ i ∈ s, 0 ≤ p i ∧ p i ≤ 1) (j : ι) (hj : j ∈ s) : serial s p ≤ p j :=
  prod_le_factor s p hp j hj

theorem parallel_bounds {ι : Type} (s : Finset ι) (q : ι → ℝ)
    (hq : ∀ i ∈ s, 0 ≤ q i ∧ q i ≤ 1) (j : ι) (hj : j ∈ s) :
    q j ≤ parallel s q ∧ parallel s q ≤ 1 := by
  have hq' : ∀ i ∈ s, 0 ≤ 1 - q i ∧ 1 - q i ≤ 1 := fun i hi => by
    obtain ⟨a, b⟩ := hq i hi; constructor <;> linarith
  have hle := prod_le_factor s (fun i => 1 - q i) hq' j hj
  have hnn : 0 ≤ ∏ i ∈ s, (1 - q i) := Finset.prod_nonneg (fun i hi => (hq' i hi).1)
  unfold parallel
  constructor <;> simp only at hle <;> linarith

theorem two_routes (p q : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hq0 : 0 ≤ q) (hq1 : q ≤ 1) :
    1 - (1 - p) * (1 - q) = max p q ↔ (min p q = 0 ∨ max p q = 1) := by
  rcases le_total p q with h | h
  · rw [max_eq_right h, min_eq_left h]
    constructor
    · intro e
      have : p * (1 - q) = 0 := by linarith
      rcases mul_eq_zero.mp this with h1 | h1
      · exact Or.inl h1
      · exact Or.inr (by linarith)
    · rintro (e | e) <;> subst e <;> ring
  · rw [max_eq_left h, min_eq_right h]
    constructor
    · intro e
      have : q * (1 - p) = 0 := by linarith
      rcases mul_eq_zero.mp this with h1 | h1
      · exact Or.inl h1
      · exact Or.inr (by linarith)
    · rintro (e | e) <;> subst e <;> ring

theorem main : ViridisStatements.P6.SerialParallel.Statement :=
  ⟨fun ι s p hp j hj => serial_le s p hp j hj,
   fun ι s q hq j hj => parallel_bounds s q hq j hj,
   fun p q hp0 hp1 hq0 hq1 => two_routes p q hp0 hp1 hq0 hq1⟩

end Candidate
