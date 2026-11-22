# Statement proposals for P6

Three statements, one Lean module each, self-contained over Mathlib. Keep every definition inside
the statement's own namespace. Mathlib lemma names below are hints to check against the pinned
Mathlib, not part of any statement.

Throughout statements 1 and 2: `V` is a finite type of patches (`Fintype V`, `DecidableEq V`),
`G : SimpleGraph V` with decidable adjacency, n = `Fintype.card V`, m = `G.edgeFinset.card`.
"Remove corridor e" means `G.deleteEdges {e}`.

## P6.MinimalNetwork

A conjunction of three parts.

1. Lower bound. If `G.Connected` then n ≤ m + 1.
2. Trees are exactly the minimal connected networks. `G.Connected ∧ m + 1 = n ↔ G.IsTree`.
3. No spare corridor. If `G.IsTree` then for every `e ∈ G.edgeSet`,
   `¬ (G.deleteEdges {e}).Connected`.

Hints: `SimpleGraph.Connected.card_vert_le_card_edgeSet_add_one`,
`SimpleGraph.isTree_iff_connected_and_card`, `SimpleGraph.isAcyclic_iff_forall_edge_isBridge`,
`SimpleGraph.isBridge_iff`.

Sanity checks to include (by `decide` or explicit proof): the path on `Fin 3` (edges 0–1, 1–2) is
connected with m = 2 = n − 1; removing edge 0–1 disconnects it. Negative control to describe in the
rationale: part 2 is false without connectivity. On `Fin 4`, the graph with edges 0–1, 1–2, 0–2 has
m + 1 = n but is not a tree (vertex 3 is isolated and there is a cycle).

## P6.SingleFailureRobust

Statement: if 2 ≤ n, `G.Connected`, and for every `e ∈ G.edgeSet` the graph `G.deleteEdges {e}` is
connected, then n ≤ m.

Proof idea (not part of the statement): by P6.MinimalNetwork part 1, n ≤ m + 1. If m + 1 = n then G
is a tree; a connected graph on at least two vertices has an edge; by part 3 removing it
disconnects G, a contradiction. Restate what you need; do not import the other module.

The module must also contain two attainment witnesses as separate checked examples: the complete
graph on `Fin 3` (the triangle, m = 3 = n) and the cycle on `Fin 4` (edges 0–1, 1–2, 2–3, 3–0,
m = 4 = n) each satisfy all three hypotheses. Negative control to describe: the hypothesis 2 ≤ n
cannot be dropped, because on one vertex the hypotheses hold with m = 0 < 1 = n.

Check before proposing: for n = 2 no simple graph satisfies the hypotheses (the only connected one
is a single edge, whose removal disconnects), so the statement is true there vacuously. Say this in
the rationale.

## P6.SerialParallel

Real numbers only. `s` is a `Finset ι`.

1. Serial route. If 0 ≤ p i ≤ 1 for all i ∈ s, then for every j ∈ s: ∏ i ∈ s, p i ≤ p j.
2. Parallel routes. If 0 ≤ q i ≤ 1 for all i ∈ s, then for every j ∈ s:
   q j ≤ 1 − ∏ i ∈ s, (1 − q i), and 1 − ∏ i ∈ s, (1 − q i) ≤ 1.
3. Two routes, equality case. For 0 ≤ p ≤ 1 and 0 ≤ q ≤ 1:
   1 − (1 − p) * (1 − q) = max p q ↔ (min p q = 0 ∨ max p q = 1).

Check the algebra of part 3 before proposing: 1 − (1 − p)(1 − q) = p + q(1 − p), which equals p
exactly when q = 0 or p = 1; then treat p ≥ q and q ≥ p separately.

Sanity checks to include: p = q = 1/2 gives 3/4 > 1/2; links 1/2 and 1/2 in series give 1/4.
Negative control to describe: part 1 fails if some p i > 1 (links 2 and 1/2: product 1 > 1/2).

The rationale must say that part 2 computes "at least one route succeeds" only under independence of
the routes, which is a field assumption and not part of the mathematics, and that part 1 is the same
inequality as the upper bound of `P3.CascadedRecovery` with p i = 1 − r i.
