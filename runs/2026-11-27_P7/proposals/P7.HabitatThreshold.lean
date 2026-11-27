import Mathlib

/-!
# P7 · The Levins extinction threshold under habitat loss

Model (Levins 1969, with habitat loss as in Lande 1987 and Nee and May 1992): the fraction `p`
of patches occupied changes at rate `dp/dt = growth c e h p = c·p·(h − p) − e·p`, where `c` is the
colonisation rate, `e` the extinction rate and `h` the fraction of patches still suitable. The
nontrivial equilibrium is `pstar c e h = h − e/c`.

`Statement` is about the **sign of the growth term** only. It says nothing about solutions of the
differential equation, and nothing about whether a real species follows this model or about any
value of `c`, `e` or `h`; those are field inputs. Each part holds for all real `c, e, h` with
`0 < c` and `0 < e`:

1. factorisation: `growth c e h p = c·p·(pstar c e h − p)` for every `p`;
2. below the threshold (`h ≤ e/c`): `growth c e h p < 0` for every `p > 0`;
3. above the threshold (`e/c < h`): `0 < pstar < h`, `growth` vanishes at `pstar`, is positive on
   `(0, pstar)` and negative above `pstar`;
4. Levins rule: `e/c < h ↔ 1 − h < 1 − e/c` (the destroyed fraction `1 − h` must stay below the
   intact-habitat occupancy `1 − e/c`);
5. the threshold `e/c` falls strictly when `c` rises and rises strictly when `e` rises.
-/

namespace ViridisStatements.P7.HabitatThreshold

/-- Levins growth term with habitat loss: `c·p·(h − p) − e·p`. -/
def growth (c e h p : ℝ) : ℝ := c * p * (h - p) - e * p

/-- Nontrivial equilibrium occupancy `p* = h − e/c`. -/
noncomputable def pstar (c e h : ℝ) : ℝ := h - e / c

/-- **Proposed sealed target `P7.HabitatThreshold`.** -/
def Statement : Prop :=
  (∀ c e h : ℝ, 0 < c → 0 < e →
      ∀ p : ℝ, growth c e h p = c * p * (pstar c e h - p)) ∧
  (∀ c e h : ℝ, 0 < c → 0 < e → h ≤ e / c →
      ∀ p : ℝ, 0 < p → growth c e h p < 0) ∧
  (∀ c e h : ℝ, 0 < c → 0 < e → e / c < h →
      0 < pstar c e h ∧ pstar c e h < h ∧ growth c e h (pstar c e h) = 0 ∧
      (∀ p : ℝ, 0 < p → p < pstar c e h → 0 < growth c e h p) ∧
      (∀ p : ℝ, pstar c e h < p → growth c e h p < 0)) ∧
  (∀ c e h : ℝ, 0 < c → 0 < e → (e / c < h ↔ 1 - h < 1 - e / c)) ∧
  (∀ c e : ℝ, 0 < c → 0 < e →
      (∀ c' : ℝ, c < c' → e / c' < e / c) ∧ (∀ e' : ℝ, e < e' → e / c < e' / c))

/-! ## Sanity checks -/

/-- Witness: `c = 2, e = 1, h = 1` gives `p* = 1/2`, and the growth at `p = 1/4` is `1/8 > 0`. -/
example : pstar 2 1 1 = 1/2 ∧ growth 2 1 1 (1/4) = 1/8 ∧ 0 < growth 2 1 1 (1/4) := by
  norm_num [pstar, growth]

/-- Witness: with habitat cut to `h = 1/2 = e/c` the growth at `p = 1/4` is `−1/8 < 0`. -/
example : growth 2 1 (1/2) (1/4) = -1/8 ∧ growth 2 1 (1/2) (1/4) < 0 := by
  norm_num [growth]

/-- Factorisation at the witness point: `c·p·(p* − p) = 2·(1/4)·(1/2 − 1/4) = 1/8`. -/
example : (2 : ℝ) * (1/4) * (pstar 2 1 1 - 1/4) = growth 2 1 1 (1/4) := by
  norm_num [pstar, growth]

/-- Negative control for part 2: without `0 < p` the strict sign fails, since the growth term
is `0` at `p = 0` even below the threshold (`h = 1/2 ≤ e/c = 1/2`). -/
example : ¬ (growth 2 1 (1/2) 0 < 0) := by
  norm_num [growth]

/-- Negative control for part 5: with `e = 0` (excluded by `0 < e`) the threshold does not fall
when `c` rises: `0/3 = 0/2`. -/
example : ¬ ((0 : ℝ) / 3 < 0 / 2) := by
  norm_num

end ViridisStatements.P7.HabitatThreshold
