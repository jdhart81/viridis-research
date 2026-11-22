# P8 · Agroforestry accounting: land equivalent ratio and the shared light budget

P8 builds the formal core for two calculations used to judge a mixed tree–crop system against
separate plots: how much land the mixture saves, and how light is shared between a tree layer and
the crop beneath it.

Planned statements (drafted by P8-T001, sealed only by Justin's decision on issue #1):

1. **P8.LandEquivalentRatio.** With sole-crop yields Mᵢ > 0 and mixture yields Yᵢ ≥ 0 per unit
   area, LER = Σ Yᵢ/Mᵢ is exactly the least sole-crop area that matches one unit area of the
   mixture. A mosaic of sole crops with no interaction has LER = 1. When LER > 1 the mixture saves
   the land fraction 1 − 1/LER. If no component out-yields its sole crop, LER is at most the number
   of components.
2. **P8.LightBudget.** For a tree layer above a crop layer with Beer–Lambert interception, the
   layers together intercept 1 − exp(−(k_t·L_t + k_c·L_c)); the crop under trees intercepts
   exactly the fraction exp(−k_t·L_t) of what it would alone; adding tree leaf area never lowers
   the total and never raises the crop's share.

These are standard definitions and identities (Mead and Willey 1980 for LER; Monsi and Saeki 1953
for canopy light), not new theorems.

A PROVEN label here certifies the accounting. It never certifies a yield, an extinction
coefficient, a leaf area or that a real stand behaves as two uniform layers: alley and row systems
are not horizontally uniform, and LER says nothing about value, labour, risk or which component a
grower wants. Those stay ASSUMED until field evidence or a human review covers them.

P8 is separate from the Agroforestry Designer assurance proposal (intake AGRO-ASSURANCE-001), which
concerns that software's own step functions and still waits for a routing decision. P8 uses none of
its material. It complements `P2.Afforestation`: P2 covers tree establishment and carbon, P8 covers
what the mixture gives up or gains in land and light.

## Tasks

- **P8-T001** proposes the two statements, exactly as specified in `context/STATEMENT_PROPOSAL.md`.
- **P8-T002** proves `P8.LandEquivalentRatio`.
- **P8-T003** proves `P8.LightBudget`.
