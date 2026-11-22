import Mathlib

/-!
# P2 · re-certification: Multi-ring alignment capacity (the MRAB core)

The live Viridis OS Multi-ring alignment capacity kernel reports a ceiling on the joint
information rate of an agent working across `K` rings, as the unaligned base rate
`P · D̄ / κ` times the alignment product `∏_k cos²Θ_k`. Its formal backing is four theorems of
`MRAB.lean` in the archived canon (github.com/jdhart81/viridis-canon, commit
80d32904d751b45f415e23f872510cc2eddca3ff, sha256
f56396bf4717d3264da534edd92f6cd77919d7377e7b24e56f8885a3d54db2e7):
`MRAB.Dbar_le_arith_mean`, `MRAB.mrab_bound_le_baseRate`, `MRAB.mrab_saturation` and
`MRAB.mrab_reduces_to_IB`. This module restates those four theorems, over the same five
real-valued definitions (`kappa`, `Dbar`, `alignFactor`, `baseRate`, `mrabBound`), as one target.
Nothing is imported from or copied wholesale out of the canon file.

Data on `Fin K`: per-ring alignment factors `c k` (read as `cos²Θ_k`), per-ring dissipation
fractions `D k`, power `P`, Boltzmann constant `kB`, temperature `T`.

`Statement` is the conjunction of:
1. (`Dbar_le_arith_mean`) for `0 < K` and `D ≥ 0`, `D̄ ≤ (∑ D) / K` (AM–GM);
2. (`mrab_bound_le_baseRate`) for `P ≥ 0`, `kB > 0`, `T > 0`, `D ≥ 0`, `0 ≤ c ≤ 1`, the MRAB
   ceiling is at most the base rate;
3. (`mrab_saturation`) if every `c k = 1`, the ceiling equals the base rate;
4. (`mrab_reduces_to_IB`) at `K = 1` with `c 0 = 1`, the ceiling is `P · D 0 / κ`.

These are facts about a defined bound. They do not show that any layered system attains or obeys
it; no rate of any system appears in the statement.
-/

namespace ViridisStatements.P2.MultiRingAlignment

open scoped BigOperators

/-- Effective Landauer constant `κ = kB · T · ln 2` (canon `MRAB.kappa`). -/
noncomputable def kappa (kB T : ℝ) : ℝ := kB * T * Real.log 2

/-- Geometric-mean dissipation factor `D̄ = (∏_k D_k)^{1/K}` (canon `MRAB.Dbar`). -/
noncomputable def Dbar (K : ℕ) (D : Fin K → ℝ) : ℝ := (∏ k, D k) ^ ((1 : ℝ) / K)

/-- Alignment factor `∏_k c_k`, with `c_k` read as `cos²Θ_k` (canon `MRAB.alignFactor`). -/
noncomputable def alignFactor (K : ℕ) (c : Fin K → ℝ) : ℝ := ∏ k, c k

/-- Unaligned base rate `P · D̄ / κ` (canon `MRAB.baseRate`). -/
noncomputable def baseRate (K : ℕ) (P kB T : ℝ) (D : Fin K → ℝ) : ℝ :=
  P * Dbar K D / kappa kB T

/-- The MRAB ceiling `(P · D̄ / κ) · ∏_k c_k` (canon `MRAB.mrabBound`). -/
noncomputable def mrabBound (K : ℕ) (P kB T : ℝ) (D c : Fin K → ℝ) : ℝ :=
  baseRate K P kB T D * alignFactor K c

/-- **Proposed sealed target `P2.MultiRingAlignment`.** The four canon theorems, with their
canon hypotheses, in canon order. -/
def Statement : Prop :=
  -- 1. `Dbar_le_arith_mean`: geometric mean ≤ arithmetic mean.
  (∀ (K : ℕ), 0 < K → ∀ (D : Fin K → ℝ), (∀ k, 0 ≤ D k) →
    Dbar K D ≤ (∑ k, D k) / K) ∧
  -- 2. `mrab_bound_le_baseRate`: alignment can only shrink the ceiling.
  (∀ (K : ℕ) (P kB T : ℝ) (D c : Fin K → ℝ),
    0 ≤ P → 0 < kB → 0 < T → (∀ k, 0 ≤ D k) → (∀ k, 0 ≤ c k) → (∀ k, c k ≤ 1) →
    mrabBound K P kB T D c ≤ baseRate K P kB T D) ∧
  -- 3. `mrab_saturation`: perfect alignment saturates the ceiling.
  (∀ (K : ℕ) (P kB T : ℝ) (D c : Fin K → ℝ), (∀ k, c k = 1) →
    mrabBound K P kB T D c = baseRate K P kB T D) ∧
  -- 4. `mrab_reduces_to_IB`: one ring, perfectly aligned, gives `P · D / κ`.
  (∀ (P kB T : ℝ) (D c : Fin 1 → ℝ), c 0 = 1 →
    mrabBound 1 P kB T D c = P * D 0 / kappa kB T)

