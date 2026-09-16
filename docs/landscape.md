# Landscape: how others do agent-driven planning

Research behind the shape of product-builder, gathered 2026-09-15. Read this when editing the suite, to see what each design choice was borrowed from and what was deliberately left out.

## Contents
- One-paragraph summaries
- Comparison table
- What product-builder took from each
- What product-builder deliberately does not do
- Sources

## One-paragraph summaries

**pstack (Lauren Tan / @poteto, Cursor plugin).** A router (`/poteto-mode`) matches the task to one of 23 playbooks (feature, bug fix, prototype, multi-phase plan, opening a PR, babysit, autonomous run, …), opens a todo list from the playbook, and calls leaf skills as steps require. Leaf skills: `/how` (parallel explorers map a subsystem), `/why` (evidence from git, issues, chat, monitoring), `/architect` (usage-first design sketch, arena of 2+ structurally distinct candidates, scrap the sketch when implementation friction proves it wrong), `/arena` (N parallel attempts, graft the best parts), `/interrogate` (several models review the same diff; findings merged into act on / consider / noted / dismissed with the dismissed kept visible), `/create-verification-skill` (generates a project-local skill that drives the app like a user), `/show-me-your-work` (TSV decision log), `/reflect` (improve skills after a hard task). Twenty-one one-page principle skills (`disable-model-invocation`) are routed through the mode: laziness protocol, subtract before you add, prove it works, never block on the human, experience first, exhaust the design space, sequence verifiable units, model the domain, guard the context window, and so on. The feature playbook: `how` → `architect` → delegate implementation with a named data shape → verify on the matching surface → small ordered commits → `interrogate` if contested → opening-a-pr. The prototype playbook: name the decision the prototype exists to make (no decision, no prototype), build throwaway in a scratch dir, variants behind one switcher, verify by screenshot, present alternatives and a recommendation, hand to Feature for the real build. The multi-phase plan playbook: settle open questions by prototype first, explore in subagents that return pointers not dumps, one section per PR, every box names its evidence, unit + live + perf verification per PR, hand back and stop until the operator says go. Opening-a-PR: conventional-commit titles, a briefing-style body (Why, Scope, Tradeoffs, Blast radius, Verification), prefer five narrow PRs to one large one, stacks as base-branch chains. Community ports for Claude Code: open-pstack, pstack-claude, cstack (46 skills), pstack-skills.

**Matt Pocock's skills.** `grill-me` (interview relentlessly, one question at a time, each with a recommended answer, explore the codebase before asking, walk the decision tree depth-first). `grilling` (the reusable primitive: work the frontier, questions whose prerequisites are settled, in rounds; research in a subagent while asking non-dependent questions; done when the frontier is empty). `grill-with-docs` (challenge terms against CONTEXT.md and ADRs, update them inline, ADR only when hard to reverse + surprising + real trade-off). `to-spec` (synthesise the conversation into Problem, Solution, User stories, Implementation decisions, Testing decisions, Out of scope; confirm the testing seam with the user). `to-tickets` (vertical tracer-bullet slices through every layer, blocking edges declared, sized to one context window, iterate granularity with the user). `prototype` (throwaway HTML to answer a design question: logic validation with free-play buttons and guided walkthroughs, or UI exploration with radically different variants behind a switcher; commit to a throwaway branch, keep only the decision). `implement` (TDD at pre-agreed seams, code-review, commit). `wayfinder` (a shared decision map for work too big for one session; one ticket per decision; sessions work the frontier). `to-questionnaire` (turn an interview the user cannot answer into an async Markdown questionnaire, most important first, answer stubs under each question). `handoff`, `wait-what`, `writing-for-agents`.

