# Eval run

claude 2.1.277 · 1309s · est. $24.78 · partial: False 

Cases passed 9/13 · overall 0.8517094017094016 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| leaf-how | 1 |  | 1 |  |  |
| leaf-personas | 1 |  | 1 |  |  |
| leaf-plain | 0 |  | 1 |  | plain, shorter |
| leaf-pm | 1 |  | 1 |  |  |
| leaf-prototype | 1 |  | 1 |  |  |
| leaf-reflect | 1 |  | 1 |  |  |
| leaf-research | 0.75 |  | 1 |  | explorers |
| leaf-resume | 1 |  | 1 |  |  |
| leaf-review-all-seats | 0.7222222222222222 |  | 1 |  | seat-accessibility, seat-adversarial, seat-frontend, seat-integration, seat-sre |
| leaf-setup | 1 |  | 1 |  |  |
| leaf-techlead-all-seats | 0.6 |  | 1 |  | seat-database, seat-frontend, seat-integration, seat-sre |
| leaf-verify | 1 |  | 1 |  |  |
| leaf-why | 1 |  | 1 |  |  |

## Per-run detail

### leaf-how run 1: score 1 · 19 turns · 221s · $1.28 · error: None
- pass `anchors`: matched src/\w+\.js:\d+
- pass `explorers`: Agent called 3x (expected 2..∞)
- pass `no-change`: src/** absent as expected
- pass `shape`: matched overview[\s\S]*how it works[\s\S]*where things live

### leaf-personas run 1: score 1 · 38 turns · 388s · $2.47 · error: None
- pass `devin`: Agent called 1x (expected 1..∞)
- pass `five-second`: matched five.second
- pass `limitation`: matched pilot|not a substitute|stereotype
- pass `mara`: Agent called 1x (expected 1..∞)
- pass `paper-said`: matched paper
- pass `priya-or-edge`: Agent called 2x (expected 1..∞)

### leaf-plain run 1: score 0 · 3 turns · 18s · $0.18 · error: None
- FAIL `plain`: judge votes: FAIL FAIL FAIL
- FAIL `shorter`: pattern not found in last_message

### leaf-pm run 1: score 1 · 21 turns · 333s · $2.94 · error: None
- pass `buckets`: matched act on[\s\S]*consider[\s\S]*noted[\s\S]*dismissed
- pass `scope-question`: matched hold scope|wedge
- pass `seat-analyst`: Agent called 1x (expected 1..∞)
- pass `seat-customer`: Agent called 1x (expected 1..∞)
- pass `seat-designer`: Agent called 1x (expected 1..∞)
- pass `seat-pm`: Agent called 1x (expected 1..∞)
- pass `seat-skeptic`: Agent called 2x (expected 1..∞)

### leaf-prototype run 1: score 1 · 21 turns · 250s · $1.25 · error: None
- pass `decision-recorded`: matched prototype
- pass `html-written`: docs/plans/keyboard-archive/prototype/index.html exists as expected
- pass `recommendation`: matched recommend
- pass `switcher`: matched variant|switch

### leaf-reflect run 1: score 1 · 36 turns · 278s · $1.48 · error: None
- pass `no-suite-edit`: Edit called 0x (expected 0..0)
- pass `nothing-applied-without-approval`: matched approv|apply
- pass `table`: matched accepted[\s\S]*rejected[\s\S]*backlog

### leaf-research run 1: score 0.75 · 56 turns · 368s · $2.03 · error: None
- pass `anchors-at-sha`: matched src/\w+\.js:\d+
- pass `census`: matched entry point
- FAIL `explorers`: Agent called 0x (expected 1..∞)
- pass `research-written`: matched current system

### leaf-resume run 1: score 1 · 15 turns · 80s · $0.48 · error: None
- pass `both-plans`: matched keyboard-archive[\s\S]*shared-boards|shared-boards[\s\S]*keyboard-archive
- pass `next-move`: matched next move
- pass `nothing-written`: docs/** absent as expected
- pass `status-tags`: matched implementing|drafted

### leaf-review-all-seats run 1: score 0.7222222222222222 · 31 turns · 429s · $5.69 · error: None
- pass `no-edit`: Edit called 0x (expected 0..0)
- pass `path-read-test-found`: matched routes-contract|README lacks
- pass `prompt-contradiction-found`: matched contradict
- pass `safety-fact`: matched safe because|unproven
- FAIL `seat-accessibility`: Agent called 0x (expected 1..∞)
- FAIL `seat-adversarial`: Agent called 0x (expected 1..∞)
- pass `seat-backwards-compat`: Agent called 1x (expected 1..∞)
- pass `seat-cost`: Agent called 2x (expected 1..∞)
- pass `seat-database`: Agent called 9x (expected 1..∞)
- FAIL `seat-frontend`: Agent called 0x (expected 1..∞)
- FAIL `seat-integration`: Agent called 0x (expected 1..∞)
- pass `seat-product-owner`: Agent called 1x (expected 1..∞)
- pass `seat-prompt-quality`: Agent called 1x (expected 1..∞)
- pass `seat-qa`: Agent called 1x (expected 1..∞)
- pass `seat-security`: Agent called 1x (expected 1..∞)
- pass `seat-silent-failure`: Agent called 1x (expected 1..∞)
- FAIL `seat-sre`: Agent called 0x (expected 1..∞)
- pass `seat-staff`: Agent called 1x (expected 1..∞)

### leaf-setup run 1: score 1 · 26 turns · 356s · $1.61 · error: None
- pass `ci-lane`: matched test-concurrency=1
- pass `drive`: .product-builder/drive.md exists as expected
- pass `first-run-hook`: matched has no \.product-builder/profile\.md
- pass `forge-probed`: Bash called 1x (expected 1..∞)
- pass `models`: .product-builder/models.md exists as expected
- pass `no-unknown-where-answerable`: pattern absent as expected
- pass `personas`: .product-builder/personas.md exists as expected
- pass `profile`: .product-builder/profile.md exists as expected
- pass `test-command-detected`: matched node --test

### leaf-techlead-all-seats run 1: score 0.6 · 8 turns · 552s · $4.13 · error: None
- pass `rulings-ledger`: matched ## Review rulings[\s\S]*\| (techlead|tech lead|hawk|security|frontend|database|SRE|integration|cost)
- pass `seat-cost`: Agent called 2x (expected 1..∞)
- FAIL `seat-database`: Agent called 0x (expected 1..∞)
- FAIL `seat-frontend`: Agent called 0x (expected 1..∞)
- pass `seat-hawk`: Agent called 1x (expected 1..∞)
- FAIL `seat-integration`: Agent called 0x (expected 1..∞)
- pass `seat-security`: Agent called 2x (expected 1..∞)
- FAIL `seat-sre`: Agent called 0x (expected 1..∞)
- pass `seat-techlead`: Agent called 1x (expected 1..∞)
- pass `verifier-pass`: matched verif

### leaf-verify run 1: score 1 · 21 turns · 143s · $0.82 · error: None
- pass `evidence-path`: matched evidence/|exit code|\{
- pass `flag-both-states`: matched flag off[\s\S]*flag on|flag on[\s\S]*flag off
- pass `pass-per-scenario`: matched pass|fail
- pass `real-request`: Bash called 1x (expected 1..∞)
- pass `server-launched`: Bash called 1x (expected 1..∞)

### leaf-why run 1: score 1 · 12 turns · 52s · $0.40 · error: None
- pass `adr-found`: matched ADR 0001|0001-json
- pass `dated`: matched 2026-08-20
- pass `git-history`: Bash called 3x (expected 1..∞)

