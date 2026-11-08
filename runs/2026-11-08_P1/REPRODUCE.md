# Reproduce `runs/2026-11-08_P1`

Run date 2026-11-08. Verified by engine version `98153355c710`; the verifier kit in this repository
(`engine/lean_check.py`, `engine/reproduce.py`) re-runs every check.

## Everything at once

```bash
git clone https://github.com/jdhart81/viridis-research && cd viridis-research
# Lean toolchain and the Mathlib cache (pins in lean/lean-toolchain and lean/lake-manifest.json)
curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none
(cd lean && lake exe cache get)
python3 -m engine.reproduce runs/2026-11-08_P1
```

`engine.reproduce` checks `MANIFEST.sha256`, re-runs every Lean check below, and reports the result
for each claim. Add `--docker` to run the checks in the same sandbox the verifier uses.

## Lean checks

- Toolchain `leanprover/lean4:v4.28.0`, Mathlib `8f9d9cff6bd728b17a24e163c9402775d9e6a365`.
- `lean/` in this folder holds each sealed statement module, the candidate proof, and the check file
  the verifier generated (`ViridisCheck.lean`), which asserts the statement match and prints the axioms.

### C1: `P1.Insertion` (ASSUMED)

- Statement: `lean/P1.Insertion/Statement.lean` (sha256 `800bd9b9fec5033192b40a9d02dae8abf5c15195b3e2b6f2a1c438a7ab08c734`)
- Candidate: `proofs/P1.Insertion.lean` (sha256 `12bbdc63e632b9e046317a2740a5b0630b55b01ed02329b7ab62a2c183cd52a9`)
- Verifier result: stage `source`, axioms `n/a`

## Paper

`paper.pdf` is the verifier's certification page followed by the compiled paper. To rebuild the paper,
run `latexmk -pdf -no-shell-escape main.tex` in `paper/`, with `docker/tex/viridis-lean.sty` on
`TEXINPUTS` (the verifier builds it in `docker/tex/Dockerfile`).
