# Working in this repository

This is the product-builder suite: a Claude Code plugin (`.claude-plugin/`, `hooks/`, `skills/`), its evals (`evals/`), and its records (`docs/`). Read `README.md` first and `docs/PLAN.md` when a design question comes up.

## The structure board

The wiring of the suite (entry hooks, the mode, every playbook, every leaf skill, every subagent cast, the scripts and the judge, the per-repo state, the evals) is drawn on an Excalidraw board:

- Scene: `Z07dYjHJBO` in the Excalidraw+ workspace, `https://app.excalidraw.com/s/919s34P0y0E/Z07dYjHJBO`
- Edited through the `excalidraw-plus` MCP server: `read_diagram_format` once per session, then `edit_scene_content` for label or edge changes, or `create_diagram` with `clearExisting: true` to redraw it; `take_screenshot` to check the result.

Update the board in the same change whenever the structure moves: a playbook or leaf skill added, renamed, or removed; a seat added to a cast; a script or hook added; a state file added under `.product-builder/` or `docs/plans/<slug>/`; the evals layout changed. A wording change inside a file does not need it. If the MCP server is not available in the session, say so in the reply and leave a line under the CHANGELOG's Unreleased entry naming what the board is missing, so the next session with access catches up.

## Rules that apply to every change here

- Prose follows `skills/product-builder/references/writing.md`: no em or en dashes, sentence case, colons only before a list. `skills/product-builder/scripts/check --plugin-validate` must pass before a commit; it lints frontmatter, paths under both install shapes, cross-references, dashes, JSON, hooks, and the plugin manifest.
- Changes that alter behaviour get a paragraph under `## Unreleased` in `CHANGELOG.md` and, when they add or change a behaviour worth testing, a case under `evals/` (generated from `evals/tools-gen-cases.py`; run `evals/run.sh --case <name> --ablation none`) and a spec under `evals/specs/`.
- Lessons from field runs go to `docs/journal.md`, and eval-loop work to `docs/eval-log.md`. Neither names the repository, product, people, or files a run came from; the lesson is what gets written.
- Findings from an eval are verified against the run's trace before the suite changes; a grader can be wrong. The loop is: run, verify each failure, fix the suite or the grader, `check`, commit, push, rerun.
- Claude Code is the only harness supported. Do not add fallbacks for other harnesses.

## Open loop: finish the eval pass (todo for the next session)

The eval loop in `docs/eval-log.md` was stopped on 2026-09-19 before its closing condition. What remains, in order:

1. Rerun the four cases whose fixes (F11, F12, F13 and the `source=page` fixture change) are not yet re-verified: `evals/run.sh --tag retest1 --ablation none -j 4` (the tag is set on `playbook-bug-fix`, `playbook-ship`, `playbook-plan-feature`, `playbook-qa`). Roughly an hour and $50 at list price; the account's monthly spend limit stopped two earlier attempts, so check the limit first with `evals/run.sh --case leaf-plain --ablation none` (20 s).
2. For each failed grader, read the trace (`evals/trace-summary.py <aggregate-result.json> --full`) before changing anything; a grader can be wrong. Fix the suite or the grader, `scripts/check --plugin-validate`, commit, push, rerun until the four are clean. Log every step in `docs/eval-log.md` under a new dated heading.
3. Closing pass: `evals/run.sh --ablation none --runs 2 -j 4` over the whole set (54 cases; several hours and several hundred dollars at list price, so confirm the budget with the user first). The loop is done when every case scores 1.0 and no finding is open.
4. Update the board (scene `Z07dYjHJBO`) if the structure moved, and remove this section.
