"""The certified index (I15): one file that says what the record has certified, and nothing else does.

``index/certified.json`` is a pure function of the record: the sealed-statement registry, the
outcomes, each merged run's ``certification.json``, the projects and the Zenodo ledger. Every
engine commit to main refreshes it in the same commit (``gitio.commit_and_push``), so at any commit
of the record the index equals ``build(record)``. It has no timestamp of its own.

Downstream systems (the Viridis Research Network, Viridis OS, the website) take the status of a
result from this file at a pinned commit, never from prose, a theorem name or a search hit.

Rules
- C1  A statement is PROVEN here only if a MERGED run's certification gives a claim the label
      PROVEN for that statement ID with the statement hash the registry holds. Otherwise it is
      SEALED_UNPROVEN. The earliest such run is the proof of record.
- C2  A claim is TESTED here only if a MERGED run's certification labels it TESTED.
- C3  Anything unreadable or inconsistent is left out and listed under ``problems``; it never
      becomes a status.
- C4  Building never raises into a commit: a failed refresh leaves the previous index in place.
- C5  The output is deterministic: sorted keys, sorted lists, no clock.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from .util import RECORD_ROOT, log

INDEX_REL = "index/certified.json"
SCHEMA = "viridis-certified-index-v1"
BOUNDARY = ("Derived from the record at the commit that holds this file. PROVEN: a Lean proof of a statement sealed "
            "in advance, checked by the kernel on standard axioms; it certifies the formal statement, not its "
            "ecological or physical interpretation. TESTED: the verifier re-ran the analysis on inputs pinned by "
            "hash and reproduced the reported numbers; it certifies the computation, not the data's origin or the "
            "conclusion. Everything else in the record is ASSUMED or CONJECTURE.")


def _read(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _text(value: Any, limit: int = 600) -> str:
    return value.strip()[:limit] if isinstance(value, str) else ""


def _sealed_by(root: Path, decision: Any) -> str:
    """Who sealed a statement: "owner" (the owner's own comment), "policy" (the standing sealing policy, I17),
    or "unknown" when the decision record cannot be read."""
    try:
        record = _read(root / "decisions" / "records" / f"{decision}.json")
        authority = record.get("authority", "owner")
        return authority if authority in ("owner", "policy") else "unknown"
    except (OSError, ValueError, KeyError, TypeError, AttributeError):
        return "unknown"


def build(root: Path = RECORD_ROOT) -> dict[str, Any]:
    """Return the index for the record at ``root``. Pure: reads files, writes nothing."""
    problems: list[str] = []

    registry: dict[str, Any] = {}
    try:
        reg = _read(root / "statements" / "registry.json")
        registry = reg["statements"] if isinstance(reg.get("statements"), dict) else {}
    except FileNotFoundError:
        pass
    except (OSError, ValueError, KeyError, TypeError) as exc:
        problems.append(f"statements/registry.json: unreadable ({type(exc).__name__})")

    dois: dict[str, str] = {}
    try:
        ledger = _read(root / "config" / "channels.json")["zenodo"].get("runs", {})
        dois = {k: v["doi"] for k, v in ledger.items() if isinstance(v, dict) and isinstance(v.get("doi"), str)}
    except (OSError, ValueError, KeyError, TypeError, AttributeError):
        pass

    # Weekly release files also record DOIs, including deposits made before the per-run ledger existed.
    release_dir = root / "releases"
    for rel in sorted(release_dir.glob("*.json")) if release_dir.is_dir() else []:
        try:
            for key, item in (_read(rel).get("zenodo") or {}).items():
                url = item.get("doi_url") if isinstance(item, dict) else None
                if isinstance(url, str) and url.startswith("https://doi.org/") and key not in dois:
                    dois[key] = url[len("https://doi.org/"):]
        except (OSError, ValueError, AttributeError, TypeError):
            problems.append(f"releases/{rel.name}: unreadable")

    statements: dict[str, dict[str, Any]] = {}
    for sid, entry in sorted(registry.items()):
        if not isinstance(entry, dict) or not isinstance(entry.get("sha256"), str):
            problems.append(f"registry entry {sid}: malformed")
            continue
        probe = entry.get("probe") if isinstance(entry.get("probe"), dict) else {}
        statements[sid] = {"status": "SEALED_UNPROVEN", "project": entry.get("project"), "task": entry.get("task"),
                           "decision": entry.get("decision"), "sealed_at": entry.get("sealed_at"),
                           "sealed_by": _sealed_by(root, entry.get("decision")),
                           "sha256": entry["sha256"], "path": entry.get("path"), "constant": entry.get("constant"),
                           "closed_by_single_tactic": any(v == "closed" for v in probe.values()), "proof": None}

    runs: list[dict[str, Any]] = []
    tested: list[dict[str, Any]] = []
    outcome_dir = root / "outcomes"
    for path in sorted(outcome_dir.glob("*.json")) if outcome_dir.is_dir() else []:
        try:
            o = _read(path)
        except (OSError, ValueError):
            problems.append(f"outcomes/{path.name}: unreadable")
            continue
        if not isinstance(o, dict) or o.get("status") != "MERGED" or not isinstance(o.get("run_dir"), str):
            continue
        run_dir, date = o["run_dir"], o.get("date")
        try:
            cert = _read(root / run_dir / "certification.json")
            labels = cert["labels"]
            assert isinstance(labels, dict)
        except (OSError, ValueError, KeyError, TypeError, AssertionError):
            problems.append(f"{run_dir}: certification.json missing or unreadable; the run certifies nothing here")
            continue
        run_key = run_dir.split("/", 1)[-1]
        counts: dict[str, int] = {}
        for cid, lab in sorted(labels.items()):
            if not isinstance(lab, dict) or not isinstance(lab.get("label"), str):
                problems.append(f"{run_dir}: label {cid} malformed")
                continue
            counts[lab["label"]] = counts.get(lab["label"], 0) + 1
            if lab["label"] == "PROVEN":
                sid = lab.get("statement_id")
                if sid not in statements:
                    problems.append(f"{run_dir}: {cid} is PROVEN for {sid!r}, which is not in the registry")
                elif lab.get("statement_sha256") != statements[sid]["sha256"]:
                    problems.append(f"{run_dir}: {cid} proves a different text of {sid} than the registry holds")
                elif statements[sid]["proof"] is None:            # C1: the earliest run is the proof of record
                    statements[sid]["status"] = "PROVEN"
                    statements[sid]["proof"] = {"run_dir": run_dir, "date": date, "claim_id": cid,
                                                "axioms": sorted(lab.get("axioms") or []),
                                                "candidate_sha256": lab.get("candidate_sha256"),
                                                "doi": dois.get(run_key)}
            elif lab["label"] == "TESTED":
                tested.append({"run_dir": run_dir, "date": date, "project": o.get("project"), "task": o.get("task"),
                               "claim_id": cid, "text": _text(lab.get("text")), "entry": lab.get("entry"),
                               "pinned_inputs": lab.get("inputs"), "doi": dois.get(run_key)})
        runs.append({"date": date, "project": o.get("project"), "task": o.get("task"), "run_dir": run_dir,
                     "title": _text(o.get("title"), 300), "labels": dict(sorted(counts.items())),
                     "paper_built": o.get("paper_built") is True, "manifest_sha256": o.get("manifest_sha256"),
                     "doi": dois.get(run_key)})

    projects: dict[str, dict[str, Any]] = {}
    for pj in sorted((root / "projects").glob("*/project.json")) if (root / "projects").is_dir() else []:
        try:
            p = _read(pj)
            projects[str(p["id"])] = {"title": _text(p.get("title"), 200), "status": p.get("status"),
                                      "priority": p.get("priority")}
        except (OSError, ValueError, KeyError, TypeError):
            problems.append(f"projects/{pj.parent.name}/project.json: unreadable")

    proven = sorted(s for s, v in statements.items() if v["status"] == "PROVEN")
    return {"schema": SCHEMA, "boundary": BOUNDARY,
            "counts": {"sealed_statements": len(statements), "proven_statements": len(proven),
                       "tested_claims": len(tested), "merged_runs": len(runs), "problems": len(problems)},
            "proven": proven, "statements": statements,
            "tested_claims": sorted(tested, key=lambda t: (str(t["date"]), t["run_dir"], t["claim_id"])),
            "runs": sorted(runs, key=lambda r: (str(r["date"]), r["run_dir"])),
            "projects": projects, "problems": sorted(problems)}


def render(index: dict[str, Any]) -> str:
    return json.dumps(index, indent=1, sort_keys=True, ensure_ascii=False) + "\n"       # C5


def refresh(root: Path) -> str | None:
    """Write the index if it changed. Returns its path when written, None otherwise. Never raises (C4)."""
    try:
        text = render(build(root))
        path = root / INDEX_REL
        if path.is_file() and path.read_text(encoding="utf-8") == text:
            return None
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        return INDEX_REL
    except Exception as exc:  # noqa: BLE001 - C4: the index must never block an outcome or a decision
        log(f"certified index not refreshed ({type(exc).__name__}: {str(exc)[:200]})")
        return None


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="engine.certified_index")
    ap.add_argument("--root", type=Path, default=RECORD_ROOT)
    ap.add_argument("--check", action="store_true", help="exit 1 if the committed index differs from the record")
    ap.add_argument("--write", action="store_true", help="write index/certified.json")
    args = ap.parse_args(argv)
    text = render(build(args.root))
    path = args.root / INDEX_REL
    if args.check:
        current = path.read_text(encoding="utf-8") if path.is_file() else None
        print("certified index: " + ("up to date" if current == text else "STALE or missing"))
        return 0 if current == text else 1
    if args.write:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        print(f"wrote {path}")
        return 0
    sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
