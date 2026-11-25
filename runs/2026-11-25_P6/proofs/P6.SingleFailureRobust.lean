import Mathlib
import ViridisStatements.P6.SingleFailureRobust

namespace Candidate

open SimpleGraph ViridisStatements.P6.SingleFailureRobust

/-- The number of corridors as a `Nat.card` of the edge set. -/
lemma corridorCount_eq {V : Type} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] : corridorCount G = Nat.card G.edgeSet := by
  rw [corridorCount, Nat.card_eq_fintype_card, ← edgeFinset_card]

lemma patchCount_eq (V : Type) [Fintype V] : patchCount V = Nat.card V := by
  rw [patchCount, Nat.card_eq_fintype_card]

/-- In a tree, every corridor is a bridge, so deleting it disconnects the network. -/
lemma tree_delete_not_connected {V : Type} (G : SimpleGraph V) (hT : G.IsTree)
    (e : Sym2 V) (he : e ∈ G.edgeSet) : ¬ (G.deleteEdges {e}).Connected := by
  have hb : G.IsBridge e := isAcyclic_iff_forall_edge_isBridge.mp hT.IsAcyclic he
  induction e using Sym2.ind with
  | _ u v =>
    rw [isBridge_iff] at hb
    intro hc
    apply hb.2
    have := hc.preconnected u v
    simpa [deleteEdges] using this

/-- A connected graph on at least two vertices has an edge. -/
lemma exists_edge {V : Type} [Fintype V] (G : SimpleGraph V) (hc : G.Connected)
    (h2 : 2 ≤ Fintype.card V) : ∃ e, e ∈ G.edgeSet := by
  obtain ⟨u, v, huv⟩ := Fintype.exists_pair_of_one_lt_card (by omega : 1 < Fintype.card V)
  obtain ⟨p⟩ := hc.preconnected u v
  cases p with
  | nil => exact absurd rfl huv
  | cons h _ => exact ⟨_, (G.mem_edgeSet).mpr h⟩

theorem main : ViridisStatements.P6.SingleFailureRobust.Statement := by
  intro V _ _ G _ h2 hS
  obtain ⟨hc, hdel⟩ := hS
  by_contra hlt
  push_neg at hlt
  have hle : patchCount V ≤ corridorCount G + 1 := by
    rw [patchCount_eq, corridorCount_eq]
    exact hc.card_vert_le_card_edgeSet_add_one
  have heq : Nat.card G.edgeSet + 1 = Nat.card V := by
    have h1 := corridorCount_eq G
    have h3 := patchCount_eq V
    omega
  have hT : G.IsTree := isTree_iff_connected_and_card.mpr ⟨hc, heq⟩
  obtain ⟨e, he⟩ := exists_edge G hc h2
  exact tree_delete_not_connected G hT e he (hdel e he)

/-- Attainment witness 1 (restated from the sealed module): the triangle. -/
theorem triangle_attains : 2 ≤ patchCount (Fin 3) ∧
    SurvivesSingleFailure (⊤ : SimpleGraph (Fin 3)) ∧
    corridorCount (⊤ : SimpleGraph (Fin 3)) = patchCount (Fin 3) := by
  unfold SurvivesSingleFailure
  decide

/-- Attainment witness 2 (restated from the sealed module): the 4-cycle. -/
theorem cycle4_attains : 2 ≤ patchCount (Fin 4) ∧
    SurvivesSingleFailure cycle4 ∧
    corridorCount cycle4 = patchCount (Fin 4) := by
  unfold SurvivesSingleFailure
  decide

end Candidate
