# P2 · Re-certifying the live Viridis OS decision kernels

Seventeen decision kernels are live on viridisconservation.com. Their formal cores were checked by tools that can no
longer be re-run: the retired Lean certifier droplet (the Comparator), historical Aristotle runs, and the old canon gate.
P2 brings each kernel to this engine's standard. Each kernel's formal core is sealed as a statement, by Justin's decision,
and re-proved under the pinned toolchain (Lean v4.28.0, Mathlib 8f9d9cff), with a kernel replay.

A PROVEN label here certifies the mathematics a kernel applies. It never certifies the field coefficients or the
ecological outcome. Those stay ASSUMED until the TESTED lane or a human review covers them.

Order (by business value): Carbon Continuity, Restoration, Afforestation, Harmonization, then the remaining
thirteen.

Sources: the archived canon at github.com/jdhart81/viridis-canon, commit 80d32904d751b45f415e23f872510cc2eddca3ff. The
files are copied into context/, with hashes in context/SOURCES.sha256.
