# Reproduce `runs/2026-11-12_P4`

Run date 2026-11-12. Verified by engine version `2368d59583c5`; the verifier kit in this repository
(`engine/lean_check.py`, `engine/reproduce.py`) re-runs every check.

## Everything at once

```bash
git clone https://github.com/jdhart81/viridis-research && cd viridis-research
# Lean toolchain and the Mathlib cache (pins in lean/lean-toolchain and lean/lake-manifest.json)
curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none
(cd lean && lake exe cache get)
python3 -m engine.reproduce runs/2026-11-12_P4
```

`engine.reproduce` checks `MANIFEST.sha256`, re-runs every Lean check below, and reports the result
for each claim. Add `--docker` to run the checks in the same sandbox the verifier uses.

## Lean checks

- Toolchain `leanprover/lean4:v4.28.0`, Mathlib `8f9d9cff6bd728b17a24e163c9402775d9e6a365`.
- `lean/` in this folder holds each sealed statement module, the candidate proof, and the check file
  the verifier generated (`ViridisCheck.lean`), which asserts the statement match and prints the axioms.

This run made no formal claims.
## Re-executed analyses (TESTED)

The verifier ran each script below in a sandbox with no network, with this folder's `code/` and
`data/` as the only inputs, and compared the result files it produced with `results/`. The input
files and their sources are listed in `data_pins.json`; `certification.json` (`reexecution`) records
the hashes. To repeat it: `python3 -m engine.reexec runs/2026-11-12_P4` (add `--docker` for the
verifier's image, `docker/py/Dockerfile`).

- C1: `code/rerun_p1c.py`

## Paper

`paper.pdf` is the verifier's certification page followed by the compiled paper. To rebuild the paper,
run `latexmk -pdf -no-shell-escape main.tex` in `paper/`, with `docker/tex/viridis-lean.sty` on
`TEXINPUTS` (the verifier builds it in `docker/tex/Dockerfile`).
