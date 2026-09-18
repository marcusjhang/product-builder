# Eval run

claude 2.1.277 · 2902s · est. $76.13 · partial: False 

Cases passed 9/13 · overall 0.9287545787545788 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| calcom-review | 1 |  | 1 |  |  |
| calcom-setup | 1 |  | 1 |  |  |
| gate-one-question-default | 0.75 |  | 1 |  | twelve-lines-before-q1 |
| leaf-plain | 1 |  | 1 |  |  |
| leaf-research | 1 |  | 1 |  |  |
| leaf-review-all-seats | 1 |  | 1 |  |  |
| leaf-techlead-all-seats | 1 |  | 1 |  |  |
| playbook-babysit | 0.8571428571428571 |  | 1 | timed out after 2400s | triage-table |
| playbook-built-first | 1 |  | 1 |  |  |
| playbook-decision-record | 1 |  | 1 |  |  |
| playbook-dependency-upgrade | 1 |  | 1 |  |  |
| playbook-opening-a-pr | 0.8 |  | 1 |  | body-sections |
| route-state-vs-words | 0.6666666666666666 |  | 1 |  | state-recommended |

## Per-run detail

### calcom-review run 1: score 1 · 52 turns · 711s · $10.78 · error: None
- pass `by-signal-seat`: Agent called 3x (expected 1..∞)
- pass `findings-block`: matched act on|consider|noted|dismissed
- pass `no-edit`: Edit called 0x (expected 0..0)
- pass `seats-cast`: Agent called 3x (expected 3..∞)
- pass `verifier`: matched verif

### calcom-setup run 1: score 1 · 38 turns · 501s · $2.35 · error: None
- pass `drive`: .product-builder/drive.md exists as expected
- pass `forge-unknown-honest`: matched UNKNOWN|fixture|denied
- pass `profile`: .product-builder/profile.md exists as expected
- pass `stack-detected`: matched yarn|turbo|prisma|next

### gate-one-question-default run 1: score 0.75 · 26 turns · 109s · $0.99 · error: None
- pass `ends-with-one-question`: matched Reply \"ok\" for \(\w\), or name the letter
- pass `explored-first`: Bash called 5x (expected 1..∞)
- pass `not-two-questions`: pattern absent as expected
- FAIL `twelve-lines-before-q1`: pattern not found in last_message

### leaf-plain run 1: score 1 · 3 turns · 35s · $0.23 · error: None
- pass `no-jargon`: matched ^(?:(?!provisional|intake probe|Budgets|G1|DoR).){0,800}$
- pass `plain`: judge votes: PASS PASS PASS

### leaf-research run 1: score 1 · 25 turns · 392s · $2.65 · error: None
- pass `anchors-at-sha`: matched src/\w+\.js:\d+
- pass `census`: matched entry point
- pass `explorers`: Agent called 1x (expected 1..∞)
- pass `research-written`: matched current system

### leaf-review-all-seats run 1: score 1 · 33 turns · 872s · $8.23 · error: None
- pass `no-edit`: Edit called 0x (expected 0..0)
- pass `path-read-test-found`: matched routes-contract|README lacks
- pass `prompt-contradiction-found`: matched contradict
- pass `safety-fact`: matched safe because|unproven
- pass `seat-accessibility`: Agent called 1x (expected 1..∞)
- pass `seat-adversarial`: Agent called 1x (expected 1..∞)
- pass `seat-backwards-compat`: Agent called 1x (expected 1..∞)
- pass `seat-cost`: Agent called 2x (expected 1..∞)
- pass `seat-database`: Agent called 15x (expected 1..∞)
- pass `seat-frontend`: Agent called 1x (expected 1..∞)
- pass `seat-integration`: Agent called 1x (expected 1..∞)
- pass `seat-product-owner`: Agent called 1x (expected 1..∞)
- pass `seat-prompt-quality`: Agent called 1x (expected 1..∞)
- pass `seat-qa`: Agent called 1x (expected 1..∞)
- pass `seat-security`: Agent called 1x (expected 1..∞)
- pass `seat-silent-failure`: Agent called 1x (expected 1..∞)
- pass `seat-sre`: Agent called 1x (expected 1..∞)
- pass `seat-staff`: Agent called 1x (expected 1..∞)

