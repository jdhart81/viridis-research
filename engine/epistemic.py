"""Epistemic status (I24): what the record conjectures, what it proves, and what it knows through evidence.

Lean can show that a theorem follows from its stated hypotheses. It cannot show that those hypotheses
describe nature. So every claim carries two tracks, set independently, and one status derived from them.

formal track     NOT_APPLICABLE | UNPROVED | PROVED_CONDITIONAL | PROVED
empirical track  NOT_APPLICABLE | UNTESTED | REPRODUCED | INCONCLUSIVE | SUPPORTED | CONTRADICTED
status           CONJECTURED | UNRESOLVED | CONDITIONALLY_PROVED | FORMALLY_PROVED |
                 EMPIRICALLY_SUPPORTED | EXPERIMENTALLY_FALSIFIED

Rules
- E1  Additive. The I6 label is never changed here; a claim only gains the key ``epistemic``.
- E2  Independent tracks. The formal track is read from the Lean label only, the empirical track from
      the verifier's re-execution only. Neither can raise the other.
- E3  ``status`` is a pure function of (kind, formal, empirical); see ``status_of``.
- E4  Unconditional needs a review. A PROVEN claim is PROVED (FORMALLY_PROVED) only if
      ``statements/premises.json`` holds an entry for the statement, bound to the sealed hash, whose
      ``premises`` list is empty. With premises listed, or with no entry (``UNCLASSIFIED``), it is
      PROVED_CONDITIONAL (CONDITIONALLY_PROVED).
- E5  A verdict needs a plan fixed in advance. An empirical claim is SUPPORTED, CONTRADICTED or
      INCONCLUSIVE only if all of these hold: it is TESTED; it names a plan in
      ``preregistrations/registry.json``; the plan file has the registered hash; the plan is for the
      run's project and was registered on an earlier date than the run; the run's ``code/`` tree is
      exactly the plan's frozen file set, hash for hash; every input the plan froze (``data``, optional)
      is present with its hash; the entry script is the plan's; and the plan's verdict file is among
      the reproduced result files and holds a verdict from ``VERDICTS``.
      Otherwise a TESTED claim is REPRODUCED, which is not evidence about nature.
- E6  Caution on error. Anything missing, malformed or unreadable gives the weaker value with the
      reason. Nothing here raises, and nothing here can fail a night.
- E7  Not the agent's to write. ``statements/premises.json`` and ``preregistrations/`` are outside the
      artifact. A plan changes only by a pull request the owner merges. The premise review changes by
      such a pull request or by the verify job under I25 (``engine/premise_review.py``), which can only
      add caution to an entry and needs two independent runs before it records an empty list.
- E8  A premise can point at the empirical claims that test it (``tested_by``). The index resolves each
      pointer to that claim's empirical track; a contradicted premise is flagged, the theorem's formal
      track is not changed.
- E9  One plan, one verdict. The earliest merged run that carries a verdict under a plan holds that
      plan's verdict of record. A later run under the same plan stays REPRODUCED, so a plan cannot be
      re-run on other data until it says SUPPORTED. New data needs a new registered plan.

What the statuses do not mean. FORMALLY_PROVED says the reviewed premise list is empty, not that the
result matters or is new. EMPIRICALLY_SUPPORTED says a plan registered in advance returned SUPPORTED on
re-executed, pinned data; it does not certify the data's origin, that the outcome data were unseen when
the plan was registered (the owner attests that by merging it), or causation.
"""
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

from .util import sha256_file

SCHEMA = "viridis-epistemic-v1"
PREMISES_REL = "statements/premises.json"
PREMISES_SCHEMA = "viridis-premises-v1"
PLANS_REL = "preregistrations/registry.json"
PLANS_SCHEMA = "viridis-preregistrations-v1"

FORMAL = ("NOT_APPLICABLE", "UNPROVED", "PROVED_CONDITIONAL", "PROVED")
EMPIRICAL = ("NOT_APPLICABLE", "UNTESTED", "REPRODUCED", "INCONCLUSIVE", "SUPPORTED", "CONTRADICTED")
STATUSES = ("CONJECTURED", "UNRESOLVED", "CONDITIONALLY_PROVED", "FORMALLY_PROVED", "EMPIRICALLY_SUPPORTED",
            "EXPERIMENTALLY_FALSIFIED")
# A registered plan's verdict (left) and the empirical track it gives (right).
VERDICTS = {"SUPPORTED": "SUPPORTED", "CONTRADICTED": "CONTRADICTED", "NOT_SUPPORTED": "INCONCLUSIVE",
            "NOT_ESTIMABLE": "INCONCLUSIVE"}
