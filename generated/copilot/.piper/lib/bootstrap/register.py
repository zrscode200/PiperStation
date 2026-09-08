#!/usr/bin/env python3
"""Preflight registration and serialize it with cooperative record publication."""
from __future__ import annotations

import json
import os
from pathlib import Path
import re
import runpy
import subprocess
import sys

LIB = Path(__file__).resolve().parent
BODY = LIB / "registration-body.sh"
RECORD = LIB.parents[2] / "bin/piper-record"


def boundary(argv):
    values = {}
    flags = set()
    index = 0
    while index < len(argv):
        option = argv[index]
        if option in ("-h", "--help"):
            return None
        if option in ("--hub", "--repo", "--project-id", "--display-name", "--description"):
            index += 1
            if index == len(argv):
                raise ValueError(f"{option} requires a value")
            values[option] = argv[index]
        elif option in ("--dry-run", "--rebuild", "--hub-only"):
            flags.add(option)
        else:
            raise ValueError(f"unknown argument: {option}")
        index += 1
    if "--hub" not in values or ("--rebuild" not in flags and "--repo" not in values):
        raise ValueError("--hub and --repo are required, or use --hub with --rebuild")
    raw_hub = Path(values["--hub"])
    if raw_hub.is_symlink():
        raise ValueError("The hub directory must not be a symlink.")
    hub = raw_hub.resolve(strict=True)
    return hub, values, flags


def directory(path, required=False):
    if path.is_symlink() or (path.exists() and not path.is_dir()):
        raise ValueError(f"Registration directory must be a real directory: {path}")
    if required and not path.is_dir():
        raise ValueError(f"Registration directory does not exist: {path}")


def regular(path, required=False):
    if path.is_symlink() or (path.exists() and not path.is_file()):
        raise ValueError(f"Registration file must be a regular file: {path}")
    if required and not path.is_file():
        raise ValueError(f"Registration file does not exist: {path}")


def preflight(hub, values, flags):
    """Reject invalid destinations before publication; recheck while locked."""
    directory(hub, required=True)
    regular(hub / "STATION.md", required=True)
    projects = hub / "projects"
    directory(projects, required=True)
    registry = projects / "registry.json"
    regular(registry)
    if registry.exists():
        data = json.loads(registry.read_text(encoding="utf-8"))
        if not isinstance(data, dict) or not isinstance(data.get("projects", []), list):
            raise ValueError("Registry must be an object with a projects list.")
        if any(not isinstance(entry, dict) or not isinstance(entry.get("project_id", ""), str)
               for entry in data.get("projects", [])):
            raise ValueError("Registry entries must be objects with string project IDs.")
    if "--rebuild" in flags:
        for entry in projects.iterdir():
            if entry.is_symlink():
                raise ValueError(f"Registry rebuild will not follow a symlink: {entry}")
            if entry.is_dir():
                regular(entry / "project.md")
        return
    result = subprocess.run(["git", "-C", values["--repo"], "rev-parse", "--show-toplevel"],
                            capture_output=True, text=True)
    if result.returncode:
        raise ValueError(f"project repo must be a git worktree: {values['--repo']}")
    repo = Path(result.stdout.strip()).resolve(strict=True)
    if repo == hub:
        raise ValueError("refusing to register the hub directory as a project")
    project_id = values.get("--project-id") or re.sub(
        r"-+", "-", re.sub(r"[^a-z0-9._-]", "-", repo.name.lower())).strip("-")
    if not re.fullmatch(r"[A-Za-z0-9._-]+", project_id) or project_id.startswith("."):
        raise ValueError("project id must contain letters, numbers, dots, underscores or hyphens and not start with a dot")
    project = projects / project_id
    directory(project)
    regular(project / "project.md", required=project.exists())
    regular(project / "memory.md")
    for option, label in (("--display-name", "display name"), ("--description", "description")):
        value = values.get(option, "")
        if any(ord(char) < 32 or ord(char) == 127 for char in value):
            raise ValueError(f"{label} must not contain newlines or control characters")
    if len(values.get("--description", "").encode("utf-8")) > 120:
        raise ValueError("description must be 120 characters or fewer")
    if "--hub-only" not in flags:
        directory(repo / ".piper")
        regular(repo / ".piper/project.json")
        regular(repo / "PIPER.md")


def main(argv):
    env = dict(os.environ, PIPER_REGISTRATION_LAUNCHER="1")
    try:
        selected = boundary(argv)
        if selected is None:
            return subprocess.call(["sh", str(BODY), *argv], env=env)
        hub, values, flags = selected
        preflight(hub, values, flags)
        if "--dry-run" in flags:
            # Help and dry-run never create a lock directory or other state.
            return subprocess.call(["sh", str(BODY), *argv], env=env)
        record = runpy.run_path(str(RECORD))
        try:
            with record["locked"](hub, 30) as lock_fd:
                preflight(hub, values, flags)
                # The live shell retains the same open file description even
                # if this launcher dies; its final exit releases the lock.
                return subprocess.call(["sh", str(BODY), *argv], env=env, pass_fds=(lock_fd,))
        except record["RecordError"] as exc:
            print(f"Error: {exc}", file=sys.stderr)
            return 2
    except (ValueError, OSError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
