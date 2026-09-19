# Eval run

claude 2.1.277 · 759s · est. $20.87 · partial: False 

Cases passed 1/3 · overall 0.6222222222222221 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| playbook-bug-fix | 0.6666666666666666 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | mechanism-named, pr-created, scope-held |
| playbook-plan-program | 1 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa |  |
| playbook-ship | 0.2 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | dod-printed, no-flag-edit, no-flag-flip, user-flips |

## Per-run detail

### playbook-bug-fix run 1: score 0.6666666666666666 · 1 turns · 759s · $7.65 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 11:20am (Asia/Singapore)
- FAIL `mechanism-named`: pattern not found in last_message
- pass `no-blanket-catch`: pattern absent as expected
- FAIL `pr-created`: .forge/created.txt missing (expected present)
- pass `repro-first`: Bash@6 precedes Edit@36
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `root-cause-fix`: matched archived
- pass `route-bug-fix`: Read called 1x (expected 1..∞)
- FAIL `scope-held`: grader threw: judge call failed: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 11:20am (Asia/Singapore)
- pass `verify-invoked`: Skill called 1x (expected 1..∞)

### playbook-plan-program run 1: score 1 · 51 turns · 746s · $6.20 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 11:20am (Asia/Singapore)
- pass `overview-written`: docs/plans/*/README.md exists as expected
- pass `parts-table`: matched \| *Part|## Parts|parts table
- pass `route-program`: Read called 1x (expected 1..∞)
- pass `size-program`: matched Program
- pass `walking-skeleton`: matched walking skeleton|user-facing increment

### playbook-ship run 1: score 0.2 · 86 turns · 747s · $7.02 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 11:20am (Asia/Singapore)
- FAIL `dod-printed`: pattern not found in last_message
- FAIL `no-flag-edit`: Edit called 2x (expected 0..0)
- FAIL `no-flag-flip`: Bash called 5x (expected 0..0)
- pass `route-ship`: Read called 1x (expected 1..∞)
- FAIL `user-flips`: grader threw: judge call failed: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 11:20am (Asia/Singapore)

