# product-builder profile: <project>

Written by `product-builder-setup`. Every section is optional; a playbook that needs a missing section says so and continues. `UNKNOWN` means detection could not settle it; the first playbook that needs the value reads the repo, fills it in, and notes where it was read.

## Baseline
`git fetch origin --prune && git rev-list --left-right --count HEAD...origin/<default-branch>`. If the branch has no unique commits and `git status --porcelain --untracked-files=no` is empty, `git reset --hard origin/<default-branch>`; otherwise rebase. Record the SHA and the behind-count in every plan header.

## Stack and commands
Language and package manager: UNKNOWN. Run from `<dir>`:
- check: UNKNOWN
- tests for changed files: UNKNOWN · full unit suite: UNKNOWN · integration: UNKNOWN
- dev: UNKNOWN (port UNKNOWN)
- db: UNKNOWN
- what runs only in CI: UNKNOWN

## Where docs live
- plan root: `docs/plans/<slug>/`
- design docs: UNKNOWN · ADRs: UNKNOWN (numbering rule: UNKNOWN)
- glossary: UNKNOWN

## Domain language and law
UNKNOWN. List the nouns the product uses, the roles, and any document that is law (ADRs, a glossary).

## Agents by phase
No repo agents detected. Playbooks use the built-in Explore agent for maps and general-purpose subagents with a read-only instruction for review seats.

## Skills by phase
None detected. Mark each as `light` (returns instructions) or `heavy` (runs its own pipeline) when adding one.

## Browser drivers
Main session: UNKNOWN. Subagents: assume none (paper mode) until a run proves otherwise.

## Design tokens and UX invariants
UNKNOWN. Palette, font, radius, and the rules a prototype must not break.

## Architecture canon
UNKNOWN. Layering, mutation rules, invariants, the cost of a "simple field".

## Deploy reality
UNKNOWN. Rolling deploys, expand/contract, preview environments, merge queue.

## Feature flags
Mechanism: UNKNOWN. Rollout stages: internal → cohort → percentage → all. Kill switch: UNKNOWN. Who may flip in production: UNKNOWN. Flag removal: a follow-up PR after the watch window.

## Analytics and instrumentation
Helper: UNKNOWN. Naming convention: object plus past-tense verb, snake_case, unless the repo already uses another.

## Required reviewers by path
None. Add `path glob → agent` rows as reviewer agents are added.

## Tracker
None. Tickets only when the user asks.

## Observability
UNKNOWN. Where logs, traces, and error tracking live and how to query them.

## Judge
Model: none. `typesafe/jev-latest` when `TYPESAFE_API_KEY` is in the environment; `none` means every judge gate is judged by the session model and the first reply of a run says so.
Mode: shadow. `shadow` logs each verdict to `.product-builder/judge-log.jsonl` beside the session's own call and changes nothing; `gate` lets the verdict route (the question-gate hook blocks a deflected question, findings take the judge's bucket, an uncovered acceptance line stays uncovered). Gates, questions, and thresholds: the suite's `references/judge-questions.json`. Switch to `gate` when `product-builder-reflect` reports the agreement rate supports it.
