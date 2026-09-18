# Eval run

claude 2.1.277 · 4119s · est. $103.79 · partial: False 

Cases passed 12/15 · overall 0.9504761904761904 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| playbook-decision-record | 0.8 |  | 1 |  | consequences |
| playbook-dependency-upgrade | 0.8571428571428571 |  | 1 |  | changelog-read |
| playbook-flaky-test | 1 |  | 1 |  |  |
| playbook-incident | 1 |  | 1 |  |  |
| playbook-intake-ships | 1 |  | 1 |  |  |
| playbook-investigation | 1 |  | 1 |  |  |
| playbook-opening-a-pr | 0.6 |  | 1 | exit 1: Reached maximum number of turns (80) | body-sections, pr-created |
| playbook-pause | 1 |  | 1 |  |  |
| playbook-perf-issue | 1 |  | 1 |  |  |
| playbook-pickup | 1 |  | 1 | exit 1: Reached maximum number of turns (120) |  |
| playbook-refactoring | 1 |  | 1 |  |  |
| playbook-release | 1 |  | 1 |  |  |
| playbook-removal | 1 |  | 1 |  |  |
| playbook-revise | 1 |  | 1 |  |  |
| playbook-spike | 1 |  | 1 |  |  |

## Per-run detail

### playbook-decision-record run 1: score 0.8 · 51 turns · 425s · $2.27 · error: None
- pass `adr-written`: docs/adr/0002-*.md exists as expected
- FAIL `consequences`: grader threw: case "playbook-decision-record" grader focus file "docs/adr/0002-*.md": path "docs/adr/0002-*.md" does not exist
- pass `review-skipped`: matched skip: prose|skipped
- pass `route-adr`: Read called 1x (expected 1..∞)
- pass `why-invoked`: Skill called 1x (expected 1..∞)

