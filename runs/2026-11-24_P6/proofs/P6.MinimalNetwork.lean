import Mathlib
import ViridisStatements.P6.MinimalNetwork

namespace Candidate

open SimpleGraph ViridisStatements.P6.MinimalNetwork

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

theorem main : ViridisStatements.P6.MinimalNetwork.Statement := by
  intro V _ _ G _
  refine ⟨?_, ?_, ?_⟩
  · intro hc
    rw [patchCount_eq, corridorCount_eq]
    exact hc.card_vert_le_card_edgeSet_add_one
  · rw [patchCount_eq, corridorCount_eq, isTree_iff_connected_and_card]
  · intro hT e he
    exact tree_delete_not_connected G hT e he

end Candidate