PREREGISTERED = ("INCONCLUSIVE", "SUPPORTED", "CONTRADICTED")
PREMISE_KINDS = ("physical", "empirical", "modelling")
UNCLASSIFIED = "UNCLASSIFIED"

PLAN_ID = re.compile(r"[A-Z][A-Za-z0-9]{0,15}-[A-Za-z0-9][A-Za-z0-9._-]{0,63}\Z")
PREMISE_ID = re.compile(r"[A-Za-z][A-Za-z0-9_.-]{0,31}\Z")
DATE = re.compile(r"\d{4}-\d{2}-\d{2}\Z")
SHA = re.compile(r"[0-9a-f]{64}\Z")
MAX_VERDICT_BYTES = 1_000_000


def status_of(kind: str, formal: str, empirical: str) -> str:
    """E3. The one place a status is derived."""
    if kind == "formal":
        return {"PROVED": "FORMALLY_PROVED", "PROVED_CONDITIONAL": "CONDITIONALLY_PROVED"}.get(formal, "UNRESOLVED")
    if kind == "empirical":
        return {"SUPPORTED": "EMPIRICALLY_SUPPORTED", "CONTRADICTED": "EXPERIMENTALLY_FALSIFIED"}.get(empirical, "UNRESOLVED")
    return "CONJECTURED"


