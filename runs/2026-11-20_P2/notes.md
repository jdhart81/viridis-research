# P2-T014 lab notebook (2026-11-20): propose sealed statement P2.Tempo

## Start
- Task: proposal for the Tempo cadence kernel. No canon Lean source (README, Tempo section).
- context/Tempo_function.json sha256 3a8c5312...f294827 and context/Tempo_runner.py sha256
  a98b5c65...28d07745 match context/SOURCES.sha256.
- Prior runs (11-02, 11-01, 10-31): no Aristotle projects pending.
- STATEMENT_PROPOSAL.md is still absent from inputs/context (task said to read it first).

## Checks of the brief's six parts (by hand, then in scratch Lean)
- All six parts as written in the brief are true. Key identities: with s = sqrt h, r = sqrt n,
  Sigma(t) - 2sr = (s - r t)^2 / t; cosh(log x) = (x + 1/x)/2 (Mathlib `Real.cosh_log`).
- Published example h=4, n=1, t=2: optimum 2, floor 4, cost 4, normalised 1, tax 1. Matches.
- Units: registry gives h and n both "cost per cycle"; h/t + n t needs n in cost/time^2 if h is a
  cost. A documentation issue, not mathematical.

## Deposited source found (important for P2-T015 / sealing)
- WebFetch of doi:10.5281/zenodo.20705183 -> Zenodo record "The Stewardship Tempo Theorem: The
  Optimal Pace of Conservation Action", J. D. Hart, S4-v1, published 2026-06-15, modified
  2026-11-14 (after the 11-11 replay), "a newer version exists". Files: ARISTOTLE_SUMMARY.md,
  S4_STT.pdf, S4_STT.tex, StewardshipTempo.lean (7.3 kB), viridis-journal.cls.
- Got the six theorem signatures of StewardshipTempo.lean as a quotation through WebFetch (summarising
  model). Not a byte-level read: copying/reading the saved binary was denied by the sandbox
  permission mode and I did not work around it. NOT hashed, compiled or replayed.
- Per that quotation (namespace ViridisForge.Tempo, cost A/τ + Bτ, 0<A, 0<B):
  (1)-(4) identical to the brief. haste_neglect_cosh: ∀ u>0, (u + 1/u)/2 = cosh(log u).
  governability_tax: (A/τ+Bτ)/(2√(AB)) = cosh(log(√(A/B)/τ)) (ratio inverted vs runner).
  No deposited theorem states tax ≥ 1 or the iff.
- Decision: keep every part of the brief and conjoin the deposited form into parts (5) and (6), so
  that the sealed Statement implies both. Justin can delete the two deposited conjuncts to get the
  brief's form.

## Proposal out/proposals/P2.Tempo.lean
- Compiles with `lean` (pinned toolchain), no warnings. No denylisted tokens.
- Sanity examples: published example; h=1,n=4 witness; cosh(log 2) = 5/4 = normalised cost at
  t=1; negative controls t=1 (cost 5 > 4), t=-2, n=0 (parts 5 and 6 fail), h=0 (no strict
  convexity). All closed by norm_num/rewrites (decide does not apply over ℝ).
- Feasibility: scratch /tmp/scratch/Scratch.lean proves the full Statement (not in out/, not a
  claim). Uses `Real.cosh_log`, `Real.one_lt_cosh`, `Real.log_eq_zero`, `Real.sqrt_mul`,
  `Real.sqrt_div'`, field_simp/nlinarith; strict convexity directly from the definition via the
  identity (a h/x + b h/y)(a x + b y) = h + h a b (x-y)^2/(xy) with b = 1-a.
- Probe: 17 one-shot tactics after `unfold Statement`; none closes it.

## Aristotle
- Not used; no project IDs.

## Paper and run record
- paper/main.tex extended: Tempo section (sec:tempo), status/proposal table rows, Tempo scope
  paragraph, limitations (deposit provenance), reproducibility, changelog; retitled. Builds with
  latexmk -pdf in /tmp/ptex (no errors, no undefined citations). Added refs.bib entry HartTempo2026
  (DOI 10.5281/zenodo.20705183, confirmed via WebFetch of zenodo.org/doi/...).
- run.json: one proposal (P2.Tempo), one conjecture-kind observation (C1) on the deposit comparison.
- announcement.md written.

## Open questions
- Is the Zenodo StewardshipTempo.lean (modified 2026-11-14) the intended canon source? Should it be
  deposited in viridis-canon with its hash, per the registry's reconciliation note?
- Seal merged form or brief's six-part form?
