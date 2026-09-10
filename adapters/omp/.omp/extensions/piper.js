// OMP 18.0.8 native extension. No dependencies, model calls or record writes.
import { execFile } from "node:child_process";
import { join } from "node:path";
import { promisify } from "node:util";

const run = promisify(execFile);

export default function piper(pi) {
  // session_start has no resume discriminator. Restore saved-record guidance
  // on initial load too, including `omp --continue` and `omp --resume`.
  let source = "resume";
  let pending = true;
  const restore = (reason = "resume") => {
    source = reason;
    pending = true;
  };
  async function context(ctx, event) {
    const { stdout } = await run("python3", [
      join(ctx.cwd, ".piper/lib/lifecycle.py"),
      "--runtime", "omp", "--event", event, "--source", source,
    ], { cwd: ctx.cwd, timeout: 5000, maxBuffer: 256 * 1024 });
    return stdout.trim();
  }
  function unavailable(ctx) {
    if (ctx.hasUI) ctx.ui.notify("Piper context could not load. Read AGENTS.md, RUNTIMES.md and the selected lane records directly.", "warning");
  }

  pi.on("session_start", () => restore());
  pi.on("session_switch", event => restore(event.reason === "new" ? "new" : "resume"));
  pi.on("session_branch", () => restore());
  pi.on("session_tree", () => restore());
  pi.on("session_compact", () => restore("compact"));
  pi.on("before_agent_start", async (_event, ctx) => {
    if (!pending) return;
    try {
      const content = await context(ctx, "session-start");
      pending = false;
      return { message: { customType: "piper-station", content, display: false } };
    } catch {
      unavailable(ctx);
      // Keep retrying next turn, while making the fallback visible to the model.
      return { message: { customType: "piper-station", display: false,
        content: "Piper lifecycle context is unavailable. Read AGENTS.md, RUNTIMES.md and the selected lane's saved records directly before work. No checkpoint has been written." } };
    }
  });
  pi.on("session_before_compact", async (_event, ctx) => {
    try {
      const reminder = await context(ctx, "pre-compact");
      if (ctx.hasUI) ctx.ui.notify(reminder, "info");
    } catch { unavailable(ctx); }
    // No cancellation, custom summary, or assertion that a checkpoint exists.
  });
  pi.on("session.compacting", async (_event, ctx) => {
    try { return { context: [await context(ctx, "pre-compact")] }; }
    catch { unavailable(ctx); }
  });
}
