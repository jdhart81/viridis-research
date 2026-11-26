import Mathlib

/-!
# P6 · Serial and parallel route reliability

Model: a route is a chain of corridor links indexed by a finite set `s`; link `i` is crossed with
probability `p i ∈ [0, 1]`. The serial success probability of the route is the product
`serial s p = ∏ i ∈ s, p i`. Given alternative routes indexed by `s` with success probabilities
`q i ∈ [0, 1]`, the expression `parallel s q = 1 - ∏ i ∈ s, (1 - q i)` is the probability that at
least one succeeds *if the routes fail independently*. Independence is a field assumption and is
not part of the mathematics below: `parallel` is just a real-valued formula.

`Statement`:
1. serial: if every `p i ∈ [0, 1]` for `i ∈ s`, then `serial s p ≤ p j` for every `j ∈ s`
   (a route is no stronger than its weakest link);
2. parallel: if every `q i ∈ [0, 1]` for `i ∈ s`, then `q j ≤ parallel s q ≤ 1` for every `j ∈ s`
   (alternatives are never worse than the best single route);
3. two routes, equality: for `p, q ∈ [0, 1]`,
   `1 - (1 - p) * (1 - q) = max p q ↔ (min p q = 0 ∨ max p q = 1)`.

Part 1 is the same inequality as part 3 of `P3.CascadedRecovery` with `p i = 1 - r i`; it is
restated here self-contained. No claim is made about any real link probability.
-/

namespace ViridisStatements.P6.SerialParallel

/-- Success probability of a route whose links have crossing probabilities `p`. -/
def serial {ι : Type} (s : Finset ι) (p : ι → ℝ) : ℝ := ∏ i ∈ s, p i

/-- Probability that at least one of the routes `s` succeeds, under independence. -/
def parallel {ι : Type} (s : Finset ι) (q : ι → ℝ) : ℝ := 1 - ∏ i ∈ s, (1 - q i)

/-- **Proposed sealed target `P6.SerialParallel`.** -/
def Statement : Prop :=
  (∀ (ι : Type) (s : Finset ι) (p : ι → ℝ), (∀ i ∈ s, 0 ≤ p i ∧ p i ≤ 1) →
      ∀ j ∈ s, serial s p ≤ p j) ∧
  (∀ (ι : Type) (s : Finset ι) (q : ι → ℝ), (∀ i ∈ s, 0 ≤ q i ∧ q i ≤ 1) →
      ∀ j ∈ s, q j ≤ parallel s q ∧ parallel s q ≤ 1) ∧
  (∀ p q : ℝ, 0 ≤ p → p ≤ 1 → 0 ≤ q → q ≤ 1 →
      (1 - (1 - p) * (1 - q) = max p q ↔ (min p q = 0 ∨ max p q = 1)))

/-! ## Sanity checks -/

/-- Two links of `1/2` in series: the route succeeds with probability `1/4 < 1/2`. -/
example : serial Finset.univ ![(1/2 : ℝ), 1/2] = 1/4 ∧
    serial Finset.univ ![(1/2 : ℝ), 1/2] < 1/2 := by
  norm_num [serial, Fin.prod_univ_two]

/-- Two independent routes of `1/2` in parallel: at least one succeeds with probability
`3/4 > 1/2`, strictly above the best route. -/
example : parallel Finset.univ ![(1/2 : ℝ), 1/2] = 3/4 ∧
    1/2 < parallel Finset.univ ![(1/2 : ℝ), 1/2] := by
  norm_num [parallel, Fin.prod_univ_two]

/-- Part 3 at `p = q = 1/2`: the left side is `3/4`, not `max p q = 1/2`, and indeed neither
`min p q = 0` nor `max p q = 1`. -/
example : 1 - (1 - (1/2 : ℝ)) * (1 - 1/2) ≠ max (1/2 : ℝ) (1/2) ∧
    ¬ (min (1/2 : ℝ) (1/2) = 0 ∨ max (1/2 : ℝ) (1/2) = 1) := by
  norm_num

/-- Part 3 equality cases: a dead alternative (`q = 0`) or a sure route (`p = 1`). -/
example : 1 - (1 - (1/2 : ℝ)) * (1 - 0) = max (1/2 : ℝ) 0 ∧
    1 - (1 - (1 : ℝ)) * (1 - 1/2) = max (1 : ℝ) (1/2) := by
  norm_num

/-- Negative control for part 1: with an out-of-range "probability" `2`, links `2` and `1/2`
have product `1 > 1/2`, so the bound `p i ≤ 1` cannot be dropped. -/
example : 1/2 < serial Finset.univ ![(2 : ℝ), 1/2] := by
  norm_num [serial, Fin.prod_univ_two]

end ViridisStatements.P6.SerialParallel
