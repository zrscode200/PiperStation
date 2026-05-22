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
RUNTIMES = ("codex", "claude")
COMMANDS = ("add-project.md", "work-on.md", "superpowers.md", "ralph.md", "compact-handoff.md")
SKILLS = (
    "hub-workflow/SKILL.md",
    "automation-policy/SKILL.md",
    "superpowers-planning/SKILL.md",
    "ralph-loop/SKILL.md",
    "review/SKILL.md",
)
RUNTIME_CONFIG = {
    "codex": {
        "runtime_name": "Codex",
        "instruction_doc": "AGENTS.md",
        "command_dir": ".piper/plugin/commands",
        "skill_dir": ".piper/plugin/skills",
        "frontmatter": {
            "add-project.md": "---\ndescription: Register a project repo with this Piper Station hub\nallowed-tools: [Read, Write, Bash]\n---\n\n",
            "work-on.md": "---\ndescription: Orient to a registered project and route work through Piper Station modes\nallowed-tools: [Read, Bash]\n---\n\n",
            "superpowers.md": "---\ndescription: Enter Superpowers Mode for discovery, specification, and planning\nallowed-tools: [Read, Write, Bash]\n---\n\n",
            "ralph.md": "---\ndescription: Enter Ralph Mode for one scoped implementation slice\nallowed-tools: [Read, Write, Bash]\n---\n\n",
            "compact-handoff.md": "---\ndescription: Prepare compact-safe project work records\nallowed-tools: [Read, Write, Bash]\n---\n\n",
        },
    },
    "claude": {
        "runtime_name": "Claude Code",
        "instruction_doc": "CLAUDE.md",
        "command_dir": ".claude/commands",
        "skill_dir": ".claude/skills",
        "frontmatter": {name: "" for name in COMMANDS},
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
    )


def render_behavior(runtime: str, out: Path) -> None:
    cfg = RUNTIME_CONFIG[runtime]
    for command in COMMANDS:
        src = ROOT / "core/commands" / command
        text = render_text(src.read_text(encoding="utf-8"), runtime, cfg["frontmatter"][command])
        write(out / cfg["command_dir"] / command, text)
    for skill in SKILLS:
        src = ROOT / "core/skills" / skill
        text = render_text(src.read_text(encoding="utf-8"), runtime)
        write(out / cfg["skill_dir"] / skill, text)


def render_runtime(runtime: str, out_root: Path) -> None:
    out = out_root / runtime
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    copy_tree(ROOT / "core/shared", out)
    copy_tree(ROOT / "adapters" / runtime, out)
    render_behavior(runtime, out)
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
