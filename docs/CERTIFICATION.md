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
