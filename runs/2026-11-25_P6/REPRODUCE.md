# Reproduce `runs/2026-11-25_P6`

Run date 2026-11-25. Verified by engine version `01d0c45a73fb`; the verifier kit in this repository
(`engine/lean_check.py`, `engine/reproduce.py`) re-runs every check.

## Everything at once

```bash
git clone https://github.com/jdhart81/viridis-research && cd viridis-research
# the commit that added this run, so Lean and Mathlib are the ones it was verified with
git checkout "$(git log --diff-filter=A --format=%H -1 -- runs/2026-11-25_P6/MANIFEST.sha256)"
# Lean toolchain and the Mathlib cache (pins in lean/lean-toolchain and lean/lake-manifest.json)
curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none
(cd lean && lake exe cache get)
python3 -m engine.reproduce runs/2026-11-25_P6
```

`engine.reproduce` checks `MANIFEST.sha256`, re-runs every Lean check below, and reports the result
for each claim. Add `--docker` to run the checks in the same sandbox the verifier uses.

## Lean checks

- Toolchain `leanprover/lean4:v4.28.0`, Mathlib `8f9d9cff6bd728b17a24e163c9402775d9e6a365`.
- `lean/` in this folder holds each sealed statement module, the candidate proof, and the check file
  the verifier generated (`ViridisCheck.lean`), which asserts the statement match and prints the axioms.

### C1: `P6.SingleFailureRobust` (PROVEN)

- Statement: `lean/P6.SingleFailureRobust/Statement.lean` (sha256 `f7c925574028357c3a83fa7e362b3bc76effd0c355f54bcd57c298bf8bd82c81`)
- Candidate: `proofs/P6.SingleFailureRobust.lean` (sha256 `4ffe72496f95787324cae2be8112af875fccd9a610f20e56ff88f6fd40c185f3`)
- Verifier result: stage `passed`, axioms `Classical.choice, Quot.sound, propext`

## Paper

`paper.pdf` is the verifier's certification page followed by the compiled paper. To rebuild the paper,
run `latexmk -pdf -no-shell-escape main.tex` in `paper/`, with `docker/tex/viridis-lean.sty` on
`TEXINPUTS` (the verifier builds it in `docker/tex/Dockerfile`).
