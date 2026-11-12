# P4-T001 lab notebook (2026-11-12)

Task: re-execute the registered P1C v1.4 confirmatory test (northeast Washington), unchanged, and write it up.

## What was done
1. Read inputs/context: README, INPUTS.json, P1C_RESULTS.md, PREREGISTRATION_P1C_NEWA_v1.4.md, ADDENDUM_v1.4.md.
   Context files match inputs/context/SOURCES.sha256.
2. Downloaded all 11 data_pins inputs and code/run_test.py from raw.githubusercontent.com at the registered commit
   cfdf55a24b2b833ef88dcd160813edab9c7116dd. Gunzipped the three .gz files (p1c predictors, pilot outcomes, pilot predictors).
   **All 12 SHA-256 hashes match INPUTS.json.** code/rerun_p1c.py copied unchanged from inputs/context (hash 065fe6a5... matches).
   No file was edited.
3. out/data_pins.json = the data_pins object of INPUTS.json, exactly. Its file list equals the contents of out/data/ (11 files).
4. Environment: `python3 -m pip install --user ...` was refused (PEP 668, externally managed). Used a venv outside out/
   (/home/agent/venv) with numpy 2.5.4, pandas 3.1.1 (the verifier's versions), Python 3.12.3.
   - First run FAILED: the frozen run_test.py imports `scipy.stats.t` (t critical value for the v1.1-rule reading) and scipy
     was not installed. The task brief mentions only numpy and pandas. The verifier image includes scipy. Installed scipy 1.18.1.
5. `python3 code/rerun_p1c.py` from out/ with empty results/: rc=0, a few minutes. Output:
   PRIMARY (B, M2R): SUPPORTED | REPLICATED; beta = 0.05313557, se_twoway 0.01201, se_year 0.00966, interval
   [0.022751, 0.083520], n = 11,314, T = 4.424. inputs_verified = true, synthetic = false.
6. Every number in P1C_RESULTS.md was checked against results/p1c_results.json (primary, other intervals, small telescopes,
   S13, leave-one-year-out, stacked comparison, S1-S12, secondary models, H3, H4). **All agree** to the published precision.
7. Determinism: deleted results/ and re-ran; both files are byte-identical across the two runs.
   - results/p1c_primary.json sha256 6741918aea2b5a19f09c54cd38c9b9a9767fcc4f104574e777f09de73d04c7f6
   - results/p1c_results.json sha256 adda924a11ff4ab64b8b29180d1817bfac38d41f00370afece46809e9326b534
8. Hash vs INPUTS.json "expected" (0770488159..., numpy 2.5.3 / pandas 3.0.5, 2026-11-09): **differs**. Cross-check in a scratch
   copy (/tmp, not in out/) with a second venv holding numpy 2.5.3, pandas 3.0.5, scipy 1.18.1 gave a third hash (ccde8cd9...).
   All non-float fields are identical; the max relative difference of any float is 8.9e-13 (primary file) and 5.8e-12 (full results).
   So the hash differences are last-digit floating-point rounding (platform / BLAS), well inside the verifier's 1e-6 tolerance.
9. Paper (out/paper/main.tex + refs.bib): full report of the registered study. It compiles cleanly with latexmk -pdf; I built it in a scratch copy so no aux files land in out/.
   DOIs resolved via doi.org (Crossref BibTeX): Cameron et al. 2011, Simonsohn 2015, Abatzoglou 2013, Eidenshink 2007,
   Rollins 2009, Scott & Burgan 2005, Short 2014, FPA FOD 7th ed. (10.2737/RDS-2013-0009.7), O'Connor et al. 2016 and 2017.
   Trees Cannot Cut concept DOI 10.5281/zenodo.21686446 (Zenodo API: latest version 1.0.1, 10.5281/zenodo.21708530).
   TIGER, NHD and LANDFIRE FBFM40 are cited by URL (no DOI found). An initial guess at an O'Connor DOI (geosciences7010013)
   resolved to an unrelated paper and was not used.

## Observations / open questions
- P1C_RESULTS.md names the registration commit 9e79127d...; the inputs were downloaded at cfdf55a2... (the later commit in the
  same PR that also holds the results folder). Hashes match FREEZE.json either way.
- The task brief's install instructions omit scipy; future P4 tasks that re-run run_test.py-family scripts need it.
- No new analysis, subgroup or model was added (by design).

## Aristotle
- None (empirical task, no Lean work). No pending projects from prior runs (no prior runs).

## Next steps
- If C1 is labelled TESTED, take on the next registered real-fire test (for example the pilot, if its frozen package is pinned).
