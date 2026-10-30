import Mathlib

/-!
# P2 · re-certification: the Afforestation stewardship laws

The live Viridis OS Afforestation kernel ranks seeding plans and site-preparation levers by
seeding efficiency (established canopy per seed) and scores how well a seed allocation is
aligned with the optimal one. Its formal backing is the Afforestation Stewardship Theorem
clean core,
`Viridis.Afforestation.AfforestationStewardship.establishment_efficiency_cubic_in_drive_over_tension`
and `Viridis.Afforestation.AfforestationStewardship.seeding_efficiency_eq_cos2_theta`, in the
archived canon (github.com/jdhart81/viridis-canon, commit
80d32904d751b45f415e23f872510cc2eddca3ff, file `AfforestationStewardship.lean`, sha256
3ebe33bfd6bd74124e87b5d7e73448db58e1459207fd6ff5c00a90fc3ac9526f).
This module restates those two theorems, over the same definitions, as one sealed target.

Model: for a site with ecological drive `Δμ`, edge hostility ("surface tension") `σ`, shape
constant `a` and canopy per established nucleus `C`, the seeding efficiency is
`eff = C·(3Δμ/(2aσ))^3 = C/n*`, where `n* = (2aσ/(3Δμ))^3` is the critical nucleus.
The alignment of an allocation `n` with the optimal seeding vector `m` is
`η = ⟨n, m⟩² / (‖n‖²·‖m‖²)` (= cos²Θ); the forcing debt is `1 − η`.

`Statement`, part 1: for `a, σ, Δμ, t > 0`, scaling the drive by `t` multiplies the efficiency
by `t^3`. Part 2: in every real inner-product space, for nonzero `n, m`, `0 ≤ η ≤ 1`.
-/

namespace ViridisStatements.P2.Afforestation

/-- Critical nucleus size `n* = (2aσ/(3Δμ))^3` (as in the Restoration kernel). -/
noncomputable def nStar (a σ Δμ : ℝ) : ℝ := (2 * a * σ / (3 * Δμ)) ^ 3

/-- Seeding efficiency `e = C / n* = C·(3Δμ/(2aσ))^3` (established canopy per seed). -/
noncomputable def eff (a σ Δμ C : ℝ) : ℝ := C * (3 * Δμ / (2 * a * σ)) ^ 3

/-- Alignment of a seed allocation `n` with the optimal seeding vector `m`:
`η = ⟨n, m⟩² / (‖n‖²·‖m‖²)`, the squared cosine of the angle between them. -/
noncomputable def eta {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
    (n m : E) : ℝ :=
  (inner ℝ n m : ℝ) ^ 2 / (‖n‖ ^ 2 * ‖m‖ ^ 2)

/-- **Sealed target `P2.Afforestation`.**
(1) Cubic establishment-efficiency law: for `a, σ, Δμ, t > 0` and any `C`,
`eff a σ (t·Δμ) C = t^3 · eff a σ Δμ C`.
(2) Seeding alignment is a squared cosine: for nonzero `n, m` in any real inner-product
space, `0 ≤ η(n, m) ≤ 1`. -/
def Statement : Prop :=
  (∀ a σ Δμ C t : ℝ, 0 < a → 0 < σ → 0 < Δμ → 0 < t →
    eff a σ (t * Δμ) C = t ^ 3 * eff a σ Δμ C) ∧
  (∀ (E : Type*) [NormedAddCommGroup E] [InnerProductSpace ℝ E] (n m : E),
    n ≠ 0 → m ≠ 0 → 0 ≤ eta n m ∧ eta n m ≤ 1)

/-! ## Sanity checks

These pin the meaning of the definitions with concrete numbers. -/

/-- Efficiency is canopy per seed: with `a = σ = Δμ = 1`, `C = 1`, `n* = 8/27` and
`eff = 27/8 = C / n*`. -/
example : nStar 1 1 1 = 8/27 ∧ eff 1 1 1 1 = 27/8 ∧ eff 1 1 1 1 = 1 / nStar 1 1 1 := by
  norm_num [nStar, eff]

/-- Doubling the drive multiplies efficiency by `2^3 = 8`: `eff(Δμ = 2) = 27 = 8·(27/8)`. -/
example : eff 1 1 2 1 = 27 ∧ eff 1 1 2 1 = 2 ^ 3 * eff 1 1 1 1 := by
  norm_num [eff]

/-- Negative control: the law is cubic, not linear: doubling the drive does not merely
double the efficiency. -/
example : eff 1 1 2 1 ≠ 2 * eff 1 1 1 1 := by
  norm_num [eff]

/-- Halving the edge hostility `σ` gives the canon's 8× site-prep lever at a concrete point. -/
example : eff 1 (1/2) 1 1 = 8 * eff 1 1 1 1 := by
  norm_num [eff]

/-- Parallel allocations are perfectly aligned: in `ℝ`, `η(2, 3) = 1`. -/
example : eta (2 : ℝ) 3 = 1 := by
  norm_num [eta]

/-- Orthogonal allocations have zero alignment: in `ℝ²`, `η((1,0), (0,1)) = 0`. -/
example : eta (!₂[1, 0] : EuclideanSpace ℝ (Fin 2)) !₂[0, 1] = 0 := by
  simp [eta, EuclideanSpace.inner_eq_star_dotProduct, dotProduct, Fin.sum_univ_two]

/-- Negative control: without the normalisation the squared inner product is not bounded by 1:
in `ℝ`, `⟨2, 3⟩² = 36 > 1`, while `η(2, 3) = 1`. -/
example : (1 : ℝ) < (inner ℝ (2 : ℝ) 3) ^ 2 := by
  norm_num

end ViridisStatements.P2.Afforestation
