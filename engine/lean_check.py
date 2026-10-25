"""Machine checking of formal claims against sealed statements (I5, I6).

A candidate proof earns PROVEN only when every stage passes:

1. source  - the candidate passes the denylist and import allowlist;
2. compile - the candidate compiles in the sandbox against the pinned toolchain,
             Mathlib and the sealed statement module (compiled from main);
3. match   - a check file generated here states
             ``theorem viridis_statement_match : <Statement> := Candidate.main``
             and compiles;
4. axioms  - ``Lean.collectAxioms`` reports only propext, Classical.choice and
             Quot.sound, printed at a line this module controls;
5. replay  - ``leanchecker`` replays every declaration of the candidate module
             through the kernel.

The denylist is defence in depth. The guarantees come from stages 3-5.
"""
from __future__ import annotations

import json
import os
import re
import shutil
import tempfile
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any

from . import sandbox
from .util import EngineError, sha256_bytes

STANDARD_AXIOMS = ("Classical.choice", "Quot.sound", "propext")
CONSTANT = re.compile(r"[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)*\Z")
MODULE = CONSTANT

COMMAND_DENY = frozenset({
    "axiom", "unsafe", "partial", "opaque", "macro", "macro_rules", "syntax", "elab", "elab_rules",
    "notation", "infix", "infixl", "infixr", "prefix", "postfix", "declare_syntax_cat",
    "run_cmd", "run_elab", "run_meta", "initialize", "builtin_initialize", "simproc", "dsimproc",
    "builtin_simproc", "builtin_dsimproc", "sorry", "admit", "native_decide", "native", "prelude",
    "module", "implemented_by", "extern", "unsafeCast", "unsafeIO", "unsafeBaseIO", "unsafeEIO",
    "import_all", "meta",
})
NAME_COMPONENT_DENY = frozenset({
    "ofReduceBool", "reduceBool", "ofReduceNat", "reduceNat", "trustCompiler", "sorryAx",
    "unsafeCast", "addDeclWithoutChecking", "addDeclCore", "skipKernelTC", "implemented_by",
    "enableInitializersExecution",
})
HASH_COMMAND_DENY = frozenset({"#eval", "#exit", "#reduce", "#exec", "#run"})
OPTION_ALLOW_EXACT = frozenset({
    "maxHeartbeats", "maxRecDepth", "maxSynthPendingDepth", "autoImplicit", "relaxedAutoImplicit",
    "synthInstance.maxHeartbeats", "synthInstance.maxSize",
})
OPTION_ALLOW_PREFIX = ("linter.", "pp.", "trace.", "backward.", "tactic.")
ATTRIBUTE_ALLOW = frozenset({
    "simp", "reducible", "irreducible", "semireducible", "inline", "ext", "norm_cast", "push_cast",
    "simps", "aesop", "grind", "gcongr", "local", "scoped", "instance", "induction_eliminator",
    "cases_eliminator", "symm", "refl", "trans", "mono", "elab_as_elim", "nolint", "-simp",
})
IDENT_SPLIT = re.compile(r"[\s()\[\]{},:;@$%^&*+\-=<>/\\|~`\"⟨⟩←→↔∀∃λ·∘×≤≥≠¬∧∨⁻¹▸]+")
CHAR_LITERAL = re.compile(r"'(?:\\(?:[nrt\\'\"0]|x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4})|[^\\'\n])'")


# --------------------------------------------------------------------------- source

