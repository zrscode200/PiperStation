// Exercise the installed module against native event contracts without a model.
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { join } from "node:path";
const hub = process.argv[2];
const code = await readFile(join(hub, ".omp/extensions/piper.js"));
const { default: install } = await import(`data:text/javascript;base64,${code.toString("base64")}`);
const handlers = new Map();
const notices = [];
install({ on(name, handler) {
  assert.ok(!handlers.has(name), `duplicate ${name}`);
  handlers.set(name, handler);
} });
const ctx = { cwd: hub, hasUI: true, ui: { notify: (...args) => notices.push(args) } };
const call = (name, event = {}, context = ctx) => handlers.get(name)(event, context);
await call("session_start");
let result = await call("before_agent_start");
assert.equal(result.message.customType, "piper-station");
assert.equal(result.message.display, false);
assert.match(result.message.content, /Resume guidance/);
assert.match(result.message.content, /lane:retained/);
assert.equal(await call("before_agent_start"), undefined, "do not repeat context every turn");
for (const event of ["session_branch", "session_tree", "session_compact"]) {
  await call(event);
  result = await call("before_agent_start");
  assert.match(result.message.content, /Resume guidance/);
  assert.equal(await call("before_agent_start"), undefined);
}
for (const reason of ["new", "resume", "fork"]) {
  await call("session_switch", { reason });
  result = await call("before_agent_start");
  assert.equal(result.message.content.includes("Resume guidance"), reason !== "new");
}
assert.equal(await call("session_before_compact"), undefined, "must not cancel or replace compaction");
assert.match(notices.at(-1)[0], /does not write a snapshot or block compaction/);
result = await call("session.compacting");
assert.match(result.context[0], /preserve goal, phase\/boundary/);
assert.deepEqual(Object.keys(result), ["context"], "do not replace native summary prompt");
const headless = { cwd: hub, hasUI: false };
await call("session_before_compact", {}, headless);
await call("session_start");
const missing = { cwd: join(hub, "missing"), hasUI: false };
result = await call("before_agent_start", {}, missing);
assert.match(result.message.content, /No checkpoint has been written/);
result = await call("before_agent_start");
assert.match(result.message.content, /lane:retained/, "failed context must retry");
assert.equal(await call("session.compacting", {}, missing), undefined);
console.log("OMP lifecycle events, headless fallback and retry passed");
