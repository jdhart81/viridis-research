# P6-T002 lab notebook (2026-11-24)

Task: prove sealed statement P6.MinimalNetwork.

## Start of session
- Prior run 2026-11-23_P6 (P6-T001) submitted no Aristotle jobs, so none are pending.
- No Aristotle jobs submitted this session (none were needed).

## What was done
- Read the sealed module inputs/statements/P6.MinimalNetwork.lean.
- Wrote out/proofs/P6.MinimalNetwork.lean. It PASSED `viridis-lean-check` on the first attempt
  (axioms: propext, Classical.choice, Quot.sound). The verifier alone awards PROVEN.
- Proof route (as P6-T001 predicted):
  - Bridge `corridorCount G = Nat.card G.edgeSet` via `Nat.card_eq_fintype_card` and
    `SimpleGraph.edgeFinset_card`; `patchCount V = Nat.card V` via `Nat.card_eq_fintype_card`.
  - Part 1: `SimpleGraph.Connected.card_vert_le_card_edgeSet_add_one`.
  - Part 2: `SimpleGraph.isTree_iff_connected_and_card` (after the count rewrites, `rw` closes the goal by rfl).
  - Part 3: `isAcyclic_iff_forall_edge_isBridge` gives that e is a bridge; `Sym2.ind` splits e = s(u,v);
    `isBridge_iff` gives ¬(G \ fromEdgeSet {s(u,v)}).Reachable u v; connectivity of
    G.deleteEdges {s(u,v)} would give that reachability (`simpa [deleteEdges]`).
- Verified bibliography entries by web search: Urban & Keitt 2001, Diestel 2017, mathlib 2020, Lean 4 (CADE 28).
  Dropped Moore & Shannon 1956 from refs.bib since it is not cited in this note.
- Premise review: the statement is pure mathematics about its own definitions, and its module says it makes no
  claim about real corridors. Listed no premises (counts only if a second run agrees).

## Failures / hiccups
- None.

## Open questions
- Should the patch type be universe-polymorphic? Sealed as `Type`; the proof would generalise unchanged.

## Next steps
- P6-T003 (SingleFailureRobust): by contradiction; if m < n then with connectivity m + 1 = n, so G is a tree
  (part 2 of this statement, reproved locally); with n >= 2 get an edge; it is a bridge, contradicting survival.
- P6-T004 (SerialParallel).
