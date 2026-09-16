# Stress test, 2026-09-16

Six scenarios against a real production repository (a SvelteKit + Bun monorepo with its own agents and skills), each run by an agent following the mode exactly as a user would type it, with a second agent playing a busy product engineer who answered every question from a hidden brief and rated every message. Two builders died on a transient API error mid-run and resumed from the ledger, which tested the resume path for free. Subagents had no browser driver, so every UI check ran in paper mode and said so.

| # | Prompt | Size | Result | User score |
|---|---|---|---|---|
| S1 | add a tooltip to the Archive button on the task card | Trivial | The button does not exist and delete already has a tooltip; stopped with four options instead of inventing work | single turn |
| S2 | add a keyboard shortcut to archive the selected task | Bounded | Ready to implement, Definition of Ready green, five questions, one PR | 8/10 |
| S3 | let members snooze an action from the board | Feature, re-sized Bounded | Proved the Actions substrate does not exist at main, read the design doc, found the ask breaks three locked decisions, proposed an amendment with a fix for the spec's own objection; Verified, on hold | 7/10 |
| S4 | how does a task agent claim a turn | Investigation | Explanation with file:line at the SHA, a guard table, test-backed proof, three doc-drift findings | read-only |
| S5 | go, build archive-task-shortcut | Build of S2 | Five commits in dependency order, 13 files, 2038 tests green, review found and fixed a real double-undo bug, PR body written and shown, stopped at merge | 8/10 |
| S6 | where was I on snooze-action (fresh session) | Resume | Capsule with tagged threads and four ledger-versus-live mismatches, including a closed PR the plan did not know about | read-only |

## What the simulated users rated best

Explore before ask, every time: a shortcut already bound; an undo that would 403 for members; a delete that cascades PRs and sub-tasks; a missing subsystem; a spec objection with a client-side answer. One-letter decisions with buys and costs. Evidence, not claims: commit hashes, test counts, named pre-existing failures with file:line. The PR was never opened without the user.

## What they rated worst, and the fix each produced

| Complaint | Fix |
|---|---|
| The recommendation reconstructed the user's numbers (blended a 22% baseline with a 30% kill floor, changed the window) | Recommendations quote the user's figures verbatim; any change to what the user said is flagged in the same sentence |
| A permission rule was locked, then research found a pattern that made it moot | Never lock a decision that depends on an unread mechanism; read first or mark `pending research` |
| Story text widened scope past the decision it rested on | Story-versus-decision check before presenting the set |
| "ASSUMED, waiting on you" followed by continuing in the same reply | A ruling that waits ends the reply; ASSUMED rows are never described as waiting |
| The end-of-slice menu named the PR body file instead of showing it | Title and body inline before the menu; blockers as their own lines |
| Messages too long for a busy engineer | Twelve-line cap before a question; ten-line digests; the principles line only at step close |

## What the builders hit, and the fix each produced

Eight passes in total. The largest: a trivial track and the sizing table in the mode; plain-text fallbacks for the todo list and the question tool, which subagent sessions do not have; the Bounded fast path renumbered and ordered research-before-decisions; on-hold status and `spec:` anchors for a plan written against a design doc; `UNKNOWN` profile fields resolved and written back with a learning; a status-only resume track; branch name and last step in the ledger so a dropped session resumes; a seam spike before the tech lead; one user stop per slice instead of three; reviewers receive a file list, not a raw diff; a check that is red at the baseline does not block a PR; heavy skills marked so a two-line change skips them; explorer negative claims must name the search that failed; line numbers come from `grep -n`, never counted from a range.

## Not tested

Browser-driven personas, live verify, QA and ship need a session where a browser driver reaches subagents. The bug-fix, refactoring, and perf-issue playbooks did not run.
