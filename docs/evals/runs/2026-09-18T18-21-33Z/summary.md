# Eval run

claude 2.1.277 · 751s · est. $11.56 · partial: False 

Cases passed 2/11 · overall 0.4954545454545455 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| gate-judge-no-key | 0.5 |  | 1 |  | says-no-key |
| gate-judge-none | 0.5 |  | 1 |  | judged-by-you |
| gate-one-question-default | 0.5 |  | 1 |  | ends-with-one-question, twelve-lines |
| leaf-plain | 0 |  | 1 |  | plain, shorter |
| playbook-intake-ships | 0.2 |  | 1 |  | behind-count, no-plan-folder, one-question, says-ships |
| route-by-state | 0.6666666666666666 |  | 1 |  | route-named-with-facts |
| route-continue-no-args | 1 |  | 1 |  |  |
| route-explicit-prefix | 1 |  | 1 | timed out after 600s |  |
| route-no-profile | 0.3333333333333333 |  | 1 |  | setup-first, setup-invoked-or-run |
| route-state-vs-words | 0 |  | 1 |  | both-routes, one-question, state-recommended |
| route-trivial | 0.75 |  | 1 |  | trivial-said |

## Per-run detail

### gate-judge-no-key run 1: score 0.5 · 20 turns · 116s · $0.77 · error: None
- pass `no-crash`: pattern absent as expected
- FAIL `says-no-key`: grader threw: Invalid regular expression: unrecognized character after (?

### gate-judge-none run 1: score 0.5 · 13 turns · 70s · $0.58 · error: None
- FAIL `judged-by-you`: grader threw: Invalid regular expression: unrecognized character after (?
- pass `no-judge-call`: Bash called 0x (expected 0..0)

### gate-one-question-default run 1: score 0.5 · 31 turns · 150s · $1.02 · error: None
- FAIL `ends-with-one-question`: grader threw: Invalid regular expression: unrecognized character after (?
- pass `explored-first`: Bash called 2x (expected 1..∞)
- pass `not-two-questions`: pattern absent as expected
- FAIL `twelve-lines`: judge votes: FAIL FAIL FAIL

### leaf-plain run 1: score 0 · 2 turns · 21s · $0.17 · error: None
- FAIL `plain`: judge votes: FAIL FAIL FAIL
- FAIL `shorter`: pattern not found in last_message

### playbook-intake-ships run 1: score 0.2 · 29 turns · 147s · $1.11 · error: None
- FAIL `behind-count`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `no-plan-folder`: docs/plans/** exists (expected absent)
- FAIL `one-question`: grader threw: Invalid regular expression: unrecognized character after (?
- pass `reads-origin`: Bash called 3x (expected 1..∞)
- FAIL `says-ships`: grader threw: Invalid regular expression: unrecognized character after (?

### route-by-state run 1: score 0.6666666666666666 · 33 turns · 277s · $1.54 · error: None
- pass `route-built-first`: Read called 1x (expected 1..∞)
- FAIL `route-named-with-facts`: grader threw: Invalid regular expression: unrecognized character after (?
- pass `state-read-first`: Bash called 4x (expected 1..∞)

### route-continue-no-args run 1: score 1 · 16 turns · 84s · $0.67 · error: None
- pass `resume-invoked`: Skill called 1x (expected 1..∞)
- pass `route-pickup`: Read called 1x (expected 1..∞)

### route-explicit-prefix run 1: score 1 · 82 turns · 600s · $2.99 · error: timed out after 600s
- pass `no-other-playbook`: Read called 0x (expected 0..0)
- pass `route-flaky`: Read called 1x (expected 1..∞)

### route-no-profile run 1: score 0.3333333333333333 · 22 turns · 216s · $1.15 · error: None
- pass `hook-line`: matched has no \.product-builder/profile\.md
- FAIL `setup-first`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `setup-invoked-or-run`: Read called 0x (expected 1..∞)

### route-state-vs-words run 1: score 0 · 21 turns · 129s · $0.84 · error: None
- FAIL `both-routes`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `one-question`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `state-recommended`: grader threw: Invalid regular expression: unrecognized character after (?

### route-trivial run 1: score 0.75 · 21 turns · 79s · $0.72 · error: None
- pass `changed`: matched Taskbox Pro
- pass `no-plan-folder`: docs/plans/** absent as expected
- FAIL `trivial-said`: grader threw: Invalid regular expression: unrecognized character after (?
- pass `verified`: Bash called 11x (expected 1..∞)

