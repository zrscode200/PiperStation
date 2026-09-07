#!/usr/bin/env python3
"""Exercise cooperative record writes and shared-index commits with real processes."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time
import unittest


HELPER = Path(__file__).resolve().parents[1] / "core/shared/bin/piper-record"


class RecordTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="piper-record-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.hub = self.root / "hub"
        self.project = self.hub / "projects/example"
        self.project.mkdir(parents=True)
        (self.hub / "STATION.md").write_text("Piper hub\n")
        (self.project / "project.md").write_text("# Example\n")
        self.proposal = self.root / "proposal.md"
        self.proposal.write_text("new record\n")
        self.env = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
        self.env.update(GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")

    def cmd(self, *args, project=None, timeout=5):
        return [sys.executable, str(HELPER), "--project", str(project or self.project),
                "--lock-timeout", str(timeout), *map(str, args)]

    def run_record(self, *args, expected=0, **kwargs):
        result = subprocess.run(self.cmd(*args, **kwargs), text=True, env=self.env,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=15)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return json.loads(result.stdout)

    def git(self, *args):
        return subprocess.run(["git", "-C", str(self.hub), *args], env=self.env, check=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout

    def init_git(self):
        self.git("init", "-q", "-b", "main")
        self.git("config", "user.name", "Record Test")
        self.git("config", "user.email", "record@example.invalid")
        self.git("config", "commit.gpgsign", "false")
        (self.hub / ".gitignore").write_text(".piper/locks/\n")
        self.git("add", ".")
        self.git("commit", "-qm", "base")

    def write(self, path="memory.md", expected="missing", content=None, code=0):
        if content is not None:
            self.proposal.write_text(content)
        return self.run_record("replace", path, "--expected", expected, "--content-file", self.proposal,
                               expected=code)

    def register_checkout(self):
        checkout = self.root / "source"
        checkout.mkdir()
        (self.project / "project.md").write_text(
            "# Example\n<!-- piper-project:start -->\n"
            f"- Project ID: `example`\n- Path: `{checkout}`\n"
            "<!-- piper-project:end -->\n"
        )
        return checkout

    @staticmethod
    def binding(checkout, status="active"):
        return f"# Current work\ncheckout: `{checkout}`\nstatus: {status}\n\n## Wave\nWork.\n"

    def test_distinct_simultaneous_lane_claims_have_one_checkout_owner(self):
        checkout = self.register_checkout()
        paths = ["work/lanes/ingestion/active-work.md", "work/lanes/consumption/active-work.md"]
        proposals = [self.root / f"claim-{i}.md" for i in range(2)]
        for proposal in proposals:
            proposal.write_text(self.binding(checkout))
        processes = [subprocess.Popen(self.cmd("replace", path, "--expected", "missing",
                     "--content-file", proposal), env=self.env, text=True,
                     stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                     for path, proposal in zip(paths, proposals)]
        outputs = [process.communicate(timeout=10) for process in processes]
        self.assertEqual(sorted(process.returncode for process in processes), [0, 2], outputs)
        winner = next(path for path, process in zip(paths, processes) if process.returncode == 0)
        loser = next(path for path, process in zip(paths, processes) if process.returncode != 0)
        rejected = next(json.loads(output[0]) for process, output in zip(processes, outputs) if process.returncode != 0)
        self.assertIn(winner, rejected["message"])
        self.assertFalse((self.project / loser).exists())
        self.assertEqual((self.project / winner).read_text(), self.binding(checkout))

    def test_checkout_aliases_conflict_across_group_and_named_lane(self):
        checkout = self.register_checkout()
        alias = self.root / "source-alias"
        alias.symlink_to(checkout, target_is_directory=True)
        self.write("work/groups/ingestion/active-work.md", content=self.binding(checkout))
        aliases = [alias, checkout / ".." / checkout.name]
        case_alias = checkout.with_name(checkout.name.upper())
        if case_alias.exists():
            aliases.append(case_alias)
        for value in aliases:
            result = self.write("work/lanes/consumption/active-work.md", content=self.binding(value), code=2)
            self.assertIn("work/groups/ingestion/active-work.md", result["message"])

    def test_reserved_execution_record_case_aliases_cannot_bypass_claim_guard(self):
        checkout = self.register_checkout()
        first = "work/lanes/first/active-work.md"
        self.write(first, content=self.binding(checkout))
        for path in ("work/lanes/second/ACTIVE-WORK.md", "work/LANES/second/active-work.md",
                     "work/GROUPS/second/active-work.md", "work/Active-Work.md"):
            with self.subTest(path=path):
                result = self.write(path, content=self.binding(checkout), code=2)
                self.assertIn("canonical lowercase", result["message"])
                self.assertFalse((self.project / path).exists())
        self.assertEqual((self.project / first).read_text(), self.binding(checkout))

    def test_own_lane_directory_case_alias_does_not_conflict_with_itself(self):
        checkout = self.register_checkout()
        path = "work/groups/owned/active-work.md"
        initial = self.write(path, content=self.binding(checkout))
        alias = "work/groups/OWNED/active-work.md"
        if not (self.project / alias).exists():
            self.skipTest("Filesystem does not provide case aliases")
        self.write(alias, expected=initial["digest"], content=self.binding(checkout, "paused"))
        self.assertEqual((self.project / path).read_text(), self.binding(checkout, "paused"))

    def test_own_update_and_closed_release_allow_checkout_reassignment(self):
        checkout = self.register_checkout()
        first, second = "work/groups/first/active-work.md", "work/lanes/second/active-work.md"
        initial = self.write(first, content=self.binding(checkout))
        paused = self.write(first, expected=initial["digest"], content=self.binding(checkout, "paused"))
        self.write(second, content=self.binding(checkout), code=2)
        self.write(first, expected=paused["digest"], content="# Closed\nstatus: closed\n")
        self.write(second, content=self.binding(checkout))

    def test_studios_are_not_writers_and_different_checkouts_coexist(self):
        checkout = self.register_checkout()
        other = self.root / "other-checkout"
        other.mkdir()
        # Only the canonical execution layouts carry source ownership. Other
        # Markdown may discuss checkout values without accidentally claiming one.
        for path in ("work/design/ingestion/active-work.md", "work/notes/active-work.md"):
            self.write(path, content=self.binding(checkout))
        self.write("work/lanes/ingestion/active-work.md", content=self.binding(checkout))
        self.write("work/groups/consumption/active-work.md", content=self.binding(other))

    def test_flat_legacy_binding_owns_registered_checkout(self):
        checkout = self.register_checkout()
        initial = self.write("work/active-work.md", content="# Current ordinary work\nInvestigate.\n")
        rejected = self.write("work/lanes/another/active-work.md", content=self.binding(checkout), code=2)
        self.assertIn("work/active-work.md", rejected["message"])
        self.write("work/active-work.md", expected=initial["digest"], content="status: closed\n")
        self.write("work/lanes/another/active-work.md", content=self.binding(checkout))

    def test_missing_and_ambiguous_claims_are_rejected_before_writing(self):
        checkout = self.register_checkout()
        path = "work/lanes/proposed/active-work.md"
        for content in ("status: active\n", self.binding("relative/path"),
                        f"status: active\ncheckout: {checkout}\ncheckout: {checkout}\n",
                        f"status: closed\nstatus: active\ncheckout: {checkout}\n"):
            self.write(path, content=content, code=2)
            self.assertFalse((self.project / path).exists())
        other = self.project / "work/groups/ambiguous"
        other.mkdir(parents=True)
        self.write(path, content=self.binding(checkout), code=2)
        # Explicitly releasing the malformed record remains possible.
        self.write("work/groups/ambiguous/active-work.md", content="status: closed\n")
        self.write(path, content=self.binding(checkout))

    def test_claims_require_registration_but_ordinary_records_and_release_do_not(self):
        self.write("work/lanes/proposed/active-work.md", content=self.binding(self.root), code=2)
        self.write("memory.md", content="Ordinary durable knowledge.\n")
        self.write("work/lanes/proposed/active-work.md", content="status: closed\n")

    def test_cas_conflict_precedes_proposed_binding_validation(self):
        checkout = self.register_checkout()
        path = "work/lanes/owned/active-work.md"
        accepted = self.write(path, content=self.binding(checkout))
        rejected = self.write(path, content="status: active\n", code=3)
        self.assertEqual(rejected["status"], "conflict")
        self.assertEqual(rejected["digest"], accepted["digest"])

    def test_claim_scan_rejects_symlinked_ownership_tree(self):
        checkout = self.register_checkout()
        external = self.root / "external"
        external.mkdir()
        (self.project / "work").mkdir()
        (self.project / "work/groups").symlink_to(external, target_is_directory=True)
        self.write("work/lanes/proposed/active-work.md", content=self.binding(checkout), code=2)
        self.assertEqual(list(external.iterdir()), [])

    def test_read_only_missing_and_replace_preserve_utf8_and_mode(self):
        record = self.run_record("read", "work/design/topic/context-pack.md")
        self.assertEqual(record["digest"], "missing")
        self.assertFalse((self.project / "work").exists())
        self.assertFalse((self.hub / ".piper").exists())
        result = self.write(content="Café, 研究\n")
        target = self.project / "memory.md"
        target.chmod(0o640)
        self.assertEqual(result["digest"], hashlib.sha256(target.read_bytes()).hexdigest())
        self.write(expected=result["digest"], content="Preserved\n")
        self.assertEqual(target.stat().st_mode & 0o777, 0o640)

    def test_conflict_reports_current_and_reconciliation_preserves_both(self):
        result = self.write(content="original\n")
        self.write(expected=result["digest"], content="original\nA accepted\n")
        conflict = self.write(expected=result["digest"], content="original\nB proposed\n", code=3)
        self.assertEqual(conflict["content"], "original\nA accepted\n")
        self.write(expected=conflict["digest"], content=conflict["content"] + "B proposed\n")
        self.assertEqual((self.project / "memory.md").read_text(), "original\nA accepted\nB proposed\n")

    def test_simultaneous_create_and_replace_have_one_winner(self):
        for initial in ("missing", "existing"):
            with self.subTest(initial=initial):
                if initial == "missing":
                    digest = "missing"
                else:
                    digest = self.run_record("read", "memory.md")["digest"]
                proposals = []
                for i in range(2):
                    proposal = self.root / f"proposal-{i}.md"
                    proposal.write_text(f"{initial} writer {i}\n")
                    proposals.append(proposal)
                command = ["replace", "memory.md", "--expected", digest, "--content-file"]
                processes = [subprocess.Popen(self.cmd(*command, p), env=self.env, text=True,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE) for p in proposals]
                outputs = [p.communicate(timeout=10) for p in processes]
                self.assertEqual(sorted(p.returncode for p in processes), [0, 3], outputs)
                winner = [json.loads(out[0]) for p, out in zip(processes, outputs) if p.returncode == 0][0]
                self.assertEqual(self.run_record("read", "memory.md")["digest"], winner["digest"])

    def test_unsafe_record_paths_never_touch_outside(self):
        outside = self.root / "outside.md"
        outside.write_text("keep\n")
        for path in ("../outside.md", str(outside), "work/../memory.md", "work//thing.md",
                     ".git/config", "work/.private/info.md", "work/info.txt", "work/thing\n.md"):
            with self.subTest(path=path):
                self.write(path=path, code=2)
        (self.project / "memory.md").symlink_to(outside)
        self.write(code=2)
        self.run_record("read", "memory.md", expected=2)
        (self.project / "work").symlink_to(self.root, target_is_directory=True)
        self.write(path="work/outside.md", code=2)
        self.assertEqual(outside.read_text(), "keep\n")

    def test_directory_fifo_and_invalid_utf8_are_not_replaced(self):
        (self.project / "memory.md").mkdir()
        self.write(code=2)
        (self.project / "memory.md").rmdir()
        os.mkfifo(self.project / "memory.md")
        self.write(code=2)
        (self.project / "memory.md").unlink()
        self.proposal.write_bytes(b"\xff")
        self.write(code=2)
        self.assertFalse((self.project / "memory.md").exists())

    def test_symlinked_lock_refused(self):
        lockdir = self.hub / ".piper/locks"
        lockdir.mkdir(parents=True)
        outside = self.root / "outside"
        outside.write_text("keep\n")
        (lockdir / "records.lock").symlink_to(outside)
        self.write(code=2)
        self.assertEqual(outside.read_text(), "keep\n")

    def test_killed_lock_holder_releases_without_deleting_inode(self):
        self.write()
        lock = self.hub / ".piper/locks/records.lock"
        inode = lock.stat().st_ino
        holder = subprocess.Popen([sys.executable, "-u", "-c",
            "import fcntl,sys; f=open(sys.argv[1],'a'); fcntl.flock(f,fcntl.LOCK_EX); "
            "print('held',flush=True); sys.stdin.read()", str(lock)],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            self.assertEqual(holder.stdout.readline().strip(), "held")
            self.run_record("replace", "decisions.md", "--expected", "missing", "--content-file", self.proposal,
                            timeout=0.05, expected=2)
        finally:
            holder.kill()
            holder.communicate(timeout=5)
        self.write(path="decisions.md")
        self.assertEqual(lock.stat().st_ino, inode)

    def test_commit_selected_new_record_preserves_unrelated_partial_stage(self):
        other = self.hub / "unrelated.md"
        other.write_text("base\n")
        self.init_git()
        other.write_text("staged\n")
        self.git("add", "unrelated.md")
        other.write_text("unstaged\n")
        indexed = self.git("show", ":unrelated.md")
        self.write()
        result = self.run_record("commit", "--paths", "memory.md", "--message", "Record memory")
        self.assertEqual(result["status"], "committed", result)
        self.assertEqual(self.git("show", ":unrelated.md"), indexed)
        self.assertEqual(other.read_text(), "unstaged\n")
        self.assertEqual(self.git("show", "HEAD:unrelated.md"), b"base\n")
        self.assertEqual(self.git("diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD").strip(),
                         b"projects/example/memory.md")

    def test_commit_treats_pathspec_metacharacters_literally(self):
        self.init_git()
        self.write(path="work/[a].md", content="chosen\n")
        self.write(path="work/a.md", content="other\n")
        self.git("add", "projects/example/work/a.md")
        self.run_record("commit", "--paths", "work/[a].md", "--message", "Literal")
        self.assertEqual(self.git("show", "HEAD:projects/example/work/[a].md"), b"chosen\n")
        self.assertEqual(self.git("diff", "--cached", "--name-only").strip(), b"projects/example/work/a.md")

    def test_design_checkpoint_preserves_binary_assets_and_other_studio_index(self):
        other = self.project / "work/design/other/design.md"
        other.parent.mkdir(parents=True)
        other.write_text("base\n")
        self.init_git()
        other.write_text("staged\n")
        self.git("add", "projects/example/work/design/other/design.md")
        other.write_text("unstaged\n")
        indexed = self.git("ls-files", "--stage")
        studio = self.project / "work/design/recovery"
        studio.mkdir()
        artifacts = {
            "design.md": b"revision: 1\naccepted_revision: 1\nContract: [states](states.json).\n",
            "states.json": b'{"failure": "stop"}\n',
            "flow.svg": b'<svg xmlns="http://www.w3.org/2000/svg"/>\n',
            # Non-UTF-8 bytes must be preserved, not decoded as a Markdown record.
            "preview.png": b"\x89PNG\r\n\x1a\n\xff\x00",
            "build-log.md": b"User accepted revision 1 and the adopted states contract.\n",
        }
        for name, data in artifacts.items():
            (studio / name).write_bytes(data)
        paths = ["work/design/recovery/" + name for name in artifacts]
        result = self.run_record("commit", "--paths", *paths, "--message", "Accept recovery revision 1")
        for name, data in artifacts.items():
            path = "work/design/recovery/" + name
            self.assertEqual(self.git("show", f"{result['head']}:projects/example/{path}"), data)
            self.assertEqual(result["committed_digests"][path], hashlib.sha256(data).hexdigest())
        self.assertEqual(self.git("diff", "--cached", "--name-only").strip(),
                         b"projects/example/work/design/other/design.md")
        self.assertEqual(self.git("show", ":projects/example/work/design/other/design.md"), b"staged\n")
        self.assertEqual(other.read_text(), "unstaged\n")
        self.assertTrue(all(entry in self.git("ls-files", "--stage").splitlines()
                            for entry in indexed.splitlines()))

    def test_ordinary_acceptance_history_recovers_details_after_later_edits(self):
        self.init_git()
        studio = self.project / "work/design/recovery"
        studio.mkdir(parents=True)
        design = "work/design/recovery/design.md"
        evidence = "work/design/recovery/probe.md"
        detail = "work/design/recovery/states.mmd"
        ledger = "work/design/recovery/build-log.md"
        self.write(design, content="revision: 1\naccepted_revision: 1\nContract: [states](states.mmd).\n")
        self.write(evidence, content="2026-09-01: observed stop on failure at source A.\n")
        self.write(ledger, content="2026-09-02: user accepted revision 1, using probe.md.\n")
        (self.project / detail).write_text("stateDiagram-v2\n  Failed --> Stopped\n")
        accepted = self.run_record("commit", "--paths", design, evidence, detail, ledger,
                                   "--message", "Accept recovery revision 1")["head"]
        observation = (self.project / evidence).read_bytes()
        original = (self.project / detail).read_bytes()
        (self.project / evidence).write_bytes(observation + b"2026-09-03: source B changes retry; revalidate recovery.\n")
        (self.project / detail).write_text("stateDiagram-v2\n  Failed --> Retrying\n")
        self.run_record("commit", "--paths", evidence, detail, "--message", "Record later investigation")
        # Ordinary Git reveals changed supporting content even with the same
        # overview revision. This verifies recovery, not model judgment of drift.
        self.assertEqual(self.git("diff", "--name-only", accepted, "HEAD", "--",
                                 "projects/example/" + design), b"")
        self.assertIn(("projects/example/" + detail).encode(),
                      self.git("diff", "--name-only", accepted, "HEAD"))
        self.assertEqual(self.git("show", f"{accepted}:projects/example/{detail}"), original)
        self.assertEqual(self.git("show", f"{accepted}:projects/example/{evidence}"), observation)
        self.assertTrue((self.project / evidence).read_bytes().startswith(observation))

    def test_invalid_design_asset_selection_does_not_stage_valid_record(self):
        self.init_git()
        self.write()
        studio = self.project / "work/design/recovery"
        studio.mkdir(parents=True)
        outside = self.root / "outside.png"
        outside.write_bytes(b"external\xff")
        (studio / "link.png").symlink_to(outside)
        (studio / "alias").symlink_to(self.root, target_is_directory=True)
        (studio / "directory.png").mkdir()
        os.mkfifo(studio / "fifo.png")
        (studio / "executable.svg").write_text("<svg/>\n")
        (studio / "executable.svg").chmod(0o755)
        (studio / "prototype.py").write_text("print('source stays outside')\n")
        (self.project / "work/preview.png").write_bytes(b"wrong area")
        (studio / ".private").mkdir()
        (studio / ".private/preview.png").write_bytes(b"hidden")
        before = self.git("ls-files", "--stage")
        head = self.git("rev-parse", "HEAD")
        for path in ("work/preview.png", "work/design/recovery/link.png",
                     "work/design/recovery/alias/outside.png", "work/design/recovery/directory.png",
                     "work/design/recovery/fifo.png", "work/design/recovery/executable.svg",
                     "work/design/recovery/prototype.py", "work/design/recovery/missing.png",
                     "work/design/recovery/.private/preview.png", "work/design/../preview.png",
                     "../../STATION.md", str(outside)):
            with self.subTest(path=path):
                self.run_record("commit", "--paths", "memory.md", path, "--message", "Invalid", expected=2)
                self.assertEqual(self.git("ls-files", "--stage"), before)
                self.assertEqual(self.git("rev-parse", "HEAD"), head)
        self.assertEqual(outside.read_bytes(), b"external\xff")

    def test_design_assets_do_not_expand_markdown_mutation_commands(self):
        asset = self.project / "work/design/recovery/flow.svg"
        asset.parent.mkdir(parents=True)
        asset.write_bytes(b"<svg/>\n")
        self.run_record("read", "work/design/recovery/flow.svg", expected=2)
        self.write("work/design/recovery/flow.svg", content="replacement\n", code=2)
        self.assertEqual(asset.read_bytes(), b"<svg/>\n")

    def test_hook_mutating_selected_binary_asset_reports_actual_commit(self):
        self.init_git()
        asset = self.project / "work/design/recovery/preview.png"
        asset.parent.mkdir(parents=True)
        asset.write_bytes(b"\xfforiginal\x00")
        hook = self.hub / ".git/hooks/pre-commit"
        hook.write_text("#!/bin/sh\nprintf 'changed' > projects/example/work/design/recovery/preview.png\n"
                        "git add -- projects/example/work/design/recovery/preview.png\n")
        hook.chmod(0o755)
        result = self.run_record("commit", "--paths", "work/design/recovery/preview.png",
                                 "--message", "Hook changed asset", expected=4)
        self.assertEqual(result["status"], "committed-needs-attention")
        self.assertEqual(self.git("show", f"{result['head']}:projects/example/work/design/recovery/preview.png"),
                         b"changed")

    def test_hook_changing_only_asset_mode_is_reported_after_commit(self):
        self.init_git()
        path = "projects/example/work/design/recovery/flow.svg"
        asset = self.hub / path
        asset.parent.mkdir(parents=True)
        asset.write_text("<svg/>\n")
        hook = self.hub / ".git/hooks/pre-commit"
        hook.write_text(f"#!/bin/sh\nchmod +x {path}\ngit add -- {path}\n")
        hook.chmod(0o755)
        result = self.run_record("commit", "--paths", "work/design/recovery/flow.svg",
                                 "--message", "Hook changed mode", expected=4)
        self.assertEqual(result["status"], "committed-needs-attention")
        self.assertEqual(result["invalid_asset_modes"], [path])

    def test_commit_rejects_inherited_parent_repo_without_mutation(self):
        subprocess.run(["git", "init", "-q", str(self.root)], env=self.env, check=True)
        self.write()
        self.run_record("commit", "--paths", "memory.md", "--message", "No", expected=2)
        self.assertFalse((self.root / ".git/index").exists())

    def test_hook_failure_preserves_unrelated_stage_and_reports_no_commit(self):
        self.init_git()
        other = self.hub / "other.md"
        other.write_text("another lane\n")
        self.git("add", "other.md")
        hook = self.hub / ".git/hooks/pre-commit"
        hook.write_text("#!/bin/sh\nexit 1\n")
        hook.chmod(0o755)
        self.write()
        before = self.git("rev-parse", "HEAD")
        result = self.run_record("commit", "--paths", "memory.md", "--message", "Rejected", expected=2)
        self.assertEqual(result["status"], "not-committed")
        self.assertEqual(self.git("rev-parse", "HEAD"), before)
        self.assertEqual(self.git("show", ":other.md"), b"another lane\n")

    def test_hook_adds_other_path_is_reported_after_publication(self):
        self.init_git()
        self.write()
        (self.hub / "extra.md").write_text("hook addition\n")
        hook = self.hub / ".git/hooks/pre-commit"
        hook.write_text("#!/bin/sh\ngit add -- extra.md\n")
        hook.chmod(0o755)
        result = self.run_record("commit", "--paths", "memory.md", "--message", "Hook changed scope", expected=4)
        self.assertEqual(result["status"], "committed-needs-attention")
        self.assertEqual(result["unexpected_paths"], ["extra.md"])
        self.assertEqual(self.git("show", "HEAD:extra.md"), b"hook addition\n")

    def test_invalid_second_selection_does_not_stage_first(self):
        self.init_git()
        self.write()
        before = self.git("ls-files", "--stage")
        self.run_record("commit", "--paths", "memory.md", "work/missing.md", "--message", "Invalid", expected=2)
        self.assertEqual(self.git("ls-files", "--stage"), before)

    def test_commit_blob_digest_preserves_crlf(self):
        self.init_git()
        (self.project / "memory.md").write_bytes(b"windows\r\nrecord\r\n")
        result = self.run_record("commit", "--paths", "memory.md", "--message", "CRLF")
        self.assertEqual(result["status"], "committed")
        self.assertEqual(result["committed_digests"]["memory.md"],
                         hashlib.sha256(self.git("show", "HEAD:projects/example/memory.md")).hexdigest())

    def test_postcommit_inspection_failure_reports_changed_head(self):
        self.init_git()
        self.write()
        before = self.git("rev-parse", "HEAD").decode().strip()
        bindir = self.root / "bin"
        bindir.mkdir()
        wrapper = bindir / "git"
        wrapper.write_text(f"#!{sys.executable}\nimport subprocess,sys\n"
                           "if 'diff' in sys.argv[1:] and '--name-only' in sys.argv[1:]:\n"
                           " print('injected inspection failure',file=sys.stderr); sys.exit(42)\n"
                           f"sys.exit(subprocess.run([{shutil.which('git')!r},*sys.argv[1:]]).returncode)\n")
        wrapper.chmod(0o755)
        self.env["PATH"] = str(bindir) + os.pathsep + os.environ["PATH"]
        result = self.run_record("commit", "--paths", "memory.md", "--message", "Published", expected=4)
        self.assertEqual(result["status"], "commit-needs-inspection")
        self.assertTrue(result["head_changed"])
        self.assertEqual(result["previous_head"], before)
        self.assertEqual(result["observed_head"], self.git("rev-parse", "HEAD").decode().strip())

    def test_postcommit_hook_overwriting_unrelated_work_is_reported(self):
        other = self.hub / "other.md"
        other.write_text("base\n")
        self.init_git()
        other.write_text("staged\n")
        self.git("add", "other.md")
        other.write_text("unstaged\n")
        hook = self.hub / ".git/hooks/post-commit"
        hook.write_text("#!/bin/sh\nprintf 'hook overwrite\\n' > other.md\n")
        hook.chmod(0o755)
        self.write()
        result = self.run_record("commit", "--paths", "memory.md", "--message", "Hook", expected=4)
        self.assertEqual(result["status"], "committed-needs-attention")
        self.assertEqual(result["unrelated_worktree_changes"], ["other.md"])
        self.assertEqual(self.git("show", ":other.md"), b"staged\n")

    def test_unrelated_symlink_ancestor_never_reads_external_file(self):
        notes = self.hub / "notes"
        notes.mkdir()
        tracked = notes / "outside.md"
        tracked.write_text("tracked\n")
        self.init_git()
        tracked.unlink()
        notes.rmdir()
        outside = self.root / "outside"
        outside.mkdir()
        external = outside / "outside.md"
        external.write_text("private\n")
        external.chmod(0)
        self.addCleanup(external.chmod, 0o644)
        notes.symlink_to(outside, target_is_directory=True)
        self.write()
        result = self.run_record("commit", "--paths", "memory.md", "--message", "Bounded")
        self.assertEqual(result["status"], "committed")

    def test_non_utf8_hook_output_does_not_hide_published_commit(self):
        self.init_git()
        self.write()
        hook = self.hub / ".git/hooks/post-commit"
        hook.write_text("#!/bin/sh\nprintf '\\377'\n")
        hook.chmod(0o755)
        result = self.run_record("commit", "--paths", "memory.md", "--message", "Binary hook")
        self.assertEqual(result["status"], "committed")
        self.assertEqual(result["head"], self.git("rev-parse", "HEAD").decode().strip())


if __name__ == "__main__":
    unittest.main()
