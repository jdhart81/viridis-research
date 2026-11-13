"""The Lean pins of a checkout, and two checks that keep them honest (toolchain migration steps 1 and 2).

The pins that actually run are ``lean/lean-toolchain`` and the Mathlib entry of ``lean/lake-manifest.json``.
``config/engine.json`` ``lean.*`` only labels them (certification page, ``REPRODUCE.md``, watchdog).

P1  Labels match what runs: ``consistency`` reports every difference between ``config/engine.json`` ``lean.*``,
    ``lean/lean-toolchain``, ``lean/lakefile.toml`` and ``lean/lake-manifest.json``. Verify refuses to certify
    while there is one, and the record's own workflow checks it on every push.
P2  A run is reproduced at its own pins: ``run_mismatch`` says when a run folder's copies of the pin files
    differ from the checkout's. ``engine.reproduce`` then refuses unless told to use the checkout's pins.
P3  Both checks only read files. Unreadable or missing files are reported, never guessed.

``python3 -m engine.pins --check`` exits 1 when P1 fails.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

from .util import RECORD_ROOT, log

PIN_FILES = ("lean-toolchain", "lake-manifest.json")


def _toolchain(lean_dir: Path) -> str:
    return "".join((lean_dir / "lean-toolchain").read_text(encoding="utf-8").split())


def _manifest_mathlib(lean_dir: Path) -> str:
    manifest = json.loads((lean_dir / "lake-manifest.json").read_text(encoding="utf-8"))
    revs = [p.get("rev") for p in manifest.get("packages", []) if isinstance(p, dict) and p.get("name") == "mathlib"]
    if len(revs) != 1 or not isinstance(revs[0], str):
        raise ValueError("lake-manifest.json must have exactly one mathlib package with a rev")
    return revs[0]


def read(lean_dir: Path) -> dict[str, str]:
    """The pins a ``lean/`` directory (a checkout's, or a run folder's copy) actually selects."""
    return {"toolchain": _toolchain(lean_dir), "mathlib_rev": _manifest_mathlib(lean_dir)}


def _lakefile_mathlib(lean_dir: Path) -> str | None:
    text = (lean_dir / "lakefile.toml").read_text(encoding="utf-8")
    block = re.search(r'\[\[require\]\]\s*(?:(?!\[\[).)*?name\s*=\s*"mathlib"(?:(?!\[\[).)*', text, re.S)
    rev = re.search(r'^\s*rev\s*=\s*"([^"]+)"', block.group(0), re.M) if block else None
    return rev.group(1) if rev else None


def consistency(root: Path, cfg: dict[str, Any] | None = None) -> list[str]:
    """P1: every way the labels and the pin files of ``root`` disagree. Empty when they agree."""
    lean_dir = root / "lean"
    try:
        if cfg is None:
            cfg = json.loads((root / "config" / "engine.json").read_text(encoding="utf-8"))
        actual = read(lean_dir)
        lakefile = _lakefile_mathlib(lean_dir)
        label = cfg["lean"]
        label_tc, label_rev = label["toolchain"], label["mathlib_rev"]
    except (OSError, ValueError, KeyError, TypeError) as exc:
        return [f"pins unreadable: {type(exc).__name__}: {exc}"]
    problems = []
    if label_tc != actual["toolchain"]:
        problems.append(f"config lean.toolchain is {label_tc} but lean/lean-toolchain is {actual['toolchain']}")
    if label_rev != actual["mathlib_rev"]:
        problems.append(f"config lean.mathlib_rev is {label_rev} but lake-manifest.json has {actual['mathlib_rev']}")
    if lakefile != actual["mathlib_rev"]:
        problems.append(f"lakefile.toml requires mathlib {lakefile} but lake-manifest.json has {actual['mathlib_rev']}")
    return problems


def run_mismatch(folder: Path, root: Path) -> str | None:
    """P2: why ``folder`` (a run) cannot be reproduced at ``root``'s pins, or None when the pins are the same.

    A run folder without pin copies gives None: there is nothing to compare, as before this check existed.
    """
    run_lean = folder / "lean"
    if not all((run_lean / name).is_file() for name in PIN_FILES):
        return None
    try:
        ran, here = read(run_lean), read(root / "lean")
    except (OSError, ValueError) as exc:
        return f"pins unreadable: {type(exc).__name__}: {exc}"
    if ran == here:
        return None
    return (f"this run was verified at {ran['toolchain']} with Mathlib {ran['mathlib_rev'][:12]}, but this checkout "
            f"pins {here['toolchain']} with Mathlib {here['mathlib_rev'][:12]}")


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(prog="engine.pins")
    ap.add_argument("--check", action="store_true", help="exit 1 when labels and pin files disagree")
    ap.add_argument("--root", type=Path, default=RECORD_ROOT)
    args = ap.parse_args(argv)
    problems = consistency(args.root)
    for p in problems:
        log(f"pins: {p}")
    if not problems:
        pins = read(args.root / "lean")
        print(f"pins consistent: {pins['toolchain']}, Mathlib {pins['mathlib_rev']}")
    return 1 if (problems and args.check) else 0


if __name__ == "__main__":
    sys.exit(main())
