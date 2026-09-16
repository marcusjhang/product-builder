---
name: product-builder-setup
description: Prepares a repository for the product-builder mode. Detects the stack, commands, docs layout, glossary and ADRs, available agents and skills, browser drivers, design tokens, feature-flag and analytics conventions, observability, and how to launch and drive the app, then writes .product-builder/profile.md, personas.md, drive.md, and models.md (per-role model choices after a budget question). Interviews the repo before the user. Use on first run in a repo, or "set up product-builder", "refresh the profile".
argument-hint: [--refresh]
---

# product-builder-setup

Write `.product-builder/profile.md`, `personas.md`, `drive.md`, and `models.md` for this repo. Interview the repository first; ask the user only what detection cannot answer, one question at a time with a recommended answer. Write `UNKNOWN` rather than guess. With `--refresh`, re-detect and show a diff against the existing files instead of overwriting.

## 1. Detect

- Stack and commands: `package.json`, `pyproject.toml`, `Makefile`, `Cargo.toml`, `go.mod`; the check, test, changed-tests, dev (and its port), and db scripts; what runs only in CI (read the CI config).
- Docs: `docs/`, `adr/`, `CONTEXT.md`, `AGENTS.md`, `CLAUDE.md`, `DESIGN.md`, an existing plan root.
- Agents and skills: `.claude/agents/`, `.claude/skills/`, `~/.claude/skills/`; note which fit the roles map (map, prior art, review seats, verification, debugging), minimal-implementation, review, journey-test, docs. Mark each skill in the profile as `light` (returns instructions) or `heavy` (runs its own subagents or pipeline) so a playbook can skip a heavy skill for a two-line change and say so.
- Drivers: MCP tools in this session that drive a browser or read logs; whether subagents can use them (assume no unless the profile says so).
- Design tokens: a design-system file, Tailwind config, CSS variables.
- Flags and analytics: grep for the flag helper and the analytics helper; the event naming convention in use.
- Forge: `gh` or other.
- Domain law: ADR directory and numbering, glossary.

## 2. Ask (only what detection cannot answer)

Who the product is for (seed three to five personas, one a consumer of any API); a test account or login path; what is law; deploy reality and who may flip flags in production; reviewers required by path; where logs and product analytics live.

## 3. Write

Use the schema in `${CLAUDE_SKILL_DIR}/../product-builder/references/templates.md` and the section list in the mode's plan (Baseline; Stack and commands; Where docs live; Domain language and law; Agents by phase; Skills by phase; Browser drivers; Design tokens and UX invariants; Architecture canon; Deploy reality; Feature flags; Analytics and instrumentation; Required reviewers by path; Tracker; Observability). Mark each detected fact with where it was read. `personas.md`: name, role, context, what they know, what they will not tolerate, typical goals. `drive.md`: launch command, readiness signal, login or seed, stable selectors, isolation, flag flip, teardown.

## 4. Validate drive.md

Launch once, wait for readiness, open the root page in the driver, screenshot, teardown. Record the outcome in `drive.md`. No driver → mark paper-only and say so.

## 5. Models

Detect the models this session can spawn. Ask one budget question with the question tool (unlimited, large, medium, small). Show the per-role table (plan explorers, prior art, arena runners, persona agents, pm seats, techlead seats, review seats, implementer, verifier) with defaults applied; confirm or change roles; write `.product-builder/models.md`. Never write a model the session cannot spawn; `inherit` means the session model, which for the Agent tool means omitting the model field. Roles that run in the session itself (implementer, verifier) are always `inherit`.

**Reply:** the four paths, the `UNKNOWN` list, what was validated.
