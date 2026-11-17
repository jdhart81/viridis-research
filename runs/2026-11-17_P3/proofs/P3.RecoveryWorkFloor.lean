import Mathlib
import ViridisStatements.P3.RecoveryWorkFloor

namespace Candidate

open ViridisStatements.P3.RecoveryWorkFloor

/-- Uniform efficiency bound (Run-163 `uniform_efficiency_bound`, restated for the sealed
`useful`): useful work is at most `emax · (wf + wr)`. -/
theorem uniform_efficiency_bound (wf wr ef er emax : ℝ) (hwf : 0 ≤ wf) (hwr : 0 ≤ wr)
    (hef : ef ≤ emax) (her : er ≤ emax) :
    useful wf wr ef er ≤ emax * (wf + wr) := by
  have h1 : 0 ≤ (emax - ef) * wf := mul_nonneg (sub_nonneg.mpr hef) hwf
  have h2 : 0 ≤ (emax - er) * wr := mul_nonneg (sub_nonneg.mpr her) hwr
  unfold useful
  nlinarith

/-- Run-163 `target_requires_supply`, restated: reaching `T` needs total supply `≥ T / emax`. -/
theorem target_requires_supply (wf wr ef er emax T : ℝ) (hwf : 0 ≤ wf) (hwr : 0 ≤ wr)
    (hef : ef ≤ emax) (her : er ≤ emax) (he : 0 < emax) (hT : T ≤ useful wf wr ef er) :
    T / emax ≤ wf + wr := by
  have hu := uniform_efficiency_bound wf wr ef er emax hwf hwr hef her
  rw [div_le_iff₀ he]
  linarith [mul_comm emax (wf + wr)]

/-- The floor is the total-supply bound with the recovered part moved across:
`(T - emax·wr)/emax = T/emax - wr`. -/
theorem freshFloor_eq (T wr emax : ℝ) (he : 0 < emax) :
    freshFloor T wr emax = T / emax - wr := by
  unfold freshFloor
  field_simp

/-- Part 1 (floor). -/
theorem floor (wf wr ef er emax T : ℝ) (hwf : 0 ≤ wf) (hwr : 0 ≤ wr)
    (hef : ef ≤ emax) (her : er ≤ emax) (he : 0 < emax)
    (hT : T ≤ useful wf wr ef er) : freshFloor T wr emax ≤ wf := by
  rw [freshFloor_eq T wr emax he]
  linarith [target_requires_supply wf wr ef er emax T hwf hwr hef her he hT]

/-- Part 2 (attainment): the floor is nonnegative and, at `ef = er = emax`, delivers `T`. -/
theorem attain (wr emax T : ℝ) (he : 0 < emax) (hT : emax * wr ≤ T) :
    0 ≤ freshFloor T wr emax ∧ useful (freshFloor T wr emax) wr emax emax = T := by
  unfold freshFloor useful
  refine ⟨div_nonneg (by linarith) he.le, ?_⟩
  field_simp
  ring

theorem main : ViridisStatements.P3.RecoveryWorkFloor.Statement :=
  ⟨fun wf wr ef er emax T hwf hwr _ hef _ her he hT =>
      floor wf wr ef er emax T hwf hwr hef her he hT,
   fun wr emax T he _ hT => attain wr emax T he hT⟩

end Candidate
