"""Small, dependency-free helpers shared by every engine module."""
from __future__ import annotations

import hashlib
import json
import os
import re
import sys
from pathlib import Path, PurePosixPath
from typing import Any, Iterable

REPO_ROOT = Path(__file__).resolve().parent.parent
# The research record (public repo). The engine (private repo) checks it out separately and points
# VIRIDIS_RECORD at it; with one combined checkout (tests, the public verifier kit) both are the same.
RECORD_ROOT = Path(os.environ["VIRIDIS_RECORD"]).resolve() if os.environ.get("VIRIDIS_RECORD") else REPO_ROOT

SAFE_COMPONENT = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]{0,127}\Z")


class EngineError(RuntimeError):
    """A failure with a short, machine-readable reason code."""

    def __init__(self, reason: str, detail: str = ""):
        super().__init__(f"{reason}: {detail}" if detail else reason)
        self.reason = reason
        self.detail = detail


def canonical_json(obj: Any) -> str:
    """Stable JSON: sorted keys, two-space indent, trailing newline."""
    return json.dumps(obj, sort_keys=True, indent=2, ensure_ascii=False) + "\n"


def load_json(path: Path | str) -> Any:
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def write_json(path: Path | str, obj: Any) -> None:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(canonical_json(obj), encoding="utf-8")
    os.replace(tmp, path)


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path | str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def safe_relpath(rel: str) -> PurePosixPath:
    """Validate a repository-relative POSIX path.

    Rejects absolute paths, empty or dot components, hidden names, and any
    character outside ``[A-Za-z0-9._-]``. Returns the normalised path.
    """
    if not isinstance(rel, str) or not rel or len(rel) > 512:
        raise EngineError("bad_path", repr(rel))
    if rel.startswith("/") or "\\" in rel or "\x00" in rel:
        raise EngineError("bad_path", rel)
    parts = rel.split("/")
    for part in parts:
        if not SAFE_COMPONENT.match(part) or part in (".", ".."):
            raise EngineError("bad_path", rel)
    return PurePosixPath(*parts)


def is_within(path: Path, root: Path) -> bool:
    try:
        path.resolve().relative_to(root.resolve())
        return True
    except ValueError:
        return False


def log(msg: str) -> None:
    print(f"[viridis] {msg}", file=sys.stderr, flush=True)


def gh_output(**pairs: str) -> None:
    """Write step outputs for GitHub Actions (no-op outside Actions)."""
    target = os.environ.get("GITHUB_OUTPUT")
    lines = []
    for key, value in pairs.items():
        value = str(value)
        if "\n" in value:
            raise EngineError("bad_output", key)
        lines.append(f"{key}={value}")
    if target:
        with open(target, "a", encoding="utf-8") as fh:
            fh.write("\n".join(lines) + "\n")
    else:
        for line in lines:
            log(f"output {line}")


def gh_summary(markdown: str) -> None:
    target = os.environ.get("GITHUB_STEP_SUMMARY")
    if target:
        with open(target, "a", encoding="utf-8") as fh:
            fh.write(markdown.rstrip() + "\n")


def chunks(items: Iterable[Any], size: int) -> Iterable[list[Any]]:
    batch: list[Any] = []
    for item in items:
        batch.append(item)
        if len(batch) == size:
            yield batch
            batch = []
    if batch:
        yield batch
