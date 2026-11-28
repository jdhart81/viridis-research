# P12 · Forest carbon and nitrogen: the stoichiometric ceiling on carbon gain

P12 builds the formal core for the carbon-nitrogen accounting behind the Solar Wing study of
nitrogen delivery to forests. Before anyone asks whether delivering nitrogen to a stand adds
carbon, the books have to say how much carbon a unit of nitrogen can carry, when added nitrogen
helps, and when it gives nothing because something else limits growth.

Planned statements (drafted by P12-T001, sealed under the standing sealing policy, D-018):

1. **P12.StoichiometricCeiling.** If new biomass has a fixed carbon-to-nitrogen ratio r > 0, the
   carbon gain from available nitrogen N with carbon potential Cpot is G = min(Cpot, r·N). It never
   exceeds r·N or Cpot; adding nitrogen d raises it by at most r·d; while growth is nitrogen-limited
   it rises by exactly r·d; and once the carbon potential binds, added nitrogen gives nothing.
2. **P12.PoolStoichiometry.** Carbon held in pools with nitrogen N_i ≥ 0 and C:N ratios at most
   r_max is at most r_max times the total nitrogen, and moving nitrogen δ from a pool of ratio r_lo
   to one of ratio r_hi changes the carbon held by exactly (r_hi − r_lo)·δ.

These are stoichiometric bookkeeping (Liebig's law of the minimum; the progressive nitrogen
limitation literature), not new theorems. They are the known rung of this project. The queued
extension (P12-T004) states when delivered nitrogen gives a positive net carbon benefit once the
emissions of delivering it are counted, which is where P12 meets the carbon accounting of P10.

A PROVEN label here certifies the arithmetic of the model. It never certifies a C:N ratio, a
retention fraction, a carbon potential, any delivery, any aircraft or any carbon outcome. A fixed
ratio and a sharp minimum are assumptions; real stands adjust their ratios and respond to several
limits at once.

## Tasks

- **P12-T001** (known) proposes the two statements, exactly as specified in `context/STATEMENT_PROPOSAL.md`.
- **P12-T002** (known) proves `P12.StoichiometricCeiling`.
- **P12-T003** (known) proves `P12.PoolStoichiometry`.
- **P12-T004** (extension) proposes `P12.DeliveryNetBenefit`, as specified in `context/EXTENSION.md`.
- **P12-T005** (extension) proves it.
