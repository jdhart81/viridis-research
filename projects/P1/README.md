# P1: a machine-checked raster bridge for *Trees Cannot Cut*

## Background

Hart (2026), *Trees Cannot Cut: Circuit Rank as the Design Variable Reconciling
Habitat Connectivity and Fuel Discontinuity in Managed Forest Landscapes*
(Viridis LLC; concept DOI [10.5281/zenodo.21686446](https://doi.org/10.5281/zenodo.21686446)),
argues that fuel breaks and corridors separate a landscape into compartments
only through their cycles. An acyclic corridor ("a tree") leaves the fuel
matrix in one piece.

The paper's machine-checked core, `context/DualCorridor.lean`, proves the graph
theory that follows from the topology. The topological step itself is not
proved. It is carried as an explicit hypothesis, `FaceCount`: the number of
compartments equals circuit rank plus one, justified in the manuscript by
Alexander duality. Mathlib has neither Alexander duality nor a usable planar
Euler formula.

## Goal

Discharge that hypothesis in the discrete setting that real fire and
fuel-break data actually come in: rasters. For a finite barrier raster `B` in
`ℤ²`, read with 8-connected barriers and a 4-connected complement:

> enclosed non-barrier 4-components of `ℤ² \ B` = C8(B) − χ(K B)

Here `K B` is the union of the closed unit squares of `B`, and `χ = V − E + F`.

## Lemma ladder

| Rung | Statement ID | Content | Status |
|---|---|---|---|
| L1 | `P1.BitQuad` | `4·χ(K B) = Q₁ − Q₃ − 2·Q_D` (Gray's bit-quad formula, 8-connected form) | statement drafted in `lean/ViridisStatements/P1/BitQuad.lean`; sealing is decision D-001 |
| L2 | `P1.Insertion` | adding one barrier pixel preserves `enclosed − C8 + χ` | to be proposed (task P1-T002) |
| L3 | `P1.Bridge` | the identity above for every finite raster | to be proposed (task P1-T002) |

Controls that any proposed L2/L3 statement must reproduce:

- **Witness.** A 3×3 ring has C8 = 1, χ = 0 and one enclosed component.
- **Negative control 1.** A solid 2×2 block encloses nothing. Its
  8-neighbour graph is K4, whose circuit rank is 3, so reading graph circuit
  rank as a compartment count fails here.
- **Negative control 2.** Four pixels N, S, E and W of an empty centre form an
  acyclic 4-neighbour graph, yet under (8,4) connectivity the centre is
  enclosed. This makes the adjacency pairing load-bearing.

## Scope of this public project

This repository starts the formal track. The empirical P1 program (real-fire
pilot, preregistered confirmatory test and mechanism test) is archived
privately. It enters this repository only through a pull request that Justin
approves, together with its registrations.
