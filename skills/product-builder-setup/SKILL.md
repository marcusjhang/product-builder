---
name: product-builder-setup
description: Prepares a repository for the product-builder mode. Detects the stack, commands, docs layout, glossary and ADRs, available agents and skills, browser drivers, design tokens, feature-flag and analytics conventions, observability, and how to launch and drive the app, then writes .product-builder/profile.md, personas.md, drive.md, and models.md (per-role model choices after a budget question). Interviews the repo before the user. Use on first run in a repo, or "set up product-builder", "refresh the profile".
argument-hint: [--refresh]
---

# product-builder-setup

Write `.product-builder/profile.md`, `personas.md`, `drive.md`, and `models.md` for this repo. Interview the repository first; ask the user only what detection cannot answer, one question at a time with a recommended answer. Write `UNKNOWN` rather than guess. With `--refresh`, re-detect and show a diff against the existing files instead of overwriting.

## 1. Detect

- Stack and commands: `package.json`, `pyproject.toml`, `Makefile`, `Cargo.toml`, `go.mod`; the check, test, changed-tests, dev (and its port), and db scripts; what runs only in CI (read the CI config), and CI's exact test lane as one runnable command (the runner flags, pool, isolation, order, and shards CI passes), because a changed-files run and CI's run find different failures.
- Docs: `docs/`, `adr/`, `CONTEXT.md`, `AGENTS.md`, `CLAUDE.md`, `DESIGN.md`, an existing plan root.
- Agents and skills: `.claude/agents/`, `.claude/skills/`, `~/.claude/skills/`; note which fit the roles map (map, prior art, review seats, verification, debugging), minimal-implementation, review, journey-test, docs. Mark each skill in the profile as `light` (returns instructions) or `heavy` (runs its own subagents or pipeline) so a playbook can skip a heavy skill for a two-line change and say so.
- Local services: one `select 1` against `DATABASE_URL` and one `PING` against `REDIS_URL` (or the equivalents the stack uses), each recorded as pass or fail with the date and the error text; a fail is a fact the verify skill reads before it launches anything. The workspace provisioning script, whatever the repo's tooling runs on a fresh checkout (a worktree setup hook, a devcontainer, a `.superset/config.json` setup entry, a `make setup`): every environment value it rewrites is recorded, an OAuth or login proxy host above all, because a login page that leaves localhost costs an hour when it is discovered by clicking.
- Drivers: MCP tools in this session that drive a browser or read logs; whether subagents can use them (assume no unless the profile says so).
- Design tokens: a design-system file, Tailwind config, CSS variables.
- Flags and analytics: grep for the flag helper and the analytics helper; the event naming convention in use.
- Forge and access: the tool (`gh` or other), then access with that tool: `gh auth status`, `gh repo view --json nameWithOwner,viewerPermission`, `git ls-remote --heads origin | head -1`. A failure is not a detected forge: write the Forge section as `UNKNOWN` with the failing command and its output, list every authenticated account tried, and ask which account has access before any playbook that pushes. The account that passed, its permission, and the date go in the Forge section. When the tool has more than one login, or the remote's configured credential user (`git config credential.username`, `credential.helper`) differs from the tool's active login, the Forge section names which login this remote uses; playbooks that push or open PRs use that login's token through the tool's per-user token command (for `gh`, `gh auth token --user <login>` supplied to `git` through a credential helper or to `gh` through `GH_TOKEN`) and say which login they used once per run. A token is never written to a file in the repo.
- Judge: `TYPESAFE_API_KEY` in the environment. Present → the Judge section reads `Model: typesafe/jev-latest` and `Mode: shadow`; absent → `Model: none`. Never write `Mode: gate` on first setup; reflect recommends it from the log. When the suite was installed by copying `skills/*` rather than as the plugin, say that the first-run and question-gate hooks must be added to `.claude/settings.json` by hand (both commands are in the suite's `hooks/hooks.json`).
- Domain law: ADR directory and numbering, glossary.

## 2. Ask (only what detection cannot answer)

Who the product is for (seed three to five personas, one a consumer of any API); a test account or login path; what is law; deploy reality and who may flip flags in production; reviewers required by path; where logs and product analytics live.

## 3. Write

Use the schema in `${CLAUDE_SKILL_DIR}/../../profiles/default.md` (the profile's shape, every section present) and the section list in the mode's plan (Baseline; Stack and commands; Where docs live; Domain language and law; Agents by phase; Skills by phase; Browser drivers; Design tokens and UX invariants; Architecture canon; Deploy reality; Feature flags; Analytics and instrumentation; Required reviewers by path; Tracker; Observability; Forge; Evidence; Judge). Mark each detected fact with where it was read. Ask once whether `.product-builder/` is committed (recommended: commit it, so every worktree and session shares the profile and the learnings) or gitignored; write the answer into the profile's header. `personas.md`: name, role, context, what they know, what they will not tolerate, typical goals. `drive.md`: launch command, readiness signal, login or seed, stable selectors, isolation, flag flip, teardown.

## 4. Validate drive.md

Launch once, wait for readiness, open the root page in the driver, screenshot, teardown. Record the outcome in `drive.md`. No driver → mark paper-only and say so.

## 5. Models

Detect the models this session can spawn. Ask one budget question with the question tool (unlimited, large, medium, small); when the user has delegated the run or is away, record `medium (ASSUMED)` and list it first in the reply instead of asking. Show the per-role table (plan explorers, prior art, arena runners, persona agents, pm seats, techlead seats, review seats, implementer, verifier) with defaults applied; confirm or change roles; write `.product-builder/models.md`. Never write a model the session cannot spawn; `inherit` means the session model, which for the Agent tool means omitting the model field. Roles that run in the session itself (implementer, verifier) are always `inherit`.

**Reply:** the four paths, the `UNKNOWN` list, what was validated.
