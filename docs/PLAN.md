# product-builder: a plan-to-ship skill suite for product engineers, portable across projects

**Date:** 2026-09-15
**Status:** Plan. Nothing built yet except the drafted files under `skills/product-builder/` in this folder (the mode skill, README, templates with the Definition of Ready and Definition of Done, principles, the interaction model, writing rules, a worked example profile, the research landscape).
**Read with:** `skills/product-builder/SKILL.md` (the mode: non-negotiables, principles, autonomy, subagents, reply rules, playbook table), `skills/product-builder/references/templates.md` (plan file templates, Definition of Ready, Definition of Done), `skills/product-builder/references/principles.md`, `skills/product-builder/references/landscape.md` (the research behind every choice, with sources), `profiles/example-calcom.md` (the worked example profile).
**Audience of the suite:** product engineers. One person owns a feature from the first conversation to the post-ship check, and the suite is tuned so that planning the feature and building it are handled completely.

## Contents
1. What it is
2. Requirements from the brief
3. Architecture: one mode, playbooks, leaf skills
4. The per-project layer (what makes it portable)
5. Skill specs: product track (plan, build, QA, ship)
6. Skill specs: engineering track
7. Repo layout, install, distribution
8. Build plan, evals, dogfooding
9. Open decisions
10. Sources

---

## 1. What it is

product-builder is a Claude Code working mode for product engineers. One command, `/product-builder <what you want>`, matches the task to a playbook and opens the playbook's steps in the todo list. Playbooks call leaf skills. One per-project profile makes it portable.

The **product track** runs a feature from idea to shipped. Interview the person who wants it, research the codebase and the market, turn the answers into user stories with acceptance criteria, write a short product plan and a short implementation plan, settle feel questions with a throwaway prototype, verify the plan with subagents playing the target audience and with a tech-lead panel, build it one vertical slice per PR, QA it against the stories on the real app, ship it behind a flag, and check the success signal afterwards. Two checklists bracket the build: the **Definition of Ready** (nothing is built until the plan passes it) and the **Definition of Done** (nothing is called shipped until the feature passes it).

The **engineering track** covers the rest of a product engineer's week: explain how a subsystem works and why it is that way, fix a bug from a reproduction to a verified PR, refactor without changing behaviour, chase a performance regression against a baseline, review a diff adversarially, open a well-shaped PR, and drive it to merge-ready.

Both tracks share the leaf skills (research, prototype, personas, product panel, tech lead, review, verify, how, why, resume), seventeen principles named in every reply, the four-bucket findings format, and one per-project profile. Three properties make the suite portable:

- The skills know nothing about a specific project. Everything project-specific lives in one folder in the target repo (`.product-builder/`), written by a setup skill and edited by hand.
- Every product-track run leaves the same file set (`docs/plans/<slug>/`); every engineering-track run leaves evidence in the reply and, when it opens a PR, in the PR body. Every run shows its steps in the todo list, with skipped steps marked.
- Installed skills are reused as prerequisites (grill-me for the interview discipline) rather than re-implemented.

## 2. Requirements from the brief

Kept close to the original wording so a builder can check the result against it.

1. Planning stages: describe and scope the problem grill-me style; research the current system deeply, including spikes against real APIs and mock APIs; product plan plus implementation plan (ASCII diagram or similar), a big feature split into several docs under one overview; prototype if needed; scope the PRs.
2. Planning deliverables: a prototype when applicable, a rough product plan, a rough implementation plan, both high level, the simplest way around the problem, the codebase looked at properly.
3. Process shape: a rough first interview; agents explore those parts thoroughly and map the current architecture; a second set of questions informed by that; the plans, with the user involved at certain steps; deliverables at the end; refinement guided by agents.
4. Deep research on existing tools (prior art) before planning.
5. User stories, discussed with the user.
6. Verification of plans and prototype: subagents acting as the target audience with the right intention click through and respond, then a discussion with the developer; a tech-lead agent judges the technical plan, then a discussion with the developer.
7. Reproducible; the user is involved at decisions and product calls.
8. An editing process for existing plans.
9. Implementation and QA skills.
10. Engineering workflows as well as planning: understand, fix, refactor, perf, review, PR.
11. Extensible across all projects: one suite, many repos.
12. Built for product engineers: planning the feature and building it must be handled completely, end to end.
13. External skills may be reused as prerequisites. The brief's ordering is a suggestion.

## 3. Architecture

### 3.1 Layers

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ product-builder plugin (one repo, installed once, used in every project)                                   │
│                                                                                                            │
│   MODE   /product-builder <task>  matches a playbook, opens its steps as todos, stays on                   │
│                                                                                                            │
│   PLAYBOOKS (markdown step lists under the mode, copied into the todo list)                                │
│   product track:      plan · revise · implement · qa · ship · program                                      │
│   engineering track:  investigation · bug-fix · refactoring · perf-issue · babysit ·                       │
│                       pickup-and-pause · opening-a-pr (ends every code playbook)                           │
│                                                                                                            │
│   LEAF SKILLS (called by steps, or directly)                                                               │
│   product-builder-setup · -how · -why · -research · -prototype · -personas · -pm ·                         │
│   -techlead · -review · -verify · -resume · -reflect · -plain                                              │
│                                                                                                            │
│   SHARED: templates (Definition of Ready and Done) · principles · interaction ·                            │
│           writing · landscape · profiles/default.md                                                        │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ project layer  <repo>/.product-builder/                                                                    │
│   profile.md   commands, docs, agents, drivers, canon, deploy, flags, analytics, reviewers, obs            │
│   personas.md  standing audience roster    drive.md  launch, login, seed, click    models.md  role → model │
│   principles.md (optional)  overrides/ (optional)  routes.md (optional)                                    │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ plan folders  <repo>/docs/plans/<slug>/                                                                    │
│   product.md · implementation.md · research.md · decisions.md ·                                            │
│   prototype/ · qa-report.md · README.md (program size only)                                                │
└────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Product track

```
idea ─▶ plan ─▶ [Ready to implement] ─▶ implement ─▶ [Built] ─▶ qa ─▶ [QA passed] ─▶ ship ─▶ [Shipped] ─▶ reflect
          │  ▲                              │                    │                    │
          │  └──────────── revise ◀─────────┴────────────────────┴────────────────────┘
          │                (new fact, scope change, review or QA finding, friction, main moved)
          ├── research    current system (file:line at SHA), closest existing feature, prior art, spikes
          ├── prototype   throwaway clickable HTML, in-app spike, or contract sample, for one named decision
          ├── personas    audience subagents click through and report back
          ├── pm          product panel (PM, skeptic, designer, data analyst) reads product.md
          └── techlead    tech-lead panel reads implementation.md against the code

Inside plan:
0 intake ─ 1 interview 1 ─ G1 ─ 2 research ─ G2 ─ 3 interview 2 + stories + assumptions ─ G3 ─ 4 approach arena, draft, appetite check ─ G4 ─ 5 prototype? ─ G5 ─ 6 verify (personas, pm, techlead) ─ G6 ─ 7 Definition of Ready ─ G7

Inside implement, per slice:
re-read ledger ─ contract ─ branch ─ build (tests from acceptance) ─ verify on the surface ─ review (spec + quality) ─ PR ─ ledger ─ G8 merge
```

### 3.3 Engineering track

```
"how does X work"  ──▶ investigation playbook    routes to the how skill (and why for motivation) → cited explanation
"why is it like this" ▶ investigation playbook    evidence from git, PRs, issues, docs, ADRs → dated rationale
bug ──────────────▶ bug-fix playbook             reproduce → root cause → failing test → fix → verify → review → opening-a-pr
refactor ─────────▶ refactoring playbook         characterise → expand → migrate callers in verified batches → contract → opening-a-pr
slow ─────────────▶ perf-issue playbook          baseline → trace → one change → interleaved re-measure → opening-a-pr
"review this" ────▶ product-builder-review      reviewers cast by signal → four buckets → rulings
"does it work" ───▶ product-builder-verify      drive the matching surface per drive.md, return evidence
"open a PR" ──────▶ opening-a-pr playbook        size and stack, conventional title, briefing body with evidence
"get it merged" ──▶ babysit playbook             CI and review comments to merge-ready, never merges
```

### 3.4 Playbook match (the mode's Playbooks section)

| The user brings | Route to |
|---|---|
| An idea, a problem statement, a feature request, "plan this" | Plan playbook |
| A slug or path under the plan root plus a change, new fact, review feedback, "main moved" | Revise playbook |
| A plan at `Ready to implement`, "build it", "continue the build" | Implement playbook |
| A built branch, PR, or preview URL plus "test", "QA", "does the feature work" | QA playbook |
| A plan at `QA passed`, "ship it", "roll it out", "flip the flag", "did it work after launch" | Ship playbook |
| "How does X work", "walk me through", "map this area" | Investigation playbook, via the how skill |
| "Why is it like this", "who decided", "what was the reason" | Investigation playbook, via the why skill |
| A bug, a failing test, a stack trace, "it's broken" | Bug fix playbook |
| "Refactor", "clean up", "rename across", "extract"; behaviour must not change | Refactoring playbook |
| "Slow", "latency", "memory", a number to improve | Perf issue playbook |
| "Review this", "tear this apart", "find blind spots" | `product-builder-review` |
| "Does this work", "prove it", "run it like a user would" | `product-builder-verify` |
| "Open a PR", "split this into PRs" | Opening a PR playbook |
| "Get this merged", "fix CI", "handle the review comments" | Babysit playbook |
| "Review my product plan", "is the PRD solid", "poke holes in the stories" | `product-builder-pm` |
| "Where was I", "catch me up on <slug>", "what's in flight", "hand this off" | `product-builder-resume` |
| One leaf skill by name | that skill, outside any playbook |
| "Pick up where the other session left off", "pause, I'm compacting" | Pickup and pause playbook |
| First run in a repo, or no `.product-builder/profile.md` | `product-builder-setup` first, then the route above |
| "What should we change about the workflow", after a hard run | `product-builder-reflect` |

Two playbooks could apply → one question with the options. A repo may add rows in `.product-builder/routes.md`; the mode merges them. The matched playbook's steps are copied verbatim into the todo list before any task-specific todos; a step the mode decides not to run stays in the list as `skip: <reason>`.

### 3.5 Sizing and budgets

Sizing decides which steps run and how much each may cost. The mode states the size in its first reply as provisional, from the intake probe's three lines (ships, closest feature, target tree) rather than the phrasing, and restates it after research, up or down; the user can override it. When in doubt take the heavier size; a downgrade from Program removes the parts skeleton.

| Size | Signal | Interviews | Research | Docs | Prototype | Verification | Slices |
|---|---|---|---|---|---|---|---|
| **Trivial** | 1-2 files, obvious approach, no product call | none; do the work without the suite | | | | | |
| **Bounded** | one subsystem, one PR, at most one product call | one combined interview, at most 5 questions | one explorer, no fan-out; prior art and spikes only when a fact blocks | at most one page each | only for a UX fork | tech lead, 1-2 seats; product panel and personas on request | 1 |
| **Feature** | 2-4 PRs, one or two subsystems, real product calls | interview 1 at most 8; interview 2 at most 8 plus the story set | 2-4 explorers, 3-5 prior-art products, spikes as needed | about 2 pages and 3 pages | when a decision needs feel | personas 3-5, product panel 3-4 seats, tech lead 2-4 seats | 2-4, riskiest first |
| **Program** | more than 4 PRs, several surfaces or subsystems, several independent user-facing changes | overview interview at most 6; each part runs Feature budgets | per part | overview at most one page plus parts | per part | per part, plus one tech-lead pass on the overview's ordering | parts ordered by risk then value; part 1 is the walking skeleton |

Feature and Program sizes compare two or three candidate approaches before `implementation.md` is drafted (§5.2, Phase 4); Bounded writes from one.

The engineering track sizes itself inside each skill: a one-line fix skips the reviewer cast and says so; a rename inside one file skips expand/contract.

### 3.6 Principles

