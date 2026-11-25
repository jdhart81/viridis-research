"""Pre-registered test of the size-scaling consequence of premise M-Nucleation.

Reads data/tree_recruits.csv (Zenodo 4731126, tree_recruits-2007-2013.csv) and data/design.json,
writes results/verdict.json. Run from the plan root: python3 code/analyze.py
"""
import csv
import json
import math
import os
import random


def norm(s):
    return (s or "").strip().lstrip("﻿").strip()


def load_counts(path, design):
    col = design["final_survival_column"]
    alive = set(design["alive_codes"])
    counts = {}  # site -> {class: count}
    with open(path, newline="", encoding="utf-8", errors="replace") as f:
        reader = csv.DictReader(f)
        reader.fieldnames = [norm(h) for h in reader.fieldnames]
        for row in reader:
            row = {norm(k): norm(v) for k, v in row.items() if k is not None}
            site = row.get("Site", "")
            treat = row.get("Treat", "").upper()
            fq = row.get("FQ", "").upper()
            if not site or fq == "LTB":
                continue
            if treat == "I":
                cls = row.get("Isz", "").upper()
                if cls not in ("S", "M", "L"):
                    continue
            elif treat == "C":
                if fq != "LT":
                    continue
                cls = "C"
            else:
                continue
            site_counts = counts.setdefault(site, {"S": 0, "M": 0, "L": 0, "C": 0, "_I": False, "_C": False})
            site_counts["_I" if treat == "I" else "_C"] = True
            is_seedling = row.get("Sd/Rs", "").lower() == "s"
            if is_seedling and row.get(col, "").lower() in alive:
                site_counts[cls] += 1
    return {s: c for s, c in counts.items() if c["_I"]}


def log_density(c, cls, design):
    return math.log((c[cls] + design["pseudocount"]) / design["area_m2"][cls])


def mean(xs):
    return sum(xs) / len(xs)


def boot_ci(xs, n_boot, rng):
    stats = []
    for _ in range(n_boot):
        stats.append(mean([xs[rng.randrange(len(xs))] for _ in xs]))
    stats.sort()
    return stats[int(0.025 * n_boot)], stats[int(0.975 * n_boot) - 1]


def main():
    with open("data/design.json") as f:
        design = json.load(f)
    os.makedirs("results", exist_ok=True)
    out = {"plan_id": "P6-NucleationIslandSize", "tests": ["M-Nucleation"]}
    path = "data/tree_recruits.csv"
    if not os.path.exists(path):
        out.update(verdict="NOT_ESTIMABLE", reason="outcome file missing")
    else:
        counts = load_counts(path, design)
        sites = sorted(counts)
        out["n_sites"] = len(sites)
        out["counts"] = {s: {k: counts[s][k] for k in ("S", "M", "L", "C")} for s in sites}
        if len(sites) < design["min_sites"]:
            out.update(verdict="NOT_ESTIMABLE", reason="fewer than min_sites island sites")
        else:
            ls = [log_density(counts[s], "L", design) - log_density(counts[s], "S", design) for s in sites]
            ms = [log_density(counts[s], "M", design) - log_density(counts[s], "S", design) for s in sites]
            lm = [log_density(counts[s], "L", design) - log_density(counts[s], "M", design) for s in sites]
            rng = random.Random(design["seed"])
            lo, hi = boot_ci(ls, design["n_boot"], rng)
            out.update(mean_log_L_over_S=mean(ls), ci95_log_L_over_S=[lo, hi],
                       mean_log_M_over_S=mean(ms), mean_log_L_over_M=mean(lm))
            if lo > 0 and mean(ms) > 0 and mean(lm) > 0:
                out["verdict"] = "SUPPORTED"
            elif hi < 0:
                out["verdict"] = "CONTRADICTED"
            else:
                out["verdict"] = "NOT_SUPPORTED"
    with open("results/verdict.json", "w") as f:
        json.dump(out, f, indent=2, sort_keys=True)
    print(out["verdict"])


if __name__ == "__main__":
    main()
