"""Execution checkout bindings shared by record publication and integration.

Callers hold the hub record lock while checking and publishing an ownership
change. These records coordinate participating writers; they do not establish
native session liveness or grant permission to edit a checkout.
"""
from __future__ import annotations

import os
from pathlib import Path, PurePosixPath
import re
import stat


class OwnershipError(Exception):
    def __init__(self, code: str, message: str):
        self.code = code
        super().__init__(message)


def owned_path(path: Path, project: Path) -> Path:
    try:
        parts = path.relative_to(project).parts
    except ValueError as exc:
        raise OwnershipError("unsafe-path", f"Hub record escapes project: {path}") from exc
    current = project
    for part in parts:
        current /= part
        if current.is_symlink():
            raise OwnershipError("unsafe-path", f"Hub records must not follow symlinks: {current}")
    return path


def record_text(path: Path, project: Path) -> str:
    """Read a regular record without following its ancestors or final symlink."""
    owned_path(path, project)
    parts = path.relative_to(project).parts
    fd = os.open(project, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        for part in parts[:-1]:
            child = os.open(part, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=fd)
            os.close(fd)
            fd = child
        child = os.open(parts[-1], os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK, dir_fd=fd)
        with os.fdopen(child, "rb") as stream:
            if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):
                raise OwnershipError("lane-record", f"Ownership record must be a regular file: {path}")
            return stream.read().decode("utf-8")
    except FileNotFoundError as exc:
        raise OwnershipError("lane-record", f"Missing ownership record: {path}. Reconcile its ownership first.") from exc
    finally:
        os.close(fd)


def registered_repo(project: Path) -> Path:
    path = project / "project.md"
    text = record_text(path, project)
    starts, ends = "<!-- piper-project:start -->", "<!-- piper-project:end -->"
    if text.count(starts) != 1 or text.count(ends) != 1 or text.index(starts) > text.index(ends):
        raise OwnershipError("registration", f"Repair the single managed registration block in {path}.")
    block = text.split(starts, 1)[1].split(ends, 1)[0]
    repos = re.findall(r"^\s*- Path: `([^`\n]+)`\s*$", block, re.MULTILINE)
    ids = re.findall(r"^\s*- Project ID: `([^`\n]+)`\s*$", block, re.MULTILINE)
    if (len(repos) != 1 or ids != [project.name] or not Path(repos[0]).is_absolute()
            or any(ord(char) < 32 for char in repos[0])):
        raise OwnershipError("registration", f"Repair the project ID and absolute Path binding in {path}.")
    repo = Path(repos[0])
    if repo.is_symlink():
        raise OwnershipError("unsafe-path", f"Registered repository must not be a symlink: {repo}")
    try:
        return repo.resolve(strict=True)
    except (OSError, RuntimeError, ValueError) as exc:
        raise OwnershipError("invalid-path", f"Cannot open registered repository {repo}: {exc}") from exc


def is_execution_record(relative: PurePosixPath) -> bool:
    parts = relative.parts
    return parts == ("work", "active-work.md") or (
        len(parts) == 4 and parts[0] == "work" and parts[1] in ("groups", "lanes")
        and parts[3] == "active-work.md"
    )


def parse_header(text: str, path: Path) -> dict[str, str]:
    fields = {}
    for line in text.splitlines():
        if line.startswith("## "):
            break
        match = re.fullmatch(r"\s*(?:-\s+)?(checkout|status):\s*(.*?)\s*", line)
        if match:
            key, value = match.groups()
            if key in fields:
                raise OwnershipError("lane-record", f"Ambiguous duplicate {key}: header in {path}")
            fields[key] = value.strip("`\"'")
    return fields


def checkout_binding(fields: dict[str, str], path: Path, project: Path, repo: Path) -> Path | None:
    if fields.get("status") == "closed":
        return None
    checkout = fields.get("checkout")
    if not checkout:
        if path == project / "work/active-work.md":
            return repo  # An existing legacy flat record holds repo_path.
        raise OwnershipError("lane-record", f"Non-closed execution lane lacks checkout: in {path}. Reconcile ownership first.")
    if not Path(checkout).is_absolute() or any(ord(char) < 32 for char in checkout):
        raise OwnershipError("lane-record", f"Record an absolute checkout: path without control characters in {path}.")
    try:
        return Path(checkout).resolve()
    except (OSError, RuntimeError, ValueError) as exc:
        raise OwnershipError("lane-record", f"Cannot resolve checkout: in {path}: {exc}") from exc


def execution_records(project: Path):
    work = owned_path(project / "work", project)
    if not work.exists():
        return
    if not work.is_dir():
        raise OwnershipError("lane-record", f"Execution record directory is not a directory: {work}")
    flat = owned_path(work / "active-work.md", project)
    if flat.exists():
        yield flat
    for kind in ("groups", "lanes"):
        directory = owned_path(work / kind, project)
        if directory.exists():
            if not directory.is_dir():
                raise OwnershipError("lane-record", f"Execution record directory is not a directory: {directory}")
            for lane in sorted(directory.iterdir()):
                owned_path(lane, project)
                if lane.is_dir():
                    # A named folder without its header is ambiguous, never idle.
                    yield lane / "active-work.md"


def ensure_unoccupied(project: Path, repo: Path, target: Path, exclude: Path | None = None) -> None:
    target = target.resolve()
    for record in execution_records(project):
        if record == exclude:
            continue
        fields = parse_header(record_text(record, project), record)
        bound = checkout_binding(fields, record, project, repo)
        if bound is not None and same_checkout(bound, target):
            raise OwnershipError("target-occupied", f"Target is owned by {record} (status {fields.get('status', 'unspecified')}). Checkpoint and explicitly release its writer binding before reassignment or integration; a paused or absent session does not release it.")


def same_checkout(first: Path, second: Path) -> bool:
    if first == second:
        return True
    try:
        # realpath resolves symlinks, but retains case aliases on macOS volumes.
        return first.samefile(second)
    except FileNotFoundError:
        return False
    except OSError as exc:
        raise OwnershipError("lane-record", f"Cannot compare checkout ownership for {first} and {second}: {exc}") from exc


def guard_replacement(project: Path, relative: PurePosixPath, text: str) -> None:
    """Validate one proposed claim while the caller holds the hub record lock."""
    if not is_execution_record(relative):
        return
    path = project / relative
    fields = parse_header(text, path)
    if fields.get("status") == "closed":
        return  # Explicit release must remain available to repair existing state.
    repo = registered_repo(project)
    target = checkout_binding(fields, path, project, repo)
    ensure_unoccupied(project, repo, target, exclude=path)
