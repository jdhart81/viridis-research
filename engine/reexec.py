"""Verifier re-execution of empirical claims: the TESTED label (I6, T1-T9 in docs/CERTIFICATION.md).

An empirical claim may carry ``"reproduce": {"entry": "code/<script>.py"}``. When re-execution is
enabled in the record's ``config/engine.json`` (``tested.enabled``), the verifier:

1. checks that every file under ``data/`` is pinned in ``data_pins.json`` (path, SHA-256, https URL);
2. copies ``code/`` and ``data/`` to a clean directory and runs the entry script in the I5 sandbox
   (no network, read-only root, non-root user) with that directory as the working directory and an
   empty, writable ``results/``;
3. compares every ``results/`` evidence file of type JSON, CSV or TSV with the file the script just
   produced: byte for byte, or number by number within the configured tolerance.

The claim is TESTED only if at least one evidence file was compared and all of them match. Anything
else leaves the claim ASSUMED with the reason. Nothing here can fail the night (T6).

TESTED means the stated computation reproduces from the pinned inputs. It does not certify where
the data came from or the inference drawn from it.
"""
from __future__ import annotations

import argparse
import csv
import io
import json
import math
import os
import re
import shutil
import stat
import subprocess
import sys
import time
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Callable

from . import sandbox
from .util import REPO_ROOT, load_json, log, sha256_bytes, sha256_file

PINS_SCHEMA = "viridis-data-pins-v1"
ENTRY = re.compile(r"code/[A-Za-z0-9_][A-Za-z0-9._-]*(?:/[A-Za-z0-9_][A-Za-z0-9._-]*)*\.py\Z")
COMPARABLE = (".json", ".csv", ".tsv")
DEFAULTS: dict[str, Any] = {"enabled": False, "timeout_seconds": 600, "memory_mb": 4096, "max_claims": 3,
                            "rel_tol": 1e-6, "abs_tol": 1e-9, "max_result_bytes": 25_000_000}
RUN_ENV = {"PYTHONHASHSEED": "0", "PYTHONDONTWRITEBYTECODE": "1", "OMP_NUM_THREADS": "1",
           "OPENBLAS_NUM_THREADS": "1", "MKL_NUM_THREADS": "1", "MPLBACKEND": "Agg", "TZ": "UTC"}

PYTHON = "/opt/venv/bin/python"     # the image's pinned environment (docker/py/requirements.txt)

Runner = Callable[[Path, str, dict[str, Any]], sandbox.SandboxResult]


class Problem(Exception):
    """A reason the claim stays ASSUMED."""


@dataclass
class ReexecResult:
    claim_id: str
    ok: bool = False
    reason: str = ""
    entry: str = ""
    image: str = ""
    duration_s: float = 0.0
    inputs: list[dict[str, str]] = field(default_factory=list)
    files: list[dict[str, str]] = field(default_factory=list)
    not_compared: list[str] = field(default_factory=list)
    log_tail: str = ""

    def to_json(self) -> dict[str, Any]:
        return asdict(self)


def settings(cfg: dict[str, Any]) -> dict[str, Any]:
    merged = dict(DEFAULTS)
    merged.update({k: v for k, v in (cfg.get("tested") or {}).items() if k in DEFAULTS})
    return merged


def enabled(cfg: dict[str, Any]) -> bool:
    return settings(cfg)["enabled"] is True


# --------------------------------------------------------------------------- image

def py_image_tag(root: Path = REPO_ROOT) -> str:
    override = os.environ.get("VIRIDIS_PY_IMAGE")
    if override:
        return override
    d = root / "docker" / "py"
    return f"viridis-py:{sha256_bytes((d / 'Dockerfile').read_bytes() + b'\0' + (d / 'requirements.txt').read_bytes())[:16]}"


def ensure_py_image(root: Path = REPO_ROOT) -> str:
    tag = py_image_tag(root)
    if not sandbox.image_present(tag):
        sandbox.build_image(root / "docker" / "py" / "Dockerfile", tag)
    return tag


# --------------------------------------------------------------------------- inputs

def _safe_rel(rel: Any, top: str) -> str:
    if not isinstance(rel, str) or not rel.startswith(top + "/") or any(p in ("", ".", "..") for p in rel.split("/")):
        raise Problem(f"bad path {rel!r}")
    return rel


def entry_of(claim: dict[str, Any], out: Path) -> str:
    spec = claim.get("reproduce")
    if not isinstance(spec, dict) or not isinstance(spec.get("entry"), str) or not ENTRY.match(spec["entry"]):
        raise Problem("reproduce.entry must name a Python script under code/")
    entry = spec["entry"]
    path = out / entry
    if path.is_symlink() or not path.is_file():
        raise Problem(f"{entry} does not exist")
    return entry