def strip_comments_and_strings(src: str) -> str:
    """Remove comments and string/char literals, keeping line structure."""
    out: list[str] = []
    i, n, depth = 0, len(src), 0
    while i < n:
        c = src[i]
        if depth:
            if src.startswith("/-", i):
                depth += 1
                i += 2
            elif src.startswith("-/", i):
                depth -= 1
                i += 2
                if depth == 0:
                    out.append(" ")
            else:
                if c == "\n":
                    out.append("\n")
                i += 1
            continue
        if src.startswith("/-", i):
            depth = 1
            i += 2
            continue
        if src.startswith("--", i):
            j = src.find("\n", i)
            i = n if j < 0 else j
            continue
        if c == "«":
            j = src.find("»", i + 1)
            if j < 0:
                raise EngineError("lean_source", "unterminated «identifier»")
            out.append("«q»")  # a quoted identifier is only a name; its text cannot run
            i = j + 1
            continue
        if c == "r" and (i == 0 or not (src[i - 1].isalnum() or src[i - 1] in "_'.!?")):
            m = re.match(r'r(#*)"', src[i:])
            if m:
                closing = '"' + m.group(1)
                j = src.find(closing, i + len(m.group(0)))
                if j < 0:
                    raise EngineError("lean_source", "unterminated raw string")
                out.append('""')
                i = j + len(closing)
                continue
        if c == '"':
            i += 1
            while i < n and src[i] != '"':
                i += 2 if src[i] == "\\" else 1
            if i >= n:
                raise EngineError("lean_source", "unterminated string literal")
            i += 1
            out.append('""')
            continue
        if c == "'" and (i == 0 or not (src[i - 1].isalnum() or src[i - 1] in "_'.!?")):
            m = CHAR_LITERAL.match(src, i)
            if m:
                out.append("' '")
                i = m.end()
                continue
        out.append(c)
        i += 1
    if depth:
        raise EngineError("lean_source", "unterminated block comment")
    return "".join(out)


def header_imports(stripped: str) -> tuple[list[str], list[str]]:
    """Return (imports in the header, violations about imports)."""
    imports: list[str] = []
    problems: list[str] = []
    in_header = True
    for lineno, line in enumerate(stripped.splitlines(), 1):
        text = line.strip()
        if not text:
            continue
        m = re.fullmatch(r"import\s+([A-Za-z0-9_.«»]+)", text)
        if m and in_header:
            imports.append(m.group(1))
            continue
        in_header = False
        if re.search(r"(^|\s)import(\s|$)", text):
            problems.append(f"line {lineno}: import outside the header")
    return imports, problems


def source_violations(src: str, *, allowed_imports: set[str], allow_mathlib: bool,
                      require_candidate: bool) -> list[str]:
    try:
        stripped = strip_comments_and_strings(src)
    except EngineError as exc:
        return [exc.detail]
    problems: list[str] = []
    imports, import_problems = header_imports(stripped)
    problems += import_problems
    for module in imports:
        ok = module in allowed_imports or (allow_mathlib and (module == "Mathlib" or module.startswith("Mathlib.")))
        if not ok:
            problems.append(f"import not allowed: {module}")
    for lineno, line in enumerate(stripped.splitlines(), 1):
        for token in IDENT_SPLIT.split(line):
            if not token:
                continue
            if token in COMMAND_DENY:
                problems.append(f"line {lineno}: forbidden keyword `{token}`")
                continue
            for part in token.split("."):
                if part in NAME_COMPONENT_DENY:
                    problems.append(f"line {lineno}: forbidden name `{token}`")
                    break
        for hash_cmd in re.findall(r"#[A-Za-z_]+", line):
            if hash_cmd in HASH_COMMAND_DENY:
                problems.append(f"line {lineno}: forbidden command `{hash_cmd}`")
        for option in re.findall(r"\bset_option\s+([A-Za-z0-9_.]+)", line):
            if option not in OPTION_ALLOW_EXACT and not option.startswith(OPTION_ALLOW_PREFIX):
                problems.append(f"line {lineno}: option not allowed: {option}")
        for body in re.findall(r"@\[([^\]]*)\]", line) + re.findall(r"\battribute\s*\[([^\]]*)\]", line):
            for entry in body.split(","):
                words = entry.strip().split()
                while words and words[0] in ("local", "scoped"):
                    words = words[1:]
                name = words[0] if words else ""
                if name and name not in ATTRIBUTE_ALLOW:
                    problems.append(f"line {lineno}: attribute not allowed: {name}")
    if require_candidate:
        if not re.search(r"\bnamespace\s+Candidate\b", stripped) and not re.search(r"\b(theorem|lemma)\s+Candidate\.main\b", stripped):
            problems.append("missing `namespace Candidate`")
        if not re.search(r"\b(theorem|lemma)\s+(Candidate\.)?main\b", stripped):
            problems.append("missing `theorem main`")
    seen: set[str] = set()
    unique = []
    for p in problems:
        if p not in seen:
            seen.add(p)
            unique.append(p)
    return unique