Seventeen, one paragraph each in `skills/product-builder/references/principles.md`; skills cite them by number; a repo appends its own in `.product-builder/principles.md`. Product and process (1-12): explore before you ask; one question at a time with a recommended answer; product calls are the user's, execution calls are the agent's; never block on reversible work; the simplest change that could work; every current-state claim carries file:line at a SHA; non-goals and appetite; decide by prototype when the question is feel; verify with the audience, not the author; vertical slices, one PR each; plans are living documents with a ledger; rough means short. Engineering (13-17): fix root causes; prove it works on the matching surface; sequence work into verifiable units; attack the premise; test behaviour, not implementation.

### 3.7 Conventions every skill follows

- Leaf skills carry frontmatter: `name`, third-person `description` with what plus when, `argument-hint`; `SKILL.md` under 300 lines; prompts and banks in `references/` one level deep with a table of contents. Playbooks are markdown files under the mode's `playbooks/` with a one-line ownership statement, numbered steps, and a `**Reply:**` contract; no frontmatter. Cross-references via `${CLAUDE_SKILL_DIR}/../product-builder/references/...` so the suite works as a plugin or copied into `~/.claude/skills/`.
- The todo list is the progress UI: the matched playbook's steps are copied in verbatim, ticked as they finish, and a skipped step stays as `skip: <reason>`. Every reply follows the mode's Writing the reply rules and the playbook's `**Reply:**` contract (§3.8).
- Every review lands findings in four buckets: act on, consider, noted, dismissed; dismissed stays visible with the reason.
- Every subagent prompt is self-contained: baseline SHA, mandate, paths or inline docs, output schema, "return pointers, not dumps", read-only unless the mandate says otherwise.
- Verification means the matching surface: a UI change is clicked, a CLI change is run, an API change gets a real request, a migration is replayed, a perf change is measured against its baseline. "The build passed" is not evidence. Evidence is a screenshot, a log line, a response body, a number with a unit, or a SHA.
- The user is asked one question at a time with a recommended answer and a one-line reason. Exceptions: the user-story set (presented as a list) and reviewer rulings (multi-select over at most four findings per question).
- Autonomous mode: "run without me" or an absent user → every question resolves to the recommendation, recorded as `ASSUMED`, listed first at hand-off. Irreversible actions still stop: merge, push to a shared branch, migrations against a shared database, deletes, external messages, flag flips for real users.
- The ledger (`decisions.md`) is the memory that survives compaction and sessions. Every stage re-reads it before acting and writes to it before replying.
- No completion claim without a fresh run in the same reply. "Should work", "probably passes", and "done" before the command has run are forbidden; the reply shows the command and its output, and a finding or a pass carries the evidence next to it.
- Writing rules in `product-builder/references/writing.md` apply to plan docs, PR bodies, and the UI copy inside stories: sentence case, plain words, one idea per sentence, the mechanism or the number instead of the feeling, no filler, no decorative punctuation.

### 3.8 Interaction model

The mode skill carries the rules (Non-negotiables, Autonomy, Subagents, Writing the reply, Playbooks) and `references/interaction.md` shows them in use. What the user experiences:

- **One command.** `/product-builder <what you want>` in plain words. The mode reads the profile, matches a playbook, states the size and budgets, opens the todo list with the playbook's steps copied verbatim, and starts the first step in the same turn.
- **The todo list is the progress UI.** Steps tick as they finish; sub-todos show long fan-outs; a skipped step stays as `skip: <reason>`. No custom progress line.
- **Ask only product calls.** Before any question the mode classifies it: a fact the repo answers is read and reported; a fact an experiment answers is prototyped or spiked and the result decides; a product or preference call is asked, one per reply, with a recommended answer and its reason, accepted with "ok". "skip" or "you decide" records ASSUMED.
- **Present instead of asking on reversible work.** Drafts, prototypes, and doc edits from findings are done and shown as a path plus a ten-line digest with "say what to change"; the playbook continues unless the user objects. Framing (G1), the story set (G3), go (G7), merge (G8), and the flag flip (G9) wait.
- **Reply contract.** Every playbook ends with: who the work is for and what changes for them; what the maintainer inherits; what was chosen and why, naming the principles that shaped it; the evidence (paths, commands with output, screenshots, numbers with units); open decisions and ASSUMED rows; the next move. Tables for alternatives and findings. Files never pasted.
- **Findings as one block.** At most eight lines, grouped by bucket, with source and confidence; reversible edits applied and listed; scope cuts asked.
- **Fallbacks in one sentence.** A missing driver or tool names its fallback and the run continues.
- **Session overrides.** "going to bed", "run until done", "you decide" keep the run going on recommendations, all recorded as ASSUMED and listed first.
- **Candour.** Asked whether to do something, the mode gives its real judgment; "this does not earn its place" is an acceptable answer.
- **Turn budgets.** Bounded plan 5 to 7 turns to Ready, Feature 10 to 14; exceeding a budget is said at the next gate with "skip ahead" offered.

## 4. The per-project layer (what makes it portable)

### 4.1 Discovery

Every skill starts by reading `${CLAUDE_PROJECT_DIR}/.product-builder/profile.md`. If it is missing, say so, invoke `product-builder-setup`, then continue. The plugin ships `profiles/default.md` (generic: no agents, commands discovered from the package manager, paper-mode personas) and `profiles/example-calcom.md` (the worked example).

### 4.2 `profile.md` schema

