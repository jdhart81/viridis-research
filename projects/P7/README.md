# P7 · Persistence thresholds: how much habitat a population and a biota need

P7 builds the formal core for a habitat-loss kernel from two textbook models: the Levins
metapopulation model with habitat loss, and the power-law species–area relationship. Both give a
planner a threshold or a bound instead of a forecast.

Planned statements (drafted by P7-T001, sealed only by Justin's decision on issue #1):

1. **P7.HabitatThreshold.** In the model dp/dt = c·p·(h − p) − e·p, with colonisation rate c > 0,
   extinction rate e > 0 and suitable habitat fraction h, the growth term is negative for every
   occupancy when h ≤ e/c, and when h > e/c there is exactly one positive equilibrium
   p* = h − e/c, towards which the growth term points from both sides. Starting from intact
   habitat, the population persists exactly while the destroyed fraction is smaller than the
   occupancy it had when intact. The threshold e/c falls when c rises and rises with e.
2. **P7.SpeciesArea.** If species number follows S = k·A^z with 0 < z ≤ 1, keeping a fraction a of
   the area keeps the fraction a^z of the species. That fraction is at least a, strictly more when
   0 < a < 1 and z < 1, and keeping a fraction s of the species needs the area fraction s^(1/z),
   which is at most s.

These are classical results (Levins 1969; Lande 1987; Nee and May 1992; Arrhenius 1921), not new
theorems. P7 states them about the sign of the growth term, not about solutions of the differential
equation.

A PROVEN label here certifies the algebra of the two models. It never certifies that a real species
follows the Levins model, any value of c, e, h or z, or any extinction forecast. The species–area
form is an empirical regularity that P7 assumes, and it ignores extinction debt, which species are
lost and where the remaining habitat lies. Statement 1 is where connectivity enters: a corridor
network (project P6) matters to this model only through the colonisation rate c, and P7 does not
claim how any network changes c.

## Tasks

- **P7-T001** proposes the two statements, exactly as specified in `context/STATEMENT_PROPOSAL.md`.
- **P7-T002** proves `P7.HabitatThreshold`.
- **P7-T003** proves `P7.SpeciesArea`.