def check_inputs(out: Path) -> list[dict[str, str]]:
    """T4: every file under data/ is pinned (path, sha256, https url) and the hashes match."""
    data = out / "data"
    present = sorted(p.relative_to(out).as_posix() for p in data.rglob("*") if p.is_file() and not p.is_symlink()) \
        if data.is_dir() else []
    if not present:
        return []
    pins_path = out / "data_pins.json"
    if not pins_path.is_file():
        raise Problem("data/ has files but there is no data_pins.json")
    try:
        pins = load_json(pins_path)
    except (OSError, ValueError) as exc:
        raise Problem(f"data_pins.json is unreadable ({exc})")
    if not isinstance(pins, dict) or pins.get("schema") != PINS_SCHEMA or not isinstance(pins.get("inputs"), list):
        raise Problem(f"data_pins.json must have schema {PINS_SCHEMA} and a list `inputs`")
    listed: dict[str, dict[str, str]] = {}
    for item in pins["inputs"]:
        if not isinstance(item, dict):
            raise Problem("data_pins.json: every input must be an object")
        rel = _safe_rel(item.get("path"), "data")
        sha, url = item.get("sha256"), item.get("url")
        if not isinstance(sha, str) or not re.fullmatch(r"[0-9a-f]{64}", sha):
            raise Problem(f"data_pins.json: {rel} needs a sha256")
        if not isinstance(url, str) or not url.startswith("https://") or len(url) > 2000 or any(c.isspace() for c in url):
            raise Problem(f"data_pins.json: {rel} needs an https url")
        if rel in listed:
            raise Problem(f"data_pins.json: {rel} is listed twice")
        listed[rel] = {"path": rel, "sha256": sha, "url": url}
    if sorted(listed) != present:
        extra = sorted(set(present) - set(listed)) + sorted(set(listed) - set(present))
        raise Problem("data/ and data_pins.json disagree: " + ", ".join(extra[:5]))
    for rel, item in listed.items():
        if sha256_file(out / rel) != item["sha256"]:
            raise Problem(f"{rel} does not match its pinned sha256")
    return [listed[rel] for rel in present]


def evidence_of(claim: dict[str, Any]) -> tuple[list[str], list[str]]:
    results = [_safe_rel(rel, "results") for rel in claim.get("evidence", [])
               if isinstance(rel, str) and rel.startswith("results/")]
    compared = [r for r in results if r.lower().endswith(COMPARABLE)]
    return compared, [r for r in results if r not in compared]


# --------------------------------------------------------------------------- run

def stage(out: Path, work: Path) -> Path:
    """A clean directory holding copies of code/ and data/ and an empty, writable results/."""
    if work.exists():
        shutil.rmtree(work, ignore_errors=True)
    root = work / "stage"
    root.mkdir(parents=True)
    for name in ("code", "data"):
        src = out / name
        dest = root / name
        dest.mkdir()
        if src.is_dir():
            for path in sorted(src.rglob("*")):
                if path.is_symlink():
                    continue
                target = dest / path.relative_to(src)
                if path.is_dir():
                    target.mkdir(parents=True, exist_ok=True)
                elif path.is_file():
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(path, target)
        for path in [dest, *dest.rglob("*")]:
            os.chmod(path, 0o755 if path.is_dir() else 0o644)
    (root / "results").mkdir()
    os.chmod(root / "results", 0o777)
    os.chmod(root, 0o755)
    return root


def docker_runner(root: Path, entry: str, cfg: dict[str, Any]) -> sandbox.SandboxResult:
    mounts = [sandbox.Mount(root / "code", "/work/code"), sandbox.Mount(root / "data", "/work/data"),
              sandbox.Mount(root / "results", "/work/results", writable=True)]
    return sandbox.run(ensure_py_image(), [PYTHON, "-B", f"/work/{entry}"], mounts, workdir="/work", env=RUN_ENV,
                       timeout_s=cfg["timeout_seconds"], memory_mb=cfg["memory_mb"], cpus=2, pids=256)


def local_runner(root: Path, entry: str, cfg: dict[str, Any]) -> sandbox.SandboxResult:
    """NOT a sandbox. For tests and for the agent's own self-check; the verifier never uses it."""
    started = time.monotonic()
    env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": "/tmp", "LANG": "C.UTF-8", **RUN_ENV}
    try:
        proc = subprocess.run([sys.executable, "-B", str(root / entry)], cwd=root, env=env, capture_output=True,
                              timeout=cfg["timeout_seconds"])
        code, out, err, timed_out = proc.returncode, proc.stdout, proc.stderr, False
    except subprocess.TimeoutExpired as exc:
        code, out, err, timed_out = -9, exc.stdout or b"", exc.stderr or b"", True
    return sandbox.SandboxResult(code, out.decode("utf-8", "replace"), err.decode("utf-8", "replace"), timed_out,
                                 round(time.monotonic() - started, 3), [entry])