| Section | Read by | Content |
|---|---|---|
| Baseline | all | git rules: fetch, fast-forward or rebase, record the SHA and the behind-count, worktree quirks |
| Stack and commands | research, implement, fix, refactor, perf, qa, verify | language, package manager, `check`, `test`, `test:changed`, `dev` and its port, `db:*`, what runs only in CI |
| Where docs live | plan, revise, why | plan root (default `docs/plans/`), house design-doc paths and formats, ADR path and numbering rule |
| Domain language and law | plan, techlead, review | glossary file, ADR directory, rules that are law, spelling |
| Agents by phase | research, techlead, review, implement, fix | repo agents to prefer for map, prior art, review seats, verification, debugging; fallbacks are built-in `Explore`, `Plan`, `general-purpose` |
| Skills by phase | plan, implement, qa, review | repo or personal skills to invoke when present (grill-me, minimal-implementation, review skills, journey-test tools) |
| Browser drivers | prototype, personas, qa, verify | which MCP or skill drives a browser; whether subagents can use it; shared-browser rule (sequential personas) |
| Design tokens and UX invariants | prototype, personas | palette, font, radius, what a prototype must not break |
| Architecture canon | techlead, review, implement, refactor | layering, mutation rules, invariants, the "simple field touches N layers" cost |
| Deploy reality | techlead, implement, refactor, ship, babysit | rolling deploys, expand/contract, what never auto-rebuilds, merge queue, preview environments |
| Feature flags | plan, implement, qa, ship | how flags are declared, read, and flipped; rollout stages (internal, cohort, percentage, all); kill switch; who may flip in production; when a flag must be removed |
| Analytics and instrumentation | plan, qa, ship | how product events are emitted and where they are queried; naming convention (object plus past-tense verb, casing); who owns the tracking plan |
| Required reviewers by path | review, implement, fix | path glob → reviewer agent (security, migrations, billing, sandbox) |
| Tracker | plan, implement, qa, fix | how to create and link tickets, only on request |
| Forge | setup, opening-a-pr, babysit, implement | the tool, the repo, the account that has access and its permission, verified by `gh repo view` at setup; `UNKNOWN` with the failing command stops any playbook that pushes |
| Evidence | verify, implement, qa, opening-a-pr, prototype | where text evidence lives (the plan folder), where screenshots and recordings go (PR attachments or an artifact store), whether binaries may be committed, that the scratchpad is never a cited path |
| Observability | why, fix, perf, verify, ship | where logs, traces, and error tracking live and how to query them |
| Judge | the question-gate hook, how, research, pm, techlead, review, personas, babysit, reflect | a decision model (`typesafe/jev-latest` or `none`) and its mode (`shadow` logs verdicts beside the session's own, `gate` lets them route); the gates and thresholds live in the suite's `references/judge-questions.json`, the client in `scripts/judge`, the verdict log in `.product-builder/judge-log.jsonl` |

`.product-builder/learnings.md` sits beside the profile: append-only entries written by `product-builder-reflect` after approval and read by the planning and review skills before they recommend.

### 4.3 `personas.md`

A product's audience is stable across features. Four to eight standing personas: name, role, context, what they know, what they will not tolerate, typical goals. Include consumer personas for non-UI surfaces (an integrator calling the API, a script, the on-call engineer reading the logs). `product-builder-personas` casts from the roster first and adds one-off personas per feature (a wrong-role user, a mobile user, the person who receives the output). New personas learned in a run are proposed back into the roster by `product-builder-reflect`.

### 4.4 `drive.md`

How to launch the app locally, the readiness signal, a test account or login path, how to seed data, stable selectors (`data-testid`, ARIA labels, route paths), whether two instances can run at once, how to flip a flag locally, teardown. Read by `product-builder-verify`, `product-builder-personas` (live mode), and the QA playbook. Written by `product-builder-setup` by interviewing the repository, not the user, and validated by doing it once.

### 4.5 `models.md`

Per-role model choices, written by `product-builder-setup` after a budget question (unlimited, large, medium, small) and a per-role confirmation, one line per role: plan explorers, prior art, arena runners, persona agents, pm seats, techlead seats, review seats, implementer, verifier. A role with no line runs on the session model. Alias `inherit` means the session model. Every real model written must be one the session can actually spawn.

### 4.6 Overrides and additions

- `.product-builder/principles.md`: project rules appended to the suite's seventeen.
- `.product-builder/overrides/templates.md`: replaces any of the plan templates, or the Definition of Ready and Done.
- `.product-builder/routes.md`: extra playbook-match rows pointing at project-local playbooks or skills (a deploy playbook, a data-migration playbook).

### 4.7 What stays generic

No skill may name a framework, a package manager, a file path outside the plan root, an MCP tool, or an agent. Those come from the profile. Before shipping, grep the suite for `bun`, `npm`, `svelte`, `react`, `app/`, `mcp__`, `gh ` and move every hit into the profile or behind a "per the profile" clause. `gh` is allowed in the Opening a PR playbook and the Babysit playbook with a profile override for other forges. The judge is named only as "the profile's judge" and its gates; the endpoint lives in `scripts/judge` and the model in the profile, and every gate has a no-judge fallback (the session model judges, said once).

## 5. Playbooks and leaf skills: product track (plan, build, QA, ship)

Written for the product engineer who owns the feature. Playbooks are step lists the mode copies into the todo list; each has a **Match** line (what the mode matches on), an ownership statement, numbered steps, and a **Reply** contract. Leaf skills have frontmatter and are callable on their own. Every reply follows the mode's Writing the reply rules (§3.8). The mode is drafted in full in `skills/product-builder/SKILL.md` and needs no changes beyond moving into the new repo.

### 5.1 `product-builder-setup`

**Purpose.** Write `.product-builder/profile.md`, `personas.md`, `drive.md`, and `models.md` for a repo, interviewing the repository first and the user second.

**Frontmatter.** `name: product-builder-setup` · description: "Prepares a repository for the product-builder suite: detects the stack, commands, docs layout, glossary and ADRs, available agents and skills, browser drivers, design tokens, feature-flag and analytics conventions, observability, and how to launch and drive the app, then writes .product-builder/profile.md, personas.md, drive.md, and models.md (per-role model choices after a budget question). Interviews the repo before the user. Use on first run in a repo, or 'set up product-builder', 'refresh the profile'." · `argument-hint: [--refresh]`

**Steps.**
1. Detect: package manager and scripts (`package.json`, `pyproject.toml`, `Makefile`, `Cargo.toml`, `go.mod`), check and test commands, dev command and port, docs directories (`docs/`, `adr/`, `CONTEXT.md`, `AGENTS.md`, `CLAUDE.md`, `DESIGN.md`), `.claude/agents/` and `.claude/skills/`, personal skills, MCP servers in the session (browser drivers, log or error tools) and whether subagents can use them, CI config (what runs where), design tokens, the feature-flag mechanism (grep for the flag helper), the analytics helper and event naming, forge (`gh` or other).
2. Interview the user one question at a time, only for what detection cannot answer: who the product is for (seed three to five personas, including a consumer persona if there is an API), a test account or login path, what is law (glossary, ADRs), deploy reality and who may flip flags in production, reviewers required by path, where logs and product analytics live.
3. Write the three files from the §4 schema. Mark every detected fact with where it was read; write `UNKNOWN` rather than guess.
4. Validate `drive.md` by doing it once: launch, wait for readiness, open the root page in the browser driver, screenshot, teardown. Record the outcome. No driver → mark drive as paper-only and say so.
5. Models: detect the models this session can spawn, ask one budget question with the question tool (unlimited, large, medium, small), show the per-role table with the defaults applied, confirm or change roles, and write `.product-builder/models.md`. Never write a model the session cannot spawn.
6. Reply with the four paths and the `UNKNOWN` list.

`--refresh` re-detects and shows a diff against the existing files instead of overwriting.

### 5.2 Playbook: plan (`playbooks/plan.md`)

**You own the plan, not the code. Interview, research, decide, draft, prototype, verify, hand off.** Delegate exploration, panels, and personas to leaf skills; stay in the lead.

**Match.** "Staged feature planning for product engineers. Interviews the user to frame the problem (grill-me discipline), fans out research on the current system, the closest existing feature, prior art, and spikes, interviews again to lock decisions and user stories with acceptance criteria, writes a short product plan (problem, audience, appetite, solution with surfaces and states, stories, non-goals, instrumentation, rollout) and a short implementation plan (current-to-target diagram, change table, riskiest-first PR slices with tests and rollback), checks the slices against the appetite, builds a throwaway prototype when a decision needs one, verifies with target-audience persona subagents and a tech-lead panel, and hands off only when the Definition of Ready is green. Writes docs/plans/<slug>/. Use for 'plan this feature', 'scope this', 'write a product plan', or when product-builder routes here. For an existing plan the mode matches Revise."

**Steps, copied verbatim into the todo list.**

```
- [ ] 0 Intake: baseline, size, budgets, folder
- [ ] 1 Interview 1 (frame) → G1
- [ ] 2 Research: system, closest feature, prior art, spikes → G2
- [ ] 3 Interview 2 (decide) + user stories → G3
- [ ] 4 Draft product.md + implementation.md, appetite check → G4
- [ ] 5 Prototype (only if a decision needs one) → G5
- [ ] 6 Verify: personas + tech lead → rulings → G6
- [ ] 7 Definition of Ready → G7
```

**Phase 0, intake.** If the argument names an existing plan folder, invoke the Revise playbook and stop. Read the profile. Apply the baseline rule; record the SHA and the behind-count; a behind-count above the profile's stale threshold means anchors are read from `origin/<default>` and "which tree?" is asked first. Run the intake probe against the default branch and the remotes (code, flags, branches, worktrees, log, ledgers, learnings) and open the ledger with its three lines; a `ships` verdict stops with one question. Choose a slug (kebab, at most four words). Create `docs/plans/<slug>/decisions.md` from the template with status `Draft`; other files are created when their phase runs. Size the work with the §3.5 table, write the size and its budgets in the ledger header, and say which phases will run. **Fast path for Bounded:** phases 1 and 3 merge into one interview of at most five questions, research is one explorer, phase 5 is skipped unless a UX fork appears, and phase 6 is the tech lead alone unless the user asks for personas. Program size also creates `README.md`; parts are decided after Interview 1 from the scope map, each part a shippable user-facing increment, never a layer.

**Phase 1, Interview 1 (frame).** Invoke `grill-me` if installed; the rules are also in `references/interview.md`. Before each question, check whether the repo answers it (grep, read, git log, existing docs under the plan root, the persona roster). Use a multiple-choice question with the recommended option first when the answer space is enumerable; free text otherwise. Pick at most eight questions from the bank, in priority order. Exit when all are recorded: a problem statement of at most three sentences, today's workaround, one to three persona seeds, the appetite, at least one non-goal, a success signal and a kill criterion, constraints, prior attempts checked, stakeholders named. Write the answers into a draft `product.md` (Problem, Who, Appetite, Non-goals, Success signal) and the ledger; stakeholder questions the user cannot answer go to `questions.md` (the questionnaire fallback). Close the interview by stating the three to five premises the plan rests on, one sentence each; G1 presents them with the framing and asks once: agree with all, or name the one to change. A disagreed premise is rewritten before research. Status → `Framed`.

**Phase 2, research.** Invoke `product-builder-research <slug>`. Read its "Closest existing feature", "What this changes about the framing", and "New questions for Interview 2". G2, light: at most five bullets of what changed; ask one question only if a framing item is contradicted. Status → `Researched`.

**Phase 3, Interview 2 (decide) plus user stories.** Build the decision tree from the research questions, the product forks (scope, terminology against the glossary, defaults, permissions per role, visibility, empty and error states and their copy, destructive actions and undo, notifications, mobile, what the feature does when its flag is off), and the technical forks (seam to reuse, data model, sync or async, migration, backward compatibility of stored data and clients, integration points, flag or dark launch, what to instrument). Walk it depth-first, dependencies first. Product calls are asked. Technical calls are recommended and recorded; ask only when the call changes what the user sees or costs appetite. Draft three to eight stories (Bounded: one to three) and present the set as a numbered list for editing, then discuss contested stories one at a time. Story rules: every story traces to a persona and to the problem; every must-story is demoable on its own (one that cannot be is two stories or an enabling slice); every must-story carries at least one failure or edge acceptance line; for a UI story, name the surface and the five states (loading, empty, error, populated, live-updating); for a non-UI story, name the consumer and the contract sample (request and response, CLI transcript, event payload); if roles exist, a permissions line per role. Ask which story is cut first if the appetite runs out. Decisions that cannot be settled on paper are marked `→ prototype`. Then list the assumptions the plan rests on, each tagged desirability, viability, feasibility, usability, or ethical, and place each by importance and evidence. The high-importance, low-evidence ones are the riskiest, and each gets a test before the Definition of Ready: a prototype walkthrough, a persona session, a spike, existing data, or a one-question check with the user. Assumptions go into `product.md` with their test and, later, their verdict. Exit when the frontier is empty or the user says move on; the rest goes to Open with recommendations. Gate G3. Status → `Decided`.

**Phase 4, draft and appetite check.**

`product.md`, about two pages: Problem; Who it's for; Appetite; Solution at fat-marker level with an ASCII sketch and a **Surfaces and states** table (surface, placement, the five states, keyboard and mobile notes); User stories; Non-goals; Rabbit holes; **Assumptions** (the table from Phase 3 with each test and verdict); **Instrumentation** (the product events to emit, named per the profile's convention, each with trigger, properties, and owner, and the query that will read the success signal; events describe outcomes, not UI surfaces); **Rollout and launch** (flag name and default, rollout stages, kill switch, what the user sees with the flag off, when the flag is removed, docs or changelog or support note needed); **Success signal** written as a hypothesis (the metric with its baseline and target, and the guardrail metrics that must not get worse); Open questions.

**Approach arena (Feature and Program).** Before writing the approach, dispatch two or three architect subagents in parallel with the same stories, research, and canon, and distinct mandates: minimal change (fewest files, reuse everything), clean shape (the structure a fresh design would have), pragmatic (the best trade between the two). Each returns a usage sketch, the files it would touch, its slice order, and what it gives up. Compare them in a table, recommend one, and ask only if the candidates differ in what the user sees or in appetite. The rejected candidates become the simpler-alternatives table. Bounded size skips the arena and writes that table from one candidate.

`implementation.md`, about three pages: current → target ASCII diagrams with every current box anchored in `research.md`; Approach in three to eight lines naming the closest existing feature being modelled on; a table of simpler alternatives and the story or constraint each fails (reuse ladder: existing seam, framework or standard library, installed dependency, new code); Changes table with real, verified paths; Data and contracts with expand/contract steps; **Test strategy** (which existing test seams to extend, what is unit versus integration versus end-to-end, what runs only in CI); **Observability** (the logs, metrics, and error signals that make the feature debuggable in production); Slices; Risks and rollout; Open questions.

Slices: one PR each, vertical, ordered **riskiest and most uncertain first**. When rollout uses a flag, P1 is the walking skeleton: the flag plus the thinnest end-to-end path, so every later slice merges dark. A schema expand is its own slice, merged and deployed before anything that depends on it. Each slice block names: stories, depends-on, size (S, M, L), files, data, flag, tests (each acceptance line of its stories maps to a named test or a live check), live check, regression, rollback, and "you see". 

**Appetite check.** Add up the slices against the appetite from G1. If the plan is over, propose cuts before showing the drafts: drop `later` stories, defer whole slices into a follow-up plan, or shrink a story to its must-line. Cuts are product calls and are asked at G4 with the recommendation first. Everything cut or deferred is written to the ledger's Deferred section with what would bring it back.

Coverage check: every story maps to at least one slice; every slice maps to a story or an "enabling" reason. Split rule for Program: more than four slices, more than two subsystems, or more than one independent surface → `README.md` overview plus `parts/<slug>/product.md` and `implementation.md`, each part shippable on its own, part 1 the walking skeleton, shared decisions in the root ledger. Self-review: no placeholders, no contradiction with the ledger, no unanchored current-state claim, both docs within cap, every must-story has a failure line, every slice has tests and rollback. Gate G4: a gate card with a ten-line digest of each document and the appetite verdict, then the three fixed options. Status → `Drafted`.

**Phase 5, prototype (conditional).** Run when a decision is marked `→ prototype`, a story's acceptance depends on feel, or the surface is new; otherwise write `Prototype: none (<reason>)` in the header. Invoke `product-builder-prototype <slug>`, which picks the mode (standalone HTML, in-app spike, or contract sample). G5 is inside the helper. Status → `Prototyped`.

**Phase 6, verify.** Invoke `product-builder-personas <slug>` (prototype target, or paper mode against the stories), `product-builder-pm <slug>` on `product.md`, and `product-builder-techlead <slug>` on `implementation.md`. Each runs its own rulings discussion and applies accepted edits. Re-run only changed stories and slices. Exit when no "act on" finding is open. Status → `Verified`.

**Phase 7, Definition of Ready and hand-off.** Walk the Definition of Ready (§5.13) item by item and print it with each box checked or named as missing; a missing item sends the plan back to the phase that owns it. When green: status → `Ready to implement`; revision-log row "initial plan". Reply: folder path; digest (problem, who, appetite, story count, slices in order with sizes); ASSUMED decisions first; open questions with owners; prototype path; what verification found and what was applied. Offer tickets per slice if the profile has a tracker. Gate G7: wait for "go".

**Reply.** The plan folder path; who the feature is for and what changes for them; the digest of `product.md` and `implementation.md`; the approach chosen and the candidates it beat, in a table; the principles that shaped the calls; what verification found and what was applied; ASSUMED rows first, then open questions with owners; the prototype path; the next move ("go" starts the Implement playbook).

**Anti-patterns written into the playbook.** Bundling questions outside the story set; asking what grep answers; drafting before G1; a plan over the caps; a prototype without a named decision; a must-story without a failure line; an approach written without candidates at Feature size; a riskiest assumption left untested at hand-off; slices ordered easiest-first; skipping the appetite check; skipping the tech-lead pass on a Bounded plan; editing a locked decision without superseding it; handing off with a red Definition of Ready item.

