import Mathlib
import ViridisStatements.P2.Tempo

namespace Candidate

open ViridisStatements.P2.Tempo

/-- With `h = s ^ 2` and `n = r ^ 2`, the optimum is `s / r`. -/
lemma optimum_sq {s r : ℝ} (hs : 0 < s) (hr : 0 < r) :
    optimum (s ^ 2) (r ^ 2) = s / r := by
  rw [optimum, Real.sqrt_div' _ (by positivity), Real.sqrt_sq hs.le, Real.sqrt_sq hr.le]

/-- With `h = s ^ 2` and `n = r ^ 2`, the floor is `2 * s * r`. -/
lemma floor_sq {s r : ℝ} (hs : 0 < s) (hr : 0 < r) :
    floor (s ^ 2) (r ^ 2) = 2 * s * r := by
  rw [floor, ← mul_pow, Real.sqrt_sq (by positivity)]; ring

/-- Gap identity: `Sigma t - floor = (s - r t) ^ 2 / t`. -/
lemma gap {s r t : ℝ} (hs : 0 < s) (hr : 0 < r) (ht : 0 < t) :
    ViridisStatements.P2.Tempo.Sigma (s ^ 2) (r ^ 2) t - floor (s ^ 2) (r ^ 2) = (s - r * t) ^ 2 / t := by
  rw [floor_sq hs hr, ViridisStatements.P2.Tempo.Sigma]; field_simp; ring

/-- The cosh form of the normalised cost, in either orientation. -/
lemma norm_eq_cosh {s r t : ℝ} (hs : 0 < s) (hr : 0 < r) (ht : 0 < t) :
    normalizedCost (s ^ 2) (r ^ 2) t = Real.cosh (Real.log (t / (s / r))) ∧
    normalizedCost (s ^ 2) (r ^ 2) t = Real.cosh (Real.log (s / r / t)) := by
  rw [normalizedCost, floor_sq hs hr, ViridisStatements.P2.Tempo.Sigma,
    Real.cosh_log (by positivity), Real.cosh_log (by positivity)]
  constructor <;> (field_simp; try ring)

lemma core {s r : ℝ} (hs : 0 < s) (hr : 0 < r) :
    StrictConvexOn ℝ (Set.Ioi 0) (ViridisStatements.P2.Tempo.Sigma (s ^ 2) (r ^ 2)) ∧
    (∀ t : ℝ, 0 < t → floor (s ^ 2) (r ^ 2) ≤ ViridisStatements.P2.Tempo.Sigma (s ^ 2) (r ^ 2) t) ∧
    ViridisStatements.P2.Tempo.Sigma (s ^ 2) (r ^ 2) (optimum (s ^ 2) (r ^ 2)) = floor (s ^ 2) (r ^ 2) ∧
    (∀ t : ℝ, 0 < t → ViridisStatements.P2.Tempo.Sigma (s ^ 2) (r ^ 2) t = floor (s ^ 2) (r ^ 2) →
      t = optimum (s ^ 2) (r ^ 2)) ∧
    ((∀ u : ℝ, 0 < u → (u + 1 / u) / 2 = Real.cosh (Real.log u)) ∧
      (∀ t : ℝ, 0 < t → normalizedCost (s ^ 2) (r ^ 2) t = tax (s ^ 2) (r ^ 2) t)) ∧
    (∀ t : ℝ, 0 < t →
      normalizedCost (s ^ 2) (r ^ 2) t =
        Real.cosh (Real.log (optimum (s ^ 2) (r ^ 2) / t)) ∧
      1 ≤ tax (s ^ 2) (r ^ 2) t ∧ (tax (s ^ 2) (r ^ 2) t = 1 ↔ t = optimum (s ^ 2) (r ^ 2))) := by
  -- (2) floor
  have hfloor : ∀ t : ℝ, 0 < t → floor (s ^ 2) (r ^ 2) ≤ ViridisStatements.P2.Tempo.Sigma (s ^ 2) (r ^ 2) t := by
    intro t ht
    have := gap hs hr ht
    have : 0 ≤ (s - r * t) ^ 2 / t := by positivity
    linarith
  -- (3) optimum
  have hopt : ViridisStatements.P2.Tempo.Sigma (s ^ 2) (r ^ 2) (optimum (s ^ 2) (r ^ 2)) = floor (s ^ 2) (r ^ 2) := by
    have hpos : 0 < s / r := by positivity
    have := gap hs hr hpos
    rw [optimum_sq hs hr]
    have h0 : s - r * (s / r) = 0 := by field_simp; ring
    rw [h0] at this
    simp at this
    linarith
  -- (4) uniqueness
  have huniq : ∀ t : ℝ, 0 < t → ViridisStatements.P2.Tempo.Sigma (s ^ 2) (r ^ 2) t = floor (s ^ 2) (r ^ 2) →
      t = optimum (s ^ 2) (r ^ 2) := by
    intro t ht he
    have hg := gap hs hr ht
    rw [he, sub_self] at hg
    have h1 : (s - r * t) ^ 2 = 0 := by
      have := hg.symm
      rwa [div_eq_zero_iff, or_iff_left ht.ne'] at this
    have h2 : s - r * t = 0 := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h1
    rw [optimum_sq hs hr]
    field_simp
    linarith
  -- (5) cosh
  have hcosh : ∀ u : ℝ, 0 < u → (u + 1 / u) / 2 = Real.cosh (Real.log u) := by
    intro u hu
    rw [Real.cosh_log hu, one_div]
  have htax : ∀ t : ℝ, 0 < t → normalizedCost (s ^ 2) (r ^ 2) t = tax (s ^ 2) (r ^ 2) t := by
    intro t ht
    rw [tax, optimum_sq hs hr]
    exact (norm_eq_cosh hs hr ht).1
  refine ⟨?_, hfloor, hopt, huniq, ⟨hcosh, htax⟩, ?_⟩
  · -- (1) strict convexity, directly from the definition
    refine ⟨convex_Ioi 0, ?_⟩
    intro x hx y hy hxy a b ha hb hab
    simp only [Set.mem_Ioi] at hx hy
    simp only [ViridisStatements.P2.Tempo.Sigma, smul_eq_mul]
    have hb' : b = 1 - a := by linarith
    subst hb'
    have hz : 0 < a * x + (1 - a) * y := by nlinarith
    have hs2 : 0 < s ^ 2 := by positivity
    -- reduce to the harmonic part
    suffices hkey : s ^ 2 / (a * x + (1 - a) * y) < a * (s ^ 2 / x) + (1 - a) * (s ^ 2 / y) by
      nlinarith
    rw [div_lt_iff₀ hz]
    have hxy' : 0 < (x - y) ^ 2 := by
      have : x - y ≠ 0 := sub_ne_zero.mpr hxy
      positivity
    have e : (a * (s ^ 2 / x) + (1 - a) * (s ^ 2 / y)) * (a * x + (1 - a) * y)
        = s ^ 2 + s ^ 2 * a * (1 - a) * (x - y) ^ 2 / (x * y) := by
      field_simp; ring
    rw [e]
    have : 0 < s ^ 2 * a * (1 - a) * (x - y) ^ 2 / (x * y) := by
      have h1a : 0 < 1 - a := hb
      positivity
    linarith
  · -- (6) governability tax
    intro t ht
    refine ⟨?_, Real.one_le_cosh _, ?_⟩
    · rw [optimum_sq hs hr]; exact (norm_eq_cosh hs hr ht).2
    · constructor
      · intro h1
        apply huniq t ht
        have hn : normalizedCost (s ^ 2) (r ^ 2) t = 1 := by rw [htax t ht, h1]
        have hf : 0 < floor (s ^ 2) (r ^ 2) := by rw [floor_sq hs hr]; positivity
        rw [normalizedCost, div_eq_one_iff_eq hf.ne'] at hn
        exact hn
      · intro h1
        have hf : 0 < floor (s ^ 2) (r ^ 2) := by rw [floor_sq hs hr]; positivity
        rw [← htax t ht, normalizedCost, h1, hopt, div_self hf.ne']

theorem main : ViridisStatements.P2.Tempo.Statement := by
  intro h n hh hn
  have eh : h = Real.sqrt h ^ 2 := (Real.sq_sqrt hh.le).symm
  have en : n = Real.sqrt n ^ 2 := (Real.sq_sqrt hn.le).symm
  have := core (Real.sqrt_pos.mpr hh) (Real.sqrt_pos.mpr hn)
  rw [← eh, ← en] at this
  exact this

end Candidate
