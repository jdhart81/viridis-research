import Mathlib
import ViridisStatements.P2.CarbonContinuity

namespace Candidate

open ViridisStatements.P2.CarbonContinuity

/-- Sufficiency: above the threshold, the portfolio `(L, D) = (r, 1 - a)` is positive and
holds living carbon exactly while durable carbon does not shrink. -/
theorem sufficient (a d r p : ℝ) (ha1 : a < 1) (hr : 0 < r)
    (h : (1 - a) * (1 - d) ≤ r * p) : Sustainable a d r p := by
  refine ⟨r, 1 - a, hr, by linarith, ?_, ?_⟩
  · simp only [stepLiving]; nlinarith
  · simp only [stepDurable]; nlinarith

/-- Necessity: multiplying the two leakage inequalities `(1 - a) L ≤ r D` and
`(1 - d) D ≤ p L` and cancelling `L D > 0` gives the threshold. -/
theorem necessary (a d r p : ℝ) (ha1 : a < 1) (hd1 : d < 1)
    (hs : Sustainable a d r p) : (1 - a) * (1 - d) ≤ r * p := by
  obtain ⟨L, D, hL, hD, hliv, hdur⟩ := hs
  simp only [stepLiving] at hliv
  simp only [stepDurable] at hdur
  have h1 : (1 - a) * L ≤ r * D := by linarith
  have h2 : (1 - d) * D ≤ p * L := by linarith
  have h3 : ((1 - a) * L) * ((1 - d) * D) ≤ (r * D) * (p * L) :=
    mul_le_mul h1 h2 (by nlinarith) (by nlinarith)
  have h4 : ((1 - a) * (1 - d)) * (L * D) ≤ (r * p) * (L * D) := by linarith
  exact le_of_mul_le_mul_right h4 (mul_pos hL hD)

theorem main : ViridisStatements.P2.CarbonContinuity.Statement := by
  intro a d r p _ ha1 _ hd1 hr _
  exact ⟨necessary a d r p ha1 hd1, sufficient a d r p ha1 hr⟩

end Candidate
