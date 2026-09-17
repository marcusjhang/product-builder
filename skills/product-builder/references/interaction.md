# Interaction model

How a session with product-builder feels, with examples. The examples use an invented feature ("snooze-action") and invented numbers; never carry their figures, names, or framing into a real run. The rules themselves live in the mode skill (`SKILL.md`: Non-negotiables, Autonomy, Subagents, Writing the reply, Playbooks). This file shows them in use.

## Contents
- The shape of a session
- The todo list is the progress UI
- Asking, and not asking
- Presenting instead of asking
- The reply contract
- Findings and rulings
- Digests, never documents
- Fallbacks
- Turn budgets
- Examples

## The shape of a session

1. The user types `/product-builder <what they want>` in plain words.
2. The mode reads the profile, matches a playbook, and opens the todo list with the playbook's steps copied verbatim. Its first reply says which playbook, why, the size and its budgets, and starts the first step in the same turn.
3. Steps run. Reversible work proceeds and is presented. Product calls are asked one at a time with a default. Observable questions are settled by a prototype or a spike instead of a question.
4. Each step that finishes is ticked. A step that is skipped stays in the list as `skip: <reason>`. The list is rewritten at every gate close and playbook switch; it never goes stale while work moves.
5. The playbook ends with its reply contract: impact for the consumer and the maintainer first, what was chosen and why, the evidence, the open decisions, the ASSUMED list when the user was away, and the next move.

The mode stays on for the session. Follow-ups are matched to a playbook again. "Stop using product-builder" turns it off.

## The todo list is the progress UI

There is no custom progress line. The todo list carries the playbook steps and the task-specific todos under them; the user sees what is done, what is running, and what was skipped. Long steps (research fan-out, persona runs) get a sub-todo per subagent so the wait is visible.

```
[x] 0 Intake: baseline, size, budgets, folder
[x] 1 Interview 1 (frame) → G1
[~] 2 Research: system, closest feature, prior art, spikes → G2
    [x] explorer: surfaces        [x] explorer: data model
    [~] explorer: jobs and events [~] prior art (3 of 5)
[ ] 3 Interview 2 (decide) + user stories + assumptions → G3
[ ] 4 Approach arena, draft, appetite check → G4
[ ] 5 Prototype (only if a decision needs one) → G5   skip: no UX fork found in interview 2
[ ] 6 Verify: personas, pm, techlead → rulings → G6
[ ] 7 Definition of Ready → G7
```

## Asking, and not asking

Before any question, classify it. Three kinds:

| Kind | Example | What happens |
|---|---|---|
| Fact the repo answers | "do we already have a snooze column?" | read it, say what was found, no question |
| Fact an experiment answers | "does the sweeper run often enough?", "chips or a picker?" | spike or prototype, let the result decide, report it |
| Product or preference call | "can a member snooze another member's action?" | ask, one question, with a recommendation and its reason |

A question looks like this and nothing else:

```
Can a member snooze an action that is not theirs?
Recommended: no. Snooze is the owner's deferral; letting others snooze it hides work from the person who owes it. Reply "ok" or say what to change.
```

Enumerable answers (two to four options) use the question tool with the recommended option first and marked `(Recommended)`; each option carries one line of what it buys and one of what it costs, and the question names the decision (`D3 · who may snooze`) so the ledger row and the question match. "skip" or "you decide" takes the recommendation and records it as ASSUMED. Never two questions in one reply. The story set is the one list the user edits in a batch, and rulings are the one multi-select.

## Presenting instead of asking

Reversible work is done and shown, not proposed. A draft is written and its digest shown with "say what to change"; the playbook continues on the next turn unless the user objects. Gates G1 (framing, presented as the premises the plan rests on, agree or name the one to change) and G3 (stories) wait, because they are product calls. G4 (drafts), G5 (prototype direction), and G6 (rulings on doc edits) present and continue. G7 (go), G8 (merge), and G9 (flag flip) wait, because what follows is costly or irreversible.

## The reply contract