def _read(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def _text(value: Any, limit: int = 600) -> str:
    return value.strip()[:limit] if isinstance(value, str) else ""


# --------------------------------------------------------------------------- premises (formal track)

def load_premises(root: Path) -> tuple[dict[str, Any], list[str]]:
    """Return (entries by statement ID, problems). A missing file is an empty review, not a problem."""
    path = root / PREMISES_REL
    if not path.exists():
        return {}, []
    try:
        obj = _read(path)
        if obj.get("schema") != PREMISES_SCHEMA or not isinstance(obj.get("statements"), dict):
            raise ValueError("schema")
        return obj["statements"], []
    except (OSError, ValueError, AttributeError, TypeError) as exc:
        return {}, [f"{PREMISES_REL}: unreadable ({type(exc).__name__}); every proof is treated as conditional"]


def _clean_premises(raw: Any) -> list[dict[str, Any]] | None:
    """The premise list in canonical form, or None when it is malformed."""
    if not isinstance(raw, list) or len(raw) > 50:
        return None
    out, seen = [], set()
    for p in raw:
        if (not isinstance(p, dict) or not isinstance(p.get("id"), str) or not PREMISE_ID.match(p["id"])
                or p["id"] in seen or not _text(p.get("text")) or p.get("kind") not in PREMISE_KINDS):
            return None
        seen.add(p["id"])
        refs = p.get("tested_by", [])
        if not isinstance(refs, list) or len(refs) > 20:
            return None
        clean_refs = []
        for r in refs:
            if not isinstance(r, dict) or not isinstance(r.get("run_dir"), str) or not isinstance(r.get("claim_id"), str):
                return None
            clean_refs.append({"run_dir": r["run_dir"], "claim_id": r["claim_id"]})
        out.append({"id": p["id"], "kind": p["kind"], "text": _text(p["text"]),
                    "tested_by": sorted(clean_refs, key=lambda r: (r["run_dir"], r["claim_id"]))})
    return sorted(out, key=lambda p: p["id"])


def formal_track(proven: bool, statement_id: Any, statement_sha256: Any,
                 premises: dict[str, Any]) -> tuple[str, Any, str]:
    """E4. Return (formal value, premises list or UNCLASSIFIED or None, reason)."""
    if not proven:
        return "UNPROVED", None, "no kernel-checked proof of the sealed statement"
    entry = premises.get(statement_id) if isinstance(statement_id, str) else None
    if entry is None:
        return "PROVED_CONDITIONAL", UNCLASSIFIED, "proved; its premises have not been reviewed"
    if not isinstance(entry, dict) or entry.get("sha256") != statement_sha256:
        return "PROVED_CONDITIONAL", UNCLASSIFIED, "proved; the premise review is for a different text of the statement"
    clean = _clean_premises(entry.get("premises"))
    if clean is None:
        return "PROVED_CONDITIONAL", UNCLASSIFIED, "proved; the premise review is malformed"
    if clean:
        return ("PROVED_CONDITIONAL", clean,
                f"proved from {len(clean)} premise(s) about the world that the proof does not establish")
    return "PROVED", [], "proved; the reviewed premise list is empty"


# --------------------------------------------------------------------------- plans (empirical track)

def load_plans(root: Path) -> tuple[dict[str, Any], list[str]]:
    """Return (plans by ID, problems). A missing registry means no plan is registered."""
    path = root / PLANS_REL
    if not path.exists():
        return {}, []
    try:
        obj = _read(path)
        if obj.get("schema") != PLANS_SCHEMA or not isinstance(obj.get("plans"), dict):
            raise ValueError("schema")
        return obj["plans"], []
    except (OSError, ValueError, AttributeError, TypeError) as exc:
        return {}, [f"{PLANS_REL}: unreadable ({type(exc).__name__}); no claim can carry a registered verdict"]


def plan_problem(plan_id: Any, plans: dict[str, Any], root: Path) -> str | None:
    """Why the named plan is not a valid registration at ``root``; None when it is."""
    if not isinstance(plan_id, str) or not PLAN_ID.match(plan_id):
        return "the claim names no valid plan ID"
    plan = plans.get(plan_id)
    if not isinstance(plan, dict):
        return f"plan {plan_id} is not in {PLANS_REL}"
    code = plan.get("code")
    shaped = (plan.get("path") == f"preregistrations/{plan_id}.md" and isinstance(plan.get("sha256"), str)
              and SHA.match(plan["sha256"]) and isinstance(plan.get("project"), str)
              and isinstance(plan.get("registered_at"), str) and DATE.match(plan["registered_at"])
              and isinstance(plan.get("entry"), str) and isinstance(plan.get("verdict_file"), str)
              and plan["verdict_file"].startswith("results/") and plan["verdict_file"].endswith(".json")
              and isinstance(plan.get("verdict_key"), str) and plan["verdict_key"]
              and isinstance(code, dict) and code and plan["entry"] in code
              and all(isinstance(k, str) and k.startswith("code/") and isinstance(v, str) and SHA.match(v)
                      for k, v in code.items())
              and isinstance(plan.get("data", {}), dict)
              and all(isinstance(k, str) and k.startswith("data/") and isinstance(v, str) and SHA.match(v)
                      for k, v in plan.get("data", {}).items()))
    if not shaped:
        return f"plan {plan_id} is malformed"
    file = root / plan["path"]
    try:
        if file.is_symlink() or not file.is_file() or sha256_file(file) != plan["sha256"]:
            return f"plan {plan_id}: the plan file is missing or does not have the registered hash"
    except OSError:
        return f"plan {plan_id}: the plan file could not be read"
    return None


def verdict_of_record(root: Path, plan_id: str) -> str | None:
    """E9. The merged run that already carries a verdict under this plan, if any (earliest first)."""
    outcomes = root / "outcomes"
    for path in sorted(outcomes.glob("*.json")) if outcomes.is_dir() else []:
        try:
            o = _read(path)
            if o.get("status") != "MERGED" or not isinstance(o.get("run_dir"), str):
                continue
            for lab in _read(root / o["run_dir"] / "certification.json")["labels"].values():
                stored = lab.get("epistemic") if isinstance(lab, dict) else None
                if (isinstance(stored, dict) and stored.get("empirical") in PREREGISTERED and lab.get("label") == "TESTED"
                        and isinstance(stored.get("preregistration"), dict)
                        and stored["preregistration"].get("plan") == plan_id):
                    return o["run_dir"]
        except (OSError, ValueError, KeyError, TypeError, AttributeError):
            continue
    return None


def _code_tree(out: Path) -> dict[str, str] | None:
    """Every file under ``out/code`` with its hash; None if the tree holds anything but regular files."""
    top = out / "code"
    found: dict[str, str] = {}
    if not top.is_dir() or top.is_symlink():
        return found
    for path in sorted(top.rglob("*")):
        if path.is_symlink():
            return None
        if path.is_dir():
            continue
        if not path.is_file():
            return None
        found[path.relative_to(out).as_posix()] = sha256_file(path)
    return found


def _inputs_match(out: Path, frozen: dict[str, str]) -> bool:
    for rel, sha in frozen.items():
        path = out / rel
        if ".." in rel.split("/") or path.is_symlink() or not path.is_file() or sha256_file(path) != sha:
            return False
    return True


def _verdict(out: Path, rel: str, key: str) -> str | None:
    path = out / rel
    if path.is_symlink() or not path.is_file() or path.stat().st_size > MAX_VERDICT_BYTES:
        return None
    obj = _read(path)
    value = obj.get(key) if isinstance(obj, dict) else None
    if not isinstance(value, str):
        return None
    return value.strip().upper().replace(" ", "_")


def empirical_track(claim: dict[str, Any], tested: bool, rerun: Any, plans: dict[str, Any], *, root: Path, out: Path,
                    project: str, date: str) -> tuple[str, dict[str, Any] | None, str]:
    """E5. Return (empirical value, registration record or None, reason)."""
    if not tested:
        return "UNTESTED", None, "the verifier did not reproduce this claim's analysis"
    plan_id = claim.get("preregistration")
    if plan_id is None:
        return "REPRODUCED", None, "the computation reproduces; no plan was registered in advance, so there is no verdict"
    why = plan_problem(plan_id, plans, root)
    if why is None:
        plan = plans[plan_id]
        reproduced = {f.get("path") for f in getattr(rerun, "files", []) or []
                      if isinstance(f, dict) and f.get("verdict") in ("exact", "within tolerance")}
        if plan["project"] != project:
            why = f"plan {plan_id} is registered for project {plan['project']}, not {project}"
        elif not (isinstance(date, str) and DATE.match(date) and plan["registered_at"] < date):
            why = f"plan {plan_id} was not registered before the run's date"
        elif (earlier := verdict_of_record(root, plan_id)) is not None:
            why = f"plan {plan_id} already has its verdict of record in {earlier}; new data needs a new plan"
        elif getattr(rerun, "entry", None) != plan["entry"]:
            why = f"the re-executed script is not the plan's entry {plan['entry']}"
        elif _code_tree(out) != plan["code"]:
            why = f"the run's code/ tree is not the file set frozen by plan {plan_id}"
        elif not _inputs_match(out, plan.get("data", {})):
            why = f"an input frozen by plan {plan_id} is missing or has a different hash"
        elif plan["verdict_file"] not in reproduced:
            why = f"the plan's verdict file {plan['verdict_file']} is not among the reproduced result files"
        else:
            verdict = _verdict(out, plan["verdict_file"], plan["verdict_key"])
            if verdict not in VERDICTS:
                why = f"{plan['verdict_file']} holds no verdict from {', '.join(sorted(VERDICTS))}"
            else:
                record = {"plan": plan_id, "sha256": plan["sha256"], "registered_at": plan["registered_at"],
                          "verdict": verdict, "verdict_file": plan["verdict_file"]}
                if _text(plan.get("hypothesis")):
                    record["hypothesis"] = _text(plan["hypothesis"])
                return (VERDICTS[verdict], record,
                        f"plan {plan_id}, registered {plan['registered_at']}, returned {verdict} on re-executed, pinned data")
    return "REPRODUCED", None, f"the computation reproduces; no registered verdict ({why})"


# --------------------------------------------------------------------------- verify side

def annotate(labels: dict[str, dict[str, Any]], run_obj: dict[str, Any], reruns: dict[str, Any] | None, *,
             root: Path, out: Path, project: str, date: str) -> list[str]:
    """Add ``epistemic`` to every label entry (E1). Returns problems found. Never raises (E6)."""
    problems: list[str] = []
    try:
        premises, p1 = load_premises(root)
        plans, p2 = load_plans(root)
        problems += p1 + p2
        claims = {c["id"]: c for c in run_obj.get("claims", []) if isinstance(c, dict) and isinstance(c.get("id"), str)}
    except Exception as exc:  # noqa: BLE001 - E6
        return [f"epistemic status not derived ({type(exc).__name__}: {str(exc)[:200]})"]
    for cid, entry in labels.items():
        try:
            kind = entry.get("kind")
            record: dict[str, Any] = {"schema": SCHEMA, "formal": "NOT_APPLICABLE", "empirical": "NOT_APPLICABLE"}
            if kind == "formal":
                record["formal"], listed, record["reason"] = formal_track(
                    entry.get("label") == "PROVEN", entry.get("statement_id"), entry.get("statement_sha256"), premises)
                if listed is not None:
                    record["premises"] = listed
            elif kind == "empirical":
                record["empirical"], registration, record["reason"] = empirical_track(
                    claims.get(cid, {}), entry.get("label") == "TESTED", (reruns or {}).get(cid), plans,
                    root=root, out=out, project=project, date=date)
                if registration is not None:
                    record["preregistration"] = registration
            else:
                record["reason"] = "stated without proof or test"
            record["status"] = status_of(str(kind), record["formal"], record["empirical"])
            entry["epistemic"] = record
        except Exception as exc:  # noqa: BLE001 - E6: the weaker value, never a failed night
            fallback = {"formal": "UNPROVED" if entry.get("kind") == "formal" else "NOT_APPLICABLE",
                        "empirical": "UNTESTED" if entry.get("kind") == "empirical" else "NOT_APPLICABLE"}
            entry["epistemic"] = {"schema": SCHEMA, **fallback,
                                  "status": "CONJECTURED" if entry.get("kind") not in ("formal", "empirical") else "UNRESOLVED",
                                  "reason": f"status could not be derived ({type(exc).__name__})"}
            problems.append(f"{cid}: epistemic status could not be derived ({type(exc).__name__}: {str(exc)[:200]})")
    return problems


# --------------------------------------------------------------------------- index side

def empirical_from_certification(lab: dict[str, Any], plans: dict[str, Any], root: Path) -> tuple[str, dict[str, Any] | None, str | None]:
    """The empirical track of a claim in a merged run, as the record supports it now.

    Returns (value, registration or None, problem or None). A registered verdict is kept only while
    its plan is still in the registry with the hash the certification recorded.
    """
    if lab.get("kind") != "empirical":
        return "NOT_APPLICABLE", None, None
    if lab.get("label") not in ("TESTED", "REPLICATED"):
        return "UNTESTED", None, None
    stored = lab.get("epistemic") if isinstance(lab.get("epistemic"), dict) else {}
    value, reg = stored.get("empirical"), stored.get("preregistration")
    if value not in PREREGISTERED:
        return "REPRODUCED", None, None
    if (not isinstance(reg, dict) or VERDICTS.get(reg.get("verdict")) != value):
        return "REPRODUCED", None, "its registered verdict is malformed"
    why = plan_problem(reg.get("plan"), plans, root)
    if why is None and plans[reg["plan"]]["sha256"] != reg.get("sha256"):
        why = f"plan {reg['plan']} no longer has the hash the run was certified against"
    if why is not None:
        return "REPRODUCED", None, why
    kept = {k: reg.get(k) for k in ("plan", "registered_at", "sha256", "verdict", "verdict_file")}
    if _text(reg.get("hypothesis")):
        kept["hypothesis"] = _text(reg["hypothesis"])
    return value, kept, None


def resolve_premises(listed: Any, claim_tracks: dict[tuple[str, str], str]) -> tuple[Any, bool, list[str]]:
    """E8. Attach each ``tested_by`` pointer's empirical track. Returns (premises, any contradicted, problems)."""
    if not isinstance(listed, list):
        return listed, False, []
    out, contradicted, problems = [], False, []
    for p in listed:
        refs = []
        for r in p.get("tested_by", []):
            track = claim_tracks.get((r["run_dir"], r["claim_id"]))
            if track is None:
                problems.append(f"premise {p['id']}: {r['run_dir']} {r['claim_id']} is not an empirical claim of a merged run")
                continue
            refs.append({**r, "empirical": track})
        tracks = {r["empirical"] for r in refs}
        state = ("CONTRADICTED" if "CONTRADICTED" in tracks else "SUPPORTED" if "SUPPORTED" in tracks else "UNTESTED")
        contradicted = contradicted or state == "CONTRADICTED"
        out.append({"id": p["id"], "kind": p["kind"], "text": p["text"], "tested_by": refs, "evidence": state})
    return out, contradicted, problems


def frontier(statement_epistemic: dict[str, dict[str, Any]]) -> dict[str, Any]:
    """What the record would learn most from next, read off the statuses. Pure and deterministic.

    ``premises``: every premise that is not SUPPORTED, grouped by ID across statements and ordered by how
    many proved statements rest on it. ``unreviewed``: proved statements whose premises nobody has listed.
    ``unproved``: sealed statements with no proof.
    """
    grouped: dict[str, dict[str, Any]] = {}
    unreviewed, unproved = [], []
    for sid, e in sorted(statement_epistemic.items()):
        if e.get("formal") == "UNPROVED":
            unproved.append(sid)
        elif e.get("premises") == UNCLASSIFIED:
            unreviewed.append(sid)
        for p in e["premises"] if isinstance(e.get("premises"), list) else []:
            if p.get("evidence") == "SUPPORTED":
                continue
            g = grouped.setdefault(p["id"], {"id": p["id"], "kind": p["kind"], "text": p["text"],
                                             "evidence": p.get("evidence", "UNTESTED"), "statements": []})
            g["statements"].append(sid)
            if p.get("evidence") == "CONTRADICTED":
                g["evidence"] = "CONTRADICTED"
    ranked = sorted(grouped.values(), key=lambda g: (-len(g["statements"]), g["id"]))
    return {"premises": ranked, "unreviewed": unreviewed, "unproved": unproved}
