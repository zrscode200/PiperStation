#!/usr/bin/env python3
from __future__ import annotations

import argparse
import filecmp
import os
import shutil
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNTIMES = ("codex", "claude", "opencode", "deepagent")
COMMANDS = ("add-project.md", "superpowers.md", "ralph.md", "compact-handoff.md")
SKILLS = (
    "brainstorm",
    "design-studio",
    "piper-workflow",
    "review",
    "automation-policy",
)
# Runtimes without a native slash-command surface (Codex, Deep Agents) render
# commands as reference files under their owning skill: add-project belongs to
# the brainstorm front door; the planning and execution commands belong to
# piper-workflow. Runtimes with a command surface render every command into a
# single flat command_dir instead. A runtime opts into reference routing by
# setting "command_skill" in its RUNTIME_CONFIG entry.
COMMAND_OWNING_SKILL = {
    "add-project.md": "brainstorm",
    "superpowers.md": "piper-workflow",
    "ralph.md": "piper-workflow",
    "compact-handoff.md": "piper-workflow",
}
RUNTIME_CONFIG = {
    "codex": {
        "runtime_name": "Codex",
        "instruction_doc": "AGENTS.md",
        # Commands render as references under their owning skill, so no single
        # command_dir applies here.
        "command_skill": COMMAND_OWNING_SKILL,
        "skill_dir": ".codex/skills",
        "frontmatter": {
            "add-project.md": "",
            "superpowers.md": "",
            "ralph.md": "",
            "compact-handoff.md": "",
        },
        "runtime_native": "Codex-native",
        "runtime_session": "Codex session",
        "workspace_access": "If the project repo is outside the current workspace or sandbox, ask the user to make it accessible before editing.",
        "registration_entrypoints": "`./bin/add-project`",
        "review_helper": "read-only reviewer subagent",
    },
    "claude": {
        "runtime_name": "Claude Code",
        "instruction_doc": "CLAUDE.md",
        "command_dir": ".claude/commands",
        "skill_dir": ".claude/skills",
        "frontmatter": {
            "add-project.md": "---\ndescription: Register a project repo with this Piper Station hub\nargument-hint: \"<repo-path> [project-id]\"\n---\n\n",
            "superpowers.md": "---\ndescription: Enter Superpowers Mode for direction verification and planning\nargument-hint: \"<project-id> [request]\"\n---\n\n",
            "ralph.md": "---\ndescription: Enter Ralph Mode for the current wave, explicit slice, or queued task\nargument-hint: \"<project-id> [boundary id or description]\"\n---\n\n",
            "compact-handoff.md": "---\ndescription: Prepare compact-safe project work records before /compact\nargument-hint: \"[project-id] [current boundary]\"\n---\n\n",
        },
        "runtime_native": "Claude Code-native",
        "runtime_session": "Claude Code session",
        "workspace_access": "If the repo is outside the hub, ensure Claude Code has workspace access through `/add-dir <repo-path>` or `claude --add-dir <repo-path>` before editing.",
        "registration_entrypoints": "`/add-project` or `./bin/add-project`",
        "review_helper": "read-only reviewer agent",
    },
    "opencode": {
        "runtime_name": "OpenCode",
        "instruction_doc": "AGENTS.md",
        "command_dir": ".opencode/commands",
        "skill_dir": ".opencode/skills",
        "frontmatter": {
            "add-project.md": "---\ndescription: Register a project repo with this Piper Station hub\nargument-hint: \"[repo path and optional project id]\"\n---\n\n",
            "superpowers.md": "---\ndescription: Enter Superpowers Mode for direction verification and planning\nargument-hint: \"[project id or repo path and request]\"\n---\n\n",
            "ralph.md": "---\ndescription: Enter Ralph Mode for the current wave, explicit slice, or queued task\nargument-hint: \"[project id and optional boundary id]\"\n---\n\n",
            "compact-handoff.md": "---\ndescription: Prepare compact-safe project work records\nargument-hint: \"[project id and current boundary]\"\n---\n\n",
        },
        "runtime_native": "OpenCode-native",
        "runtime_session": "OpenCode session",
        "workspace_access": "If the project repo is outside the current working directory, open OpenCode from the project directory or adjust workspace access before editing.",
        "registration_entrypoints": "`./bin/add-project`",
        "review_helper": "read-only reviewer subagent",
    },
    "deepagent": {
        "runtime_name": "Deep Agents",
        "instruction_doc": ".deepagents/AGENTS.md",
        # Deep Agents Code has no custom slash-command surface; commands render
        # as references under their owning skill, same routing as Codex.
        "command_skill": COMMAND_OWNING_SKILL,
        "skill_dir": ".deepagents/skills",
        "frontmatter": {
            "add-project.md": "",
            "superpowers.md": "",
            "ralph.md": "",
            "compact-handoff.md": "",
        },
        "runtime_native": "Deep Agents-native",
        "runtime_session": "Deep Agents session",
        "workspace_access": "The agent works in the hub directory it was launched from, and the hub must be a git repository root for hub surfaces to load. Use absolute paths when reading or editing files in registered project repos; relative paths do not resolve against the working directory.",
        "registration_entrypoints": "`./bin/add-project`",
        "review_helper": "read-only reviewer subagent",
    },
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


def render_text(text: str, runtime: str, frontmatter: str = "") -> str:
    cfg = RUNTIME_CONFIG[runtime]
    return (
        text.replace("{{RUNTIME_NAME}}", cfg["runtime_name"])
        .replace("{{INSTRUCTION_DOC}}", cfg["instruction_doc"])
        .replace("{{FRONTMATTER}}", frontmatter)
        .replace("{{RUNTIME_NATIVE}}", cfg["runtime_native"])
        .replace("{{RUNTIME_SESSION}}", cfg["runtime_session"])
        .replace("{{WORKSPACE_ACCESS}}", cfg["workspace_access"])
        .replace("{{REGISTRATION_ENTRYPOINTS}}", cfg["registration_entrypoints"])
        .replace("{{REVIEW_HELPER}}", cfg["review_helper"])
    )


def command_dir_for(runtime: str, command: str) -> str:
    cfg = RUNTIME_CONFIG[runtime]
    command_skill = cfg.get("command_skill")
    if command_skill is not None:
        return f"{cfg['skill_dir']}/{command_skill[command]}/references"
    return cfg["command_dir"]


def render_skill_tree(runtime: str, out: Path, skill: str) -> None:
    cfg = RUNTIME_CONFIG[runtime]
    src_root = ROOT / "core/skills" / skill
    dst_root = out / cfg["skill_dir"] / skill
    for src in sorted(src_root.rglob("*")):
        if not src.is_file():
            continue
        rel = src.relative_to(src_root)
        text = render_text(src.read_text(encoding="utf-8"), runtime)
        write(dst_root / rel, text)


def render_behavior(runtime: str, out: Path) -> None:
    cfg = RUNTIME_CONFIG[runtime]
    for skill in SKILLS:
        render_skill_tree(runtime, out, skill)
    # Commands render after skill trees so command-owned references win for
    # command_skill runtimes if a core skill ever contains a file with the same
    # relative path.
    for command in COMMANDS:
        src = ROOT / "core/commands" / command
        text = render_text(src.read_text(encoding="utf-8"), runtime, cfg["frontmatter"][command])
        write(out / command_dir_for(runtime, command) / command, text)


def render_runtime(runtime: str, out_root: Path) -> None:
    out = out_root / runtime
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    copy_tree(ROOT / "core/shared", out)
    render_behavior(runtime, out)
    copy_tree(ROOT / "adapters" / runtime, out)
    add_project = ROOT / "core/shared/bin/add-project"
    copy_tree(add_project, out / ".piper/lib/bootstrap/add-project.sh")
    wrapper = """#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- \"$(dirname -- \"$0\")\" && pwd)
HUB_DIR=$(CDPATH= cd -- \"$SCRIPT_DIR/..\" && pwd -P)
HELPER=\"$HUB_DIR/.piper/lib/bootstrap/add-project.sh\"

for arg in \"$@\"; do
  if [ \"$arg\" = \"--hub\" ]; then
    echo \"Error: hub-local commands infer --hub; do not pass --hub explicitly.\" >&2
    exit 1
  fi
done

if [ ! -x \"$HELPER\" ]; then
  echo \"Error: missing Piper Station helper: $HELPER\" >&2
  exit 1
fi

exec \"$HELPER\" --hub \"$HUB_DIR\" \"$@\"
"""
    write(out / "bin/add-project", wrapper, 0o755)


def render_all(out_root: Path) -> None:
    out_root.mkdir(parents=True, exist_ok=True)
    for runtime in RUNTIMES:
        render_runtime(runtime, out_root)


def compare_dirs(left: Path, right: Path) -> list[str]:
    problems: list[str] = []
    cmp = filecmp.dircmp(left, right)
    for name in cmp.left_only:
        problems.append(f"missing from generated: {Path(cmp.left) / name}")
    for name in cmp.right_only:
        problems.append(f"extra in generated: {Path(cmp.right) / name}")
    for name in cmp.diff_files:
        problems.append(f"stale generated file: {Path(cmp.right) / name}")
    for sub in cmp.common_dirs:
        problems.extend(compare_dirs(Path(cmp.left) / sub, Path(cmp.right) / sub))
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
