# P3 · Circular-economy kernel: loops, cascades and industrial symbiosis

P3 builds the formal core for a Viridis OS circular-economy kernel. Today the canon proves only one
circular-economy result: the two-partner Reciprocity Corridor (Run-128, doi:10.5281/zenodo.21971047),
which backs the `byproduct-exchange` preview module. P3 adds the mass-balance and cascade accounting a
recycling kernel needs, a recovery-adjusted work floor built on the Useful and Dissipated Work Ledger
(Run-163, doi:10.5281/zenodo.22736716), and the N-partner generalisation of the corridor.

Planned statements (drafted by P3-T001, sealed only by Justin's decision on issue #1):

1. **P3.LoopMassBalance.** Virgin input V = D(1 − r). The secondary stock S(t+1) = ρS(t) + rD
   converges to rD/(1 − ρ). Cumulative virgin input T·D·(1 − r) strictly falls as r rises.
2. **P3.CascadedRecovery.** After n stages the virgin share is ∏(1 − rᵢ). It is at least
   (1 − max rᵢ)ⁿ and no larger than any single stage's share.
3. **P3.RecoveryWorkFloor.** Fresh supply ≥ (T − e_max·w_r)/e_max when useful work must reach T.
4. **P3.CyclicSymbiosis.** A strictly beneficial flow around an N-partner cycle exists if and only if
   ∏cᵢ < ∏vᵢ. For N = 2 this is the Reciprocity Corridor's product condition.

A PROVEN label here certifies the mathematics of the model. It never certifies a recovery rate, a
cost, a material's value or an environmental outcome. Those stay ASSUMED until field evidence or a
human review covers them. Statement 3 is a bound on modeled efficiency. It is not a Landauer bound,
and it does not rely on the Intelligence Bound, which remains a conjecture.

P3 has priority 3, so it runs only on nights when P1 and P2 have no eligible task.

Sources: the canon at github.com/jdhart81/viridis-canon, commit
17a0702fca0850fd1650a83de8ab160b6901b4f4. `series/RC/PaperFormalization.lean` is copied as
`context/ReciprocityCorridor.lean` and `series/UDWL/ViridisRun163.lean` as
`context/UsefulDissipatedWork.lean`, with hashes in `context/SOURCES.sha256`.
