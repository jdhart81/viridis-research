"""Sealed statements: the fixed targets that PROVEN is measured against.

A statement is sealed when ``statements/registry.json`` lists it with the
SHA-256 of its file on main, and a recorded ``yes`` decision with a matching
``seal_statement`` effect exists. Seals are never edited. A changed statement
is a new statement with a new ID.
"""
from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .lean_check import StatementSource
from .util import RECORD_ROOT, EngineError, load_json, sha256_file

REGISTRY = Path("statements/registry.json")
REGISTRY_SCHEMA = "viridis-statement-registry-v1"
STATEMENT_ID = re.compile(r"[A-Z][A-Za-z0-9]{0,15}\.[A-Z][A-Za-z0-9]{0,63}\Z")


def check_id(statement_id: str) -> str:
    if not isinstance(statement_id, str) or not STATEMENT_ID.match(statement_id):
        raise EngineError("statement_id", repr(statement_id))
    return statement_id


def module_for(statement_id: str) -> str:
    return "ViridisStatements." + check_id(statement_id)


def path_for(statement_id: str) -> str:
    return "lean/" + module_for(statement_id).replace(".", "/") + ".lean"


def constant_for(statement_id: str) -> str:
    return module_for(statement_id) + ".Statement"


@dataclass(frozen=True)
class SealedStatement:
    statement_id: str
    module: str
    constant: str
    path: str
    sha256: str
    decision: str
    sealed_at: str
    project: str
    probe: dict[str, str]
    source: str

    @property
    def trivial(self) -> bool:
        return any(v == "closed" for v in self.probe.values())

    def as_source(self) -> StatementSource:
        return StatementSource(self.statement_id, self.module, self.constant, self.source)


def empty_registry() -> dict[str, Any]:
    return {"schema": REGISTRY_SCHEMA, "statements": {}}


def load_registry(root: Path = RECORD_ROOT) -> dict[str, Any]:
    path = root / REGISTRY
    if not path.exists():
        return empty_registry()
    reg = load_json(path)
    if reg.get("schema") != REGISTRY_SCHEMA or not isinstance(reg.get("statements"), dict):
        raise EngineError("registry_schema", str(path))
    return reg


def load_sealed(statement_id: str, root: Path = RECORD_ROOT) -> SealedStatement:
    check_id(statement_id)
    entry = load_registry(root)["statements"].get(statement_id)
    if entry is None:
        raise EngineError("not_sealed", statement_id)
    expected = {"module": module_for(statement_id), "constant": constant_for(statement_id), "path": path_for(statement_id)}
    for key, value in expected.items():
        if entry.get(key) != value:
            raise EngineError("registry_entry", f"{statement_id}.{key}")
    file = root / entry["path"]
    if not file.is_file():
        raise EngineError("seal_missing_file", entry["path"])
    actual = sha256_file(file)
    if actual != entry["sha256"]:
        raise EngineError("seal_mismatch", f"{statement_id}: file sha256 {actual} != sealed {entry['sha256']}")
    decision = entry.get("decision", "")
    record_path = root / "decisions" / "records" / f"{decision}.json"
    if not re.fullmatch(r"D-\d{3,5}", decision) or not record_path.is_file():
        raise EngineError("seal_unauthorized", f"{statement_id}: no decision record {decision!r}")
    record = load_json(record_path)
    effect = record.get("effect") or {}
    if (record.get("answer") != "yes" or effect.get("type") != "seal_statement"
            or effect.get("statement_id") != statement_id or effect.get("sha256") != entry["sha256"]):
        raise EngineError("seal_unauthorized", f"{statement_id}: decision {decision} does not approve this seal")
    return SealedStatement(statement_id=statement_id, module=entry["module"], constant=entry["constant"],
                           path=entry["path"], sha256=entry["sha256"], decision=decision,
                           sealed_at=entry.get("sealed_at", ""), project=entry.get("project", ""),
                           probe=dict(entry.get("probe", {})), source=file.read_text(encoding="utf-8"))


def sealed_ids(root: Path = RECORD_ROOT) -> list[str]:
    return sorted(load_registry(root)["statements"])
