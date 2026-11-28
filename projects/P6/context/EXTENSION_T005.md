# Extension statement for P6 (rung: extension): P6-T005

P6's three sealed statements are the known rung: classical facts about corridor graphs. This
extension joins them to the persistence threshold of project P7 (`P7.HabitatThreshold`), which says
a Levins population with colonisation rate c, extinction rate e and habitat fraction h persists
exactly when e / c < h. P7 deliberately says nothing about how a network sets c. This statement
does not say it either: it takes the link as a declared hypothesis and shows what follows.

## P6.CorridorPersistence

`V` is a finite type of patches (`Fintype V`, `DecidableEq V`), graphs `G : SimpleGraph V` with
decidable adjacency. A colonisation map is `col : SimpleGraph V → ℝ` with 0 < col G for every G
and col G ≤ col H whenever G ≤ H (more corridors never lower colonisation). Definition:
threshold (e : ℝ) (col) (G) : ℝ := e / col G.

Statement: a conjunction of three parts, for every e with 0 < e and every such col.

1. Losses only raise the threshold. For every G and every x ∈ G.edgeSet:
   threshold e col G ≤ threshold e col (G.deleteEdges {x}).
2. Robust persistence. For every G, h with G.edgeSet nonempty: if
   threshold e col (G.deleteEdges {x}) < h for every x ∈ G.edgeSet, then threshold e col G < h,
   and h - threshold e col (G.deleteEdges {x}) > 0 for every x (each single loss leaves a positive
   equilibrium occupancy, in P7's sense).
3. A count-based map cannot see fragmentation. With col G = 1 + G.edgeFinset.card on `Fin 3`, the
   path with edges 0–1 and 1–2 has an edge whose removal disconnects it (P6.MinimalNetwork part 3)
   while its threshold with e = 1 after that loss is 1/2 < 1 = h. State this as an existential
   over the edge, with both conjuncts.

Check before proposing: part 1 is `G.deleteEdges {x} ≤ G` and division by a smaller positive
number; part 2 uses one edge from the nonempty set and part 1; part 3 is a concrete computation
(`decide` for disconnection may need the reachability facts restated by hand).

Sanity checks to include: on the path on `Fin 3` with col G = 1 + (number of corridors), the
threshold with e = 1 is 1/3 with both corridors and 1/2 after either loss. Negative control to
describe: part 1 fails for a map that is not monotone (col G = 1 / (1 + number of corridors),
which lowers colonisation as corridors are added).

The rationale must say that the colonisation map is an assumption taken as a hypothesis, that how
a real corridor changes colonisation is a field question, and that part 3 is there because a map
depending only on the corridor count cannot tell a connected network from a fragmented one: a
planner using such a map must check connectivity separately, which is what P6.MinimalNetwork and
P6.SingleFailureRobust are for.
