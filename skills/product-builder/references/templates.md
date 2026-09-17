# product-builder plan templates

## Contents
- Status lifecycle
- Length caps
- product.md
- implementation.md
- research.md
- decisions.md
- qa-report.md
- README.md (program overview)
- Definition of Ready
- Definition of Done

## Status lifecycle

`Draft` → `Framed` (G1) → `Researched` → `Decided` (G3) → `Drafted` (G4) → `Prototyped` → `Verified` (G6) → `Ready to implement` (G7, Definition of Ready green) → `Implementing` → `Built` → `QA passed` | `QA failed` → `Shipping` → `Shipped` (Definition of Done green) | `Superseded`

A plan whose substrate does not exist yet carries `On hold: <what it waits for>` after its status (for example `Verified, on hold: Actions shipping`). Claims about a design doc rather than code are anchored `spec:<path>:<line>`; the Definition of Ready item for anchors reads "spec-anchored, re-anchor on revise" and stays red until the code exists, which is honest, not a failure.

The status line sits in the header of `product.md` and is mirrored in `decisions.md`. Move it forward only when the gate for that step is closed.

## Length caps

Rough means short. `product.md` about two pages, `implementation.md` about three. When a section wants more, the extra goes to `research.md` (facts) or `decisions.md` (why), and the plan links to it. A program's `README.md` stays under one page.

## product.md

```markdown
# <Feature>: product plan

**Status:** Draft
**Baseline:** `origin/main` @ `<sha>` (read <YYYY-MM-DD>)
**Owner:** <name> · **Plan folder:** `docs/plans/<slug>/` · **Prototype:** none (<reason>) | `prototype/index.html` | branch `<slug>/spike-…` | `prototype/contract.md`
**Size:** Bounded | Feature | Program (part of `docs/plans/<program-slug>/`) · **Watch window:** 3 days

## Problem
<The story that motivates the work. One concrete situation, who was in it, what went wrong or was slow, how often it happens. What they do today instead and what it costs them. Three to eight lines.>

## Who it's for
- **<Persona name>** (<role>): <what they are trying to do, what they know, what they will not tolerate>. 2-4 lines.

## Appetite
<One PR this week | 2-4 PRs over ~2 weeks | a program of parts.> <What that appetite rules out.>

## Solution
<What a user does and sees, in five to ten lines. Fat-marker level. Name the one thing this must get right. An ASCII sketch of the surface is welcome.>

| Surface | Placement | Loading | Empty | Error | Populated | Live | Keyboard / mobile |
|---|---|---|---|---|---|---|---|

## User stories
### S1. <short name>
As a <persona>, I want <capability>, so that <benefit>.
Surface: <screen or endpoint or command> · States: loading, empty, error, populated, live   (UI)
Consumer: <who calls it> · Contract sample: <request → response, transcript, or payload>   (non-UI)
Acceptance:
- WHEN <trigger or context> THEN <observable result>
- WHEN <failure or edge> THEN <observable result>
Permissions: owner …, member …, viewer …   (when roles exist)
Priority: must | should | later · Verified by: prototype catalog #, persona walkthrough, <test name>, QA

## Non-goals
- <Thing not being done>. <Why, and what would bring it back.>

## Rabbit holes
- <Detail that could eat the appetite>. <The decision that keeps it shallow.>

## Assumptions
| # | Assumption (what must be true) | Type | Importance | Evidence | Test | Verdict |
|---|---|---|---|---|---|---|
| A1 | | desirability / viability / feasibility / usability / ethical | high / low | strong / weak / none | prototype / persona / spike / data / one question | pending / holds / fails / accepted risk |

## Instrumentation
Convention: <from the profile, e.g. object plus past-tense verb, snake_case>. Events describe outcomes, not UI surfaces.
| Event | Trigger | Properties | Owner | Reads |
|---|---|---|---|---|
Success-signal query: <where and how it is read>.

## Rollout and launch
Flag: `<name>` default off · Stages: internal → <cohort> → <percentage> → all, each gated by <check> · Kill switch: <how> · Flag off: <what the user sees> · Flag removed: <when, by which follow-up> · Docs / changelog / support note: <needed or not, and where>.

## Success signal
Hypothesis: if <persona> can <capability>, then <metric> moves from <baseline> to <target> within <window>.
Guardrails: <metrics that must not get worse>. Kill criterion: <what would tell us we were wrong>.

## Open questions
- <Question>. Recommendation: <answer>. Owner: <who>. Needed by: <phase>.
```

## implementation.md

