# P6-T001 lab notebook (2026-11-23)

Task: propose P6.MinimalNetwork, P6.SingleFailureRobust, P6.SerialParallel.
No prior runs, so there are no pending Aristotle projects. No Aristotle jobs were submitted this session (none needed).

## What was done
- Read README.md and STATEMENT_PROPOSAL.md.
- Checked the Mathlib hint names against the pinned Mathlib. All four exist:
  Connected.card_vert_le_card_edgeSet_add_one, isTree_iff_connected_and_card (both use Nat.card),
  isAcyclic_iff_forall_edge_isBridge, isBridge_iff (stated with G \ fromEdgeSet {s(u,v)}).
  Also found: IsTree.card_edgeFinset.
- Wrote the three modules. All compile with `lean`. Graph sanity checks are closed by `decide`
  (Connected, edgeFinset.card and deleteEdges are all decidable on Fin n with explicit DecidableRel instances).
  Real checks are closed by norm_num.
- Hand checks: n = 2 is vacuous for SingleFailureRobust; checked the algebra of part 3 of SerialParallel.
- Consistency: throwaway proofs of all three Statements (in /tmp, NOT in out/) compiled, so none of the
  targets is false as written. No proof is claimed.

## Hiccups
- SimpleGraph.loopless in this Mathlib is `Std.Irrefl`, so it needs the anonymous constructor ⟨fun i h => ...⟩.
- `Nonempty V` has to be obtained from `hc.nonempty` before using Classical.arbitrary.

## Open questions
- Should the patch type be universe-polymorphic (Type u) rather than Type? I used Type for simplicity.
- Possible extra statement: the extremal graphs for SingleFailureRobust (m = n) are exactly the cycles.

## Next steps
See run.json next_steps.