### leaf-techlead-all-seats run 1: score 1 · 30 turns · 758s · $6.76 · error: None
- pass `rulings-ledger`: matched ## Review rulings[\s\S]*\| (techlead|tech lead|hawk|security|frontend|database|SRE|integration|cost)
- pass `seat-cost`: Agent called 3x (expected 1..∞)
- pass `seat-database`: Agent called 1x (expected 1..∞)
- pass `seat-frontend`: Agent called 1x (expected 1..∞)
- pass `seat-hawk`: Agent called 1x (expected 1..∞)
- pass `seat-integration`: Agent called 1x (expected 1..∞)
- pass `seat-security`: Agent called 2x (expected 1..∞)
- pass `seat-sre`: Agent called 1x (expected 1..∞)
- pass `seat-techlead`: Agent called 1x (expected 1..∞)
- pass `verifier-pass`: matched verif

### playbook-babysit run 1: score 0.8571428571428571 · 232 turns · 2401s · $12.66 · error: timed out after 2400s
- pass `fix-wave`: matched fix wave
- pass `never-merges`: Bash called 0x (expected 0..0)
- pass `readme-fixed`: matched priority
- pass `reads-pr`: Bash called 2x (expected 1..∞)
- pass `route-babysit`: Read called 1x (expected 1..∞)
- FAIL `triage-table`: pattern not found in last_message
- pass `verify-invoked`: Skill called 1x (expected 1..∞)

### playbook-built-first run 1: score 1 · 100 turns · 925s · $12.08 · error: None
- pass `assumed-derived`: matched ASSUMED: derived from the diff
- pass `derived-plan`: docs/plans/*/decisions.md exists as expected
- pass `dor-printed`: matched Definition of Ready
- pass `pm-invoked`: Skill called 1x (expected 1..∞)
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `round-trip`: matched round.trip|displays|removes
- pass `route-built-first`: Read called 1x (expected 1..∞)
- pass `status-derived`: matched Status:\*?\*? *Derived
- pass `techlead-invoked`: Skill called 1x (expected 1..∞)

### playbook-decision-record run 1: score 1 · 46 turns · 319s · $2.10 · error: None
- pass `adr-written`: docs/adr/0002-*.md exists as expected
- pass `consequences`: matched consequences
- pass `review-skipped`: matched skip: prose|skipped
- pass `route-adr`: Read called 1x (expected 1..∞)
- pass `why-invoked`: Skill called 1x (expected 1..∞)

### playbook-dependency-upgrade run 1: score 1 · 158 turns · 1209s · $14.20 · error: None
- pass `changelog-read`: matched tinydate-v2/CHANGELOG
- pass `compat-seat`: Agent called 1x (expected 1..∞)
- pass `consumer-fixed`: matched add\(|\{ pattern
- pass `pr-created`: .forge/created.txt exists as expected
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-upgrade`: Read called 1x (expected 1..∞)
- pass `tests-run`: Bash called 39x (expected 1..∞)

### playbook-opening-a-pr run 1: score 0.8 · 47 turns · 317s · $2.26 · error: None
- FAIL `body-sections`: pattern not found in last_message
- pass `checks-run`: Bash called 8x (expected 1..∞)
- pass `no-force-push`: Bash called 0x (expected 0..0)
- pass `pr-created`: .forge/created.txt exists as expected
- pass `route-opening`: Read called 1x (expected 1..∞)

### route-state-vs-words run 1: score 0.6666666666666666 · 17 turns · 143s · $0.83 · error: None
- pass `both-routes`: matched bug fix[\s\S]*babysit|babysit[\s\S]*bug fix
- pass `one-question`: matched Q1|Recommended:
- FAIL `state-recommended`: pattern not found in last_message