```markdown
# <Feature>: implementation plan

**Status:** Draft
**Baseline:** `origin/main` @ `<sha>` (read <YYYY-MM-DD>) · **Product plan:** `product.md` · **Research:** `research.md` · **Modelled on:** <closest existing feature, path>

## Current → target

```
<ASCII diagram of the current flow>        <ASCII diagram of the target flow>
```
<Two or three lines on what the diagram changes. Every box that exists today has a file:line anchor in research.md.>

## Approach
<Three to eight lines. The seam being reused, the closest feature being copied, the one new thing, and why this is the smallest change that satisfies the stories.>

| Simpler alternative considered | Why not |
|---|---|
| <option> | <the story or constraint it fails> |

## Changes
| Area | File | Change |
|---|---|---|
| <route / service / dao / schema / component / job / flag / event> | `<real path>` | <one line> |

## Data and contracts
<Schema changes with expand/contract steps if destructive, API or event contracts, realtime payloads. "None" is a valid answer.>

## Test strategy
<Existing test seams to extend (paths). Unit vs integration vs end-to-end. What runs only in CI. Each acceptance line's test is named in its slice.>

## Observability
<Logs, metrics, error signals that make a failure of this feature diagnosable in production without a repro.>

## Slices (one PR each, riskiest first)
### P1. <verb phrase>   (walking skeleton when a flag exists)
Stories: S1 · Depends on: none · Size: S | M | L
Files: `<paths>` · Data: <none | expand step> · Flag: `<name>` off
Build: <one to three lines>
Tests: S1-a → `<test name>` · S1-b → live check
You see: <the observable result>
Verify: unit `<command>` · live <click path or command, flag on and off> · regression <what must still work>
Rollback: <flag off | revert PR | contract step>

### P2. ...

## Risks and rollout
- <Risk>. Lands in P<n>, watched by <signal>. Rollout order: expand, skeleton, slices, contract.

## Open questions
- <Question>. Recommendation: <answer>.
```

## research.md

```markdown
# <Feature>: research

**Read at:** `origin/main` @ `<sha>` (<YYYY-MM-DD>) · **Explorers:** <n> · **Prior art:** <n> products · **Spikes:** <n>

## Current system
<Entry points → data flow → persistence → events/realtime → tests, each hop a real path with file:line. Existing patterns to reuse. Permissions touched. Constraints from ADRs, glossary, and deploy reality. Bullets, not prose.>

## Closest existing feature
<Name, files, the PR that added it, the conventions it followed (component, route, service, test, flag, event). Why the plan models on it, or why not.>

## Prior art
| Product / tool | How they solve it | Takeaway for us |
|---|---|---|

Must have (table stakes): ... · Differentiators: ... · Defer: ...
Pitfalls seen elsewhere: ...
Sources: <URLs, retrieval date>

## Spikes
| Question | What ran | Verdict | Artifact |
|---|---|---|---|

## What this changes about the framing
<Bullets. Facts that contradict or sharpen Interview 1's answers.>

## New questions for Interview 2
<Numbered. Each with the fact that raised it and a recommended answer.>
```

## decisions.md

```markdown
# <Feature>: decisions ledger

**Status:** Draft · **Size:** <size> (provisional until Researched) · **Budgets:** <from the sizing table> · **Last revision:** <date> · **Baseline:** `<sha>` (<n> behind, anchors read from <checkout | origin/<default>>)
**Probe:** <ships | partial | absent> (<file:line on origin/<default>, or the exact search that failed>) · **Closest feature:** <name, path> · **Prior art:** <spec or plan folder found, or none>

## Decisions
| # | Decision | Options considered | Why | Who | Date | Status |
|---|---|---|---|---|---|---|
| D1 | <the call> | (a) … (b) … | <one line> | user \| agent \| ASSUMED | <date> | locked \| superseded by D<n> |

## Assumed (awaiting the user)
<Rows above marked ASSUMED, each with the question the user should answer to confirm or overturn.>

## Rejected (do not re-introduce)
| Idea | Why rejected | Date |
|---|---|---|

## Deferred (written down or it does not exist)
| Item | Deferred from | What brings it back | Date |
|---|---|---|---|

## Open questions
| Question | Recommendation | Owner | Needed by |
|---|---|---|---|

## Review rulings
| Source | Finding | Bucket | Ruling | Applied to |
|---|---|---|---|---|
| persona:<name> / pm:<seat> / techlead:<seat> / review:<seat> / qa | <one line> | act on / consider / noted / dismissed | change plan / change prototype / accept risk / needs real users | product.md §… / implementation.md P… / prototype |

## Next move
<One line: the single most useful next action and the playbook or skill that runs it. Rewritten at every hand-off, revision, and slice end.>

## Revision log
| Date | Trigger | What changed | Phases re-run |
|---|---|---|---|

## Implementation log
| Slice | Branch | PR | Status | Last step | Deviations from plan |
|---|---|---|---|---|---|
<One row per slice, written when the branch is created (status `started`, last step `branch`), updated at every playbook step (`tests red`, `tests green`, `verified`, `reviewed round n`, `pr body written`, `pr open #N`, `merged`), so a dropped session can resume from the row.>

