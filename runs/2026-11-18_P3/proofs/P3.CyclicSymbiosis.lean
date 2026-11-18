import Mathlib
import ViridisStatements.P3.CyclicSymbiosis

namespace Candidate

open ViridisStatements.P3.CyclicSymbiosis

/-- Explicit form of the predecessor: `0 ↦ N - 1`, `i ↦ i - 1` otherwise. -/
lemma prev_val {N : ℕ} (i : Fin N) :
    (prev i).val = if i.val = 0 then N - 1 else i.val - 1 := by
  have hN := i.isLt
  unfold prev
  split_ifs with h
  · simp only [h, zero_add]
    exact Nat.mod_eq_of_lt (by omega)
  · have : i.val + (N - 1) = (i.val - 1) + N := by omega
    simp only [this, Nat.add_mod_right]
    exact Nat.mod_eq_of_lt (by omega)

/-- The predecessor map is injective, hence a bijection of the finite cycle. -/
lemma prev_bijective {N : ℕ} : Function.Bijective (prev : Fin N → Fin N) := by
  rw [← Finite.injective_iff_bijective]
  intro a b hab
  have ha := prev_val a
  have hb := prev_val b
  have := congrArg Fin.val hab
  have := a.isLt
  have := b.isLt
  ext
  split_ifs at ha hb <;> omega

/-- Reindexing along the cycle: `∏ x (prev i) = ∏ x i`. -/
lemma prod_prev {N : ℕ} (x : Fin N → ℝ) : ∏ i, x (prev i) = ∏ i, x i :=
  Fintype.prod_bijective prev prev_bijective _ _ (fun _ => rfl)

/-- Necessity: a strictly beneficial flow forces `∏ c < ∏ v`. -/
lemma necessity (N : ℕ) (hN : 2 ≤ N) (c v : Fin N → ℝ) (hc : ∀ i, 0 < c i)
    (x : Fin N → ℝ) (hx : StrictlyBeneficialFlow c v x) : CycleProductCondition c v := by
  obtain ⟨hxpos, hnet⟩ := hx
  have hne : (Finset.univ : Finset (Fin N)).Nonempty := ⟨⟨0, by omega⟩, Finset.mem_univ _⟩
  have hlt : ∏ i, (c i * x i) < ∏ i, (v i * x (prev i)) := by
    apply Finset.prod_lt_prod_of_nonempty _ _ hne
    · intro i _; exact mul_pos (hc i) (hxpos i)
    · intro i _
      have := hnet i
      unfold net at this
      linarith
  rw [Finset.prod_mul_distrib, Finset.prod_mul_distrib, prod_prev] at hlt
  have hX : 0 < ∏ i, x i := Finset.prod_pos (fun i _ => hxpos i)
  exact lt_of_mul_lt_mul_right hlt hX.le

