# P1-T003 lab notebook (2026-11-08)

Task: prove sealed statement P1.Insertion (L2): inserting any pixel p ∉ B into a finite raster
leaves enclosed − C8 + euler unchanged.

## Session start (23:03 UTC)
- Prior runs (2026-11-04, 2026-11-03, 2026-10-28): no Aristotle project IDs were ever created
  (API key failures). Nothing pending to fetch.
- Copied the 2026-11-04 paper as the starting point.

## Log
- Step 1: Aristotle submission of the full statement (self-contained project /tmp/ar1, defs copied
  verbatim) failed immediately: "Invalid Aristotle API key". No project ID created. Not retried
  beyond this, not worked around. Working by hand.
- Step 2: Built a gap-free development (out/proofs/P1.Insertion.lean, compiles with
  `lean`; viridis-lean-check stops at "denylist: missing `theorem main`", as expected because there
  is no `Candidate.main`). Proved:
  * `euler_insert_local`: Δχ depends only on `win B p` (B ∩ 3×3 window). Route: card of a
    biUnion over `insert`, and every new corner/edge of p can only be shared with window pixels.
  * `C8_insert`: C8(insert p B) = C8 B + 1 − k, k = #8-components of B containing an
    8-neighbour of p. Route: map of components along the inclusion hom; walk lemma by
    ReflTransGen induction; explicit bijection Option {non-touching} ≃ CC(insert p B).
  * `enclosed_insert` (needs hypothesis: B has finitely many enclosed components):
    enclosed(insert p B) = enclosed B − [old comp of p enclosed] + P, P = #enclosed comps of
    ℤ²∖(insert p B) containing a 4-neighbour of p. Route: same walk lemma for the complement,
    supports preserved away from p (so finiteness preserved), bijection of the untouched parts.
  * `invariant_insert` and `statement_of_jordan`: Statement follows from (i) finiteness of
    enclosed components for every B and (ii) the Jordan identity
    P − [cp enclosed] − (1 − k) + Δχ(win B p) = 0.
  Pitfalls: `congrArg Subtype.val h` mis-elaborates on hom applications (use an explicit lambda);
  `if IsEnclosed ..` needs `open Classical in`; `Finite.card_option` (not Nat.card_option).
- Step 3: Proved `finite_enclosed` (F): every finite B has finitely many enclosed components
  (bound M from a sum of |coords|; pixels outside [-M,M]² have a free horizontal ray, using the
  sealed module's `Controls.infinite_of_ray`/`ray_right`/`ray_left`; injective choice of
  representatives via `Quot.exists_rep`). `invariant_insert` and `statement_of_jordan` no
  longer need a finiteness hypothesis. `#print axioms statement_of_jordan`:
  [propext, Classical.choice, Quot.sound] (checked in a scratch copy, not shipped).
- Paper updated (new section "Toward a proof of L2"), compiles.
- Step 4 (done by 23:15 UTC): Proved `insertion_hole`: invariant (insert p B) = invariant B when all four 4-neighbours
  of p are in B (P = 0; cp = {p} enclosed via sealed `Controls.isolated`; k = 1 since all
  8-neighbours reach N via S–E–N, using `barrier_adj_iff`/`g8_adj_iff`; Δχ = 1 since all
  corners/edges of p are already present). Axioms: standard three only. File now 658 lines.

- Step 5 (23:16-23:25 UTC): raster-scan reduction, all compiled with no gaps:
  * `statement_of_scan` / `invariant_zero_of_scan`: Statement follows from insertions with
    `Before B p` (Finset.induction_on_max_value with key toLex (q.2, q.1); base case
    invariant ∅ = 0 from the sealed Controls lemmas).
  * `cp_not_enclosed`, `touch_enclosed_eq_S`, `P_scan`: in scan order the old component is
    infinite; the new pieces at E, N, W are infinite (W is 4-adjacent to NW); so
    P = [SEnc B p].
  * `euler_scan`: Δχ = [W,S,SW ∉ B] + [S,SE ∉ B] − [S ∉ B] (membership lemmas for the four
    corners and four edges of p).
  * `statement_of_core`: case analysis (S ∈ B; S,SE ∉ B with/without L; S ∉ B, SE ∈ B, no L)
    closes four cases; the fifth is hypothesis hcore: [SEnc] + k = 2.
  * `k_core`, `statement_of_halfplane_jordan`: in the fifth case k = 1 if JoinLR else 2,
    so Statement follows from hJ: SEnc B p ↔ JoinLR B p.
