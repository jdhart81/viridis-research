import Mathlib

/-!
# P6 · Minimal corridor networks: trees are the cheapest connected networks

Model: habitat patches are the vertices of a finite type `V`; corridors are the edges of a simple
graph `G : SimpleGraph V`. There is no geometry, width, quality or cost: only incidence.
`patchCount V = Fintype.card V` is the number of patches `n`, and `corridorCount G =
G.edgeFinset.card` is the number of corridors `m`. Removing corridor `e` is `G.deleteEdges {e}`.

`Statement` (for every finite `V` with decidable equality and every `G` with decidable adjacency):
1. lower bound: if `G` is connected then `n ≤ m + 1`;
2. characterisation: `G` is connected with `m + 1 = n` if and only if `G` is a tree;
3. no spare corridor: if `G` is a tree, removing any one of its corridors disconnects it.

This is classical graph theory, not a new theorem. No claim is made about any real corridor,
species movement or landscape.
-/

namespace ViridisStatements.P6.MinimalNetwork

/-- Number of habitat patches `n`. -/
def patchCount (V : Type) [Fintype V] : ℕ := Fintype.card V

/-- Number of corridors `m` of a corridor network `G`. -/
def corridorCount {V : Type} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] : ℕ :=
  G.edgeFinset.card

/-- **Proposed sealed target `P6.MinimalNetwork`.** -/
def Statement : Prop :=
  ∀ (V : Type) [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj],
    (G.Connected → patchCount V ≤ corridorCount G + 1) ∧
    (G.Connected ∧ corridorCount G + 1 = patchCount V ↔ G.IsTree) ∧
    (G.IsTree → ∀ e ∈ G.edgeSet, ¬ (G.deleteEdges {e}).Connected)

/-! ## Sanity checks -/

/-- The path on three patches: corridors `0–1` and `1–2`. -/
def path3 : SimpleGraph (Fin 3) where
  Adj i j := (i.val + 1 = j.val) ∨ (j.val + 1 = i.val)
  symm := fun _ _ h => h.symm
  loopless := ⟨fun i h => by omega⟩

instance : DecidableRel path3.Adj := fun i j =>
  inferInstanceAs (Decidable ((i.val + 1 = j.val) ∨ (j.val + 1 = i.val)))

/-- The path on `Fin 3` is connected. -/
example : path3.Connected := by decide

/-- The path on `Fin 3` has `m = 2 = n - 1`, i.e. `m + 1 = n`. -/
example : corridorCount path3 = 2 ∧ corridorCount path3 + 1 = patchCount (Fin 3) := by decide

/-- Removing corridor `0–1` from the path disconnects it. -/
example : ¬ (path3.deleteEdges {s(0, 1)}).Connected := by decide

/-- Negative control for part 2: the triangle `0–1, 1–2, 0–2` on `Fin 4` with vertex `3`
isolated. -/
def triangleAndIsolated : SimpleGraph (Fin 4) where
  Adj i j := i ≠ j ∧ i.val < 3 ∧ j.val < 3
  symm := fun _ _ h => ⟨h.1.symm, h.2.2, h.2.1⟩
  loopless := ⟨fun _ h => h.1 rfl⟩

instance : DecidableRel triangleAndIsolated.Adj := fun i j =>
  inferInstanceAs (Decidable (i ≠ j ∧ i.val < 3 ∧ j.val < 3))

/-- It has `m + 1 = n` (`3 + 1 = 4`) but is not connected, so the count alone does not make a
tree: connectivity in part 2 cannot be dropped. -/
example : corridorCount triangleAndIsolated + 1 = patchCount (Fin 4) ∧
    ¬ triangleAndIsolated.Connected := by decide

end ViridisStatements.P6.MinimalNetwork