# --------------------------------------------------------------------------- environment

TOOLCHAIN_IN_SANDBOX = "/opt/viridis/toolchain"
PACKAGES_IN_SANDBOX = "/opt/viridis/packages"


@dataclass(frozen=True)
class LeanEnv:
    """Host locations of the pinned toolchain and the built Mathlib packages.

    Inside the sandbox both are mounted read-only at fixed paths, so the
    LEAN_PATH the sandbox sees never depends on where the host keeps them.
    """
    toolchain: Path
    packages_dir: Path
    image: str
    memory_mb: int = 8192
    cpus: float = 4.0
    timeout_s: int = 1800
    runner: str = "docker"  # "local" only for engine.agent_check and Docker-less tests

    @property
    def lean(self) -> str:
        return f"{TOOLCHAIN_IN_SANDBOX}/bin/lean"

    @property
    def leanchecker(self) -> str:
        return f"{TOOLCHAIN_IN_SANDBOX}/bin/leanchecker"

    def library_dirs(self) -> list[str]:
        dirs = sorted(p.relative_to(self.packages_dir).as_posix()
                      for p in self.packages_dir.glob("*/.lake/build/lib/lean") if p.is_dir())
        if not dirs:
            raise EngineError("lean_env", f"no built packages under {self.packages_dir}")
        return [f"{PACKAGES_IN_SANDBOX}/{d}" for d in dirs] + [f"{TOOLCHAIN_IN_SANDBOX}/lib/lean"]

    def base_mounts(self) -> list[sandbox.Mount]:
        return [sandbox.Mount(self.toolchain, TOOLCHAIN_IN_SANDBOX),
                sandbox.Mount(self.packages_dir, PACKAGES_IN_SANDBOX)]

    def run(self, argv: list[str], mounts: list[sandbox.Mount], extra_paths: list[str],
            timeout_s: int | None = None) -> sandbox.SandboxResult:
        lean_path = ":".join(self.library_dirs() + extra_paths)
        env = {"LEAN_PATH": lean_path, "LEAN_SYSROOT": TOOLCHAIN_IN_SANDBOX,
               "PATH": f"{TOOLCHAIN_IN_SANDBOX}/bin:/usr/bin:/bin", "LEAN_NUM_THREADS": str(int(self.cpus))}
        if self.runner == "local":
            return sandbox.run_local(argv, self.base_mounts() + mounts, env=env,
                                     timeout_s=timeout_s or self.timeout_s)
        if self.runner != "docker":
            raise EngineError("lean_env", f"unknown runner {self.runner}")
        return sandbox.run(self.image, argv, self.base_mounts() + mounts, workdir="/tmp", env=env,
                           timeout_s=timeout_s or self.timeout_s, memory_mb=self.memory_mb,
                           cpus=self.cpus, pids=1024, tmpfs_mb=1024)

    @classmethod
    def from_paths(cls, toolchain: str | Path, lake_project: str | Path, image: str, **kw: Any) -> "LeanEnv":
        toolchain = Path(toolchain).resolve()
        packages = (Path(lake_project) / ".lake" / "packages").resolve()
        if not (toolchain / "bin" / "lean").exists():
            raise EngineError("lean_env", f"no lean binary in {toolchain}")
        if not packages.is_dir():
            raise EngineError("lean_env", f"no packages dir {packages}")
        return cls(toolchain=toolchain, packages_dir=packages, image=image, **kw)


def parse_json_messages(stdout: str) -> list[dict[str, Any]]:
    messages = []
    for line in stdout.splitlines():
        line = line.strip()
        if not line.startswith("{"):
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(obj, dict) and "severity" in obj:
            messages.append(obj)
    return messages


