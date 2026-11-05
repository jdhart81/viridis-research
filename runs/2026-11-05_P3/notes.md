# P3-T001 lab notebook (2026-11-05)

Task: propose four sealed statements (P3.LoopMassBalance, P3.CascadedRecovery,
P3.RecoveryWorkFloor, P3.CyclicSymbiosis).

## Session start
- No prior runs for P3; no pending Aristotle projects to fetch.
- `inputs/context/STATEMENT_PROPOSAL.md` referenced by the prompt does not exist; used
  `inputs/statements/P2.Restoration.lean` as the house style for a statement module.
- Read context/ReciprocityCorridor.lean (Run-128) and context/UsefulDissipatedWork.lean (Run-163).

## Work done (00:29–01:00 UTC)
- Drafted four statement modules in `proposals/`; all compile with `lean` under the pinned
  toolchain with no warnings. Each has `norm_num`/`simp`/`decide` sanity examples incl.
  negative controls. Rationale files list every hypothesis and what is not settled.
- Probe check (my own, approximating the verifier): `simp`, `norm_num`, `decide`, `aesop`,
  `trivial`, `simp_all`, `exact?` each fail to close every one of the four `Statement`s.
- Truth check: I wrote scratch proofs of all four `Statement`s in /tmp (outside `out/`); all
  compiled with no errors and no `sorry`. These are NOT claims and are not in `out/proofs/`
  (the statements are not sealed). Proof sketches for the follow-up proof tasks:
  - LoopMassBalance: induction on t with `field_simp; ring` for the gap recursion;
    `tendsto_pow_atTop_nhds_zero_of_lt_one` + `.mul_const` + `.add_const`; the sum is
    `simp [cumulativeVirgin, virgin]; ring`; StrictAntiOn by `nlinarith [mul_pos hT hD]`.
  - CascadedRecovery: `Finset.prod_le_prod` against the constant `1 - m`;
    `Finset.mul_prod_erase _ (fun i => 1 - r i) (Finset.mem_univ j)` to split off stage j;
    `Finset.prod_le_one` for the rest; iSup via `le_ciSup (Finite.bddAbove_range r)` and
    `ciSup_le` (case n = 0 by `simp`).
  - RecoveryWorkFloor: `div_le_iff₀` + `nlinarith` with `mul_le_mul_of_nonneg_right`;
    attainment by `field_simp; ring`.
  - CyclicSymbiosis: `prev` injective (mod arithmetic: add 1, `Nat.add_mod_right`,
    `Nat.mod_eq_of_lt`), hence bijective by `Finite.injective_iff_bijective`, so
    `∏ x (prev i) = ∏ x i` (`Fintype.prod_bijective`). Forward: `Finset.prod_lt_prod_of_nonempty`
    then cancel `∏ x`. Backward: `a i = v i / c i`, `P = ∏ a > 1`, `lam = P^(1/N)` (rpow),
    `lam^N = P`; extend `a` to `A : ℕ → ℝ`;
    `x i = (∏ k ∈ range (i+1), A k) / (A 0 * lam^i)`; for i ≥ 1, `prev i = i-1` and
    `x i = x(prev i) * a i / lam`; for i = 0, `a 0 * x (N-1) = P / lam^(N-1) = lam > 1 = x 0`.
    About 120 lines in total.
- Aristotle: `aristotle submit` for CyclicSymbiosis failed immediately with "Invalid Aristotle
  API key". No project ID was created. Nothing is pending.
- `inputs/context/STATEMENT_PROPOSAL.md`, named in the prompt, does not exist. I followed the
  style of `inputs/statements/P2.Restoration.lean`.

## Design decisions to flag for Justin
- RecoveryWorkFloor part 1 is algebraically equivalent to Run-163 `target_requires_supply`
  (`(T - emax wr)/emax = T/emax - wr`). The new content is the recovery reading and the attainment
  half. If a stronger target is wanted, separate caps for fresh and recovered efficiency
  (`ef ≤ ef_max`, `er ≤ er_max`) would give `wf ≥ (T - er_max wr)/ef_max`.
- CascadedRecovery uses `⨆ i, r i` for the max (equal to 0 on `Fin 0`) and also includes a
  uniform-bound form.
- CyclicSymbiosis keeps `2 ≤ N` per the brief, although the equivalence also holds at N = 1.

## Wrap-up (~01:25 UTC)
- `code/probe.sh` re-run gave `results/probe_results.tsv`: all 4 modules compile, and all 28
  tactic probes leave the statements open.
- Paper `paper/main.tex` (+ `refs.bib`, 6 references, each checked by WebSearch/WebFetch,
  DOIs included) compiles with latexmk in a clean scratch dir. One cosmetic 8pt overfull box
  remains in the reproducibility section. The paper contains informal mathematical arguments
  for each statement but claims no Lean proof.
- run.json has one empirical claim (C1: compile + probe results) and four proposals.

## Open questions for Justin
1. Should RecoveryWorkFloor use separate efficiency caps (stronger) instead of the common
   `emax` from the brief?
2. CyclicSymbiosis: is a single directed cycle enough for the byproduct-exchange module, or is a
   general network (every cycle of the exchange graph satisfies the product condition) the next
   rung?
3. LoopMassBalance: should a stock-limited recovery variant (`rD ≤ ρ S(t)`) be added later?

## Next steps
- Wait for the sealing decision; then prove each statement (sketches above).
- Check Aristotle API access before planning around it.
