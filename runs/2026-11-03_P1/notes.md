# P1-T002 lab notebook (2026-11-03)

Task: propose sealed statements P1.Insertion (L2) and P1.Bridge (L3).

## Log
- Session start. Prior run 2026-10-28_P1 used no Aristotle projects; nothing pending.
- P1.BitQuad is present in inputs/statements/ (sealed; certified PROVEN in prior run), so the proposals import it.
- Design decision: Statement uses semantic definitions on all of Z^2 (Mathlib SimpleGraph.fromRel for 4- and 8-adjacency,
  induced subgraphs, ConnectedComponent, enclosed := component with finite support, counted by Nat.card). These are not
  decidable, so the controls are checked by `decide` against a separate computable bounded-box flood-fill model
  (boxC8, boxEnclosed) that the Statement does not mention. Agreement of the box model with the semantic definitions
  is NOT proved; it is a natural lemma for the proving task.
- Bridge Statement also asserts finiteness of the set of enclosed components, to defuse the Nat.card-of-infinite = 0 trap.
- Proposals cannot import each other, so both modules restate the same definitions verbatim.
- decide timings: ring/block/diamond ~3-5 s each. Two disjoint rings (box 9x5) hit the 200000-heartbeat limit; dropped.
  A full 256-configuration table by decide would take too long (est. >10 min of kernel time); done in Python instead.
- Both modules compile with `lean` (Bridge ~20 s, Insertion ~50 s).
- Aristotle: submission failed immediately with "Invalid Aristotle API key". No project ID was created. Did not retry
  or work around it.
- Python check (code/bridge_check.py -> results/bridge_check.json): L3 holds on all 65,536 subsets of a 4x4 box and
  3,000 random rasters up to 12x12; L2 holds on 10,496 insertions covering all 256 configurations of the 8-neighbourhood,
  each in 41 contexts. 0 failures. Evidence, not proof.
- Proved the control values for the *semantic* definitions inside both modules (namespace Controls), with no sorry
  and no box model: enclosed ring = 1, enclosed block = 0, enclosed diamond = 1, enclosed ∅ = 0, C8 = 1 for
  ring/block/diamond, C8 ∅ = 0. Key lemmas: infinite_of_ray (a free horizontal ray makes a component infinite) and
  isolated (a pixel whose four 4-neighbours are barrier is a finite component). Combined with decide on euler, the L3
  identity is checked on ring, block and diamond for the real definitions. Pitfall hit: abs_cases sign facts must be
  kept for omega.
- Paper extended: new title/abstract, section on the proposals, controls table, evidence section, Rosenfeld 1970
  (DOI 10.1145/321556.321570, checked via Crossref), changelog entry. Compiles with latexmk -pdf (2 small overfull hboxes).
- L1 proof file and bitquad_check.py are not repeated in this run's out/; the paper points to the 2026-10-28 package.

## Aristotle project IDs
- None. The single submission attempt failed with an invalid API key before creating a project.

## Open questions
- Should the box-model/semantic agreement become its own sealed rung (a "localisation" lemma)? It would make the
  decide checks bind to Statement, and it is also the core of the finiteness clause of P1.Bridge.
- L2 and L3 (equation) are equivalent given the base case. Sealing both is still useful as a proof roadmap, but Justin
  may prefer a stronger L2 that names the local Delta-chi explicitly.
- A kernel-friendly encoding (e.g. bitmasks of the 3x3 neighbourhood) might let the 256-configuration table be
  checked by decide.

## Next steps
See run.json next_steps: localisation and finiteness, then local Delta-chi from L1, then Delta C8, then Delta enclosed
via the 8-cycle around p, then induction for L3.