### playbook-dependency-upgrade run 1: score 0.8571428571428571 · 95 turns · 1053s · $9.33 · error: None
- FAIL `changelog-read`: Read called 0x (expected 1..∞)
- pass `compat-seat`: Agent called 2x (expected 1..∞)
- pass `consumer-fixed`: matched add\(|\{ pattern
- pass `pr-created`: .forge/created.txt exists as expected
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-upgrade`: Read called 1x (expected 1..∞)
- pass `tests-run`: Bash called 26x (expected 1..∞)

### playbook-flaky-test run 1: score 1 · 72 turns · 766s · $4.63 · error: None
- pass `cause-fixed`: judge votes: PASS PASS PASS
- pass `no-retry-hack`: pattern absent as expected
- pass `quantified`: Bash called 35x (expected 5..∞)
- pass `rate-reported`: matched \d+ ?/ ?\d+|\d+ ?%|rate
- pass `route-flaky`: Read called 1x (expected 1..∞)

### playbook-incident run 1: score 1 · 72 turns · 1133s · $8.81 · error: None
- pass `declares`: matched since|affected
- pass `evidence-preserved`: docs/plans/*/evidence/* exists as expected
- pass `mitigate-first`: judge votes: PASS PASS PASS
- pass `postmortem`: docs/plans/*/postmortem.md exists as expected
- pass `root-cause`: matched src/tasks\.js
- pass `route-incident`: Read called 1x (expected 1..∞)

### playbook-intake-ships run 1: score 1 · 11 turns · 54s · $0.55 · error: None
- pass `behind-count`: matched \b7\b.*behind|behind.*\b7\b
- pass `no-plan-folder`: docs/plans/** absent as expected
- pass `one-question`: matched nothing to do
- pass `reads-origin`: Bash called 3x (expected 1..∞)
- pass `says-ships`: matched already ships|ships on origin|shipped

### playbook-investigation run 1: score 1 · 19 turns · 186s · $1.51 · error: None
- pass `anchors-present`: matched src/(tasks|server)\.js:\d+
- pass `answer`: judge votes: PASS PASS PASS
- pass `how-skill-invoked`: Skill called 1x (expected 1..∞)
- pass `no-change-made`: src/** absent as expected
- pass `route-investigation`: Read called 1x (expected 1..∞)

### playbook-opening-a-pr run 1: score 0.6 · 81 turns · 1164s · $11.67 · error: exit 1: Reached maximum number of turns (80)
- FAIL `body-sections`: pattern not found in last_message
- pass `checks-run`: Bash called 22x (expected 1..∞)
- pass `no-force-push`: Bash called 0x (expected 0..0)
- FAIL `pr-created`: .forge/created.txt missing (expected present)
- pass `route-opening`: Read called 1x (expected 1..∞)

### playbook-pause run 1: score 1 · 26 turns · 138s · $1.01 · error: None
- pass `capsule`: matched next move
- pass `handoff-written`: docs/plans/keyboard-archive/handoff.md exists as expected
- pass `route-pause`: Read called 1x (expected 1..∞)
- pass `wip-saved`: Bash called 2x (expected 1..∞)

### playbook-perf-issue run 1: score 1 · 128 turns · 1595s · $14.84 · error: None
- pass `baseline-number`: matched \d+ ?ms
- pass `bench-twice`: Bash called 36x (expected 2..∞)
- pass `one-change`: matched Set|Map
- pass `pr-created`: .forge/created.txt exists as expected
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-perf`: Read called 1x (expected 1..∞)

### playbook-pickup run 1: score 1 · 121 turns · 1773s · $17.22 · error: exit 1: Reached maximum number of turns (120)
- pass `capsule`: matched next move|capsule
- pass `claims-row`: matched \| P1 \|
- pass `on-slice-branch`: matched p1-archive-button
- pass `resume-invoked`: Skill called 1x (expected 1..∞)
- pass `route-pickup`: Read called 1x (expected 1..∞)

### playbook-refactoring run 1: score 1 · 134 turns · 1537s · $14.45 · error: None
- pass `characterise`: matched characteris
- pass `class-exists`: matched class Store
- pass `pr-created`: .forge/created.txt exists as expected
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-refactoring`: Read called 1x (expected 1..∞)
- pass `tests-run`: Bash called 49x (expected 2..∞)

### playbook-release run 1: score 1 · 47 turns · 316s · $2.28 · error: None
- pass `breaking-noted`: matched breaking|archived
- pass `changelog-entry`: matched ## (0\.2\.0|1\.0\.0)
- pass `commands-shown`: matched git tag
- pass `route-release`: Read called 1x (expected 1..∞)
- pass `tag-shown-not-run`: Bash called 0x (expected 0..0)

### playbook-removal run 1: score 1 · 26 turns · 1016s · $9.75 · error: None
- pass `cli-clean`: pattern absent as expected
- pass `deleted`: pattern absent as expected
- pass `inventory-searches`: Bash called 45x (expected 1..∞)
- pass `measured-or-said`: judge votes: PASS PASS PASS
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-removal`: Read called 1x (expected 1..∞)
- pass `why-invoked`: Skill called 1x (expected 1..∞)

### playbook-revise run 1: score 1 · 70 turns · 653s · $4.33 · error: None
- pass `revision-log`: matched revision log[\s\S]*two PRs|re-slice|reslice
- pass `route-revise`: Read called 1x (expected 1..∞)
- pass `superseded`: judge votes: PASS PASS PASS — note: long file (11319 chars); llm judges are noisy on long inputs, prefer a regex grader for large artifacts
- pass `techlead-invoked`: Skill called 1x (expected 1..∞)
- pass `two-slices`: matched ### P2\.

### playbook-spike run 1: score 1 · 31 turns · 180s · $1.13 · error: None
- pass `not-merged`: Bash called 0x (expected 0..0)
- pass `probe-run`: Bash called 1x (expected 1..∞)
- pass `route-spike`: Read called 1x (expected 1..∞)
- pass `verdict`: matched verdict|\byes\b|\bno\b|unknown
- pass `written`: docs/spikes/*.md exists as expected

