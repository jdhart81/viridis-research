import Mathlib

/-!
# P7 · Bounds from a power-law species–area relationship

Model (Arrhenius 1921): species number follows `S = k·A^z` with `0 < z ≤ 1`. If a fraction `a` of
the area `A` is kept, the fraction of species kept is `S(a·A)/S(A) = a^z`; the constant `k` (and
`A`) cancels. To keep a fraction `s` of the species the area fraction needed is `s^(1/z)`.
Powers are real powers (`Real.rpow`).

The power law is an empirical regularity that this module **assumes** only through the
interpretation above; the mathematics below is about `a ^ z` for real `a, z`. Nothing is claimed
about extinction debt, about which species are lost, about where the remaining habitat lies, or
about any value of `z`.

`Statement`, each part for all real `z` with `0 < z ≤ 1`:
1. retained fraction bound: `a ≤ a^z ≤ 1` for `0 ≤ a ≤ 1`;
2. strict gain: if `z < 1`, then `a < a^z` for `0 < a < 1`;
3. monotone: `a^z ≤ b^z` for `0 ≤ a ≤ b`;
4. area needed: for `0 ≤ s ≤ 1`, `(s^(1/z))^z = s` and `s^(1/z) ≤ s`.
-/

namespace ViridisStatements.P7.SpeciesArea

/-- **Proposed sealed target `P7.SpeciesArea`.** Here `a ^ z` is the fraction of species kept
when a fraction `a` of the area is kept, and `s ^ (1 / z)` the area fraction needed to keep a
fraction `s` of the species. -/
def Statement : Prop :=
  (∀ z : ℝ, 0 < z → z ≤ 1 →
      ∀ a : ℝ, 0 ≤ a → a ≤ 1 → a ≤ a ^ z ∧ a ^ z ≤ 1) ∧
  (∀ z : ℝ, 0 < z → z ≤ 1 → z < 1 →
      ∀ a : ℝ, 0 < a → a < 1 → a < a ^ z) ∧
  (∀ z : ℝ, 0 < z → z ≤ 1 →
      ∀ a b : ℝ, 0 ≤ a → a ≤ b → a ^ z ≤ b ^ z) ∧
  (∀ z : ℝ, 0 < z → z ≤ 1 →
      ∀ s : ℝ, 0 ≤ s → s ≤ 1 → (s ^ (1 / z)) ^ z = s ∧ s ^ (1 / z) ≤ s)

/-! ## Sanity checks -/

/-- Witness: `z = 1/2`, `a = 1/4` gives `a^z = 1/2`: keeping a quarter of the area keeps half
the species. -/
example : (1/4 : ℝ) ^ (1/2 : ℝ) = 1/2 := by
  have h : (1/4 : ℝ) = (1/2) ^ (2 : ℝ) := by norm_num
  rw [h, ← Real.rpow_mul (by norm_num)]
  norm_num

/-- Witness: `z = 1/2`, `s = 1/2` gives area fraction `s^(1/z) = s^2 = 1/4`. -/
example : (1/2 : ℝ) ^ ((1 : ℝ) / (1/2)) = 1/4 := by
  rw [show (1 : ℝ) / (1/2) = (2 : ℕ) by norm_num, Real.rpow_natCast]
  norm_num

/-- Negative control for part 1: the bound fails for `z = 2 > 1`, since `(1/2)^2 = 1/4 < 1/2`. -/
example : (1/2 : ℝ) ^ (2 : ℝ) < 1/2 := by
  rw [show (2 : ℝ) = (2 : ℕ) by norm_num, Real.rpow_natCast]
  norm_num

end ViridisStatements.P7.SpeciesArea