**superpowers (Jesse Vincent).** `brainstorming`: explore context first, classify the ask as spike / bounded / architectural ("when in doubt take the heavier path"), one question per message, prefer multiple choice, propose 2-3 approaches with trade-offs leading with the recommendation, apply YAGNI, present the design in sections and ask after each whether it looks right, a hard approval gate before any implementation, write the design to `docs/superpowers/specs/…-design.md`, self-review for placeholders and contradictions, then hand to `writing-plans`. `writing-plans`: plans assume an engineer with zero context, 2-5 minute atomic steps, real code not "TBD", self-review for spec coverage. `executing-plans`: load, critically assess, raise concerns first, execute with verification, stop on blockers. `subagent-driven-development`: fresh implementer per task with a one-line context, the brief, and earlier interfaces; separate spec-compliance and code-quality review; a ledger that survives compaction; fix loop of up to five rounds with escalation; every adjudication recorded, "a silent discard is forbidden"; stop only for irreversible, security-sensitive, out-of-worktree actions or a plan so broken every path is a guess.

**GitHub Spec Kit.** `/specify` → `/clarify` → `/plan` → `/tasks` → `/analyze` → `/implement`, with a project constitution of immutable principles. Ambiguity is marked inline as `[NEEDS CLARIFICATION: question]` rather than assumed. Tasks marked `[P]` can run in parallel. Revision is cascade regeneration: change the spec, regenerate the dependent plan and tasks.

**OpenSpec.** Every change is a proposal folder: `proposal.md`, `design.md`, `tasks.md`, and spec deltas written as ADDED / MODIFIED / REMOVED requirements with WHEN/THEN scenarios. Modifying an existing feature is a new change proposal, never a direct edit. `archive` merges the deltas into the canonical specs and keeps the change as history.

**BMAD.** Sizes the process to four tracks (trivial, one-session, epic-sized, project-sized). Artifacts by phase: brief and research → PRD, UX doc, spec → architecture, epics with ordered stories. Brownfield work documents the existing codebase first. Course correction: update the spec and re-run story breakdown when earlier work reveals a missing constraint.

**Kiro.** Three files per feature: `requirements.md` (user stories with EARS acceptance criteria: WHEN <trigger> THE SYSTEM SHALL <response>), `design.md`, `tasks.md` (checkbox list). Iterates between phases; specs are updated when code changes.

**Shape Up (Basecamp).** A pitch has five ingredients: problem (a concrete story), appetite (how much time, which constrains the solution), solution (elements at fat-marker level, not wireframes), rabbit holes (details called out to avoid problems), no-gos (explicitly excluded). Breadboarding and fat-marker sketches keep the design under-specified on purpose.

**Persona testing research (UXAgent, PerceptUI).** LLM agents with generated personas drive a real browser through a perceive → plan → act loop plus a slower wonder/reflect loop, produce action traces and memory traces, and can be interviewed afterwards for qualitative feedback. Findings: chat interviews with the agent are the most valued output; agents over-deliberate compared with humans; stereotype and decision biases exist; persona-aware variants match human response distributions better; treat the output as a pilot session, supplementary to real users, never a replacement.

