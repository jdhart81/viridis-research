# P3-T005 lab notebook (2026-11-18)

Task: prove sealed statement P3.CyclicSymbiosis (sealed by D-014, sha256 a6825700...).

## Session start
- Prior runs checked for pending Aristotle projects: none pending (2026-11-15/16/17 did not use
  Aristotle; 2026-11-05 submission failed).
- Paper started from 2026-11-17 run's main.tex.

## Proof (out/proofs/P3.CyclicSymbiosis.lean)
- prev_val: (prev i).val = if i = 0 then N-1 else i-1 (split_ifs, Nat.add_mod_right, mod_eq_of_lt).
- prev_bijective via Finite.injective_iff_bijective + omega; prod_prev via Fintype.prod_bijective.
- necessity: Finset.prod_lt_prod_of_nonempty on c_i x_i < v_i x_{prev i}, prod_mul_distrib,
  prod_prev, lt_of_mul_lt_mul_right.
- sufficiency: P = prod v / prod c > 1, s = P^(1/N) (Real.rpow), s > 1 (Real.one_lt_rpow),
  s^N = P (Real.rpow_inv_natCast_pow); a_i = v_i/(c_i s), prod a = 1; x_i = prod_{j in range(i+1)} a'_j
  with a' the extension of a to N by 1; recursion x_i = a_i x_{prev i} (case i=0 uses
  Fin.prod_univ_eq_prod_range and prod a = 1); net_i = v_i x_prev (1 - 1/s) > 0.
- First attempt PASSED viridis-lean-check (preview); axioms propext, Classical.choice, Quot.sound.
  `lean` compile: no warnings.
- Added helper corollary `two_partner_corridor`: from `main` at N = 2, Run-128's strict
  feasibility test (exists x,y>0 with uX>0, uY>0) <-> ProductCondition vX cX vY cY. Re-checked:
  PASSED (preview).
- Observations: necessity does not use v>0; N>=2 only used for nonemptiness (statement also true
  for N=1, false for N=0).

## Aristotle
- Not used this session (not needed). No project IDs. None pending.

## Paper
- Rewritten as a note on CyclicSymbiosis: model, theorem, human proof with explicit flow,
  hypothesis remark, worked 3-partner example (checked by hand: x = (4/s, 2/s^2, 1), s = 2^(1/3)),
  N=2 section, full Lean listing, settled/not settled, reproducibility, changelog.
- refs.bib: added Run-128 Zenodo record doi:10.5281/zenodo.21971047 (confirmed by WebFetch:
  "The Reciprocity Corridor: A Bilateral-Benefit Test for Directional Information Exchange",
  J. D. Hart, 2026-08-17, v0.2.2-release-reconciled).
- Compiles with latexmk -pdf in a scratch dir; 0 overfull boxes, no missing characters.

## Open questions / next steps
- All four P3 sealed statements now have candidate proofs that passed the preview check.
- Candidate extensions (not sealed): general strongly connected exchange graph (conjecture: the
  condition becomes a max-cycle-product / spectral condition on the matrix of v_i/c_i ratios);
  fixed costs or capacity limits; an N-partner Nash-bargaining split generalising Run-128 Thm 3.