**`playbooks/plan-interview.md`** (the plan playbook's reference). The six interview rules (one question per turn; recommended answer with a reason; explore before asking; depth-first; dependencies first; stop when the frontier is empty). Interview 1 bank, in priority order, each with an explore-first hint; ask at most eight:

1. Trigger story: "What happened that made this worth doing now? Tell it as one concrete situation." Explore: recent issues, support notes, commits in the area.
2. Who: "Who was the person in that story, what is their role, how often does this hit them?" Explore: `.product-builder/personas.md`.
3. Today's workaround: "What do they do today instead, and what does that cost them?" The workaround reveals the real need and usually the smallest solution.
4. Done: "If this shipped perfectly, what does that person do differently, or what stops happening?"
5. Appetite: "One PR this week, a few PRs over a couple of weeks, or a multi-part program?" Recommend from the area's size.
6. Non-goals: "What are we explicitly not doing even though it is adjacent?" Recommend from adjacent features in the repo.
7. Constraints: "Anything fixed: dates, must-use or must-not-use tech, compatibility, decisions already made?" Explore: ADRs, glossary.
8. Success signal and kill criterion: "A week after shipping, what tells us it worked, and what would tell us we were wrong?"
9. Prior attempts: "Has this been tried or drafted before?" Explore: plan root, design docs, closed PRs, branches.
10. Stakeholders: "Who else must agree, and who will be surprised?" Unanswerable items become `questions.md`.
11. Observation: "What did you notice about this problem that the obvious solution misses?" Asked only when the answers so far are conventional.

Questions 1, 2, 3, and 5 carry the office-hours stance: push back on a category where a person is wanted, label the evidence for demand, treat the workaround as the smallest solution's competitor, and recommend the narrowest wedge first with the full vision written to Deferred.

Interview 2 categories with sample forcing questions: scope forks from research ("the code has X and Y paths; both, or only X, and why?"); terminology ("the glossary calls this a Stack; you said bundle; which word?"); defaults and permissions ("who can do this by default, who must never, and what does a viewer see?"); states and copy ("what does the empty state say, what happens on failure, what does the flag-off state look like?"); destructive actions ("undo, confirmation, or neither?"); story priority ("which story goes first if the appetite runs out?"); seam ("reuse seam A, recommended because …, or add B?"); rollout ("flag with a cohort, dark launch, or everyone?"); instrumentation ("which event proves the success signal, and what property makes it queryable?"); assumptions ("what must be true for this to work, and how much evidence do we have for it?"). Forcing patterns: why X and not Y; what is the kill criterion; what is blocking the decision; which side of the trade-off; what is the dependency; even at 60% confidence, what is the call today.

User-story format:

```
### S1. <short name>
As a <persona>, I want <capability>, so that <benefit>.
Surface: <screen or endpoint or command> · States: loading, empty, error, populated, live   (UI stories)
Consumer: <who calls it> · Contract sample: <request → response, transcript, or payload>   (non-UI stories)
Acceptance:
- WHEN <trigger or context> THEN <observable result>
- WHEN <failure or edge> THEN <observable result>
Permissions: owner …, member …, viewer …   (when roles exist)
Priority: must | should | later · Verified by: prototype catalog #, persona walkthrough, test name, QA
```

Stop rules: frontier empty; three answers in a row raise nothing new; the answer is predictable; the user signals fatigue (record the rest as Open); the decision is cheaply reversible (do not grill it). Questionnaire fallback: when the user says "I'll answer later" or names a stakeholder who holds the answer, write `docs/plans/<slug>/questions.md`, most important first, one question per heading, a recommended answer and an answer stub under each, and continue on the recommendations as ASSUMED.

### 5.3 `product-builder-research`

**Purpose.** Map the current system for the plan's area, find the closest existing feature to model on, tear down comparable products, and run spikes where a fact cannot be read. Writes `research.md`. Reuses `product-builder-how` for the system map.

**Frontmatter.** `name: product-builder-research` · description: "Maps the current system for a plan area with parallel read-only explorers (entry points, data flow, persistence, events, tests, seams, permissions, constraints, each with file:line at a named SHA), finds the closest existing feature and the PR that added it, runs a prior-art teardown of comparable products and tools, and time-boxed spikes (API probe, mock API, feasibility script) when a fact cannot be read. Writes docs/plans/<slug>/research.md. Use when the Plan playbook reaches research, or alone for 'map this area', 're-research, main moved', 'how do others do X'." · `argument-hint: [slug] [--system|--prior-art|--spikes|--delta]`

**Steps.**
1. Inputs: read `decisions.md` and the draft `product.md`; derive keywords, candidate paths (grep), user-facing surfaces, roles involved, third-party services.
2. Baseline: confirm the SHA. If `research.md` exists at a different SHA, `--delta` mode: `git diff <old>..<new> --stat -- <paths>`, refresh only changed anchors.
3. System map: invoke `product-builder-how --map` with the area and keywords; it fans out two to four read-only explorers (angles: entry points and surfaces; data model and persistence; services, events, jobs, realtime; tests, fixtures, similar features, extension seams, permissions, glossary and ADR constraints). Bounded size uses one explorer. Each returns at most forty lines of pointers with file:line, conventions, commands; no code dumps.
4. Closest existing feature: the one feature already in the product that this most resembles, its files, the PR that added it, and the conventions it followed (component, route, service, test, flag, event). The plan models on it unless research shows why not.
5. Prior art, in parallel with 3 and 4: three to five comparable products or tools (ask the user only when the space is unfamiliar). For each: how they solve it, table stakes, differentiators, pitfalls, sources with retrieval date. Use the profile's research agent if one exists, else web search and fetch. Time-box: about ten fetches.
6. Spikes, only for facts that cannot be read: a third-party API's real shape or limits (probe script with a real call, secrets redacted, never production credentials), an unknown contract (a mock API stub so the prototype and plan can proceed), feasibility (does library X do Y), rough performance. Scratch dir `docs/plans/<slug>/spikes/<name>/` or the session scratchpad; at most about thirty tool calls each; one verdict line; never merged into app code.
7. Write `research.md` from the template, including "Closest existing feature", "What this changes about the framing", and "New questions for Interview 2" (each with the fact that raised it and a recommendation).
8. Reply in at most ten lines: what was mapped, the closest feature, prior-art count, spike verdicts, what changed.

**Explorer prompt (in `references/explorer-prompt.md`).**

```
You are a read-only explorer for a planning run. Baseline: <sha>. Area: <name>. Keywords: <list>. Starting paths: <list>.
Angle: <one of: entry points and user-facing surfaces | data model, persistence, migrations | services, events, jobs, realtime | tests, fixtures, similar existing features, extension seams, permissions, glossary and ADR constraints>.
Report only what you verified by reading. Cite file:line for every claim. Say "not found" when it is not found. Flag docs that contradict code.
Return at most 40 lines in this shape:
- Map: entry → flow → persistence → events → tests, one real path per hop
- Reuse: existing helpers, patterns, components this feature should extend (path + one line)
- Closest feature: the nearest existing feature and its files, if your angle shows one
- Constraints: rules from ADRs, glossary, permissions, deploy reality that bind the design (path + one line)
- Cost: the layers a change here must touch (count and names)
- Open: facts you could not settle by reading, phrased as questions
No code dumps. Pointers, not payloads.
```

### 5.4 `product-builder-prototype`

**Purpose.** A throwaway artifact that settles one named product or UX decision before code is written.

**Frontmatter.** `name: product-builder-prototype` · description: "Builds a throwaway prototype to settle one named product or UX decision: a standalone clickable HTML page (default) with variants behind a switcher and a catalog where every user story and state is a jump; an in-app spike on a branch that is never merged, when the feel depends on real data or latency; or a contract sample (requests and responses, CLI transcript, event payloads) for non-UI surfaces. Uses the project's design tokens, checks readiness (every story reachable, five states present, real copy, keyboard path), serves and screenshots it, presents alternatives with a recommendation, and records the decision in the plan ledger. Use when the Plan playbook marks a decision '→ prototype', or for 'prototype X', 'mock this up', 'let me click through it'." · `argument-hint: [slug] [--decision "..."] [--mode html|in-app|contract]`

**Rules.** No decision, no prototype (route back to the plan). Throwaway: speed over polish, no tests, no abstractions. Never import into the app; the folder is documentation. Read the closest existing feature's screen first so the prototype matches the app's shape.

**Modes.**
- **Standalone HTML** (default for UI feel): one `index.html` under `docs/plans/<slug>/prototype/`; vanilla HTML, CSS, JS; CDN dependencies allowed; the profile's tokens and font; a catalog sidebar listing every story `S1..Sn` and every state (loading, empty, error, populated, live) as a jump; variants `A/B/C` via `?v=` and a floating switcher; state visible after every action; in-memory only; realistic data and real copy, never placeholder text.
- **In-app spike** (when the feel depends on real data, real latency, or a real component): a branch `<slug>/spike-<decision>` behind the feature flag, the smallest code that renders the idea, no tests, never merged; the decision and screenshots are recorded, then the branch is left to expire.
- **Contract sample** (non-UI surfaces: API, CLI, job, event): `docs/plans/<slug>/prototype/contract.md` with example requests and responses, a CLI transcript, or event payloads for every story and every failure line; consumer personas read it.

**Readiness check before personas.** Every story reachable from the catalog; the five states present for every UI story; real copy; keyboard path works; the flag-off state is shown when rollout uses a flag. "If a row cannot be clicked, the plan is not done."

**Steps.** 1 name the decision (ledger or one question) · 2 read stories, personas, tokens, the closest feature's screen · 3 pick the mode and build · 4 serve with `scripts/serve.sh <dir> [port]` (python3 `http.server` on a free port from 8765, background, PID file, `--stop`; error with a hint if python3 is missing) · 5 readiness check in the browser driver: click every catalog row, screenshot each variant and story to `prototype/shots/`, fix what is broken · 6 present variants, trade-offs, recommendation; G5: ask only if variants differ on a product call · 7 record: ledger decision row with the prototype as evidence, `Prototype:` header line in `product.md`, `Verified by: prototype #` on stories.

### 5.5 `product-builder-personas`

**Purpose.** Target-audience subagents click through the prototype or the live app, think aloud, are interviewed, and their findings are discussed with the developer.

**Frontmatter.** `name: product-builder-personas` · description: "Casts 3-5 target-audience personas from .product-builder/personas.md and the plan's user stories, gives each a concrete intention, and runs each as a subagent that drives the prototype or the live app in a real browser (or reads a contract sample as a consumer), runs a five-second first-impression test, attempts the stories thinking aloud, and is interviewed afterwards. Synthesises findings per story into act on / consider / noted / dismissed, discusses them with the developer, records rulings in the ledger, applies accepted edits, and re-runs only the changed stories. Use when the Plan or QA playbook reaches verification, or for 'have users try this', 'walk through as a new user', 'usability pass'." · `argument-hint: [slug] [--target url|path] [--stories S1,S3] [--paper]`

**Steps.**
1. Inputs: plan folder; target (prototype dir → serve it; URL → live mode, read `drive.md` for login, seed, and flag; contract sample → consumer mode); story filter. Refuse to run before the prototype readiness check has passed.
2. Cast: three to five cards. Always one first-time user, one skeptic or power user, one edge (wrong role or no permission, mobile width, slow network, or the person who receives the output); for non-UI surfaces, the integrator and the on-call engineer. Card: name, role, context, what they know, goal for this session in their words, stories to attempt, what makes them give up, success from their point of view. Show the cast as a table; the user may swap.
3. Driver per profile. Shared browser → personas run sequentially, each in a fresh tab. No driver, or `--paper` → the persona reads the rendered text only and the report says "paper walkthrough".
4. Run one subagent per persona with the prompt below. Each session opens with the five-second test (what is this, what can I do here, what would I click first) before any task. Screenshots at key moments to the scratchpad.
5. Synthesise: five-second answers side by side; per story, pass / partial / fail per persona; findings table (severity, story, personas hit n/N, what happened, what they expected, recommendation); consensus map; copy problems; missing states; permission surprises.
6. Discuss with the developer: at most eight findings, proposed buckets, then multi-select rulings on act-on and consider items (at most four per question). For each accepted finding the developer picks one of four responses, recorded in the ledger: change the plan (a story, a state, copy), change the prototype, accept the risk (with the reason), or needs real users (becomes an open question with an owner). Apply the first two when reversible; re-run only the changed stories with one or two personas.
7. Report ends with the limitation paragraph: LLM personas over-deliberate, carry stereotype bias, and are a pilot session, not a substitute for real users; use them for flow gaps, unclear copy, missing states, and permission surprises, not for quantitative claims.

**Persona prompt (in `references/persona-prompt.md`).**

```
You are <name>, <role>. <context: what you know about the product, what you are trying to get done today, what you will not tolerate>.
Your goal this session, in your own words: "<goal>". You will consider yourself done when <success criterion>. You give up after three dead ends and say so.
Open <URL>. <login, seed, or flag steps from drive.md, if any>.
First, before touching anything, look for five seconds and answer as <name>: What is this? What can I do here? What would I click first, and why?
Rules: stay in character. Use only what is visible on screen; never read source, never guess hidden routes. Before each action write one line each: I see / I expect / I do. After each action write: what happened / how I feel about it (one short sentence). Take a screenshot when something surprises you, and at the end.
Attempt these stories in order: <S1 …>. For each, say whether the acceptance held: <WHEN/THEN lines>.
When done or given up, answer as <name>:
1. What were you trying to do, and did you get it done?
2. Where did you hesitate, and what did you expect to see there?
3. What word or label confused you?
4. What would you change first?
5. Would you use this again? (1-5 and why)
6. What did you never notice that the designer probably wanted you to?
7. Anything that felt slow, risky, or irreversible?
Return: a JSON block {persona, five_second: {what, can_do, first_click}, stories: [{id, result: pass|partial|fail, evidence}], dead_ends: [...], screenshots: [...]} followed by the think-aloud log and the interview answers.
```

### 5.6 `product-builder-techlead`

**Purpose.** A small panel reads `implementation.md` against the code and tells the developer whether it is sound, simplest, and safe to build in the stated order.

**Frontmatter.** `name: product-builder-techlead` · description: "Casts a tech-lead panel (tech lead and staff simplicity hawk always; database or release, security, frontend, SRE, integration seats by signal) of read-only subagents to review an implementation plan against the code at the baseline SHA. Verifies every current-state claim, looks for a simpler seam, checks change-site completeness, migration and rollout safety, riskiest-first slice order and the walking skeleton, test strategy, observability, permissions, performance at scale, story-to-slice coverage, and whether an unverified assumption needs a spike. Merges findings into act on / consider / noted / dismissed with reviewer attribution, kills false positives, discusses rulings with the developer, records them, applies accepted edits. Use when the Plan playbook reaches verification, or for 'is this plan sound', 'tech lead review', 'sanity-check the approach'. For a diff, use product-builder-review." · `argument-hint: [slug] [--slices P1,P2]`

**Steps.** 1 read the plan folder and the profile's canon, deploy reality, flags, reviewers-by-path · 2 cast two to four seats by signal, say why · 3 dispatch in parallel with self-contained prompts (baseline SHA, the three docs inline or by path, the mandate, output schema) · 4 verifier pass by the lead (you): re-check every critical and high finding against the code and drop what does not survive · 5 four buckets with attribution and an agreement map · 6 rulings with the developer, multi-select, at most four per question · 7 apply accepted edits to `implementation.md`, ledger rows, re-run the affected seat only if a slice changed shape · 8 if any seat marked an assumption "unverified", recommend a spike and route it to `product-builder-research --spikes`.

**Reviewer prompt (in `references/reviewer-prompt.md`).**

```
You are the <seat> on a tech-lead panel. Read-only. Baseline: <sha>.
Read: product.md, implementation.md, research.md (paths). Read the code the plan cites before judging it.
Judge, in this order:
(1) every current-state claim in implementation.md, verified or refuted at file:line;
(2) is there a simpler seam that satisfies the same stories, and what does it cost;
(3) change sites the plan misses (search the aliases the domain uses);
(4) data, migration, rollout safety per the profile's deploy reality; the schema-expand slice is first and separate;
(5) slice order: riskiest and most uncertain first, P1 a walking skeleton behind the flag when there is one, each slice demoable alone, no slice larger than L;
(6) test strategy: does each acceptance line map to a named test or live check, and does the named seam exist;
(7) observability: can a failure of this feature be diagnosed from logs and metrics without a repro;
(8) permissions and security per role, tenancy isolation, hostile input;
(9) performance at scale: N+1, pagination, payload size, hot paths;
(10) story ↔ slice coverage; (11) names against the glossary; (12) assumptions the plan makes that no one has verified, and whether a spike would settle them;
(13) prime directives: zero silent failures and every error has a name (the exception, its trigger, its handler, what the user sees); every data flow has its shadow paths (nil, empty, upstream error); every interaction has its edge cases (double-click, navigate-away, slow network, stale state); observability is in scope, not an afterthought; boring technology by default; reversible by preference (flag, incremental rollout);
(14) diagrams: a state machine, sequence, or data-flow diagram exists for every non-trivial flow, and it agrees with the code;
(15) the test matrix: implementation.md's per-slice lanes read as a test plan QA can execute (each acceptance line, each failure line, each role, both flag states).
For each finding: severity (critical | high | medium | low), confidence 0-100 (below 60 is reported as noted, never as act on), file:line or plan section, the concrete failure scenario, the suggested change. No "feels complex": name the simpler place it could live.
Also return: your one-paragraph "simplest path" statement, the coverage matrix (story → slices), the list of unverified assumptions, and any diagram the plan is missing, drawn in ASCII.
At most 60 lines. Pointers, not payloads.
```

### 5.7 `product-builder-pm`

**Purpose.** A product panel reads `product.md` the way a strong PM, a skeptic, a designer, a data analyst, and a customer would, and tells the product engineer what is missing before anything is built.

**Frontmatter.** `name: product-builder-pm` · description: "Casts a product panel of read-only subagents over a product plan: a product manager (problem, audience, stories, non-goals, appetite), a skeptic (what breaks the hypothesis, what the workaround already solves), a designer (surfaces, states, copy, keyboard and mobile), a data analyst (success signal as a hypothesis with baseline, target, and guardrails; instrumentation that can actually answer it), and a customer voice from the persona roster. Verifies story coverage of every persona, failure lines, permissions, assumptions and their tests. Merges findings into act on / consider / noted / dismissed with attribution and confidence, discusses rulings with the developer, records them, applies accepted edits. Use when the Plan playbook reaches verification, or for 'review my product plan', 'is the PRD solid', 'poke holes in the stories'." · `argument-hint: [slug] [--seats pm,skeptic,designer,analyst,customer]`

**Steps.** 0 after the seats report, ask one scope question with the question tool: hold scope (recommended when the appetite check passed), reduce to the wedge (the smallest version that still moves the signal, the rest to Deferred), selective expansion (the panel's one or two high-impact additions, each its own yes or no), expansion (only when the user asked to think bigger); the PM seat's must-answer lines are "what existing feature already solves part of this" and "which decisions must be made now rather than during implementation" · 1 read `product.md`, `decisions.md`, `research.md`, `.product-builder/learnings.md`, the persona roster, and the profile's analytics convention · 2 cast three to five seats; the PM and the skeptic always sit; the designer when a UI story exists; the analyst when a success signal or instrumentation is claimed; the customer voice from the roster · 3 dispatch in parallel, read-only, self-contained prompts with the panel prompt below · 4 verifier pass: drop findings that the plan already answers · 5 four buckets with attribution and confidence · 6 rulings with the developer, multi-select, at most four per question · 7 apply accepted edits to `product.md` (stories, states, copy, assumptions, instrumentation, non-goals), ledger rows, and hand anything that changes a slice to `product-builder-techlead`.

**Panel prompt (in `references/panel-prompt.md`).**

```
You are the <seat> on a product panel. Read-only.
Read: product.md, decisions.md, research.md (paths). Persona roster: <path>.
Judge from your seat:
- product manager: is the problem a real story with a workaround and a cost; does every persona have a story; do the non-goals and appetite bound the solution; which story is cut first; what is the smallest version that still moves the signal
- skeptic: what would make the hypothesis false; which assumption has the least evidence; what the workaround already solves well enough; what a competitor from research.md does that this ignores
- designer: does each UI story name its surface and five states; is the empty and error copy written; keyboard and mobile paths; anything that breaks the profile's UX invariants; for information architecture, states, journey, and copy give a 0-10 with one line on what a 10 looks like, and propose the edit that gets there
- data analyst: is the success signal a hypothesis with a baseline, a target, and guardrails; do the named events, properties, and query actually answer it; naming per the profile's convention; what is missing to attribute the change
- customer (<persona>): read the stories as the person in the roster; what you would not understand, not trust, or not bother with
For each finding: severity, confidence 0-100, the section, what is wrong in one sentence, the concrete edit. At most 40 lines. Pointers, not payloads.
```

### 5.8 Playbook: revise (`playbooks/revise.md`)

**You own the plan's history. Classify the trigger, re-run only what it touches, supersede, never rewrite.**

**Match.** "Edits an existing plan under docs/plans/<slug>/ without losing history. Classifies the trigger (requirement or scope change, new fact or main moved, review or QA finding, implementation friction, wording, post-implementation correction), re-runs only the affected phases, supersedes decisions instead of rewriting them, keeps a 'rejected, do not re-introduce' list, refreshes stale file:line anchors, re-verifies only the changed stories and slices, re-checks the Definition of Ready, and logs the revision. Use for 'update the plan', 'the requirement changed', 'main moved', 'implementation found X', 'add a story', or when the Plan playbook finds an existing folder."

**Steps.** 1 load all plan files; print status, baseline, last revision, open ASSUMED rows, the rejected list · 2 one question for the trigger, options: (a) requirement or scope change (b) new fact or main moved (c) review or QA finding (d) implementation friction (e) wording only (f) post-implementation correction · 3 apply the impact matrix:

| Trigger | What runs |
|---|---|
| wording | edit in place; revision-log row |
| decision change | old ledger row → `superseded by Dn`; new row with why; touch the sections; mark dependent decisions `re-check` and walk them, one question each if product; if the new decision re-introduces a rejected idea, say so and ask |
| scope or story change | Interview 2 on the new branch only; stories updated; coverage and appetite checks; slices adjusted; personas on changed stories (update the prototype catalog if one exists); tech lead on changed slices |
| new fact or main moved | `product-builder-research --delta`; refresh anchors; re-check approach and changes table; tech lead if the changes table changed |
| implementation friction | deviation row in the implementation log; decide: supersede the affected decision, split the slice, or scrap the approach for that slice (recurring workarounds, escape-hatch types, callers that must know internals → back to Phase 4 for that slice); never patch silently |
| framing change | back to Interview 1; say so; usually a new plan |
| post-implementation correction | top-of-doc `> Update (date, post-implementation): …` blockquote; the decision record is never rewritten |

4 baseline drift: if `origin/main` moved since the header SHA, diff the paths in the changes table and update the header · 5 status: back to `Drafted` or `Prototyped` if verification was invalidated, else unchanged; re-run the Definition of Ready if the plan was at `Ready to implement` or later · 6 revision-log row.

**Reply.** The trigger and its classification; what changed, section by section; decisions superseded and by what; steps re-run and their results; what still needs the user.

### 5.9 Playbook: implement (`playbooks/implement.md`)

**You own the build. One slice at a time, tests from the acceptance lines, verified on the surface, reviewed, one PR each.** Delegate slices to implementer subagents when they are independent; review every diff yourself.

**Match.** "Builds a plan that passed the Definition of Ready, slice by slice: one branch and one PR per slice, the flag-plus-skeleton slice first, tests derived from the stories' acceptance lines, the smallest implementation inside the plan's change table, verification on the matching surface with evidence, a review panel on the diff that returns spec-compliance and quality verdicts with a bounded fix loop, a briefing-style PR with human verification steps and screenshots, and a ledger entry that survives compaction. Stops at every merge. Independent slices can run in parallel in isolated worktrees. Deviations from the plan go through the Revise playbook instead of silent patches. Use for 'implement the plan', 'build P2', 'continue the build', or when the mode matches it."

**Preconditions.** Status `Ready to implement` with a green Definition of Ready, or an explicit user override recorded in the ledger; the G7 "go"; a worktree off main; if main moved since the baseline, the Revise playbook delta first.

**Per slice.**
0. Re-read `decisions.md` (implementation log) and the slice block. A slice already logged as opened or merged is never redone; this is what makes the run safe across compaction and sessions.
1. Contract: restate the slice in the reply: stories and their acceptance lines, depends-on, size, files, data, flag, tests to write (one per acceptance line, named), live check, regression, rollback. If a dependency PR is not merged, stack on its branch.
2. Branch `<slug>/p<n>-<verb>`.
3. Build. P1 with a flag is the walking skeleton: declare the flag (default off), the thinnest end-to-end path, and the instrumentation event, nothing else. Write the failing tests from the acceptance lines first where a seam exists; implement with the reuse ladder (invoke `minimal-implementation` when installed); stay inside the changes table. **Budget rule:** if the slice grows past twice its size estimate or needs a file outside its list, stop, and route to the Revise playbook (friction path) to split or re-plan; do not push through.
4. Verify: the profile's check and test commands (via the profile's verification agent when one exists); `product-builder-verify` on the matching surface with evidence, with the flag on and off when there is one; the slice's regression lane; for a schema-expand slice, the migration replayed on a scratch database. No pass is claimed unless the command ran in this reply and its output is shown.
5. Review: `product-builder-review --diff --contract <slice>`; both verdicts required (spec compliance against the acceptance lines, and quality); fix loop of at most three rounds; unresolved findings → the user with the reviewer's reason.
6. Opening a PR: links the plan folder and stories; the Verification section includes numbered steps a human can follow to see the change, and before/after screenshots or a short recording for any UI slice.
7. Ledger: implementation-log row (slice, branch, PR, status, deviations); tick the slice in `implementation.md`; `Verified by: <test name>` on the stories.
8. End-of-slice menu: open the PR (default), keep the branch as is, or discard it (only on an explicit request, confirmed by the typed word `discard`). Stop at G8: merge is the user's. Remove worktrees the suite created once their PR is merged; never force-delete uncommitted work. Then the next slice whose dependencies are merged.

**`--parallel N`.** Independent slices (no shared files, no unmerged dependency) may be dispatched to implementer subagents, each in its own isolated worktree, at most N in flight. Each implementer receives only its contract, the plan's change table for its files, and the interfaces from merged slices, and returns one of `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED` with a report. The controller runs steps 4-7 on each returned diff itself. The ledger is the queue; a slice is claimed by writing its row before dispatch.

Autonomy: proceed on reversible work; stop for merge, push to shared branches, migrations against shared databases, deletes, external messages, and production flag flips.

**Reply, per slice.** For the user of the feature, what works now; for the next engineer, what the slice owns; the tests and their output; the live evidence with the flag on and off; the review verdicts and what was fixed; the PR URL; deviations and the revision they triggered; the next slice.

### 5.10 Playbook: qa (`playbooks/qa.md`)

**You own the verdict. Charter from the stories, prove each line on the real app, report with evidence.**

**Match.** "QA for a built feature against its plan: derives a test charter from the user stories' acceptance criteria, the permissions matrix, the slices' verification lanes, and the risks; runs the repo's automated suites; runs acceptance with persona subagents on the real app; runs an exploratory pass (flag on and off, empty and first-run states, error paths, permissions per role, concurrency, mobile width, slow network, keyboard and labels); checks that the instrumentation events fire; rehearses rollback; runs regression on touched surfaces; writes docs/plans/<slug>/qa-report.md with evidence, a bug table, and a ship / fix-first verdict. Use for 'QA this', 'test the feature', 'does it work end to end', or when the mode matches it."

**Steps.** 1 inputs: slug, target (PR preview, staging, or local per `drive.md`), which slices are merged, how to flip the flag there, the mode (diff-aware by default: the changes table plus the pages the diff touches; full; quick smoke; regression against a baseline) · 2 charter table: story → acceptance line → how tested (test name, persona, lane) → role · 3 automated: the profile's suites and journey-test tools · 4 acceptance: `product-builder-personas --target <url> --stories …` live mode · 5 exploratory pass by a QA-engineer subagent with the checklist: flag off shows the old behaviour, flag on shows the new; empty and first-run states; every failure line; each role in the permissions matrix; two users at once; mobile width; slow network; keyboard path and icon labels · 6 instrumentation: the events named in `product.md` fire with their properties, checked in the analytics tool or logs · 7 rollback rehearsal: flip the flag off, confirm the old behaviour and no orphaned data · 8 regression on the surfaces in the changes table via `product-builder-verify` · 9 fix tier when asked or when a bug is trivially local: one fix per bug, one commit per fix (`fix(qa): <id> <description>`), a regression test per verified fix that reproduces the precondition, a before and after screenshot pair, re-test; stop when a fix leaves the slice's files, was reverted, or the risk of a wrong fix exceeds one in five · 10 health score: the share of charter lines passing, before and after · 11 `qa-report.md` from the template: verdict, health score, per-story pass or fail with evidence, fixes with commits and tests, bug table (severity, repro, expected, actual, story), coverage gaps, environment · 12 feed back: remaining bugs to tickets on request or to Implement fix slices; status `QA passed` or `QA failed`.

**Reply.** The verdict first; per story pass or fail with its evidence path; the bug table; what could not be tested and why; the next move (Ship, or Implement for the fix slices).

### 5.11 Playbook: ship (`playbooks/ship.md`)

**You own the launch, not the flip. Pre-flight, prepare, watch, close.**

**Match.** "Ships a feature that passed QA: runs the pre-flight from the Definition of Done (QA verdict, flag and cohort plan, docs or changelog or support note, rollback rehearsed, instrumentation live, reviewers-by-path satisfied), prepares the flip and the announcement for the user to execute, then after the watch window checks the success signal, error rates, and flag-off fallbacks in the profile's observability and analytics tools, and closes the plan as Shipped or opens the revert path. Use for 'ship it', 'roll it out', 'flip the flag', 'did it work after launch', or when the mode matches it."

**Steps.** 1 read the plan and the profile's flags, analytics, observability, deploy reality · 2 pre-flight: walk the Definition of Done items that precede the flip; a red item routes back (QA, implement, or docs); the review and QA verdicts must name the deployed head SHA, a stale verdict is re-run · 3 prepare, never execute: the rollout stages in order (internal users, a named cohort, a percentage, everyone) with the check that gates each step, the kill switch, the changelog or docs entry, the support note, the announcement draft; the user flips and announces (irreversible, external) · 4 canary in the first hour after each stage (touched surfaces load without console or server errors, events arrive, flag-off path unchanged); `--watch` after the window in `product.md` (default three days): run the success-signal query, compare error rates and latency on the touched surfaces against the week before, confirm flag-off users are unaffected, sample the instrumentation events · 5 close: status → `Shipped`, ledger row with the numbers; schedule flag removal as a follow-up slice or ticket so the flag does not outlive its launch; if the signal is missing or errors rose, present the revert path (flag off) and route to Revise or Bug fix; offer `product-builder-reflect`.

**Reply.** The pre-flight with each box; the rollout stages and their gates; what the user must flip and announce; after the watch, the success signal against its baseline, error rates against the prior week, and the flag-removal follow-up; status.

### 5.12 Playbook: program (`playbooks/program.md`)

**You own the overview. Parts are shippable increments, each planned with the Plan playbook.**

**Match.** A plan sized Program by the mode: more than four PRs, several surfaces or subsystems, or several independent user-facing changes; "this is big", "break this into parts".

**Steps.** 1 overview interview, at most six questions: the problem, who, the appetite for the whole, the parts as the user sees them, what lands first, what is out · 2 research at overview depth: the subsystems each part touches and the shared decisions (vocabulary, data ownership, order of landing) · 3 write `README.md` from the overview template: parts table, each part a shippable user-facing increment, never a layer; part 1 is the walking skeleton · 4 one tech-lead pass on the ordering and the shared decisions · 5 run the Plan playbook per part under `parts/<slug>/`, sharing the root ledger · 6 the overview's Definition of Ready is the union of the parts'.

**Reply.** The overview path; the parts table with order and status; the shared decisions; which part is planned next.

### 5.13 Definition of Ready and Definition of Done

Both lists live in `references/templates.md` so every playbook reads the same text; a repo may override them. The Plan playbook prints the Definition of Ready with each box checked before hand-off; the Ship playbook prints the Definition of Done before the flip and again at close.

**Definition of Ready (a plan may be built when all hold):**
- Problem statement, audience, today's workaround, appetite, success signal, and kill criterion are written and confirmed at G1.
- Every must-story has WHEN/THEN acceptance including at least one failure or edge line, a surface with five states (UI) or a consumer and contract sample (non-UI), and a permissions line where roles exist.
- Non-goals and rabbit holes are written with reasons.
- Every current-state claim in `implementation.md` has a file:line anchor at the baseline SHA, and the closest existing feature is named.
- Simpler alternatives are listed with the story or constraint each fails; at Feature and Program size the approach was chosen from at least two candidates.
- The riskiest assumptions each have a test verdict or an accepted risk with a reason.
- Slices are vertical, ordered riskiest-first, sized S/M/L, each with stories, files, data, flag, named tests per acceptance line, live check, regression, rollback; a schema expand is its own first slice; P1 is the walking skeleton when a flag exists.
- The appetite check passed, or the cuts were made and recorded.
- Instrumentation events and the success-signal query are named; rollout (flag, cohorts, kill switch, flag-off behaviour) is written.
- Product-panel and tech-lead findings have no open "act on"; persona findings (when run) have no open "act on"; unverified assumptions have a spike verdict or an owner.
- Open questions each have a recommendation and an owner; ASSUMED decisions are listed.

**Definition of Done (a feature may be called shipped when all hold):**
- Every slice is merged; the ledger's implementation log matches the PRs.
- Every acceptance line maps to a passing test or a live check with evidence.
- `qa-report.md` verdict is ship; flag on and off both verified; permissions matrix verified per role; rollback rehearsed.
- Instrumentation events fire with their properties in the real environment.
- Reviewers-by-path satisfied; docs, changelog, or support note done when the plan called for them.
- The flag is on for the intended cohort; the watch window passed; the success signal and error rates were checked and recorded in the ledger.
- Flag removal is scheduled or done.
- Status is `Shipped` and `product-builder-reflect` was offered.

## 6. Playbooks and leaf skills: engineering track

Playbooks (investigation, bug fix, refactoring, perf issue, babysit, pickup and pause, opening a PR) are step lists the mode copies into the todo list; leaf skills (how, why, review, verify, resume, reflect, plain) are callable on their own. Every code playbook ends with Opening a PR.

### 6.1 `product-builder-how`

**Purpose.** Explain how a subsystem works well enough for a senior engineer to change it. Also the map engine behind `product-builder-research`.

**Frontmatter.** `name: product-builder-how` · description: "Explains how part of the system works: routes the question by complexity, spawns 2-4 parallel read-only explorers on distinct angles for a multi-file subsystem, then one explainer that synthesises Overview, Key concepts, How it works, Where things live, Gotchas, every claim with file:line at a named SHA. Use for 'how does X work', 'walk me through', 'map this area', or when product-builder-research needs a system map." · `argument-hint: [question] [--map]`

**Steps.** 1 baseline SHA · 2 route: single module → one explainer; cross-cutting → explorers first (angles as in §5.3) · 3 synthesise with the explainer prompt; flag stale docs · 4 `--map` mode returns the map block only, for research · 5 reply is the explanation; pointers, not dumps.

### 6.2 `product-builder-why`

**Purpose.** Evidence for why the system is the way it is.

**Frontmatter.** `name: product-builder-why` · description: "Finds evidence for why the system was built a certain way: git history and blame across renames, PR descriptions and review threads, issues, ADRs and design docs, and the profile's observability tools, queried in parallel. Returns a dated rationale with links and says plainly what has no recorded reason. Use for 'why is it like this', 'who decided', 'what was the reason', or before a refactor that would undo a past decision." · `argument-hint: [question]`

**Steps.** 1 identify the symbol, file, or behaviour · 2 parallel evidence lanes: `git log --follow` and blame, PR search and bodies, issues, ADR and design directories, the profile's logs or error tracker if the question is about runtime · 3 merge into a timeline: date, actor, artifact link, the stated reason; mark inferred reasons as inferred · 4 close with "no recorded reason" where that is the truth, and with the ADR it would take to record one if the decision meets the ADR bar.

### 6.3 Playbook: bug-fix (`playbooks/bug-fix.md`)

**You own this task. Reproduce, root-cause, fix with runtime evidence.** Every shipped line traces to evidence; a change that "might help" is a hypothesis and does not ship.

**Match.** "Fixes a bug from a reproduction: narrows to a failing test or a scripted repro, finds the root cause (never a guard that silences the symptom), states the premise and attacks it when two fixes have failed the same gate, applies the smallest fix, verifies on the matching surface with evidence, runs the review skill on the diff, and ends with Opening a PR. Use for a bug, a failing test, a stack trace, 'it's broken', or a flaky job."

**Steps, copied verbatim into the todo list.**
```
- [ ] Reproduce: the narrowest failing test or scripted repro, with its output
- [ ] Root cause: the mechanism at file:line, and why sibling callers do or do not share it
- [ ] Premise check: if two fixes already failed this gate, write the shared premise and attack it before a third
- [ ] Fix: smallest change at the root; regression test stays red-then-green
- [ ] Verify: matching surface with evidence (product-builder-verify); profile checks
- [ ] Review: product-builder-review --diff
- [ ] PR: Opening a PR, body names the mechanism and the evidence
```
Use the profile's debugging agent for the root cause when one exists. A fix that adds a nil check, a retry, or a try/catch without naming the mechanism is rejected by the playbook's own steps.

**Reply.** What was broken, the root cause at file:line, the fix, how it was verified. Paste the failing-then-passing repro output verbatim. The PR URL.

### 6.4 Playbook: refactoring (`playbooks/refactoring.md`)

**You own the shape. Behaviour does not change; every batch proves it.**

**Match.** "Behaviour-preserving structural change: characterises current behaviour with tests or captured outputs first, then expands (new shape beside the old), migrates callers in batches each verified green, and contracts (deletes the old form), with the review skill on the diff and one PR per batch when the sweep is wide. Runs the why skill first when the refactor would undo a recorded decision. Use for 'refactor', 'clean up', 'extract', 'rename across the codebase', 'consolidate'."

**Steps.** 1 scope and blast radius: every caller and alias, enumerated · 2 `product-builder-why` if a past decision is being undone · 3 characterise: existing tests or captured outputs that pin behaviour · 4 expand → migrate in batches sized to stay green, verify each → contract · 5 review, Opening a PR per batch or one PR for a small sweep. Subtract before you add; a refactor that grows net lines needs a sentence explaining why.

**Reply.** What moved and what stayed; the characterisation that pinned behaviour; each batch with its green check; net lines with the reason if positive; the PR URLs.

### 6.5 Playbook: perf-issue (`playbooks/perf-issue.md`)

**You own the number. Baseline first, one change at a time, interleaved measurement.**

**Match.** "Performance work against a baseline: names the metric and its unit, measures it on trunk first with a repeatable probe, traces where the time or memory goes, changes one thing, re-measures interleaved with the baseline, and reports before → after with the probe so a reviewer can rerun it. Refuses to claim a ratio between unlike scenarios. Use for 'slow', 'latency', 'memory', 'this takes too long', or a number to improve."

**Steps.** 1 metric, unit, probe (a command or script the reviewer can rerun) · 2 baseline on trunk, recorded first · 3 trace with the profile's tools · 4 hypothesis → one change · 5 interleaved re-measure · 6 rule with the number; if trunk lacks the feature, an absolute budget instead of a ratio · 7 review, Opening a PR with `before → after` and the probe path.

**Reply.** The metric and unit; baseline and after, interleaved; the probe a reviewer can rerun; what changed and why it helped; the PR URL.

### 6.6 `product-builder-review`

**Purpose.** Adversarial review of a diff, cast for the change, findings the developer rules on.

**Frontmatter.** `name: product-builder-review` · description: "Reviews a diff (branch, PR, or working tree) with 3-5 read-only reviewer subagents cast by what the diff touches (always a staff simplicity hawk, a QA engineer, and a product owner; database, security, frontend, SRE, integration, cost, accessibility, adversarial user by signal), each with the stated intent of the change. Merges findings into act on / consider / noted / dismissed with attribution and a confidence score, runs a verifier that re-checks every critical and high against the code, names the one fact a risky diff is safe because of and proves it by running real code, and when a slice contract is given returns two separate verdicts: spec compliance against the acceptance lines, and quality, plus deviations from the plan. Use for 'review this', 'tear this apart', 'find blind spots', or from the implement, bug-fix, refactoring, and perf-issue playbooks." · `argument-hint: [--diff base..head | --pr N] [--contract path]`

**Steps.** 1 scope and intent (task, PR body, commits, then the diff) · 2 cast three to five seats with reasons; the profile's reviewers-by-path are mandatory seats when their paths are touched; a silent-failure hunter sits whenever the diff touches error handling, retries, or async code · 3 dispatch in parallel, self-contained prompts, read-only; every finding carries confidence 0-100 and below 60 lands in noted · 4 verifier pass; for a diff that touches shared code, name the one fact it is safe because of and prove it with a script or test that runs the real code, or mark it unproven · 5 buckets, attribution, agreement map · 6 rulings with the developer · 7 with `--contract`: spec-compliance verdict (each acceptance line: covered by a test or live check, or not), quality verdict, both required, plus deviations from the plan for the Revise playbook. Never edits code. Existing repo review skills may be invoked as extra passes when the profile lists them.

### 6.7 `product-builder-verify`

**Purpose.** Prove a change works on the matching surface, with evidence.

**Frontmatter.** `name: product-builder-verify` · description: "Verifies a change on the surface that matches it, per .product-builder/drive.md: a UI change is clicked through in a real browser, a CLI change is run, an API change gets a real request and response, a migration is replayed on a scratch database, a job is triggered and its side effect read back, a flag is checked in both states. Returns evidence (screenshots, logs, response bodies, exit codes) and a pass / fail per scenario. Never accepts 'the build passed' as proof. Use for 'does this work', 'prove it', 'run it like a user would', or from any stage that just changed code." · `argument-hint: [scenario ...] [--target url]`

**Steps.** 1 read `drive.md`: launch, readiness, login, seed, selectors, flags, teardown; when an installed browser-testing skill provides a server-lifecycle helper and headless-browser conventions, use it instead of hand-rolling them · 2 pick the surface by what changed · 3 for each scenario: the click path or command, the observable result, the pass predicate · 4 drive it; capture evidence to the scratchpad · 5 regression lane on trunk when the scenario is load-bearing and trunk has the feature · 6 report per scenario with evidence paths; "inconclusive" is a fail and says why.

### 6.8 Playbook: opening-a-pr (`playbooks/opening-a-pr.md`)

**Invoked at the end of every playbook that changed code.**

**Match.** "Opens pull requests from the current work: rebases into small ordered commits, prefers five narrow PRs to one wide one, stacks dependent PRs as a base-branch chain, writes a conventional-commit title and a briefing body (Why, Scope, Tradeoffs, Blast radius, Verification with evidence and numbered steps a human can follow, screenshots or a recording for UI), links the plan folder and stories when one exists, opens ready not draft, and links the tracker task on request. Use for 'open a PR', 'split this into PRs', or at the end of any playbook that changed code."

**Body format.**
```
## Why            intent and approach, one or two short paragraphs
## Scope          real symbols and paths; both sides of a rename; in/out only when the boundary matters
## Tradeoffs      rejected alternatives a reviewer would otherwise ask about (omit when none)
## Blast radius   who or what this touches, why it is safe or risky, flag state, one to three sentences
## Verification   each real run path and its outcome; numbered "to see it yourself" steps; before/after
                  screenshots or a recording for UI; perf as before → after with a unit
Plan: docs/plans/<slug>/ · Stories: S1, S3 · Slice: P2        (when a plan exists)
```
Before the PR: plan completion when a plan exists (the slice's items marked done, changed, or deferred; files outside the slice's list named as scope drift and explained or split out); the changelog line composed from the diff without asking when the profile has one; docs synced through the profile's docs skill when user-facing behaviour changed; a fresh run of the profile's checks in the same reply. Refuses: pushing from the base branch, force-push, a PR with failing checks, a PR with an unresolved act-on finding, a credential in a body. No "Summary" or "Test plan" boilerplate, no SHA lists, no file-by-file essays. The first line of Why is a TL;DR that matches the actual diff. Mechanical and generated files are listed apart from logic. Commits are grouped in dependency order (schema, core logic, wiring, UI, tests); after any history rewrite the tree hash is compared with the original before pushing. Forge per profile; `gh` by default.

**Reply.** The PR URL as a full link; one line on what a reviewer should read first.

### 6.9 Playbook: babysit (`playbooks/babysit.md`)

**You own merge-ready, never the merge.** Declare the mode before polling: one pass, or watch until green.

**Match.** "Drives an open pull request to merge-ready: watches CI, reproduces and fixes failures at the root, triages review comments (bots and humans) into act / push back / clarify with a reason each, keeps the branch rebased, re-runs product-builder-verify after changes, and reports the queue state. Pushes back when feedback drifts from the PR's intent. Never merges. Use for 'get this merged', 'fix CI', 'handle the review comments', 'is this PR ready', 'check on PR X'."

**Steps.** 1 read the PR, checks, and comments · 2 for each failing check: root cause via the Bug fix playbook's discipline, never a retry-until-green · 3 comment triage table (comment, bucket, reason, action) · 4 rebase, push, re-verify · 5 report: checks, open comments, what changed since the last report · 6 stop at merge-ready; the merge is the user's.

**Reply.** Checks and their state; the comment triage table; what changed since the last report; merge-ready or what blocks it.

### 6.10 `product-builder-reflect`

**Purpose.** Improve the suite and the project layer from real runs.

**Frontmatter.** `name: product-builder-reflect` · description: "After a hard or surprising run, reviews the transcript and the plan folder for friction: questions the user had to answer twice, facts the profile lacked, personas that were missing, prompts that produced dumps instead of pointers, steps that were skipped, Definition of Ready items that were red at hand-off. Proposes concrete edits to .product-builder/ files and to the suite's skills, sorted into accepted / rejected / backlog, and applies only what the user approves. Use for 'what should we change about the workflow', 'that was painful, learn from it', or after a ship." · `argument-hint: [slug]`

Nothing changes without approval. Proposed suite edits are written as a patch the user can apply in the product-builder repo; proposed project edits are applied in place after approval. Approved learnings are appended to `.product-builder/learnings.md` (type: pattern, pitfall, preference, architecture, tool; confidence 1-10; the files it refers to; one-line note); the plan, research, pm, techlead, and review skills read that file first and say "prior learning applied" when an entry shaped a call.

### 6.11 `product-builder-resume`

**Purpose.** Rebuild where a feature or a piece of work stands, across sessions and agents, and hand back a capsule with the next move.

**Frontmatter.** `name: product-builder-resume` · description: "Rebuilds working context before starting or resuming: reads the plan folder and its ledger, the git state (branches, worktrees, uncommitted work), open PRs and their checks, and recent session notes, then hands back a capsule: what this is and where it stands, one line per thread with a status tag, the recurring problems, and the single next move. With --handoff writes a redacted hand-off note another agent or session can start from. Use for 'where was I', 'catch me up on <slug>', 'what's in flight', 'hand this off', or at the start of any session that continues earlier work." · `argument-hint: [slug | --all] [--handoff]`

**Steps.** 1 scope: a slug, or all plan folders with status between `Framed` and `Shipping` · 2 read `decisions.md` (implementation log, revision log, ASSUMED rows, open questions), the plan headers, and `qa-report.md` if present · 3 live state: `git branch --list '<slug>/*'`, worktrees, uncommitted files, `gh pr list --search <slug>` with check status · 4 verify the ledger against live state: a PR the ledger calls open that is merged, or a branch the ledger does not know, is a finding · 5 write the capsule; `--handoff` also writes `docs/plans/<slug>/handoff.md` with the capsule, the artifact paths, the skills to invoke next, and secrets redacted.

**Capsule contract.**
```
Capsule      at most 5 bullets: what this work is and where it stands
Threads      one line each, prefixed with exactly one tag: [merged #N] [open PR #N] [in flight <branch>] [verified, uncommitted] [reverted #N] [planned, not started]
Problems     at most 5, the recurring ones, with what was tried
Assumed      ASSUMED decisions still awaiting the user
Next move    the single most useful next action, concrete, with the skill to invoke
```

### 6.12 Playbook: investigation (`playbooks/investigation.md`)

**You own the answer. Route, read, write.** Read-only. The deliverable is a cited explanation or a recommendation, not a change.

**Match.** "How does X work", "why is it like this", "are we sure about Z", "should we do A or B".

**Steps.** 1 route through the how skill; for motivation questions also the why skill · 2 for "A or B", a recommendation with a trade-offs table and your real judgment · 3 the reply follows the how shape (Overview, Key concepts, How it works, Where things live, Gotchas), every claim with file:line or a label · 4 no PR, no change; if a change follows, hand back and match Bug fix or Plan.

**Reply.** The investigation output; for "are we sure" the judgment with reasons; push back if the premise is wrong.

### 6.13 Playbook: pickup-and-pause (`playbooks/pickup-and-pause.md`)

**You own continuity.** Pick up another session's in-flight work, or suspend your own so the next session can.

**Match.** "Pick up where the other session left off", a pushed branch or transcript to take over, "pause, I'm compacting", "I'm going offline".

**Steps.** Pickup: 1 the resume skill for the capsule · 2 verify the capsule against git, PRs, and the ledger · 3 claim the work in the ledger (implementation-log row with this session's id) · 4 continue in the matched playbook from the last completed step. Pause: 1 commit or stash-with-tag any uncommitted work and name it in the ledger · 2 write the capsule to `docs/plans/<slug>/handoff.md` via the resume skill's `--handoff` · 3 tick or skip-mark every open todo with its state · 4 stop with the capsule as the reply.

**Reply.** The capsule; what was claimed or released; the next move.

### 6.14 `product-builder-plain`

**Frontmatter.** `name: product-builder-plain` · description: "Restates the last reply in plain language, no jargon, shorter, as one person talking to another. Use for 'plain', 'say that simply', 'what does that mean'." · `disable-model-invocation: true`

Restate your last message. Drop the jargon, keep the facts and the numbers, one idea per sentence.

## 7. Repo layout, install, distribution

```
product-builder/                         the new repo
  .claude-plugin/plugin.json             name, description, version, author
  .claude-plugin/marketplace.json        so `/plugin marketplace add <owner>/product-builder` works
  skills/
    product-builder/                     SKILL.md (the mode)
      playbooks/                         plan.md, plan-interview.md, revise.md, implement.md, qa.md, ship.md, program.md,
                                         investigation.md, bug-fix.md, refactoring.md, perf-issue.md, babysit.md,
                                         pickup-and-pause.md, opening-a-pr.md
      references/                        principles.md, templates.md, interaction.md, writing.md, landscape.md
    product-builder-setup/  -how/  -why/  -research/  -prototype/  -personas/  -pm/  -techlead/
    product-builder-review/  -verify/  -resume/  -reflect/  -plain/
  profiles/
    default.md                           generic profile
    example-calcom.md                    worked example (calcom/cal.com)
  docs/guide/                            01-setup, 02-the-mode, 03-plan, 04-build, 05-verify-and-ship, 06-engineering-playbooks,
                                         07-overnight, 08-principles, 09-make-it-yours, 10-recipes-and-pitfalls
  evals/                                 scenario files, see §8
  CHANGELOG.md
```

Install into a project: `/plugin marketplace add <owner>/product-builder` then `/plugin install product-builder@product-builder`, or copy `skills/*` into `~/.claude/skills/`. First run in a repo: `/product-builder-setup`, which also asks the model budget and offers to validate `drive.md`. The guide under `docs/guide/` walks a new user through setup, the mode, one plan, one build, verification and shipping, the engineering playbooks, overnight runs, the principles, adapting the profile, and recipes. Verify the plugin manifest format against the current Claude Code plugin docs before the first publish; the skill frontmatter and `${CLAUDE_SKILL_DIR}` substitution are documented at https://code.claude.com/docs/en/skills.

Prerequisites: `grill-me` (Matt Pocock, MIT; `skills/productivity/grill-me` from github.com/mattpocock/skills into `~/.claude/skills/grill-me`), a browser driver that subagents can use (Playwright MCP, Claude in Chrome, or an equivalent skill), an authenticated forge CLI. Optional per project: `minimal-implementation`, review skills, journey-test tools, named in the profile.

## 8. Build plan, evals, dogfooding

Build in the order that gives an end-to-end path soonest, and dogfood each phase on a real feature before the next.

| Phase | Build | Exit criterion |
|---|---|---|
| 0 Skeleton | repo, manifest, README, the `product-builder` mode and `references/{principles,templates,interaction,writing,landscape}.md` (move the drafts as they are), `profiles/default.md` (write it), `profiles/example-calcom.md` (the worked example) | plugin installs; `/product-builder` matches a playbook, opens its steps in the todo list, and sizes a made-up request |
| 1 Setup + understand | `product-builder-setup` (with `models.md`), `-how`, `-why`, `-verify`, `-resume`, `-plain`, the investigation and pickup-and-pause playbooks | in a real repo: `.product-builder/` written with fewer than five `UNKNOWN`s; `drive.md` validated by a real launch and screenshot; `/product-builder-how` on one subsystem returns an explanation with file:line |
| 2 Plan core | the plan playbook (steps 0-4, 7) with `plan-interview.md`, `-research`, `-pm`, `-techlead` | a Bounded feature planned end to end: four files, at most five questions, tech-lead findings ruled and applied, Definition of Ready green |
| 3 Plan verification | `product-builder-prototype`, `-personas` | a Feature with a UX fork: prototype passes the readiness check, three or more personas with five-second answers and think-aloud logs, rulings in the ledger, one story rewritten from a persona finding |
| 4 Build and prove | `-review`, the opening-a-pr, implement, qa, ship, and babysit playbooks | the Phase 2 plan implemented as one PR per slice with evidence and human verification steps in each body; QA report with a verdict covering both flag states; ship pre-flight printed; post-ship watch recorded |
| 5 Edit and learn | the revise and program playbooks, `-reflect` | after "main moved" on the Phase 2 plan: delta research, a superseded decision row, a revision-log row, Definition of Ready re-checked; reflect proposes at least one profile edit |
| 6 Engineering track | the bug-fix, refactoring, and perf-issue playbooks | one real bug fixed root-first with a red-then-green test; one refactor landed in verified batches |
| 7 Portability | dogfood the whole suite on a second repo with a different stack using `profiles/default.md` | no skill needed editing; only `.product-builder/` differed; the §4.6 grep is clean |

Evals (write them before writing more documentation). Keep at least these in `evals/`, each a query, the files it starts from, and expected behaviours a reviewer can check:

1. `plan-bounded`: "plan: add a keyboard shortcut to archive a task" → four files, at most five questions, no prototype, tech-lead findings table, Definition of Ready green, both docs within caps.
2. `plan-feature-ux-fork`: "plan: a docked chat panel with tabs" → prototype passes readiness, at least three personas with five-second answers, rulings recorded, changed stories re-run, slices riskiest-first with P1 the flag skeleton.
3. `plan-non-ui`: "plan: a webhook that notifies on task completion" → contract sample with every failure line, consumer personas (integrator, on-call), no HTML prototype.
4. `plan-over-appetite`: a Feature whose slices sum past the appetite → cuts proposed at G4 before drafts are shown, recorded as decisions.
5. `revise-main-moved`: existing plan, 200 commits on main touching a cited file → delta research, refreshed anchors, superseded decision, revision log, Definition of Ready re-checked.
6. `implement-friction`: a slice that needs a file outside its list → stop at the budget rule, revise splits the slice, no silent patch.
7. `implement-parallel`: two independent slices with `--parallel 2` → two worktrees, two PRs, both reviewed with both verdicts, ledger rows written before dispatch.
8. `fix-root-cause`: a failing test with a tempting nil-check fix → mechanism named at file:line, regression test red then green, no guard-only fix.
9. `review-contract`: a diff that satisfies the acceptance lines but adds an unplanned abstraction → spec-compliance pass, quality finding on the abstraction, deviation flagged for revise.
10. `personas-paper`: no browser driver available to subagents → paper walkthrough, report says so, no fabricated clicks.
11. `ship-preflight`: a plan with a red Definition of Done item (no instrumentation event) → ship refuses the flip and routes back.
12. `plan-arena`: a Feature-size plan → two or three candidate approaches compared in a table, one recommended, the rest recorded as simpler alternatives.
13. `plan-assumptions`: a plan whose riskiest assumption has no evidence → a test is run (spike, persona, or one question) before the Definition of Ready turns green.
14. `pm-panel`: a product.md with a success signal but no baseline → the analyst seat flags it, the developer rules, the hypothesis is rewritten with baseline and guardrails.
15. `resume-capsule`: a new session and "where was I on <slug>" → a capsule with tagged threads, ledger-versus-git discrepancies named, and one next move.
16. `review-safety-fact`: a diff touching a shared helper → the one safety fact is named and proven by a script, or marked unproven.
17. `mode-todo-list`: `/product-builder plan X` → the plan playbook's steps appear verbatim in the todo list before any task todo; a skipped step stays as `skip: <reason>`; no reply asks two questions; no document is pasted in full.
18. `ask-classification`: the run reaches "chips or a date picker?" → no question is asked; a prototype settles it and the reply reports the result and the principle.
19. `reply-contract`: the final reply of any playbook → opens with who the work is for and what changes for them, names the principles that shaped the calls, carries evidence next to every claim, lists ASSUMED rows first, ends with the next move.
20. `zero-args-resume`: `/product-builder continue` typed on a branch named `<slug>/p2-…` → the slug and slice are inferred from the branch and the ledger, and the implement playbook resumes at the right step without a question.

## 9. Open decisions

Decided 2026-09-15: the product panel is its own skill, `product-builder-pm`, so it can run alone on a PRD that has no implementation plan yet. Decided 2026-09-15: the interaction model is the mode-plus-playbooks pattern (one command, playbook steps copied into the todo list, skip markers, per-playbook reply contracts, questions only for product calls, proceed-then-present on reversible work).

| Decision | Options | Recommendation |
|---|---|---|
| Short alias prefix | keep `product-builder-*` only, or add `pb-*` aliases | keep the long names; the mode is what people type; add aliases only if typing the leaf skills directly becomes common |
| Plan root | `docs/plans/<slug>/` everywhere, or per-profile | default `docs/plans/`, profile can override; never the house design-doc folder |
| Profile location | `.product-builder/` in the repo, or under `.claude/` | `.product-builder/`: visible, versioned, not mistaken for Claude config |
| Persona execution | sequential on a shared browser, parallel with one browser each, paper first then live | sequential live by default; paper first as a cheap pre-pass on large casts |
| Multi-model review panels | by role on available models, or by vendor | by role now; add vendor diversity only if other model access exists in the session |
| Principles | one file, or one skill per principle | one file now; split when a principle needs more than a paragraph or must be invoked alone |
| Implement cadence | stop after every PR, or continue across independent slices | continue across independent slices, stop at every merge; `--parallel` opt-in |
| Tickets | never, on request, always per slice | on request; the ledger is the source of truth |
| Post-ship watch window | fixed three days, or per plan | per plan in `product.md`, default three days |
| Distribution | plugin marketplace, or copy to personal skills | plugin; personal copy stays supported |

## 10. Sources

The research behind every choice, with what was taken from each and the URLs, is in `skills/product-builder/references/landscape.md`, including the fourth pass over gstack (office-hours, plan reviews, qa, ship).
