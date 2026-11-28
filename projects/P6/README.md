# P6 · Habitat networks: minimal corridors, redundancy and route reliability

P6 builds the formal core for a corridor-network kernel: how few corridors can connect a set of
habitat patches, what it costs to survive the loss of any one corridor, and how the chance of
crossing a route depends on its links. It is the first engine project for Hierarchical Dendritic
Forest Management (HDFM), which designs tree-shaped (dendritic) corridor networks.

The question it answers for a planner: a dendritic network is the cheapest way to connect patches,
and for exactly that reason it has no spare corridor. P6 states both halves precisely.

Planned statements (drafted by P6-T001, sealed only by Justin's decision on issue #1):

1. **P6.MinimalNetwork.** A connected network on n patches has at least n − 1 corridors. It has
   exactly n − 1 if and only if it is a tree, and then removing any one corridor disconnects it.
2. **P6.SingleFailureRobust.** A network on n ≥ 2 patches that stays connected after the loss of
   any one corridor has at least n corridors. The triangle and the 4-cycle attain the bound.
3. **P6.SerialParallel.** For link probabilities in [0, 1]: a route's success probability, the
   product of its links, is no larger than its weakest link; with independent alternative routes
   the chance that at least one succeeds is no smaller than the best route, with equality for two
   routes exactly when the worse one is 0 or the better one is 1.

These are classical graph theory and elementary probability, not new theorems. Statement 3's serial
bound is the same inequality as the upper bound in `P3.CascadedRecovery` (a cascade of recovery
stages and a chain of corridor links are both products of fractions); P6 restates it self-contained
and says so.

A PROVEN label here certifies the mathematics of the model. It never certifies that a mapped
corridor is used by any species, a link probability, the independence of routes, or any ecological
outcome. Those stay ASSUMED until field evidence or a human review covers them. The graph is an
abstraction: patches are vertices and corridors are edges, with no geometry, width, quality or
cost. It does not discharge the FaceCount assumption of *Trees Cannot Cut*, which is project P1.

## Tasks

- **P6-T001** proposes the three statements, exactly as specified in `context/STATEMENT_PROPOSAL.md`.
- **P6-T002** proves `P6.MinimalNetwork`.
- **P6-T003** proves `P6.SingleFailureRobust`.
- **P6-T004** proves `P6.SerialParallel`.
- **P6-T005** (extension) proposes `P6.CorridorPersistence`, as specified in
  `context/EXTENSION_T005.md`: it joins the corridor statements above to the persistence threshold
  of `P7.HabitatThreshold` through a declared colonisation map. It is the project's next rung, so it
  is not a restatement of a known fact.
- **P6-T006** (extension) proves it.

The three statements above are this project's known rung; every task's rung is in `tasks.json`.
