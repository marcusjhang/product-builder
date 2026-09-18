# Eval run

claude 2.1.277 · 426s · est. $8.95 · partial: True interrupted

Cases passed 0/7 · overall 0.20238095238095236 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| leaf-how | 0.5 |  | 1 |  | explorers, shape |
| leaf-personas | 0.3333333333333333 |  | 1 |  | five-second, limitation, paper-said, priya-or-edge |
| leaf-plain | 0 |  | 1 |  | plain, shorter |
| leaf-pm | 0 |  | 1 |  | buckets, scope-question, seat-analyst, seat-customer, seat-designer, seat-pm, seat-skeptic |
| leaf-prototype | 0.25 |  | 1 | interrupted | decision-recorded, recommendation, switcher |
| leaf-reflect | 0.3333333333333333 |  | 1 | interrupted | nothing-applied-without-approval, table |
| leaf-research | 0 |  | 1 | interrupted | anchors-at-sha, census, explorers, research-written |

## Per-run detail

### leaf-how run 1: score 0.5 · 4 turns · 165s · $1.94 · error: None
- pass `anchors`: matched src/\w+\.js:\d+
- FAIL `explorers`: grader threw: Invalid regular expression: unrecognized character after (?
- pass `no-change`: src/** absent as expected
- FAIL `shape`: grader threw: Invalid regular expression: unrecognized character after (?

### leaf-personas run 1: score 0.3333333333333333 · 30 turns · 380s · $2.21 · error: None
- pass `devin`: Agent called 3x (expected 1..∞)
- FAIL `five-second`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `limitation`: grader threw: Invalid regular expression: unrecognized character after (?
- pass `mara`: Agent called 1x (expected 1..∞)
- FAIL `paper-said`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `priya-or-edge`: grader threw: Invalid regular expression: unrecognized character after (?

### leaf-plain run 1: score 0 · 1 turns · 21s · $0.16 · error: None
- FAIL `plain`: judge votes: FAIL FAIL FAIL
- FAIL `shorter`: pattern not found in last_message

### leaf-pm run 1: score 0 · 9 turns · 321s · $3.16 · error: None
- FAIL `buckets`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `scope-question`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `seat-analyst`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `seat-customer`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `seat-designer`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `seat-pm`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `seat-skeptic`: grader threw: Invalid regular expression: unrecognized character after (?

### leaf-prototype run 1: score 0.25 · 17 turns · 261s · $0.88 · error: interrupted
- FAIL `decision-recorded`: grader threw: The operation was aborted.
- pass `html-written`: docs/plans/keyboard-archive/prototype/index.html exists as expected
- FAIL `recommendation`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `switcher`: grader threw: The operation was aborted.

### leaf-reflect run 1: score 0.3333333333333333 · 5 turns · 84s · $0.32 · error: interrupted
- pass `no-suite-edit`: Edit called 0x (expected 0..0)
- FAIL `nothing-applied-without-approval`: grader threw: Invalid regular expression: unrecognized character after (?
- FAIL `table`: grader threw: Invalid regular expression: unrecognized character after (?

### leaf-research run 1: score 0 · 4 turns · 46s · $0.28 · error: interrupted
- FAIL `anchors-at-sha`: grader threw: The operation was aborted.
- FAIL `census`: grader threw: The operation was aborted.
- FAIL `explorers`: Agent called 0x (expected 1..∞)
- FAIL `research-written`: grader threw: The operation was aborted.

