import Mathlib

/-!
# P2 · re-certification: the Restoration critical-nucleus go/no-go

The live Viridis OS Restoration kernel decides whether a planted cluster on degraded land is
large enough to grow into forest (go) or will dissolve back into the degraded state (no-go).
Its formal backing is the Forest Nucleation Theorem clean core,
`Viridis.Afforestation.ForestNucleation.critical_nucleus` and
`Viridis.Afforestation.ForestNucleation.barrier_half_identity`, in the archived canon
(github.com/jdhart81/viridis-canon, commit 80d32904d751b45f415e23f872510cc2eddca3ff,
file `ForestNucleation.lean`, sha256
667a826a2e5befac67964b69670435362de2d3d792e163807c3bb7c2aec28132).
This module restates those two theorems, over the same definitions, as one sealed target.

Model (classical nucleation in the cube-root order parameter `r = n^(1/3)`): a cluster of
`n = r^3` trees has free energy `G(r) = -Δμ·r^3 + a·σ·r^2`, where `Δμ` is the per-tree driving
force, `σ` the edge "surface tension" and `a` a shape factor. The critical radius is
`rStar = 2aσ/(3Δμ)` and the critical nucleus is `n* = rStar^3`.

`Statement`, part 1 (`critical_nucleus`): for `Δμ, a, σ > 0`, `rStar > 0` and `rStar` is the
unique global maximiser of `G` over `r ≥ 0` (the top of the nucleation barrier).
`Statement`, part 2 (`barrier_half_identity`): for `Δμ > 0`, the barrier height is
`G(rStar) = ½·Δμ·rStar^3`, i.e. `ΔG* = ½·Δμ·n*`.
-/

namespace ViridisStatements.P2.Restoration

/-- Critical radius (cube-root order parameter) `rStar = 2aσ/(3Δμ)`;
the critical nucleus is `n* = rStar ^ 3`. -/
noncomputable def rStar (Δμ a σ : ℝ) : ℝ := 2 * a * σ / (3 * Δμ)

/-- Nucleation free energy in the cube-root order parameter `r` (with `n = r^3`,
`n^(2/3) = r^2`): `G(r) = -Δμ·r^3 + a·σ·r^2`. -/
noncomputable def G (Δμ a σ r : ℝ) : ℝ := -Δμ * r ^ 3 + a * σ * r ^ 2

/-- **Sealed target `P2.Restoration`.**
(1) For positive driving force, shape factor and surface tension, the critical radius is
positive and is the unique maximiser of `G` on `r ≥ 0`.
(2) For positive driving force, the barrier height is half the driving energy stored in the
critical nucleus: `G(rStar) = ½·Δμ·rStar^3`. -/
def Statement : Prop :=
  (∀ Δμ a σ : ℝ, 0 < Δμ → 0 < a → 0 < σ →
    0 < rStar Δμ a σ ∧
    (∀ r : ℝ, 0 ≤ r → G Δμ a σ r ≤ G Δμ a σ (rStar Δμ a σ)) ∧
    (∀ r : ℝ, 0 ≤ r → G Δμ a σ r = G Δμ a σ (rStar Δμ a σ) → r = rStar Δμ a σ)) ∧
  (∀ Δμ a σ : ℝ, 0 < Δμ →
    G Δμ a σ (rStar Δμ a σ) = (1 / 2) * Δμ * (rStar Δμ a σ) ^ 3)

/-! ## Sanity checks

These pin the meaning of the definitions with concrete numbers. -/

/-- The canon's non-vacuity witness `(Δμ, a, σ) = (1, 1, 3/2)`: `rStar = 1`, so `n* = 1`,
and the barrier is `G(1) = 1/2 = ½·1·1^3 > 0`. -/
example : rStar 1 1 (3/2) = 1 ∧ G 1 1 (3/2) 1 = 1/2 ∧ (1/2 : ℝ) = (1/2) * 1 * 1 ^ 3 := by
  norm_num [rStar, G]

/-- Below the critical radius the free energy is lower than at the barrier top
(a sub-critical cluster sits on the uphill side): `G(1/2) = 1/4 < 1/2 = G(1)`. -/
example : G 1 1 (3/2) (1/2) = 1/4 ∧ G 1 1 (3/2) (1/2) < G 1 1 (3/2) 1 := by
  norm_num [G]

/-- Above the critical radius the free energy falls again (a super-critical cluster grows
downhill): `G(2) = -2 < 1/2 = G(1)`. -/
example : G 1 1 (3/2) 2 = -2 ∧ G 1 1 (3/2) 2 < G 1 1 (3/2) 1 := by
  norm_num [G]

/-- Negative control: the restriction `r ≥ 0` is needed. At the unphysical `r = -1` the cubic
exceeds the barrier, `G(-1) = 5/2 > 1/2 = G(rStar)`, so maximality fails off `r ≥ 0`. -/
example : G 1 1 (3/2) (rStar 1 1 (3/2)) < G 1 1 (3/2) (-1) := by
  norm_num [G, rStar]

/-- Negative control: the barrier is half, not all, of `Δμ·n*`:
`G(rStar) = 1/2 ≠ 1 = Δμ·rStar^3` at the witness. -/
example : G 1 1 (3/2) (rStar 1 1 (3/2)) ≠ 1 * (rStar 1 1 (3/2)) ^ 3 := by
  norm_num [G, rStar]

/-- Negative control: with negative driving force (`Δμ = -1`, degraded state favoured) the
critical radius is negative, so part 1 genuinely needs `0 < Δμ`. -/
example : rStar (-1) 1 (3/2) < 0 := by
  norm_num [rStar]

end ViridisStatements.P2.Restoration
