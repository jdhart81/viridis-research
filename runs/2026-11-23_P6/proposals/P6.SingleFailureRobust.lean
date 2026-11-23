import Mathlib

/-!
# P6 · Single-failure robustness costs at least one spare corridor

Model: as in `P6.MinimalNetwork` (restated here, nothing is imported from it). Habitat patches are
the vertices of a finite type `V`, corridors are the edges of `G : SimpleGraph V`,
`n = Fintype.card V` and `m = G.edgeFinset.card`. Removing corridor `e` is `G.deleteEdges {e}`.

A network *survives any single corridor failure* if it is connected and stays connected after the
removal of any one of its corridors.

`Statement` (for every finite `V` with decidable equality and every `G` with decidable adjacency):
if `2 ≤ n` and `G` survives any single corridor failure, then `n ≤ m`.

So a robust network needs at least one corridor more than the `n - 1` of a tree. The triangle and
the 4-cycle attain the bound. For `n = 2` no simple graph satisfies the hypotheses, so the
statement holds there vacuously. This is classical graph theory, not a new theorem. No claim is
made about any real corridor, failure mode or landscape.
-/

namespace ViridisStatements.P6.SingleFailureRobust

/-- Number of habitat patches `n`. -/
def patchCount (V : Type) [Fintype V] : ℕ := Fintype.card V

/-- Number of corridors `m` of a corridor network `G`. -/
def corridorCount {V : Type} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] : ℕ :=
  G.edgeFinset.card

/-- `G` is connected and stays connected after the loss of any one corridor. -/
def SurvivesSingleFailure {V : Type} (G : SimpleGraph V) : Prop :=
  G.Connected ∧ ∀ e ∈ G.edgeSet, (G.deleteEdges {e}).Connected

/-- **Proposed sealed target `P6.SingleFailureRobust`.** -/
def Statement : Prop :=
  ∀ (V : Type) [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj],
    2 ≤ patchCount V → SurvivesSingleFailure G → patchCount V ≤ corridorCount G

/-! ## Sanity checks -/

/-- Attainment witness 1: the triangle (complete graph on `Fin 3`) has `2 ≤ n`, survives any
single corridor failure, and has `m = 3 = n`. -/
example : 2 ≤ patchCount (Fin 3) ∧
    (⊤ : SimpleGraph (Fin 3)).Connected ∧
    (∀ e ∈ (⊤ : SimpleGraph (Fin 3)).edgeSet, ((⊤ : SimpleGraph (Fin 3)).deleteEdges {e}).Connected) ∧
    corridorCount (⊤ : SimpleGraph (Fin 3)) = 3 ∧
    corridorCount (⊤ : SimpleGraph (Fin 3)) = patchCount (Fin 3) := by
  decide

/-- The 4-cycle: corridors `0–1, 1–2, 2–3, 3–0`. -/
def cycle4 : SimpleGraph (Fin 4) where
  Adj i j := (i.val + 1) % 4 = j.val ∨ (j.val + 1) % 4 = i.val
  symm := fun _ _ h => h.symm
  loopless := ⟨fun i h => by omega⟩

instance : DecidableRel cycle4.Adj := fun i j =>
  inferInstanceAs (Decidable ((i.val + 1) % 4 = j.val ∨ (j.val + 1) % 4 = i.val))

/-- Attainment witness 2: the 4-cycle has `2 ≤ n`, survives any single corridor failure, and has
`m = 4 = n`. -/
example : 2 ≤ patchCount (Fin 4) ∧
    cycle4.Connected ∧
    (∀ e ∈ cycle4.edgeSet, (cycle4.deleteEdges {e}).Connected) ∧
    corridorCount cycle4 = 4 ∧
    corridorCount cycle4 = patchCount (Fin 4) := by
  decide

/-- Negative control: on a single patch the hypotheses other than `2 ≤ n` hold (the empty network
is connected and has no corridor to lose) yet `m = 0 < 1 = n`; so `2 ≤ n` cannot be dropped. -/
example : (⊥ : SimpleGraph (Fin 1)).Connected ∧
    (∀ e ∈ (⊥ : SimpleGraph (Fin 1)).edgeSet, ((⊥ : SimpleGraph (Fin 1)).deleteEdges {e}).Connected) ∧
    corridorCount (⊥ : SimpleGraph (Fin 1)) < patchCount (Fin 1) := by
  decide

/-- Check of the `n = 2` case: the single corridor `0–1` is connected but removing it
disconnects, so no simple graph on two patches satisfies the hypotheses. -/
example : (⊤ : SimpleGraph (Fin 2)).Connected ∧
    ¬ ((⊤ : SimpleGraph (Fin 2)).deleteEdges {s(0, 1)}).Connected ∧
    ¬ (⊥ : SimpleGraph (Fin 2)).Connected := by
  decide

end ViridisStatements.P6.SingleFailureRobust
