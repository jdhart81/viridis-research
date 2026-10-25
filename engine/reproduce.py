"""Reproduce a run's certification from its folder: ``python3 -m engine.reproduce runs/<date>_<project>``.

Checks the manifest, recompiles the sealed statements, re-runs the five Lean
stages for every formal claim, and compares the result with
``certification.json``. ``--docker`` uses the verifier's sandbox; the default
runs Lean directly.
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from . import lean_check, package, statements
from .util import RECORD_ROOT as REPO_ROOT, load_json


def default_toolchain() -> Path:
    lean = subprocess.run(["elan", "which", "lean"], capture_output=True, text=True, cwd=REPO_ROOT / "lean")
    if lean.returncode != 0:
        raise SystemExit("elan not found; install it first (see REPRODUCE.md)")
    return Path(lean.stdout.strip()).resolve().parent.parent


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="engine.reproduce")
    ap.add_argument("run_dir", type=Path)
    ap.add_argument("--docker", action="store_true")
    ap.add_argument("--toolchain", type=Path)
    ap.add_argument("--lake-project", type=Path, default=REPO_ROOT / "lean")
    args = ap.parse_args(argv)
    folder = args.run_dir if args.run_dir.is_absolute() else (Path.cwd() / args.run_dir)
    problems = package.verify_manifest(folder)
    print("manifest:", "ok" if not problems else "; ".join(problems))
    cert = load_json(folder / "certification.json")
    run_obj = load_json(folder / "run.json")
    cfg = load_json(REPO_ROOT / "config" / "engine.json")
    env = lean_check.LeanEnv.from_paths(args.toolchain or default_toolchain(), args.lake_project,
                                        cfg["sandbox"]["base_image"], runner="docker" if args.docker else "local")
    work = Path(tempfile.mkdtemp(prefix="viridis-reproduce-"))
    mismatches = 0
    try:
        olean_root = work / "sealed"
        modules = {statements.module_for(s) for s in statements.sealed_ids(REPO_ROOT)}
        registry = statements.load_registry(REPO_ROOT)["statements"]
        for sid in sorted(registry, key=lambda s: (registry[s].get("sealed_at", ""), s)):
            st = statements.load_sealed(sid, REPO_ROOT)
            compiled = lean_check.compile_statement(env, st.as_source(), work / sid, olean_root=olean_root,
                                                    allowed_imports=modules - {st.module})
            if not compiled.ok:
                print(f"sealed statement {sid} failed to compile: {compiled.messages}")
                return 2
        for claim in run_obj.get("claims", []):
            if claim["kind"] != "formal":
                continue
            sid = claim["statement_id"]
            source_file = folder / "lean" / sid / "Statement.lean"
            stmt = lean_check.StatementSource(sid, statements.module_for(sid), statements.constant_for(sid),
                                              source_file.read_text(encoding="utf-8"))
            compiled = lean_check.CompiledStatement(stmt, olean_root, True)
            result = lean_check.check_candidate(env, compiled, (folder / claim["proof_file"]).read_text(encoding="utf-8"),
                                                work / f"claim-{claim['id']}")
            recorded = cert["labels"][claim["id"]]["label"]
            reproduced = "PROVEN" if result.ok else "ASSUMED"
            same = recorded == reproduced
            mismatches += 0 if same else 1
            print(f"{claim['id']} {sid}: recorded {recorded}, reproduced {reproduced} (stage {result.stage})"
                  + ("" if same else "  <-- MISMATCH"))
    finally:
        shutil.rmtree(work, ignore_errors=True)
    ok = not problems and mismatches == 0
    print("REPRODUCED" if ok else "NOT REPRODUCED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
