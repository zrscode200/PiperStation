#!/usr/bin/env python3
"""Exercise source publication against disposable real Git worktrees."""
from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time
import unittest

HELPER = Path(__file__).resolve().parents[1] / "core/shared/bin/piper-integrate"
RECORD_HELPER = HELPER.with_name("piper-record")


class IntegrationTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="piper-integration-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.repo = self.root / "source"
        self.repo.mkdir()
        self.git(self.repo, "init", "-q", "-b", "main")
        self.git(self.repo, "config", "user.name", "Integration Test")
        self.git(self.repo, "config", "user.email", "integration@example.invalid")
        self.git(self.repo, "config", "commit.gpgsign", "false")
        (self.repo / "base.txt").write_text("base\n")
        self.git(self.repo, "add", "base.txt")
        self.git(self.repo, "commit", "-qm", "base")
        self.base = self.oid(self.repo)
        self.candidate = self.root / "candidate"
        self.git(self.repo, "worktree", "add", "-qb", "candidate", str(self.candidate))
        (self.candidate / "feature.txt").write_text("verified feature\n")
        self.git(self.candidate, "add", "feature.txt")
        self.git(self.candidate, "commit", "-qm", "candidate")
        self.verified = self.oid(self.candidate)
        self.project = self.root / "hub/projects/example"
        self.project.mkdir(parents=True)
        (self.root / "hub/STATION.md").write_text("Piper hub\n")
        (self.project / "project.md").write_text(
            "# Example\n<!-- piper-project:start -->\n"
            f"- Project ID: `example`\n- Path: `{self.repo}`\n"
            "<!-- piper-project:end -->\n"
        )
        self.env = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
        self.env.update(GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull)

    @staticmethod
    def git(path, *args):
        env = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
        env.update(GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull)
        return subprocess.run(["git", "-C", str(path), *args], env=env, text=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True).stdout.strip()

    def oid(self, path):
        return self.git(path, "rev-parse", "HEAD")

    def command(self, **overrides):
        options = dict(project=self.project, target_checkout=self.repo, base="main",
                       expected_base=self.base, verified_checkout=self.candidate,
                       verified_head=self.verified, lock_timeout="5")
        options.update(overrides)
        return [sys.executable, str(HELPER), *[part for key, value in options.items()
                for part in ("--" + key.replace("_", "-"), str(value))]]

    def run_helper(self, expected=0, env=None, **overrides):
        result = subprocess.run(self.command(**overrides), env=env or self.env, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=15)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return json.loads(result.stdout)

    def conflict(self, code, **overrides):
        result = self.run_helper(expected=2, **overrides)
        self.assertEqual(result["status"], "conflict")
        self.assertEqual(result["code"], code, result)
        self.assertEqual(self.oid(self.repo), self.base)
        return result

    def lane(self, relative, status="active", checkout=None):
        record = self.project / "work" / relative / "active-work.md"
        record.parent.mkdir(parents=True, exist_ok=True)
        record.write_text(f"# Work\nstatus: {status}\ncheckout: {checkout or self.repo}\n\n## Current wave\n")
        return record

    def holder(self):
        lock = self.repo / ".git/piper-integration.lock"
        process = subprocess.Popen(
            [sys.executable, "-u", "-c", "import fcntl,sys; f=open(sys.argv[1], 'a'); "
             "fcntl.flock(f, fcntl.LOCK_EX); print('locked', flush=True); sys.stdin.read()", str(lock)],
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
        )
        self.assertEqual(process.stdout.readline().strip(), "locked")
        self.addCleanup(self.stop_process, process)
        return process

    @staticmethod
    def stop_process(process):
        if process.poll() is None:
            process.kill()
        process.communicate(timeout=5)

    def start_waiter(self):
        process = subprocess.Popen(self.command(), env=self.env, stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE, text=True)
        self.addCleanup(self.stop_process, process)
        time.sleep(0.2)
        self.assertIsNone(process.poll(), "helper should still be waiting on the held lock")
        self.assertEqual(self.oid(self.repo), self.base)
        return process

    def test_publishes_exact_candidate_preserving_other_worktrees_and_records(self):
        other = self.root / "other"
        self.git(self.repo, "worktree", "add", "-qb", "other", str(other), self.base)
        (other / "base.txt").write_text("uncommitted unrelated work\n")
        (other / "untracked.txt").write_text("keep\n")
        before = (self.project / "project.md").read_bytes()
        result = self.run_helper()
        self.assertEqual(result["status"], "published")
        self.assertEqual(result["published_oid"], self.verified)
        self.assertEqual(self.oid(self.repo), self.verified)
        self.assertEqual((self.repo / "feature.txt").read_text(), "verified feature\n")
        self.assertEqual(self.oid(other), self.base)
        self.assertEqual((other / "base.txt").read_text(), "uncommitted unrelated work\n")
        self.assertEqual((other / "untracked.txt").read_text(), "keep\n")
        self.assertEqual((self.project / "project.md").read_bytes(), before)
        self.assertEqual(self.git(self.repo, "status", "--porcelain"), "")

    def test_target_tracked_and_untracked_changes_are_preserved(self):
        for name in ("base.txt", "untracked.txt"):
            with self.subTest(name=name):
                path = self.repo / name
                original = path.read_bytes() if path.exists() else None
                path.write_text("preserve me\n")
                self.conflict("dirty-checkout")
                self.assertEqual(path.read_text(), "preserve me\n")
                if original is None:
                    path.unlink()
                else:
                    path.write_bytes(original)

    def test_staged_source_change_is_rejected(self):
        (self.repo / "base.txt").write_text("staged\n")
        self.git(self.repo, "add", "base.txt")
        self.conflict("dirty-checkout")
        self.assertEqual(self.git(self.repo, "diff", "--cached", "--name-only"), "base.txt")

    def test_dirty_candidate_is_rejected(self):
        (self.candidate / "untracked.txt").write_text("not part of verified commit\n")
        self.conflict("dirty-checkout")

    def test_wrong_target_branch_and_detached_head(self):
        self.git(self.repo, "switch", "-qc", "different")
        self.conflict("wrong-branch")
        self.git(self.repo, "checkout", "-q", "--detach", self.base)
        self.conflict("wrong-branch")

    def test_stale_base(self):
        (self.repo / "base.txt").write_text("new base\n")
        self.git(self.repo, "commit", "-qam", "base advanced")
        result = self.run_helper(expected=2)
        self.assertEqual(result["code"], "stale-base")
        self.assertNotEqual(self.oid(self.repo), self.verified)

    def test_candidate_oid_mismatch(self):
        self.conflict("candidate-mismatch", verified_head=self.base)

    def test_base_branch_checked_out_elsewhere_is_rejected(self):
        other = self.root / "duplicate-base"
        self.git(self.repo, "worktree", "add", "--force", str(other), "main")
        self.conflict("branch-occupied")
        self.assertEqual(self.oid(other), self.base)

    def test_oid_must_be_full_commit(self):
        self.conflict("invalid-oid", verified_head="candidate")
        self.conflict("invalid-oid", expected_base=self.base[:12])
        blob = self.git(self.repo, "rev-parse", "HEAD:base.txt")
        self.conflict("invalid-oid", verified_head=blob)

    def test_candidate_must_contain_expected_base(self):
        self.git(self.candidate, "checkout", "-q", "--orphan", "unrelated")
        self.git(self.candidate, "commit", "-qm", "unrelated root")
        self.conflict("candidate-outdated", verified_head=self.oid(self.candidate))

    def test_candidate_and_target_must_belong_to_registered_repo(self):
        wrong = self.root / "wrong"
        self.git(self.root, "clone", "-q", str(self.repo), str(wrong))
        self.conflict("wrong-repository", verified_checkout=wrong)
        self.conflict("wrong-repository", target_checkout=wrong)

    def test_source_checkouts_must_remain_outside_hub(self):
        for kind in ("verified", "target", "registered"):
            with self.subTest(kind=kind):
                nested = self.root / "hub" / (kind + "-source")
                if kind == "verified":
                    self.git(self.repo, "worktree", "add", "-qb", "inside-verified", str(nested), self.verified)
                    self.conflict("source-inside-hub", verified_checkout=nested)
                elif kind == "target":
                    self.git(self.repo, "worktree", "add", "--force", str(nested), "main")
                    self.conflict("source-inside-hub", target_checkout=nested)
                else:
                    nested.mkdir()
                    self.git(nested, "init", "-q", "-b", "main")
                    binding = self.project / "project.md"
                    original = binding.read_text()
                    binding.write_text(original.replace(str(self.repo), str(nested)))
                    self.conflict("source-inside-hub")
                    binding.write_text(original)

    def test_checkout_subdirectories_and_symlink_arguments_are_rejected(self):
        subdir = self.repo / "subdir"
        subdir.mkdir()
        self.conflict("invalid-checkout", target_checkout=subdir)
        alias = self.root / "alias"
        alias.symlink_to(self.candidate, target_is_directory=True)
        self.conflict("unsafe-path", verified_checkout=alias)

    def test_nonclosed_lane_ownership_in_all_execution_layouts(self):
        for relative in ("", "groups/ingestion", "lanes/interface"):
            for status in ("active", "paused", "blocked", "idle", "unknown"):
                with self.subTest(relative=relative, status=status):
                    record = self.lane(relative, status=status)
                    self.conflict("target-occupied")
                    record.unlink()
                    # Group/independent directories without headers are ambiguous.
                    if relative:
                        record.parent.rmdir()

    def test_closed_lanes_and_studio_continuity_do_not_occupy_target(self):
        self.lane("groups/finished", status="closed")
        self.lane("design/ingestion", status="active")
        self.lane("lanes/elsewhere", checkout=self.candidate)
        self.assertEqual(self.run_helper()["status"], "published")

    def test_record_claim_and_integration_share_binding_and_release_rules(self):
        alias = self.root / "source-alias"
        alias.symlink_to(self.repo, target_is_directory=True)
        proposal = self.root / "binding.md"
        proposal.write_text(f"# Work\n- checkout: `{alias}`\n- status: 'paused'\n\n## Wave\nFinish.\n")
        record_path = "work/lanes/writer/active-work.md"
        command = [sys.executable, str(RECORD_HELPER), "--project", str(self.project),
                   "replace", record_path, "--content-file", str(proposal), "--expected"]
        claim = subprocess.run([*command, "missing"], env=self.env, text=True,
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        self.assertEqual(claim.returncode, 0, claim.stdout + claim.stderr)
        digest = json.loads(claim.stdout)["digest"]
        self.conflict("target-occupied")
        proposal.write_text("# Closed writer\nstatus: closed\n")
        release = subprocess.run([*command, digest], env=self.env, text=True,
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        self.assertEqual(release.returncode, 0, release.stdout + release.stderr)
        self.assertEqual(self.run_helper()["published_oid"], self.verified)

    def test_legacy_flat_lane_defaults_to_registered_repo(self):
        record = self.lane("")
        record.write_text("# Active work\n\nImplement current wave.\n")
        self.conflict("target-occupied")

    def test_malformed_nonclosed_lane_ownership_fails_closed(self):
        record = self.lane("lanes/malformed")
        record.write_text("# Work\nstatus: active\n")
        self.conflict("lane-record")
        record.unlink()
        self.conflict("lane-record")

    def test_symlinked_lane_tree_and_registration_are_rejected(self):
        work = self.project / "work"
        work.mkdir()
        (work / "groups").symlink_to(self.root, target_is_directory=True)
        self.conflict("unsafe-path")
        (work / "groups").unlink()
        record = self.project / "project.md"
        content = record.read_bytes()
        record.unlink()
        external = self.root / "binding.md"
        external.write_bytes(content)
        record.symlink_to(external)
        self.conflict("unsafe-path")
        self.assertEqual(external.read_bytes(), content)

    def test_wrong_project_binding_is_rejected(self):
        path = self.project / "project.md"
        path.write_text(path.read_text().replace("Project ID: `example`", "Project ID: `other`"))
        self.conflict("registration")

    def test_unfinished_git_operation_is_rejected_even_when_clean(self):
        (self.repo / ".git/MERGE_HEAD").write_text(self.verified + "\n")
        self.conflict("operation-in-progress")

    def test_simultaneous_first_publishers_are_serialized(self):
        self.assertFalse((self.repo / ".git/piper-integration.lock").exists())
        publishers = [subprocess.Popen(self.command(), env=self.env, stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE, text=True) for _ in range(2)]
        for process in publishers:
            self.addCleanup(self.stop_process, process)
        results = []
        for process in publishers:
            stdout, stderr = process.communicate(timeout=15)
            self.assertIn(process.returncode, (0, 2), stdout + stderr)
            results.append(json.loads(stdout))
        self.assertEqual(sorted(result["status"] for result in results), ["conflict", "published"])
        self.assertEqual(next(result for result in results if result["status"] == "conflict")["code"], "stale-base")
        self.assertEqual(self.oid(self.repo), self.verified)

    def test_lock_timeout_does_not_delete_lock(self):
        holder = self.holder()
        self.conflict("integration-busy", lock_timeout="0.05")
        self.assertIsNone(holder.poll())
        self.assertTrue((self.repo / ".git/piper-integration.lock").exists())

    def test_base_is_rechecked_after_waiting_for_lock(self):
        holder = self.holder()
        waiter = self.start_waiter()
        (self.repo / "base.txt").write_text("advanced during lock wait\n")
        self.git(self.repo, "commit", "-qam", "advance base")
        actual = self.oid(self.repo)
        self.stop_process(holder)
        stdout, stderr = waiter.communicate(timeout=8)
        self.assertEqual(waiter.returncode, 2, stdout + stderr)
        self.assertEqual(json.loads(stdout)["code"], "stale-base")
        self.assertEqual(self.oid(self.repo), actual)

    def test_new_lane_binding_is_rechecked_after_waiting_for_lock(self):
        holder = self.holder()
        waiter = self.start_waiter()
        self.lane("lanes/new-owner")
        self.stop_process(holder)
        stdout, stderr = waiter.communicate(timeout=8)
        self.assertEqual(waiter.returncode, 2, stdout + stderr)
        self.assertEqual(json.loads(stdout)["code"], "target-occupied")
        self.assertEqual(self.oid(self.repo), self.base)

    def test_killed_holder_releases_process_lock_without_file_cleanup(self):
        holder = self.holder()
        waiter = self.start_waiter()
        lock = self.repo / ".git/piper-integration.lock"
        inode = lock.stat().st_ino
        self.stop_process(holder)
        stdout, stderr = waiter.communicate(timeout=8)
        self.assertEqual(waiter.returncode, 0, stdout + stderr)
        self.assertEqual(json.loads(stdout)["published_oid"], self.verified)
        self.assertEqual(lock.stat().st_ino, inode)

    def test_repository_hook_runs_and_dirty_post_state_requires_attention(self):
        hook = self.repo / ".git/hooks/post-merge"
        hook.write_text("#!/bin/sh\nprintf 'hook ran' > hook-result.txt\n")
        hook.chmod(0o755)
        result = self.run_helper(expected=3)
        self.assertEqual(result["status"], "published-needs-attention")
        self.assertEqual(result["published_oid"], self.verified)
        self.assertEqual((self.repo / "hook-result.txt").read_text(), "hook ran")

    def test_non_utf8_hook_output_still_inspects_published_state(self):
        hook = self.repo / ".git/hooks/post-merge"
        hook.write_bytes(b"#!/bin/sh\nprintf '\\377'\nprintf '\\376' >&2\n")
        hook.chmod(0o755)
        result = self.run_helper()
        self.assertEqual(result["status"], "published")
        self.assertTrue(result["candidate_landed"])
        self.assertEqual(result["actual_head"], self.verified)
        self.assertEqual(self.oid(self.repo), self.verified)

    def test_ownership_publication_waits_through_source_publication(self):
        started = self.root / "source-publication-started"
        release = self.root / "release-source-publication"
        hook = self.repo / ".git/hooks/post-merge"
        hook.write_text(f"#!{sys.executable}\nfrom pathlib import Path\nimport time\n"
                        f"Path({str(started)!r}).touch()\n"
                        "deadline=time.monotonic()+8\n"
                        f"while not Path({str(release)!r}).exists() and time.monotonic()<deadline: time.sleep(.02)\n")
        hook.chmod(0o755)
        self.addCleanup(release.touch)
        helper = subprocess.Popen(self.command(), env=self.env, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE, text=True)
        self.addCleanup(self.stop_process, helper)
        deadline = time.monotonic() + 5
        while not started.exists() and time.monotonic() < deadline:
            time.sleep(.02)
        self.assertTrue(started.exists(), "publication hook did not start")
        proposal = self.root / "ownership-proposal.md"
        proposal.write_text(f"# New lane\nstatus: active\ncheckout: {self.repo}\n")
        destination = self.project / "work/lanes/new-owner/active-work.md"
        record_command = [sys.executable, str(RECORD_HELPER), "--project", str(self.project),
                          "--lock-timeout", "0.05", "replace", "work/lanes/new-owner/active-work.md",
                          "--expected", "missing", "--content-file", str(proposal)]
        busy = subprocess.run(record_command, env=self.env, text=True, capture_output=True, timeout=3)
        self.assertEqual(busy.returncode, 2, busy.stdout + busy.stderr)
        self.assertIn("busy", json.loads(busy.stdout)["message"])
        self.assertFalse(destination.exists())
        record_command[record_command.index("0.05")] = "5"
        writer = subprocess.Popen(record_command, env=self.env, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE, text=True)
        self.addCleanup(self.stop_process, writer)
        time.sleep(.2)
        self.assertIsNone(helper.poll(), "publication should still be held in its hook")
        self.assertIsNone(writer.poll(), "cooperating ownership publication must wait")
        self.assertFalse(destination.exists(), "ownership must not change during publication")
        release.touch()
        stdout, stderr = helper.communicate(timeout=8)
        self.assertEqual(helper.returncode, 0, stdout + stderr)
        self.assertEqual(json.loads(stdout)["status"], "published")
        stdout, stderr = writer.communicate(timeout=8)
        self.assertEqual(writer.returncode, 0, stdout + stderr)
        self.assertEqual(json.loads(stdout)["status"], "replaced")
        self.assertEqual(destination.read_text(), proposal.read_text())
        self.assertEqual(self.oid(self.repo), self.verified)

    def test_git_child_keeps_lock_if_helper_dies_during_hook(self):
        started = self.root / "hook-started"
        release = self.root / "release-hook"
        hook = self.repo / ".git/hooks/post-merge"
        hook.write_text(f"#!{sys.executable}\nfrom pathlib import Path\nimport time\n"
                        f"Path({str(started)!r}).touch()\n"
                        "deadline=time.monotonic()+8\n"
                        f"while not Path({str(release)!r}).exists() and time.monotonic()<deadline: time.sleep(.02)\n")
        hook.chmod(0o755)
        helper = subprocess.Popen(self.command(), env=self.env, stdout=subprocess.DEVNULL,
                                  stderr=subprocess.DEVNULL)
        self.addCleanup(self.stop_process, helper)
        self.addCleanup(release.touch)
        deadline = time.monotonic() + 5
        while not started.exists() and time.monotonic() < deadline:
            time.sleep(.02)
        self.assertTrue(started.exists(), "post-merge hook did not start")
        helper.kill()
        helper.wait(timeout=5)
        probe = [sys.executable, "-c", "import fcntl,sys; f=open(sys.argv[1],'a'); "
                 "\ntry: fcntl.flock(f, fcntl.LOCK_EX|fcntl.LOCK_NB)"
                 "\nexcept BlockingIOError: sys.exit(77)", str(self.repo / ".git/piper-integration.lock")]
        self.assertEqual(subprocess.run(probe).returncode, 77)
        record_probe = [*probe[:-1], str(self.root / "hub/.piper/locks/records.lock")]
        self.assertEqual(subprocess.run(record_probe).returncode, 77)
        release.touch()
        deadline = time.monotonic() + 5
        while subprocess.run(probe).returncode == 77 and time.monotonic() < deadline:
            time.sleep(.02)
        self.assertEqual(subprocess.run(probe).returncode, 0)
        self.assertEqual(subprocess.run(record_probe).returncode, 0)
        self.assertEqual(self.oid(self.repo), self.verified)

    def test_nonzero_merge_after_publication_is_not_reported_as_unpublished(self):
        bindir = self.root / "bin"
        bindir.mkdir()
        wrapper = bindir / "git"
        wrapper.write_text(f"#!{sys.executable}\nimport subprocess,sys\n"
                           f"r=subprocess.run([{shutil.which('git')!r}, *sys.argv[1:]])\n"
                           "sys.exit(9 if 'merge' in sys.argv[1:] and r.returncode == 0 else r.returncode)\n")
        wrapper.chmod(0o755)
        env = dict(self.env, PATH=str(bindir) + os.pathsep + os.environ["PATH"])
        result = self.run_helper(expected=3, env=env)
        self.assertEqual(result["status"], "published-needs-attention")
        self.assertTrue(result["candidate_landed"])
        self.assertEqual(result["actual_head"], self.verified)

    def test_ignored_user_file_is_not_overwritten(self):
        (self.repo / ".git/info/exclude").write_text("feature.txt\n")
        (self.repo / "feature.txt").write_text("user-owned ignored data\n")
        result = self.run_helper(expected=3)
        self.assertFalse(result["candidate_landed"])
        self.assertEqual(self.oid(self.repo), self.base)
        self.assertEqual((self.repo / "feature.txt").read_text(), "user-owned ignored data\n")


if __name__ == "__main__":
    unittest.main()
