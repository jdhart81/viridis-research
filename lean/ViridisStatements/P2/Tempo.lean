import Mathlib

/-!
# P2 · re-certification: Tempo, the stewardship-cadence kernel

The live Viridis OS Tempo kernel picks a monitoring cadence (interval between visits) that
balances the cost of acting too often against the cost of acting too rarely. Its registry entry
(`Tempo_function.json`, viridis-canon commit 6a177d6b1a779f38c9215bd618f17f9be29cc253) names six
theorems in a Lean module `StewardshipTempo`: `Sigma_strictConvexOn`, `tempo_floor`,
`tempo_optimum`, `tempo_unique_minimizer`, `haste_neglect_cosh` and `governability_tax`.
The canon repository holds no Lean source for that module, so this module is a **reconstruction**
of the formal core from what the kernel's reference runner (`Tempo_runner.py`, same commit)
computes. It was then compared with the theorem signatures of a `StewardshipTempo.lean` listed in
the Zenodo record behind the registry DOI 10.5281/zenodo.20705183 (namespace `ViridisForge.Tempo`,
cost `A / τ + B * τ`). Each deposited signature is included below, up to renaming
`A B τ ↦ h n t` and folding the explicit formulas into the definitions.

Model (an assumption about a stewardship programme, not a result): with haste cost `h > 0`,
neglect cost `n > 0` and cadence `t > 0`, the cost per unit time is `Sigma(t) = h / t + n * t`.
The runner reports
* `optimal_cadence = sqrt (h / n)`,
* `tempo_floor = 2 * sqrt (h * n)`,
* `cadence_cost = h / t + n * t`,
* `normalized_cost = cadence_cost / tempo_floor`,
* `haste_neglect_tax = cosh (log (t / optimal_cadence))`.

`Statement`: for all real `h > 0`, `n > 0`,
(1) `Sigma` is strictly convex on `(0, ∞)`;
(2) `Sigma t ≥ 2 * sqrt (h * n)` for every `t > 0`;
(3) `Sigma (sqrt (h / n)) = 2 * sqrt (h * n)`;
(4) `sqrt (h / n)` is the only `t > 0` with `Sigma t = 2 * sqrt (h * n)`;
(5) `(u + 1/u)/2 = cosh (log u)` for `u > 0`, and hence
    `Sigma t / (2 * sqrt (h * n)) = cosh (log (t / sqrt (h / n)))` for every `t > 0`;
(6) for every `t > 0`, `Sigma t / (2 * sqrt (h * n)) = cosh (log (sqrt (h / n) / t))` (deposited
    orientation), the tax is at least `1`, and it equals `1` exactly when `t = sqrt (h / n)`.
-/

namespace ViridisStatements.P2.Tempo

/-- Cadence cost `Sigma(t) = h / t + n * t` (runner: `cadence_cost`). -/
noncomputable def Sigma (h n t : ℝ) : ℝ :=
  h / t + n * t

/-- Optimal cadence `sqrt (h / n)` (runner: `optimal_cadence`). -/
noncomputable def optimum (h n : ℝ) : ℝ :=
  Real.sqrt (h / n)

/-- Tempo floor `2 * sqrt (h * n)` (runner: `tempo_floor`). -/
noncomputable def floor (h n : ℝ) : ℝ :=
  2 * Real.sqrt (h * n)

/-- Normalised cost `Sigma(t) / floor` (runner: `normalized_cost`). -/
noncomputable def normalizedCost (h n t : ℝ) : ℝ :=
  Sigma h n t / floor h n

/-- Haste–neglect (governability) tax `cosh (log (t / optimum))` (runner: `haste_neglect_tax`). -/
noncomputable def tax (h n t : ℝ) : ℝ :=
  Real.cosh (Real.log (t / optimum h n))

/-- **Proposed sealed target `P2.Tempo`.** For haste cost `h > 0` and neglect cost `n > 0`, one
numbered part per registry theorem name:
(1) `Sigma_strictConvexOn`, (2) `tempo_floor`, (3) `tempo_optimum`, (4) `tempo_unique_minimizer`,
(5) `haste_neglect_cosh`: the identity `(u + 1/u)/2 = cosh (log u)` for `u > 0`, as deposited, and
its kernel form `normalizedCost = tax`;
(6) `governability_tax`: the deposited form `normalizedCost = cosh (log (optimum / t))`, plus the
runner-facing facts `1 ≤ tax` and `tax = 1 ↔ t = optimum`. -/
def Statement : Prop :=
  ∀ h n : ℝ, 0 < h → 0 < n →
    -- (1) Sigma_strictConvexOn
    StrictConvexOn ℝ (Set.Ioi 0) (Sigma h n) ∧
    -- (2) tempo_floor
    (∀ t : ℝ, 0 < t → floor h n ≤ Sigma h n t) ∧
    -- (3) tempo_optimum
    Sigma h n (optimum h n) = floor h n ∧
    -- (4) tempo_unique_minimizer
    (∀ t : ℝ, 0 < t → Sigma h n t = floor h n → t = optimum h n) ∧
    -- (5) haste_neglect_cosh
    ((∀ u : ℝ, 0 < u → (u + 1 / u) / 2 = Real.cosh (Real.log u)) ∧
      (∀ t : ℝ, 0 < t → normalizedCost h n t = tax h n t)) ∧
    -- (6) governability_tax
    (∀ t : ℝ, 0 < t →
      normalizedCost h n t = Real.cosh (Real.log (optimum h n / t)) ∧
      1 ≤ tax h n t ∧ (tax h n t = 1 ↔ t = optimum h n))

/-! ## Sanity checks

