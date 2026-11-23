# Certification

Labels are assigned only by `engine/labels.py`, which runs in the verify job.
The agent can claim whatever it likes, but only the verifier's labels appear
on the certification page and in the outcome.

- **ASSUMED** is the default for every claim.
- **PROVEN** requires all five Lean stages to pass against a sealed statement
  (see ARCHITECTURE.md). The certification page reprints the sealed statement,
  its hash, the decision that sealed it, and the axioms the proof uses.
- **TRIVIAL** is a flag on PROVEN. It is set when any probe tactic closes the
  sealed statement on its own; the probe tactics are listed in
  `config/engine.json`. A TRIVIAL result is never announced.
- **TESTED** means the verifier re-executed the claim's analysis script in the
  sandbox on the inputs pinned in `data_pins.json` and reproduced the cited
  result files (see "TESTED" below). It is off until the record's
  `config/engine.json` sets `tested.enabled` to `true`; until then, and for any
  claim without a `reproduce` entry, empirical claims stay ASSUMED.
- **REPLICATED** will mean TESTED on independent data or by an independent
  implementation in a later run.
- **ENDORSED** and **ADOPTED** come from people, through a recorded decision
  (effect `endorse`).

## TESTED: verifier re-execution (`engine/reexec.py`)

An empirical claim asks for re-execution with `"reproduce": {"entry": "code/<script>.py"}`.

| ID | Rule | Checked by (`tests/test_reexec.py`, `tests/test_verify_e2e.py`) |
|---|---|---|
| T1 | Off by default. Without `tested.enabled: true` nothing is run and labels are as before. | `test_off_by_default_changes_nothing`, `test_reexecution_is_off_unless_the_record_enables_it` |
| T2 | Re-execution only. The script runs in the I5 sandbox (no network, read-only root, non-root user, all capabilities dropped, memory, CPU, process and time limits) from a clean copy of `code/` and `data/`, with an empty `results/`. It never sees the results the agent submitted. | `test_real_sandbox_has_no_network_and_read_only_inputs`, `test_script_cannot_reach_the_claimed_results_or_smuggle_links` |
| T3 | Reproduction. Every JSON, CSV or TSV result file in the claim's `evidence` must come back equal: byte for byte, or number by number within `rel_tol` 1e-6 and `abs_tol` 1e-9. Structure, text and booleans must be identical. At least one such file is required. | `test_fabricated_result_stays_assumed`, `test_numeric_tolerance`, `test_compare_is_strict_about_structure_and_non_numbers` |
| T4 | Pinned inputs. Every file under `data/` is listed in `data_pins.json` with its SHA-256 and an https source URL, the hashes match, and nothing else is listed. | `test_unpinned_or_altered_inputs_stay_assumed` |
| T5 | Trusted judge. The image (`docker/py/Dockerfile`: base pinned by digest, every Python package pinned by version and hash in `docker/py/requirements.txt`) and the comparison come from main. Output files are read without following links and with a size limit. | `test_oversized_and_special_outputs_are_refused` |
| T6 | Never fails the night. Any problem, including a verifier fault, leaves the claim ASSUMED with the reason. | `test_verifier_faults_never_raise`, `test_unreproduced_empirical_claim_is_assumed_and_the_night_still_merges` |
| T7 | Bounded. At most `max_claims` (3) claims per run, each within `timeout_seconds` (600). | `test_max_claims`, `test_failing_and_slow_scripts_stay_assumed` |
| T8 | Recorded. `certification.json` (`reexecution`) holds the script, image, input pins, both hashes of every compared file and the verdicts; the run folder keeps `code/`, `data/` and `results/`. | `test_reproduced_empirical_claim_is_tested` |

**What TESTED does not mean.** It certifies that the stated computation gives the
stated numbers from the pinned files. It does not certify that the files are what
their URLs say, that the data were collected well, that the analysis is the right
one, or that the conclusion follows. A pre-registered analysis plan, fixed before
the data are seen, is what makes a TESTED result evidence; the engine does not
yet enforce pre-registration. Input files are committed to the public record, so
only data that may be redistributed belongs in `data/`.

## Epistemic status: two tracks beside the label (`engine/epistemic.py`, I24)

Lean can show that a theorem follows from its stated hypotheses. It cannot show that those
hypotheses describe nature. So every claim also carries two tracks, set independently by the
verifier, and one status derived from them. The label above is never changed by this.

| Kind | Track value | Status | Requires |
|---|---|---|---|
| conjecture | n/a | `CONJECTURED` | nothing |
| formal | `UNPROVED` | `UNRESOLVED` | the label is not PROVEN |
| formal | `PROVED_CONDITIONAL` | `CONDITIONALLY_PROVED` | PROVEN, and the statement's premises are listed, or were never reviewed (`UNCLASSIFIED`) |
| formal | `PROVED` | `FORMALLY_PROVED` | PROVEN, and the reviewed premise list is empty |
| empirical | `UNTESTED` | `UNRESOLVED` | the label is not TESTED |
| empirical | `REPRODUCED` | `UNRESOLVED` | TESTED, with no valid registered plan |
| empirical | `INCONCLUSIVE` | `UNRESOLVED` | TESTED under a registered plan whose verdict is NOT_SUPPORTED or NOT_ESTIMABLE |
| empirical | `SUPPORTED` | `EMPIRICALLY_SUPPORTED` | TESTED under a registered plan whose verdict is SUPPORTED |
| empirical | `CONTRADICTED` | `EXPERIMENTALLY_FALSIFIED` | TESTED under a registered plan whose verdict is CONTRADICTED |

