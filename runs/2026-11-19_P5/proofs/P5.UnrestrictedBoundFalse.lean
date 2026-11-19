import Mathlib
import ViridisStatements.P5.UnrestrictedBoundFalse

namespace Candidate

open ViridisStatements.P5.UnrestrictedBoundFalse

/-- At zero power the bound evaluates to zero, whatever `D`, `kB`, `T`. -/
lemma bound_zero_power (D kB T : ℝ) : maxBitRate 0 kB T * D = 0 := by
  simp [maxBitRate]

theorem main : ViridisStatements.P5.UnrestrictedBoundFalse.Statement := by
  intro h
  -- Counterinstance: dIdt = 1, P = 0, D = 0, kB = T = 1.
  have h1 := h 1 0 0 1 1 one_pos one_pos le_rfl le_rfl zero_le_one
  rw [bound_zero_power] at h1
  exact absurd h1 (by norm_num)

/-- Explosion: taken as a hypothesis, the unrestricted bound proves every proposition. -/
theorem bound_proves_anything
    (h : ∀ dIdt P D kB T : ℝ, kB > 0 → T > 0 → P ≥ 0 → D ≥ 0 → D ≤ 1 →
      dIdt ≤ maxBitRate P kB T * D)
    (p : Prop) : p :=
  absurd h main

end Candidate
