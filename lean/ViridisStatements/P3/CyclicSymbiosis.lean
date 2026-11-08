import Mathlib

/-!
# P3 · Cyclic industrial symbiosis: the N-partner product condition

Generalises the two-partner Reciprocity Corridor (canon Run-128,
`series/RC/PaperFormalization.lean`, copied as `context/ReciprocityCorridor.lean`) to a cycle
of `N ≥ 2` partners. Restated over Mathlib only.

Model: partners are indexed by `Fin N` and arranged in a cycle. Partner `i`
* ships a by-product flow `x i` to partner `i + 1` at cost `c i · x i` (`c i > 0`);
* receives the flow `x (i - 1)` of its predecessor, worth `v i · x (i - 1)` to it (`v i > 0`);
  indices are taken mod `N` (`prev i = (i + N - 1) mod N`).
Net benefit of partner `i`: `v i · x (prev i) - c i · x i` (linear, separable, one period, no
externalities; the Run-128 standing assumptions).

`Statement`: for `N ≥ 2` and positive `c, v`, there is a strictly positive flow `x` giving
every partner strictly positive net benefit **iff** `∏ c i < ∏ v i`.

For `N = 2` the cycle is the Run-128 bilateral exchange (`x 0 = x`, `x 1 = y`,
`v 0 = vX`, `c 0 = cX`, `v 1 = vY`, `c 1 = cY`), the net benefits are Run-128's `uX`, `uY`, and
`∏ c < ∏ v` is Run-128's `ProductCondition vX cX vY cY := cX * cY < vX * vY`; the sanity
checks below verify this agreement.

No claim is made about any real cost, value, partner or material.
-/

namespace ViridisStatements.P3.CyclicSymbiosis

/-- Predecessor on the cycle `Fin N`: `prev i = (i + N - 1) mod N`. -/
def prev {N : ℕ} (i : Fin N) : Fin N :=
  ⟨(i.val + (N - 1)) % N, Nat.mod_lt _ (Nat.zero_lt_of_lt i.isLt)⟩

/-- Net benefit of partner `i`: value of the received flow minus cost of the shipped flow. -/
def net {N : ℕ} (c v x : Fin N → ℝ) (i : Fin N) : ℝ := v i * x (prev i) - c i * x i

/-- A strictly positive flow giving every partner strictly positive net benefit. -/
def StrictlyBeneficialFlow {N : ℕ} (c v x : Fin N → ℝ) : Prop :=
  (∀ i, 0 < x i) ∧ ∀ i, 0 < net c v x i

/-- The N-partner product condition `∏ c i < ∏ v i`. -/
def CycleProductCondition {N : ℕ} (c v : Fin N → ℝ) : Prop := ∏ i, c i < ∏ i, v i

/-- Run-128's two-partner product condition, copied verbatim (argument order `vX cX vY cY`). -/
def ProductCondition (vX cX vY cY : ℝ) : Prop := cX * cY < vX * vY

/-- **Proposed sealed target `P3.CyclicSymbiosis`.** -/
def Statement : Prop :=
  ∀ (N : ℕ), 2 ≤ N → ∀ c v : Fin N → ℝ, (∀ i, 0 < c i) → (∀ i, 0 < v i) →
    ((∃ x : Fin N → ℝ, StrictlyBeneficialFlow c v x) ↔ CycleProductCondition c v)

/-! ## Sanity checks -/

/-- The cycle structure on `Fin 3`: `0 ← 2`, `1 ← 0`, `2 ← 1`. -/
example : prev (0 : Fin 3) = 2 ∧ prev (1 : Fin 3) = 0 ∧ prev (2 : Fin 3) = 1 := by decide

/-- On `Fin 2` each partner's predecessor is the other partner. -/
example : prev (0 : Fin 2) = 1 ∧ prev (1 : Fin 2) = 0 := by decide

/-- `N = 2` agreement, condition: the cycle product condition is Run-128's
`ProductCondition vX cX vY cY`. -/
example (vX cX vY cY : ℝ) :
    CycleProductCondition ![cX, cY] ![vX, vY] ↔ ProductCondition vX cX vY cY := by
  simp [CycleProductCondition, ProductCondition, Fin.prod_univ_two]

/-- `N = 2` agreement, payoffs: partner `0` nets Run-128's `uX = vX*y - cX*x` and partner `1`
nets `uY = vY*x - cY*y` at the flow `![x, y]`. -/
example (vX cX vY cY x y : ℝ) :
    net ![cX, cY] ![vX, vY] ![x, y] 0 = vX * y - cX * x ∧
    net ![cX, cY] ![vX, vY] ![x, y] 1 = vY * x - cY * y := by
  have h0 : prev (0 : Fin 2) = 1 := by decide
  have h1 : prev (1 : Fin 2) = 0 := by decide
  simp [net, h0, h1]

/-- Three-partner witness: `c = (1,1,1)`, `v = (4, 1/2, 1)`, so `∏ c = 1 < 2 = ∏ v`. -/
example : CycleProductCondition ![(1 : ℝ), 1, 1] ![(4 : ℝ), 1/2, 1] := by
  simp only [CycleProductCondition, Fin.prod_univ_three, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.cons_val_two, Matrix.head_cons, Matrix.tail_cons]
  norm_num

/-- The flow must be tuned: in the same economy the uniform flow `x = (1,1,1)` leaves
partner `1` with net benefit `1/2 - 1 < 0`, while the flow `x = (1, 9/20, 2/5)` benefits all
three partners (nets `3/5`, `1/20`, `1/20`). -/
example :
    net ![(1 : ℝ), 1, 1] ![(4 : ℝ), 1/2, 1] ![1, 1, 1] 1 < 0 ∧
    StrictlyBeneficialFlow ![(1 : ℝ), 1, 1] ![(4 : ℝ), 1/2, 1] ![1, 9/20, 2/5] := by
  have h0 : prev (0 : Fin 3) = 2 := by decide
  have h1 : prev (1 : Fin 3) = 0 := by decide
  have h2 : prev (2 : Fin 3) = 1 := by decide
  refine ⟨?_, ?_, ?_⟩
  · simp only [net, h1, Matrix.cons_val_zero, Matrix.cons_val_one]
    norm_num
  · intro i; fin_cases i <;> simp
  · intro i
    fin_cases i
    · simp only [net, Fin.zero_eta, h0]; simp; norm_num
    · simp only [net, Fin.mk_one, h1]; simp; norm_num
    · simp only [net]
      rw [show (⟨2, by decide⟩ : Fin 3) = 2 from rfl, h2]; simp; norm_num

/-- Negative control: `c = (2,2,2)`, `v = (1,1,1)` fails the product condition
(`8 < 1` is false), and the uniform flow indeed harms every partner. -/
example : ¬ CycleProductCondition ![(2 : ℝ), 2, 2] ![(1 : ℝ), 1, 1] ∧
    net ![(2 : ℝ), 2, 2] ![(1 : ℝ), 1, 1] ![1, 1, 1] 0 < 0 := by
  have h0 : prev (0 : Fin 3) = 2 := by decide
  constructor
  · simp only [CycleProductCondition, Fin.prod_univ_three, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.cons_val_two, Matrix.head_cons, Matrix.tail_cons]
    norm_num
  · simp only [net, h0]; simp

/-- Negative control: equality of products is not enough. With `c = v = (1,1)` the boundary
case `∏ c = ∏ v` fails the strict condition. -/
example : ¬ CycleProductCondition ![(1 : ℝ), 1] ![(1 : ℝ), 1] := by
  simp [CycleProductCondition, Fin.prod_univ_two]

end ViridisStatements.P3.CyclicSymbiosis