Over `ℝ` these cannot be closed by `decide` (real equality is not decidable), so they are
closed by `norm_num` and short rewrites, as in the other sealed P2 modules. They pin the meaning
of the definitions on the registry's published example `h = 4`, `n = 1`, `t = 2`, whose expected
outputs are optimum `2`, floor `4`, cost `4`, normalised cost `1`, tax `1`. -/

/-- `sqrt 4 = 2`, used by the examples below. -/
theorem sqrt_four : Real.sqrt 4 = 2 := by
  rw [show (4 : ℝ) = 2 ^ 2 by norm_num]
  exact Real.sqrt_sq (by norm_num)

/-- Published example: optimum `sqrt (4 / 1) = 2` and floor `2 * sqrt (4 * 1) = 4`. -/
example : optimum 4 1 = 2 ∧ floor 4 1 = 4 := by
  refine ⟨?_, ?_⟩
  · rw [optimum, div_one, sqrt_four]
  · rw [floor, mul_one, sqrt_four]; norm_num

/-- Published example: cost `4 / 2 + 1 * 2 = 4`, which equals the floor. -/
example : Sigma 4 1 2 = 4 ∧ Sigma 4 1 2 = floor 4 1 := by
  refine ⟨by norm_num [Sigma], ?_⟩
  rw [floor, mul_one, sqrt_four]; norm_num [Sigma]

/-- Published example: normalised cost `4 / 4 = 1` and tax `cosh (log (2 / 2)) = cosh 0 = 1`. -/
example : normalizedCost 4 1 2 = 1 ∧ tax 4 1 2 = 1 := by
  refine ⟨?_, ?_⟩
  · rw [normalizedCost, floor, mul_one, sqrt_four]; norm_num [Sigma]
  · rw [tax, optimum, div_one, sqrt_four]; norm_num

/-- A second witness off the published example: `h = 1`, `n = 4` gives optimum `sqrt (1/4) = 1/2`,
floor `2 * sqrt 4 = 4`, and `Sigma (1/2) = 2 + 2 = 4`. -/
example : optimum 1 4 = 1 / 2 ∧ floor 1 4 = 4 ∧ Sigma 1 4 (1 / 2) = 4 := by
  refine ⟨?_, ?_, by norm_num [Sigma]⟩
  · rw [optimum, show (1 : ℝ) / 4 = (1 / 2) ^ 2 by norm_num]
    exact Real.sqrt_sq (by norm_num)
  · rw [floor, one_mul, sqrt_four]; norm_num

/-- Negative control (off-optimum cadence): `h = 4`, `n = 1`, `t = 1` gives cost
`4 / 1 + 1 * 1 = 5`, strictly above the floor `4`, and normalised cost `5 / 4 > 1`. -/
example : Sigma 4 1 1 = 5 ∧ floor 4 1 < Sigma 4 1 1 ∧ 1 < normalizedCost 4 1 1 := by
  refine ⟨by norm_num [Sigma], ?_, ?_⟩
  · rw [floor, mul_one, sqrt_four]; norm_num [Sigma]
  · rw [normalizedCost, floor, mul_one, sqrt_four]; norm_num [Sigma]

/-- Witness for parts (5) and (6) off the optimum: at `h = 4`, `n = 1`, `t = 1` the normalised
cost is `5 / 4`, and `cosh (log 2) = (2 + 1/2) / 2 = 5 / 4` as well, in the deposited orientation
`log (optimum / t) = log 2`. -/
example : normalizedCost 4 1 1 = 5 / 4 ∧
    Real.cosh (Real.log (optimum 4 1 / 1)) = 5 / 4 := by
  have ho : optimum 4 1 = 2 := by rw [optimum, div_one, sqrt_four]
  refine ⟨?_, ?_⟩
  · rw [normalizedCost, floor, mul_one, sqrt_four]; norm_num [Sigma]
  · rw [ho, div_one, Real.cosh_log (by norm_num)]; norm_num

/-- Negative control (hypotheses matter): with a negative cadence `t = -2` the cost
`4 / (-2) + 1 * (-2) = -4` is below the floor `4`, so part (2) needs `t > 0`. -/
example : Sigma 4 1 (-2) < floor 4 1 := by
  rw [floor, mul_one, sqrt_four]; norm_num [Sigma]

/-- Negative control (hypotheses matter): parts (5) and (6) need `n > 0`. With `n = 0` Lean's
convention `x / 0 = 0` gives optimum `sqrt (4 / 0) = 0` and floor `0`, so the normalised cost is
`0` while the tax is `cosh (log (1 / 0)) = cosh 0 = 1`; and the tax equals `1` at `t = 1`,
which is not the "optimum" `0`. -/
example : optimum 4 0 = 0 ∧ normalizedCost 4 0 1 = 0 ∧ tax 4 0 1 = 1 ∧ (1 : ℝ) ≠ optimum 4 0 := by
  have h0 : optimum 4 0 = 0 := by simp [optimum]
  refine ⟨h0, by simp [normalizedCost, floor], ?_, by rw [h0]; norm_num⟩
  rw [tax, h0]; simp

/-- Negative control (hypotheses matter): part (1) needs `h > 0`. With `h = 0` the cost is
linear, `Sigma 0 1 t = t`, so the midpoint of `t = 1` and `t = 3` meets the chord exactly:
`Sigma 0 1 2 = 2 = (Sigma 0 1 1 + Sigma 0 1 3) / 2`, and strict convexity fails. -/
example : Sigma 0 1 ((1 + 3) / 2) = (Sigma 0 1 1 + Sigma 0 1 3) / 2 := by
  norm_num [Sigma]

end ViridisStatements.P2.Tempo
