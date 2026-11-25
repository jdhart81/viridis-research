# P6-NucleationIslandSize: does per-area recruitment rise with planted-cluster size?

Tests premise **M-Nucleation** (P2.Afforestation, P2.Restoration rest on it).

## Hypothesis
M-Nucleation models a planted cluster of n trees with free energy G = -dmu*n + a*sigma*n^(2/3).
The surface term penalises small clusters relative to their size, so the per-tree (per-area)
tendency of a cluster to grow, -dG/dn = dmu - (2/3)*a*sigma*n^(-1/3), increases with n.
The necessary, testable consequence used here: **in planted tree islands on degraded pasture, the
density (per m^2) of naturally established tree seedlings surviving to the final census increases with
island size: small (4x4 m) < medium (8x8 m) < large (12x12 m).** A reversed ordering (large islands
recruiting fewer per m^2 than small ones) contradicts the premise.

This tests only the size-scaling consequence of the premise, not its free-energy mechanism, and not
the existence or value of the critical size n*. Tree-island recruitment is also driven by disperser
attraction, which the premise does not model. A SUPPORTED verdict does not establish the mechanism.

## Data
- Outcome (not opened by the proposer): `tree_recruits-2007-2013.csv` from Zahawi, Holl, Cole & Reid,
  "Data from: Testing applied nucleation as a strategy to facilitate tropical forest recovery",
  Zenodo record 4731126 (DOI 10.7291/D11681, CC0). Downloaded to `data/tree_recruits.csv`.
  Before writing the code, only the record's file listing and its ReadMe (column definitions) were read.
- Fixed now: `data/design.json`. It holds the sampled area per class per plot (assumed two islands of each size, recalled from Zahawi et al. 2013, J. Appl. Ecol. 50:88-96, doi:10.1111/1365-2664.12014, but not confirmed:
  S 32 m^2, M 128 m^2, L 288 m^2; control interior 40x40 m = 1600 m^2), the final census column `Surv13`,
  the alive codes (`1`, `c`, `tpm`, `n`), a pseudocount of 0.5 recruits, at least 5 sites, 10000
  bootstrap draws and seed 20261125. If the actual number of islands per size differs from two, all
  three classes are scaled by the same factor, so the log ratios between sizes do not change.

Disclosure on severity: a web-search summary of the 2013 paper's abstract that the proposer saw says
the reported recruit density was higher in large than small islands. That makes a SUPPORTED verdict on
this dataset likely, so the test is weaker than a blind one. The analysis differs from the paper's: it
counts only seedlings (`Sd/Rs = s`) alive at the 2013 census, excludes the 2013 edge buffer (`FQ = LTB`)
and uses site-level log ratios with a bootstrap.

## Analysis (code/analyze.py, Python standard library only)
1. Rows: island plots (`Treat = I`, `Isz` in S/M/L) and control interiors (`Treat = C`, `FQ = LT`);
   rows with `FQ = LTB` are dropped. Count seedlings alive in 2013 per site and class.
2. Per site with island rows: log density = log((count + 0.5) / area). Compute
   r_LS = logdens(L) - logdens(S), r_MS and r_LM.
3. Bootstrap over sites (10000 draws, seed fixed) for a 95% percentile CI on mean r_LS.

## Decision rule
- `NOT_ESTIMABLE`: outcome file missing or fewer than 5 sites with island plots.
- `SUPPORTED`: CI lower bound of mean r_LS > 0, and mean r_MS > 0 and mean r_LM > 0 (monotone).
- `CONTRADICTED`: CI upper bound of mean r_LS < 0 (large islands recruit significantly fewer per m^2).
- `NOT_SUPPORTED`: anything else.

## What would contradict it
Large islands carrying significantly lower per-area density of surviving recruits than small islands,
across sites. The control column is reported but is not used in the verdict.

## Fixtures
`fixtures/supported/data/` and `fixtures/contradicted/data/` hold made-up `tree_recruits.csv` files (8 sites,
per-area densities increasing and decreasing with size, respectively) and a copy of `design.json`.
