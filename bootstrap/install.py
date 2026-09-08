#!/usr/bin/env python3
"""Install a compatible set of native adapters without touching project records."""
from __future__ import annotations

import argparse
import datetime
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
SOURCE = Path(__file__).resolve().parents[1]
RUNTIMES = ("codex", "claude", "copilot")
VERSION = "0.3.0"
RETIRED = (".opencode", "opencode.json", ".deepagents")


def fail(message):
    raise ValueError(message)


def parts(relative):
    return tuple(p.casefold() for p in PurePosixPath(relative).parts)


def project_owned(relative):
    return parts(relative)[:1] == ("projects",)


def validate_relative(relative):
    path = PurePosixPath(relative)
    if (not relative or path.is_absolute() or ".." in path.parts or "\\" in relative
            or any(ord(char) < 32 or ord(char) == 127 for char in relative)):
        fail(f"unsafe managed manifest path: {relative!r}; no hub files changed")
    folded = parts(relative)
    if ".git" in folded or folded[:2] == (".piper", "locks"):
        fail(f"reserved operational path in managed manifest: {relative!r}; no hub files changed")


def read_manifest(hub):
    manifest = hub / ".piper/hub-manifest.json"
    if (hub / ".piper").is_symlink() or manifest.is_symlink():
        fail("managed manifest uses a symlink; no hub files changed")
    try:
        data = json.loads(manifest.read_text()) if manifest.exists() else {}
        if not isinstance(data, dict):
            raise ValueError("expected an object")
        for key in ("runtimes", "managed_files"):
            if not isinstance(data.get(key, []), list) or not all(isinstance(v, str) for v in data.get(key, [])):
                raise ValueError(f"{key} must be a list of strings")
    except (OSError, ValueError) as exc:
        fail(f"invalid existing hub manifest: {exc}; no hub files changed")
    for relative in data.get("managed_files", []):
        validate_relative(relative)
    return data


def select_runtimes(hub, data, requested):
    managed = data.get("managed_files", [])
    installed = set(data.get("runtimes", []))
    legacy = any((hub / item).exists() or (hub / item).is_symlink() for item in RETIRED)
    legacy |= any(p == item or p.startswith(item + "/") for p in managed for item in RETIRED)
    if legacy or installed - set(RUNTIMES):
        fail("existing hub contains retired runtime surfaces; no hub files changed. Migrate unsupported runtimes explicitly.")
    # Older manifests may omit runtimes. Only their owned native entry points
    # identify adapters; .claude/skills alone is shared by Claude and Copilot.
    for name, markers in {"codex": (".codex/",), "claude": ("CLAUDE.md", ".claude/settings.json", ".claude/agents/"),
                          "copilot": (".github/copilot-instructions.md", ".github/agents/", ".github/hooks/")}.items():
        if any(p == marker or (marker.endswith("/") and p.startswith(marker)) for p in managed for marker in markers):
            installed.add(name)
    chosen = installed | set(requested)
    if not chosen:
        chosen.add("codex")
    return tuple(name for name in RUNTIMES if name in chosen)


def template_files(runtimes):
    files = {}
    for runtime in runtimes:
        template = SOURCE / "generated" / runtime
        if not template.is_dir():
            fail(f"missing generated template for runtime {runtime}")
        for src in sorted(template.rglob("*")):
            if src.is_symlink():
                fail(f"generated template uses a symlink: {src}")
            if not src.is_file():
                continue
            relative = str(src.relative_to(template))
            validate_relative(relative)
            if relative in files:
                previous = files[relative]
                if previous.read_bytes() != src.read_bytes() or stat.S_IMODE(previous.stat().st_mode) != stat.S_IMODE(src.stat().st_mode):
                    fail(f"incompatible runtime templates at {relative}; no hub files changed")
            files[relative] = src
    return files


def preflight(hub, data, files):
    managed = data.get("managed_files", [])
    for relative in set(files) | set(managed) | {".piper/hub-manifest.json"}:
        dest = hub / relative
        for component in (dest, *dest.parents):
            if component == hub:
                break
            if component.is_symlink():
                fail(f"managed destination uses a symlink: {component}; no hub files changed")
            if component != dest and component.exists() and not component.is_dir():
                fail(f"managed parent is not a directory: {component}; no hub files changed")
        if dest.exists() and not dest.is_file():
            fail(f"managed destination is not a file: {dest}; no hub files changed")
    # Every incoming file needs ownership, including newly enabled roles and
    # skills. Identical bytes and mode are safe to adopt; conflicting unmanaged
    # content must be reconciled before any mutation. Also guard Claude settings
    # outside our output: Copilot could execute old Piper hooks found there.
    sensitive = {"AGENTS.md", "CLAUDE.md", ".claude/settings.json", ".codex/config.toml",
                 ".github/copilot-instructions.md", ".github/hooks/piper.json"}
    managed_normalized = {str(PurePosixPath(p)) for p in managed}
    for relative in set(files) | sensitive:
        if project_owned(relative):
            continue
        dest = hub / relative
        if dest.exists() and relative not in managed_normalized:
            if (relative in files and dest.is_file()
                    and dest.read_bytes() == files[relative].read_bytes()
                    and stat.S_IMODE(dest.stat().st_mode) == stat.S_IMODE(files[relative].stat().st_mode)):
                continue
            fail(f"unmanaged runtime configuration at {relative}; preserve and reconcile it before bootstrap; no hub files changed")