def read_output(root: Path, rel: str, limit: int) -> bytes:
    """Read a file the untrusted script wrote: no symlinks anywhere on the path, regular file, bounded size."""
    current = root
    for part in rel.split("/"):
        current = current / part
        try:
            st = os.lstat(current)
        except OSError:
            raise Problem(f"{rel} was not produced")
        if stat.S_ISLNK(st.st_mode):
            raise Problem(f"{rel}: symbolic link in the output")
    if not stat.S_ISREG(st.st_mode):
        raise Problem(f"{rel} is not a regular file")
    if st.st_size > limit:
        raise Problem(f"{rel} is too large ({st.st_size} bytes)")
    fd = os.open(current, os.O_RDONLY | os.O_NOFOLLOW)
    try:
        with os.fdopen(fd, "rb", closefd=False) as fh:
            return fh.read(limit + 1)
    finally:
        os.close(fd)


# --------------------------------------------------------------------------- compare

def _is_number(x: Any) -> bool:
    return isinstance(x, (int, float)) and not isinstance(x, bool)


def _close(a: float, b: float, cfg: dict[str, Any]) -> bool:
    if math.isnan(a) or math.isnan(b):
        return math.isnan(a) and math.isnan(b)
    return math.isclose(a, b, rel_tol=cfg["rel_tol"], abs_tol=cfg["abs_tol"])


def _diff_json(a: Any, b: Any, cfg: dict[str, Any], where: str = "$") -> str | None:
    if _is_number(a) and _is_number(b):
        return None if _close(float(a), float(b), cfg) else f"{where}: {a!r} vs {b!r}"
    if type(a) is not type(b):
        return f"{where}: different types"
    if isinstance(a, dict):
        if sorted(a) != sorted(b):
            return f"{where}: different keys"
        for key in sorted(a):
            found = _diff_json(a[key], b[key], cfg, f"{where}.{key}")
            if found:
                return found
        return None
    if isinstance(a, list):
        if len(a) != len(b):
            return f"{where}: different lengths ({len(a)} vs {len(b)})"
        for i, (x, y) in enumerate(zip(a, b)):
            found = _diff_json(x, y, cfg, f"{where}[{i}]")
            if found:
                return found
        return None
    return None if a == b else f"{where}: {a!r:.60} vs {b!r:.60}"


def _rows(data: bytes, delimiter: str) -> list[list[str]]:
    return list(csv.reader(io.StringIO(data.decode("utf-8"), newline=""), delimiter=delimiter))


def _diff_table(a: bytes, b: bytes, delimiter: str, cfg: dict[str, Any]) -> str | None:
    ra, rb = _rows(a, delimiter), _rows(b, delimiter)
    if len(ra) != len(rb):
        return f"different row counts ({len(ra)} vs {len(rb)})"
    for i, (x, y) in enumerate(zip(ra, rb)):
        if len(x) != len(y):
            return f"row {i + 1}: different column counts"
        for j, (c, d) in enumerate(zip(x, y)):
            if c == d:
                continue
            try:
                same = _close(float(c), float(d), cfg)
            except ValueError:
                same = False
            if not same:
                return f"row {i + 1}, column {j + 1}: {c!r:.40} vs {d!r:.40}"
    return None


def compare(rel: str, claimed: bytes, produced: bytes, cfg: dict[str, Any]) -> tuple[str, str]:
    """Return (verdict, detail); verdict is 'exact', 'within tolerance' or 'differs'."""
    if claimed == produced:
        return "exact", ""
    try:
        if rel.lower().endswith(".json"):
            found = _diff_json(json.loads(claimed.decode("utf-8")), json.loads(produced.decode("utf-8")), cfg)
        else:
            found = _diff_table(claimed, produced, "\t" if rel.lower().endswith(".tsv") else ",", cfg)
    except (ValueError, UnicodeDecodeError, csv.Error) as exc:
        return "differs", f"could not be parsed ({exc})"[:200]
    return ("within tolerance", "") if found is None else ("differs", found[:200])


# --------------------------------------------------------------------------- one claim

