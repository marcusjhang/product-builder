# Eval run

claude 2.1.277 · 977s · est. $15.84 · partial: False 

Cases passed 8/11 · overall 0.8484848484848485 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| gate-judge-no-key | 1 |  | 1 |  |  |
| gate-judge-none | 1 |  | 1 |  |  |
| gate-one-question-default | 0.5 |  | 1 |  | ends-with-one-question, twelve-lines |
| leaf-plain | 0.5 |  | 1 |  | plain |
| playbook-intake-ships | 1 |  | 1 |  |  |
| route-by-state | 1 |  | 1 |  |  |
| route-continue-no-args | 1 |  | 1 |  |  |
| route-explicit-prefix | 1 |  | 1 |  |  |
| route-no-profile | 1 |  | 1 |  |  |
| route-state-vs-words | 0.3333333333333333 |  | 1 |  | both-routes, state-recommended |
| route-trivial | 1 |  | 1 |  |  |

## Per-run detail

### gate-judge-no-key run 1: score 1 · 13 turns · 134s · $0.94 · error: None
- pass `no-crash`: pattern absent as expected
- pass `says-no-key`: matched no key|not set|judged by you|session model

### gate-judge-none run 1: score 1 · 13 turns · 164s · $0.99 · error: None
- pass `judged-by-you`: matched judge
- pass `no-judge-call`: Bash called 0x (expected 0..0)

### gate-one-question-default run 1: score 0.5 · 27 turns · 174s · $1.18 · error: None
- FAIL `ends-with-one-question`: pattern not found in last_message
- pass `explored-first`: Bash called 5x (expected 1..∞)
- pass `not-two-questions`: pattern absent as expected
- FAIL `twelve-lines`: judge votes: FAIL PASS FAIL

### leaf-plain run 1: score 0.5 · 3 turns · 47s · $0.25 · error: None
- FAIL `plain`: judge votes: FAIL FAIL FAIL
- pass `shorter`: matched ^(?:(?!provisional|intake probe|Budgets).){0,500}$

### playbook-intake-ships run 1: score 1 · 7 turns · 64s · $0.50 · error: None
- pass `behind-count`: matched \b7\b.*behind|behind.*\b7\b
- pass `no-plan-folder`: docs/plans/** absent as expected
- pass `one-question`: matched nothing to do
- pass `reads-origin`: Bash called 3x (expected 1..∞)
- pass `says-ships`: matched already ships|ships on origin|shipped

### route-by-state run 1: score 1 · 39 turns · 329s · $1.88 · error: None
- pass `route-built-first`: Read called 1x (expected 1..∞)
- pass `route-named-with-facts`: matched built first[\s\S]*(ahead|no plan)
- pass `state-read-first`: Bash called 5x (expected 1..∞)

### route-continue-no-args run 1: score 1 · 18 turns · 96s · $0.72 · error: None
- pass `resume-invoked`: Skill called 1x (expected 1..∞)
- pass `route-pickup`: Read called 1x (expected 1..∞)

### route-explicit-prefix run 1: score 1 · 51 turns · 813s · $6.24 · error: None
- pass `no-other-playbook`: Read called 0x (expected 0..0)
- pass `route-flaky`: Read called 1x (expected 1..∞)

### route-no-profile run 1: score 1 · 21 turns · 251s · $1.34 · error: None
- pass `hook-line`: matched has no \.product-builder/profile\.md
- pass `setup-first`: matched product-builder-setup|setup
- pass `setup-invoked`: Skill called 1x (expected 1..∞)

### route-state-vs-words run 1: score 0.3333333333333333 · 22 turns · 150s · $0.95 · error: None
- FAIL `both-routes`: pattern not found in last_message
- pass `one-question`: matched Q1|Recommended:
- FAIL `state-recommended`: pattern not found in last_message

### route-trivial run 1: score 1 · 20 turns · 106s · $0.83 · error: None
- pass `changed`: matched Taskbox Pro
- pass `no-plan-folder`: docs/plans/** absent as expected
- pass `trivial-said`: matched trivial
- pass `verified`: Bash called 12x (expected 1..∞)

