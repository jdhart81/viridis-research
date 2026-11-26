# Reproduce `runs/2026-11-26_P6`

Run date 2026-11-26. Verified by engine version `90222ed1bdaa`; the verifier kit in this repository
(`engine/lean_check.py`, `engine/reproduce.py`) re-runs every check.

## Everything at once

```bash
git clone https://github.com/jdhart81/viridis-research && cd viridis-research
# the commit that added this run, so Lean and Mathlib are the ones it was verified with
git checkout "$(git log --diff-filter=A --format=%H -1 -- runs/2026-11-26_P6/MANIFEST.sha256)"
# Lean toolchain and the Mathlib cache (pins in lean/lean-toolchain and lean/lake-manifest.json)
curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none
(cd lean && lake exe cache get)
python3 -m engine.reproduce runs/2026-11-26_P6
```

`engine.reproduce` checks `MANIFEST.sha256`, re-runs every Lean check below, and reports the result
for each claim. Add `--docker` to run the checks in the same sandbox the verifier uses.

## Lean checks

- Toolchain `leanprover/lean4:v4.28.0`, Mathlib `8f9d9cff6bd728b17a24e163c9402775d9e6a365`.
- `lean/` in this folder holds each sealed statement module, the candidate proof, and the check file
  the verifier generated (`ViridisCheck.lean`), which asserts the statement match and prints the axioms.

### C1: `P6.SerialParallel` (PROVEN)

- Statement: `lean/P6.SerialParallel/Statement.lean` (sha256 `a882c97873aba9a8589b820eb1d894b9ba79489c067a1a05bce8c070b76889e3`)
- Candidate: `proofs/P6.SerialParallel.lean` (sha256 `c128f57f223e46b90007f8511f12a767b18d2e180006f77c691c884b7bf07504`)
- Verifier result: stage `passed`, axioms `Classical.choice, Quot.sound, propext`

## Re-executed analyses (TESTED)

The verifier ran each script below in a sandbox with no network, with this folder's `code/` and
`data/` as the only inputs, and compared the result files it produced with `results/`. The input
files and their sources are listed in `data_pins.json`; `certification.json` (`reexecution`) records
the hashes. To repeat it: `python3 -m engine.reexec runs/2026-11-26_P6` (add `--docker` for the
verifier's image, `docker/py/Dockerfile`).

- C2: `code/analyze.py`

## Paper

`paper.pdf` is the verifier's certification page followed by the compiled paper. To rebuild the paper,
run `latexmk -pdf -no-shell-escape main.tex` in `paper/`, with `docker/tex/viridis-lean.sty` on
`TEXINPUTS` (the verifier builds it in `docker/tex/Dockerfile`).