- code/core_check.py -> results/core_check.json: hJ holds in 17,344 configurations
  (7,924 enclosed / 9,420 not), 0 failures; scan insertions 15,281, 0 failures.
  Mutation (ignore SW in JoinLR): 3,662 failures, so the test discriminates. 3 s.
- Paper: new paragraphs (scan order, Table of five cases, conjecture), new reference
  Rosenfeld & Pfaltz 1966 (DOI 10.1145/321356.321357, checked on Crossref).

- Step 6 (23:31-23:40 UTC): one direction of hJ and half of L3, all compiled with no gaps:
  * `senc_of_join` (JoinLR → SEnc): crossing parity. N(v) = number of steps of the closed curve
    p → (8-walk in B from L to SE) → p joining column v.1 to v.1+1 whose column-v.1 endpoint is
    above v. Per-step identities mod 2 (`cross_horiz`, `cross_vert`, `cross_below`) are
    checked by `split_ifs <;> omega`; `dsum_parity`/`cycle_parity` sum them along the walk.
    N is constant mod 2 along free 4-steps, odd at S, even outside a box -> component of S
    lies in a finite box.
  * `scan_step_eq_or_core`, `scan_step_mono`: every scan-order insertion changes the invariant
    by 0 or +1. `invariant_nonneg` / `enclosed_ge`: enc(B) ≥ C8(B) − χ(B) for all finite B.
  * `statement_of_enc_join` (Statement from SEnc → JoinLR) and `statement_of_le` (Statement
    from enc ≤ C8 − χ).
  Pitfalls: lambdas left un-beta-reduced after `rw [dsum_add]` (use `beta_reduce`);
  `rw [abs_lt]` on `|a| < M ∧ |b| < M` rewrites only the first instance (use `simp only`).

## Status at end of session
- out/proofs/P1.Insertion.lean: no gaps, compiles, standard axioms only, but NO `Candidate.main`;
  viridis-lean-check reports "denylist: missing `theorem main`" -> NOT PASSED (expected).
- Proved: euler_insert_local, C8_insert, enclosed_insert, finite_enclosed, invariant_insert,
  statement_of_jordan, insertion_hole, statement_of_scan, euler_scan, P_scan, k_core,
  statement_of_core, statement_of_halfplane_jordan, bridge_of_halfplane_jordan (the L3
  equation enc = C8 − χ from the same hypothesis hJ), senc_of_join, invariant_nonneg,
  enclosed_ge, statement_of_enc_join, statement_of_le. File: 1607 lines, ~20 s.
- Open: ONLY the hypothesis of `statement_of_enc_join` (one direction of hJ):
    ∀ B p, p ∉ B → Before B p → S ∉ B → SE ∈ B → (W ∈ B ∨ SW ∈ B) → SEnc B p → JoinLR B p
  equivalently ∀ B, enc B ≤ C8 B − euler B (the other inequality is `enclosed_ge`).
  (S = p+(0,−1), SE = p+(1,−1), W = p+(−1,0), SW = p+(−1,−1)). This is a half-plane digital
  Jordan lemma. Unavoidable by changing the order: in the diamond, every pixel inserted last in
  any of the 8 scan orders is in this case.

## Aristotle project IDs
- None created. 2026-11-08 submission (full statement) failed: invalid API key.

## Open questions
- Should the remaining direction of hJ (or enc ≤ C8 − χ) be sealed as its own rung? It is now
  the only gap.
- Why Jordan cannot be avoided by a smarter order: steps where p is simple, isolated or interior
  (all 4-neighbours barrier) are local, but simple closed 8-curves such as the diamond have no
  such pixel. For them, L3 already contains the digital Jordan curve theorem.
- Should the paper's link to Trees Cannot Cut (raster-to-corridor-graph correspondence) be
  stated as a separate proposal once L2/L3 are done?

## Next steps
1. Prove SEnc → JoinLR (JoinLR → SEnc is done: `senc_of_join`). If L and SE are in
   different 8-components of B, build a free 4-path from S around the 8-component of SE to
   the free upper half-plane (boundary following), or prove that the outer border of a finite
   4-connected set is 8-connected and apply it to the component of S.
2. Consider proposing that direction (or enc ≤ C8 − χ) as its own sealed rung.
3. Once L2 is done, P1.Bridge: clause (1) is essentially `finite_enclosed`, and the equation is
   `invariant_zero_of_scan`.
