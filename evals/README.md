# Evals

The suite is pressure-tested with `claude plugin eval`, Claude Code's native plugin eval runner. Each case runs the plugin in a fresh headless session inside a workspace a scaffold builds, then grades the transcript and the files.

## Run

```
evals/run.sh --tag tier1 --ablation none -j 4          # routing and gates, minutes
evals/run.sh --tag playbook --ablation none -j 4       # every playbook
evals/run.sh --tag leaf --ablation none -j 4           # every leaf skill alone, every seat
evals/run.sh --tag calcom --ablation none -j 2         # the mature repo (cal.com)
evals/run.sh --case playbook-bug-fix                    # one case, with the no-plugin baseline arm
```

`run.sh` wraps `claude plugin eval . --scaffold --trust-plugin --allow-tools Bash Write Edit --keep-temp` and runs it under a clean `HOME` that links only `.claude`, `.claude.json`, and `Library`, with a real `git` first on `PATH` and `GOOGLE_APPLICATION_CREDENTIALS` unset. The sandbox refuses to start otherwise on a machine whose home holds a credential store it cannot exclude, and `/usr/bin/git` is an xcrun shim that fails inside the sandbox. Every run saves `aggregate-result.json`, `run.log`, and `summary.md` under `docs/evals/runs/<timestamp>/`; the HTML report stays under `evals/results/` (gitignored). Kept run directories under `/private/tmp/e-*` hold the trace at `out/trace.jsonl` (`chmod 700` the directory to read it).

## Layout

```
evals/
  README.md                 this file
  run.sh                    the runner wrapper
  summarize.py              aggregate-result.json to summary.md
  tools-gen-cases.py        the case table; regenerates every case directory
  fixtures/lib.sh           builds the taskbox app and its scenario layers; clones cal.com from a cache
  specs/*.json              behaviour specs in the skill-creator shape (prompt plus expected behaviour), the source for cases
  <case>/                   case.yaml (limits, scaffold), prompt.md (the user's message), scaffold.sh, graders/*.md
  results/                  runner output, gitignored
```

## Tiers and tags

| Tag | What | Cost |
|---|---|---|
| `tier1` | routing by state and by prefix, one question with a default, the judge's degradation paths, plain | minutes, cents |
| `tier2` `playbook` | one case per playbook, with the session override so a flow runs to its gate without a human | up to an hour each |
| `tier2` `leaf` | each leaf skill invoked alone; the seat cases assert every review, tech-lead, and product-panel seat by name in the subagent prompts | minutes to an hour |
| `team` | cases whose graders assert casts | |
| `tier3` `calcom` | setup, investigation, and a Bounded plan against calcom/cal.com at a pinned SHA, no dependencies installed | up to an hour each |

## How a case grades

- The route: a `tool_used: Read` grader on `playbooks/<name>.md`, because the mode reads the matched playbook file. A `/product-builder …` prompt is expanded by Claude Code, so there is no `Skill` call to grade for the mode itself.
- A leaf skill the mode calls: `tool_used: Skill` with `input_match` on the skill name.
- A seat: `tool_used: Agent` with `input_match` on the seat's name in the subagent prompt.
- The result: `file_exists`, a `regex` over a produced file or the final message, or an `llm` rubric with PASS and FAIL conditions.
- "Never": `tool_used` with `min: 0, max: 0` (no `git tag`, no `pr merge`, no flag flip).

## Fixtures

`taskbox` is a small JavaScript app (tasks, a CLI, an HTTP API, a page) with `node:test`, no dependencies, and a local bare `origin` so the mode's baseline rule works with no network. `tb_base` builds it; `tb_profile` adds a finished `.product-builder/` and an offline `bin/gh`; each `tb_layer_*` adds one scenario's signal (a shipped feature behind a flag, a bug with a failing test, a path-reading test, a flaky test, a slow path, a vendored dependency with a v2, dead code behind a flag, a thin module, release commits, an incident log, a finished branch, a plan folder at a status, a slice branch, an open PR, a branch touching every review seat's signal, a plan touching every tech-lead seat's signal). `SKIP_SELFTEST=1` skips the fixture's own test run.

`calcom_base` clones calcom/cal.com from `~/.pb-eval-cache/calcom` (a shallow clone made on first use) into the workspace with a local bare origin; `calcom_profile` adds the suite's example profile.

## Adding a case

Add a row to `CASES` in `tools-gen-cases.py`, run it, run the case once with `--ablation none`, read the trace before trusting a grader, and log the outcome in `docs/eval-log.md`. A finding is a suite defect only after the trace shows it; a grader can be wrong.
