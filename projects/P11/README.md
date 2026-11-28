# P11 · Catchment water: the water balance and the Budyko bounds

P11 builds the formal core for a catchment water kernel: the books every hydrological estimate has
to balance, and the limits a long-term evaporation estimate cannot cross. It is the first engine
project on water, and it sits beside the forest projects because forest cover is one of the main
reasons catchments differ.

Planned statements (drafted by P11-T001, sealed under the standing sealing policy, D-018):

1. **P11.WaterBalance.** With storage S, precipitation P, evaporation E and runoff Q per period, the
   storage recursion S(n+1) = S(n) + P(n) − E(n) − Q(n) telescopes: the change in storage over any
   number of periods is the summed P − E − Q. When storage ends no lower than it started and
   evaporation is non-negative, total runoff is at most total precipitation.
2. **P11.BudykoFu.** Fu's form of the Budyko curve, F(φ, w) = 1 + φ − (1 + φ^w)^(1/w), for aridity
   index φ ≥ 0 and parameter w ≥ 1, never makes the evaporative fraction negative, never above the
   water supply (1) and never above the energy limit (φ); at w = 1 it is 0.

Both are classical (the catchment water balance; Budyko 1974; Fu 1981), not new theorems. They are
the known rung of this project. The queued extension (P11-T004) states how the evaporative fraction
moves with w and with φ, the step a forest-cover study needs before it can ask anything of the
field.

A PROVEN label here certifies the mathematics. It never certifies a measured or modelled water
balance term, a value of w or φ, or any effect of land cover on runoff. Fu's curve is an assumed
empirical form; how forest cover changes w is a field question P11 does not answer.

## Tasks

- **P11-T001** (known) proposes the two statements, exactly as specified in `context/STATEMENT_PROPOSAL.md`.
- **P11-T002** (known) proves `P11.WaterBalance`.
- **P11-T003** (known) proves `P11.BudykoFu`.
- **P11-T004** (extension) proposes `P11.BudykoMonotone`, as specified in `context/EXTENSION.md`.
- **P11-T005** (extension) proves it.
