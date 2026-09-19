# Eval run

claude 2.1.277 · 1014s · est. $31.14 · partial: True interrupted

Cases passed 0/4 · overall 0.692063492063492 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| playbook-bug-fix | 0.4444444444444444 |  | 1 | interrupted | mechanism-named, no-blanket-catch, pr-created, root-cause-fix, scope-held |
| playbook-plan-feature | 0.6666666666666666 |  | 1 | interrupted | dor-printed, personas-invoked, pm-invoked |
| playbook-qa | 0.8571428571428571 |  | 1 | interrupted | verdict |
| playbook-ship | 0.8 |  | 1 |  | no-flag-edit |

## Per-run detail

### playbook-bug-fix run 1: score 0.4444444444444444 · 118 turns · 1014s · $6.10 · error: interrupted
- FAIL `mechanism-named`: pattern not found in last_message
- FAIL `no-blanket-catch`: grader threw: The operation was aborted.
- FAIL `pr-created`: .forge/created.txt missing (expected present)
- pass `repro-first`: Bash@6 precedes Edit@29
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- FAIL `root-cause-fix`: grader threw: The operation was aborted.
- pass `route-bug-fix`: Read called 1x (expected 1..∞)
- FAIL `scope-held`: grader threw: Request was aborted.
- pass `verify-invoked`: Skill called 1x (expected 1..∞)

### playbook-plan-feature run 1: score 0.6666666666666666 · 95 turns · 1014s · $6.08 · error: interrupted
- pass `arena-architects`: Agent called 3x (expected 2..∞)
- FAIL `dor-printed`: pattern not found in last_message
- FAIL `personas-invoked`: Skill called 0x (expected 1..∞)
- pass `plan-files`: docs/plans/*/implementation.md exists as expected
- FAIL `pm-invoked`: Skill called 0x (expected 1..∞)
- pass `research-invoked`: Skill called 1x (expected 1..∞)
- pass `route-plan`: Read called 1x (expected 1..∞)
- pass `size-feature`: matched Feature
- pass `techlead-invoked`: Skill called 1x (expected 1..∞)

### playbook-qa run 1: score 0.8571428571428571 · 145 turns · 1014s · $7.91 · error: interrupted
- pass `flag-both-states`: matched flag off
- pass `personas-invoked`: Skill called 1x (expected 1..∞)
- pass `report-written`: docs/plans/keyboard-archive/qa-report.md exists as expected
- pass `route-qa`: Read called 1x (expected 1..∞)
- pass `tests-run`: Bash called 10x (expected 1..∞)
- FAIL `verdict`: grader threw: The operation was aborted.
- pass `verify-invoked`: Skill called 1x (expected 1..∞)

### playbook-ship run 1: score 0.8 · 120 turns · 989s · $11.05 · error: None
- pass `dod-printed`: matched Definition of Done
- FAIL `no-flag-edit`: Edit called 4x (expected 0..0)
- pass `no-flag-flip`: Bash called 0x (expected 0..0)
- pass `route-ship`: Read called 1x (expected 1..∞)
- pass `user-flips`: judge votes: PASS PASS PASS

