# Reproduce `runs/2026-11-15_P3`

Run date 2026-11-15. Verified by engine version `29d372b669ac`; the verifier kit in this repository
(`engine/lean_check.py`, `engine/reproduce.py`) re-runs every check.

## Everything at once

```bash
git clone https://github.com/jdhart81/viridis-research && cd viridis-research
# the commit that added this run, so Lean and Mathlib are the ones it was verified with
git checkout "$(git log --diff-filter=A --format=%H -1 -- runs/2026-11-15_P3/MANIFEST.sha256)"
# Lean toolchain and the Mathlib cache (pins in lean/lean-toolchain and lean/lake-manifest.json)
curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none
(cd lean && lake exe cache get)
python3 -m engine.reproduce runs/2026-11-15_P3
```

`engine.reproduce` checks `MANIFEST.sha256`, re-runs every Lean check below, and reports the result
for each claim. Add `--docker` to run the checks in the same sandbox the verifier uses.

## Lean checks

- Toolchain `leanprover/lean4:v4.28.0`, Mathlib `8f9d9cff6bd728b17a24e163c9402775d9e6a365`.
- `lean/` in this folder holds each sealed statement module, the candidate proof, and the check file
  the verifier generated (`ViridisCheck.lean`), which asserts the statement match and prints the axioms.

### C1: `P3.LoopMassBalance` (PROVEN)

- Statement: `lean/P3.LoopMassBalance/Statement.lean` (sha256 `f00634594133f7edfb49f21bf30203d259cc8dfa7e62a40326bff1da1ea31ac7`)
- Candidate: `proofs/P3.LoopMassBalance.lean` (sha256 `0e110da9753e71462f1f2613eef5f7aa9e7fd1c6d8b368034fcc5210283a69b3`)
- Verifier result: stage `passed`, axioms `Classical.choice, Quot.sound, propext`

## Paper

`paper.pdf` is the verifier's certification page followed by the compiled paper. To rebuild the paper,
run `latexmk -pdf -no-shell-escape main.tex` in `paper/`, with `docker/tex/viridis-lean.sty` on
`TEXINPUTS` (the verifier builds it in `docker/tex/Dockerfile`).
