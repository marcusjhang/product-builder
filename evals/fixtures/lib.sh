#!/usr/bin/env bash
# Fixture library for the eval suite. Sourced by each case's scaffold script; cwd is the empty run workspace.
# Every repo gets a local bare `origin` so `git fetch origin` works with no network.
set -euo pipefail

FIX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_commit() { git add -A >/dev/null; git -c user.name=fixture -c user.email=fixture@example.com commit -q -m "$1" --date="${2:-2026-09-01T10:00:00}"; }
_git() { git -c user.name=fixture -c user.email=fixture@example.com "$@"; }

# ---------------------------------------------------------------- taskbox base
tb_base() {
  git init -q -b main .
  git config user.name fixture; git config user.email fixture@example.com
  cat > package.json <<'EOF'
{
  "name": "taskbox",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "node --test 'tests/*.test.js'",
    "test:changed": "node --test tests/tasks.test.js",
    "check": "node scripts/check.js",
    "dev": "node src/server.js",
    "migrate": "node scripts/migrate.js"
  }
}
EOF
  mkdir -p src tests scripts docs/adr migrations public data logs
  cat > src/store.js <<'EOF'
import { readFileSync, writeFileSync, existsSync } from "node:fs";

// The store path is read on every call so a test can point it at a scratch file.
const file = () => process.env.TASKBOX_STORE || "data/tasks.json";

export function load() {
  if (!existsSync(file())) return { tasks: [], nextId: 1 };
  return JSON.parse(readFileSync(file(), "utf8"));
}

export function save(db) {
  writeFileSync(file(), JSON.stringify(db, null, 2));
}
EOF
  cat > src/flags.js <<'EOF'
import { readFileSync, existsSync } from "node:fs";

// Feature flags: data/flags.json, {"name": true}. A flag that is absent is off.
export function flag(name) {
  const file = process.env.TASKBOX_FLAGS || "data/flags.json";
  if (!existsSync(file)) return false;
  return Boolean(JSON.parse(readFileSync(file, "utf8"))[name]);
}
EOF
  cat > src/track.js <<'EOF'
import { appendFileSync } from "node:fs";

// Analytics: object plus past-tense verb, snake_case, e.g. task_completed. One line per event in logs/events.log.
export function track(event, props = {}) {
  appendFileSync("logs/events.log", JSON.stringify({ event, ...props, at: new Date().toISOString() }) + "\n");
}
EOF
  cat > src/tasks.js <<'EOF'
import { load, save } from "./store.js";
import { track } from "./track.js";

export function create(title, { priority = "normal", tags = [] } = {}) {
  const db = load();
  const task = { id: db.nextId++, title, priority, tags, status: "open", createdAt: new Date().toISOString() };
  db.tasks.push(task);
  save(db);
  track("task_created", { id: task.id, priority });
  return task;
}

export function list({ status, priority } = {}) {
  return load().tasks.filter((t) => (!status || t.status === status) && (!priority || t.priority === priority));
}

export function complete(id) {
  const db = load();
  const task = db.tasks.find((t) => t.id === id);
  if (!task) throw new Error(`task ${id} not found`);
  task.status = "done";
  save(db);
  track("task_completed", { id });
  return task;
}

export function archive(id) {
  const db = load();
  const task = db.tasks.find((t) => t.id === id);
  if (!task) throw new Error(`task ${id} not found`);
  task.status = "archived";
  save(db);
  track("task_archived", { id });
  return task;
}
EOF
  cat > src/format.js <<'EOF'
// Formats a list of tasks for the CLI and the API. dedupe() is called on every list.
export function dedupe(tasks) {
  const out = [];
  for (const t of tasks) {
    let seen = false;
    for (const o of out) if (o.id === t.id) seen = true;
    if (!seen) out.push(t);
  }
  return out;
}

export function line(t) {
  return `#${t.id} [${t.status}] ${t.title} (${t.priority})`;
}
EOF
  cat > src/server.js <<'EOF'
import { createServer } from "node:http";
import { readFileSync } from "node:fs";
import { create, list, complete, archive } from "./tasks.js";
import { dedupe } from "./format.js";
import { flag } from "./flags.js";

export const ROUTES = ["GET /", "GET /tasks", "POST /tasks", "POST /tasks/:id/complete", "POST /tasks/:id/archive"];