def check_claim(claim: dict[str, Any], out: Path, work: Path, cfg: dict[str, Any], *,
                runner: Runner | None = None, image: str | None = None) -> ReexecResult:
    """Re-execute one empirical claim. Never raises (T6)."""
    cfg = settings(cfg) if "rel_tol" not in cfg else cfg
    result = ReexecResult(claim_id=str(claim.get("id", "")))
    try:
        result.entry = entry_of(claim, out)
        compared, result.not_compared = evidence_of(claim)
        if not compared:
            raise Problem("no JSON, CSV or TSV result file in the evidence to compare")
        result.inputs = check_inputs(out)
        root = stage(out, work)
        run = (runner or docker_runner)(root, result.entry, cfg)
        result.image = image if image is not None else (py_image_tag() if runner is None else "local (not a sandbox)")
        result.duration_s = run.duration_s
        result.log_tail = (run.stdout + run.stderr)[-1500:]
        if run.timed_out:
            raise Problem(f"the script did not finish within {cfg['timeout_seconds']} seconds")
        if not run.ok:
            raise Problem(f"the script exited with code {run.returncode}")
        failures = []
        for rel in compared:
            claimed = (out / rel).read_bytes()
            entry: dict[str, str] = {"path": rel, "claimed_sha256": sha256_bytes(claimed)}
            try:
                produced = read_output(root, rel, cfg["max_result_bytes"])
                entry["produced_sha256"] = sha256_bytes(produced)
                entry["verdict"], detail = compare(rel, claimed, produced, cfg)
            except Problem as exc:
                entry["verdict"], detail = "missing", str(exc)
            if detail:
                entry["detail"] = detail
            if entry["verdict"] not in ("exact", "within tolerance"):
                failures.append(f"{rel}: {detail or entry['verdict']}")
            result.files.append(entry)
        if failures:
            raise Problem("not reproduced: " + "; ".join(failures[:3]))
        exact = sum(1 for f in result.files if f["verdict"] == "exact")
        result.ok = True
        where = "in the verifier's sandbox with no network" if runner is None else "locally (not a sandbox)"
        result.reason = (f"re-executed {result.entry} {where}; "
                         f"{len(result.files)} result file(s) reproduced ({exact} byte for byte, "
                         f"{len(result.files) - exact} within tolerance); {len(result.inputs)} pinned input file(s)")
    except Problem as exc:
        result.reason = f"re-execution did not confirm the claim: {exc}"
    except Exception as exc:  # noqa: BLE001 - T6: a verifier fault leaves the claim ASSUMED, it never fails the night
        result.reason = f"re-execution could not be completed ({type(exc).__name__}: {str(exc)[:200]})"
    return result


def check_run(run_obj: dict[str, Any], out: Path, work: Path, cfg: dict[str, Any], *,
              runner: Runner | None = None) -> dict[str, ReexecResult]:
    """Re-execute the empirical claims of a run that ask for it, up to ``max_claims``. Never raises."""
    conf = settings(cfg)
    results: dict[str, ReexecResult] = {}
    claims = run_obj.get("claims") if isinstance(run_obj, dict) else None
    if conf["enabled"] is not True or not isinstance(claims, list):
        return results
    wanted = [c for c in claims if isinstance(c, dict) and c.get("kind") == "empirical"
              and c.get("reproduce") is not None and isinstance(c.get("id"), str)]
    for claim in wanted:
        if len(results) >= conf["max_claims"]:
            results[claim["id"]] = ReexecResult(claim["id"], reason=f"not re-executed: more than {conf['max_claims']} "
                                                                    "claims asked for re-execution in one run")
            continue
        results[claim["id"]] = check_claim(claim, out, work / claim["id"], conf, runner=runner)
        log(f"{claim['id']} re-execution: ok={results[claim['id']].ok} ({results[claim['id']].reason[:160]})")
    return results


def main(argv: list[str] | None = None) -> int:
    """Self-check for the agent and for readers: re-run the claims of an output or run folder."""
    ap = argparse.ArgumentParser(prog="engine.reexec")
    ap.add_argument("folder", type=Path, help="a folder holding run.json, code/, results/ and optionally data/")
    ap.add_argument("--docker", action="store_true", help="run in the verifier's sandbox image (needs Docker)")
    ap.add_argument("--work", type=Path, default=None)
    args = ap.parse_args(argv)
    import tempfile
    work = args.work or Path(tempfile.mkdtemp(prefix="viridis-reexec-"))
    conf = dict(DEFAULTS, enabled=True)
    run_obj = load_json(args.folder / "run.json")
    results = check_run(run_obj, args.folder, work, {"tested": conf}, runner=None if args.docker else local_runner)
    for cid, res in sorted(results.items()):
        print(f"{cid}: {'reproduced' if res.ok else 'NOT reproduced'}: {res.reason}")
        if not res.ok and res.log_tail:
            print(res.log_tail)
    if not results:
        print("no empirical claim has a `reproduce` entry")
    return 0 if results and all(r.ok for r in results.values()) else 1


if __name__ == "__main__":
    sys.exit(main())