/-- Sufficiency: under `∏ c < ∏ v` an explicit flow benefits every partner. -/
lemma sufficiency (N : ℕ) (hN : 2 ≤ N) (c v : Fin N → ℝ) (hc : ∀ i, 0 < c i)
    (hv : ∀ i, 0 < v i) (hP : CycleProductCondition c v) :
    ∃ x : Fin N → ℝ, StrictlyBeneficialFlow c v x := by
  unfold CycleProductCondition at hP
  have hCpos : 0 < ∏ i, c i := Finset.prod_pos (fun i _ => hc i)
  have hVpos : 0 < ∏ i, v i := Finset.prod_pos (fun i _ => hv i)
  set P : ℝ := (∏ i, v i) / (∏ i, c i) with hPdef
  have hP1 : 1 < P := by rw [hPdef, one_lt_div hCpos]; exact hP
  set s : ℝ := P ^ ((N : ℝ)⁻¹) with hsdef
  have hs1 : 1 < s := Real.one_lt_rpow hP1 (by positivity)
  have hs0 : 0 < s := by linarith
  have hsN : s ^ N = P := Real.rpow_inv_natCast_pow (by linarith) (by omega)
  -- per-partner ratios, with product one
  set a : Fin N → ℝ := fun i => v i / (c i * s) with hadef
  have hapos : ∀ i, 0 < a i := fun i => div_pos (hv i) (mul_pos (hc i) hs0)
  have haprod : ∏ i, a i = 1 := by
    simp only [hadef, Finset.prod_div_distrib, Finset.prod_mul_distrib, Finset.prod_const,
      Finset.card_univ, Fintype.card_fin, hsN, hPdef]
    field_simp
  -- extend to ℕ and take prefix products
  set a' : ℕ → ℝ := fun j => if h : j < N then a ⟨j, h⟩ else 1 with ha'def
  have ha'pos : ∀ j, 0 < a' j := by
    intro j; simp only [ha'def]; split_ifs
    · exact hapos _
    · exact one_pos
  set y : ℕ → ℝ := fun k => ∏ j ∈ Finset.range (k + 1), a' j with hydef
  have hypos : ∀ k, 0 < y k := fun k => Finset.prod_pos (fun j _ => ha'pos j)
  set x : Fin N → ℝ := fun i => y i.val with hxdef
  -- the key recursion around the cycle
  have hrec : ∀ i, x i = a i * x (prev i) := by
    intro i
    have hpv := prev_val i
    have hi := i.isLt
    simp only [hxdef]
    split_ifs at hpv with h0
    · rw [hpv, h0]
      have hyN : y (N - 1) = 1 := by
        simp only [hydef]
        rw [show N - 1 + 1 = N by omega, ← haprod, ← Fin.prod_univ_eq_prod_range]
        apply Finset.prod_congr rfl
        intro j _
        simp [ha'def, j.isLt]
      rw [hyN, mul_one]
      simp only [hydef, zero_add, Finset.prod_range_one, ha'def]
      rw [dif_pos (by omega)]
      congr 1
      ext; simp [h0]
    · rw [hpv]
      simp only [hydef]
      rw [show i.val + 1 = (i.val - 1 + 1) + 1 by omega, Finset.prod_range_succ,
        show i.val - 1 + 1 = i.val by omega, mul_comm]
      congr 1
      simp only [ha'def, dif_pos hi]
  refine ⟨x, fun i => hypos _, fun i => ?_⟩
  unfold net
  rw [hrec i]
  have hX : 0 < x (prev i) := hypos _
  have hci := hc i
  have hvi := hv i
  have : c i * (a i * x (prev i)) = v i * x (prev i) / s := by
    simp only [hadef]; field_simp
  rw [this]
  have hvx : 0 < v i * x (prev i) := mul_pos hvi hX
  rw [sub_pos, div_lt_iff₀ hs0]
  nlinarith

theorem main : ViridisStatements.P3.CyclicSymbiosis.Statement := by
  intro N hN c v hc hv
  exact ⟨fun ⟨x, hx⟩ => necessity N hN c v hc x hx, sufficiency N hN c v hc hv⟩

/-- `N = 2` corollary: specialising `main` to the two-partner cycle gives Run-128's strict
feasibility test (Theorem 2): strictly positive flows `x, y` with both payoffs
`uX = vX*y - cX*x` and `uY = vY*x - cY*y` strictly positive exist iff
`ProductCondition vX cX vY cY`. -/
theorem two_partner_corridor (vX cX vY cY : ℝ) (hvX : 0 < vX) (hcX : 0 < cX)
    (hvY : 0 < vY) (hcY : 0 < cY) :
    (∃ x y : ℝ, 0 < x ∧ 0 < y ∧ 0 < vX * y - cX * x ∧ 0 < vY * x - cY * y) ↔
      ProductCondition vX cX vY cY := by
  have h0 : prev (0 : Fin 2) = 1 := by decide
  have h1 : prev (1 : Fin 2) = 0 := by decide
  have hc : ∀ i, 0 < (![cX, cY] : Fin 2 → ℝ) i := by
    intro i; fin_cases i <;> simp [hcX, hcY]
  have hv : ∀ i, 0 < (![vX, vY] : Fin 2 → ℝ) i := by
    intro i; fin_cases i <;> simp [hvX, hvY]
  have key := main 2 le_rfl ![cX, cY] ![vX, vY] hc hv
  have hcond : CycleProductCondition ![cX, cY] ![vX, vY] ↔ ProductCondition vX cX vY cY := by
    simp [CycleProductCondition, ProductCondition, Fin.prod_univ_two]
  rw [← hcond, ← key]
  constructor
  · rintro ⟨x, y, hx, hy, hX, hY⟩
    refine ⟨![x, y], ?_, ?_⟩
    · intro i; fin_cases i <;> simp [hx, hy]
    · intro i
      fin_cases i
      · simpa [net, h0] using hX
      · simpa [net, h1] using hY
  · rintro ⟨f, hpos, hnet⟩
    refine ⟨f 0, f 1, hpos 0, hpos 1, ?_, ?_⟩
    · simpa [net, h0] using hnet 0
    · simpa [net, h1] using hnet 1

end Candidate
