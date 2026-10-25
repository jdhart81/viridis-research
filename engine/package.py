"""Run folder assembly, manifest and deterministic reproduce zip (I8)."""
from __future__ import annotations

import io
import shutil
import zipfile
from pathlib import Path
from typing import Any

from .util import canonical_json, sha256_bytes, sha256_file

AGENT_ITEMS = ("run.json", "notes.md", "announcement.md", "data_pins.json", "paper", "proofs", "proposals", "code",
               "results")
ZIP_DATE = (1980, 1, 1, 0, 0, 0)


def copy_agent_outputs(artifact_out: Path, folder: Path) -> None:
    for name in AGENT_ITEMS:
        src = artifact_out / name
        if src.is_file() and not src.is_symlink():
            shutil.copyfile(src, folder / name)
        elif src.is_dir() and not src.is_symlink():
            for path in sorted(src.rglob("*")):
                if path.is_symlink() or not path.is_file():
                    continue
                target = folder / path.relative_to(artifact_out)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)


def reproduce_md(*, run_dir: str, date: str, commit: str, repository: str, toolchain: str, mathlib_rev: str,
                 formal: list[dict[str, Any]]) -> str:
    lines = [f"# Reproduce `{run_dir}`", "",
             f"Run date {date}. Verified by engine version `{commit[:12]}`; the verifier kit in this repository",
             "(`engine/lean_check.py`, `engine/reproduce.py`) re-runs every check.", "",
             "## Everything at once", "",
             "```bash",
             f"git clone https://github.com/{repository} && cd {repository.split('/')[1]}",
             "# Lean toolchain and the Mathlib cache (pins in lean/lean-toolchain and lean/lake-manifest.json)",
             "curl -sSfL https://elan.lean-lang.org/elan-init.sh | sh -s -- -y --default-toolchain none",
             "(cd lean && lake exe cache get)",
             f"python3 -m engine.reproduce {run_dir}",
             "```", "",
             "`engine.reproduce` checks `MANIFEST.sha256`, re-runs every Lean check below, and reports the result",
             "for each claim. Add `--docker` to run the checks in the same sandbox the verifier uses.", "",
             "## Lean checks", "",
             f"- Toolchain `{toolchain}`, Mathlib `{mathlib_rev}`.",
             "- `lean/` in this folder holds each sealed statement module, the candidate proof, and the check file",
             "  the verifier generated (`ViridisCheck.lean`), which asserts the statement match and prints the axioms.", ""]
    if not formal:
        lines.append("This run made no formal claims.")
    for item in formal:
        lines += [f"### {item['claim_id']}: `{item['statement_id']}` ({item['label']})", "",
                  f"- Statement: `lean/{item['statement_id']}/Statement.lean` (sha256 `{item['statement_sha256']}`)",
                  f"- Candidate: `proofs/{item['statement_id']}.lean` (sha256 `{item['candidate_sha256']}`)",
                  f"- Verifier result: stage `{item['stage']}`, axioms `{', '.join(item.get('axioms', [])) or 'n/a'}`", ""]
    lines += ["## Paper", "",
              "`paper.pdf` is the verifier's certification page followed by the compiled paper. To rebuild the paper,",
              "run `latexmk -pdf -no-shell-escape main.tex` in `paper/`, with `docker/tex/viridis-lean.sty` on",
              "`TEXINPUTS` (the verifier builds it in `docker/tex/Dockerfile`).", ""]
    return "\n".join(lines)


def files_sorted(folder: Path) -> list[tuple[str, Path]]:
    """Regular files under ``folder`` ordered by their POSIX relative path (byte order)."""
    items = [(p.relative_to(folder).as_posix(), p) for p in folder.rglob("*") if p.is_file() and not p.is_symlink()]
    return sorted(items, key=lambda item: item[0].encode("utf-8"))


def manifest(folder: Path) -> str:
    rows = []
    for rel, path in files_sorted(folder):
        if rel == "MANIFEST.sha256":
            continue
        rows.append(f"{sha256_file(path)}  {rel}")
    return "\n".join(rows) + "\n"


def write_manifest(folder: Path) -> str:
    text = manifest(folder)
    (folder / "MANIFEST.sha256").write_text(text, encoding="utf-8")
    return sha256_bytes(text.encode("utf-8"))


def verify_manifest(folder: Path) -> list[str]:
    problems = []
    listed: dict[str, str] = {}
    for line in (folder / "MANIFEST.sha256").read_text(encoding="utf-8").splitlines():
        digest, _, rel = line.partition("  ")
        listed[rel] = digest
    for rel, digest in listed.items():
        path = folder / rel
        if not path.is_file():
            problems.append(f"missing {rel}")
        elif sha256_file(path) != digest:
            problems.append(f"changed {rel}")
    for path in folder.rglob("*"):
        rel = path.relative_to(folder).as_posix()
        if path.is_file() and rel not in listed and rel not in ("MANIFEST.sha256", "endorsements.json"):
            problems.append(f"unlisted {rel}")
    return problems


def deterministic_zip(folder: Path, prefix: str) -> bytes:
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w") as zf:
        for rel, path in files_sorted(folder):
            if rel == "endorsements.json":
                continue
            info = zipfile.ZipInfo(f"{prefix}/{rel}", date_time=ZIP_DATE)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            info.create_system = 3
            zf.writestr(info, path.read_bytes(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    return buf.getvalue()


def write_json_file(path: Path, obj: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(canonical_json(obj), encoding="utf-8")
