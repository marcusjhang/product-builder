# Eval run

claude 2.1.277 · 3679s · est. $54.08 · partial: False 

Cases passed 1/12 · overall 0.382771164021164 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| playbook-babysit | 0.8571428571428571 |  | 1 |  | verify-invoked |
| playbook-bug-fix | 0.75 |  | 1 | timed out after 2400s | mechanism-named, pr-created |
| playbook-built-first | 0.7777777777777778 |  | 1 |  | assumed-derived, status-derived |
| playbook-data-migration | 0.8333333333333334 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | migration-file |
| playbook-hardening | 1 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa |  |
| playbook-implement | 0.125 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | ledger-row, pr-created, review-invoked, route-implement, slice-branch, tests-run, verify-invoked |
| playbook-implement-parallel | 0 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | implementers-dispatched, ledger-two-rows, pr-created, review-invoked, route-implement, two-branches |
| playbook-plan-bounded | 0 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | assumed-rows, dor-printed, ledger-written, probe-partial, research-invoked, route-plan, size-bounded, techlead-invoked |
| playbook-plan-feature | 0 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | arena-architects, dor-printed, personas-invoked, plan-files, pm-invoked, research-invoked, route-plan, size-feature, techlead-invoked |
| playbook-plan-program | 0 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | overview-written, parts-table, route-program, size-program, walking-skeleton |
| playbook-qa | 0 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | flag-both-states, personas-invoked, report-written, route-qa, tests-run, verdict, verify-invoked |
| playbook-ship | 0.25 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | dod-printed, route-ship, user-flips |

## Per-run detail

### playbook-babysit run 1: score 0.8571428571428571 · 88 turns · 969s · $8.45 · error: None
- pass `fix-wave`: matched fix wave
- pass `never-merges`: Bash called 0x (expected 0..0)
- pass `readme-fixed`: matched priority
- pass `reads-pr`: Bash called 1x (expected 1..∞)
- pass `route-babysit`: Read called 1x (expected 1..∞)
- pass `triage-table`: matched act|push back|clarify
- FAIL `verify-invoked`: Skill called 0x (expected 1..∞)

### playbook-bug-fix run 1: score 0.75 · 220 turns · 2401s · $14.65 · error: timed out after 2400s
- FAIL `mechanism-named`: pattern not found in last_message
- pass `no-blanket-catch`: pattern absent as expected
- FAIL `pr-created`: .forge/created.txt missing (expected present)
- pass `repro-first`: Bash@8 precedes Edit@17
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `root-cause-fix`: matched archived
- pass `route-bug-fix`: Read called 1x (expected 1..∞)
- pass `verify-invoked`: Skill called 1x (expected 1..∞)