## Ship log
| Date | Flag state / cohort | Success signal | Errors vs prior week | Notes |
|---|---|---|---|---|
```

## qa-report.md

```markdown
# <Feature>: QA report

**Verdict:** ship | fix-first · **Target:** <url or env> · **Baseline:** `<sha>` · **Slices merged:** <list> · **Date:** <YYYY-MM-DD>

## Charter
| Story | Acceptance line | How tested | Role | Result | Evidence |
|---|---|---|---|---|---|

## Exploratory pass
| Check | Result | Evidence |
|---|---|---|
| Flag off shows old behaviour | | |
| Flag on shows new behaviour | | |
| Empty and first-run states | | |
| Every failure line | | |
| Each role in the permissions matrix | | |
| Two users at once | | |
| Mobile width | | |
| Slow network | | |
| Keyboard path and icon labels | | |
| Instrumentation events fire with properties | | |
| Rollback rehearsal | | |

## Regression
| Surface | Result | Evidence |
|---|---|---|

## Bugs
| # | Severity | Story | Repro | Expected | Actual | Owner |
|---|---|---|---|---|---|---|

## Coverage gaps
<What could not be tested here and why.>
```

## README.md (program overview, Program size only)

```markdown
# <Program>: overview

**Status:** Draft · **Baseline:** `<sha>` · **Parts:** <n>

## Problem
<Three to five lines. Link each part for detail.>

## Parts
| Part | Folder | Scope (one line, a shippable user-facing increment) | Depends on | Status |
|---|---|---|---|---|
| 1 | `parts/<slug>/` | the walking skeleton | none | Draft |

## Shared decisions
<Decisions that bind every part: vocabulary, data ownership, order of landing. Each is also a row in this folder's decisions.md.>

## Order
<Which parts land first and why. What a user sees after each part.>
```

## Definition of Ready

A plan may be built when all hold. The Plan playbook prints this list in the reply before hand-off, each box with the evidence that checks it; a box without evidence is red, a list that was not printed has not run, and a red item sends the plan back to the phase that owns it.

- [ ] Problem statement, audience, today's workaround, appetite, success signal, and kill criterion are written and confirmed at G1.
- [ ] Every must-story has WHEN/THEN acceptance including at least one failure or edge line, a surface with five states (UI) or a consumer and contract sample (non-UI), and a permissions line where roles exist.
- [ ] Non-goals and rabbit holes are written with reasons.
- [ ] Every current-state claim in `implementation.md` has a file:line anchor at the baseline SHA (or a `spec:` anchor when the plan is on hold against a design doc, which keeps this item red until code exists), and the closest existing feature is named.
- [ ] Simpler alternatives are listed with the story or constraint each fails; at Feature and Program size the approach was chosen from at least two candidates.
- [ ] The riskiest assumptions each have a test verdict or an accepted risk with a reason; `pending` is red.
- [ ] Slices are vertical, ordered riskiest-first, sized S/M/L, each with stories, files, data, flag, named tests per acceptance line, live check, regression, rollback; a schema expand is its own first slice; P1 is the walking skeleton when a flag exists. Each slice, and each commit contract stacked inside a PR, compiles and its tests are green with only what lands before it; a change that widens an exhaustive type or registry (a union, an enum, a `Record` over one) lists every consumer in the same slice.
- [ ] The appetite check passed, or the cuts were made and recorded.
- [ ] Instrumentation events and the success-signal query are named; rollout (flag, cohorts, kill switch, flag-off behaviour) is written.
- [ ] Tech-lead findings have no open "act on"; product-panel and persona findings, when those were cast, have no open "act on" (Bounded: "not cast, Bounded" is green); the rulings table has one row per finding the panels returned and its counts match the findings blocks; a high-importance assumption has a spike verdict or an accepted risk with a reason, and only a low-importance one may pass with an owner.
- [ ] Open questions each have a recommendation and an owner; ASSUMED decisions are listed.

## Definition of Done

A feature may be called shipped when all hold. the Ship playbook prints this list before the flip and again at close.

- [ ] Every slice is merged; the ledger's implementation log matches the PRs.
- [ ] Every acceptance line maps to a passing test or a live check with evidence.
- [ ] `qa-report.md` verdict is ship; flag on and off both verified; permissions matrix verified per role; rollback rehearsed.
- [ ] Instrumentation events fire with their properties in the real environment.
- [ ] Reviewers-by-path satisfied; docs, changelog, or support note done when the plan called for them.
- [ ] The review and QA verdicts name the deployed head SHA (no stale verdict).
- [ ] The flag is on for the intended cohort; the watch window passed; the success signal and error rates were checked and recorded in the ship log.
- [ ] Flag removal is scheduled or done.
- [ ] Status is `Shipped` and `product-builder-reflect` was offered.
