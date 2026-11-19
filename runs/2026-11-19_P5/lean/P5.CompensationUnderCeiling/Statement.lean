import Mathlib

/-!
# P5 · Compensation under a power ceiling

`Non_Substitutability_Complete.lean` (SHA-256 `8b1194634…bee273`) introduces a theorem named
`no_finite_compensation` with prose saying no finite power increase compensates a loss of `D`,
but its formal text proves that the finite power `P + P·ΔD/(D − ΔD) = P·D/(D − ΔD)` restores the
bound exactly. This module separates the four facts that the prose mixes, for the capacity
algebra `cap P D C = P · D / C` restated over Mathlib only.

`Statement` is the conjunction of:
1. (interior) for `0 < C`, `0 < P`, `0 < dD < D`, the power `P·D/(D − dD)` restores the
   capacity after the loss, and it is the only power that does;
2. (ceiling) if moreover `P ≤ Pmax`, then some power `P' ≤ Pmax` restores the capacity iff
   `dD ≤ D·(1 − P/Pmax)`;
3. (divergence) for `0 < C, P, D`, the compensating power `P·D/(D − dD)` exceeds any bound `M`
   once `dD < D` is close enough to `D`;
4. (complete loss) for `0 < C, P, D`, at `D = 0` every power gives capacity `0`, strictly below
   `cap P D C`; so no power restores a positive capacity.

The result is elementary; it is a correction, not a new theorem. It says nothing about whether
any agent preserves biodiversity, and nothing about the Intelligence Bound as a physical
conjecture.
-/

noncomputable section

namespace ViridisStatements.P5.CompensationUnderCeiling

/-- Capacity `P · D / C` at power `P`, diversity fraction `D` and per-bit cost `C`. -/
def cap (P D C : ℝ) : ℝ := P * D / C

/-- **Proposed sealed target `P5.CompensationUnderCeiling`.** -/
def Statement : Prop :=
  -- 1. Interior: finite compensation exists and is unique.
  (∀ P D dD C : ℝ, 0 < C → 0 < P → 0 < dD → dD < D →
    cap (P * D / (D - dD)) (D - dD) C = cap P D C ∧
    ∀ P' : ℝ, cap P' (D - dD) C = cap P D C → P' = P * D / (D - dD)) ∧
  -- 2. Ceiling: compensation within `Pmax` is possible exactly when `dD ≤ D·(1 − P/Pmax)`.
  (∀ P D dD C Pmax : ℝ, 0 < C → 0 < P → 0 < dD → dD < D → P ≤ Pmax →
    ((∃ P' : ℝ, P' ≤ Pmax ∧ cap P' (D - dD) C = cap P D C) ↔ dD ≤ D * (1 - P / Pmax))) ∧
  -- 3. Divergence: the compensating power is unbounded as `dD → D⁻`.
  (∀ P D C : ℝ, 0 < C → 0 < P → 0 < D →
    ∀ M : ℝ, ∃ δ : ℝ, 0 < δ ∧ ∀ dD : ℝ, D - δ < dD → dD < D → M < P * D / (D - dD)) ∧
  -- 4. Complete loss: at `D = 0` no power restores a positive capacity.
  (∀ P D C : ℝ, 0 < C → 0 < P → 0 < D →
    ∀ P' : ℝ, cap P' 0 C = 0 ∧ cap P' 0 C < cap P D C)

/-! ## Sanity checks -/

/-- Witness: `P = D = C = 1`, `dD = 1/2` needs compensating power `2`, and `2` restores the
capacity `1`. -/
example : (1 : ℝ) * 1 / (1 - 1/2) = 2 ∧ cap 2 (1 - 1/2) 1 = cap 1 1 1 := by
  norm_num [cap]

/-- The same witness with denominators cleared, checked by `decide` over `ℤ`: measuring `D`
and `dD` in halves (`D = 2`, `dD = 1`), the compensating power `P' = 2` is the unique integer in
`[0, 10]` with `P'·(D − dD) = P·D`. -/
example : (2 : ℤ) * (2 - 1) = 1 * 2 ∧
    ∀ P' : Fin 11, ((P' : ℕ) : ℤ) * (2 - 1) = 1 * 2 → (P' : ℕ) = 2 := by
  decide

/-- Ceiling `Pmax = 2`: the condition holds with equality, `1/2 ≤ 1 · (1 − 1/2)`. -/
example : (1/2 : ℝ) ≤ 1 * (1 - 1 / 2) ∧ (1/2 : ℝ) = 1 * (1 - 1 / 2) := by
  norm_num

/-- Ceiling `Pmax = 3/2`: the condition fails, `1/2 > 1 · (1 − 2/3) = 1/3`, matching the fact
that the required power `2` exceeds `3/2`. -/
example : ¬ ((1/2 : ℝ) ≤ 1 * (1 - 1 / (3/2))) ∧ (3/2 : ℝ) < 2 := by
  norm_num

/-- Both ceiling checks in the cleared form `P·D ≤ Pmax·(D − dD)` (equivalent to the ceiling
condition when `Pmax > 0` and `dD < D`), checked by `decide` over `ℤ`. With `D = 2, dD = 1`
(halves): `Pmax = 2, P = 1` gives `2 ≤ 2` (equality); scaling powers by `2`, `Pmax = 3/2, P = 1`
becomes `Pmax = 3, P = 2` and gives `4 ≤ 3`, which fails. -/
example : ((1 : ℤ) * 2 ≤ 2 * (2 - 1) ∧ (1 : ℤ) * 2 = 2 * (2 - 1)) ∧
    ¬ ((2 : ℤ) * 2 ≤ 3 * (2 - 1)) := by
  decide

/-- Complete loss: at `D = 0` the capacity is `0` whatever the power. -/
example : cap 1000 0 1 = 0 ∧ cap 1000 0 1 < cap 1 1 1 := by
  norm_num [cap]

/-- Negative control for part 2 without `P ≤ Pmax`: with `Pmax = -1`, `P = D = C = 1`,
`dD = 1/2`, the right side `1/2 ≤ 1·(1 − 1/(−1)) = 2` holds, but no `P' ≤ −1` restores the
capacity (it would need `P'·(1/2) = 1`). -/
example : (1/2 : ℝ) ≤ 1 * (1 - 1 / (-1)) ∧
    ¬ (∃ P' : ℝ, P' ≤ -1 ∧ cap P' (1 - 1/2) 1 = cap 1 1 1) := by
  refine ⟨by norm_num, ?_⟩
  rintro ⟨P', hP', h⟩
  simp only [cap] at h
  linarith

/-- Negative control for part 2 without `dD < D`: with `P = D = C = Pmax = 1` and `dD = 2`,
the negative power `P' = −1` satisfies `P' ≤ Pmax` and `cap (−1) (1 − 2) 1 = cap 1 1 1`, but
the right side `2 ≤ 1·(1 − 1/1) = 0` fails. -/
example : ((-1 : ℝ) ≤ 1 ∧ cap (-1) (1 - 2) 1 = cap 1 1 1) ∧ ¬ ((2 : ℝ) ≤ 1 * (1 - 1 / 1)) := by
  norm_num [cap]

end ViridisStatements.P5.CompensationUnderCeiling
