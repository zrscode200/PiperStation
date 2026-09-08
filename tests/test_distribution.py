#!/usr/bin/env python3
"""Behavioral distribution checks using disposable hubs and renderer outputs."""
from __future__ import annotations

import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time
import sys

ROOT = Path(sys.argv[1])
TMP = Path(sys.argv[2]).resolve() / "distribution"
TMP.mkdir()
BOOTSTRAP = ROOT / "bootstrap/init.sh"


def snapshot(root: Path) -> dict:
    result = {}
    for path in sorted(root.rglob("*")):
        rel = str(path.relative_to(root))
        if path.is_symlink():
            result[rel] = ("symlink", os.readlink(path))
        elif path.is_dir():
            result[rel] = ("dir", path.stat().st_mode)
        else:
            result[rel] = ("file", path.stat().st_mode, path.read_bytes())
    return result


def rejects_without_mutation(hub: Path, message: str, *args: str) -> None:
    before = snapshot(hub)
    result = subprocess.run([str(BOOTSTRAP), *args, str(hub)], capture_output=True, text=True)
    assert result.returncode != 0, result.stdout
    assert message in result.stderr, result.stderr
    assert snapshot(hub) == before, "rejected bootstrap changed existing hub"


for index, surface in enumerate((".opencode/agents/reviewer.md", "opencode.json", ".deepagents/AGENTS.md")):
    hub = TMP / f"legacy-surface-{index}"
    path = hub / surface
    path.parent.mkdir(parents=True)
    path.write_text("keep this runtime configuration\n")
    (hub / "projects").mkdir()
    (hub / "projects/README.md").write_text("keep project understanding\n")
    rejects_without_mutation(hub, "retired runtime surfaces")
    rejects_without_mutation(hub, "retired runtime surfaces", "--force")
    rejects_without_mutation(hub, "retired runtime surfaces", "--dry-run")

for index, data in enumerate((
    {"managed_files": [".deepagents/AGENTS.md"]},
    {"runtimes": ["future-runtime"]},
)):
    hub = TMP / f"legacy-manifest-{index}"
    (hub / ".piper").mkdir(parents=True)
    (hub / ".piper/hub-manifest.json").write_text(json.dumps(data))
    rejects_without_mutation(hub, "retired runtime surfaces")

hub = TMP / "bad-manifest"
(hub / ".piper").mkdir(parents=True)
manifest = hub / ".piper/hub-manifest.json"
for data in ("invalid JSON", '[]', '{"managed_files": "bad"}', '{"runtimes": [1]}'):
    manifest.write_text(data)
    rejects_without_mutation(hub, "invalid existing hub manifest")
for rel in ("../outside", "a/../../outside", "/absolute", "a\\b", "a\nb", "a\tb"):
    manifest.write_text(json.dumps({"managed_files": [rel]}))
    rejects_without_mutation(hub, "unsafe managed manifest path")

guard_outside = TMP / "guard_outside"
guard_outside.mkdir()
(guard_outside / "sentinel").write_text("keep external files\n")
hub = TMP / "symlinked-destination"
hub.mkdir()
(hub / ".codex").symlink_to(guard_outside, target_is_directory=True)
external_before = snapshot(guard_outside)
rejects_without_mutation(hub, "uses a symlink")
assert snapshot(guard_outside) == external_before

hub = TMP / "file-directory-collision"
(hub / "STATION.md").mkdir(parents=True)
rejects_without_mutation(hub, "is not a file")

# Resolve target aliases physically before refusing the source distribution.
alias = TMP / "source-alias"
alias.symlink_to(ROOT, target_is_directory=True)
result = subprocess.run([str(BOOTSTRAP), str(alias)], capture_output=True, text=True)
assert result.returncode != 0 and "bootstrap source" in result.stderr, result.stderr
case_alias = ROOT.with_name(ROOT.name.swapcase())
if case_alias.exists() and os.path.samefile(case_alias, ROOT):
    result = subprocess.run([str(BOOTSTRAP), "--dry-run", str(case_alias)], capture_output=True, text=True)
    assert result.returncode != 0 and "bootstrap source" in result.stderr, result.stderr

# A refresh repairs executable modes and keeps user-owned project files intact.
hub = TMP / "refresh"
subprocess.run([str(BOOTSTRAP), str(hub)], check=True, stdout=subprocess.DEVNULL)
(hub / "bin/add-project").chmod(0o644)
(hub / "projects/README.md").write_text("custom project guidance\n")
(hub / "local-note.md").write_text("unmanaged hub note\n")
subprocess.run([str(BOOTSTRAP), "--runtime", "codex", str(hub)], check=True, stdout=subprocess.DEVNULL)
assert (hub / "bin/add-project").stat().st_mode & 0o111
assert (hub / "projects/README.md").read_text() == "custom project guidance\n"
assert (hub / "local-note.md").read_text() == "unmanaged hub note\n"
manifest_data = json.loads((hub / ".piper/hub-manifest.json").read_text())
assert manifest_data["runtimes"] == ["codex"]
assert not any(p.startswith("projects/") for p in manifest_data["managed_files"])

