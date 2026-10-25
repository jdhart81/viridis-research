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
- **TESTED** will mean the verifier re-executed `code/` in the sandbox on the
  inputs pinned in `data_pins.json` and reproduced the recorded result hashes.
  Until that path is enabled, empirical claims stay ASSUMED.
- **REPLICATED** will mean TESTED on independent data or by an independent
  implementation in a later run.
- **ENDORSED** and **ADOPTED** come from people, through a recorded decision
  (effect `endorse`).

## What PROVEN does not mean

PROVEN does not mean that the paper's prose is correct, that the result is
new, or that the sealed definitions capture the intended mathematics. The last
point is why Justin reviews every statement before it is sealed, and why the
statement is reprinted in full on the certification page. The trusted base is
the Lean kernel, `leanchecker`, the pinned Mathlib, and this repository's
verifier code.

## References

Every DOI in the bibliography is resolved through the DOI handle API. Any DOI
that is unresolved or could not be checked is listed on the certification page.
A run with an unresolved DOI is never announced.