function json(res, code, body) {
  res.writeHead(code, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
}

async function body(req) {
  let raw = "";
  for await (const chunk of req) raw += chunk;
  return raw ? JSON.parse(raw) : {};
}

export function handler(req, res) {
  const url = new URL(req.url, "http://localhost");
  const m = url.pathname.match(/^\/tasks\/(\d+)\/(complete|archive)$/);
  if (req.method === "GET" && url.pathname === "/") {
    res.writeHead(200, { "content-type": "text/html" });
    return res.end(readFileSync("public/index.html", "utf8"));
  }
  if (req.method === "GET" && url.pathname === "/tasks") {
    return json(res, 200, dedupe(list({ status: url.searchParams.get("status") || undefined })));
  }
  if (req.method === "POST" && url.pathname === "/tasks") {
    return body(req).then((b) => json(res, 201, create(b.title, b))).catch((e) => json(res, 400, { error: e.message }));
  }
  if (req.method === "POST" && m) {
    const id = Number(m[1]);
    try {
      if (m[2] === "archive" && !flag("archive")) return json(res, 404, { error: "not found" });
      return json(res, 200, m[2] === "complete" ? complete(id) : archive(id));
    } catch (e) {
      return json(res, 404, { error: e.message });
    }
  }
  json(res, 404, { error: "not found" });
}

if (process.argv[1] && process.argv[1].endsWith("server.js")) {
  const port = Number(process.env.PORT || 3000);
  createServer(handler).listen(port, () => console.log(`taskbox listening on ${port}`));
}
EOF
  cat > src/cli.js <<'EOF'
import { create, list, complete, archive } from "./tasks.js";
import { line } from "./format.js";

const [cmd, ...rest] = process.argv.slice(2);
const out = (s) => process.stdout.write(s + "\n");
if (cmd === "add") out(line(create(rest.join(" "))));
else if (cmd === "list") for (const t of list()) out(line(t));
else if (cmd === "done") out(line(complete(Number(rest[0]))));
else if (cmd === "archive") out(line(archive(Number(rest[0]))));
else { out("usage: cli.js add <title> | list | done <id> | archive <id>"); process.exit(2); }
EOF
  cat > public/index.html <<'EOF'
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>Taskbox</title>
<style>:root{--ink:#222;--paper:#fff;--accent:#0a6}body{font:16px system-ui;color:var(--ink);background:var(--paper);margin:2rem}button{background:var(--accent);color:#fff;border:0;padding:.4rem .8rem}</style>
</head>
<body>
<h1>Taskbox</h1>
<form id="add"><input name="title" placeholder="New task" required><button type="submit">Add</button></form>
<ul id="tasks"></ul>
<script>
async function refresh(){const r=await fetch('/tasks');const ts=await r.json();const ul=document.getElementById('tasks');ul.innerHTML='';for(const t of ts){const li=document.createElement('li');li.textContent=`#${t.id} ${t.title} [${t.status}]`;const b=document.createElement('button');b.textContent='Done';b.onclick=async()=>{await fetch(`/tasks/${t.id}/complete`,{method:'POST'});refresh()};li.append(' ',b);ul.append(li)}}
document.getElementById('add').onsubmit=async(e)=>{e.preventDefault();await fetch('/tasks',{method:'POST',body:JSON.stringify({title:e.target.title.value})});e.target.reset();refresh()};
refresh();
</script>
</body>
</html>
EOF
  cat > scripts/check.js <<'EOF'
// Static check: every file in src/ parses (node --check). Exit 1 on the first syntax error.
import { readdirSync } from "node:fs";
import { spawnSync } from "node:child_process";
let failed = false;
for (const f of readdirSync("src")) {
  const r = spawnSync(process.execPath, ["--check", `src/${f}`], { encoding: "utf8" });
  if (r.status !== 0) { console.error(r.stderr.trim()); failed = true; }
}
process.exit(failed ? 1 : 0);
EOF
  cat > scripts/migrate.js <<'EOF'
// Runs every migration in migrations/ that data/migrations.json has not recorded, in name order.
import { readdirSync, readFileSync, writeFileSync, existsSync } from "node:fs";
import { pathToFileURL } from "node:url";
const applied = existsSync("data/migrations.json") ? JSON.parse(readFileSync("data/migrations.json", "utf8")) : [];
for (const f of readdirSync("migrations").sort()) {
  if (applied.includes(f)) continue;
  const m = await import(pathToFileURL(`migrations/${f}`).href);
  await m.up();
  applied.push(f);
  writeFileSync("data/migrations.json", JSON.stringify(applied));
  console.log(`applied ${f}`);
}
EOF
  cat > migrations/001-init.js <<'EOF'
import { load, save } from "../src/store.js";
export async function up() { const db = load(); if (!db.tasks) db.tasks = []; save(db); }
EOF
  cat > migrations/002-add-priority.js <<'EOF'
import { load, save } from "../src/store.js";
export async function up() { const db = load(); for (const t of db.tasks) if (!t.priority) t.priority = "normal"; save(db); }
EOF
  cat > tests/helpers.js <<'EOF'
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
export function scratch(flags = {}) {
  const dir = mkdtempSync(join(tmpdir(), "taskbox-"));
  process.env.TASKBOX_STORE = join(dir, "tasks.json");
  process.env.TASKBOX_FLAGS = join(dir, "flags.json");
  writeFileSync(process.env.TASKBOX_FLAGS, JSON.stringify(flags));
  return dir;
}
EOF
  cat > tests/tasks.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { scratch } from "./helpers.js";
import { create, list, complete, archive } from "../src/tasks.js";

test("create then list", () => {
  scratch();
  create("write the plan");
  assert.equal(list().length, 1);
  assert.equal(list()[0].status, "open");
});

test("complete marks done and lists by status", () => {
  scratch();
  const t = create("ship it");
  complete(t.id);
  assert.equal(list({ status: "done" }).length, 1);
});

test("archive hides from open", () => {
  scratch();
  const t = create("old");
  archive(t.id);
  assert.equal(list({ status: "open" }).length, 0);
});
EOF
  cat > tests/server.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { createServer } from "node:http";
import { scratch } from "./helpers.js";
import { handler } from "../src/server.js";

async function withServer(fn) {
  const srv = createServer(handler);
  await new Promise((r) => srv.listen(0, r));
  const base = `http://localhost:${srv.address().port}`;
  try { await fn(base); } finally { srv.close(); }
}

test("POST /tasks then GET /tasks", async () => {
  scratch();
  await withServer(async (base) => {
    const r = await fetch(`${base}/tasks`, { method: "POST", body: JSON.stringify({ title: "hello" }) });
    assert.equal(r.status, 201);
    const ts = await (await fetch(`${base}/tasks`)).json();
    assert.equal(ts.length, 1);
  });
});

test("archive route is 404 with the flag off", async () => {
  scratch({ archive: false });
  await withServer(async (base) => {
    const r = await fetch(`${base}/tasks/1/archive`, { method: "POST" });
    assert.equal(r.status, 404);
  });
});
EOF
  cat > docs/glossary.md <<'EOF'
# Glossary

- **Task**: one item of work with a title, a priority (low, normal, high), tags, and a status.
- **Status**: `open`, `done`, or `archived`. Archived tasks never return to open.
- **Flag**: a feature flag in `data/flags.json`, read by `src/flags.js`. Absent means off.
- **Event**: an analytics line in `logs/events.log`, named object plus past-tense verb in snake_case.
EOF
  cat > docs/adr/0001-json-file-store.md <<'EOF'
# ADR 0001: keep the store as one JSON file

Status: accepted · Date: 2026-08-20

## Context
Taskbox is single-user and local. A database adds a process to run and a schema to migrate.

## Decision
One JSON file at `data/tasks.json`, read and written whole by `src/store.js`. Migrations in `migrations/` transform the file in place.

## Consequences
Every write rewrites the file, so lists over a few thousand tasks will be slow. Revisit when a second user or a second machine appears.
EOF
  cat > README.md <<'EOF'
# taskbox

A small task manager: an HTTP API (`npm run dev`, port 3000), a CLI (`node src/cli.js`), and a page at `/`.

- `npm test` runs every test under `tests/` with `node --test 'tests/*.test.js'`.
- `npm run check` parses every file in `src/`.
- `npm run migrate` applies pending migrations from `migrations/`.
- CI runs `node --test --test-concurrency=1 'tests/*.test.js'` (see `.github/workflows/ci.yml`).

Feature flags live in `data/flags.json`. Analytics events go to `logs/events.log`. Decisions are recorded under `docs/adr/`.
EOF
  mkdir -p .github/workflows
  cat > .github/workflows/ci.yml <<'EOF'
name: ci
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 24 }
      - run: node scripts/check.js
      - run: node --test --test-concurrency=1 'tests/*.test.js'
EOF
  cat > CHANGELOG.md <<'EOF'
# Changelog

## 0.1.0 (2026-08-25)

First release: tasks with priority and tags, complete and archive, the CLI, the HTTP API, the page.
EOF
  printf 'data/tasks.json\ndata/migrations.json\nlogs/*.log\nnode_modules/\n' > .gitignore
  echo '{"archive": true}' > data/flags.json
  touch logs/.keep
  _commit "taskbox 0.1.0: tasks, CLI, API, page" "2026-08-25T10:00:00"
  _git tag -a v0.1.0 -m "0.1.0"
  _commit_noop() { :; }
}

