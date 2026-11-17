import Mathlib

/-!
# P3 · Recovery-adjusted work floor

Extends `target_requires_supply` of the Useful and Dissipated Work Ledger (canon Run-163,
`series/UDWL/ViridisRun163.lean`, copied as `context/UsefulDissipatedWork.lean`) from two
generic supplies to a *fresh* supply `wf` and a *recovered* supply `wr`.

Model (restated over Mathlib only; same algebra as Run-163 `useful w1 w2 e1 e2` with
`w1 = wf`, `w2 = wr`):
* supplies `wf, wr ≥ 0`;
* modeled conversion efficiencies `ef, er ∈ [0, emax]` with a common cap `emax > 0`;
* useful work `U = ef·wf + er·wr`.

`Statement`:
1. (floor) if `U ≥ T` then `wf ≥ (T - emax·wr) / emax`;
2. (attainment) for every `emax > 0`, `wr ≥ 0` and target `T ≥ emax·wr`, the fresh supply
   `wf = (T - emax·wr)/emax` is nonnegative and, run at `ef = er = emax`, delivers exactly `T`;
   so the floor in part 1 cannot be raised.

`emax` is a bound on *modeled* efficiency. The statement is not a Landauer bound, does not use
the Intelligence Bound, and makes no claim about any real efficiency or recovered supply.
-/

noncomputable section

namespace ViridisStatements.P3.RecoveryWorkFloor

/-- Useful work from fresh supply `wf` at efficiency `ef` and recovered supply `wr` at
efficiency `er`. -/
def useful (wf wr ef er : ℝ) : ℝ := ef * wf + er * wr

/-- The fresh-supply floor `(T - emax·wr) / emax`. -/
def freshFloor (T wr emax : ℝ) : ℝ := (T - emax * wr) / emax

/-- **Proposed sealed target `P3.RecoveryWorkFloor`.** -/
def Statement : Prop :=
  (∀ wf wr ef er emax T : ℝ, 0 ≤ wf → 0 ≤ wr →
    0 ≤ ef → ef ≤ emax → 0 ≤ er → er ≤ emax → 0 < emax →
    T ≤ useful wf wr ef er → freshFloor T wr emax ≤ wf) ∧
  (∀ wr emax T : ℝ, 0 < emax → 0 ≤ wr → emax * wr ≤ T →
    0 ≤ freshFloor T wr emax ∧ useful (freshFloor T wr emax) wr emax emax = T)

/-! ## Sanity checks -/

/-- The Run-163 witness `(w1, w2, e1, e2) = (8, 4, 3/4, 1/2)` read as fresh `8`, recovered `4`:
useful work `8`; with `emax = 3/4` and `T = 8` the floor is `20/3 ≤ 8`. -/
example : useful 8 4 (3/4) (1/2) = 8 ∧ freshFloor 8 4 (3/4) = 20/3 ∧
    freshFloor 8 4 (3/4) ≤ (8 : ℝ) := by
  norm_num [useful, freshFloor]

/-- Attainment witness: `emax = 1/2`, recovered `4`, target `8` give floor `12`, and
`12` units of fresh supply at efficiency `1/2` reach the target exactly. -/
example : freshFloor 8 4 (1/2) = 12 ∧ useful 12 4 (1/2) (1/2) = 8 := by
  norm_num [freshFloor, useful]

/-- Recovery lowers the floor: with no recovered supply the same target needs `16`. -/
example : freshFloor 8 4 (1/2) < freshFloor 8 0 (1/2) := by
  norm_num [freshFloor]

/-- Negative control: fresh supply below the floor (`11 < 12`) cannot reach the target even at
the cap, `useful 11 4 (1/2) (1/2) = 15/2 < 8`. -/
example : useful 11 4 (1/2) (1/2) < 8 := by
  norm_num [useful]

/-- Negative control: the efficiency cap matters. An efficiency `1` above the cap `1/2`
reaches `8` with fresh supply `4`, below the floor `12`. -/
example : useful 4 4 1 1 = 8 ∧ (4 : ℝ) < freshFloor 8 4 (1/2) := by
  norm_num [useful, freshFloor]

/-- Negative control: when recovery alone covers the target (`emax·wr > T`) the floor is
negative, so attainment (part 2) genuinely needs `emax·wr ≤ T`. -/
example : freshFloor 1 4 (1/2) < 0 := by
  norm_num [freshFloor]

end ViridisStatements.P3.RecoveryWorkFloor
