"""Docker sandbox for agent-supplied Lean and LaTeX (I4, I5).

Every container runs with: no network, read-only root filesystem, all
capabilities dropped, no-new-privileges, a non-root numeric user, memory, CPU
and process limits, an explicit environment (nothing inherited), and only the
mounts the caller names. Mounts are read-only unless the caller marks one
writable. A host-side timeout kills the container, not just the client.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import threading
import time
import uuid
from dataclasses import dataclass, field
from pathlib import Path

from .util import RECORD_ROOT, REPO_ROOT, EngineError, log

SANDBOX_USER = "65534:65534"  # nobody:nogroup
OUTPUT_CAP_BYTES = 2_000_000
FORBIDDEN_MOUNT_ROOTS = (REPO_ROOT, RECORD_ROOT)


@dataclass(frozen=True)
class Mount:
    host: Path
    target: str
    writable: bool = False


@dataclass
class SandboxResult:
    returncode: int
    stdout: str
    stderr: str
    timed_out: bool
    duration_s: float
    argv: list[str] = field(default_factory=list)

    @property
    def ok(self) -> bool:
        return self.returncode == 0 and not self.timed_out


def docker_available() -> bool:
    if shutil.which("docker") is None:
        return False
    try:
        proc = subprocess.run(["docker", "info", "--format", "{{.ServerVersion}}"],
                              capture_output=True, text=True, timeout=20)
    except (OSError, subprocess.TimeoutExpired):
        return False
    return proc.returncode == 0


def _check_mount(mount: Mount) -> None:
    host = mount.host.resolve()
    if not host.is_absolute() or not host.exists():
        raise EngineError("sandbox_mount", f"missing host path {mount.host}")
    if "," in str(host) or "=" in str(host):
        raise EngineError("sandbox_mount", f"unsupported character in host path {host}")
    for root in FORBIDDEN_MOUNT_ROOTS:
        root = root.resolve()
        if host == root or root in host.parents:
            raise EngineError("sandbox_mount", f"refusing to mount the repository checkout ({host})")
    if not mount.target.startswith("/") or ":" in mount.target or "," in mount.target:
        raise EngineError("sandbox_mount", f"bad target {mount.target}")


def _pump(stream, sink: bytearray) -> None:
    while True:
        chunk = stream.read(65536)
        if not chunk:
            break
        room = OUTPUT_CAP_BYTES - len(sink)
        if room > 0:
            sink.extend(chunk[:room])
    stream.close()


def build_argv(image: str, argv: list[str], mounts: list[Mount], *, workdir: str,
               env: dict[str, str], memory_mb: int, cpus: float, pids: int,
               tmpfs_mb: int, name: str) -> list[str]:
    cmd = [
        "docker", "run", "--rm", "--name", name,
        "--network", "none",
        "--read-only",
        "--cap-drop", "ALL",
        "--security-opt", "no-new-privileges",
        "--pids-limit", str(pids),
        "--memory", f"{memory_mb}m",
        "--memory-swap", f"{memory_mb}m",
        "--cpus", str(cpus),
        "--user", SANDBOX_USER,
        "--tmpfs", f"/tmp:rw,exec,nosuid,nodev,size={tmpfs_mb}m",
        "--workdir", workdir,
    ]
    base_env = {"HOME": "/tmp", "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
                "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"}
    base_env.update(env)
    for key in sorted(base_env):
        if not key.replace("_", "").isalnum() or "\n" in base_env[key]:
            raise EngineError("sandbox_env", key)
        cmd += ["--env", f"{key}={base_env[key]}"]
    for mount in mounts:
        _check_mount(mount)
        spec = f"type=bind,source={mount.host.resolve()},target={mount.target}"
        if not mount.writable:
            spec += ",readonly"
        cmd += ["--mount", spec]
    cmd.append(image)
    cmd += argv
    return cmd


def run(image: str, argv: list[str], mounts: list[Mount], *, workdir: str = "/tmp",
        env: dict[str, str] | None = None, timeout_s: float = 600, memory_mb: int = 4096,
        cpus: float = 2.0, pids: int = 512, tmpfs_mb: int = 512) -> SandboxResult:
    name = f"viridis-{uuid.uuid4().hex[:12]}"
    cpus = max(0.5, min(float(cpus), float(os.cpu_count() or 1)))
    cmd = build_argv(image, argv, mounts, workdir=workdir, env=env or {}, memory_mb=memory_mb,
                     cpus=cpus, pids=pids, tmpfs_mb=tmpfs_mb, name=name)
    started = time.monotonic()
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.DEVNULL,
                            env={"PATH": os.environ.get("PATH", "/usr/bin:/bin"),
                                 "DOCKER_HOST": os.environ.get("DOCKER_HOST", "unix:///var/run/docker.sock")})
    out, err = bytearray(), bytearray()
    threads = [threading.Thread(target=_pump, args=(proc.stdout, out), daemon=True),
               threading.Thread(target=_pump, args=(proc.stderr, err), daemon=True)]
    for t in threads:
        t.start()
    timed_out = False
    try:
        proc.wait(timeout=timeout_s)
    except subprocess.TimeoutExpired:
        timed_out = True
        log(f"sandbox timeout after {timeout_s}s; killing {name}")
        subprocess.run(["docker", "kill", name], capture_output=True, timeout=60)
        subprocess.run(["docker", "rm", "-f", name], capture_output=True, timeout=60)
        try:
            proc.wait(timeout=60)
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait()
    for t in threads:
        t.join(timeout=30)
    return SandboxResult(
        returncode=proc.returncode if proc.returncode is not None else -9,
        stdout=out.decode("utf-8", errors="replace"),
        stderr=err.decode("utf-8", errors="replace"),
        timed_out=timed_out,
        duration_s=round(time.monotonic() - started, 3),
        argv=argv,
    )


def run_local(argv: list[str], mounts: list[Mount], *, env: dict[str, str] | None = None,
              timeout_s: float = 600) -> SandboxResult:
    """Run without Docker, mapping sandbox paths back to host paths.

    NOT a sandbox. It exists only for the agent's own self-check tool
    (``engine.agent_check``), which runs as the unprivileged agent user on
    files the agent wrote itself, and for tests on machines without Docker.
    The verifier never uses it (see ``engine.verify``).
    """
    ordered = sorted(mounts, key=lambda m: len(m.target), reverse=True)

    def translate(value: str) -> str:
        parts = []
        for piece in value.split(":"):
            for mount in ordered:
                if piece == mount.target or piece.startswith(mount.target + "/"):
                    piece = str(mount.host.resolve()) + piece[len(mount.target):]
                    break
            parts.append(piece)
        return ":".join(parts)

    real_argv = [translate(a) for a in argv]
    real_env = {"PATH": os.environ.get("PATH", "/usr/bin:/bin"), "HOME": os.environ.get("HOME", "/tmp"),
                "LANG": "C.UTF-8"}
    for key, value in (env or {}).items():
        real_env[key] = translate(value) if key in ("LEAN_PATH", "LEAN_SYSROOT", "PATH") else value
    started = time.monotonic()
    timed_out = False
    try:
        proc = subprocess.run(real_argv, capture_output=True, timeout=timeout_s, env=real_env, cwd="/tmp")
        code, out, err = proc.returncode, proc.stdout, proc.stderr
    except subprocess.TimeoutExpired as exc:
        timed_out, code, out, err = True, -9, exc.stdout or b"", exc.stderr or b""
    return SandboxResult(returncode=code, stdout=out[:OUTPUT_CAP_BYTES].decode("utf-8", "replace"),
                         stderr=err[:OUTPUT_CAP_BYTES].decode("utf-8", "replace"), timed_out=timed_out,
                         duration_s=round(time.monotonic() - started, 3), argv=argv)


def build_image(dockerfile: Path, tag: str, timeout_s: float = 1800) -> None:
    """Build a trusted image from main's Dockerfile (network allowed: trusted input only)."""
    proc = subprocess.run(["docker", "build", "--pull", "-t", tag, "-f", str(dockerfile), str(dockerfile.parent)],
                          capture_output=True, text=True, timeout=timeout_s)
    if proc.returncode != 0:
        raise EngineError("image_build_failed", proc.stderr[-4000:])


def image_present(tag: str) -> bool:
    proc = subprocess.run(["docker", "image", "inspect", tag], capture_output=True, text=True)
    return proc.returncode == 0
