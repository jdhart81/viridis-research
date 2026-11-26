# P6-T004 lab notebook (2026-11-26)

Task: prove sealed statement P6.SerialParallel (sha256 a882c978...; sealed by D-026).

## Start of session
- Prior runs 2026-11-25, -24, -23 (P6) submitted no Aristotle jobs; none pending.
- No Aristotle jobs submitted this session (none needed).

## Main task
- Wrote out/proofs/P6.SerialParallel.lean. `viridis-lean-check` PASSED on the second attempt
  (axioms Classical.choice, Quot.sound, propext). Only the verifier awards PROVEN.
- First attempt failed: `Finset.mul_prod_erase` needs `DecidableEq ι`; the statement quantifies over
  arbitrary `ι : Type`. Fixed with `classical` at the start of the helper lemma.
- Proof route:
  - helper `prod_le_factor`: split off factor j with `Finset.mul_prod_erase`, bound the rest by
    `Finset.prod_le_one`, then `mul_le_mul_of_nonneg_left`.
  - part 1 is the helper directly.
  - part 2: apply the helper to `1 - q i` (in [0,1]); with `Finset.prod_nonneg`, linarith gives both bounds.
  - part 3: `le_total p q`; in case p <= q, LHS - q = p*(1-q), so equality iff p = 0 or q = 1
    (`mul_eq_zero`); converse by `subst` and `ring`. Symmetric case likewise.
- Cross-reference: part 1 is the same inequality as part 3 of P3.CascadedRecovery (p i = 1 - r i),
  proved in run runs/2026-11-16_P3 (P3-T003, label PROVEN per its certification.json fetched from
  github.com/jdhart81/viridis-research). Cited in the paper.

## Registered plan run: P6-NucleationIslandSize (tests M-Nucleation)
- Copied code/analyze.py (sha256 399d6e6b... matches REGISTRATION) and data/design.json (a8691696... matches) unchanged.
- Downloaded data/tree_recruits.csv from the registered Zenodo URL: OK, 382488 bytes,
  sha256 b35a35bbb5c89f3a717dbee677e96f45655177054b4aff8603783cd517fd861f. No pinned hash existed to compare against
  (template had a placeholder); recorded in data_pins.json.
- Ran `python3 -I code/analyze.py` from out/ with empty results/: verdict **NOT_ESTIMABLE**
  ("fewer than min_sites island sites", n_sites = 0).
- Cause (diagnosed, NOT fixed, analysis not changed): the frozen code reads the treatment column as `Treat`,
  but the file header names it `Trt` (header: Site,Trt,Isz,FQ,Species,Tag#,Disp,Sd/Rs,Surv07,...,Surv13).
  So every row has empty treatment and is skipped. The plan's PLAN.md also says `Treat`; the proposer
  worked from the ReadMe and never opened the file. The verdict therefore says nothing about M-Nucleation.
  Also I did not check whether the FQ codes (LT, LTB) or alive codes match the file; I only looked at the header and the first rows.
- Suggestion for the engine: a new plan (new ID) with the corrected column name would be needed; that is a
  new registration, not an edit of this one. The severity caveat in PLAN.md (the large>small result is already known) still applies.

## Premise reviews
- P6.SingleFailureRobust: independent reading, no premises. Pure finite graph theory on its own definitions;
  the module says it makes no claim about real corridors. (Agrees with the T003 review.)
- P6.SerialParallel (proved tonight): listed two modelling premises, M-IndependentLinks and M-IndependentRoutes.
  The sealed inequalities are pure algebra and hold regardless. But the module ties `serial` and `parallel` to
  route success probabilities, and those readings need independence, which the module itself calls a field assumption.
  Following "when unsure, list the premise".

## Paper
- out/paper/main.tex extended from the T003 paper. It now leads with SerialParallel and keeps the two graph
  theorems as statements. It compiles with latexmk -pdf; build files removed.

## Open questions / next steps
- P6 has no further sealed tasks listed in status.json after T004. Possible proposals: a strict version of part 2
  (strict gain if two routes have q in (0,1)); a positively correlated routes bound (parallel <= independent formula?
  no: positive correlation lowers P(at least one), so the independent formula is an optimistic upper estimate);
  a combined series-parallel network reliability statement.
