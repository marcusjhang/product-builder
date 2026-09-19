# Eval run

claude 2.1.277 · 5897s · est. $145.24 · partial: False 

Cases passed 7/11 · overall 0.8732323232323232 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| calcom-built-first | 1 |  | 1 |  |  |
| calcom-plan-bounded | 1 |  | 1 |  |  |
| playbook-bug-fix | 0.6666666666666666 |  | 1 |  | mechanism-named, pr-created, review-invoked |
| playbook-data-migration | 1 |  | 1 |  |  |
| playbook-implement | 1 |  | 1 |  |  |
| playbook-implement-parallel | 1 |  | 1 |  |  |
| playbook-plan-bounded | 1 |  | 1 |  |  |
| playbook-plan-feature | 0.8888888888888888 |  | 1 |  | personas-invoked |
| playbook-plan-program | 0.8 |  | 1 |  | walking-skeleton |
| playbook-qa | 1 |  | 1 |  |  |
| playbook-ship | 0.25 |  | 1 | exit 1: Reached maximum number of turns (100) | dod-printed, no-flag-flip, user-flips |

## Per-run detail

### calcom-built-first run 1: score 1 · 113 turns · 1135s · $15.00 · error: None
- pass `anchors`: matched (apps|packages)/[\w/.-]+\.tsx?:\d+
- pass `assumed-derived`: matched ASSUMED: derived from the diff
- pass `derived-plan`: docs/plans/*/decisions.md exists as expected
- pass `dor-printed`: matched Definition of Ready
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-built-first`: Read called 1x (expected 1..∞)
- pass `techlead-invoked`: Skill called 1x (expected 1..∞)

### calcom-plan-bounded run 1: score 1 · 102 turns · 1547s · $11.90 · error: None
- pass `anchors`: matched (apps|packages)/[\w/.-]+\.tsx?:\d+
- pass `dor-or-stop`: matched Definition of Ready|already ships|nothing to do
- pass `probe-ran`: Bash called 60x (expected 1..∞)
- pass `route-plan`: Read called 1x (expected 1..∞)

### playbook-bug-fix run 1: score 0.6666666666666666 · 63 turns · 379s · $2.94 · error: None
- FAIL `mechanism-named`: pattern not found in last_message
- pass `no-blanket-catch`: pattern absent as expected
- FAIL `pr-created`: .forge/created.txt missing (expected present)
- pass `repro-first`: Bash@13 precedes Edit@34
- FAIL `review-invoked`: Skill called 0x (expected 1..∞)
- pass `root-cause-fix`: matched archived
- pass `route-bug-fix`: Read called 1x (expected 1..∞)
- pass `scope-held`: judge votes: FAIL PASS PASS
- pass `verify-invoked`: Skill called 1x (expected 1..∞)

### playbook-data-migration run 1: score 1 · 144 turns · 2610s · $26.95 · error: None
- pass `db-seat`: Agent called 2x (expected 1..∞)
- pass `five-steps`: matched expand[\s\S]*backfill[\s\S]*cut ?over[\s\S]*contract
- pass `migration-file`: migrations/003* exists as expected
- pass `replayed`: Bash called 27x (expected 1..∞)
- pass `route-migration`: Read called 1x (expected 1..∞)
- pass `techlead-invoked`: Skill called 1x (expected 1..∞)

### playbook-implement run 1: score 1 · 141 turns · 1772s · $12.92 · error: None
- pass `flags-route`: matched /flags
- pass `ledger-row`: matched \| P1 \|.*keyboard-archive/p1
- pass `pr-created`: .forge/created.txt exists as expected
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-implement`: Read called 1x (expected 1..∞)
- pass `slice-branch`: Bash called 7x (expected 1..∞)
- pass `tests-run`: Bash called 51x (expected 1..∞)
- pass `verify-invoked`: Skill called 1x (expected 1..∞)

### playbook-implement-parallel run 1: score 1 · 14 turns · 1359s · $15.49 · error: None
- pass `implementers-dispatched`: Agent called 4x (expected 2..∞)
- pass `ledger-two-rows`: matched \| P2 \|
- pass `pr-created`: .forge/created.txt exists as expected
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-implement`: Read called 1x (expected 1..∞)
- pass `two-branches`: Bash called 8x (expected 1..∞)

### playbook-plan-bounded run 1: score 1 · 93 turns · 1525s · $9.86 · error: None
- pass `assumed-rows`: matched ASSUMED
- pass `dor-printed`: matched Definition of Ready
- pass `ledger-written`: docs/plans/*/decisions.md exists as expected
- pass `probe-partial`: judge votes: PASS PASS PASS
- pass `research-invoked`: Skill called 1x (expected 1..∞)
- pass `route-plan`: Read called 1x (expected 1..∞)
- pass `size-bounded`: matched Bounded
- pass `techlead-invoked`: Skill called 1x (expected 1..∞)

### playbook-plan-feature run 1: score 0.8888888888888888 · 89 turns · 2990s · $20.60 · error: None
- pass `arena-architects`: Agent called 4x (expected 2..∞)
- pass `dor-printed`: matched Definition of Ready
- FAIL `personas-invoked`: Skill called 0x (expected 1..∞)
- pass `plan-files`: docs/plans/*/implementation.md exists as expected
- pass `pm-invoked`: Skill called 1x (expected 1..∞)
- pass `research-invoked`: Skill called 1x (expected 1..∞)
- pass `route-plan`: Read called 1x (expected 1..∞)
- pass `size-feature`: matched Feature
- pass `techlead-invoked`: Skill called 1x (expected 1..∞)

### playbook-plan-program run 1: score 0.8 · 88 turns · 1310s · $11.05 · error: None
- pass `overview-written`: docs/plans/*/README.md exists as expected
- pass `parts-table`: matched \| *Part|## Parts|parts table
- pass `route-program`: Read called 1x (expected 1..∞)
- pass `size-program`: matched Program
- FAIL `walking-skeleton`: judge votes: FAIL FAIL FAIL

### playbook-qa run 1: score 1 · 105 turns · 737s · $7.60 · error: None
- pass `flag-both-states`: matched flag off
- pass `personas-invoked`: Skill called 1x (expected 1..∞)
- pass `report-written`: docs/plans/keyboard-archive/qa-report.md exists as expected
- pass `route-qa`: Read called 1x (expected 1..∞)
- pass `tests-run`: Bash called 4x (expected 1..∞)
- pass `verdict`: matched verdict
- pass `verify-invoked`: Skill called 1x (expected 1..∞)

### playbook-ship run 1: score 0.25 · 101 turns · 1264s · $10.93 · error: exit 1: Reached maximum number of turns (100)
- FAIL `dod-printed`: pattern not found in last_message
- FAIL `no-flag-flip`: Bash called 5x (expected 0..0)
- pass `route-ship`: Read called 1x (expected 1..∞)
- FAIL `user-flips`: judge votes: FAIL FAIL FAIL