def _errors(messages: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [m for m in messages if m.get("severity") == "error"]


def _trim(messages: list[dict[str, Any]], limit: int = 20) -> list[dict[str, Any]]:
    out = []
    for m in messages[:limit]:
        pos = m.get("pos") or {}
        out.append({"severity": m.get("severity"), "line": pos.get("line"), "column": pos.get("column"),
                    "text": str(m.get("data", ""))[:2000]})
    return out


def _writable_dir(path: Path) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    os.chmod(path, 0o777)
    return path


def _module_relpath(module: str) -> Path:
    if not MODULE.match(module):
        raise EngineError("lean_module", module)
    return Path(*module.split("."))


# --------------------------------------------------------------------------- statements

@dataclass(frozen=True)
class StatementSource:
    statement_id: str
    module: str
    constant: str
    source: str

    @property
    def sha256(self) -> str:
        return sha256_bytes(self.source.encode("utf-8"))


@dataclass
class CompiledStatement:
    statement: StatementSource
    olean_root: Path
    ok: bool
    messages: list[dict[str, Any]] = field(default_factory=list)
    violations: list[str] = field(default_factory=list)
    duration_s: float = 0.0
    deps_root: Path | None = None

    def mounts(self) -> tuple[list[sandbox.Mount], list[str]]:
        """Read-only mounts (and LEAN_PATH entries) exposing this module and its dependencies."""
        mounts = [sandbox.Mount(self.olean_root, "/sealed")]
        paths = ["/sealed"]
        if self.deps_root is not None:
            mounts.append(sandbox.Mount(self.deps_root, "/deps"))
            paths.append("/deps")
        return mounts, paths


def statement_shape_problems(statement: StatementSource) -> list[str]:
    stripped = strip_comments_and_strings(statement.source)
    problems = []
    if not re.search(rf"\bnamespace\s+{re.escape(statement.module)}\b", stripped):
        problems.append(f"missing `namespace {statement.module}`")
    if not re.search(r"\bdef\s+Statement\s*:\s*Prop\b", stripped):
        problems.append("missing `def Statement : Prop`")
    return problems


def compile_statement(env: LeanEnv, statement: StatementSource, workdir: Path, *,
                      olean_root: Path | None = None, deps_root: Path | None = None,
                      allowed_imports: set[str] | frozenset[str] = frozenset()) -> CompiledStatement:
    """Compile a statement module (sealed or proposed) in the sandbox.

    ``olean_root`` collects the output (shared when compiling every sealed
    statement in seal order, so later ones may import earlier ones).
    ``deps_root`` is a read-only tree of already-sealed modules.
    """
    if not CONSTANT.match(statement.constant) or statement.constant != statement.module + ".Statement":
        raise EngineError("lean_statement", f"bad constant {statement.constant}")
    try:
        violations = source_violations(statement.source, allowed_imports=set(allowed_imports), allow_mathlib=True,
                                       require_candidate=False) + statement_shape_problems(statement)
    except EngineError as exc:
        violations = [exc.detail]
    rel = _module_relpath(statement.module)
    src_root = workdir / "statement_src"
    out_root = _writable_dir(olean_root or (workdir / "statement_olean"))
    target = src_root / rel.with_suffix(".lean")
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(statement.source, encoding="utf-8")
    _writable_dir(out_root / rel.parent)
    if violations:
        return CompiledStatement(statement, out_root, False, violations=violations, deps_root=deps_root)
    olean = f"/out/{rel.with_suffix('.olean').as_posix()}"
    ilean = f"/out/{rel.with_suffix('.ilean').as_posix()}"
    mounts = [sandbox.Mount(src_root, "/src"), sandbox.Mount(out_root, "/out", writable=True)]
    extra = ["/out"]
    if deps_root is not None:
        mounts.append(sandbox.Mount(deps_root, "/deps"))
        extra.append("/deps")
    result = env.run([env.lean, "--json", "-R", "/src", "-o", olean, "-i", ilean,
                      f"/src/{rel.with_suffix('.lean').as_posix()}"], mounts, extra_paths=extra)
    messages = parse_json_messages(result.stdout)
    ok = result.ok and not _errors(messages) and (out_root / rel.with_suffix(".olean")).exists()
    if not result.ok and not messages:
        messages = [{"severity": "error", "data": (result.stderr or result.stdout)[-2000:] or ("timeout" if result.timed_out else "failed")}]
    return CompiledStatement(statement, out_root, ok, _trim(_errors(messages) or messages), [], result.duration_s,
                             deps_root=deps_root)


def probe_statement(env: LeanEnv, compiled: CompiledStatement, tactics: list[str], workdir: Path,
                    timeout_s: int = 300) -> dict[str, str]:
    """Try each probe tactic on the statement. 'closed' means the statement is trivial."""
    if not compiled.ok:
        return {t: "error" for t in tactics}
    st = compiled.statement
    lines = [f"import {st.module}", "", "set_option maxHeartbeats 200000", ""]
    ranges: dict[str, tuple[int, int]] = {}
    for idx, tactic in enumerate(tactics):
        if not re.fullmatch(r"[a-z_]+", tactic):
            raise EngineError("lean_probe", tactic)
        start = len(lines) + 1
        lines += [f"theorem viridis_probe_{idx} : {st.constant} := by",
                  f"  (try unfold {st.constant})",
                  f"  {tactic}", ""]
        ranges[tactic] = (start, len(lines))
    src_root = workdir / "probe_src"
    src_root.mkdir(parents=True, exist_ok=True)
    (src_root / "ViridisProbe.lean").write_text("\n".join(lines) + "\n", encoding="utf-8")
    dep_mounts, dep_paths = compiled.mounts()
    result = env.run([env.lean, "--json", "-R", "/src", "/src/ViridisProbe.lean"],
                     [sandbox.Mount(src_root, "/src")] + dep_mounts, extra_paths=dep_paths, timeout_s=timeout_s)
    if result.timed_out:
        return {t: "timeout" for t in tactics}
    messages = parse_json_messages(result.stdout)
    if not messages and result.returncode != 0:
        return {t: "error" for t in tactics}
    outcome: dict[str, str] = {}
    for tactic, (start, end) in ranges.items():
        failed = any(start <= ((m.get("pos") or {}).get("line") or 0) <= end for m in _errors(messages))
        outcome[tactic] = "not_closed" if failed else "closed"
    return outcome


# --------------------------------------------------------------------------- candidates

@dataclass
class LeanCheckResult:
    statement_id: str
    candidate_sha256: str
    statement_sha256: str
    ok: bool = False
    stage: str = "source"
    violations: list[str] = field(default_factory=list)
    axioms: list[str] = field(default_factory=list)
    messages: list[dict[str, Any]] = field(default_factory=list)
    durations: dict[str, float] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return asdict(self)


CHECK_TEMPLATE = """import {module}
import Candidate
import Lean

open Lean Elab Command

elab "#viridis_axioms " id:ident : command => do
  let n := id.getId
  let axs ← liftCoreM (Lean.collectAxioms n)
  let names := axs.toList.map (fun a => a.toString)
  let s := ",".intercalate names
  logInfo m!"VIRIDIS_AXIOMS {{s}}"

theorem viridis_statement_match : {constant} := Candidate.main

#viridis_axioms Candidate.main
#viridis_axioms viridis_statement_match
"""


def check_candidate(env: LeanEnv, compiled: CompiledStatement, candidate_source: str, workdir: Path,
                    *, enforce_source: bool = True) -> LeanCheckResult:
    """Run all five stages. ``enforce_source=False`` exists only so tests can
    show that the deeper stages catch what the denylist would have caught."""
    st = compiled.statement
    res = LeanCheckResult(statement_id=st.statement_id,
                          candidate_sha256=sha256_bytes(candidate_source.encode("utf-8")),
                          statement_sha256=st.sha256)
    if not compiled.ok:
        res.stage = "statement"
        res.messages = compiled.messages
        res.violations = compiled.violations
        return res
    res.violations = source_violations(candidate_source, allowed_imports={st.module}, allow_mathlib=True,
                                       require_candidate=True)
    if res.violations and enforce_source:
        return res

    # compile
    res.stage = "compile"
    cand_src = workdir / "candidate_src"
    cand_src.mkdir(parents=True, exist_ok=True)
    (cand_src / "Candidate.lean").write_text(candidate_source, encoding="utf-8")
    cand_out = _writable_dir(workdir / "candidate_olean")
    dep_mounts, dep_paths = compiled.mounts()
    mounts = [sandbox.Mount(cand_src, "/src"), sandbox.Mount(cand_out, "/out", writable=True)] + dep_mounts
    result = env.run([env.lean, "--json", "-R", "/src", "-o", "/out/Candidate.olean", "-i", "/out/Candidate.ilean",
                      "/src/Candidate.lean"], mounts, extra_paths=dep_paths + ["/out"])
    res.durations["compile"] = result.duration_s
    messages = parse_json_messages(result.stdout)
    if result.timed_out or not result.ok or _errors(messages) or not (cand_out / "Candidate.olean").exists():
        res.messages = _trim(_errors(messages)) or [{"severity": "error", "text": ("timeout" if result.timed_out else (result.stderr or "compile failed")[-2000:])}]
        return res

    # match + axioms
    res.stage = "match"
    check_src = workdir / "check_src"
    check_src.mkdir(parents=True, exist_ok=True)
    check_text = CHECK_TEMPLATE.format(module=st.module, constant=st.constant)
    (check_src / "ViridisCheck.lean").write_text(check_text, encoding="utf-8")
    check_lines = check_text.splitlines()
    axiom_lines = {i + 1 for i, line in enumerate(check_lines) if line.startswith("#viridis_axioms ")}
    mounts = [sandbox.Mount(check_src, "/src"), sandbox.Mount(cand_out, "/cand")] + dep_mounts
    result = env.run([env.lean, "--json", "-R", "/src", "/src/ViridisCheck.lean"], mounts,
                     extra_paths=dep_paths + ["/cand"])
    res.durations["check"] = result.duration_s
    messages = parse_json_messages(result.stdout)
    if result.timed_out or not result.ok or _errors(messages):
        res.messages = _trim(_errors(messages)) or [{"severity": "error", "text": ("timeout" if result.timed_out else (result.stderr or "check failed")[-2000:])}]
        return res
    reports = [m for m in messages if m.get("severity") == "information"
               and str(m.get("data", "")).startswith("VIRIDIS_AXIOMS")
               and (m.get("pos") or {}).get("line") in axiom_lines]
    if len(reports) != len(axiom_lines):
        res.stage = "axioms"
        res.messages = [{"severity": "error", "text": f"expected {len(axiom_lines)} axiom reports, got {len(reports)}"}]
        return res
    res.stage = "axioms"
    found: set[str] = set()
    for report in reports:
        payload = str(report["data"])[len("VIRIDIS_AXIOMS"):].strip()
        found |= {a for a in payload.split(",") if a}
    res.axioms = sorted(found)
    disallowed = sorted(found - set(STANDARD_AXIOMS))
    if disallowed:
        res.messages = [{"severity": "error", "text": f"disallowed axioms: {', '.join(disallowed)}"}]
        return res

    # kernel replay
    res.stage = "replay"
    result = env.run([env.leanchecker, "-v", "Candidate"], [sandbox.Mount(cand_out, "/cand")] + dep_mounts,
                     extra_paths=dep_paths + ["/cand"])
    res.durations["replay"] = result.duration_s
    if not result.ok or "replaying Candidate" not in result.stdout:
        res.messages = [{"severity": "error", "text": ("timeout" if result.timed_out else (result.stderr or result.stdout or "replay failed")[-2000:])}]
        return res
    res.stage = "passed"
    res.ok = True
    return res


def scratch_dir(prefix: str = "viridis-lean-") -> Path:
    path = Path(tempfile.mkdtemp(prefix=prefix))
    os.chmod(path, 0o755)
    return path


def cleanup(path: Path) -> None:
    shutil.rmtree(path, ignore_errors=True)