Every reply is written to the mode's Writing the reply rules. A playbook's final reply always contains, in this order: who this is for and what changes for them; what the maintainer inherits; what was chosen and why, with the principles that shaped it named; the evidence (paths, commands and their output, screenshots, numbers with units); open decisions and ASSUMED rows; the next move with the playbook or skill that runs it. Tables for alternatives and findings. A PR as its full URL.

## Findings and rulings

One block, at most eight lines, grouped by bucket, one finding per line with source, confidence, and the proposed edit. The rest is counted. Doc and prototype edits that follow from act-on findings are applied and listed (reversible); anything that cuts scope or changes a product call is asked.

```
Findings · personas 3 · pm 5 seats · techlead 3 seats
act on    techlead 90  realtime payload lacks snoozed_until; the dot flickers back      applied → P1 files
act on    persona 3/3  "Tomorrow" needs the time in the chip                            applied → S1 copy
consider  pm:analyst   success signal has no baseline                                   applied → read from dismiss data
consider  pm:skeptic   why not dismiss with a reminder                                  your call: accept the risk?
noted 4 · dismissed 2, reasons in decisions.md
```

## Digests, never documents

A written or changed file is shown once as its path and a digest of at most ten lines. "Show full product.md" prints it.

```
Wrote docs/plans/snooze-action/product.md (2 pages)
Problem      the Friday review_pr story; workaround is dismiss-and-forget
Stories      S1 snooze from card (must), S2 unsnooze on time (must), S3 snoozed filter (should), S4 cancel (later)
Assumptions  A1 defer beats dismiss (test: personas), A2 sweeper cadence (holds, cron every 10 min)
Flag         actions_snooze, default off; flag off keeps today's board
Signal       hypothesis, baseline 22% from dismiss data, target 60%, guardrail dismiss rate
Open         who may snooze an unassigned action (recommend: the creator)
```

## Interim turns

When subagents are running and the turn must end before they return, the reply is one line naming what is running and that no answer is needed; it is not a gate and asks nothing.

## Fallbacks

A missing driver, an absent profile section, or a failing tool names its fallback in one sentence and the run continues. It becomes a question only when the user must decide.

```
No browser driver reachable from subagents. Personas run as a paper walkthrough and the report says so.
```

## Turn budgets

| Size | Plan to Ready | Build per slice | QA | Ship |
|---|---|---|---|---|
| Bounded | 5 to 7 turns | 2 to 3 | 1 to 2 | 1 |
| Feature | 10 to 14 turns | 2 to 3 | 2 to 3 | 2 |
| Program | overview 6 turns, then Feature per part | | | |

A run that will exceed its budget says so at the next gate and offers "skip ahead".

## Examples

First reply of a plan:

```
Plan playbook. Probe: absent (`git grep -il snooze origin/main -- app/src`: no hits; no branch or worktree named snooze); closest feature is dismiss (app/src/lib/actions/dismiss.ts); anchors read from origin/main a1b2c3d (worktree was 118 behind, reset).
A board surface, an existing column, a sweeper job, and at least one product call, so Feature size, provisional until research.
Budgets: interview 1 at most 8 questions, interview 2 at most 8, 3 explorers, docs about 2 and 3 pages, personas 3 to 5. Folder docs/plans/snooze-action/ created.

Q1 What happened that made this worth doing now? Tell it as one concrete situation.
Recommended, from your actions doc: a reviewer gets review_pr on Friday and the board dot nags all weekend. Reply "ok" or correct me.
```

A build turn:

```
P2 unsnooze. For the reviewer, a snoozed action comes back at the chosen time with a "back" badge; for the next engineer, the sweeper owns unsnooze and nothing else writes snoozed_until.
Tests S2-a, S2-b green: `<the profile's changed-tests command>`, 14 passed, output below. Live: the sweeper unsnoozed the fixture at 09:00, badge shown, screenshot p2-unsnooze.png. Flag off: board unchanged.
Review: spec pass, quality one medium (a retry without a reason), fixed in round 1. Principles: fix root causes (13) removed the retry; prove it works (14) drove the live check.
Next: Opening a PR for P2.
```
