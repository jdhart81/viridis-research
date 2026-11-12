"""Re-run the registered P1C confirmatory test, unchanged, and write its results.

Run from a folder that holds `code/`, `data/` and an empty `results/`:

    python3 code/rerun_p1c.py

It copies the registered inputs into a scratch folder laid out as the frozen script expects
(`p1c/` beside `p1/`), runs the frozen `code/run_test.py` there, and writes two files:

    results/p1c_results.json   everything run_test.py reports (primary, secondary, sensitivity)
    results/p1c_primary.json   the registered primary test and its decision

`run_test.py` refuses to run unless it and its inputs match the hashes in the registered
FREEZE.json, and the outcomes match the fetch record. Needs numpy and pandas; no network.
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "data")
P1C_FILES = ["predictors_blind.csv", "outcomes.csv", "OUTCOME_FETCH.json", "FREEZE.json", "CRITICAL_VALUES.json",
             "CALIBRATION.json", "EXPOSURE_LISTS.json", "p1_config.json"]
PILOT_FILES = ["predictors_blind.csv", "outcomes.csv", "p1_config.json"]


def main() -> int:
    work = tempfile.mkdtemp(prefix="p1c-")
    p1c, p1 = os.path.join(work, "p1c"), os.path.join(work, "p1")
    os.makedirs(p1c)
    os.makedirs(p1)
    for name in P1C_FILES:
        shutil.copyfile(os.path.join(DATA, "p1c", name), os.path.join(p1c, name))
    for name in PILOT_FILES:
        shutil.copyfile(os.path.join(DATA, "pilot", name), os.path.join(p1, name))
    shutil.copyfile(os.path.join(ROOT, "code", "run_test.py"), os.path.join(p1c, "run_test.py"))
    proc = subprocess.run([sys.executable, "-B", "run_test.py"], cwd=p1c, capture_output=True, text=True)
    sys.stdout.write(proc.stdout[-3000:])
    sys.stderr.write(proc.stderr[-3000:])
    if proc.returncode != 0:
        return proc.returncode
    with open(os.path.join(p1c, "results.json")) as fh:
        results = json.load(fh)
    if results.get("inputs_verified") is not True or results.get("synthetic") is not False:
        sys.stderr.write("run_test.py did not verify its inputs\n")
        return 2
    primary = {"registered_test": "P1C v1.4, H2, definition B, model M2R",
               "decision_rule": "SUPPORTED iff beta - C2 * max(SE_twoway, SE_year) > 0",
               "inputs_verified_against_freeze": results["inputs_verified"],
               "n_ignitions": results["n_ignitions"], "n_with_outcome": results["n_with_outcome"],
               "pilot_overlap": results["pilot_overlap"], "primary_test": results["primary_test"],
               "decision": results["decision"], "interpretation": results["interpretation"]}
    out = os.path.join(ROOT, "results")
    with open(os.path.join(out, "p1c_results.json"), "w") as fh:
        json.dump(results, fh, indent=1, sort_keys=True)
    with open(os.path.join(out, "p1c_primary.json"), "w") as fh:
        json.dump(primary, fh, indent=1, sort_keys=True)
    shutil.rmtree(work, ignore_errors=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
