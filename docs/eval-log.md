# Eval log

Everything done to pressure-test the suite, in order, with what was found and what changed. Newest entries at the bottom. Results that back an entry live under `docs/evals/runs/<timestamp>/` (the aggregate JSON and a summary); the raw HTML reports stay local under `evals/results/`, which is gitignored.

## 2026-09-19 · Plan of record

**Goal.** Every playbook (24) exercised at least once; every member of the team (13 leaf skills; every review, tech-lead, and product-panel seat; personas; explorers; architects; implementer subagents; the verifier; the six judge gates) cast at least once and observed in a transcript; results saved and reusable; findings verified against the transcript before any change to the suite; fix, push, rerun until the set is clean.

**Harness.** `claude plugin eval` (Claude Code 2.1.276), the native plugin eval runner. Each case is a directory under `evals/` with `prompt.md` (the user's message plus run limits), `case.yaml` (a `scaffold_script` that builds the workspace), and `graders/*.md`. A run is a fresh headless session with only this plugin loaded, in an empty workspace the scaffold fills; Bash runs under the OS sandbox with writes confined to the workspace and no network. Graders read the final message, the trace, or a file the run wrote.

**Why this and not subagents reading the skill from files.** Three field runs showed the suite degraded when read from files: no hooks, no routing, no `${CLAUDE_SKILL_DIR}`. The native runner loads the plugin the way a user's install does, so the hooks fire and the skills are invoked by name.

**Fixtures.** Runs have no network, so every fixture repo carries a local bare `origin` remote and an `origin/main` ref, which makes the mode's baseline rule (`git fetch origin --prune`) work offline. Two fixture families:
- `taskbox`, a small JavaScript app with `node:test`, no dependencies, built by `evals/fixtures/lib.sh` in layers that each scenario turns on: a feature-flag helper, an analytics helper, ADRs and a glossary, a migrations directory, a test that reads a source file by path, a flaky test, a feature already shipped on `origin/main` behind a flag, a bug with a failing test, a slow path, a vendored dependency with a changelog of breaking changes, dead code behind a legacy flag, a thin module, tags and a changelog, plan folders at each status, a finished branch with no plan, a `<slug>/p2-` branch, an error log with a spike.
- `calcom`, a shallow clone of calcom/cal.com at a pinned SHA with a local bare origin and the suite's example profile, no dependencies installed: the mature-repo cases (setup, investigation, Bounded plan, Built first on a real PR, review on a real PR).

**Simulated user.** Runs never stop to ask, so the question tool is absent and the mode's text fallback applies. Gate cases end at the question and grade the question. Flow cases put the mode's session override in the prompt ("you decide; ok to every recommended answer; run until <gate>"), which the Autonomy section already defines: the run continues on recommendations and records ASSUMED rows.

**Judge.** The runner passes only `EVAL_*` and provider variables into a run, so `TYPESAFE_API_KEY` does not reach the judge script inside a case. The judge is exercised live in Tier 0 (a real call from this shell) and its no-key and `Model: none` degradation paths inside cases.

**Tiers.**
- Tier 0, structural, free: `scripts/check` (frontmatter, paths under both installs, cross-references, dashes, JSON, `claude plugin validate --strict`, judge self-test and one live call).
- Tier 1, routing and gates, cheap: fixture states × short prompts, graded from the first reply.
- Tier 2, playbooks and team, the bulk: one case per playbook, one per leaf skill run alone, one per seat family, flow cases with the session override, `runs: 1`, `--ablation none`, concurrency 4.
- Tier 3, mature repo: the calcom cases, plus two-arm runs on the cases with an objective outcome (bug-fix against a real fix) to measure Δ.

**Scoring rule for the loop.** A grader failure is a finding, not a verdict. Each is checked against the trace before anything changes: a wrong grader is fixed as a grader; a wrong suite behaviour is fixed in the suite with the transcript line quoted here; a run error (turn cap, timeout, sandbox) is a harness finding. The set is clean when every case scores 1.0 with `runs: 2` and no finding is open.

## 2026-09-19 · Harness bring-up

- `claude plugin eval` refuses to start a Bash-granting run when the real home holds a credential store it cannot exclude. On this machine two did: `GOOGLE_APPLICATION_CREDENTIALS` pointed at a file that is not valid JSON, and Docker Desktop's `~/.docker/cli-plugins` holds symlinks. `evals/run.sh` runs the suite under a clean `HOME` that links only `.claude`, `.claude.json`, and `Library` (the login keychain), and unsets the credentials variable. Nothing on the machine was changed.
- Inside the sandbox `/usr/bin/git` (the xcrun shim) fails on every call because xcrun wants a cache under `/var/folders` that the sandbox denies. The first traced run showed the session reading `.git/HEAD` by hand as a workaround. `run.sh` puts a wrapper for the Command Line Tools git first on `PATH`; a symlink was not enough because git resolves its template directory from the link's location.
- Fixture defects found by the fixture's own self-test before any case ran: `node --test tests/` does not recurse a directory (glob needed); `scripts/check.js` imported `cli.js` and ran it; the store path was resolved at import time so tests wrote to the real store; the routes contract test broke as soon as a route layer was added (README line now derived from `ROUTES`); the flaky test was not flaky but deterministic (now concurrent tests over one shared store, about one failure in two).
- Grading facts from the first traced run (`playbook-investigation`, 160 s, about $1): a `/product-builder …` prompt is expanded by Claude Code, so no `Skill` tool call marks the mode; the mode reads `principles.md`, the matched `playbooks/<name>.md`, and `writing.md`, so the route is graded as a `Read` of the playbook file. Leaf skills the mode invokes should appear as `Skill` calls; in that run there were none.
- Case set: 51 cases, 276 graders, generated by `evals/tools-gen-cases.py` from one table: 26 playbook cases (every playbook, plus pause and program), 13 leaf-skill cases, 7 routing and gate cases, 2 judge cases, 3 cal.com cases. Team coverage is asserted per seat with `tool_used: Agent` graders matched on the seat's name in the subagent prompt.

### Findings so far (verified against the trace before anything changes)

- F1 `playbook-investigation`: the investigation playbook says "Route through the product-builder-how skill"; the run read the playbook, then did the reading itself: no `Skill` call, no `Agent` call, no read of `product-builder-how/SKILL.md`. The answer was correct and anchored. Open: decide whether a one-module question may skip the how skill, or whether the playbook must say "invoke it with the Skill tool".
- F2 `leaf-plain`: the restatement turned "the probe returned partial" into "I only got part of the picture" (a wrong meaning), came out longer than the original, and used two em dashes against the writing rules. The plain skill is seven lines and says "shorter, no jargon"; it does not say "keep every fact's meaning; when a term is ambiguous keep it in quotes", nor does it point at the writing rules.

## 2026-09-19 · Tier 0 results

- `skills/product-builder/scripts/check --plugin-validate`: clean after two adjustments to the check itself (the design record `docs/PLAN.md` is not lint-checked for cross-references, since it names files as they were planned; playbooks may use inline step lists).
- Judge, live against the API for the first time (the CHANGELOG had said "not yet run against the live API"), model `jev-1.13.0`, latency 0.7 to 0.95 s per call:
  - `anchor`: a true claim about `archive()` scored holds at 0.98; a false claim ("refuses to archive a done task") scored refuted at 0.70.
  - `question-gate`: a question with no recommended answer returned `fix:add_default` before any deflection; a naming question with a default returned `ask` (product or preference 0.64).
  - `spec-line`: a domain-level test for a UI acceptance line returned uncovered ("does not exercise the WHEN/THEN" 0.66), which is right since the line says a click with the flag on; a test whose subject is a mock returned uncovered with "the subject is mocked away" 0.75.
  - `finding`: a real auth bypass returned act on at 0.94, severity critical.
  - `finding-pair`: two seats' wordings of the same bypass returned same at 0.96.
  - `pr-comment`: a human accessibility comment returned act with real bug 0.84; a bot's trailing-whitespace comment returned act at 0.98 with real bug 0.19, so the bucket rule treats a trivial lint as actionable rather than noise. Noted for the babysit playbook's triage, where `dismissed` is the bucket the playbook expects for bot noise; the verdict carries the real-bug score, so the step can still route on it. Not changed.
- The structure board exists (scene `Z07dYjHJBO`) and `CLAUDE.md` tells every session to keep it current.

## 2026-09-19 · Tier 1, run 1 (`docs/evals/runs/2026-09-18T18-21-33Z`)

11 cases, 751 s, about $11.56 at list price, 2 of 11 clean. Every failed grader was read against its trace before anything changed.

**Grader defects (fixed in the generator, no suite change).**
- Every pattern that used an inline `(?i)` threw "Invalid regular expression" (JavaScript regexes have no inline flag). 18 graders across 8 cases. `regex` graders now carry `flags: i`; `tool_used` patterns are expanded to per-letter character classes. All 250 patterns now compile under both engines.
- `route-no-profile`: the run invoked `product-builder-setup` through the Skill tool (the trace shows `product-builder:product-builder-setup`), which the grader did not accept. It now grades the Skill call.
- `gate-one-question-default`: the judge counted the options and the Recommended line as "lines before the question". The rubric now says which lines count.
- `route-explicit-prefix`: the flaky-test playbook ran its quantification loop past the case's 600 s cap; all graders passed. The budget is now 1800 s.
- `playbook-intake-ships`: the ask ("let people snooze") was broader than what shipped (the endpoint, no page control), so the probe returned `partial` and the plan continued, which is right. The prompt now asks for exactly the endpoint that ships.

**Suite defects (fixed, with the trace line that showed them).**
- F1 confirmed twice more (`gate-judge-no-key`, `gate-judge-none`): the Investigation route did the how skill's work inline, with `skip: explorers. One module` in the todo block, and in one run opened `product-builder-how/SKILL.md` with Read instead of invoking it. Reading the file bypasses the harness's `${CLAUDE_SKILL_DIR}` substitution and the skill's hooks. Fix: the mode's Playbooks section says a bold leaf-skill name is invoked with the Skill tool and never opened with Read; the investigation playbook says the how skill runs even for a one-module question.
- F2 (`leaf-plain`): fixed in the plain skill, which now keeps every fact's meaning, keeps an uncertain term in quotes, is shorter than the original, and points at the writing rules.
- F3 (`route-state-vs-words`): the state pass never ran the forge tool, so the open PR with a red check was invisible and the words alone routed to Bug fix, where the run then stopped correctly on a stack trace that does not match the code ("the premise doesn't hold"). Fix: the mode's routing paragraph is now a concrete command list that includes `pr list --head <branch>` and `pr checks`, and says an unread state fact is not "absent".

**Behaviour that held.** `route-trivial` did the change on the Trivial track with no plan folder and verified it. `route-by-state` named Built first with its two facts ("2 commits ahead of origin/main with code, the tree is clean, and there was no plan folder"). `route-continue-no-args` routed to Pickup and pause, invoked resume, and stayed on the status-only branch because the ask carried no "continue". `gate-one-question-default` explored first, locked the user's three words as D1 to D3 so the interview would not re-ask them, and ended with one question and a recommended answer.

## 2026-09-19 · Leaf batch, run 1 (`docs/evals/runs/2026-09-18T18-28-31Z`)

13 cases, 1309 s, about $24.78 at list price, 9 of 13 clean. Clean: how (four explorers on distinct angles, a synthesis with anchors), why (git history plus the ADR, dated), prototype (variants behind a switcher, a recommendation, the decision recorded), personas (five cards including two the roster did not have: a first-time user and a flag-off mobile user), pm (all five seats), reflect, resume, setup (all four files, the CI lane detected), verify.

**Suite defects (fixed).**
- F4 `leaf-review-all-seats`: the diff carried fourteen signals; nine seats were cast (staff, QA, product owner, security, silent-failure, backwards compatibility, prompt quality, cost, migration) and five with a present signal were not (frontend, integration, SRE, accessibility, adversarial user). The skill said "cast three to five seats", a cap the diff had already forced past, so the model chose which signals to drop. Fix: the count follows the diff; every seat whose signal is present is cast, in waves of at most five; an uncast seat with a present signal is a review defect.
- F5 `leaf-techlead-all-seats`: four seats cast (tech lead, hawk, security, cost) against a plan carrying six by-signal seats; database, frontend, SRE, and integration were dropped under "two to four seats". Fix: the same rule, waves of at most four.
- F6 `leaf-research`: `--system` on a Feature plan ran with zero explorers; the session read the area itself inside the step (32 Bash and 17 Read calls) and then declared "Explorers: 0" under the rule that allows zero when the area was already read. Fix: zero is allowed only when the area was read before the research step began; reading inside the step is what an explorer is for.

**Grader defects (fixed).**
- `leaf-plain`: the plain skill now produces a correct restatement (574 characters, no dashes, "part of the archiving work is already built"), and the graders still failed because they demanded a text shorter than a 450-character original. A faithful plain restatement of dense text is about the same length. The graders now allow up to about one and a half times the original and check meaning and jargon.

## 2026-09-19 · Tier 1, run 2 (`docs/evals/runs/2026-09-18T18-44-49Z`)

11 cases, 977 s, 8 of 11 clean (was 2 of 11). Both judge cases, intake-ships, route-by-state, route-no-profile, route-explicit-prefix, route-trivial, and route-continue now pass.

- `route-state-vs-words` (still failing, F3 not closed): the state pass ran as one Bash call and followed the new list except its forge step, so the open PR with the red check stayed invisible and the words routed to Bug fix. The run then did the right thing inside Bug fix: it drove the route in process (`listen` is denied in the sandbox), showed `src/tasks.js:22` is `save(db)` and no `.status` read exists in `complete`, and stopped with one question and (a) recommended. The premise check is exemplary; the routing is not. A prose list was followed nine items out of ten, so the pass is now a script: `skills/product-builder/scripts/state` prints every fact including `pr list --head` and `pr checks` through the profile's forge tool, and the mode runs it in one call. Tested on the case's fixture: it prints the PR and its failing check.
- Also seen in that trace: `git fetch` inside the sandbox failed with the xcrun cache error on `git-upload-pack`, because only `git` had a wrapper. `run.sh` now wraps `git-upload-pack`, `git-receive-pack`, and `git-upload-archive` too.
- `gate-one-question-default`: the behaviour is right (one question, three options with buys and costs, a recommendation, "Reply ok for (a), or name the letter", eight lines before Q1). Two grader defects: the regex expected the ok line directly under the Recommended line, and the judge could not count lines. Both are regexes now.
- `leaf-plain`: 315 characters, meaning kept, no dashes; the judge failed it for the word "baseline". The rubric now names the three phrases that count as jargon and allows ordinary words.

## 2026-09-19 · Playbook batch A, run 1 (`docs/evals/runs/2026-09-18T19-00-03Z`)

15 cases, 4119 s wall at concurrency 3, about $104 at list price, 12 of 15 clean: flaky-test (quantified alone and in CI's lane, fixed at the cause, four seats plus a fix wave, PR opened), incident, intake-ships (stopped at the probe with one question), investigation (how skill invoked through the Skill tool, four explorers), pause (handoff written, WIP saved), perf-issue (bench run twice, one change), pickup (resumed the slice, finished it, opened the PR), refactoring (Store class, characterisation, review), release (changelog written, tag and publish shown and not run), removal (inventory with named searches, why skill, delete in order), revise (re-slice with a revision-log row and the tech lead on the new boundary), spike (probe script, verdict, branch not merged).

**Suite defect (fixed).**
- F7 `playbook-opening-a-pr`: "open a PR for this branch" on a finished branch with no plan folder routed to Built first (the state rule for unplanned code) and ran the derived plan, three panels, a fix wave, and evidence capture for 80 turns without reaching the PR. The words named a playbook trigger and should have won. Fix: the mode's routing says "open a PR" on that state routes to Opening a PR, which names the missing plan under Why and offers Built first as the next move; the playbook's owner line says the same.

**Grader and harness defects (fixed).**
- `playbook-decision-record`: a file-source grader with a glob path ("docs/adr/0002-*.md") is refused by the runner. Every glob file grader (program overview, built-first derived plan, the ADR) now reads the written content from the Write inputs in the trace. The ADR itself was written with a Consequences section and linked both ways.
- `playbook-dependency-upgrade`: the changelog was read with `cat`, not the Read tool; the grader now looks for the path in the trace. The upgrade itself landed every breaking change with the backwards-compatibility seat cast.
- `playbook-pickup`: finished the slice and opened the PR at turn 121 against a cap of 120; every grader passed. Budget raised to 200.
- The runner exited 127 after the batch because `evals/run.sh` was edited while the batch was in flight and bash re-read the changed file mid-execution. The script body is now a function, parsed whole before it runs.

## 2026-09-19 · Playbook batch B and cal.com, run 1 (`docs/evals/runs/2026-09-18T19-18-12Z`, `2026-09-18T20-11-02Z`)

Both batches hit the account's monthly spend limit partway: 10 of 12 batch B runs and 4 of 5 cal.com runs ended with "You've hit your monthly spend limit" and their scores are harness failures, not findings. They are rerun below. Four runs completed and were verified:

- `playbook-babysit` (88 turns): read the PR and its checks through the forge stub, triaged the three comments (act, dismissed with a byte-level check that no trailing whitespace exists, act with a push-back on a wrong premise that it disproved by replaying the baseline handler), fixed, and ran two fix waves. It never invoked `product-builder-verify` after the pushes; it ran the CI lane itself. F8, fixed: babysit step 4 now says the verify skill is invoked with the Skill tool after each push, and a test run in the session is not that.
- `playbook-bug-fix` (220 turns, timed out at 2400 s): reproduced, root-caused at `src/tasks.js`, fixed with a named error, then review found six defects in the fix's own surroundings including a crash on `GET /` and the run fixed all of them, reshaped history, and regenerated evidence until the clock ran out with no PR. F9, fixed: the bug-fix playbook bounds the loop (three rounds, fix waves on the fix diff only) and sends every finding that is not about the named mechanism to "your call"; a fix that grows past the mechanism is a Hardening or a Plan. A grader now checks the scope held.
- `playbook-built-first` (113 turns): derived the plan, cast the panels, printed the Definition of Ready. Its two failures were the glob file graders already replaced.
- `calcom-investigation` (22 turns, $3.92): the how skill through the Skill tool, explorers, anchors under `apps/` and `packages/`, no change made. Clean.

**Harness.** Both runs reported that the sandbox refuses `listen` on any address, so every socket-bound test and every live HTTP check fails inside a run. `sandbox.network.allowLocalBinding: true` is now set in the user settings so sandboxed commands may bind localhost; whether the eval runner honours it is checked by rerunning `leaf-verify`, which launches the fixture's server.
- `leaf-verify` rerun with `allowLocalBinding` set: still `listen EPERM` on `0.0.0.0:3111` and on `127.0.0.1`; the eval runner's sandbox does not take the user's network settings. The setting was reverted so the machine is as it was. The case still scored 1.0: the verify skill drove the handler in process, said the sandbox refuses to bind, and graded each scenario from real responses. Live HTTP on a bound port cannot be exercised inside a run; the in-process path is what the suite has to offer there and it says so.

## 2026-09-19 · Retest wave 1 (`docs/evals/runs/2026-09-18T22-28-53Z`)

13 cases rerun after the fixes, 2902 s, 9 of 13 clean. Now clean: leaf-review-all-seats (all fourteen seats cast), leaf-techlead-all-seats, leaf-research (explorers dispatched), leaf-plain, playbook-built-first, playbook-decision-record, playbook-dependency-upgrade, calcom-setup, calcom-review.

- `playbook-opening-a-pr`: F7 closed. Routed to Opening a PR ("the words name it"), skipped the panels, opened the PR, named the unproven socket path honestly, and offered Built first as the next move. The one failed grader looked for the PR body in the last message; the body is shown before the PR opens, earlier in the run. Grader now reads the trace.
- `playbook-babysit` (232 turns, timed out): the verify skill was invoked (F8 closed) and every other grader passed, but the run ran four fix waves, each finding regressions in the previous wave's fix, widening from the three comments to "a V8 message leaking into a 400". F10: the fix wave had no mandate boundary and no termination. Fix: a wave covers the fix diff only and only regressions the fix introduced or ways it falls short; at most two waves per branch in a run; the rest goes to "your call".
- `route-state-vs-words`: the state script ran and printed PR 7 with its red check; the mode routed to Bug fix on the stack trace, checked the premise, and stopped with one question. That is what the routing rule says: words that name a trigger win. The case had expected a route question, which contradicts the rule, so its graders now assert the Bug fix route, the state script, and that the PR state is named. What the reply did not do is name the red PR at all; the mode now says a state fact that changes the next move is named in the route line's second sentence.
- `gate-one-question-default`: one question, a default, fourteen physical lines before Q1 including blanks. The grader counted blank lines; it now allows them.

## 2026-09-19 · Retest wave 1b (`docs/evals/runs/2026-09-18T23-19-39Z`)

4 of 4 clean, 684 s. `playbook-babysit` went from 232 turns and a timeout to 75 turns and 684 s with exactly two waves, the second because the first returned an act-on (F10 closed). `playbook-opening-a-pr` 61 turns, PR opened, Built first offered as the next move (F7 closed). `route-state-vs-words` 18 turns: the state script ran, the route line named the stack trace and the red PR, the premise was checked. `gate-one-question-default` 28 turns, one question with a default.

## 2026-09-19 · Retest wave 2 (`docs/evals/runs/2026-09-18T23-19-19Z`)

The 11 long flows the spend limit had killed, 5897 s, about $145 at list price, 7 of 11 clean: calcom-built-first (a real PR diff, derived plan, panels, Definition of Ready), calcom-plan-bounded, data-migration (expand, backfill, verify, cut over, contract as slices, replayed on a scratch copy, database seat), implement (slice branch, tests from acceptance lines, review, verify, PR), implement-parallel (two implementer subagents in worktrees, two branches, two ledger rows), plan-bounded (research and tech lead invoked, ASSUMED rows, Definition of Ready printed), qa (charter, personas, verify, qa-report with a verdict).

**Suite defects (fixed).**
- F11 `playbook-bug-fix` (63 turns): reproduced, root-caused, fixed with a named 409, verified on the CLI and the in-process handler, wrote learnings rows, and then ended the run on the verify skill's reply with review and the PR unchecked and no blocker named. Fix: the mode's Playbooks section says a reply that ends with a step unchecked, no question, and no blocker has stopped early; a leaf skill's reply is not the playbook's reply, and the next step runs.
- F12 `playbook-plan-feature` (89 turns, $20): research, arena architects, product panel, and tech lead all ran; personas never did and the final reply does not mention them. Fix: the Definition of Ready box now reads red for a Feature plan whose product panel or personas were not cast, so the omission cannot pass the gate silently.
- F13 `playbook-ship` (101 turns, capped): the pre-flight found the success-signal event polluted and mis-attributed, then fixed the product code inside Ship, wrote the QA report the ledger had claimed, the rollout file, docs, and an announcement, and ran out of turns before printing the Definition of Done. The playbook said a red item "routes back"; it did not say the fix is not done here. Fix: a red item names its owning playbook and the slice it needs, and Ship resumes after that slice merges; under a session override the fix is still its own Implement slice with its own ledger row.

**Fixture defect (fixed).** The merged P1 in the fixture did not pass `source: page` from the Archive button through the route, so the plan's instrumentation line was false and the ship run was right to find it. The page now sends `?source=page` and the route passes it.

**Grader defects (fixed).** `playbook-ship`'s "no flag flip" grader counted `cat data/flags.json`; it now matches writes only, plus an Edit on the file. `playbook-plan-program`'s judge could not see the overview (the Write sits mid-trace, outside the judge's first and last twelve messages); the overview's parts are user-facing increments with part 1 the skeleton, so the grader is now a regex over the trace.

## 2026-09-19 · Retest waves 3 and 4 (`docs/evals/runs/2026-09-19T01-00-00Z`, `2026-09-19T01-00-15Z`)

All five reruns (bug-fix, plan-program, ship, plan-feature, qa) hit the account's monthly spend limit within their first minutes; only `playbook-plan-program` completed before it and scored 1.0 (grader fix confirmed). The other four scores are harness failures and say nothing about F11 to F13. Stopped here at the user's request.

## Where the loop stands

- **Clean, verified against traces**: Tier 1 (11 of 11 after fixes), leaf skills and seats (13 of 13), playbook batch A (15 of 15 after fixes), cal.com (5 of 5: setup, investigation, review, built-first, plan-bounded), and from batch B: babysit, built-first, data-migration, implement, implement-parallel, plan-bounded, plan-program, opening-a-pr, pickup, pause, and the rest listed in the batch entries above. Every playbook ran at least once; every review, tech-lead, and product-panel seat, the personas, explorers, architects, parallel implementers, the verifier, and the judge's gates were observed in a transcript.
- **Fixed after the last clean run and not yet re-verified** (the spend limit blocked the reruns): F11 (a playbook continues after a leaf skill returns; `playbook-bug-fix`), F12 (Feature plans need both panels cast; `playbook-plan-feature`), F13 (Ship never fixes a red item inline; `playbook-ship`), and the fixture's `source=page` change (`playbook-qa`). Rerun with `evals/run.sh --tag retest1 --ablation none` and `--tag retest2` once the limit resets; the tags are set for exactly these cases.
- **Not done**: the final `runs: 2` pass over the whole set that the plan of record named as the closing condition.
- **Cost of the loop so far**, at list price as the runner estimates it: about $480 across nine batches.
