#!/usr/bin/env bash
# Probe each proposed Statement with simple tactics and record whether any closes it.
# Usage: probe.sh <proposals_dir> <scratch_dir>   (prints a TSV table to stdout)
# Each probe file is the proposal module with its final `end` line replaced by
#   example : Statement := by <tactic>
# followed by the `end` line. "open" means the tactic failed (Lean reported an error).
set -u
PROP="$1"; SCR="$2"; mkdir -p "$SCR"
printf "statement\ttactic\tresult\n"
for M in LoopMassBalance CascadedRecovery RecoveryWorkFloor CyclicSymbiosis; do
  # baseline: the module itself must compile without errors
  if lean "$PROP/P3.$M.lean" 2>&1 | grep -q "error"; then base=FAILS; else base=compiles; fi
  printf "P3.%s\t(module)\t%s\n" "$M" "$base"
  for T in simp norm_num decide aesop trivial simp_all "exact?"; do
    f="$SCR/probe_$M.lean"
    head -n -1 "$PROP/P3.$M.lean" > "$f"
    printf "example : Statement := by\n  %s\nend ViridisStatements.P3.%s\n" "$T" "$M" >> "$f"
    if timeout 300 lean "$f" 2>&1 | grep -q "error"; then r=open; else r=CLOSED; fi
    printf "P3.%s\t%s\t%s\n" "$M" "$T" "$r"
  done
done
