#!/usr/bin/env python3
"""Exercise native adapter composition using disposable hubs and hook events."""
import itertools
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import unittest

ROOT = Path(sys.argv.pop(1)).resolve()
SCRATCH = Path(sys.argv.pop(1)).resolve() / "runtimes"
SCRATCH.mkdir()
BOOTSTRAP = ROOT / "bootstrap/init.sh"
RUNTIMES = ("codex", "claude", "copilot")
ROLES = ("investigator", "implementer", "reviewer")


def snapshot(path):
    return {str(p.relative_to(path)): (p.stat().st_mode, p.read_bytes())
            for p in path.rglob("*") if p.is_file()}


class RuntimeTests(unittest.TestCase):
    def hub(self, name, runtimes):
        hub = SCRATCH / name
        result = subprocess.run([str(BOOTSTRAP), "--runtime", ",".join(runtimes), str(hub)],
                                text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        return hub

    def bootstrap(self, hub, *args):
        return subprocess.run([str(BOOTSTRAP), *args, str(hub)], text=True, capture_output=True)

    def test_all_seven_combinations_and_refresh(self):
        for count in range(1, 4):
            for runtimes in itertools.combinations(RUNTIMES, count):
                with self.subTest(runtimes=runtimes):
                    hub = self.hub("-".join(runtimes), runtimes)
                    manifest = json.loads((hub / ".piper/hub-manifest.json").read_text())
                    self.assertEqual(manifest["runtimes"], list(runtimes))
                    for runtime in RUNTIMES:
                        entry = {"codex": ".codex/config.toml", "claude": "bin/piper-claude",
                                 "copilot": ".github/hooks/piper.json"}[runtime]
                        self.assertEqual((hub / entry).exists(), runtime in runtimes)
                    for relative in ("STATION.md", "AGENTS.md", "RUNTIMES.md", "bin/piper-record", "bin/piper-integrate"):
                        self.assertEqual((hub / relative).read_bytes(), (ROOT / "core/shared" / relative).read_bytes())
                    self.assertFalse((hub / ".claude/settings.json").exists(), "Claude hooks must not be auto-discovered by Copilot")
                    self.assertFalse((hub / ".github/skills").exists(), "no duplicate Copilot/Claude skills")
                    for runtime in runtimes:
                        skills = hub / (".codex/skills" if runtime == "codex" else ".claude/skills")
                        self.assertEqual(len(list(skills.glob("*/SKILL.md"))), 5)
                        workflow = skills / "piper-workflow"
                        self.assertEqual((workflow / "SKILL.md").read_bytes(), (ROOT / "core/skills/piper-workflow/SKILL.md").read_bytes())
                        for name in ("superpowers", "ralph", "compact-handoff"):
                            self.assertEqual((workflow / "references" / (name + ".md")).read_bytes(),
                                             (ROOT / "core/commands" / (name + ".md")).read_bytes())
                        review = skills / ("review" if runtime == "codex" else "piper-review") / "SKILL.md"
                        self.assertTrue(review.is_file())
                        for role in ROLES:
                            relative = {"codex": f".codex/agents/{role}.toml", "claude": f".claude/agents/{role}.md",
                                        "copilot": f".github/agents/{role}.agent.md"}[runtime]
                            self.assertIn((ROOT / "core/roles" / (role + ".md")).read_text().strip(), (hub / relative).read_text())
                    retained = hub / "projects/example/work/lanes/paused/context-pack.md"
                    retained.parent.mkdir(parents=True)
                    retained.write_text("Preserve paused work and its source checkout.\n")
                    user_file = hub / "personal-notes.md"
                    user_file.write_text("unmanaged notes\n")
                    before = snapshot(hub)
                    result = self.bootstrap(hub, "--dry-run")
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertEqual(snapshot(hub), before)
                    records = snapshot(hub / "projects")
                    self.assertEqual(self.bootstrap(hub).returncode, 0)
                    self.assertEqual(snapshot(hub / "projects"), records)
                    self.assertEqual(user_file.read_text(), "unmanaged notes\n")
                    self.assertEqual(json.loads((hub / ".piper/hub-manifest.json").read_text())["runtimes"], list(runtimes))

    def test_incremental_enablement_is_order_independent(self):
        for order in itertools.permutations(RUNTIMES):
            hub = self.hub("order-" + "-".join(order), order[:1])
            for runtime in order[1:]:
                result = self.bootstrap(hub, "--runtime", runtime)
                self.assertEqual(result.returncode, 0, result.stderr)
            manifest = json.loads((hub / ".piper/hub-manifest.json").read_text())
            self.assertEqual(manifest["runtimes"], list(RUNTIMES))
            self.assertFalse(any(p.startswith("projects/") for p in manifest["managed_files"]))
            self.assertEqual(len(list((hub / ".claude/skills").glob("*/SKILL.md"))), 5)
            for relative in manifest["managed_files"]:
                self.assertTrue((hub / relative).is_file(), relative)

    def test_legacy_claude_managed_hooks_and_roles_upgrade(self):
        hub = self.hub("legacy-claude", ("claude",))
        manifest_path = hub / ".piper/hub-manifest.json"
        manifest = json.loads(manifest_path.read_text())
        legacy_settings = hub / ".claude/settings.json"
        legacy_settings.write_text('{"hooks":{"SessionStart":[]}}\n')
        legacy_role = hub / ".claude/agents/tester.md"
        legacy_role.write_text("old managed role\n")
        local_settings = hub / ".claude/settings.local.json"
        local_settings.write_text('{"model":"user-choice"}\n')
        manifest["managed_files"] += [".claude/settings.json", ".claude/agents/tester.md"]
        manifest_path.write_text(json.dumps(manifest))
        before = snapshot(hub)
        self.assertEqual(self.bootstrap(hub, "--runtime", "copilot", "--dry-run").returncode, 0)
        self.assertEqual(snapshot(hub), before)
        result = self.bootstrap(hub, "--runtime", "copilot")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(legacy_settings.exists())
        self.assertFalse(legacy_role.exists())
        self.assertEqual(local_settings.read_text(), '{"model":"user-choice"}\n')
        self.assertTrue((hub / ".piper/runtime/claude-settings.json").is_file())

    def test_unmanaged_native_configuration_is_not_adopted(self):
        for index, relative in enumerate(("CLAUDE.md", ".claude/settings.json", ".github/hooks/piper.json")):
            hub = SCRATCH / f"unmanaged-{index}"
            path = hub / relative
            path.parent.mkdir(parents=True)
            path.write_text("user-owned configuration\n")
            before = snapshot(hub)
            for flags in ([], ["--force"], ["--dry-run"]):
                result = self.bootstrap(hub, "--runtime", "claude,copilot", *flags)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("unmanaged runtime configuration", result.stderr)
                self.assertEqual(snapshot(hub), before)

    def test_enablement_preserves_unmanaged_roles_skills_and_modes(self):
        cases = (("claude", ".claude/agents/reviewer.md"),
                 ("copilot", ".github/agents/reviewer.agent.md"),
                 ("claude", ".claude/skills/brainstorm/SKILL.md"),
                 ("copilot", ".claude/skills/brainstorm/SKILL.md"),
                 ("claude", "bin/piper-claude"))
        for index, (runtime, relative) in enumerate(cases):
            with self.subTest(runtime=runtime, path=relative):
                hub = self.hub(f"custom-enable-{index}", ("codex",))
                path = hub / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                template = ROOT / "generated" / runtime / relative
                # A mode-only difference must be preserved too.
                path.write_bytes(template.read_bytes() if relative.startswith("bin/")
                                 else b"user-owned custom behavior\n")
                path.chmod(0o600)
                before = snapshot(hub)
                for flags in ([], ["--force"], ["--dry-run"]):
                    result = self.bootstrap(hub, "--runtime", runtime, *flags)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("unmanaged runtime configuration", result.stderr)
                    self.assertEqual(snapshot(hub), before)
                # An already matching file can be adopted without changing it.
                path.write_bytes(template.read_bytes())
                path.chmod(template.stat().st_mode & 0o777)
                result = self.bootstrap(hub, "--runtime", runtime)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(path.read_bytes(), template.read_bytes())
                self.assertEqual(path.stat().st_mode & 0o777, template.stat().st_mode & 0o777)

    def test_native_hook_commands_and_serialization_preserve_records(self):
        hub = self.hub("hook hub $cash 'quotes'", RUNTIMES)
        project = hub / "projects/example"
        (project / "work/design/example-studio").mkdir(parents=True)
        (project / "work/lanes/example-fix").mkdir(parents=True)
        (project / "project.md").write_text("# Example\n")
        (project / "work/design/example-studio/design.md").write_text("Unaccepted studio.\n")
        (project / "work/lanes/example-fix/context-pack.md").write_text("Preserve unresolved work.\n")
        before = snapshot(hub)
        for runtime in ("claude", "copilot"):
            config = hub / (".piper/runtime/claude-settings.json" if runtime == "claude" else ".github/hooks/piper.json")
            hooks = json.loads(config.read_text())["hooks"]
            self.assertEqual(set(hooks), {"SessionStart", "PreCompact", "PostCompact"} if runtime == "claude" else {"sessionStart", "preCompact"})
            entry = hooks["SessionStart" if runtime == "claude" else "sessionStart"][0]
            def invocation(entry):
                if runtime == "copilot":
                    return ["sh", "-c", entry["bash"]]
                hook = entry["hooks"][0]
                # Claude exec form substitutes each argument without a shell.
                return [hook["command"], *(arg.replace("${CLAUDE_PROJECT_DIR}", str(hub))
                                            for arg in hook["args"])]

            for payload in ('{"source":"startup"}', '{"source":"resume"}', '{"source":"compact"}', '[]', 'not JSON'):
                env = dict(os.environ, CLAUDE_PROJECT_DIR=str(hub), COPILOT_PROJECT_DIR=str(hub))
                result = subprocess.run(invocation(entry), cwd=project, input=payload,
                                        env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                output = json.loads(result.stdout)
                context = output["hookSpecificOutput"]["additionalContext"] if runtime == "claude" else output["additionalContext"]
                self.assertIn("studio:example-studio", context)
                self.assertIn("lane:example-fix", context)
                self.assertIn("not a liveness claim", context)
                if "resume" in payload:
                    self.assertIn("Resume guidance", context)
            entry = hooks["PreCompact" if runtime == "claude" else "preCompact"][0]
            result = subprocess.run(invocation(entry), cwd=project, input='{"trigger":"auto"}',
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            if runtime == "copilot":
                self.assertEqual(result.stdout, "")
                self.assertIn("does not write a snapshot", result.stderr)
            else:
                self.assertIn("does not write a snapshot", json.loads(result.stdout)["systemMessage"])
        self.assertEqual(snapshot(hub), before)

    def test_claude_launcher_passes_arguments_and_uses_hub(self):
        hub = self.hub("launcher hub $cash 'quotes'", ("claude",))
        stub_dir = SCRATCH / "stub-bin"
        stub_dir.mkdir()
        stub = stub_dir / "claude"
        stub.write_text(f"#!{sys.executable}\nimport json,os,sys\nprint(json.dumps({{'cwd':os.getcwd(),'args':sys.argv[1:]}}))\n")
        stub.chmod(0o755)
        args = ["--add-dir", "/tmp/a path 'quoted'", "--model", "user-choice"]
        result = subprocess.run([str(hub / "bin/piper-claude"), *args], cwd=SCRATCH,
                                env=dict(os.environ, PATH=str(stub_dir) + os.pathsep + os.environ["PATH"]),
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        observed = json.loads(result.stdout)
        self.assertEqual(Path(observed["cwd"]).resolve(), hub)
        self.assertEqual(observed["args"], ["--settings", str(hub / ".piper/runtime/claude-settings.json"), *args])

    def test_native_observers_do_not_gain_shell_or_default_permissions(self):
        for runtime in ("claude", "copilot"):
            for role in ROLES:
                relative = f".claude/agents/{role}.md" if runtime == "claude" else f".github/agents/{role}.agent.md"
                text = (ROOT / "generated" / runtime / relative).read_text()
                frontmatter = text.split("---", 2)[1]
                self.assertNotIn("model:", frontmatter)
                self.assertNotIn("permissionMode:", frontmatter)
                self.assertNotIn('"*"', frontmatter)
                if role != "implementer":
                    for forbidden in ("Bash", "Write", "Edit", "execute", '"edit"', "Agent"):
                        self.assertNotIn(forbidden, frontmatter)


unittest.main()
