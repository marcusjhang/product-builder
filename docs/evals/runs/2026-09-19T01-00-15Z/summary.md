# Eval run

claude 2.1.277 · 741s · est. $13.96 · partial: False 

Cases passed 0/2 · overall 0.5079365079365079 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| playbook-plan-feature | 0.4444444444444444 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | dor-printed, personas-invoked, plan-files, pm-invoked, techlead-invoked |
| playbook-qa | 0.5714285714285714 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | report-written, verdict, verify-invoked |

## Per-run detail

### playbook-plan-feature run 1: score 0.4444444444444444 · 71 turns · 741s · $7.80 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 11:20am (Asia/Singapore)
- pass `arena-architects`: Agent called 3x (expected 2..∞)
- FAIL `dor-printed`: pattern not found in last_message
- FAIL `personas-invoked`: Skill called 0x (expected 1..∞)
- FAIL `plan-files`: docs/plans/*/implementation.md missing (expected present)
- FAIL `pm-invoked`: Skill called 0x (expected 1..∞)
- pass `research-invoked`: Skill called 1x (expected 1..∞)
- pass `route-plan`: Read called 1x (expected 1..∞)
- pass `size-feature`: matched Feature
- FAIL `techlead-invoked`: Skill called 0x (expected 1..∞)

### playbook-qa run 1: score 0.5714285714285714 · 73 turns · 723s · $6.15 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 11:20am (Asia/Singapore)
- pass `flag-both-states`: matched flag off
- pass `personas-invoked`: Skill called 1x (expected 1..∞)
- FAIL `report-written`: docs/plans/keyboard-archive/qa-report.md missing (expected present)
- pass `route-qa`: Read called 1x (expected 1..∞)
- pass `tests-run`: Bash called 3x (expected 1..∞)
- FAIL `verdict`: grader threw: case "playbook-qa" grader focus file "docs/plans/keyboard-archive/qa-report.md": path "docs/plans/keyboard-archive/qa-report.md" does not exist
- FAIL `verify-invoked`: Skill called 0x (expected 1..∞)

