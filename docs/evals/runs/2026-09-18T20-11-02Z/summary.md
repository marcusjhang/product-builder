# Eval run

claude 2.1.277 · 523s · est. $11.76 · partial: False 

Cases passed 1/5 · overall 0.5728571428571428 · mean delta None

| Case | Score | Delta | Runs | Errors | Failed graders |
|---|---|---|---|---|---|
| calcom-built-first | 0.7142857142857143 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | dor-printed, techlead-invoked |
| calcom-investigation | 1 |  | 1 |  |  |
| calcom-plan-bounded | 0.75 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | dor-or-stop |
| calcom-review | 0.4 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | by-signal-seat, findings-block, seats-cast |
| calcom-setup | 0 |  | 1 | exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usa | drive, forge-unknown-honest, profile, stack-detected |

## Per-run detail

### calcom-built-first run 1: score 0.7142857142857143 · 1 turns · 508s · $6.71 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- pass `anchors`: matched (apps|packages)/[\w/.-]+\.tsx?:\d+
- pass `assumed-derived`: matched ASSUMED: derived from the diff
- pass `derived-plan`: docs/plans/*/decisions.md exists as expected
- FAIL `dor-printed`: pattern not found in last_message
- pass `review-invoked`: Skill called 1x (expected 1..∞)
- pass `route-built-first`: Read called 1x (expected 1..∞)
- FAIL `techlead-invoked`: Skill called 0x (expected 1..∞)

### calcom-investigation run 1: score 1 · 22 turns · 338s · $3.92 · error: None
- pass `anchors`: matched (apps|packages)/[\w/.-]+\.tsx?:\d+
- pass `explorers`: Agent called 4x (expected 1..∞)
- pass `how-invoked`: Skill called 1x (expected 1..∞)
- pass `no-change`: apps/** absent as expected
- pass `route-investigation`: Read called 1x (expected 1..∞)

### calcom-plan-bounded run 1: score 0.75 · 33 turns · 156s · $1.13 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- pass `anchors`: matched (apps|packages)/[\w/.-]+\.tsx?:\d+
- FAIL `dor-or-stop`: pattern not found in last_message
- pass `probe-ran`: Bash called 4x (expected 1..∞)
- pass `route-plan`: Read called 1x (expected 1..∞)

### calcom-review run 1: score 0.4 · 1 turns · 14s · $0.00 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- FAIL `by-signal-seat`: Agent called 0x (expected 1..∞)
- FAIL `findings-block`: pattern not found in last_message
- pass `no-edit`: Edit called 0x (expected 0..0)
- FAIL `seats-cast`: Agent called 0x (expected 3..∞)
- pass `verifier`: matched verif

### calcom-setup run 1: score 0 · 1 turns · 15s · $0.00 · error: exit 1: You've hit your monthly spend limit · raise it at claude.ai/settings/usage?from=cc_cli_limit_message · your session limit resets 6:20am (Asia/Singapore)
- FAIL `drive`: .product-builder/drive.md missing (expected present)
- FAIL `forge-unknown-honest`: grader threw: case "calcom-setup" grader focus file ".product-builder/profile.md": path ".product-builder/profile.md" does not exist
- FAIL `profile`: .product-builder/profile.md missing (expected present)
- FAIL `stack-detected`: grader threw: case "calcom-setup" grader focus file ".product-builder/profile.md": path ".product-builder/profile.md" does not exist

