# Eval run

claude 2.1.277 · 33s · est. $0.39 · partial: True interrupted

Cases passed 0/1 · overall 0.14285714285714285 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| playbook-dependency-upgrade | 0.14285714285714285 |  | 1 | interrupted | changelog-read, compat-seat, consumer-fixed, pr-created, review-invoked, tests-run |

## Per-run detail

### playbook-dependency-upgrade run 1: score 0.14285714285714285 · 6 turns · 33s · $0.39 · error: interrupted
- FAIL `changelog-read`: Read called 0x (expected 1..∞)
- FAIL `compat-seat`: Agent called 0x (expected 1..∞)
- FAIL `consumer-fixed`: grader threw: The operation was aborted.
- FAIL `pr-created`: .forge/created.txt missing (expected present)
- FAIL `review-invoked`: Skill called 0x (expected 1..∞)
- pass `route-upgrade`: Read called 1x (expected 1..∞)
- FAIL `tests-run`: Bash called 0x (expected 1..∞)

