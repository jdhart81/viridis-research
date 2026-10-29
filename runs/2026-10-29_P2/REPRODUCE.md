# Reproduce `runs/2026-10-29_P2`

Run date 2026-10-29. Verified by engine version `b6b87d8bd2c0`; the verifier kit in this repository
(`engine/lean_check.py`, `engine/reproduce.py`) re-runs every check.

## Everything at once

```bash
git clone https://github.com/jdhart81/viridis-research && cd viridis-research
# Lean toolchain and the Mathlib cache (pins in lean/lean-toolchain and lean/lake-manifest.json)
curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none
(cd lean && lake exe cache get)
python3 -m engine.reproduce runs/2026-10-29_P2
```

`engine.reproduce` checks `MANIFEST.sha256`, re-runs every Lean check below, and reports the result
for each claim. Add `--docker` to run the checks in the same sandbox the verifier uses.

## Lean checks

- Toolchain `leanprover/lean4:v4.28.0`, Mathlib `8f9d9cff6bd728b17a24e163c9402775d9e6a365`.
- `lean/` in this folder holds each sealed statement module, the candidate proof, and the check file
  the verifier generated (`ViridisCheck.lean`), which asserts the statement match and prints the axioms.

### C1: `P2.CarbonContinuity` (PROVEN)

- Statement: `lean/P2.CarbonContinuity/Statement.lean` (sha256 `a5a6e8c63205b865da0df0c302f1926b48d1874ce1310053da6c1ae3104ffded`)
- Candidate: `proofs/P2.CarbonContinuity.lean` (sha256 `bfced37f622d1ab9921f2fe7bf02ffa7c88dbdeb1e53d3a250df0ff8f0f94f44`)
- Verifier result: stage `passed`, axioms `Classical.choice, Quot.sound, propext`

## Paper

`paper.pdf` is the verifier's certification page followed by the compiled paper. To rebuild the paper,
run `latexmk -pdf -no-shell-escape main.tex` in `paper/`, with `docker/tex/viridis-lean.sty` on
`TEXINPUTS` (the verifier builds it in `docker/tex/Dockerfile`).