/-! ## Sanity checks

Equality and order on `ℝ` are not decidable, so real-valued checks use `norm_num` and short
rewrites; the arithmetic cores are also checked by `decide` over `ℚ` or `ℕ`. -/

/-- `κ` at `kB = T = 1` is `ln 2 > 0`; at `kB = 2, T = 3` it is `6 · ln 2`. -/
example : kappa 1 1 = Real.log 2 ∧ 0 < kappa 1 1 ∧ kappa 2 3 = 6 * Real.log 2 := by
  refine ⟨by simp [kappa], by simpa [kappa] using Real.log_pos one_lt_two, by
    unfold kappa; ring⟩

/-- The alignment factor multiplies per-ring factors: `(1/2) · (1/2) = 1/4` on two rings. -/
example : alignFactor 2 ![1/2, 1/2] = 1/4 := by
  norm_num [alignFactor, Fin.prod_univ_two]

/-- The same product in cleared form, by `decide` over `ℕ` (factors measured in halves, so the
product is in quarters): `1 · 1 = 1` quarter, and `1` quarter is below `2` quarters (`1/2`). -/
example : (1 * 1 : ℕ) = 1 ∧ (1 : ℕ) < 2 := by
  decide

/-- `D̄` is the geometric mean: for `D = (1/4, 1)`, `D̄ = (1/4)^{1/2} = 1/2`, below the
arithmetic mean `5/8`. -/
example : Dbar 2 ![1/4, 1] = 1/2 ∧ Dbar 2 ![1/4, 1] < (∑ k, (![1/4, 1] : Fin 2 → ℝ) k) / 2 := by
  have h : Dbar 2 ![1/4, 1] = 1/2 := by
    unfold Dbar
    rw [Fin.prod_univ_two]
    have h4 : (![1/4, 1] : Fin 2 → ℝ) 0 * (![1/4, 1] : Fin 2 → ℝ) 1 = (1/2 : ℝ) ^ (2 : ℝ) := by
      norm_num
    rw [h4, ← Real.rpow_mul (by norm_num)]
    norm_num
  refine ⟨h, ?_⟩
  rw [h, Fin.sum_univ_two]
  norm_num

/-- The AM–GM witness in cleared form, by `decide` over `ℕ` (values in eighths: `1/2 = 4/8`,
`1/4 = 2/8`, `1 = 8/8`): `4² = 2 · 8` and `2 · 4 < 2 + 8`, i.e. `1/2 < (1/4 + 1)/2`. -/
example : (4 ^ 2 : ℕ) = 2 * 8 ∧ (2 * 4 : ℕ) < 2 + 8 := by
  decide

/-- With one ring `D̄ = D 0` (exponent `1/1 = 1`). -/
example : Dbar 1 ![3/10] = 3/10 := by
  norm_num [Dbar]

/-- Base rate and ceiling with `P = 4`, `kB = T = 1`, `D = (1, 1)`, `c = (1/2, 1/2)`:
`baseRate = 4 / ln 2` and `mrabBound = (4 / ln 2) · (1/4) = 1 / ln 2`, strictly below. -/
example : baseRate 2 4 1 1 ![1, 1] = 4 / Real.log 2 ∧
    mrabBound 2 4 1 1 ![1, 1] ![1/2, 1/2] = 1 / Real.log 2 ∧
    mrabBound 2 4 1 1 ![1, 1] ![1/2, 1/2] < baseRate 2 4 1 1 ![1, 1] := by
  have hl : 0 < Real.log 2 := Real.log_pos one_lt_two
  have hb : baseRate 2 4 1 1 ![1, 1] = 4 / Real.log 2 := by
    norm_num [baseRate, Dbar, kappa, Fin.prod_univ_two]
  have hm : mrabBound 2 4 1 1 ![1, 1] ![1/2, 1/2] = 1 / Real.log 2 := by
    rw [mrabBound, hb]
    norm_num [alignFactor, Fin.prod_univ_two]
  refine ⟨hb, hm, ?_⟩
  rw [hm, hb]
  exact div_lt_div_of_pos_right (by norm_num) hl