| ID | Rule | Checked by (`tests/test_epistemic.py`) |
|---|---|---|
| E1 | Additive. A label entry only gains the key `epistemic`; the index only gains the key `epistemic`. | `test_formal_claims_are_annotated_without_touching_the_label`, `test_an_old_record_gains_only_the_new_key` |
| E2 | Independent tracks. A proof never raises the empirical track and a test never raises the formal one. | `test_status_table_is_total_and_tracks_do_not_cross` |
| E3 | The status is a pure function of kind and the two tracks (the table above). | `test_status_table_is_total_and_tracks_do_not_cross` |
| E4 | Unconditional needs a review: `statements/premises.json` must hold an entry bound to the sealed hash with an empty `premises` list. | `test_unconditional_needs_an_empty_reviewed_premise_list` |
| E5 | A verdict needs a plan fixed in advance (below). Any break in the chain leaves the claim REPRODUCED. | `test_a_registered_plan_gives_its_verdict`, `test_every_break_in_the_chain_falls_back_to_reproduced`, `test_a_fabricated_verdict_is_not_tested_so_it_is_untested` |
| E6 | Caution on error: the weaker value with the reason; nothing raises and nothing fails a night. | `test_annotate_never_raises` |
| E7 | The agent cannot write the premise review or a plan: both are outside the artifact and outside `gitio.WRITE_ROOTS`. | `test_the_agent_cannot_write_premises_or_plans` |
| E8 | A premise can point at the empirical claims that test it; the index attaches each one's track and flags a contradicted premise. | `test_index_reports_both_tracks_and_links_premises_to_tests`, `test_index_reports_bad_premise_pointers_and_unknown_statements` |
| E9 | One plan, one verdict: the earliest merged run under a plan holds its verdict of record; later runs under it stay REPRODUCED. | `test_one_plan_gives_one_verdict`, `test_index_drops_a_verdict_whose_plan_changed_or_left` |

**The premise review** (`statements/premises.json`, schema `viridis-premises-v1`, changed only by a pull
request Justin merges). One entry per sealed statement:

```json
{"schema": "viridis-premises-v1", "statements": {
  "P1.BitQuad": {"sha256": "<sealed hash>", "premises": []},
  "P0.Bound":   {"sha256": "<sealed hash>", "premises": [
    {"id": "PL", "kind": "physical", "text": "Each erased bit dissipates at least kT ln 2 in this system.",
     "tested_by": [{"run_dir": "runs/2027-01-10_P9", "claim_id": "C1"}]}]}}}
```

A premise is a hypothesis of the theorem that says something about the world (`physical`, `empirical`)
or about how well a model fits it (`modelling`). An empty list says the statement is pure mathematics.
No entry means nobody has looked, and the proof is reported as conditional.

**A registered plan** (`preregistrations/registry.json`, schema `viridis-preregistrations-v1`, and the
plan text at `preregistrations/<PLAN-ID>.md`, both changed only by a pull request Justin merges):

```json
{"schema": "viridis-preregistrations-v1", "plans": {
  "P4-Recovery": {"path": "preregistrations/P4-Recovery.md", "sha256": "<hash of the plan text>",
    "project": "P4", "registered_at": "2026-11-20", "hypothesis": "Burned plots recover more than controls.",
    "entry": "code/effect.py", "code": {"code/effect.py": "<hash>"}, "data": {"data/predictors.csv": "<hash>"},
    "verdict_file": "results/verdict.json", "verdict_key": "verdict"}}}
```

The claim names it with `"preregistration": "P4-Recovery"`. The verifier gives the plan's verdict only if
the claim is TESTED, the plan text has the registered hash, the plan is for the run's project and was
registered on an earlier date, the run's `code/` tree is exactly the frozen file set, every frozen input
is present with its hash, the entry script is the plan's, and the verdict file was reproduced and holds
`SUPPORTED`, `CONTRADICTED`, `NOT_SUPPORTED` or `NOT_ESTIMABLE` under the verdict key. The frozen code
reaches the agent as task context files, to be copied into `out/code/` unchanged.

**What these statuses do not mean.** `FORMALLY_PROVED` says the reviewed premise list is empty; it says
nothing about novelty or importance. `EMPIRICALLY_SUPPORTED` says a plan registered in advance returned
SUPPORTED on re-executed, pinned data. The engine cannot see whether the outcome data were unseen when the
plan was registered (Justin attests that by merging the plan), where the data came from, or whether the
effect is causal. `EXPERIMENTALLY_FALSIFIED` is the registered plan's CONTRADICTED verdict, which for an
observational study is evidence against the hypothesis, not a controlled experiment. REPLICATED remains
not enabled.

## What PROVEN does not mean

PROVEN does not mean that the paper's prose is correct, that the result is
new, or that the sealed definitions capture the intended mathematics. The last
point is why the statement is reprinted in full on the certification page, and
why `index/certified.json` says who sealed it. `sealed_by: owner` means Justin
reviewed and approved that statement himself. `sealed_by: policy` means it was
sealed under a standing policy he switched on by a recorded decision: the
verifier compiled it, none of the probe tactics closed it, and its task had
named it in advance. That policy does not check that the definitions capture
the intended mathematics; read the statement. The trusted base is
the Lean kernel, `leanchecker`, the pinned Mathlib, and this repository's
verifier code.

## References

Every DOI in the bibliography is resolved through the DOI handle API. Any DOI
that is unresolved or could not be checked is listed on the certification page.
A run with an unresolved DOI is never announced.
