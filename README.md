# product-builder

A working mode for product engineers in Claude Code. One command takes a feature from the first conversation to the post-ship check, and the same mode covers the rest of the week: understanding a subsystem, fixing a bug, refactoring, chasing a slow path, reviewing a diff, opening a PR, getting it merged.

```
/product-builder <what you want, in plain words>
```

The mode reads your repo's profile, sizes the work, matches a playbook, and copies the playbook's steps into the todo list. Steps call leaf skills. You are asked one question at a time, only for product calls, always with a recommended answer you can accept with "ok". Anything observable is prototyped or spiked instead of asked. Reversible work is done and shown; merges, pushes and flag flips wait for you.

## Install

```
/plugin marketplace add marcusjhang/product-builder
/plugin install product-builder@product-builder
```

Or copy `skills/*` into `~/.claude/skills/`.

First run in a repo:

```
/product-builder-setup
```

It reads the repo before it asks you anything, then writes `.product-builder/profile.md`, `personas.md`, `drive.md`, and `models.md`. Every skill reads those instead of guessing. `profiles/default.md` is the shape; `profiles/example-sveltekit-monorepo.md` is a worked example.

Prerequisite: the `grill-me` skill (Matt Pocock, MIT) at `~/.claude/skills/grill-me` for the interview discipline; the rules are also inlined in `skills/product-builder/playbooks/plan-interview.md`. A browser driver that subagents can reach (Playwright MCP, Claude in Chrome) makes persona click-throughs and live verification real; without one they run in paper mode and say so.

Optional: a judge. With `TYPESAFE_API_KEY` in the environment, setup writes a `Judge` section to the profile and six gates get a second opinion from a decision model (TypeSafe's Jev): every question to you is classified before it opens (observable by running, answerable from the repo, or a product call), file:line claims are checked against their excerpts, acceptance lines against the tests that claim them, panel and review findings are bucketed with a calibrated confidence, and PR comments are triaged. It starts in `shadow` mode, which logs verdicts beside the session's own and changes nothing; `product-builder-reflect` reports the agreement rate and proposes `gate`. The questions and thresholds are one file, `skills/product-builder/references/judge-questions.json`, meant to be read and edited. Without a key every gate is judged by the session model and the first reply says so. The question gate is a `PreToolUse` hook on the question tool; the plugin registers it from `hooks/hooks.json`, and a copy-install adds that entry to `.claude/settings.json` by hand.

## Playbooks

Product track:

| Playbook | What it does |
|---|---|
| plan | interview → research → decisions, user stories, assumptions → approach arena, drafts, appetite check → prototype if a decision needs one → personas, product panel, tech lead → Definition of Ready |
| revise | classify the trigger, re-run only the affected steps, supersede decisions, ledger it |
| implement | one PR per slice, tests from acceptance lines, verified on the surface, reviewed, PR body shown before anything opens, stop at merge |
| qa | acceptance per story on the real app, both flag states, every role, exploratory pass, report with a verdict |
| ship | Definition of Done pre-flight, rollout stages prepared for you to flip, canary, post-ship watch of the success signal |
| program | overview plus parts, each a shippable increment, plan per part |

Engineering track:

| Playbook | What it does |
|---|---|
| investigation | how does X work, why is it like this, A or B; read-only, every claim with file:line |
| bug-fix | reproduce → root cause → failing test → smallest fix → verify → review → PR |
| refactoring | characterise → expand → migrate callers in verified batches → contract → PR |
| perf-issue | baseline → trace → one change → interleaved re-measure → PR |
| babysit | CI and review comments to merge-ready; never merges |
| pickup-and-pause | resume another session's work, or suspend cleanly |
| opening-a-pr | sized, stacked, briefing body with evidence; runs at the end of every code playbook |

## Leaf skills

`product-builder-setup` · `-how` · `-why` · `-research` · `-prototype` · `-personas` · `-pm` · `-techlead` · `-review` · `-verify` · `-resume` · `-reflect` · `-plain`. Each is callable on its own (`/product-builder-how how does the queue claim a job`).

## Judge gates

| Gate | Runs in | State it judges | Verdicts |
|---|---|---|---|
| question-gate | the hook, before the question tool opens | the question and its options | ask · deflect (observable, from the repo) · fix (add a default, split) |
| anchor | how, research | a claim, its file:line, ten lines of the code at the SHA | holds · unclear · refuted |
| spec-line | review `--contract`, implement | an acceptance line and the test that claims it | covered · uncovered (does not exercise it, no literal assertion, subject mocked) |
| finding, finding-pair | pm, techlead, review, personas | a finding and the section or hunk it names; two findings | act on · consider · noted · dismissed; same · different |
| pr-comment | babysit | a comment, its hunk, the PR intent | act · push back · clarify · dismissed (noise) |

`skills/product-builder/scripts/judge --gates` prints the state shapes; `--self-test` runs the threshold rules on canned answers; `--dry-run` prints a request without sending it.

## What a run leaves behind

```
docs/plans/<slug>/
  product.md         problem, who, appetite, solution with surfaces and states, stories, non-goals, assumptions, instrumentation, rollout, success signal
  implementation.md  current → target diagram, approach and the candidates it beat, changes table, test strategy, riskiest-first slices with tests and rollback
  research.md        current system at a SHA, closest existing feature, prior art, spikes
  decisions.md       the ledger: decisions, ASSUMED, rejected, deferred, rulings, revision log, implementation log, next move
  qa-report.md       verdict, health score, bugs
```

## Principles

Seventeen, in `skills/product-builder/references/principles.md`. The ones that shape a run most: explore before you ask; one question with a default; product calls are the user's and execution calls are the agent's; the simplest change that could work; every current-state claim carries file:line at a SHA; decide by prototype when the question is feel; verify with the audience, not the author; prove it works on the matching surface.

## Docs

`docs/PLAN.md` is the design plan with every playbook and skill specified. `docs/landscape.md` records what was studied to shape it (pstack, Matt Pocock's skills, superpowers, Spec Kit, OpenSpec, BMAD, Kiro, Shape Up, UXAgent, gstack, Anthropic's guidance) and what was taken from each. `docs/stress-test.md` is the record of six scenario runs against a real repo with simulated users, the scores, and the fixes they produced.

## License

MIT.
