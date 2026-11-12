# P2 · Re-certifying the live Viridis OS decision kernels

Seventeen decision kernels are live on viridisconservation.com. Their formal cores were checked by tools that can no
longer be re-run: the retired Lean certifier droplet (the Comparator), historical Aristotle runs, and the old canon gate.
P2 brings each kernel to this engine's standard. Each kernel's formal core is sealed as a statement, by Justin's decision,
and re-proved under the pinned toolchain (Lean v4.28.0, Mathlib 8f9d9cff), with a kernel replay.

A PROVEN label here certifies the mathematics a kernel applies. It never certifies the field coefficients or the
ecological outcome. Those stay ASSUMED until the TESTED lane or a human review covers them.

Order (by business value): Carbon Continuity, Restoration, Afforestation, Harmonization, then the remaining
thirteen.

## Second wave (added 2026-11-12)

Five more admitted kernels: Decision-information capacity, Multi-ring alignment capacity, Symbiotic surplus,
Ecological-thermodynamic allocation, and the Inverse-square shadow-price planner. A replay on 2026-11-11 compiled their
canon sources unchanged and found only the three standard axioms under every referenced theorem (27 references).
That replay used cached Mathlib builds and is a measurement; it certifies nothing here. Each kernel still needs a sealed
statement and a proof checked by this engine.

Two of these kernels state capacity bounds from the Intelligence Bound family. Their theorems are conditional: the
Landauer limit enters as a hypothesis (`SatisfiesLandauerLimit`) or as a definition of the bound, and is not proved.
Sealed statements must keep that visible. See project P5 for why an unconditional reading is wrong.

## Tempo (added 2026-11-12)

Tempo, the stewardship-cadence kernel, is in the OS core list. Its registry entry names six theorems in a Lean module
`StewardshipTempo` and lists no source file; the only evidence on record is a receipt from the retired Comparator. A
replay of the canon on 2026-11-11 found no source for it. There is nothing to port, so P2 rebuilds its formal core from
what the kernel computes: `context/Tempo_function.json` and `context/Tempo_runner.py`, copied from viridis-canon at
commit 6a177d6b1a779f38c9215bd618f17f9be29cc253.

Sources: the archived canon at github.com/jdhart81/viridis-canon, commit 80d32904d751b45f415e23f872510cc2eddca3ff. The
files are copied into context/, with hashes in context/SOURCES.sha256.
