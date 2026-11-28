# P9 · Soil carbon: turnover, steady state and the equivalent-soil-mass correction

P9 builds the formal core for the soil-carbon accounting used by the Global Soil Intelligence
Platform (GSIP). It answers two questions a soil-carbon claim has to get right: where a soil's
carbon stock is heading under a steady practice, and whether a measured gain is real or an artefact
of comparing a fixed depth in soil whose density has changed.

Planned statements (drafted by P9-T001, sealed under the standing sealing policy, D-018):

1. **P9.SoilTurnover.** In the yearly one-pool model C' = C + I − k·C, with input I ≥ 0 and turnover
   rate 0 < k ≤ 1, the stock I/k is the steady state, the distance to it shrinks by the factor
   1 − k every year, a stock below it rises towards it without overshooting, and the steady state
   rises with input and falls with the turnover rate.
2. **P9.EquivalentSoilMass.** For a uniform profile of depth d, a comparison at fixed depth after
   bulk density rises from ρ0 to ρ1 overstates the stock change, relative to a comparison of the same
   soil mass, by exactly c1·d·(ρ1 − ρ0): positive when the soil was compacted, zero when density is
   unchanged.

Both are classical (Jenny 1941; Olson 1963; Ellert and Bettany 1995), not new theorems. They are
the known rung of this project. The queued extension (P9-T004) asks how much of a practice-driven
gain remains after the practice ends, the question behind permanence of a soil-carbon credit.

A PROVEN label here certifies the arithmetic of the models. It never certifies a turnover rate, an
input, a measured stock, a permanence period or any credit. A single pool with constant input and
rate is an assumption; real soils have several pools and changing inputs. The equivalent-soil-mass
statement assumes a uniform profile and does not correct any measured core.

## Tasks

- **P9-T001** (known) proposes the two statements, exactly as specified in `context/STATEMENT_PROPOSAL.md`.
- **P9-T002** (known) proves `P9.SoilTurnover`.
- **P9-T003** (known) proves `P9.EquivalentSoilMass`.
- **P9-T004** (extension) proposes `P9.Reversal`, as specified in `context/EXTENSION.md`.
- **P9-T005** (extension) proves it.
