# P4 · Real fires: re-executed tests of Trees Cannot Cut

*Trees Cannot Cut* (doi:10.5281/zenodo.21686446) says wildfires end where closed loops of holdable
features stop them. P1 works on the mathematics behind that claim. P4 brings the evidence from real
fires into this record.

That evidence already exists. In October 2026 the claim was tested on wildfire records in Washington
State, with the plan, code and inputs frozen and publicly registered before any fire size was
requested:

- **Pilot** (Okanogan, Methow and Chelan; 2,677 fires): supported for mapped barriers.
- **P1C, confirmatory replication** (northeast Washington; 11,314 fires; registered as
  [viridis-canon pull request 138](https://github.com/jdhart81/viridis-canon/pull/138)): **SUPPORTED,
  reading REPLICATED.** A compartment ten times larger went with final fires about 13% larger
  (β = 0.053, registered interval 0.023 to 0.084).

P4 does not repeat the study and does not change it. For each registered test, the engine's agent
re-runs the frozen script on the registered inputs, and the verifier then runs it again in its own
sandbox. If the verifier reproduces the reported numbers, the claim is labelled **TESTED**.

## What TESTED means here, and what it does not

TESTED certifies that the frozen, registered analysis gives the reported numbers from the registered
input files. It does not certify that barriers stop fires. The study is observational, and its own
pre-specified checks bound the result:

- without the 40 km regional terms the estimate is 0.033 and does not pass its stricter critical value;
- fires caused by lightning show no effect; the effect is in human-caused fires;
- counting recent burn scars as barriers shrinks the estimate to 0.020.

The input files are the registered ones: wildfire records from FPA FOD, and predictors derived from
TIGER, NHD, LANDFIRE and gridMET. The frozen script checks their hashes against the registration's
`FREEZE.json`. Nothing here checks them against the agencies' servers.

## Files

- `context/INPUTS.json`: every input file, its source URL at the registered commit and its SHA-256.
- `context/rerun_p1c.py`: the entry script. It runs the frozen `run_test.py` unchanged.
- `context/P1C_RESULTS.md`, `context/PREREGISTRATION_P1C_NEWA_v1.4.md`, `context/ADDENDUM_v1.4.md`:
  the published report, plan and addendum, copied from the registration.
- `context/SOURCES.sha256`: hashes of the context files.

Authorship: Justin D. Hart (Viridis LLC) is the accountable author. Claude (Anthropic) designed the
analysis and wrote and ran the code under his direction. Automated tools are not research authors.
