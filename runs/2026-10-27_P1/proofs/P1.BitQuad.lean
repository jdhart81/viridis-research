import Mathlib
import ViridisStatements.P1.BitQuad

namespace Candidate

open ViridisStatements.P1.BitQuad

/-- Counting the vertices whose shifted copy lies in `S`: if the shift is a
bijection and every point of `S` shifts back into `V`, the count is `|S|`. -/
theorem card_filter_shift (V S : Finset (ℤ × ℤ)) (i j : ℤ × ℤ → ℤ × ℤ)
    (hij : ∀ p, i (j p) = p) (hji : ∀ v, j (i v) = v)
    (hS : ∀ p ∈ S, j p ∈ V) :
    (V.filter fun v => i v ∈ S).card = S.card := by
  apply Finset.card_nbij' i j
  · intro v hv
    simp only [Finset.coe_filter, Set.mem_setOf_eq] at hv
    exact hv.2
  · intro p hp
    simp only [Finset.coe_filter, Set.mem_setOf_eq]
    exact ⟨hS p hp, by rw [hij]; exact hp⟩
  · intro v _; exact hji v
  · intro p _; exact hij p

theorem sum_ind_shift (V S : Finset (ℤ × ℤ)) (i j : ℤ × ℤ → ℤ × ℤ)
    (hij : ∀ p, i (j p) = p) (hji : ∀ v, j (i v) = v)
    (hS : ∀ p ∈ S, j p ∈ V) :
    (∑ v ∈ V, (if i v ∈ S then (1 : ℤ) else 0)) = S.card := by
  rw [Finset.sum_boole, card_filter_shift V S i j hij hji hS]

theorem mem_vertices (B : Finset Pixel) (p : Pixel) (hp : p ∈ B) (v : ℤ × ℤ)
    (hv : v ∈ corners p) : v ∈ vertices B := by
  unfold vertices
  exact Finset.mem_biUnion.mpr ⟨p, hp, hv⟩