# Profile written by a previous setup run, so playbook cases start past setup. Paper mode (no browser driver in a run).
tb_profile() {
  mkdir -p .product-builder
  cat > .product-builder/profile.md <<'EOF'
# product-builder profile: taskbox

Written by `product-builder-setup` on 2026-09-10. Every section is optional; a playbook that needs a missing section says so and continues. `UNKNOWN` means detection could not settle it.

## Baseline
Default branch: `main`. Rule: `git fetch origin --prune && git rev-list --left-right --count HEAD...origin/main`. If the branch has no unique commits and `git status --porcelain --untracked-files=no` is empty, `git reset --hard origin/main`; otherwise rebase. Record the SHA and the behind-count in every plan header. Stale threshold: 100 commits behind means the checkout is not the target; read anchors from `origin/main`. Committed: yes, `.product-builder/` is committed.

## Stack and commands
JavaScript (ES modules), Node 24, no dependencies (`package.json`). Run from the repo root:
- check: `node scripts/check.js`
- tests for changed files: `node --test tests/<file>` · full unit suite: `node --test 'tests/*.test.js'` · integration: none
- dev: `node src/server.js` (port 3000, `PORT` overrides)
- db: `node scripts/migrate.js` applies `migrations/` to `data/tasks.json`
- what runs only in CI: nothing extra
- CI's exact test lane, as one command: `node --test --test-concurrency=1 'tests/*.test.js'` (`.github/workflows/ci.yml`)
- local services at setup: none (JSON file store) · provisioning script: none

## Where docs live
`README.md`, `docs/glossary.md`, `docs/adr/NNNN-<slug>.md` (numbered, status line), `CHANGELOG.md` (keep-a-changelog style, version heading with date). Plan root: `docs/plans/`.

## Domain language and law
Glossary at `docs/glossary.md` (Task, Status, Flag, Event). Law: ADR 0001 keeps the store a single JSON file; archived tasks never return to open.

## Agents by phase
None in the repo. Every role runs as a general-purpose subagent with a read-only instruction.

## Skills by phase
None in the repo.

## Browser drivers
None reachable from this session or its subagents. Personas and verify run in paper mode (read the HTML and the responses) and say so.

## Design tokens and UX invariants
CSS variables in `public/index.html` (`--ink`, `--paper`, `--accent`). Buttons are verbs.

## Architecture canon
Routes in `src/server.js` (the `ROUTES` list is the contract), domain in `src/tasks.js`, persistence in `src/store.js`, flags in `src/flags.js`, analytics in `src/track.js`, migrations in `migrations/` applied by `scripts/migrate.js`.

## Deploy reality
Local process. No staging. Flags are flipped by editing `data/flags.json`; the owner flips them.

## Feature flags
`flag("<name>")` from `src/flags.js`, reading `data/flags.json`. Absent means off. Default for a new flag: off.

## Analytics and instrumentation
`track("<object>_<verb_past>", props)` from `src/track.js`, one JSON line per event in `logs/events.log`. Success signals are read by counting lines.

## Required reviewers by path
`src/server.js` and `src/store.js`: the owner.

## Tracker
None. Tickets are lines in the plan ledger.

## Observability
`logs/app.log` (server errors, one JSON line each), `logs/events.log` (analytics).

## Forge
Tool: `bin/gh` in the repo root, an offline stand-in with the same commands (`pr view`, `pr list`, `pr checks`, `pr create`, `api`, `auth status`); use it exactly as `gh`. Repo: `example/taskbox`. Account with access: `fixture` (permission write), verified on 2026-09-10. Login this remote uses: `fixture`.

## Evidence
Text evidence: `docs/plans/<slug>/evidence/<slice>-<scenario>.txt`, committed with the plan. Screenshots: committed under `docs/plans/<slug>/evidence/` as PNG or JPEG, each under 300 KB, at most eight per slice, embedded in the PR body by blob URL; no artifact store. Recordings: never committed. The scratchpad is never a cited path.

## Judge
Model: none
Mode: shadow
EOF
  cat > .product-builder/personas.md <<'EOF'
# Personas

- **Mara, solo maker.** Runs taskbox on a laptop for her own week. Knows the CLI, never opens the page. Will not tolerate a command that silently does nothing. Goals: add, finish, and clear tasks in seconds.
- **Devin, team lead trying it out.** Opens the page, expects a list that updates without a refresh, expects archived things to stay gone. Skeptical of anything that needs a flag file. Goals: see what is open, mark things done, trust the count.
- **Priya, API consumer.** Scripts against `/tasks` from a cron job. Reads response bodies literally; a changed field name breaks her job. Goals: stable JSON, clear errors with a message.
EOF
  cat > .product-builder/drive.md <<'EOF'
# Drive

Launch: `PORT=3111 node src/server.js` · Readiness: `curl -s localhost:3111/tasks` returns `[]` or a JSON array · Login or seed: none; `TASKBOX_STORE` points the store at a scratch file · Selectors: `#add input[name=title]`, `#tasks li`, `button` (Done) · Isolation: a fresh `TASKBOX_STORE` per run · Flag flip: edit `data/flags.json` or point `TASKBOX_FLAGS` at a scratch file · Teardown: kill the process. Validated: 2026-09-10 (launched, `/` returned the page).
EOF
  cat > .product-builder/models.md <<'EOF'
# Models

Budget: medium. Every role: `inherit` (the session model).
EOF
  mkdir -p bin
  cat > bin/gh <<'EOF'
#!/usr/bin/env bash
# Offline stand-in for gh. Answers from fixture files under .forge/ in the repo root.
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
case "${1:-} ${2:-}" in
  "auth status") echo "github.com: logged in as fixture (write)"; exit 0;;
  "repo view") echo '{"nameWithOwner":"example/taskbox","viewerPermission":"WRITE"}'; exit 0;;
  "pr list") cat "$root/.forge/prs.json" 2>/dev/null || echo "[]"; exit 0;;
  "pr view") n="${3:-}"; cat "$root/.forge/pr-$n.json" 2>/dev/null || { echo "no pull request $n" >&2; exit 1; }; exit 0;;
  "pr checks") n="${3:-}"; cat "$root/.forge/pr-$n-checks.txt" 2>/dev/null || { echo "no pull request $n" >&2; exit 1; }; exit 0;;
  "pr create") mkdir -p "$root/.forge"; echo "$*" > "$root/.forge/created.txt"; echo "https://example.invalid/example/taskbox/pull/9"; exit 0;;
  "pr comment") echo "$*" >> "$root/.forge/comments.txt"; exit 0;;
  "api "*) echo "{}"; exit 0;;
esac
echo "bin/gh: unsupported: $*" >&2; exit 1
EOF
  chmod +x bin/gh
  _commit "chore: product-builder profile, forge stub" "2026-09-10T09:00:00"
}

# Publish the current branch set to a local bare origin; origin/main tracks main. Call last, after layers.
tb_origin() {
  local bare="$PWD/.origin.git"
  git init -q --bare "$bare"
  _git remote add origin "$bare"
  _git push -q origin --all
  _git push -q origin --tags
  git fetch -q origin
  git branch -q --set-upstream-to=origin/main main 2>/dev/null || true
  mkdir -p .git/info; printf '.origin.git/\n' >> .git/info/exclude
}

# ------------------------------------------------------------------ layers
# A feature already shipped on main behind a flag: snooze. Optionally leave the checkout N commits behind.
tb_layer_shipped_snooze() {
  cat >> src/tasks.js <<'EOF'

export function snooze(id, until) {
  const db = load();
  const task = db.tasks.find((t) => t.id === id);
  if (!task) throw new Error(`task ${id} not found`);
  task.snoozedUntil = until;
  save(db);
  track("task_snoozed", { id, until });
  return task;
}
EOF
  python3 - <<'EOF'
import re
p="src/server.js"; s=open(p).read()
s=s.replace('import { create, list, complete, archive } from "./tasks.js";','import { create, list, complete, archive, snooze } from "./tasks.js";')
s=s.replace('"POST /tasks/:id/archive"];','"POST /tasks/:id/archive", "POST /tasks/:id/snooze"];')
s=s.replace('const m = url.pathname.match(/^\\/tasks\\/(\\d+)\\/(complete|archive)$/);','const m = url.pathname.match(/^\\/tasks\\/(\\d+)\\/(complete|archive|snooze)$/);')
s=s.replace('      if (m[2] === "archive" && !flag("archive")) return json(res, 404, { error: "not found" });\n      return json(res, 200, m[2] === "complete" ? complete(id) : archive(id));',
'      if (m[2] === "archive" && !flag("archive")) return json(res, 404, { error: "not found" });\n      if (m[2] === "snooze") {\n        if (!flag("snooze")) return json(res, 404, { error: "not found" });\n        return body(req).then((b) => json(res, 200, snooze(id, b.until)));\n      }\n      return json(res, 200, m[2] === "complete" ? complete(id) : archive(id));')
open(p,"w").write(s)
EOF
  cat > tests/snooze.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { scratch } from "./helpers.js";
import { create, snooze } from "../src/tasks.js";

test("snooze records until", () => {
  scratch({ snooze: true });
  const t = create("later");
  assert.equal(snooze(t.id, "2026-10-01").snoozedUntil, "2026-10-01");
});
EOF
  _commit "feat(tasks): snooze a task until a date, behind the snooze flag" "2026-09-12T10:00:00"
}

# Pad main with N small commits (docs), so a checkout at an earlier SHA is N behind.
tb_layer_pad_commits() {
  local n="$1"; for i in $(seq 1 "$n"); do echo "- note $i" >> docs/notes.md; _commit "docs: note $i" "2026-09-13T10:0$((i % 10)):00"; done
}

# The bug: completing an archived task succeeds. A failing test pins the expected behaviour.
tb_layer_bug_complete_archived() {
  cat > tests/complete-archived.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { scratch } from "./helpers.js";
import { create, archive, complete, list } from "../src/tasks.js";

test("completing an archived task is rejected", () => {
  scratch();
  const t = create("gone");
  archive(t.id);
  assert.throws(() => complete(t.id), /archived/);
  assert.equal(list({ status: "archived" }).length, 1);
});
EOF
  _commit "test: completing an archived task must be rejected (currently failing)" "2026-09-14T10:00:00"
}

# A test that reads a source file by path: no import edge to src/server.js.
tb_layer_pathread_test() {
  cat > tests/routes-contract.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

// The README and the ROUTES list must agree. Reads src/server.js as text, so a changed-files test run never sees this file.
test("every route in ROUTES is documented in README", () => {
  const src = readFileSync("src/server.js", "utf8");
  const routes = [...src.matchAll(/"(GET|POST) ([^"]+)"/g)].map((m) => `${m[1]} ${m[2]}`);
  const readme = readFileSync("README.md", "utf8");
  for (const r of routes) assert.ok(readme.includes(r), `README lacks ${r}`);
});
EOF
  python3 - <<'EOF'
import re
routes = re.findall(r'"(GET|POST) ([^"]+)"', open("src/server.js").read())
line = "Routes: " + " · ".join(f"{m} {p}" for m, p in routes)
p="README.md"; s=open(p).read()
s=s.replace("A small task manager:", line + "\n\nA small task manager:")
open(p,"w").write(s)
EOF
  _commit "test: routes contract against the README" "2026-09-14T11:00:00"
}

# A flaky test: shared temp store across two tests in one file, order-dependent.
tb_layer_flaky() {
  cat > tests/counts.test.js <<'EOF'
import { test, describe } from "node:test";
import assert from "node:assert/strict";
import { scratch } from "./helpers.js";
import { create, list } from "../src/tasks.js";

// Both tests share one scratch store on purpose (a mistake) and run concurrently, so the count depends on timing.
scratch();
const nap = () => new Promise((r) => setTimeout(r, Math.random() * 30));

describe("counts", { concurrency: true }, () => {
  test("count after one create", async () => {
    create("a");
    await nap();
    assert.equal(list().length, 1);
  });

  test("another create lands", async () => {
    await nap();
    create("b");
    assert.ok(list().length >= 1);
  });
});
EOF
  _commit "test: counts (flaky, order-dependent)" "2026-09-14T12:00:00"
}

# A slow path: dedupe is O(n^2) and runs on every list; a probe script exists.
tb_layer_slow() {
  cat > scripts/bench-list.js <<'EOF'
// Probe: time dedupe() over N tasks. Usage: node scripts/bench-list.js [N]
import { dedupe } from "../src/format.js";
const n = Number(process.argv[2] || 20000);
const tasks = Array.from({ length: n }, (_, i) => ({ id: i, title: `t${i}`, status: "open", priority: "normal" }));
const t0 = performance.now();
dedupe(tasks);
console.log(`dedupe(${n}) took ${(performance.now() - t0).toFixed(0)} ms`);
EOF
  _commit "chore: bench script for list" "2026-09-14T13:00:00"
}

# A vendored dependency with a v2 available offline and a changelog of breaking changes.
tb_layer_vendored_dep() {
  mkdir -p vendor/tinydate vendor/tinydate-v2
  cat > vendor/tinydate/index.js <<'EOF'
// tinydate 1.4.0
export function parse(s) { return new Date(s); }
export function format(d, pattern = "YYYY-MM-DD") { return d.toISOString().slice(0, 10); }
export function addDays(d, n) { return new Date(d.getTime() + n * 86400000); }
EOF
  echo '{"name":"tinydate","version":"1.4.0"}' > vendor/tinydate/package.json
  cat > vendor/tinydate-v2/index.js <<'EOF'
// tinydate 2.0.0
export function parse(s) { const d = new Date(s); if (Number.isNaN(d.getTime())) throw new TypeError(`tinydate: invalid date ${s}`); return d; }
export function format(d, { pattern = "iso-date" } = {}) { return d.toISOString().slice(0, 10); }
export function add(d, { days = 0 }) { return new Date(d.getTime() + days * 86400000); }
EOF
  echo '{"name":"tinydate","version":"2.0.0"}' > vendor/tinydate-v2/package.json
  cat > vendor/tinydate-v2/CHANGELOG.md <<'EOF'
# tinydate changelog

## 2.0.0
Breaking:
- `parse()` throws `TypeError` on an invalid date instead of returning an Invalid Date.
- `format(d, pattern)` is now `format(d, { pattern })`; the string form is removed.
- `addDays(d, n)` is removed; use `add(d, { days: n })`.

## 1.4.0
- `addDays` added.
EOF
  cat > src/dates.js <<'EOF'
import { parse, format, addDays } from "../vendor/tinydate/index.js";

export function due(task, days) { return format(addDays(parse(task.createdAt), days), "YYYY-MM-DD"); }
export function isValid(s) { return !Number.isNaN(parse(s).getTime()); }
EOF
  cat > tests/dates.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { due, isValid } from "../src/dates.js";
test("due adds days", () => assert.equal(due({ createdAt: "2026-09-01T00:00:00Z" }, 3), "2026-09-04"));
test("isValid is false for junk", () => assert.equal(isValid("junk"), false));
EOF
  _commit "feat(dates): due dates via vendored tinydate 1.4.0" "2026-09-14T14:00:00"
}

# Dead code behind a legacy flag, with one consumer and a doc mention.
tb_layer_dead_flag() {
  cat > src/export.js <<'EOF'
import { list } from "./tasks.js";
import { flag } from "./flags.js";

// Legacy CSV export, behind the legacy_export flag since 0.1.0. The page never calls it; the CLI does.
export function exportCsv() {
  if (!flag("legacy_export")) return null;
  return ["id,title,status", ...list().map((t) => `${t.id},${JSON.stringify(t.title)},${t.status}`)].join("\n");
}
EOF
  python3 - <<'EOF'
p="src/cli.js"; s=open(p).read()
s=s.replace('import { line } from "./format.js";','import { line } from "./format.js";\nimport { exportCsv } from "./export.js";')
s=s.replace('else if (cmd === "archive") out(line(archive(Number(rest[0]))));','else if (cmd === "archive") out(line(archive(Number(rest[0]))));\nelse if (cmd === "export") out(exportCsv() ?? "export is off");')
open(p,"w").write(s)
p="README.md"; s=open(p).read(); s+= "\nLegacy: `node src/cli.js export` prints CSV when the `legacy_export` flag is on.\n"; open(p,"w").write(s)
EOF
  _commit "feat(cli): legacy csv export behind legacy_export" "2026-09-14T15:00:00"
}

# A thin module: import from CSV with bare catches and no tests.
tb_layer_thin_import() {
  cat > src/import.js <<'EOF'
import { readFileSync } from "node:fs";
import { create } from "./tasks.js";

// Imports tasks from a CSV file: title,priority,tags(semicolon-separated). Returns the count imported.
export function importCsv(path) {
  let n = 0;
  try {
    const lines = readFileSync(path, "utf8").split("\n").slice(1);
    for (const l of lines) {
      try {
        const [title, priority, tags] = l.split(",");
        create(title, { priority: priority || "normal", tags: tags ? tags.split(";") : [] });
        n++;
      } catch {}
    }
  } catch {
    return 0;
  }
  return n;
}
EOF
  _commit "feat: csv import" "2026-09-14T16:00:00"
}

# Release layer: commits since v0.1.0 of each class.
tb_layer_release_commits() {
  echo "export const VERSION = '0.1.0';" > src/version.js; _commit "feat: expose VERSION" "2026-09-15T10:00:00"
  python3 - <<'EOF'
p="src/format.js"; s=open(p).read(); s=s.replace('return `#${t.id} [${t.status}] ${t.title} (${t.priority})`;','return `#${t.id} [${t.status}] ${t.title} (${t.priority})`.trim();'); open(p,"w").write(s)
EOF
  _commit "fix(format): trim trailing space in line()" "2026-09-15T11:00:00"
  python3 - <<'EOF'
p="src/tasks.js"; s=open(p).read(); s=s.replace('export function list({ status, priority } = {}) {','// BREAKING: list() now excludes archived tasks unless status is given.\nexport function list({ status, priority } = {}) {'); s=s.replace('return load().tasks.filter((t) => (!status || t.status === status) && (!priority || t.priority === priority));','return load().tasks.filter((t) => (status ? t.status === status : t.status !== "archived") && (!priority || t.priority === priority));'); open(p,"w").write(s)
EOF
  _commit "feat(tasks)!: list() hides archived tasks by default" "2026-09-15T12:00:00"
  echo "- internal: rename helper" >> docs/notes.md; _commit "chore: notes" "2026-09-15T13:00:00"
}

# Incident layer: an error spike in logs after a deploy.
tb_layer_incident() {
  mkdir -p logs
  {
    for i in $(seq 1 20); do echo "{\"at\":\"2026-09-19T09:0$((i % 10)):00Z\",\"level\":\"info\",\"msg\":\"GET /tasks 200\"}"; done
    for i in $(seq 1 40); do echo "{\"at\":\"2026-09-19T09:3$((i % 10)):00Z\",\"level\":\"error\",\"msg\":\"POST /tasks/$((i % 7 + 1))/complete 500\",\"err\":\"TypeError: Cannot read properties of undefined (reading 'status')\",\"stack\":\"at complete (src/tasks.js:22)\"}"; done
  } > logs/app.log
  cat > logs/deploys.log <<'EOF'
2026-09-19T08:00:00Z deploy 3f1c2a0 "fix(format): trim trailing space in line()"
2026-09-19T09:25:00Z deploy 9b7e4d1 "feat(tasks): complete() accepts a task object"
EOF
  python3 - <<'EOF'
p="src/tasks.js"; s=open(p).read()
s=s.replace('export function complete(id) {\n  const db = load();\n  const task = db.tasks.find((t) => t.id === id);','export function complete(idOrTask) {\n  const db = load();\n  const id = typeof idOrTask === "object" ? idOrTask.id : idOrTask;\n  const task = db.tasks.find((t) => t.id === id);')
open(p,"w").write(s)
EOF
  git rm -q --cached logs/app.log logs/deploys.log 2>/dev/null || true
  printf '!logs/app.log\n!logs/deploys.log\n' >> .gitignore
  _commit "feat(tasks): complete() accepts a task object" "2026-09-19T09:20:00"
}

# A finished feature branch with no plan: priority filter on the API and the page.
tb_layer_built_branch() {
  _git checkout -q -b feature/priority-filter
  python3 - <<'EOF'
p="src/server.js"; s=open(p).read()
s=s.replace('return json(res, 200, dedupe(list({ status: url.searchParams.get("status") || undefined })));','return json(res, 200, dedupe(list({ status: url.searchParams.get("status") || undefined, priority: url.searchParams.get("priority") || undefined })));')
open(p,"w").write(s)
p="public/index.html"; s=open(p).read()
s=s.replace('<ul id="tasks"></ul>','<select id="prio"><option value="">All priorities</option><option>low</option><option>normal</option><option>high</option></select>\n<ul id="tasks"></ul>')
s=s.replace("const r=await fetch('/tasks');","const p=document.getElementById('prio').value;const r=await fetch('/tasks'+(p?`?priority=${p}`:''));")
s=s.replace("refresh();\n</script>","document.getElementById('prio').onchange=refresh;\nrefresh();\n</script>")
open(p,"w").write(s)
EOF
  _commit "feat(api): filter GET /tasks by priority" "2026-09-16T10:00:00"
  cat > tests/priority-filter.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { scratch } from "./helpers.js";
import { create, list } from "../src/tasks.js";
test("list filters by priority", () => {
  scratch();
  create("a", { priority: "high" }); create("b");
  assert.equal(list({ priority: "high" }).length, 1);
});
EOF
  _commit "test: priority filter" "2026-09-16T11:00:00"
  _git checkout -q main
}

# A plan folder at a given status for the keyboard-archive feature, template-shaped.
tb_layer_plan() {
  local status="$1" slug="keyboard-archive" sha; sha="$(git rev-parse --short HEAD)"
  mkdir -p "docs/plans/$slug"
  cat > "docs/plans/$slug/product.md" <<EOF
# Keyboard archive: product plan

**Status:** $status
**Baseline:** \`origin/main\` @ \`$sha\` (read 2026-09-17)
**Owner:** owner · **Plan folder:** \`docs/plans/$slug/\` · **Prototype:** none (Bounded, one control)

## Problem
Mara clears her list with the CLI because the page has no way to archive; on the page she can only mark done. Archived tasks are hidden from open, done ones are not.

## Who it's for
Mara (solo maker), Devin (team lead trying it out).

## Appetite
Bounded, one PR.

## Solution
An Archive button per task on the page, behind the existing \`archive\` flag, calling \`POST /tasks/:id/archive\`. Surface: the task row. States: default (button visible when the flag is on), loading (button disabled while the request runs), success (row disappears), error (row stays, message under it), flag off (no button).

## User stories
### S1. Archive from the page
WHEN Devin clicks Archive on an open task with the flag on THEN the task status becomes archived and the row is removed. Failure: WHEN the request fails THEN the row stays and shows "Could not archive. Try again."
Permissions: everyone (single user).
Verified by: tests/server.test.js (archive route), live check.

## Non-goals
Undo. Bulk archive. Keyboard shortcut (deferred).

## Assumptions
| # | Assumption | Type | Importance | Evidence | Test | Verdict |
|---|---|---|---|---|---|---|
| A1 | People want archive on the page, not only the CLI | desirability | high | weak (one request) | one question | holds |

## Instrumentation
Convention: object plus past-tense verb, snake_case. \`task_archived\` already fires in \`src/tasks.js\`; add property \`source: page\`.
Success-signal query: count \`task_archived\` lines with \`source: page\` in \`logs/events.log\`.

## Rollout and launch
Flag: \`archive\` (exists, default on locally) · Stages: owner then all · Kill switch: flag off · Flag off: no button · Live gate: none, the user acts first · Flag removed: after two weeks · Docs: README line.

## Success signal
Hypothesis: if Devin can archive from the page, then \`task_archived\` with \`source: page\` is at least 5 per week within 2 weeks. Kill criterion: fewer than 1 per week.

## Open questions
None.
EOF
  cat > "docs/plans/$slug/implementation.md" <<EOF
# Keyboard archive: implementation plan

**Status:** $status
**Baseline:** \`origin/main\` @ \`$sha\` (read 2026-09-17) · **Product plan:** \`product.md\` · **Research:** \`research.md\` · **Modelled on:** the Done button in \`public/index.html\`

## Current → target
\`\`\`
page row: [title] [Done]            ->   page row: [title] [Done] [Archive]
POST /tasks/:id/complete                   POST /tasks/:id/archive (exists, src/server.js:36, flag-gated)
\`\`\`
The route exists on main behind the flag; only the page changes.

## Approach
Add the button beside Done in the row renderer of \`public/index.html\`, same fetch pattern as Done, hidden when \`GET /flags\` says the flag is off. Simpler alternatives: a keyboard shortcut only (fails S1: Devin uses the mouse); a CLI-only story (fails S1).

## Changes
| Area | File | Change |
|---|---|---|
| component | \`public/index.html\` | Archive button per row, hidden when flag off; error line |
| route | \`src/server.js\` | \`GET /flags\` returning \`{archive: bool}\` |
| event | \`src/tasks.js\` | \`task_archived\` gains \`source\` |
| test | \`tests/server.test.js\` | \`GET /flags\`; archive with source |

Census: entry points that mutate a task's status: \`src/tasks.js\` complete and archive; \`src/cli.js\` done and archive; \`src/server.js\` the two POST routes.

## Data and contracts
None.

## External calls
None.

## Test strategy
\`tests/server.test.js\` for the flags route (S1-a); a paper walkthrough of the page for the row states.

## Observability
\`logs/app.log\` records a 500 with the stack; \`task_archived\` lines carry \`source\`.

## Slices (one PR each, riskiest first)
### P1. Archive button on the page
Stories: S1 · Depends on: nothing · Size: S · Files: as above · Data: none · Flag: \`archive\` · Tests: S1-a \`GET /flags\`, S1-b archive carries source · Live check: click Archive on the page with the flag on and off · Regression: \`node --test --test-concurrency=1 'tests/*.test.js'\` · Rollback: revert the commit.

## Risks and rollout
Low. Flag exists.

## Open questions
None.
EOF
  cat > "docs/plans/$slug/research.md" <<EOF
# Keyboard archive: research

**Baseline:** \`origin/main\` @ \`$sha\` · Explorers: 0 (area read in session) · Anchors: holds 3

## Current system
- \`POST /tasks/:id/archive\` exists behind the \`archive\` flag (\`src/server.js:36\`).
- The page renders rows in \`refresh()\` and posts complete on the Done button (\`public/index.html:12\`).
- \`archive()\` tracks \`task_archived\` (\`src/tasks.js:38\`).

## Closest existing feature
The Done button: same row, same fetch-then-refresh pattern.

## Prior art
Todoist, Things, Linear: archive is one click on the row, undo via a toast (deferred here).

## Spikes
None.

## What this changes about the framing
Nothing; the route ships, only the page is missing.

## New questions for Interview 2
Should the button hide or disable when the flag is off? Recommended: hide.
EOF
  cat > "docs/plans/$slug/decisions.md" <<EOF
# Keyboard archive: decisions ledger

**Status:** $status · **Size:** Bounded · **Budgets:** one interview of at most 5 questions, 1 explorer, docs at most two and three pages, tech lead plus one seat · **Last revision:** 2026-09-17 · **Baseline:** \`$sha\` (0 behind, anchors read from checkout)
**Probe:** partial (route ships at \`src/server.js:36\`; the page lacks the control) · **Closest feature:** Done button, \`public/index.html\` · **Prior art:** none

## Decisions
| # | Decision | Options considered | Why | Who | Date | Status |
|---|---|---|---|---|---|---|
| D1 | Button per row, not a shortcut | (a) button (b) shortcut (c) both | Devin uses the mouse; shortcut deferred | user | 2026-09-17 | locked |
| D2 | Hide the button when the flag is off | (a) hide (b) disable | flag off must look like today | user | 2026-09-17 | locked |
| D3 | \`GET /flags\` for the page to read the flag | (a) route (b) inline in HTML | keeps flags in one file | agent | 2026-09-17 | locked |

## Assumed (awaiting the user)
None.

## Rejected (do not re-introduce)
| Idea | Why rejected | Date |
|---|---|---|
| Undo toast | out of appetite | 2026-09-17 |

## Deferred (written down or it does not exist)
| Item | Deferred from | What brings it back | Date |
|---|---|---|---|
| Keyboard shortcut | D1 | a second request | 2026-09-17 |

## Open questions
| Question | Recommendation | Owner | Needed by |
|---|---|---|---|

## Review rulings
| Source | Finding | Bucket | Ruling | Applied to |
|---|---|---|---|---|
| techlead | \`GET /flags\` needs a test | act on | added S1-a | implementation.md |

## Revision log
| Date | Trigger | Change |
|---|---|---|
| 2026-09-17 | initial plan | Ready to implement |

## Implementation log
| Slice | Branch | Status | Last step | PR |
|---|---|---|---|---|
EOF
  _commit "docs(plans): $slug plan at $status" "2026-09-17T10:00:00"
}

# A slice branch in flight for the plan above, with a ledger row and one commit.
tb_layer_slice_branch() {
  _git checkout -q -b keyboard-archive/p1-archive-button
  python3 - <<'EOF'
p="src/server.js"; s=open(p).read()
s=s.replace('export const ROUTES = ["GET /", "GET /tasks",','export const ROUTES = ["GET /", "GET /flags", "GET /tasks",')
s=s.replace('  if (req.method === "GET" && url.pathname === "/tasks") {','  if (req.method === "GET" && url.pathname === "/flags") {\n    return json(res, 200, { archive: flag("archive") });\n  }\n  if (req.method === "GET" && url.pathname === "/tasks") {')
open(p,"w").write(s)
p="docs/plans/keyboard-archive/decisions.md"; s=open(p).read()
s=s.replace("| Slice | Branch | Status | Last step | PR |\n|---|---|---|---|---|\n","| Slice | Branch | Status | Last step | PR |\n|---|---|---|---|---|\n| P1 | keyboard-archive/p1-archive-button | started | build: GET /flags done, button next | |\n")
open(p,"w").write(s)
EOF
  _commit "feat(api): GET /flags (P1, commit 1 of 2)" "2026-09-18T10:00:00"
  _git checkout -q main
}

# An open PR for the built branch, answered by bin/gh: red check and two comments.
tb_layer_open_pr() {
  mkdir -p .forge
  cat > .forge/prs.json <<'EOF'
[{"number":7,"title":"feat(api): filter GET /tasks by priority","headRefName":"feature/priority-filter","baseRefName":"main","state":"OPEN","url":"https://example.invalid/example/taskbox/pull/7"}]
EOF
  cat > .forge/pr-7.json <<'EOF'
{"number":7,"title":"feat(api): filter GET /tasks by priority","headRefName":"feature/priority-filter","baseRefName":"main","state":"OPEN","url":"https://example.invalid/example/taskbox/pull/7","body":"## Why\nPriya wants to pull only high-priority tasks from her cron job.\n\n## Scope\nsrc/server.js GET /tasks?priority=, public/index.html select.\n","comments":[{"author":{"login":"reviewer-a"},"body":"The select is not labelled; screen readers announce nothing. Add a <label>.","path":"public/index.html"},{"author":{"login":"ci-bot"},"body":"Lint: trailing whitespace on line 3 of tests/priority-filter.test.js"},{"author":{"login":"reviewer-b"},"body":"Should an unknown priority value 400 or return everything? Today it returns everything silently.","path":"src/server.js"}],"reviews":[]}
EOF
  cat > .forge/pr-7-checks.txt <<'EOF'
test	fail	1m2s	https://example.invalid/checks/1	tests/routes-contract.test.js: README lacks GET /tasks?priority=
check	pass	4s	https://example.invalid/checks/2
EOF
  mkdir -p .git/info; printf '.forge/\n' >> .git/info/exclude
}

# Leave the checkout N commits behind origin/main after tb_origin (call after tb_origin).
tb_behind() { local n="$1"; _git reset -q --hard "HEAD~$n"; }

# Run the fixture's own tests once so a scaffold fails loudly if the app is broken (skipped when SKIP_SELFTEST=1).
tb_selftest() { [ "${SKIP_SELFTEST:-0}" = "1" ] || node --test 'tests/*.test.js' >/dev/null 2>&1 || { echo "fixture selftest failed" >&2; node --test 'tests/*.test.js' 2>&1 | tail -20 >&2; return 1; }; }

# ------------------------------------------------------------ team-coverage layers
# A branch whose diff carries every review seat's signal: a migration, an auth check on user input, UI markup,
# a retry loop with a timeout, a third-party call, a model call with prompt text, a swallowed error,
# a shared helper change, and a test that reads a changed file by path.
tb_layer_kitchen_sink_branch() {
  _git checkout -q -b feature/smart-suggest
  cat > migrations/003-add-suggestion.js <<'EOF'
import { load, save } from "../src/store.js";
export async function up() { const db = load(); for (const t of db.tasks) if (t.suggestion === undefined) t.suggestion = null; save(db); }
EOF
  cat > src/ai.js <<'EOF'
// Asks a hosted model for a one-line suggestion per task. One shared API key for the whole install.
const URL = process.env.SUGGEST_URL || "https://api.example.invalid/v1/decide";
const KEY = process.env.SUGGEST_KEY || "";

export const PROMPT = `You are a task assistant. Given a task title, reply with one short next step.
Answer true if the task is actionable today. Never answer true for a task that is actionable today only after another task completes.
Keep the answer under 12 words. Always answer in a full sentence of at least 15 words.`;

export async function suggest(title, { retries = 3 } = {}) {
  for (let i = 0; i < retries; i++) {
    try {
      const res = await fetch(URL, { method: "POST", headers: { authorization: `Bearer ${KEY}` }, body: JSON.stringify({ prompt: PROMPT, input: title }), signal: AbortSignal.timeout(8000) });
      if (res.ok) return (await res.json()).text;
    } catch {}
  }
  return null;
}
EOF
  python3 - <<'EOF'
p="src/server.js"; s=open(p).read()
s=s.replace('import { flag } from "./flags.js";','import { flag } from "./flags.js";\nimport { suggest } from "./ai.js";')
s=s.replace('"POST /tasks/:id/archive"];','"POST /tasks/:id/archive", "POST /tasks/:id/suggest"];')
s=s.replace('const m = url.pathname.match(/^\\/tasks\\/(\\d+)\\/(complete|archive)$/);','const m = url.pathname.match(/^\\/tasks\\/(\\d+)\\/(complete|archive|suggest)$/);')
s=s.replace('  if (req.method === "POST" && m) {\n    const id = Number(m[1]);',
'''  if (req.method === "POST" && m && m[2] === "suggest") {
    const id = Number(m[1]);
    const token = req.headers["x-admin-token"];
    if (token !== undefined && token !== process.env.ADMIN_TOKEN) return json(res, 403, { error: "forbidden" });
    const task = list().find((t) => t.id === id);
    return suggest(task ? task.title : String(id)).then((text) => json(res, 200, { id, suggestion: text }));
  }
  if (req.method === "POST" && m) {
    const id = Number(m[1]);''')
open(p,"w").write(s)
p="public/index.html"; s=open(p).read()
s=s.replace("li.append(' ',b);","const s=document.createElement('button');s.textContent='✨';s.onclick=async()=>{const r=await fetch(`/tasks/${t.id}/suggest`,{method:'POST'});const j=await r.json();li.append(' '+(j.suggestion||''))};li.append(' ',b,' ',s);")
open(p,"w").write(s)
p="src/format.js"; s=open(p).read()
s=s.replace('return `#${t.id} [${t.status}] ${t.title} (${t.priority})`;','return `#${t.id} [${t.status}] ${t.title} (${t.priority})${t.suggestion ? " -> " + t.suggestion : ""}`;')
open(p,"w").write(s)
EOF
  cat > tests/ai.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { PROMPT } from "../src/ai.js";
test("prompt mentions next step", () => assert.match(PROMPT, /next step/));
test("format line still renders (reads source as text)", () => assert.match(readFileSync("src/format.js", "utf8"), /suggestion/));
EOF
  _commit "feat: model-backed suggestions per task, behind an admin token" "2026-09-16T12:00:00"
  _git checkout -q main
}

# A Feature-size plan whose implementation touches every tech-lead seat's signal: a schema change, auth and user input,
# a UI surface, a job with retries and timeouts, a third-party API, and a model call on a request path.
tb_layer_plan_wide() {
  local status="$1" slug="shared-boards" sha; sha="$(git rev-parse --short HEAD)"
  mkdir -p "docs/plans/$slug"
  cat > "docs/plans/$slug/product.md" <<EOF
# Shared boards: product plan

**Status:** $status
**Baseline:** \`origin/main\` @ \`$sha\` (read 2026-09-17)
**Owner:** owner · **Plan folder:** \`docs/plans/$slug/\` · **Prototype:** none (decided by contract sample)

## Problem
Devin wants his team to see one board. Taskbox is single-user; there is no account, no sharing, no notification.

## Who it's for
Devin (team lead), Priya (API consumer), Mara (solo maker who must not be affected).

## Appetite
Feature, three PRs.

## Solution
A board has members (email + token). Members see the same tasks. A nightly job emails each member their open tasks through a mail API, and a model suggests one next step per task on request. Surfaces: the page (member list, invite form), the API (\`/boards\`, \`/members\`, \`/tasks/:id/suggest\`), the job. States per surface: default, loading, success, error, flag off.

## User stories
### S1. Invite a member
WHEN Devin submits an email on the page with the flag on THEN a member row with a token is created and \`member_invited\` fires. Failure: WHEN the email is malformed THEN the form shows "Enter a valid email" and nothing is created. Permissions: only the owner invites.
### S2. Members see the board
WHEN Priya calls \`GET /tasks\` with her token THEN she gets the board's tasks. Failure: WHEN the token is unknown THEN 401 with \`{"error":"unauthorized"}\`. Permissions: members read, owner writes.
### S3. Nightly digest
WHEN the job runs at 07:00 THEN each member gets one email listing open tasks. Failure: WHEN the mail API times out THEN the job retries three times and logs \`digest_failed\`. Permissions: none.
### S4. Suggest a next step
WHEN a member clicks Suggest on a task THEN a one-line suggestion appears within 2 seconds. Failure: WHEN the model is down THEN "No suggestion right now" and nothing is stored. Permissions: members.

## Non-goals
Real-time sync. Mobile. Roles beyond owner and member.

## Assumptions
| # | Assumption | Type | Importance | Evidence | Test | Verdict |
|---|---|---|---|---|---|---|
| A1 | Teams will accept email plus token, no passwords | desirability | high | weak | one question | accepted risk |
| A2 | The mail API answers within 5 s | feasibility | high | none | spike | pending |

## Instrumentation
Convention: object plus past-tense verb, snake_case.
| Event | Trigger | Properties | Owner | Reads |
|---|---|---|---|---|
| member_invited | S1 | board_id | owner | count per week |
| digest_sent | S3 | member_count | job | daily |
| suggestion_shown | S4 | latency_ms | page | p95 |
Success-signal query: \`member_invited\` lines per week in \`logs/events.log\`.

## Rollout and launch
Flag: \`boards\` default off · Stages: owner, then invited boards, then all · Kill switch: flag off · Flag off: today's single-user page · Live gate: the suggestion is visible and dismissable on the page before the flag goes live · Flag removed: after four weeks · Docs: README section.

## Success signal
Hypothesis: if Devin can invite members, then \`member_invited\` reaches 3 per board in the first week. Kill criterion: 0 invites across 5 boards.

## Open questions
None.
EOF
  cat > "docs/plans/$slug/implementation.md" <<EOF
# Shared boards: implementation plan

**Status:** $status
**Baseline:** \`origin/main\` @ \`$sha\` (read 2026-09-17) · **Product plan:** \`product.md\` · **Research:** \`research.md\` · **Modelled on:** the archive flag and route

## Current → target
\`\`\`
page -> server.js -> tasks.js -> store.js (tasks.json)
                 target: + members.js (members.json) + auth middleware + jobs/digest.js -> mail API
                         + ai.js -> model API
\`\`\`

## Approach
Members and tokens in a second JSON file. Every request reads \`authorization: Bearer <token>\` and resolves a member; the owner is the member with role owner. The digest is a script run by cron with retries and a 5 s timeout per mail call. Suggestions call the model synchronously on the request path with a 2 s timeout.

## Changes
| Area | File | Change |
|---|---|---|
| schema | \`migrations/003-members.js\` | create \`data/members.json\` with the owner |
| service | \`src/members.js\` | invite, resolve token, list |
| route | \`src/server.js\` | auth middleware, \`/boards\`, \`/members\`, \`/tasks/:id/suggest\` |
| component | \`public/index.html\` | member list, invite form, Suggest button |
| job | \`jobs/digest.js\` | nightly digest with retries |
| service | \`src/ai.js\` | model call |
| event | \`src/track.js\` | three new events |

Census: entry points that read tasks: \`src/server.js\` GET /tasks, \`src/cli.js\` list, \`jobs/digest.js\`.

## Data and contracts
\`data/members.json\`: \`{ members: [{ id, email, token, role }] }\`. Expand only.

## External calls
| Call | Sync | Timeout | Latency budget | Failure mode | Key |
|---|---|---|---|---|---|
| mail API (digest) | async job | 5 s | none | retry 3, log \`digest_failed\` | \`MAIL_KEY\` |
| model API (suggest) | sync on request | 2 s | 2 s | "No suggestion right now" | \`SUGGEST_KEY\`, shared, metered |

## Test strategy
\`node --test\` per acceptance line; the digest job against a stub mail server; the suggest route against a stub model server.

## Observability
\`logs/app.log\` per request with member id; \`digest_failed\` and \`suggestion_shown\` with latency.

## Slices (one PR each, riskiest first)
### P1. Members and auth (walking skeleton)
Stories: S1, S2 · Size: M · Files: migration, members.js, server.js, index.html · Flag: \`boards\` · Tests: S1-a, S1-b, S2-a, S2-b · Live check: invite then GET with the token · Rollback: flag off.
### P2. Suggest
Stories: S4 · Depends on: P1 · Size: S · Files: ai.js, server.js, index.html · Tests: S4-a, S4-b · Rollback: flag off.
### P3. Digest job
Stories: S3 · Depends on: P1 · Size: M · Files: jobs/digest.js · Tests: S3-a, S3-b · Rollback: disable cron.

## Risks and rollout
Tokens in a JSON file; the shared model key can be drained by a member.

## Open questions
None.
EOF
  cat > "docs/plans/$slug/research.md" <<EOF
# Shared boards: research

**Baseline:** \`origin/main\` @ \`$sha\` · Explorers: 2 · Anchors: holds 4

## Current system
- Routes live in \`src/server.js\` (\`ROUTES\` list, \`src/server.js:8\`); there is no auth.
- Tasks are one JSON file (\`src/store.js:4\`, ADR 0001).
- Flags via \`src/flags.js:5\`; events via \`src/track.js:5\`.

## Closest existing feature
The archive flag: a route gated by a flag, tracked by an event.

## Prior art
Trello, Linear, Todoist shared projects: invite by email, member roles.

## Spikes
A2 pending.

## What this changes about the framing
Auth is new; every route changes.

## New questions for Interview 2
Token in header or query string? Recommended: header.
EOF
  cat > "docs/plans/$slug/decisions.md" <<EOF
# Shared boards: decisions ledger

**Status:** $status · **Size:** Feature · **Budgets:** interview 1 at most 8, interview 2 at most 8; 2-4 explorers; personas 3-5, pm, tech lead · **Last revision:** 2026-09-17 · **Baseline:** \`$sha\` (0 behind)
**Probe:** absent (no members, no auth on origin/main) · **Closest feature:** archive flag · **Prior art:** none

## Decisions
| # | Decision | Options considered | Why | Who | Date | Status |
|---|---|---|---|---|---|---|
| D1 | Email plus token, no passwords | (a) tokens (b) passwords (c) OAuth | smallest that works | user | 2026-09-17 | locked |
| D2 | Suggestions synchronous on the request path | (a) sync (b) queued | simplest; 2 s timeout | agent | 2026-09-17 | locked |
| D3 | One shared model key | (a) shared (b) per member | no billing per member yet | ASSUMED | 2026-09-17 | locked |

## Assumed (awaiting the user)
D3: should each member bring their own model key?

## Rejected (do not re-introduce)
| Idea | Why rejected | Date |
|---|---|---|
| Real-time sync | out of appetite | 2026-09-17 |

## Deferred (written down or it does not exist)
| Item | Deferred from | What brings it back | Date |
|---|---|---|---|
| Roles beyond owner and member | S2 | a second team | 2026-09-17 |

## Open questions
| Question | Recommendation | Owner | Needed by |
|---|---|---|---|

## Review rulings
| Source | Finding | Bucket | Ruling | Applied to |
|---|---|---|---|---|

## Revision log
| Date | Trigger | Change |
|---|---|---|
| 2026-09-17 | initial plan | Drafted |

## Implementation log
| Slice | Branch | Status | Last step | PR |
|---|---|---|---|---|
EOF
  _commit "docs(plans): $slug plan at $status" "2026-09-17T11:00:00"
}

# Turn the keyboard-archive plan into two independent slices (page button, CLI archive-all) for --parallel.
tb_layer_plan_two_slices() {
  python3 - <<'EOF'
p="docs/plans/keyboard-archive/implementation.md"; s=open(p).read()
s=s.replace("## Risks and rollout","""### P2. CLI archive-all
Stories: S2 · Depends on: nothing · Size: S · Files: \\`src/cli.js\\`, \\`tests/cli.test.js\\` · Data: none · Flag: \\`archive\\` · Tests: S2-a archive-all archives every done task · Live check: run \\`node src/cli.js archive-all\\` · Regression: \\`node --test 'tests/*.test.js'\\` · Rollback: revert the commit.

## Risks and rollout""")
open(p,"w").write(s)
p="docs/plans/keyboard-archive/product.md"; s=open(p).read()
s=s.replace("## Non-goals","""### S2. Archive all done tasks from the CLI
WHEN Mara runs \\`node src/cli.js archive-all\\` THEN every done task becomes archived and the count is printed. Failure: WHEN no task is done THEN it prints "nothing to archive" and exits 0.
Permissions: everyone.

## Non-goals""")
open(p,"w").write(s)
EOF
  _commit "docs(plans): keyboard-archive gains P2, independent of P1" "2026-09-17T12:00:00"
}

# Apply the P1 slice on main (as if merged) so QA and Ship cases have a built feature to test.
tb_layer_p1_merged() {
  python3 - <<'EOF'
p="src/server.js"; s=open(p).read()
s=s.replace('export const ROUTES = ["GET /", "GET /tasks",','export const ROUTES = ["GET /", "GET /flags", "GET /tasks",')
s=s.replace('  if (req.method === "GET" && url.pathname === "/tasks") {','  if (req.method === "GET" && url.pathname === "/flags") {\n    return json(res, 200, { archive: flag("archive") });\n  }\n  if (req.method === "GET" && url.pathname === "/tasks") {')
open(p,"w").write(s)
p="public/index.html"; s=open(p).read()
s=s.replace("async function refresh(){const r=await fetch('/tasks');","async function refresh(){const fl=await (await fetch('/flags')).json();const r=await fetch('/tasks');")
s=s.replace("li.append(' ',b);ul.append(li)","li.append(' ',b);if(fl.archive){const a=document.createElement('button');a.textContent='Archive';a.onclick=async()=>{a.disabled=true;const r=await fetch(`/tasks/${t.id}/archive`,{method:'POST'});if(!r.ok){a.disabled=false;const m=document.createElement('div');m.textContent='Could not archive. Try again.';li.append(m);return}refresh()};li.append(' ',a)}ul.append(li)")
open(p,"w").write(s)
p="src/tasks.js"; s=open(p).read()
s=s.replace('export function archive(id) {','export function archive(id, { source = "api" } = {}) {')
s=s.replace('  track("task_archived", { id });','  track("task_archived", { id, source });')
open(p,"w").write(s)
EOF
  cat > tests/flags-route.test.js <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { createServer } from "node:http";
import { scratch } from "./helpers.js";
import { handler } from "../src/server.js";
test("GET /flags reports archive", async () => {
  scratch({ archive: true });
  const srv = createServer(handler); await new Promise((r) => srv.listen(0, r));
  const j = await (await fetch(`http://localhost:${srv.address().port}/flags`)).json();
  srv.close();
  assert.equal(j.archive, true);
});
EOF
  python3 - <<'EOF'
import re
p="README.md"; s=open(p).read()
routes = re.findall(r'"(GET|POST) ([^"]+)"', open("src/server.js").read())
line = "Routes: " + " · ".join(f"{m} {p}" for m, p in routes)
s = re.sub(r"^Routes: .*$", line, s, flags=re.M)
open(p,"w").write(s)
EOF
  _commit "feat(page): Archive button per row behind the archive flag (keyboard-archive P1)" "2026-09-18T15:00:00"
  python3 - <<'EOF'
p="docs/plans/keyboard-archive/decisions.md"; s=open(p).read()
s=s.replace("| Slice | Branch | Status | Last step | PR |\n|---|---|---|---|---|\n","| Slice | Branch | Status | Last step | PR |\n|---|---|---|---|---|\n| P1 | keyboard-archive/p1-archive-button | merged | PR merged 2026-09-18 | https://example.invalid/example/taskbox/pull/8 |\n")
open(p,"w").write(s)
EOF
  _commit "docs(plans): keyboard-archive P1 merged" "2026-09-18T15:30:00"
}

# Set the plan's status line in product.md and decisions.md.
tb_plan_status() {
  local slug="$1" status="$2"
  python3 - "$slug" "$status" <<'EOF'
import re, sys
slug, status = sys.argv[1], sys.argv[2]
for f in ("product.md", "implementation.md", "decisions.md"):
    p = f"docs/plans/{slug}/{f}"; s = open(p).read()
    s = re.sub(r"\*\*Status:\*\* [^\n·]+", f"**Status:** {status}", s, count=1)
    open(p, "w").write(s)
EOF
  _commit "docs(plans): $slug status $status" "2026-09-18T16:00:00"
}

# ------------------------------------------------------------------ calcom
# calcom/cal.com at a pinned SHA, from a local cache when present, with a local bare origin and the suite's example profile.
CALCOM_SHA="${CALCOM_SHA:-main}"
calcom_base() {
  local cache="${PB_EVAL_CACHE:-$HOME/.pb-eval-cache}/calcom"
  if [ ! -d "$cache/.git" ]; then
    mkdir -p "$(dirname "$cache")"
    git clone -q --depth 50 --branch main https://github.com/calcom/cal.com "$cache"
  fi
  git clone -q --no-hardlinks "$cache" .
  git config user.name fixture; git config user.email fixture@example.com
  git remote remove origin
  local bare="$PWD/.origin.git"
  git init -q --bare "$bare"; git -C "$bare" config receive.shallowUpdate true
  git remote add origin "$bare"; git push -q origin main; git fetch -q origin
  git branch -q --set-upstream-to=origin/main main
  mkdir -p .git/info; printf '.origin.git/\n' >> .git/info/exclude
}
calcom_profile() {
  mkdir -p .product-builder
  cp "$FIX_DIR/../../profiles/example-calcom.md" .product-builder/profile.md
  cat > .product-builder/personas.md <<'EOF'
# Personas

- **Ada, freelance coach.** Sells 30-minute sessions; lives in the booking page and the availability screen. Will not tolerate a double booking.
- **Ben, ops lead at a 40-person team.** Manages team event types and routing forms; reads the admin pages weekly. Skeptical of anything that changes a URL.
- **Cleo, API integrator.** Uses the public API v2 from a CRM; reads response bodies literally.
EOF
  cat > .product-builder/drive.md <<'EOF'
# Drive

Launch: not validated in this environment (no dependencies installed, no database). Readiness: UNKNOWN. Login or seed: UNKNOWN. Paper mode.
EOF
  printf '# Models\n\nBudget: medium. Every role: `inherit`.\n' > .product-builder/models.md
  _commit "chore: product-builder profile" "2026-09-18T10:00:00"
}