def check_role_migration():
    # The distribution owns three roles. Custom unmanaged roles and old assignment
    # records must survive a refresh from the previous seven-role installation.
    hub = TMP / "role-migration"
    subprocess.run([str(BOOTSTRAP), str(hub)], check=True, stdout=subprocess.DEVNULL)
    manifest_data = json.loads((hub / ".piper/hub-manifest.json").read_text())
    role_names = {"investigator", "implementer", "reviewer"}
    role_dir = hub / ".codex/agents"
    assert {p.stem for p in role_dir.glob("*.toml")} == role_names
    declared = set(re.findall(r"^\[agents\.([^]]+)\]$", (hub / ".codex/config.toml").read_text(), re.M))
    assert declared == role_names
    for name in role_names:
        assert f'config_file = "./agents/{name}.toml"' in (hub / ".codex/config.toml").read_text()
        assert f'name = "{name}"' in (role_dir / f"{name}.toml").read_text()

    retired = ("architect", "docs-researcher", "security-reviewer", "tester", "verifier")
    for name in retired:
        relative = f".codex/agents/{name}.toml"
        (hub / relative).write_text(f'name = "{name.replace("-", "_")}"\n# old managed role\n')
        manifest_data["managed_files"].append(relative)
    (role_dir / "investigator.toml").unlink()
    manifest_data["managed_files"].remove(".codex/agents/investigator.toml")
    (hub / ".codex/config.toml").write_text("\n".join(
        f'[agents.{name.replace("-", "_")}]\nconfig_file = "./agents/{name}.toml"'
        for name in (*retired, "implementer", "reviewer")))
    (hub / ".piper/hub-manifest.json").write_text(json.dumps(manifest_data))
    (role_dir / "custom-local.toml").write_text('name = "custom_local"\n# user-owned role\n')
    retained = hub / "projects/example/work/lanes/paused/context-pack.md"
    retained.parent.mkdir(parents=True)
    retained.write_text("Paused tester assignment; native handle is historical.\nKeep checkout and dirty source; resolve ownership before reassignment.\n")
    custom_before = (role_dir / "custom-local.toml").read_bytes()
    source = TMP / "retained-source"
    source.mkdir()
    (source / "partial.py").write_text("# unfinished user source\n")
    (hub / "projects/example/project.md").write_text(f"# Retained project\n- Path: `{source}`\n")
    project_before = snapshot(hub / "projects")
    source_before = snapshot(source)
    before = snapshot(hub)
    subprocess.run([str(BOOTSTRAP), "--dry-run", str(hub)], check=True, stdout=subprocess.DEVNULL)
    assert snapshot(hub) == before, "role-upgrade dry run mutated the hub"
    subprocess.run([str(BOOTSTRAP), str(hub)], check=True, stdout=subprocess.DEVNULL)
    assert snapshot(hub / "projects") == project_before
    assert snapshot(source) == source_before
    assert (role_dir / "custom-local.toml").read_bytes() == custom_before
    assert {p.stem for p in role_dir.glob("*.toml")} == role_names | {"custom-local"}
    assert (hub / ".codex/config.toml").read_bytes() == (ROOT / "generated/codex/.codex/config.toml").read_bytes()
    manifest_data = json.loads((hub / ".piper/hub-manifest.json").read_text())
    assert {Path(p).stem for p in manifest_data["managed_files"] if p.startswith(".codex/agents/")} == role_names


check_role_migration()

# Even an old manifest using alternate spelling cannot own project records.
for relative in ("./projects/legacy.md", "Projects/legacy.md"):
    project_record = hub / relative
    project_record.parent.mkdir(exist_ok=True)
    project_record.write_text("preserve hub-owned project history\n")
    manifest_data["managed_files"].append(relative)
    (hub / ".piper/hub-manifest.json").write_text(json.dumps(manifest_data))
    result = subprocess.run([str(BOOTSTRAP), "--dry-run", str(hub)], capture_output=True, text=True, check=True)
    assert f"would remove stale managed hub file: {relative}" not in result.stdout
    subprocess.run([str(BOOTSTRAP), str(hub)], check=True, stdout=subprocess.DEVNULL)
    assert project_record.read_text() == "preserve hub-owned project history\n"

