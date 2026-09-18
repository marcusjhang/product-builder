# Eval log

Everything done to pressure-test the suite, in order, with what was found and what changed. Newest entries at the bottom. Results that back an entry live under `docs/evals/runs/<timestamp>/` (the aggregate JSON and a summary); the raw HTML reports stay local under `evals/results/`, which is gitignored.

## 2026-09-19 · Plan of record

**Goal.** Every playbook (24) exercised at least once; every member of the team (13 leaf skills; every review, tech-lead, and product-panel seat; personas; explorers; architects; implementer subagents; the verifier; the six judge gates) cast at least once and observed in a transcript; results saved and reusable; findings verified against the transcript before any change to the suite; fix, push, rerun until the set is clean.

**Harness.** `claude plugin eval` (Claude Code 2.1.276), the native plugin eval runner. Each case is a directory under `evals/` with `prompt.md` (the user's message plus run limits), `case.yaml` (a `scaffold_script` that builds the workspace), and `graders/*.md`. A run is a fresh headless session with only this plugin loaded, in an empty workspace the scaffold fills; Bash runs under the OS sandbox with writes confined to the workspace and no network. Graders read the final message, the trace, or a file the run wrote.

**Why this and not subagents reading the skill from files.** Three field runs showed the suite degraded when read from files: no hooks, no routing, no `${CLAUDE_SKILL_DIR}`. The native runner loads the plugin the way a user's install does, so the hooks fire and the skills are invoked by name.

**Fixtures.** Runs have no network, so every fixture repo carries a local bare `origin` remote and an `origin/main` ref, which makes the mode's baseline rule (`git fetch origin --prune`) work offline. Two fixture families:
- `taskbox`, a small JavaScript app with `node:test`, no dependencies, built by `evals/fixtures/lib.sh` in layers that each scenario turns on: a feature-flag helper, an analytics helper, ADRs and a glossary, a migrations directory, a test that reads a source file by path, a flaky test, a feature already shipped on `origin/main` behind a flag, a bug with a failing test, a slow path, a vendored dependency with a changelog of breaking changes, dead code behind a legacy flag, a thin module, tags and a changelog, plan folders at each status, a finished branch with no plan, a `<slug>/p2-` branch, an error log with a spike.
- `calcom`, a shallow clone of calcom/cal.com at a pinned SHA with a local bare origin and the suite's example profile, no dependencies installed: the mature-repo cases (setup, investigation, Bounded plan, Built first on a real PR, review on a real PR).

**Simulated user.** Runs never stop to ask, so the question tool is absent and the mode's text fallback applies. Gate cases end at the question and grade the question. Flow cases put the mode's session override in the prompt ("you decide; ok to every recommended answer; run until <gate>"), which the Autonomy section already defines: the run continues on recommendations and records ASSUMED rows.

**Judge.** The runner passes only `EVAL_*` and provider variables into a run, so `TYPESAFE_API_KEY` does not reach the judge script inside a case. The judge is exercised live in Tier 0 (a real call from this shell) and its no-key and `Model: none` degradation paths inside cases.

**Tiers.**
- Tier 0, structural, free: `scripts/check` (frontmatter, paths under both installs, cross-references, dashes, JSON, `claude plugin validate --strict`, judge self-test and one live call).
- Tier 1, routing and gates, cheap: fixture states × short prompts, graded from the first reply.
- Tier 2, playbooks and team, the bulk: one case per playbook, one per leaf skill run alone, one per seat family, flow cases with the session override, `runs: 1`, `--ablation none`, concurrency 4.
- Tier 3, mature repo: the calcom cases, plus two-arm runs on the cases with an objective outcome (bug-fix against a real fix) to measure Δ.

**Scoring rule for the loop.** A grader failure is a finding, not a verdict. Each is checked against the trace before anything changes: a wrong grader is fixed as a grader; a wrong suite behaviour is fixed in the suite with the transcript line quoted here; a run error (turn cap, timeout, sandbox) is a harness finding. The set is clean when every case scores 1.0 with `runs: 2` and no finding is open.

## 2026-09-19 · Harness bring-up

- `claude plugin eval` refuses to start a Bash-granting run when the real home holds a credential store it cannot exclude. On this machine two did: `GOOGLE_APPLICATION_CREDENTIALS` pointed at a file that is not valid JSON, and Docker Desktop's `~/.docker/cli-plugins` holds symlinks. `evals/run.sh` runs the suite under a clean `HOME` that links only `.claude`, `.claude.json`, and `Library` (the login keychain), and unsets the credentials variable. Nothing on the machine was changed.
- Inside the sandbox `/usr/bin/git` (the xcrun shim) fails on every call because xcrun wants a cache under `/var/folders` that the sandbox denies. The first traced run showed the session reading `.git/HEAD` by hand as a workaround. `run.sh` puts a wrapper for the Command Line Tools git first on `PATH`; a symlink was not enough because git resolves its template directory from the link's location.
- Fixture defects found by the fixture's own self-test before any case ran: `node --test tests/` does not recurse a directory (glob needed); `scripts/check.js` imported `cli.js` and ran it; the store path was resolved at import time so tests wrote to the real store; the routes contract test broke as soon as a route layer was added (README line now derived from `ROUTES`); the flaky test was not flaky but deterministic (now concurrent tests over one shared store, about one failure in two).
- Grading facts from the first traced run (`playbook-investigation`, 160 s, about $1): a `/product-builder …` prompt is expanded by Claude Code, so no `Skill` tool call marks the mode; the mode reads `principles.md`, the matched `playbooks/<name>.md`, and `writing.md`, so the route is graded as a `Read` of the playbook file. Leaf skills the mode invokes should appear as `Skill` calls; in that run there were none.
- Case set: 51 cases, 276 graders, generated by `evals/tools-gen-cases.py` from one table: 26 playbook cases (every playbook, plus pause and program), 13 leaf-skill cases, 7 routing and gate cases, 2 judge cases, 3 cal.com cases. Team coverage is asserted per seat with `tool_used: Agent` graders matched on the seat's name in the subagent prompt.

### Findings so far (verified against the trace before anything changes)

- F1 `playbook-investigation`: the investigation playbook says "Route through the product-builder-how skill"; the run read the playbook, then did the reading itself: no `Skill` call, no `Agent` call, no read of `product-builder-how/SKILL.md`. The answer was correct and anchored. Open: decide whether a one-module question may skip the how skill, or whether the playbook must say "invoke it with the Skill tool".
- F2 `leaf-plain`: the restatement turned "the probe returned partial" into "I only got part of the picture" (a wrong meaning), came out longer than the original, and used two em dashes against the writing rules. The plain skill is seven lines and says "shorter, no jargon"; it does not say "keep every fact's meaning; when a term is ambiguous keep it in quotes", nor does it point at the writing rules.