**Anthropic skill guidance.** Descriptions in third person, what plus when. SKILL.md under 500 lines; progressive disclosure through reference files one level deep, each with a table of contents when long. Checklists the model copies into its reply; validator-then-fix feedback loops; templates with a strictness matched to the need; a default with an escape hatch instead of many options. Build evaluations before extensive documentation. Claude Code frontmatter: `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `context: fork` + `agent`, `${CLAUDE_SKILL_DIR}` substitution; skills stay in context once invoked, so write standing instructions.

**Prior art in the author's own repo.** A grill-with-docs skill, a minimal-implementation skill, a complexity review, and a multi-agent review skill (personas cast for the change; waves; a verifier agent that kills false positives), plus repo agents for codebase navigation, external research, spec writing, architecture, product design, and verification. The author's own hand-written plans share conventions the suite keeps: a status line, a baseline SHA, a locked-decisions table, a "corrections this pass, do not re-introduce" list, and a clickable prototype where "every catalog row is a jump; if a row cannot be clicked the plan is not done".

## Comparison table

| | Interview | Research of the codebase | Prior art | Doc shape | User gates | Verification of the plan | Revision | PR slicing |
|---|---|---|---|---|---|---|---|---|
| pstack | none formal; `never-block-on-the-human` | `/how` parallel explorers | `/why` evidence from tools | usage sketch + rationale; multi-phase plan checklist | irreversible actions only; plan hand-back | `/interrogate` multi-model; live verification lanes | scrap the sketch on friction; `/reflect` | one PR per section, stacks, five narrow over one wide |
| grill-me / grilling | one at a time, recommended answer, frontier rounds | explore before asking | no | locked-decisions summary | every question | no | re-grill new branches only | no |
| to-spec / to-tickets | none (synthesises the chat) | yes, seams | no | Problem / Solution / User stories / Decisions / Testing / Out of scope | confirm the testing seam; ticket granularity | no | edit spec | tracer-bullet vertical slices with blocking edges |
| superpowers brainstorming | one question per message, multiple choice | explore context first | no | design doc in sections | after every section; hard approval gate | self-review for placeholders | re-run the section | writing-plans tasks |
| Spec Kit | `/clarify` with `[NEEDS CLARIFICATION]` | plan phase | no | spec / plan / tasks | per command | `/analyze` for contradictions | cascade regeneration | `[P]` parallel tasks |
| OpenSpec | proposal review | design.md | no | proposal + spec deltas + tasks | approve proposal before build | no | new change proposal, archive merges | tasks.md |
| BMAD | analyst / PM agents | brownfield: document first | analyst research | brief → PRD → architecture → stories | per artifact | QA agent | course-correct, re-run breakdown | epics → stories |
| Shape Up | shaping (humans) | rough | no | pitch: problem, appetite, solution, rabbit holes, no-gos | betting table | no | rescope within appetite | scopes |
| UXAgent | none | none | none | traces + interview | none | persona agents drive a browser | none | none |

## What product-builder took from each

- The router, the sizing table, principle-style rules, the four review buckets with dismissed kept visible, "no decision, no prototype", "explore in subagents that return pointers not dumps", "verify on the matching surface", the PR body shape, five narrow PRs over one wide one: **pstack**.
- Interview discipline (one at a time, recommended answer with a reason, explore before asking, frontier, stop when the frontier is empty, ASSUMED defaults when the user is away): **grill-me / grilling / to-questionnaire**.
- Problem, appetite, solution at fat-marker level, rabbit holes, non-goals: **Shape Up**.
- User stories with WHEN/THEN acceptance criteria, stories discussed with the user, spec ↔ tasks coverage: **to-spec, Kiro, OpenSpec**.
- Spike / bounded / feature / program sizing, heavier when in doubt, upgrade mid-way: **superpowers brainstorming, BMAD**.
- Tracer-bullet vertical slices with blocking edges: **to-tickets**.
- Throwaway prototype with variants behind a switcher and a catalog where every case is clickable: **Pocock prototype, pstack prototype playbook, the author's own docs**.
- Persona subagents that drive the real prototype, think aloud, and are interviewed afterwards; the caveat that they are a pilot session, not users: **UXAgent / PerceptUI**.
- Tech-lead panel cast for the change, a verifier that kills false positives, findings with file:line: **review-multi-agent, /interrogate**.
- Ledger that survives compaction, every adjudication recorded, spec-compliance and quality as separate verdicts, fix loop with escalation: **superpowers subagent-driven-development**.
- Supersede rather than rewrite, change proposals for edits, top-of-doc post-implementation updates: **ADRs, OpenSpec, system-architect house rules**.
- Baseline SHA in every header, file:line on every current-state claim: **engineering design-doc practice, the author's own plans**.

## What product-builder deliberately does not do

- No multi-model panels (pstack's `/interrogate` across vendors). The panel is cast by role, on the models available in the session.
- No 2-5 minute atomic task plans with inline code (superpowers `writing-plans`). Plans stay rough; the slice contract plus `minimal-implementation` at build time replace it.
- No tracker-first decision maps (`wayfinder`). The ledger lives in the plan folder; tickets are optional.
- No spec-delta syntax (OpenSpec). Stories are edited in place and the change is logged; the ledger, not a delta file, is the audit trail.
- No autonomous overnight programs (pstack autopilot). `product-builder-implement` stops at every merge.

## Sources

- pstack upstream: https://github.com/cursor/plugins/tree/main/pstack (skills, playbooks, principles read 2026-09-15)
- pstack deep dive: https://flaviocopes.com/pstack/
- Ports: https://github.com/ericlitman/open-pstack · https://github.com/michael-denyer/pstack-claude · https://github.com/irg1008/cstack · https://github.com/IgorKhramtsov/pstack-skills
- Matt Pocock skills: https://github.com/mattpocock/skills (grill-me, grilling, grill-with-docs, to-spec, to-tickets, prototype, implement, wayfinder, to-questionnaire)
- superpowers: https://github.com/obra/superpowers (brainstorming, writing-plans, executing-plans, subagent-driven-development)
- GitHub Spec Kit: https://github.com/github/spec-kit/blob/main/spec-driven.md
- OpenSpec: https://github.com/Fission-AI/OpenSpec
- BMAD: https://docs.bmad-method.org/plan/choose-a-planning-path/
- Kiro specs: https://kiro.dev/docs/specs/
- Shape Up, write the pitch: https://basecamp.com/shapeup/1.5-chapter-06
- UXAgent: https://arxiv.org/abs/2502.12561 and https://arxiv.org/pdf/2504.09407 · PerceptUI: https://arxiv.org/abs/2606.05697
- Anthropic skill authoring best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Claude Code skills reference: https://code.claude.com/docs/en/skills

## Second pass (2026-09-15): gap analysis against the best available skills

A second sweep after the suite was renamed product-builder, asking which capability each source does best and whether product-builder covers it.

| Capability | Best source | Status before this pass | What was added |
|---|---|---|---|
| Clarifying questions before design, never skipped | Anthropic feature-dev plugin (phase 3), grill-me | covered by Interview 1 and 2 | backward compatibility and integration points added to the technical forks |
| Competing approaches before choosing | feature-dev phase 4 (2-3 code-architect agents: minimal, clean, pragmatic), pstack architect arena, superpowers brainstorming | one approach plus an after-the-fact alternatives table | the approach arena at Feature and Program size; Definition of Ready requires two or more candidates |
| Assumption mapping and riskiest-assumption tests | Teresa Torres assumption testing, David Bland assumptions mapping | techlead flagged unverified assumptions | an Assumptions table (type, importance, evidence, test, verdict) in product.md; tests before the Definition of Ready |
| Product-side review of the plan | aakashg PM setup (engineer, designer, executive, skeptic, customer, data analyst reviewers) | none; techlead is engineering only | `product-builder-pm`: PM, skeptic, designer, data analyst, customer seats over product.md |
| Success metric with baseline, target, guardrails | PM PRD conventions | success signal as prose | hypothesis format with baseline, target, guardrails, kill criterion |
| Tracking plan before code | Amplitude data planning playbook, "tracking plan before code" | instrumentation table | trigger and owner columns, naming convention from the profile, outcomes not surfaces, analyst seat checks it |
| Evidence before completion claims | superpowers verification-before-completion | principle 14 | the gate function (name the command, run it fresh, show the output; forbidden phrases) in principles, conventions, implement, verify |
| End of branch menu and worktree hygiene | superpowers finishing-a-development-branch | implement stopped at merge | PR / keep / discard menu, typed `discard`, suite-created worktrees removed after merge |
| Resume across sessions and hand-off | pstack recall, Pocock handoff | the ledger only | `product-builder-resume` with the capsule contract and `--handoff` |
| One safety fact proven by running code | pstack blast-radius | change-site checks in review | review names the safety fact for shared-code diffs and proves it with a script or marks it unproven |
| Confidence-scored findings | Anthropic code-review and pr-review-toolkit plugins | severity only | confidence 0-100 on every finding; below 60 is noted, never act on; silent-failure hunter seat |
| Progressive rollout and flag removal | feature-flag practice | flag, cohort, kill switch | rollout stages (internal, cohort, percentage, all) and scheduled flag removal in ship and the Definition of Done |
| PR reviewability | pstack make-pr-easy-to-review, opening-a-pr | briefing body | TL;DR matches the diff, mechanical files listed apart, commits in dependency order, tree hash check after rewrites |
| Writing quality for docs and copy | pstack unslop | none | `references/writing.md` for plan docs, PR bodies, UI copy |
| Browser driving conventions | Anthropic webapp-testing skill | drive.md | named as an optional helper for verify and personas when installed |

Additional sources for this pass:
- Anthropic feature-dev plugin: https://github.com/anthropics/claude-code/tree/main/plugins/feature-dev
- Anthropic plugins directory (code-review, pr-review-toolkit): https://github.com/anthropics/claude-code/tree/main/plugins
- Anthropic webapp-testing skill: https://github.com/anthropics/skills/tree/main/skills/webapp-testing
- superpowers verification-before-completion and finishing-a-development-branch: https://github.com/obra/superpowers
- pstack recall, blast-radius, show-me-your-work, figure-it-out, unslop: https://github.com/cursor/plugins/tree/main/pstack/skills · make-pr-easy-to-review (port): https://github.com/michael-denyer/pstack-claude
- Assumption testing: https://www.producttalk.org/assumption-testing/ · Assumptions mapping (David Bland): https://www.strategyzer.com/library/how-assumptions-mapping-can-focus-your-teams-on-running-experiments-that-matter
- Amplitude data planning playbook: https://amplitude.com/docs/data/data-planning-playbook
- PM Claude Code setup (aakashg): https://github.com/aakashg/pm-claude-code-setup

## Third pass (2026-09-15): interaction model

The user asked for the interaction model of pstack's `/poteto-mode`, copied roughly. What was copied: one mode command; the matched playbook's steps copied verbatim into the todo list with `skip: <reason>` for skipped steps; leaf skills the steps call; a per-playbook reply contract; principles named in the reply with the choice they changed; questions reserved for product or preference calls, with observable questions settled by a prototype or spike instead; proceed-then-present on reversible work; always pause on irreversible actions; session overrides; "no is an acceptable answer"; subagent defaults (read-only, pointers not payloads, per-role models from a setup skill); the reply style (short declarative sentences, no long dashes, no mid-sentence colons, impact for the consumer and the maintainer first, every claim with its evidence or its label, never hand the human a check you could run); a plain-language restatement skill; a per-role model setup with a budget question; and a docs/guide walkthrough. Not copied: Cursor-only frontmatter (`mode`, `reminder`), multi-vendor model panels, and the overnight autopilot playbooks.

## Fourth pass (2026-09-16): gstack

gstack (Garry Tan, github.com/garrytan/gstack) runs Think → Plan → Build → Review → Test → Ship → Reflect with role-named skills. Folded into product-builder: office-hours' forcing questions (who has this problem and how do you know; the status quo; one named customer and their exact pain; the narrowest wedge; the observation others missed) and its premise check, so G1 presents three to five premises the user agrees with or corrects; plan-ceo-review's scope modes (hold, reduce to the wedge, selective expansion, expansion), "existing leverage before rebuilding", "decisions needed now, not during implementation", and "everything deferred gets written down" (a Deferred section in the ledger); plan-eng-review's prime directives (zero silent failures, every error has a name, shadow paths for nil, empty, and upstream error, interaction edge cases such as double-click and navigate-away, observability as scope, diagrams mandatory for non-trivial flows, boring by default, reversibility) into the tech-lead prompt, and its test plan feeding QA; qa's diff-aware mode, health score, one commit per fix with a regression test that reproduces the precondition, before/after evidence pairs, and a stop rule when fix risk grows; ship's plan-completion and scope-drift check, auto-composed changelog, docs sync before the PR, fresh-evidence gate, review freshness by head SHA, and the refuses list; canary checks after each rollout stage; /learn's learnings file that later runs consult ("prior learning applied"); the question card with a decision id and per-option pros and cons. Not copied: home-directory state (product-builder keeps state in the repo so it ships with the code), 0-10 design scoring, version bumping, founder signals, the browser product, and cross-vendor second opinions.
Sources: https://github.com/garrytan/gstack (office-hours, plan-ceo-review, plan-eng-review, qa, ship, docs/skills.md; read 2026-09-16).