# Reserved operational files can never be stale managed template output.
for index, relative in enumerate((".git/config", ".git", ".piper/locks/records.lock", ".piper/locks",
                                  ".GIT/config", ".Git", ".PIPER/LOCKS/records.lock", ".piper/Locks")):
    reserved_hub = TMP / f"reserved-{index}"
    (reserved_hub / ".piper/locks").mkdir(parents=True)
    (reserved_hub / ".git").mkdir()
    (reserved_hub / ".git/config").write_text("preserve Git configuration\n")
    (reserved_hub / ".piper/locks/records.lock").write_text("preserve lock inode\n")
    (reserved_hub / ".piper/hub-manifest.json").write_text(json.dumps({"managed_files": [relative]}))
    rejects_without_mutation(reserved_hub, "reserved operational path")
    rejects_without_mutation(reserved_hub, "reserved operational path", "--dry-run")


def registration_fixture(name):
    fixture = TMP / name
    fixture_hub, fixture_repo, outside = fixture / "hub", fixture / "repo", fixture / "outside"
    (fixture_hub / "projects").mkdir(parents=True)
    (fixture_hub / "STATION.md").write_text("hub\n")
    fixture_repo.mkdir(); outside.mkdir()
    subprocess.run(["git", "-C", str(fixture_repo), "init", "-q"], check=True)
    (outside / "sentinel").write_text("preserve outside state\n")
    return fixture, fixture_hub, fixture_repo, outside


# Destination traversal/collisions fail before records, markers, or locks land.
for kind in ("projects", "project-directory", "project-record", "memory-record", "marker-directory", "marker-file", "piper-file", "registry-directory", "registry-json"):
    fixture, fixture_hub, fixture_repo, outside = registration_fixture("registration-" + kind)
    if kind == "projects":
        (fixture_hub / "projects").rmdir()
        (fixture_hub / "projects").symlink_to(outside, target_is_directory=True)
    elif kind == "project-directory":
        (fixture_hub / "projects/example").symlink_to(outside, target_is_directory=True)
    elif kind in ("project-record", "memory-record"):
        project_dir = fixture_hub / "projects/example"
        project_dir.mkdir()
        (project_dir / "project.md").write_text(f"# Example\n- Path: `{fixture_repo}`\n")
        target = project_dir / ("project.md" if kind == "project-record" else "memory.md")
        if target.exists(): target.unlink()
        target.symlink_to(outside / "sentinel")
    elif kind == "marker-directory":
        (fixture_repo / ".piper").symlink_to(outside, target_is_directory=True)
    elif kind == "marker-file":
        (fixture_repo / ".piper").mkdir()
        (fixture_repo / ".piper/project.json").symlink_to(outside / "sentinel")
    elif kind == "piper-file":
        (fixture_repo / "PIPER.md").symlink_to(outside / "sentinel")
    elif kind == "registry-directory":
        (fixture_hub / "projects/registry.json").mkdir()
    else:
        (fixture_hub / "projects/registry.json").write_text('{"projects": [null]}')
    before = snapshot(fixture)
    args = [str(ROOT / "bootstrap/add-project.sh"), "--hub", str(fixture_hub), "--repo", str(fixture_repo), "--project-id", "example"]
    for mode in (["--dry-run"], []):
        result = subprocess.run([*args, *mode], text=True, capture_output=True)
        assert result.returncode != 0, (kind, mode, result.stdout)
        assert snapshot(fixture) == before, (kind, mode, "rejected registration changed files")

# Rebuild must not read a linked project from outside the registered records.
fixture, fixture_hub, fixture_repo, outside = registration_fixture("rebuild-linked")
(outside / "project.md").write_text(f"# External\n<!-- piper-project:start -->\n- Path: `{fixture_repo}`\n<!-- piper-project:end -->\n")
(fixture_hub / "projects/external").symlink_to(outside, target_is_directory=True)
before = snapshot(fixture)
result = subprocess.run([str(ROOT / "bootstrap/add-project.sh"), "--hub", str(fixture_hub), "--rebuild"], text=True, capture_output=True)
assert result.returncode != 0 and snapshot(fixture) == before, result.stdout + result.stderr

# --git-init creates an actual hub root, even under another repository, so
# a checkpoint can never accidentally commit into that enclosing repository.
parent = TMP / "parent-repository"
parent.mkdir()
subprocess.run(["git", "-C", str(parent), "init", "-q"], check=True)
parent_git_before = snapshot(parent / ".git")
nested = parent / "nested-hub"
subprocess.run([str(BOOTSTRAP), "--git-init", "--dry-run", str(nested)], check=True, stdout=subprocess.DEVNULL)
assert not nested.exists() and snapshot(parent / ".git") == parent_git_before
subprocess.run([str(BOOTSTRAP), "--git-init", str(nested)], check=True, stdout=subprocess.DEVNULL)
actual_root = subprocess.check_output(["git", "-C", str(nested), "rev-parse", "--show-toplevel"], text=True).strip()
assert Path(actual_root).resolve() == nested
for key, value in (("user.name", "Distribution Test"), ("user.email", "distribution@example.invalid"), ("commit.gpgsign", "false"), ("core.hooksPath", os.devnull)):
    subprocess.run(["git", "-C", str(nested), "config", key, value], check=True)
