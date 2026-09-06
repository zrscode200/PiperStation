#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import shutil
import stat
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
# This branch distributes one Codex hub. The output subdirectory stays stable
# so existing Codex bootstrap callers do not need a path migration.
COMMAND_OWNING_SKILL = {
    "add-project.md": "brainstorm",
    "superpowers.md": "piper-workflow",
    "ralph.md": "piper-workflow",
    "compact-handoff.md": "piper-workflow",
}
SKILLS = ("brainstorm", "design-studio", "piper-workflow", "review", "automation-policy")
SUBSTITUTIONS = {
    "RUNTIME_NAME": "Codex",
    "INSTRUCTION_DOC": "AGENTS.md",
    "FRONTMATTER": "",
    "RUNTIME_NATIVE": "Codex-native",
    "RUNTIME_SESSION": "Codex session",
    "WORKSPACE_ACCESS": "If the lane's checkout (`repo_path` or its recorded worktree) is outside the current workspace or sandbox, ask the user to make it accessible before editing.",
    "REGISTRATION_ENTRYPOINTS": "`./bin/add-project`",
    "REVIEW_HELPER": "read-only reviewer subagent",
}


def write(path: Path, text: str, mode: int = 0o644) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    os.chmod(path, mode)


def copy_tree(src: Path, dst: Path) -> None:
    if src.is_file():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        return
    for file in src.rglob("*"):
        if file.is_file():
            rel = file.relative_to(src)
            out = dst / rel
            out.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(file, out)


def render_text(text: str) -> str:
    for key, value in SUBSTITUTIONS.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def render_behavior(out: Path) -> None:
    for skill in SKILLS:
        src_root = ROOT / "core/skills" / skill
        for src in sorted(src_root.rglob("*")):
            if src.is_file():
                dst = out / ".codex/skills" / skill / src.relative_to(src_root)
                write(dst, render_text(src.read_text(encoding="utf-8")))
    for command, skill in COMMAND_OWNING_SKILL.items():
        src = ROOT / "core/commands" / command
        dst = out / ".codex/skills" / skill / "references" / command
        if dst.exists():
            raise ValueError(f"procedure has two source owners: {dst.relative_to(out)}")
        write(dst, render_text(src.read_text(encoding="utf-8")))


def render_codex(out_root: Path) -> None:
    out = out_root / "codex"
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    copy_tree(ROOT / "core/shared", out)
    render_behavior(out)
    adapter = ROOT / "adapters/codex"
    for src in adapter.rglob("*"):
        if src.is_file() and (out / src.relative_to(adapter)).exists():
            raise ValueError(f"adapter shadows core behavior: {src.relative_to(adapter)}")
    copy_tree(adapter, out)


def render_all(out_root: Path) -> None:
    if out_root.is_symlink():
        raise ValueError(f"refusing to render through a symlink: {out_root}")
    out_root.mkdir(parents=True, exist_ok=True)
    # generated/ is renderer-owned, including retired runtime output. Clearing
    # it avoids leaving obsolete templates installable after the source changes.
    for child in out_root.iterdir():
        if child.is_dir() and not child.is_symlink():
            shutil.rmtree(child)
        else:
            child.unlink()
    render_codex(out_root)


def compare_dirs(left: Path, right: Path) -> list[str]:
    problems: list[str] = []
    expected = {path.name: path for path in left.iterdir()}
    actual = {path.name: path for path in right.iterdir()}
    for name in sorted(expected.keys() - actual.keys()):
        problems.append(f"missing from generated: {right / name}")
    for name in sorted(actual.keys() - expected.keys()):
        problems.append(f"extra in generated: {right / name}")
    for name in sorted(expected.keys() & actual.keys()):
        src, dst = expected[name], actual[name]
        if src.is_symlink() or dst.is_symlink():
            problems.append(f"unexpected generated symlink: {dst}")
        elif src.is_dir() and dst.is_dir():
            problems.extend(compare_dirs(src, dst))
        elif src.is_file() and dst.is_file():
            if src.read_bytes() != dst.read_bytes():
                problems.append(f"stale generated file: {dst}")
            if stat.S_IMODE(src.stat().st_mode) != stat.S_IMODE(dst.stat().st_mode):
                problems.append(f"stale generated file mode: {dst}")
        else:
            problems.append(f"generated path type mismatch: {dst}")
    return problems


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    generated = ROOT / "generated"
    if args.check:
        with tempfile.TemporaryDirectory(prefix="piper-render-check-") as tmp:
            tmp_path = Path(tmp)
            render_all(tmp_path)
            problems = compare_dirs(tmp_path, generated)
            if problems:
                print("generated templates are stale", file=sys.stderr)
                for problem in problems:
                    print(problem, file=sys.stderr)
                return 1
        print("generated templates are current")
        return 0
    render_all(generated)
    print("rendered templates")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