### playbook-built-first run 1: score 0.7777777777777778 · 113 turns · 1303s · $11.41 · error: None
- FAIL `assumed-derived`: grader threw: case "playbook-built-first" grader focus file "docs/plans/*/decisions.md": path "docs/plans/*/decisions.md" does not exist
- pass `derived-plan`: docs/plans/*/decisions.md exists as expected
- pass `dor-printed`: matched Definition of Ready
- pass `pm-invoked`: Skill called 1x (expected 1..∞)
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `round-trip`: matched round.trip|displays|removes
- pass `route-built-first`: Read called 1x (expected 1..∞)
- FAIL `status-derived`: grader threw: case "playbook-built-first" grader focus file "docs/plans/*/product.md": path "docs/plans/*/product.md" does not exist
- pass `techlead-invoked`: Skill called 1x (expected 1..∞)

### playbook-data-migration run 1: score 0.8333333333333334 · 92 turns · 1390s · $10.42 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- pass `db-seat`: Agent called 2x (expected 1..∞)
- pass `five-steps`: matched expand[\s\S]*backfill[\s\S]*cut ?over[\s\S]*contract
- FAIL `migration-file`: migrations/003* missing (expected present)
- pass `replayed`: Bash called 6x (expected 1..∞)
- pass `route-migration`: Read called 1x (expected 1..∞)
- pass `techlead-invoked`: Skill called 1x (expected 1..∞)

### playbook-hardening run 1: score 1 · 111 turns · 1278s · $9.15 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- pass `gap-table`: matched gap
- pass `how-invoked`: Skill called 1x (expected 1..∞)
- pass `no-bare-catch`: pattern absent as expected
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-hardening`: Read called 1x (expected 1..∞)
- pass `silent-failure-seat`: Agent called 2x (expected 1..∞)
- pass `tests-added`: tests/import*.test.js exists as expected

### playbook-implement run 1: score 0.125 · 1 turns · 1s · $0.00 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- pass `flags-route`: matched /flags
- FAIL `ledger-row`: pattern not found in file docs/plans/keyboard-archive/decisions.md
- FAIL `pr-created`: .forge/created.txt missing (expected present)
- FAIL `review-invoked`: Skill called 0x (expected 1..∞)
- FAIL `route-implement`: Read called 0x (expected 1..∞)
- FAIL `slice-branch`: Bash called 0x (expected 1..∞)
- FAIL `tests-run`: Bash called 0x (expected 1..∞)
- FAIL `verify-invoked`: Skill called 0x (expected 1..∞)

### playbook-implement-parallel run 1: score 0 · 1 turns · 1s · $0.00 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- FAIL `implementers-dispatched`: Agent called 0x (expected 2..∞)
- FAIL `ledger-two-rows`: pattern not found in file docs/plans/keyboard-archive/decisions.md
- FAIL `pr-created`: .forge/created.txt missing (expected present)
- FAIL `review-invoked`: Skill called 0x (expected 1..∞)
- FAIL `route-implement`: Read called 0x (expected 1..∞)
- FAIL `two-branches`: Bash called 0x (expected 1..∞)

### playbook-plan-bounded run 1: score 0 · 1 turns · 2s · $0.00 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- FAIL `assumed-rows`: pattern not found in trace
- FAIL `dor-printed`: pattern not found in last_message
- FAIL `ledger-written`: docs/plans/*/decisions.md missing (expected present)
- FAIL `probe-partial`: grader threw: judge call failed: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- FAIL `research-invoked`: Skill called 0x (expected 1..∞)
- FAIL `route-plan`: Read called 0x (expected 1..∞)
- FAIL `size-bounded`: pattern not found in trace
- FAIL `techlead-invoked`: Skill called 0x (expected 1..∞)

### playbook-plan-feature run 1: score 0 · 1 turns · 1s · $0.00 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- FAIL `arena-architects`: Agent called 0x (expected 2..∞)
- FAIL `dor-printed`: pattern not found in last_message
- FAIL `personas-invoked`: Skill called 0x (expected 1..∞)
- FAIL `plan-files`: docs/plans/*/implementation.md missing (expected present)
- FAIL `pm-invoked`: Skill called 0x (expected 1..∞)
- FAIL `research-invoked`: Skill called 0x (expected 1..∞)
- FAIL `route-plan`: Read called 0x (expected 1..∞)
- FAIL `size-feature`: pattern not found in trace
- FAIL `techlead-invoked`: Skill called 0x (expected 1..∞)

### playbook-plan-program run 1: score 0 · 1 turns · 1s · $0.00 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- FAIL `overview-written`: docs/plans/*/README.md missing (expected present)
- FAIL `parts-table`: grader threw: case "playbook-plan-program" grader focus file "docs/plans/*/README.md": path "docs/plans/*/README.md" does not exist
- FAIL `route-program`: Read called 0x (expected 1..∞)
- FAIL `size-program`: pattern not found in trace
- FAIL `walking-skeleton`: grader threw: case "playbook-plan-program" grader focus file "docs/plans/*/README.md": path "docs/plans/*/README.md" does not exist

### playbook-qa run 1: score 0 · 1 turns · 2s · $0.00 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- FAIL `flag-both-states`: pattern not found in trace
- FAIL `personas-invoked`: Skill called 0x (expected 1..∞)
- FAIL `report-written`: docs/plans/keyboard-archive/qa-report.md missing (expected present)
- FAIL `route-qa`: Read called 0x (expected 1..∞)
- FAIL `tests-run`: Bash called 0x (expected 1..∞)
- FAIL `verdict`: grader threw: case "playbook-qa" grader focus file "docs/plans/keyboard-archive/qa-report.md": path "docs/plans/keyboard-archive/qa-report.md" does not exist
- FAIL `verify-invoked`: Skill called 0x (expected 1..∞)

### playbook-ship run 1: score 0.25 · 1 turns · 2s · $0.00 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- FAIL `dod-printed`: pattern not found in last_message
- pass `no-flag-flip`: Bash called 0x (expected 0..0)
- FAIL `route-ship`: Read called 0x (expected 1..∞)
- FAIL `user-flips`: grader threw: judge call failed: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)

