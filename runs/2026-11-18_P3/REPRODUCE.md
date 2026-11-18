# Reproduce `runs/2026-11-18_P3`

Run date 2026-11-18. Verified by engine version `43867fe8791d`; the verifier kit in this repository
(`engine/lean_check.py`, `engine/reproduce.py`) re-runs every check.

## Everything at once

```bash
git clone https://github.com/jdhart81/viridis-research && cd viridis-research
# the commit that added this run, so Lean and Mathlib are the ones it was verified with
git checkout "$(git log --diff-filter=A --format=%H -1 -- runs/2026-11-18_P3/MANIFEST.sha256)"
# Lean toolchain and the Mathlib cache (pins in lean/lean-toolchain and lean/lake-manifest.json)
curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none
(cd lean && lake exe cache get)
python3 -m engine.reproduce runs/2026-11-18_P3
```

`engine.reproduce` checks `MANIFEST.sha256`, re-runs every Lean check below, and reports the result
for each claim. Add `--docker` to run the checks in the same sandbox the verifier uses.

## Lean checks

- Toolchain `leanprover/lean4:v4.28.0`, Mathlib `8f9d9cff6bd728b17a24e163c9402775d9e6a365`.
- `lean/` in this folder holds each sealed statement module, the candidate proof, and the check file
  the verifier generated (`ViridisCheck.lean`), which asserts the statement match and prints the axioms.

### C1: `P3.CyclicSymbiosis` (PROVEN)

- Statement: `lean/P3.CyclicSymbiosis/Statement.lean` (sha256 `a6825700fb4c21d12ba330c739d321dd105da3b21c394338cda11ef5a67667c4`)
- Candidate: `proofs/P3.CyclicSymbiosis.lean` (sha256 `1ca1065a18f2125164357eee756b3c48626dd7188a58baf22606466da8f57903`)
- Verifier result: stage `passed`, axioms `Classical.choice, Quot.sound, propext`

## Paper

`paper.pdf` is the verifier's certification page followed by the compiled paper. To rebuild the paper,
run `latexmk -pdf -no-shell-escape main.tex` in `paper/`, with `docker/tex/viridis-lean.sty` on
`TEXINPUTS` (the verifier builds it in `docker/tex/Dockerfile`).
