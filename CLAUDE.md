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