fixture, ignored_hub, nested_source, outside = registration_fixture("nested-source")
subprocess.run([str(nested / "bin/add-project"), "--repo", str(nested_source), "--project-id", "example", "--hub-only"], check=True, stdout=subprocess.DEVNULL)
subprocess.run([str(nested / "bin/piper-record"), "--project", str(nested / "projects/example"), "commit", "--paths", "memory.md", "--message", "Checkpoint"], check=True, stdout=subprocess.DEVNULL)
assert snapshot(parent / ".git") == parent_git_before, "hub checkpoint changed parent Git metadata"

# Registration is a supported shared writer: it must serialize its complete
# read/modify/write with piper-record and preserve concurrent contributions.
registration_source = TMP / "registration-source"
registration_source.mkdir()
subprocess.run(["git", "-C", str(registration_source), "init", "-q"], check=True)
registration = [str(ROOT / "bootstrap/add-project.sh"), "--hub", str(hub), "--repo",
                str(registration_source), "--project-id", "example", "--hub-only"]
subprocess.run(registration, check=True, stdout=subprocess.DEVNULL)
project = hub / "projects/example"
record = [sys.executable, str(hub / "bin/piper-record"), "--project", str(project)]
original = json.loads(subprocess.check_output([*record, "read", "project.md"], text=True))
started, release = TMP / "registration-started", TMP / "registration-release"
bindir = TMP / "registration-bin"
bindir.mkdir()
shim = bindir / "mv"
shim.write_text(f"#!{sys.executable}\n" +
    "from pathlib import Path\nimport subprocess,sys,time\n" +
    f"if sys.argv[-1] == {str(project / 'project.md')!r}:\n" +
    f" Path({str(started)!r}).touch()\n" +
    " deadline=time.monotonic()+10\n" +
    f" while not Path({str(release)!r}).exists() and time.monotonic()<deadline: time.sleep(.02)\n" +
    f"sys.exit(subprocess.call([{shutil.which('mv')!r}, *sys.argv[1:]]))\n")