/-! ## Negative controls -/

/-- `0 < K` is needed in part 1: at `K = 0` the empty product gives `D̄ = 1^{1/0} = 1`, while
the arithmetic mean is `0 / 0 = 0` in Lean. -/
example : ¬ (Dbar 0 (fun _ => 0) ≤ (∑ k : Fin 0, (fun _ => (0 : ℝ)) k) / (0 : ℕ)) := by
  norm_num [Dbar]

/-- `D ≥ 0` is needed in part 1: for `D = (−1, −1)` the product is `1`, so `D̄ = 1`, while the
arithmetic mean is `−1`. -/
example : ¬ (Dbar 2 ![-1, -1] ≤ (∑ k, (![-1, -1] : Fin 2 → ℝ) k) / (2 : ℕ)) := by
  norm_num [Dbar, Fin.prod_univ_two, Fin.sum_univ_two]

/-- `c ≤ 1` is needed in part 2: with an alignment factor `c = 2` on one ring (not a `cos²`),
`P = D = kB = T = 1`, the ceiling `2 / ln 2` exceeds the base rate `1 / ln 2`. -/
example : baseRate 1 1 1 1 ![1] < mrabBound 1 1 1 1 ![1] ![2] := by
  have hl : 0 < Real.log 2 := Real.log_pos one_lt_two
  have hb : baseRate 1 1 1 1 ![1] = 1 / Real.log 2 := by
    norm_num [baseRate, Dbar, kappa]
  have hm : mrabBound 1 1 1 1 ![1] ![2] = 2 / Real.log 2 := by
    rw [mrabBound, hb]
    norm_num [alignFactor]
    ring
  rw [hb, hm]
  exact div_lt_div_of_pos_right (by norm_num) hl

/-- Imperfect alignment does not saturate: `c = (1/2)` on one ring with a positive base rate
gives a ceiling different from the base rate, so part 3 needs every `c k = 1`. -/
example : mrabBound 1 1 1 1 ![1] ![1/2] ≠ baseRate 1 1 1 1 ![1] := by
  norm_num [mrabBound, baseRate, alignFactor, Dbar, kappa]

/-- Part 2 compares the ceiling with the base rate *at the same rings*; it is not a monotonicity
in `K`. Adding a perfectly aligned ring with `D = 1` to a single ring with `D = 1/4` raises `D̄`
from `1/4` to `1/2`, so the ceiling (at `P = kB = T = 1`) rises from `(1/4)/ln 2` to `(1/2)/ln 2`. -/
example : mrabBound 1 1 1 1 ![1/4] ![1] < mrabBound 2 1 1 1 ![1/4, 1] ![1, 1] := by
  have hl : 0 < Real.log 2 := Real.log_pos one_lt_two
  have hD : Dbar 2 ![1/4, 1] = 1/2 := by
    unfold Dbar
    rw [Fin.prod_univ_two]
    have h4 : (![1/4, 1] : Fin 2 → ℝ) 0 * (![1/4, 1] : Fin 2 → ℝ) 1 = (1/2 : ℝ) ^ (2 : ℝ) := by
      norm_num
    rw [h4, ← Real.rpow_mul (by norm_num)]
    norm_num
  have h1 : mrabBound 1 1 1 1 ![1/4] ![1] = (1/4) / Real.log 2 := by
    norm_num [mrabBound, baseRate, alignFactor, Dbar, kappa]
  have h2 : mrabBound 2 1 1 1 ![1/4, 1] ![1, 1] = (1/2) / Real.log 2 := by
    unfold mrabBound baseRate
    rw [hD]
    norm_num [alignFactor, kappa, Fin.prod_univ_two]
  rw [h1, h2]
  exact div_lt_div_of_pos_right (by norm_num) hl

/-- The statement is about a defined ceiling, not about any system: a rate tied to nothing can
exceed it. With `P = 0` the ceiling is `0`, and the rate `1` is above it. -/
example : ¬ (∀ rate : ℝ, rate ≤ mrabBound 1 0 1 1 ![1] ![1]) := by
  intro h
  have := h 1
  norm_num [mrabBound, baseRate, alignFactor, Dbar, kappa] at this

end ViridisStatements.P2.MultiRingAlignment