def atomic_write(dest, content, mode):
    dest.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(prefix=dest.name + ".tmp.", dir=dest.parent)
    try:
        with os.fdopen(descriptor, "wb") as output:
            output.write(content)
            os.fchmod(output.fileno(), mode)
        os.replace(temporary, dest)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def initialize_git(hub, dry_run):
    if shutil.which("git") is None:
        fail("--git-init requires git on PATH")
    result = subprocess.run(["git", "-C", str(hub), "rev-parse", "--show-toplevel"], capture_output=True, text=True)
    if result.returncode == 0 and Path(result.stdout.strip()).resolve() == hub:
        print(f"preserve git worktree: {hub}")
    elif dry_run:
        print(f"would initialize git repo: {hub}")
    else:
        subprocess.run(["git", "-C", str(hub), "init", "-q"], check=True)
        print(f"git init: {hub}")


def install(args):
    requested = []
    for group in args.runtime or []:
        for runtime in group.split(","):
            if runtime not in RUNTIMES:
                fail(f"unsupported runtime: {runtime!r}; choose codex, claude or copilot")
            requested.append(runtime)
    hub = Path(args.target).expanduser().resolve()
    if hub == SOURCE or (hub.exists() and os.path.samefile(hub, SOURCE)):
        fail(f"refusing to initialize the bootstrap source as a hub: {SOURCE}")
    if hub.exists() and not hub.is_dir():
        fail(f"target exists and is not a directory: {hub}")
    data = read_manifest(hub)
    runtimes = select_runtimes(hub, data, requested)
    files = template_files(runtimes)
    preflight(hub, data, files)
    if args.git_init and shutil.which("git") is None:
        fail("--git-init requires git on PATH")
    print(f"Initializing Piper Station hub at {hub} for runtimes: {','.join(runtimes)}")
    if not args.dry_run:
        hub.mkdir(parents=True, exist_ok=True)
    if args.git_init:
        initialize_git(hub, args.dry_run)
    for relative in data.get("managed_files", []):
        if project_owned(relative) or str(PurePosixPath(relative)) in files:
            continue
        dest = hub / relative
        if not dest.is_file():
            continue
        if args.dry_run:
            print(f"would remove stale managed hub file: {relative}")
        else:
            dest.unlink()
            parent = dest.parent
            while parent != hub:
                try:
                    parent.rmdir()
                except OSError:
                    break
                parent = parent.parent
            print(f"remove stale managed: {relative}")
    for relative, source in sorted(files.items()):
        dest = hub / relative
        if project_owned(relative) and dest.exists():
            print(f"preserve hub file: {relative}")
            continue
        if args.dry_run:
            print(f"would {'update' if dest.exists() else 'create'} managed hub file: {relative}")
            continue
        content, mode = source.read_bytes(), stat.S_IMODE(source.stat().st_mode)
        if dest.exists() and dest.read_bytes() == content:
            dest.chmod(mode)
            print(f"preserve managed: {relative}")
        else:
            atomic_write(dest, content, mode)
            print(f"write managed: {relative}")
    if args.dry_run:
        print("would update managed hub file: .piper/hub-manifest.json")
    else:
        manifest = {"hub_version": VERSION,
                    "installed_at": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                    "runtimes": list(runtimes), "file_mode": "managed-outside-projects",
                    "files": sorted(files), "managed_files": sorted(p for p in files if not project_owned(p))}
        atomic_write(hub / ".piper/hub-manifest.json", (json.dumps(manifest, indent=2) + "\n").encode(), 0o644)
        print("write managed: .piper/hub-manifest.json")
    print("Done.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runtime", action="append", help="codex, claude, copilot, or a comma-separated combination; adds to installed runtimes")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--git-init", action="store_true")
    parser.add_argument("--force", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("target", help="hub directory; new installations default to Codex")
    try:
        install(parser.parse_args())
    except (ValueError, OSError, subprocess.CalledProcessError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
