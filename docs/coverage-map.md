# Coverage map

Where every research topic stands, how deep it has gone, and what is missing. This file is data
for people and agents planning the queue; it changes nothing the verifier does, and it certifies
nothing. The labels in `index/certified.json` and each run's `certification.json` are the record.

## Depth rungs

Every task in `projects/*/tasks.json` carries a `rung`, one of four, in order:

| Rung | Means | Example |
|---|---|---|
| `known` | A classical or already-published result, stated precisely and machine-checked. Assurance for a kernel, not novelty. | P6.MinimalNetwork (trees are the minimal connected networks) |
| `extension` | Goes beyond the project's known statements: joins two of them, adds a case, or applies one to a new question. | P6.CorridorPersistence (corridor losses and the persistence threshold) |
| `open` | A question whose answer is not known to us in the literature. | none queued yet |
| `field` | A claim tested against real data under a registered plan, re-executed by the verifier. | P4-T001 (the P1C real-fire replication) |

A rung describes the ambition of a task, not its result. A `known` task can still fail, and an
`open` task can come back TRIVIAL. The engine's companion change (fair rotation and repeat gates,
viridis-engine) reads the rungs: a new proposal must climb above its project's highest finished
rung, and P2, which is in `maintenance` mode, is exempt.

## Where each topic stands

State of the record on 2026-11-27 (main at dc4deec plus this change). "Highest finished rung" is
the highest rung among the project's completed tasks; "next rung queued" is the lowest rung among
its tasks that are not done.

| Project | Domain | Feeds | Mode | Rungs in queue | Highest finished rung | Next rung queued | Tasks done | Eligible now |
|---|---|---|---|---|---|---|---|---|
| P1 | Fire and landscape topology | Trees Cannot Cut | research | known, extension | extension | known | 4/5 | 0 |
| P2 | Decision kernels (upkeep) | Viridis OS kernels | maintenance | known | known | known | 8/15 | 4 |
| P3 | Circular economy | Byproduct Exchange, circular kernels | research | known | known | nothing queued | 5/5 | 0 |
| P4 | Wildfire (field data) | Trees Cannot Cut | research | field | field | nothing queued | 1/1 | 0 |
| P5 | Intelligence Bound audit | Canon corrections | research | known | known | nothing queued | 3/3 | 0 |
| P6 | Habitat networks | HDFM | research | known, extension | known | extension | 4/6 | 1 |
| P7 | Persistence thresholds | HDFM, restoration | research | known | known | known | 1/3 | 2 |
| P8 | Agroforestry | Agroforestry Designer | research | known | none | known | 0/3 | 1 |
| P9 | Soil carbon | GSIP | research | known, extension | none | known | 0/5 | 1 |
| P10 | Carbon accounting | Viridis GHG Ledger | research | known, extension | none | known | 0/5 | 1 |
| P11 | Catchment water | (none yet) | research | known, extension | none | known | 0/5 | 1 |
| P12 | Forest carbon and nitrogen | Solar Wing | research | known, extension | none | known | 0/5 | 1 |

Notes on the table:

- P1's only open task, P1-T001N, is a fallback that runs only if P1-T001 stalls. P1-T001 is done,
  so P1 has no live work.
- P2 is maintenance: it re-certifies kernels that are already live and stays on the known rung.
- P3, P4 and P5 have no queued work. Each needs its next rung written before it can run again.
- P9 to P12 are new. Each has two known-rung statements to propose and prove, and an extension
  proposal queued behind them.

## What is missing

- **The open rung is empty.** No project has an `open` task. The first candidates are where two
  projects meet: P6 with P7 (does a corridor network change the persistence threshold through
  anything but the colonisation rate?), P9 with P10 (permanence accounting under reversal risk), and
  P11 with P12 (forest cover, the Budyko parameter and nitrogen together).
- **The field rung has one project.** Only P4 tests a claim against real data. P9 (measured soil
  cores), P11 (gauged catchments) and P12 (fertilisation trials) each need a registered plan and
  public data before a field task can be queued.
- **P3, P4 and P5 have no next rung.** P3 needs an extension of the circular-economy kernel, P4 a
  new pre-registration (the 2026-11-20 note lists the fire data it needs), and P5 a decision on
  whether the audit is finished.
- **Domains with no project:** biodiversity monitoring (acoustic and camera-trap detection),
  invasive species, and grassland and wetland carbon.
- **Zenodo for P9 to P12.** No approval requests or record notes were added for the new projects,
  to avoid decision IDs colliding with the nightly's. Until approved, their runs publish on GitHub
  only.
