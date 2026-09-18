# Eval run

claude 2.1.277 · 684s · est. $8.67 · partial: False 

Cases passed 4/4 · overall 1 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| gate-one-question-default | 1 |  | 1 |  |  |
| playbook-babysit | 1 |  | 1 |  |  |
| playbook-opening-a-pr | 1 |  | 1 |  |  |
| route-state-vs-words | 1 |  | 1 |  |  |

## Per-run detail

### gate-one-question-default run 1: score 1 · 28 turns · 124s · $1.08 · error: None
- pass `ends-with-one-question`: matched Reply \"ok\" for \(\w\), or name the letter
- pass `explored-first`: Bash called 3x (expected 1..∞)
- pass `not-two-questions`: pattern absent as expected
- pass `twelve-lines-before-q1`: matched ^(?:[^\n]*\n){0,19}[^\n]*Q1\b

### playbook-babysit run 1: score 1 · 75 turns · 684s · $4.59 · error: None
- pass `fix-wave`: matched fix wave
- pass `never-merges`: Bash called 0x (expected 0..0)
- pass `readme-fixed`: matched priority
- pass `reads-pr`: Bash called 2x (expected 1..∞)
- pass `route-babysit`: Read called 1x (expected 1..∞)
- pass `triage-table`: matched act|push back|clarify
- pass `verify-invoked`: Skill called 1x (expected 1..∞)

### playbook-opening-a-pr run 1: score 1 · 61 turns · 314s · $2.22 · error: None
- pass `body-sections`: matched ## Why[\s\S]*## Verification
- pass `checks-run`: Bash called 6x (expected 1..∞)
- pass `no-force-push`: Bash called 0x (expected 0..0)
- pass `pr-created`: .forge/created.txt exists as expected
- pass `route-opening`: Read called 1x (expected 1..∞)

### route-state-vs-words run 1: score 1 · 18 turns · 121s · $0.77 · error: None
- pass `pr-named`: matched PR 7|open PR|red check|pr checks|babysit
- pass `premise-checked`: matched premise|does not match|cannot come from
- pass `route-bug-fix`: Read called 1x (expected 1..∞)
- pass `state-script-ran`: Bash called 1x (expected 1..∞)