theorem mem_hEdges (B : Finset Pixel) (e : ℤ × ℤ) :
    e ∈ hEdges B ↔ e ∈ B ∨ (e.1, e.2 - 1) ∈ B := by
  unfold hEdges
  simp only [Finset.mem_biUnion, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨p, hp, h | h⟩
    · left; subst h; exact hp
    · right; subst h; simpa using hp
  · rintro (h | h)
    · exact ⟨e, h, Or.inl rfl⟩
    · exact ⟨_, h, Or.inr (by ext <;> simp)⟩

theorem mem_vEdges (B : Finset Pixel) (e : ℤ × ℤ) :
    e ∈ vEdges B ↔ e ∈ B ∨ (e.1 - 1, e.2) ∈ B := by
  unfold vEdges
  simp only [Finset.mem_biUnion, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨p, hp, h | h⟩
    · left; subst h; exact hp
    · right; subst h; simpa using hp
  · rintro (h | h)
    · exact ⟨e, h, Or.inl rfl⟩
    · exact ⟨_, h, Or.inr (by ext <;> simp)⟩

theorem hEdges_left_mem (B : Finset Pixel) (e : ℤ × ℤ) (he : e ∈ hEdges B) :
    e ∈ vertices B := by
  rcases (mem_hEdges B e).mp he with h | h
  · exact mem_vertices B e h e (by simp [corners])
  · exact mem_vertices B _ h e (by simp [corners])

theorem hEdges_right_mem (B : Finset Pixel) (e : ℤ × ℤ) (he : e ∈ hEdges B) :
    (e.1 + 1, e.2) ∈ vertices B := by
  rcases (mem_hEdges B e).mp he with h | h
  · exact mem_vertices B e h _ (by simp [corners])
  · exact mem_vertices B _ h _ (by simp [corners])

theorem vEdges_low_mem (B : Finset Pixel) (e : ℤ × ℤ) (he : e ∈ vEdges B) :
    e ∈ vertices B := by
  rcases (mem_vEdges B e).mp he with h | h
  · exact mem_vertices B e h e (by simp [corners])
  · exact mem_vertices B _ h e (by simp [corners])

theorem vEdges_up_mem (B : Finset Pixel) (e : ℤ × ℤ) (he : e ∈ vEdges B) :
    (e.1, e.2 + 1) ∈ vertices B := by
  rcases (mem_vEdges B e).mp he with h | h
  · exact mem_vertices B e h _ (by simp [corners])
  · exact mem_vertices B _ h _ (by simp [corners])

theorem window_nonempty (B : Finset Pixel) (v : ℤ × ℤ) (hv : v ∈ vertices B) :
    (v.1 - 1, v.2 - 1) ∈ B ∨ (v.1, v.2 - 1) ∈ B ∨ (v.1 - 1, v.2) ∈ B ∨ (v.1, v.2) ∈ B := by
  unfold vertices at hv
  obtain ⟨p, hp, hv⟩ := Finset.mem_biUnion.mp hv
  simp only [corners, Finset.mem_insert, Finset.mem_singleton] at hv
  rcases hv with h | h | h | h <;> subst h <;> simp [hp]

theorem main : ViridisStatements.P1.BitQuad.Statement := by
  intro B
  set V := vertices B with hVdef
  -- 4F
  have hF1 : (∑ v ∈ V, (if (v.1 - 1, v.2 - 1) ∈ B then (1 : ℤ) else 0)) = B.card :=
    sum_ind_shift V B (fun v => (v.1 - 1, v.2 - 1)) (fun p => (p.1 + 1, p.2 + 1))
      (by intro p; simp) (by intro p; simp)
      (fun p hp => mem_vertices B p hp _ (by simp [corners]))
  have hF2 : (∑ v ∈ V, (if (v.1, v.2 - 1) ∈ B then (1 : ℤ) else 0)) = B.card :=
    sum_ind_shift V B (fun v => (v.1, v.2 - 1)) (fun p => (p.1, p.2 + 1))
      (by intro p; simp) (by intro p; simp)
      (fun p hp => mem_vertices B p hp _ (by simp [corners]))
  have hF3 : (∑ v ∈ V, (if (v.1 - 1, v.2) ∈ B then (1 : ℤ) else 0)) = B.card :=
    sum_ind_shift V B (fun v => (v.1 - 1, v.2)) (fun p => (p.1 + 1, p.2))
      (by intro p; simp) (by intro p; simp)
      (fun p hp => mem_vertices B p hp _ (by simp [corners]))
  have hF4 : (∑ v ∈ V, (if (v.1, v.2) ∈ B then (1 : ℤ) else 0)) = B.card :=
    sum_ind_shift V B (fun v => (v.1, v.2)) (fun p => (p.1, p.2))
      (by intro p; simp) (by intro p; simp)
      (fun p hp => mem_vertices B p hp _ (by simp [corners]))
  -- 2E
  have hH1 : (∑ v ∈ V, (if (v.1, v.2) ∈ hEdges B then (1 : ℤ) else 0)) = (hEdges B).card :=
    sum_ind_shift V _ (fun v => (v.1, v.2)) (fun p => (p.1, p.2))
      (by intro p; simp) (by intro p; simp)
      (fun p hp => hEdges_left_mem B p hp)
  have hH2 : (∑ v ∈ V, (if (v.1 - 1, v.2) ∈ hEdges B then (1 : ℤ) else 0)) = (hEdges B).card :=
    sum_ind_shift V _ (fun v => (v.1 - 1, v.2)) (fun p => (p.1 + 1, p.2))
      (by intro p; simp) (by intro p; simp)
      (fun p hp => hEdges_right_mem B p hp)
  have hE1 : (∑ v ∈ V, (if (v.1, v.2) ∈ vEdges B then (1 : ℤ) else 0)) = (vEdges B).card :=
    sum_ind_shift V _ (fun v => (v.1, v.2)) (fun p => (p.1, p.2))
      (by intro p; simp) (by intro p; simp)
      (fun p hp => vEdges_low_mem B p hp)
  have hE2 : (∑ v ∈ V, (if (v.1, v.2 - 1) ∈ vEdges B then (1 : ℤ) else 0)) = (vEdges B).card :=
    sum_ind_shift V _ (fun v => (v.1, v.2 - 1)) (fun p => (p.1, p.2 + 1))
      (by intro p; simp) (by intro p; simp)
      (fun p hp => vEdges_up_mem B p hp)
  -- right-hand side
  have hQ1 : ((Q1 B : ℕ) : ℤ) = ∑ v ∈ V, (if windowCount B v = 1 then (1 : ℤ) else 0) := by
    rw [Finset.sum_boole]; rfl
  have hQ3 : ((Q3 B : ℕ) : ℤ) = ∑ v ∈ V, (if windowCount B v = 3 then (1 : ℤ) else 0) := by
    rw [Finset.sum_boole]; rfl
  have hQD : ((QD B : ℕ) : ℤ) = ∑ v ∈ V, (if isDiagonal B v = true then (1 : ℤ) else 0) := by
    rw [Finset.sum_boole]; rfl
  have key : 4 * euler B
      = ∑ v ∈ V, (4 - 2 * ((if (v.1, v.2) ∈ hEdges B then (1 : ℤ) else 0)
          + (if (v.1 - 1, v.2) ∈ hEdges B then (1 : ℤ) else 0)
          + (if (v.1, v.2) ∈ vEdges B then (1 : ℤ) else 0)
          + (if (v.1, v.2 - 1) ∈ vEdges B then (1 : ℤ) else 0))
        + ((if (v.1 - 1, v.2 - 1) ∈ B then (1 : ℤ) else 0)
          + (if (v.1, v.2 - 1) ∈ B then (1 : ℤ) else 0)
          + (if (v.1 - 1, v.2) ∈ B then (1 : ℤ) else 0)
          + (if (v.1, v.2) ∈ B then (1 : ℤ) else 0))) := by
    simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]
    rw [hF1, hF2, hF3, hF4, hH1, hH2, hE1, hE2]
    unfold euler
    rw [← hVdef]
    simp
    ring
  rw [key, hQ1, hQ3, hQD, Finset.mul_sum, ← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro v hv
  have hne := window_nonempty B v hv
  simp only [mem_hEdges, mem_vEdges]
  unfold windowCount isDiagonal bits
  by_cases h1 : (v.1 - 1, v.2 - 1) ∈ B <;> by_cases h2 : (v.1, v.2 - 1) ∈ B <;>
    by_cases h3 : (v.1 - 1, v.2) ∈ B <;> by_cases h4 : (v.1, v.2) ∈ B <;>
    simp_all

end Candidate
