# P1-T001 lab notebook (2026-10-28)

## Plan
Double counting over vertices V of K(B):
- For S and shift (a,b) with x ∈ S ⇒ (x.1+a, x.2+b) ∈ V: #{v ∈ V : (v.1-a, v.2-b) ∈ S} = |S|.
- 4F = sum of the four window bits (shifts (1,1),(0,1),(1,0),(0,0) on B).
- 2E: arms of v are left (shift (1,0) on hEdges), right (shift 0), down (shift (0,1) on vEdges), up (shift 0).
- 4χ = Σ_v (4 - 2 arms + n); pointwise identity on 15 nonempty patterns by case split.

## Log
- Session start. No prior runs, no pending Aristotle projects.
- Wrote the proof in out/proofs/P1.BitQuad.lean along the plan above. The first full check failed only on a
  rewrite order (`← Finset.sum_sub_distrib` before `Finset.mul_sum`). After that fix,
  `viridis-lean-check out/proofs/P1.BitQuad.lean P1.BitQuad` gave PASSED (axioms: propext, Classical.choice, Quot.sound), ~20 s.
- `decide` on the 16 patterns was not needed: `obtain ⟨x, y⟩ := v` keeps the pairs from being rewritten by Prod.mk.eta,
  then `by_cases` on the 4 memberships plus `simp [ha, hb, hc, hd] at hne ⊢` closes all 16 branches
  (the empty branch is ruled out by `hne`, which says the window at a vertex is non-empty).
- Removed an unused Bool-level local identity lemma (`local_id`) from the final file. The file builds with no warnings.
- Aristotle: not used tonight (no lemma resisted). No project IDs. No pending projects from prior runs (there are none).
- Empirical sanity check: code/bitquad_check.py, all 2^16 subsets of a 4x4 box, 0 failures (results/bitquad_4x4.json).
- Paper: out/paper/main.tex (new; no prior paper existed). It compiles with latexmk -pdf; the Lean file is inlined in a listings block
  with literate replacements for Unicode. Two small overfull hboxes remain (cosmetic).

## Open questions
- The development does not identify the combinatorial V-E+F with the topological Euler characteristic of K(B) ⊂ R^2. L2/L3 should be designed not to need it.
- The 4-connected bit-quad variant (+2 QD) is not formalised. It might be useful if the complement-side argument wants it.

## Next steps
- P1-T002: propose P1.Insertion and P1.Bridge. Reuse the shift-counting lemma `card_shift` and `mem_hEdges`/`mem_vEdges` from this file.
- Prove a local Δχ lemma for insert p B as a corollary of L1 (or directly).