shim.chmod(0o755)
writer = subprocess.Popen([*registration, "--display-name", "Updated project"],
                          env=dict(os.environ, PATH=str(bindir)+os.pathsep+os.environ["PATH"]),
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
proposal = TMP / "registration-proposal.md"
proposal.write_text(original["content"] + "\nStanding note: preserve concurrent contribution.\n")
try:
    deadline = time.monotonic() + 5
    while not started.exists() and time.monotonic() < deadline:
        time.sleep(.02)
    assert started.exists(), "registration did not reach replacement"
    blocked = subprocess.run([*record, "--lock-timeout", "0.05", "replace", "project.md",
                              "--expected", original["digest"], "--content-file", str(proposal)],
                             capture_output=True, text=True, timeout=5)
    assert blocked.returncode == 2 and "lock is busy" in blocked.stdout, blocked.stdout + blocked.stderr
finally:
    release.touch()
    stdout, stderr = writer.communicate(timeout=10)
assert writer.returncode == 0, stdout + stderr
conflict = subprocess.run([*record, "replace", "project.md", "--expected", original["digest"],
                           "--content-file", str(proposal)], capture_output=True, text=True)
assert conflict.returncode == 3, conflict.stdout + conflict.stderr
current = json.loads(conflict.stdout)
assert "Updated project" in current["content"]
proposal.write_text(current["content"] + "\nStanding note: preserve concurrent contribution.\n")
subprocess.run([*record, "replace", "project.md", "--expected", current["digest"],
                "--content-file", str(proposal)], check=True, stdout=subprocess.DEVNULL)
assert "preserve concurrent contribution" in (project / "project.md").read_text()

# Killing the launcher does not release protection while its shell body is live.
started.unlink(); release.unlink()
writer = subprocess.Popen([*registration, "--display-name", "After interrupted launcher"],
                          env=dict(os.environ, PATH=str(bindir)+os.pathsep+os.environ["PATH"]),
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
try:
    deadline = time.monotonic() + 5
    while not started.exists() and time.monotonic() < deadline:
        time.sleep(.02)
    assert started.exists(), "registration body did not reach replacement"
    writer.kill()
    writer.wait(timeout=5)
    blocked = subprocess.run([*record, "--lock-timeout", "0.05", "replace", "project.md",
                              "--expected", current["digest"], "--content-file", str(proposal)],
                             capture_output=True, text=True, timeout=5)
    assert blocked.returncode == 2 and "lock is busy" in blocked.stdout, blocked.stdout + blocked.stderr
finally:
    release.touch()
    stdout, stderr = writer.communicate(timeout=10)
assert "After interrupted launcher" in (project / "project.md").read_text()
assert "preserve concurrent contribution" in (project / "project.md").read_text()

# All supported entry points use the same lock, while dry-run remains read-only.
for entry in (ROOT / "bootstrap/add-project.sh", hub / ".piper/lib/bootstrap/add-project.sh"):
    subprocess.run([str(entry), "--hub", str(hub), "--rebuild"], check=True,
                   stdout=subprocess.DEVNULL)
subprocess.run([str(hub / "bin/add-project"), "--rebuild"], check=True, stdout=subprocess.DEVNULL)
empty_hub = TMP / "dry-registration"
(empty_hub / "projects").mkdir(parents=True)
(empty_hub / "STATION.md").write_text("hub\n")
before = snapshot(empty_hub)
subprocess.run([str(ROOT / "bootstrap/add-project.sh"), "--hub", str(empty_hub),
                "--repo", str(registration_source), "--hub-only", "--dry-run"],
               check=True, stdout=subprocess.DEVNULL)
assert snapshot(empty_hub) == before, "registration dry-run created lock or records"

# Rebuild uses the managed display name, preserving a user's independent title.
target = project / "project.md"
text = target.read_text()
first_line, remaining = text.split("\n", 1)
target.write_text("# User-owned project title\n" + remaining)
subprocess.run([*registration, "--display-name", "Stable display"], check=True, stdout=subprocess.DEVNULL)
subprocess.run([str(ROOT / "bootstrap/add-project.sh"), "--hub", str(hub), "--rebuild"], check=True, stdout=subprocess.DEVNULL)
entry = next(item for item in json.loads((hub / "projects/registry.json").read_text())["projects"] if item["project_id"] == "example")
assert entry["display_name"] == "Stable display"
assert target.read_text().startswith("# User-owned project title\n")

spec = importlib.util.spec_from_file_location("piper_renderer", ROOT / "scripts/render_templates.py")
renderer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(renderer)
left, right = TMP / "expected", TMP / "actual"
left.mkdir(); right.mkdir()
(left / "entry").write_text("expected")
(right / "entry").mkdir()
assert renderer.compare_dirs(left, right), "file-directory mismatch was accepted"
shutil.rmtree(right / "entry")
(right / "entry").write_text("modified")
os.utime(right / "entry", ns=((left / "entry").stat().st_atime_ns, (left / "entry").stat().st_mtime_ns))
assert renderer.compare_dirs(left, right), "same-size/same-mtime content change was accepted"
(right / "entry").write_bytes((left / "entry").read_bytes())
(right / "entry").chmod(0o755)
assert renderer.compare_dirs(left, right), "executable mode mismatch was accepted"
(right / "entry").unlink()
(right / "entry").symlink_to(left / "entry")
assert renderer.compare_dirs(left, right), "generated symlink was accepted"

linked_output = TMP / "linked-output"
linked_output.symlink_to(guard_outside, target_is_directory=True)
try:
    renderer.render_all(linked_output)
except ValueError as exc:
    assert "through a symlink" in str(exc), str(exc)
else:
    raise AssertionError("renderer accepted a symlinked output root")
assert snapshot(guard_outside) == external_before

out = TMP / "rendered"
renderer.render_all(out)
(out / "retired-runtime").mkdir()
(out / "retired-runtime/stale.md").write_text("retired output")
renderer.render_all(out)
assert set(p.name for p in out.iterdir()) == {"codex", "claude", "copilot"}
assert not renderer.compare_dirs(ROOT / "generated", out)

# The renderer must reject future whole-file overrides, rather than silently
# shadowing core changes. Build an isolated source tree for the mutation.
source = TMP / "source"
shutil.copytree(ROOT / "core", source / "core")
shutil.copytree(ROOT / "adapters", source / "adapters")
override = source / "adapters/codex/.codex/skills/brainstorm/SKILL.md"
override.parent.mkdir(parents=True, exist_ok=True)
override.write_text("shadowed core")
renderer.ROOT = source
try:
    renderer.render_all(TMP / "collision-output")
except ValueError as exc:
    assert "shadows core behavior" in str(exc), str(exc)
else:
    raise AssertionError("renderer allowed a whole-file adapter override")
print("Distribution structural checks passed.")

# Static contracts belong at their canonical owner. Root and skill checks
# verify routing to those owners instead of requiring repeated policy blocks.
# Whitespace normalization prevents line wrapping from changing the result.
def requires(relative, *phrases):
    text = " ".join((hub / relative).read_text().split())
    for phrase in phrases:
        assert " ".join(phrase.split()) in text, f"{relative} lost contract: {phrase}"


requires("STATION.md",
    "Do not copy project source code into the hub.",
    "Registration creates no `work/` records.",
    "concurrency alone does not require a group.",
    "`studio:<slug>` | `work/design/<slug>/`",
    "`group:<gid>` | `work/groups/<gid>/`",
    "`lane:<slug>` | `work/lanes/<slug>/`",
    "One active coordinating session owns a lane at a time",
    "One checkout per writer.",
    "At most one active coordinating lane or worker writes a checkout.",
    "A token ambiguous between kinds requires clarification.",
    "multiple matching boundaries require a choice",
    "a studio is not an execution candidate",
    "Never switch or merge inside another lane's checkout.",
    "The default unit is one ungrouped wave.",
    "no roadmap or queue by default",
    "Finished work with no open state creates no packet",
    "Detail the current wave; sketch later waves only as far as the current code and evidence support.",
    "The only self-contained resume packet",
    "Project `work/build-log.md` | Flat-lane ledger and seam between independent lanes",
    "Record a per-wave acceptance commit once in the lane's ledger",
    "Other records reference the fact's owner instead of copying it.",
    "Do not create a session registry, daemon, global queue",
    "Sinks such as build logs accumulate concise meaningful history.",
    "Never prune durable history to make a window smaller.",
    "semantic as well as path overlap: disjoint files may rely on incompatible meanings.",
    "A finding that undermines an assumption is a proposal, not an accepted change.",
    "impact (`unaffected`, `needs-revalidation`, or `blocked`), and a resolution owner",
    "Do not edit another lane's current-work files on its behalf.",
    "Continue unaffected work. Suspend work that relies on an unresolved or stale contract.",
    "changes to product intent, a fixed contract, or a core premise return upstream for user alignment",
    "Never force a stale overwrite or silently drop the other contribution.",
    "Each file is atomic; a multi-file checkpoint is not a transaction.",
    "Never use `git add -A`, `commit -a`, or an ordinary unscoped commit in the shared hub.",
    "no separate per-edit or per-checkpoint ask is needed.",
    "Boundary triggers.",
    "Checkpoint invariant.",
    "Windows and ledger agree; a fresh session can resume from hub records and live source alone.",
    "Every roadmap acceptance has a corresponding closeout entry and vice versa.",
    "Disclose hub artifact changes separately and state their actual commit status.",
    "Scope tiers are advisory sizing, not artifact rules",
    "Risk tiers are implementation caution, not action classes.",
    "A prior explicit instruction or scoped waiver already covering that boundary satisfies L2; do not ask again.",
    "Review gates are required for `S2/S3` wave or group boundaries",
    "group-level review gate over the integrated cross-wave diff",
    "`confirmed-in-scope`, `confirmed-out-of-scope`, or `false-positive`",
    "do not continue to dependent tasks until the debt is resolved or explicitly accepted by the user.",
    "Entry.", "Execution.", "Closeout.", "Transition.",
    "If source integration succeeded but record publication did not, closeout remains incomplete",
    "Reconcile the roadmap acceptance, then rewrite lane windows to a short `closed` pointer.",
    "legacy studio, migrate only flat windows clearly belonging to that studio",
    "No bulk destructive migration is required.",
    "Goal", "Boundary", "Next exact action", "Verification and review state not yet in the ledger",
    "Blockers, risks, and open questions", "Stop reason", "broad-search triggers",
    "A stored session/worker handle is only a locator",
    "never duplicate work solely because a wait timed out.",
    "Read the old packet before rewriting, preserve every still-relevant non-derivable field",
    "Never regenerate solely from lossy compacted memory.",
    "A studio resumes its design phase without source edits",
    "do not claim compaction happened unless observed.")
requires("AGENTS.md",
    "`STATION.md` owns phase routing, lanes, artifact ownership, related work, checkpoints, review and resume.",
    "`automation-policy.md` owns action boundaries.",
    "`design-studio` is optional deeper durable design after explicit user choice.",
    "`piper-workflow` verifies converged direction and formalizes an execution boundary before Ralph edits.",
    "Read `RUNTIMES.md` for the active CLI's skill directory, invocation syntax,",
    "`$design-studio`", "`$piper-workflow`", "`$brainstorm`",
    "`piper-workflow/references/coordinated-work.md`",
    "`piper-workflow/references/integration.md`",
    "is for shared multi-wave acceptance, never forced by concurrency alone.",
    "Concurrent implementation workers need separate worktrees",
    "including `--add-dir <checkout-path>`",
    "Use `./bin/piper-record` for shared records and lane ownership publication.",
    "Never make an unscoped hub commit.",
    "A saved handle or status note is not proof of liveness or completion",
    "Complete explicit checkpoints even if hooks are unavailable.",
    "Use native role selection only when the active client's actual spawn tool exposes it.",
    "do not invent that argument or assume a role TOML was applied.",
    "include its behavioral brief in the explicit assignment using the supported tool parameters.",
    "when unavailable, report them as unverified.",
    "A read-only instruction is not proof of read-only sandbox enforcement",
    "the parent owns hub records, shared resolutions, integration, and acceptance.")
workflow = ".codex/skills/piper-workflow/"
requires(workflow + "SKILL.md",
    "This skill owns convergent execution.",
    "Ordinary brainstorm direction is valid input; a studio is optional.",
    "integer `revision`, and integer `accepted_revision`, both equal to handed-off `N`.",
    "Read explicitly adopted details and relevant linked evidence; verify fixed contracts and premises against live source.",
    "obtain explicit acceptance and reverify before relying on it.",
    "Record the pair rather than copying canonical design.",
    "Never execute a Ralph wave inside studio continuity.",
    "references/superpowers.md", "references/ralph.md", "references/compact-handoff.md",
    "references/coordinated-work.md", "references/integration.md",
    "Keep acceptance, actual integration, and pending PR state distinct.")
requires(workflow + "references/superpowers.md",
    "## Structural Planning", "## Wave Formalization",
    "Require `status: accepted-for-planning` and both current metadata revisions equal to N.",
    "missing, provisional, superseded, or mismatched revision returns upstream",
    "Read significant supporting artifacts and source evidence.",
    "Concurrency alone chooses a named execution lane",
    "Group folders are created at Entry",
    "Give the current wave testable acceptance criteria, expected source boundary, meaningful verification, review expectations, stop conditions",
    "with group review before acceptance.",
    "Stop before implementation unless the user already asked to proceed.",
    "planning never makes source edits.")
requires(workflow + "references/ralph.md",
    "A pending group review precedes group acceptance.",
    "If the current wave is only a sketch, run Wave Formalization",
    "later sketches do not shrink the current assignment.",
    "A stale fixed contract blocks dependent execution until revalidated; unaffected work can proceed.",
    "Verify repo identity, assigned branch, exclusive checkout ownership",
    "external/exceptional action without its required go-ahead.",
    "Give every finding a verdict before review fixes",
    "Commit a completed wave's source on its assigned branch",
    "Revalidation is required if base or candidate moves.",
    "Use a reviewer instructed to perform read-only work on actual changed code and surrounding behavior",
    "otherwise pass the installed reviewer's behavioral brief explicitly.",
    "A group requires integrated cross-wave review after its final wave",
    "Expected for meaningful S1 behavior changes; optional for S0/L0, docs-only, or trivial changes.",
    "never substitutes invented output or weakened acceptance.",
    "Never claim completion without fresh verification evidence.")
requires(workflow + "references/compact-handoff.md",
    "STATION → Compaction for the canonical packet fields",
    "prepare a full replacement outside hub records with only the non-derivable fields owned by STATION.",
    "Do not append, section-edit, or regenerate solely from lossy compacted memory.",
    "If stale, reread and reconcile before retry.",
    "Finished small work with no open state needs no new packet.",
    "Studio resume stays in the design phase.",
    "finish publication instead of repeating the merge.")
requires(workflow + "references/coordinated-work.md",
    "Ordinary single-session fixes do not need worker plans or relationship registers.",
    "Inspect the active spawn tool's supported parameters.",
    "never manufacture an `agent_type` parameter or imply that naming a role applied its configuration.",
    "state unknown when they cannot be established.",
    "The review assignment still forbids source/record edits, commits and integration even if the worker inherits broader capabilities.",
    "Missing records do not prove a checkout is idle.",
    "rejects duplicate checkout claims across flat, group, and named lanes under the shared record lock.",
    "Sequence tightly coupled work; do not manufacture parallelism.",
    "Use writable helpers only when the user authorizes implementation delegation.",
    "Prepare a separate project worktree outside the hub, on a distinct branch",
    "No worker writes its inherited parent checkout as a fallback.",
    "Treat these as evidence to inspect, not an acceptance verdict.",
    "A wait timeout is not terminal status; wait again on the same live handle.")
requires(workflow + "references/integration.md",
    "A paused lane still owns its recorded checkout.",
    "Require clean candidate and target checkouts.",
    "Keep the full tested base and verified candidate object IDs",
    "--expected-base <full-base-oid>", "--verified-head <full-candidate-oid>",
    "Do not simply replace expected IDs to silence the guard.",
    "Source publication plus missing records is incomplete closeout",
    "never report pending work as merged.")
requires(".codex/skills/design-studio/SKILL.md",
    "Different studios can remain independently active and resumable.",
    "without rewriting its working state.",
    "Combining designs means reconciling assumptions and assigning one canonical home to shared behavior.",
    "A finding can conclude an investigation without implementation.",
    "Only an explicit user signal may set `status: accepted-for-planning`",
    "If a material change follows acceptance, increment the revision",
    "preserve unrelated execution state",
    "Never overwrite another studio's working context or accept its proposals on the user's behalf.")
requires(".codex/agents/implementer.toml",
    "if missing, edit nothing and report the gap.",
    "Never use the inherited parent checkout as fallback",
    "Concurrent source-writing workers require separate checkouts",
    "Do not write hub records, integrate into base, spawn other workers",
    "The coordinator owns acceptance.")
requires(".codex/agents/reviewer.toml",
    "sandbox_mode = \"read-only\"",
    "First check acceptance, scope, non-goals, changed assumptions and missing work; then correctness",
    "cross-wave/cross-worker behavior and related contracts",
    "State actual observed source identities and verification limits.",
    "Do not repair findings or accept the result.")
requires(".codex/compact-prompt.md",
    "canonical lane locator (`flat`, `studio:<slug>`, `group:<gid>`, or `lane:<slug>`)",
    "The summary is supplemental recall",
    "old packet before any replacement, preserving still-relevant state.",
    "a wait timeout is nonterminal",
    "Resume the selected phase.")

# Exercise actual hook output for all locator kinds and malformed input.
lanes = hub / "projects/hook-example/work"
(lanes / "groups/group-one").mkdir(parents=True)
(lanes / "design/design-one").mkdir(parents=True)
(lanes / "lanes/fix-one").mkdir(parents=True)
(lanes.parent / "project.md").write_text("# Hook example\n")
for rel in ("active-work.md", "groups/group-one/active-work.md", "design/design-one/design.md", "lanes/fix-one/context-pack.md"):
    (lanes / rel).write_text("preserve this record\n")
before = snapshot(hub)
for event in ('{}', '{"source":"resume"}', '{"source":"compact"}', 'not json', '[]'):
    result = subprocess.run(["sh", str(hub / ".codex/hooks/session-context.sh")], cwd=hub,
                            input=event, text=True, capture_output=True, check=True)
    response = json.loads(result.stdout)
    output = response["hookSpecificOutput"]
    assert output["hookEventName"] == "SessionStart"
    context = output["additionalContext"]
    for locator in ("flat ->", "studio:design-one ->", "group:group-one ->", "lane:fix-one ->"):
        assert locator in context, (event, locator, context)
    assert "not a liveness claim" in context
    if 'resume' in event or 'compact' in event:
        assert "Resume guidance" in context and "a wait timeout is not terminal" in context
for hook in ("pre-compact-protection.sh", "post-compact-resume.sh"):
    result = subprocess.run(["sh", str(hub / ".codex/hooks" / hook)], cwd=hub,
                            capture_output=True, text=True, check=True)
    response = json.loads(result.stdout)
    assert "systemMessage" in response
assert snapshot(hub) == before, "lifecycle hooks mutated hub records"

# Both executable helpers import the packaged ownership module. Importing from
# source, generated output, or an installed hub must leave no cache artifacts.
module_relative = Path(".piper/lib/work_ownership.py")
module_bytes = (ROOT / "core/shared" / module_relative).read_bytes()
for package in (ROOT / "core/shared", ROOT / "generated/codex", hub):
    assert (package / module_relative).read_bytes() == module_bytes
    for command in ("piper-record", "piper-integrate"):
        subprocess.run([str(package / "bin" / command), "--help"], check=True, stdout=subprocess.DEVNULL)
    caches = [p for p in (package / ".piper/lib").rglob("*")
              if p.name == "__pycache__" or p.suffix in (".pyc", ".pyo")]
    assert not caches, (package, "helper imports left Python cache artifacts", caches)
for source in (ROOT / "core/shared" / module_relative, ROOT / "generated/codex" / module_relative):
    ignored = subprocess.run(["git", "-C", str(ROOT), "check-ignore", "-q", str(source)])
    assert ignored.returncode == 1, (source, "ownership module must ship in distribution")
assert str(module_relative) in json.loads((hub / ".piper/hub-manifest.json").read_text())["managed_files"]
print("Canonical instructions, role ownership and lifecycle checks passed.")
