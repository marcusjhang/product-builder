#!/usr/bin/env python3
"""Generates the eval case directories from the CASES table below. Re-run after editing; it overwrites generated cases only."""
import json, os, re, shutil, sys
from pathlib import Path
EVALS = Path(__file__).resolve().parent
OVERRIDE = ("\n\nSession override: you decide. Take every recommended answer as accepted, record each as ASSUMED in the ledger, "
            "and keep going until {gate}. Never stop to ask; there is no one to answer.")

def nocase(pat):
    """JS regex has no inline (?i): expand every ASCII letter outside a character class to [Aa]."""
    out, i, in_class = [], 0, False
    while i < len(pat):
        ch = pat[i]
        if ch == "\\" and i + 1 < len(pat): out.append(pat[i:i+2]); i += 2; continue
        if ch == "[": in_class = True
        elif ch == "]": in_class = False
        if ch.isalpha() and ch.isascii():
            out.append(f"[{ch.upper()}{ch.lower()}]" if not in_class else ch.upper() + ch.lower())
        else: out.append(ch)
        i += 1
    return "".join(out)

def read_pb(name): return {"type": "tool_used", "tool": "Read", "input_match": f"playbooks/{name}\\.md"}
def skill(name, **kw): return {"type": "tool_used", "tool": "Skill", "input_match": f'"skill"\\s*:\\s*"(?:[\\w-]+:)?product-builder-{name}"', **kw}
def _ci(match):
    return nocase(match.replace("(?i)", "")) if "(?i)" in match else match
def agent(match, mn=1, **kw): return {"type": "tool_used", "tool": "Agent", "input_match": _ci(match), "min": mn, **kw}
def bash(match, mn=1, **kw): return {"type": "tool_used", "tool": "Bash", "input_match": _ci(match), "min": mn, **kw}
def never(tool, match): return {"type": "tool_used", "tool": tool, "input_match": _ci(match), "min": 0, "max": 0}
def _rxkw(pattern, kw):
    if "(?i)" in pattern:
        pattern = pattern.replace("(?i)", ""); kw = {**kw, "flags": kw.get("flags", "") + "i"}
    return pattern, kw
def rx(pattern, target="last_message", **kw):
    pattern, kw = _rxkw(pattern, kw); return {"type": "regex", "pattern": pattern, "target": target, **kw}
def rxfile(path, pattern, **kw):
    pattern, kw = _rxkw(pattern, kw); return {"type": "regex", "pattern": pattern, "target": {"source": "file", "path": path}, **kw}
def exists(path, e=True): return {"type": "file_exists", "path": path, "exists": e}
def llm(criteria, focus=None):
    g = {"type": "llm", "criteria": criteria}
    if focus: g["focus"] = focus
    return g

BASE = "tb_base; tb_profile;"
CASES = [
 # ---------------- playbooks
 dict(name="playbook-investigation", tags=["playbook","tier2","pbA"], scaffold=BASE+" tb_layer_shipped_snooze; tb_origin",
      prompt="/product-builder how does a task get archived, end to end, and what stops an archived task from being completed?",
      turns=60, timeout=900, graders={
        "route-investigation": read_pb("investigation"), "how-skill-invoked": skill("how"),
        "anchors-present": rx(r"src/(tasks|server)\.js:\d+"), "no-change-made": exists("src/**", False),
        "answer": llm("PASS if the reply explains the archive path (POST /tasks/:id/archive in src/server.js gated by the archive flag, calling archive() in src/tasks.js which sets status archived and tracks task_archived) and says plainly that nothing stops an archived task from being completed today (complete() checks no status), with file:line citations. FAIL if it invents a guard that does not exist, proposes or makes a code change, or gives no file:line citations.")}),
 dict(name="playbook-plan-bounded", tags=["playbook","tier2","flow","pbB"], scaffold=BASE+" tb_layer_shipped_snooze; tb_origin",
      prompt="/product-builder plan: add an Archive button to the page for each open task, so people can archive without the CLI"+OVERRIDE.format(gate="the Definition of Ready is printed"),
      turns=200, timeout=3600, graders={
        "route-plan": read_pb("plan"), "research-invoked": skill("research"), "techlead-invoked": skill("techlead"),
        "ledger-written": exists("docs/plans/*/decisions.md"), "dor-printed": rx(r"Definition of Ready"),
        "size-bounded": rx(r"Bounded", "trace"), "assumed-rows": rx(r"ASSUMED", "trace"),
        "probe-partial": llm("PASS if the run's replies say the archive route already exists on the default branch behind the archive flag (the probe verdict partial or a similar statement) and the plan is only the page control. FAIL if the plan re-implements the route or never mentions that it exists.", focus="trace")}),
 dict(name="playbook-plan-feature", tags=["playbook","tier2","flow","team","pbB"], scaffold=BASE+" tb_origin",
      prompt="/product-builder plan: recurring tasks: a task can repeat daily or weekly, the next one appears when the current one is completed, and a weekly digest lists what is due"+OVERRIDE.format(gate="the Definition of Ready is printed"),
      turns=200, timeout=3600, graders={
        "route-plan": read_pb("plan"), "size-feature": rx(r"Feature", "trace"), "research-invoked": skill("research"),
        "arena-architects": agent(r"(?i)architect|minimal change|clean shape|pragmatic", 2), "pm-invoked": skill("pm"),
        "techlead-invoked": skill("techlead"), "personas-invoked": skill("personas"), "dor-printed": rx(r"Definition of Ready"),
        "plan-files": exists("docs/plans/*/implementation.md")}),
 dict(name="playbook-plan-program", tags=["playbook","tier2","flow","pbB"], scaffold=BASE+" tb_origin",
      prompt="/product-builder plan: a team edition: accounts with login, shared boards with members and roles, real-time updates between members, email notifications, and a mobile app"+OVERRIDE.format(gate="the program overview README and its parts table are written and the first part's intake has run"),
      turns=150, timeout=2400, graders={
        "route-program": read_pb("program"), "size-program": rx(r"Program", "trace"),
        "overview-written": exists("docs/plans/*/README.md"), "parts-table": rx(r"(?i)\| *Part|## Parts|parts table", "trace"),
        "walking-skeleton": llm("PASS if the program overview written during the run names part 1 as a shippable user-facing increment that is the walking skeleton and orders parts by risk then value. FAIL if parts are layers (database, backend, frontend) rather than user-facing increments.", focus="trace")}),
 dict(name="playbook-intake-ships", tags=["playbook","tier1","gate","pbA"], scaffold=BASE+" tb_layer_shipped_snooze; tb_layer_pad_commits 6; tb_origin; tb_behind 7",
      prompt="/product-builder plan: add a snooze endpoint, POST /tasks/:id/snooze with an until date, behind a flag",
      turns=40, timeout=900, graders={
        "no-plan-folder": exists("docs/plans/**", False), "says-ships": rx(r"(?i)already ships|ships on origin|shipped"),
        "one-question": rx(r"(?i)nothing to do"), "behind-count": rx(r"(?i)\b7\b.*behind|behind.*\b7\b", "trace"),
        "reads-origin": bash(r"origin/main")}),
 dict(name="playbook-revise", tags=["playbook","tier2","flow","pbA"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_origin",
      prompt="/product-builder revise keyboard-archive: I want this as two PRs, the flags route first and the page button second"+OVERRIDE.format(gate="the revision-log row is written"),
      turns=120, timeout=2400, graders={
        "route-revise": read_pb("revise"), "techlead-invoked": skill("techlead"),
        "revision-log": rxfile("docs/plans/keyboard-archive/decisions.md", r"(?i)revision log[\s\S]*two PRs|re-slice|reslice"),
        "two-slices": rxfile("docs/plans/keyboard-archive/implementation.md", r"### P2\."),
        "superseded": llm("PASS if the ledger shows the re-slice as a revision with the tech lead run on the new boundaries and no decision row rewritten in place. FAIL if the plan was edited with no revision-log row.", focus={"source":"file","path":"docs/plans/keyboard-archive/decisions.md"})}),
 dict(name="playbook-implement", tags=["playbook","tier2","flow","team","pbB"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_layer_pathread_test; tb_origin",
      prompt="/product-builder go: build keyboard-archive"+OVERRIDE.format(gate="the PR is opened with bin/gh and its URL is in the reply"),
      turns=200, timeout=3600, graders={
        "route-implement": read_pb("implement"), "slice-branch": bash(r"keyboard-archive/p1"),
        "tests-run": bash(r"node --test"), "review-invoked": skill("review"), "verify-invoked": skill("verify"),
        "pr-created": exists(".forge/created.txt"), "ledger-row": rxfile("docs/plans/keyboard-archive/decisions.md", r"\| P1 \|.*keyboard-archive/p1"),
        "flags-route": rxfile("src/server.js", r"/flags")}),
 dict(name="playbook-implement-parallel", tags=["playbook","tier2","flow","team","pbB"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_layer_plan_two_slices; tb_origin",
      prompt="/product-builder go: build keyboard-archive --parallel 2"+OVERRIDE.format(gate="both slices are built and reviewed and their PRs are opened with bin/gh"),
      turns=200, timeout=3600, graders={
        "route-implement": read_pb("implement"), "implementers-dispatched": agent(r"(?i)implementer|contract|DONE_WITH_CONCERNS|NEEDS_CONTEXT", 2),
        "two-branches": bash(r"keyboard-archive/p2"), "review-invoked": skill("review"), "ledger-two-rows": rxfile("docs/plans/keyboard-archive/decisions.md", r"\| P2 \|"),
        "pr-created": exists(".forge/created.txt")}),
 dict(name="playbook-qa", tags=["playbook","tier2","flow","team","pbB"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_layer_p1_merged; tb_plan_status keyboard-archive Built; tb_origin",
      prompt="/product-builder test keyboard-archive end to end"+OVERRIDE.format(gate="qa-report.md is written with a verdict"),
      turns=150, timeout=2400, graders={
        "route-qa": read_pb("qa"), "report-written": exists("docs/plans/keyboard-archive/qa-report.md"),
        "verdict": rxfile("docs/plans/keyboard-archive/qa-report.md", r"(?i)verdict"), "personas-invoked": skill("personas"),
        "verify-invoked": skill("verify"), "flag-both-states": rx(r"(?i)flag off", "trace"), "tests-run": bash(r"node --test")}),
 dict(name="playbook-ship", tags=["playbook","tier2","flow","pbB"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_layer_p1_merged; tb_plan_status keyboard-archive 'QA passed'; tb_origin",
      prompt="/product-builder ship keyboard-archive"+OVERRIDE.format(gate="the rollout stages are prepared and the reply says what the user flips"),
      turns=100, timeout=1800, graders={
        "route-ship": read_pb("ship"), "dod-printed": rx(r"Definition of Done"), "no-flag-flip": never("Bash", r"flags\.json"),
        "user-flips": llm("PASS if the reply prepares rollout stages with a gate each and says the user flips the flag and announces; the run itself does not edit data/flags.json. FAIL if the run flips the flag or declares the feature shipped.")}),
 dict(name="playbook-bug-fix", tags=["playbook","tier2","flow","team","pbB"], scaffold=BASE+" tb_layer_bug_complete_archived; tb_origin",
      prompt="/product-builder fix: completing an archived task should be rejected. tests/complete-archived.test.js fails on main."+OVERRIDE.format(gate="the PR is opened with bin/gh"),
      turns=200, timeout=3600, graders={
        "route-bug-fix": read_pb("bug-fix"), "repro-first": {"type":"tool_order","before":{"tool":"Bash","input_match":"complete-archived"},"after":{"tool":"Edit"}},
        "root-cause-fix": rxfile("src/tasks.js", r"archived"), "review-invoked": skill("review"), "verify-invoked": skill("verify"),
        "pr-created": exists(".forge/created.txt"), "no-blanket-catch": rxfile("src/tasks.js", r"try\s*\{", match="not_contains"),
        "mechanism-named": rx(r"src/tasks\.js:\d+"), "scope-held": llm("PASS if the changes are confined to rejecting complete() on an archived task (src/tasks.js, its test, and at most the CLI or route message for that case), and any other defect the review found is listed under your call rather than fixed. FAIL if unrelated files or behaviours were changed in the same PR.", focus="trace")}),
 dict(name="playbook-refactoring", tags=["playbook","tier2","flow","pbA"], scaffold=BASE+" tb_origin",
      prompt="/product-builder refactor: extract the JSON persistence in src/store.js into a Store class with load() and save() and migrate the callers; behaviour must not change"+OVERRIDE.format(gate="the PR is opened with bin/gh"),
      turns=120, timeout=2400, graders={
        "route-refactoring": read_pb("refactoring"), "characterise": rx(r"(?i)characteris", "trace"), "tests-run": bash(r"node --test", 2),
        "review-invoked": skill("review"), "pr-created": exists(".forge/created.txt"), "class-exists": rxfile("src/store.js", r"class Store")}),
 dict(name="playbook-perf-issue", tags=["playbook","tier2","flow","pbA"], scaffold=BASE+" tb_layer_slow; tb_origin",
      prompt="/product-builder perf: listing 20000 tasks takes seconds; scripts/bench-list.js 20000 shows it. Make list fast."+OVERRIDE.format(gate="the PR is opened with bin/gh"),
      turns=120, timeout=2400, graders={
        "route-perf": read_pb("perf-issue"), "bench-twice": bash(r"bench-list", 2), "baseline-number": rx(r"\d+ ?ms"),
        "one-change": rxfile("src/format.js", r"Set|Map"), "review-invoked": skill("review"), "pr-created": exists(".forge/created.txt")}),
 dict(name="playbook-babysit", tags=["playbook","tier2","flow","pbB"], scaffold=BASE+" tb_layer_pathread_test; tb_layer_built_branch; tb_layer_open_pr; tb_origin; git checkout -q feature/priority-filter",
      prompt="/product-builder get PR 7 merge-ready: the check is red and there are review comments"+OVERRIDE.format(gate="the PR is merge-ready or the blocker is named"),
      turns=120, timeout=2400, graders={
        "route-babysit": read_pb("babysit"), "reads-pr": bash(r"gh pr (view|checks|list)"), "triage-table": rx(r"(?i)act|push back|clarify"),
        "never-merges": never("Bash", r"pr merge"), "fix-wave": rx(r"(?i)fix wave", "trace"),
        "readme-fixed": rxfile("README.md", r"priority"), "verify-invoked": skill("verify")}),
 dict(name="playbook-pickup", tags=["playbook","tier2","pbA"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_plan_status keyboard-archive Implementing; tb_layer_slice_branch; tb_origin; git checkout -q keyboard-archive/p1-archive-button",
      prompt="/product-builder continue"+OVERRIDE.format(gate="the slice's next step is done or the capsule is printed and work has resumed"),
      turns=200, timeout=3600, graders={
        "route-pickup": read_pb("pickup-and-pause"), "resume-invoked": skill("resume"), "capsule": rx(r"(?i)next move|capsule", "trace"),
        "claims-row": rxfile("docs/plans/keyboard-archive/decisions.md", r"\| P1 \|"), "on-slice-branch": rx(r"p1-archive-button", "trace")}),
 dict(name="playbook-pause", tags=["playbook","tier2","pbA"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_plan_status keyboard-archive Implementing; tb_layer_slice_branch; tb_origin; git checkout -q keyboard-archive/p1-archive-button; echo '// wip' >> src/cli.js",
      prompt="/product-builder pause, I'm about to compact; leave this so another session can pick it up",
      turns=60, timeout=1200, graders={
        "route-pause": read_pb("pickup-and-pause"), "handoff-written": exists("docs/plans/keyboard-archive/handoff.md"),
        "wip-saved": bash(r"git (commit|stash)"), "capsule": rx(r"(?i)next move")}),
 dict(name="playbook-opening-a-pr", tags=["playbook","tier2","flow","pbA"], scaffold=BASE+" tb_layer_pathread_test; tb_layer_built_branch; tb_origin; git checkout -q feature/priority-filter",
      prompt="/product-builder open a PR for this branch"+OVERRIDE.format(gate="the PR is opened with bin/gh"),
      turns=80, timeout=1800, graders={
        "route-opening": read_pb("opening-a-pr"), "body-sections": rx(r"## Why[\s\S]*## Verification|Why[\s\S]*Verification"),
        "checks-run": bash(r"node --test|scripts/check"), "pr-created": exists(".forge/created.txt"), "no-force-push": never("Bash", r"push.*--force|push -f")}),
 dict(name="playbook-built-first", tags=["playbook","tier2","flow","team","pbB"], scaffold=BASE+" tb_layer_pathread_test; tb_layer_built_branch; tb_origin; git checkout -q feature/priority-filter",
      prompt="/product-builder review what I built on this branch before I open the PR"+OVERRIDE.format(gate="the Definition of Ready is printed and the hand-off is stated"),
      turns=200, timeout=3600, graders={
        "route-built-first": read_pb("built-first"), "derived-plan": exists("docs/plans/*/decisions.md"),
        "assumed-derived": rx(r"ASSUMED: derived from the diff", "trace"), "status-derived": rx(r"Status:\*?\*? *Derived", "trace"),
        "round-trip": rx(r"(?i)round.trip|displays|removes", "trace"), "pm-invoked": skill("pm"), "techlead-invoked": skill("techlead"), "review-invoked": skill("review"),
        "dor-printed": rx(r"Definition of Ready")}),
 dict(name="playbook-incident", tags=["playbook","tier2","flow","pbA"], scaffold=BASE+" tb_layer_incident; tb_origin",
      prompt="/product-builder production is throwing 500s on complete since the 09:25 deploy; users cannot finish tasks. logs/app.log and logs/deploys.log are here."+OVERRIDE.format(gate="the postmortem is written"),
      turns=120, timeout=2400, graders={
        "route-incident": read_pb("incident"), "declares": rx(r"(?i)since|affected", "trace"), "mitigate-first": llm("PASS if the run proposes or performs a mitigation (revert the 09:25 deploy, roll back, flag off, disable the entry point) before it starts root-cause work, and says the mitigation waits for the user where it touches production. FAIL if it goes straight to the code fix.", focus="trace"),
        "root-cause": rx(r"src/tasks\.js"), "postmortem": exists("docs/plans/*/postmortem.md"), "evidence-preserved": exists("docs/plans/*/evidence/*")}),
 dict(name="playbook-spike", tags=["playbook","tier2","flow","pbA"], scaffold=BASE+" tb_layer_vendored_dep; tb_origin",
      prompt="/product-builder spike: can vendor/tinydate-v2 parse ISO week dates like 2026-W38-1? One hour budget; the answer decides whether we upgrade."+OVERRIDE.format(gate="the verdict is written"),
      turns=60, timeout=1200, graders={
        "route-spike": read_pb("spike"), "probe-run": bash(r"node .*(spike|probe)"), "verdict": rx(r"(?i)verdict|\byes\b|\bno\b|unknown"),
        "not-merged": never("Bash", r"git merge|cherry-pick"), "written": exists("docs/spikes/*.md")}),
 dict(name="playbook-dependency-upgrade", tags=["playbook","tier2","flow","team","pbA"], scaffold=BASE+" tb_layer_vendored_dep; tb_origin",
      prompt="/product-builder upgrade tinydate to v2; the new version is vendored at vendor/tinydate-v2 with its changelog"+OVERRIDE.format(gate="the PR is opened with bin/gh"),
      turns=120, timeout=2400, graders={
        "route-upgrade": read_pb("dependency-upgrade"), "changelog-read": rx(r"tinydate-v2/CHANGELOG", "trace"),
        "consumer-fixed": rxfile("src/dates.js", r"add\(|\{ pattern"), "tests-run": bash(r"node --test"), "review-invoked": skill("review"),
        "compat-seat": agent(r"(?i)backwards.compat"), "pr-created": exists(".forge/created.txt")}),
 dict(name="playbook-data-migration", tags=["playbook","tier2","flow","team","pbB"], scaffold=BASE+" tb_origin",
      prompt="/product-builder move task tags out of data/tasks.json into their own file data/tags.json with a backfill, keeping every reader working during the move"+OVERRIDE.format(gate="the slices are planned, the migration is replayed on a scratch copy, and the first PR is opened with bin/gh"),
      turns=150, timeout=3600, graders={
        "route-migration": read_pb("data-migration"), "five-steps": rx(r"(?i)expand[\s\S]*backfill[\s\S]*cut ?over[\s\S]*contract", "trace"),
        "replayed": bash(r"migrate"), "techlead-invoked": skill("techlead"), "db-seat": agent(r"(?i)database|release engineer"), "migration-file": exists("migrations/003*")}),
 dict(name="playbook-removal", tags=["playbook","tier2","flow","pbA"], scaffold=BASE+" tb_layer_dead_flag; tb_origin",
      prompt="/product-builder remove the legacy CSV export and its legacy_export flag; nobody uses it"+OVERRIDE.format(gate="the PR is opened with bin/gh"),
      turns=120, timeout=2400, graders={
        "route-removal": read_pb("removal"), "inventory-searches": bash(r"grep|rg", 1), "why-invoked": skill("why"),
        "deleted": rxfile("README.md", r"legacy_export", match="not_contains"), "cli-clean": rxfile("src/cli.js", r"exportCsv", match="not_contains"),
        "measured-or-said": llm("PASS if the run either measures usage over a window from logs or says plainly that zero assumed use is not evidence and records the decision with the user's statement quoted. FAIL if it deletes with no inventory of consumers.", focus="trace"),
        "review-invoked": skill("review")}),
 dict(name="playbook-flaky-test", tags=["playbook","tier2","flow","pbA"], scaffold=BASE+" tb_layer_flaky; tb_origin",
      prompt="/product-builder tests/counts.test.js fails about half the time on CI and passes when re-run"+OVERRIDE.format(gate="the PR is opened with bin/gh"),
      turns=120, timeout=2400, graders={
        "route-flaky": read_pb("flaky-test"), "quantified": bash(r"counts\.test\.js", 5), "rate-reported": rx(r"\d+ ?/ ?\d+|\d+ ?%|(?i)rate"),
        "no-retry-hack": rxfile("tests/counts.test.js", r"retry|setTimeout\(.*\d{3,}", match="not_contains"),
        "cause-fixed": llm("PASS if the fix gives each test its own scratch store or removes the shared state, and the reply names the mechanism (shared store plus concurrent tests). FAIL if the fix is a retry, a sleep, a loosened assertion, or a skip without an owner.", focus="trace")}),
 dict(name="playbook-release", tags=["playbook","tier2","flow","pbA"], scaffold=BASE+" tb_layer_release_commits; tb_origin",
      prompt="/product-builder cut the next release"+OVERRIDE.format(gate="the changelog entry is written and the tag and publish commands are shown"),
      turns=80, timeout=1800, graders={
        "route-release": read_pb("release"), "changelog-entry": rxfile("CHANGELOG.md", r"## (0\.2\.0|1\.0\.0)"), "breaking-noted": rxfile("CHANGELOG.md", r"(?i)breaking|archived"),
        "tag-shown-not-run": never("Bash", r"git tag -a|git tag v"), "commands-shown": rx(r"git tag")}),
 dict(name="playbook-decision-record", tags=["playbook","tier2","pbA"], scaffold=BASE+" tb_origin",
      prompt="/product-builder write up the decision to keep feature flags in a JSON file rather than environment variables as an ADR"+OVERRIDE.format(gate="the record is written and linked"),
      turns=60, timeout=1200, graders={
        "route-adr": read_pb("decision-record"), "adr-written": exists("docs/adr/0002-*.md"), "consequences": rx(r"(?i)consequences", "trace"),
        "why-invoked": skill("why"), "review-skipped": rx(r"(?i)skip: prose|skipped", "trace")}),
 dict(name="playbook-hardening", tags=["playbook","tier2","flow","team","pbB"], scaffold=BASE+" tb_layer_thin_import; tb_origin",
      prompt="/product-builder add tests and error handling to src/import.js; it swallows every error today"+OVERRIDE.format(gate="the PR is opened with bin/gh"),
      turns=150, timeout=2400, graders={
        "route-hardening": read_pb("hardening"), "how-invoked": skill("how"), "gap-table": rx(r"(?i)gap", "trace"),
        "tests-added": exists("tests/import*.test.js"), "no-bare-catch": rxfile("src/import.js", r"catch\s*\{\s*\}", match="not_contains"),
        "review-invoked": skill("review"), "silent-failure-seat": agent(r"(?i)silent.failure")}),
 # ---------------- leaf skills alone
 dict(name="leaf-setup", tags=["leaf","tier2"], scaffold="tb_base; tb_origin",
      prompt="/product-builder-setup"+OVERRIDE.format(gate="the four files are written"),
      turns=80, timeout=1800, graders={
        "profile": exists(".product-builder/profile.md"), "personas": exists(".product-builder/personas.md"), "drive": exists(".product-builder/drive.md"), "models": exists(".product-builder/models.md"),
        "test-command-detected": rxfile(".product-builder/profile.md", r"node --test"), "ci-lane": rxfile(".product-builder/profile.md", r"test-concurrency=1"),
        "forge-probed": bash(r"gh (auth status|repo view)"), "no-unknown-where-answerable": rxfile(".product-builder/profile.md", r"(?i)dev: UNKNOWN|check: UNKNOWN", match="not_contains"),
        "first-run-hook": rx(r"has no \.product-builder/profile\.md", "trace")}),
 dict(name="leaf-how", tags=["leaf","tier2","team"], scaffold=BASE+" tb_layer_shipped_snooze; tb_layer_vendored_dep; tb_origin",
      prompt="/product-builder-how how does a request become a stored task and an analytics event, across the server, the domain module, the store, and the tracker?",
      turns=60, timeout=1200, graders={
        "explorers": agent(r"(?i)explorer|angle|baseline SHA", 2), "anchors": rx(r"src/\w+\.js:\d+"),
        "shape": rx(r"(?i)overview[\s\S]*how it works[\s\S]*where things live"), "no-change": exists("src/**", False)}),
 dict(name="leaf-why", tags=["leaf","tier2"], scaffold=BASE+" tb_origin",
      prompt="/product-builder-why why is the store a single JSON file instead of a database?",
      turns=40, timeout=900, graders={
        "git-history": bash(r"git log|git blame"), "adr-found": rx(r"ADR 0001|0001-json"), "dated": rx(r"2026-08-20")}),
 dict(name="leaf-research", tags=["leaf","tier2","team"], scaffold=BASE+" tb_layer_plan_wide Framed; tb_origin",
      prompt="/product-builder-research shared-boards --system",
      turns=80, timeout=1800, graders={
        "explorers": agent(r"(?i)explorer|entry points|data flow", 1), "research-written": rxfile("docs/plans/shared-boards/research.md", r"(?i)current system"),
        "anchors-at-sha": rxfile("docs/plans/shared-boards/research.md", r"src/\w+\.js:\d+"), "census": rxfile("docs/plans/shared-boards/research.md", r"(?i)entry point")}),
 dict(name="leaf-prototype", tags=["leaf","tier2"], scaffold=BASE+" tb_layer_plan 'Decided'; tb_origin",
      prompt="/product-builder-prototype keyboard-archive --decision \"where the Archive control sits: on each row, or one bulk bar above the list\" --mode html",
      turns=80, timeout=1800, graders={
        "html-written": exists("docs/plans/keyboard-archive/prototype/index.html"), "switcher": rxfile("docs/plans/keyboard-archive/prototype/index.html", r"(?i)variant|switch"),
        "recommendation": rx(r"(?i)recommend"), "decision-recorded": rxfile("docs/plans/keyboard-archive/decisions.md", r"(?i)prototype")}),
 dict(name="leaf-personas", tags=["leaf","tier2","team"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_layer_p1_merged; tb_origin",
      prompt="/product-builder-personas keyboard-archive --target public/index.html --paper",
      turns=80, timeout=1800, graders={
        "mara": agent(r"Mara"), "devin": agent(r"Devin"), "priya-or-edge": agent(r"Priya|(?i)edge|wrong role|mobile"),
        "five-second": rx(r"(?i)five.second", "trace"), "paper-said": rx(r"(?i)paper"), "limitation": rx(r"(?i)pilot|not a substitute|stereotype")}),
 dict(name="leaf-pm", tags=["leaf","tier2","team"], scaffold=BASE+" tb_layer_plan 'Drafted'; tb_origin",
      prompt="/product-builder-pm keyboard-archive"+OVERRIDE.format(gate="the findings block and the scope answer are given"),
      turns=80, timeout=1800, graders={
        "seat-pm": agent(r"(?i)product manager|\bPM\b"), "seat-skeptic": agent(r"(?i)skeptic"), "seat-designer": agent(r"(?i)designer"),
        "seat-analyst": agent(r"(?i)analyst"), "seat-customer": agent(r"(?i)customer|Mara|Devin|Priya"),
        "buckets": rx(r"(?i)act on[\s\S]*consider[\s\S]*noted[\s\S]*dismissed", "trace"), "scope-question": rx(r"(?i)hold scope|wedge", "trace")}),
 dict(name="leaf-techlead-all-seats", tags=["leaf","tier2","team"], scaffold=BASE+" tb_layer_plan_wide Drafted; tb_origin",
      prompt="/product-builder-techlead shared-boards"+OVERRIDE.format(gate="the findings block is given and reversible edits are applied"),
      turns=100, timeout=2400, graders={
        "seat-techlead": agent(r"(?i)tech lead"), "seat-hawk": agent(r"(?i)simplicity hawk|staff simplicity"), "seat-database": agent(r"(?i)database|release engineer"),
        "seat-security": agent(r"(?i)security"), "seat-frontend": agent(r"(?i)frontend"), "seat-sre": agent(r"(?i)\bSRE\b"), "seat-integration": agent(r"(?i)integration"),
        "seat-cost": agent(r"(?i)\bcost\b"), "verifier-pass": rx(r"(?i)verif", "trace"), "rulings-ledger": rxfile("docs/plans/shared-boards/decisions.md", r"## Review rulings[\s\S]*\| (techlead|tech lead|hawk|security|frontend|database|SRE|integration|cost)")}),
 dict(name="leaf-review-all-seats", tags=["leaf","tier2","team"], scaffold=BASE+" tb_layer_pathread_test; tb_layer_kitchen_sink_branch; tb_origin",
      prompt="/product-builder-review --diff main..feature/smart-suggest",
      turns=100, timeout=2400, graders={
        "seat-staff": agent(r"(?i)staff|simplicity"), "seat-qa": agent(r"(?i)\bQA\b"), "seat-product-owner": agent(r"(?i)product owner"),
        "seat-database": agent(r"(?i)database|migration"), "seat-security": agent(r"(?i)security"), "seat-frontend": agent(r"(?i)frontend"),
        "seat-sre": agent(r"(?i)\bSRE\b|resilience"), "seat-integration": agent(r"(?i)integration"), "seat-cost": agent(r"(?i)\bcost\b"),
        "seat-accessibility": agent(r"(?i)accessib"), "seat-adversarial": agent(r"(?i)adversarial"), "seat-silent-failure": agent(r"(?i)silent.failure"),
        "seat-backwards-compat": agent(r"(?i)backwards.compat"), "seat-prompt-quality": agent(r"(?i)prompt.quality"),
        "prompt-contradiction-found": rx(r"(?i)contradict", "trace"), "path-read-test-found": rx(r"(?i)routes-contract|README lacks", "trace"),
        "safety-fact": rx(r"(?i)safe because|unproven"), "no-edit": never("Edit", r".")}),
 dict(name="leaf-verify", tags=["leaf","tier2","team"], scaffold=BASE+" tb_origin",
      prompt="/product-builder-verify \"POST /tasks with a title then GET /tasks returns it\" \"POST /tasks/1/archive is 404 with the archive flag off and 200 with it on\"",
      turns=60, timeout=1200, graders={
        "server-launched": bash(r"node src/server\.js|PORT="), "real-request": bash(r"curl|fetch"), "flag-both-states": rx(r"(?i)flag off[\s\S]*flag on|flag on[\s\S]*flag off", "trace"),
        "pass-per-scenario": rx(r"(?i)pass|fail"), "evidence-path": rx(r"evidence/|exit code|\{")}),
 dict(name="leaf-resume", tags=["leaf","tier2"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_plan_status keyboard-archive Implementing; tb_layer_slice_branch; tb_layer_plan_wide Drafted; tb_origin",
      prompt="/product-builder-resume --all",
      turns=40, timeout=900, graders={
        "both-plans": rx(r"keyboard-archive[\s\S]*shared-boards|shared-boards[\s\S]*keyboard-archive"), "status-tags": rx(r"(?i)implementing|drafted"),
        "next-move": rx(r"(?i)next move"), "nothing-written": exists("docs/**", False)}),
 dict(name="leaf-reflect", tags=["leaf","tier2"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_layer_p1_merged; tb_plan_status keyboard-archive Shipped; tb_origin",
      prompt="/product-builder-reflect keyboard-archive"+OVERRIDE.format(gate="the table of proposed edits is presented"),
      turns=60, timeout=1200, graders={
        "table": rx(r"(?i)accepted[\s\S]*rejected[\s\S]*backlog"), "nothing-applied-without-approval": rx(r"(?i)approv|apply", "trace"),
        "no-suite-edit": never("Edit", r"skills/")}),
 dict(name="leaf-plain", tags=["leaf","tier1"], scaffold=BASE+" tb_origin",
      prompt="/product-builder-plain Restate my last reply, which was: \"The intake probe returned partial: the archive route ships at src/server.js:36 behind the archive flag, but the page has no control. Size is provisional Bounded pending research. Baseline 3f1c2a0, 0 behind. Budgets: one interview of at most five questions after research, one explorer, tech lead plus one seat.\"",
      turns=5, timeout=300, graders={
        "no-jargon": rx(r"^(?:(?!provisional|intake probe|Budgets|G1|DoR).){0,800}$", flags="s"), "plain": llm("PASS if the reply keeps each fact's meaning (part of the archive feature already exists on the server behind a flag, the page has no control, the size is a first guess, the commit is current, the question and reviewer limits) in everyday words a non-engineer could follow, and does not use the phrases 'intake probe', 'provisional', or 'budgets'. Words like commit, flag, route, baseline are fine. FAIL only if a meaning changed, a fact was dropped, or one of those three phrases appears.")}),
 # ---------------- routing and gates (tier 1)
 dict(name="route-by-state", tags=["routing","tier1"], scaffold=BASE+" tb_layer_built_branch; tb_origin; git checkout -q feature/priority-filter",
      prompt="/product-builder look at this",
      turns=40, timeout=900, graders={
        "route-built-first": read_pb("built-first"), "route-named-with-facts": rx(r"(?i)built first[\s\S]*(ahead|no plan)", "trace"), "state-read-first": bash(r"git (status|branch|log|rev-list|diff)")}),
 dict(name="route-explicit-prefix", tags=["routing","tier1"], scaffold=BASE+" tb_layer_flaky; tb_origin",
      prompt="/product-builder flaky-test: tests/counts.test.js fails about one time in two",
      turns=120, timeout=1800, graders={"route-flaky": read_pb("flaky-test"), "no-other-playbook": never("Read", r"playbooks/bug-fix\.md")}),
 dict(name="route-state-vs-words", tags=["routing","tier1","gate"], scaffold=BASE+" tb_layer_pathread_test; tb_layer_built_branch; tb_layer_open_pr; tb_origin; git checkout -q feature/priority-filter",
      prompt="/product-builder fix this: TypeError: Cannot read properties of undefined (reading 'status') at complete (src/tasks.js:22)",
      turns=40, timeout=900, graders={
        "one-question": rx(r"(?i)Q1|Recommended:"), "both-routes": rx(r"(?i)bug fix[\s\S]*babysit|babysit[\s\S]*bug fix"), "state-recommended": rx(r"(?i)recommended:.*(babysit|bug fix)")}),
 dict(name="route-trivial", tags=["routing","tier1"], scaffold=BASE+" tb_origin",
      prompt="/product-builder change the page title from Taskbox to Taskbox Pro"+OVERRIDE.format(gate="the change is made and verified"),
      turns=30, timeout=900, graders={
        "trivial-said": rx(r"(?i)trivial", "trace"), "no-plan-folder": exists("docs/plans/**", False), "changed": rxfile("public/index.html", r"Taskbox Pro"), "verified": bash(r"grep|curl|node")}),
 dict(name="route-no-profile", tags=["routing","tier1"], scaffold="tb_base; tb_origin",
      prompt="/product-builder plan: add a due date to tasks",
      turns=40, timeout=900, graders={"setup-first": rx(r"(?i)product-builder-setup|setup", "trace"), "setup-invoked": skill("setup"), "hook-line": rx(r"has no \.product-builder/profile\.md", "trace")}),
 dict(name="route-continue-no-args", tags=["routing","tier1"], scaffold=BASE+" tb_layer_plan 'Ready to implement'; tb_plan_status keyboard-archive Implementing; tb_layer_slice_branch; tb_origin; git checkout -q keyboard-archive/p1-archive-button",
      prompt="/product-builder", turns=40, timeout=900, graders={"route-pickup": read_pb("pickup-and-pause"), "resume-invoked": skill("resume")}),
 dict(name="gate-one-question-default", tags=["gate","tier1"], scaffold=BASE+" tb_origin",
      prompt="/product-builder plan: add a due date to every task, shown on the page and settable from the CLI",
      turns=60, timeout=1200, graders={
        "ends-with-one-question": rx(r"Reply \"ok\" for \(\w\), or name the letter"), "not-two-questions": rx(r"\bQ2\b", match="not_contains"),
        "explored-first": bash(r"grep|git log|cat", 1), "twelve-lines-before-q1": rx(r"^(?:[^\n]*\n){0,13}[^\n]*Q1\b")}),
 dict(name="gate-judge-none", tags=["gate","judge","tier1"], scaffold=BASE+" tb_origin",
      prompt="/product-builder how does the flag helper decide a flag is on?",
      turns=30, timeout=600, graders={"judged-by-you": rx(r"(?i)judge", "trace"), "no-judge-call": never("Bash", r"scripts/judge")}),
 dict(name="gate-judge-no-key", tags=["gate","judge","tier1"], scaffold=BASE+" sed -i '' 's/^Model: none/Model: typesafe\\/jev-latest/' .product-builder/profile.md; git add -A; git -c user.name=f -c user.email=f@e commit -q -m judge; tb_origin",
      prompt="/product-builder how does the flag helper decide a flag is on?",
      turns=30, timeout=600, graders={"says-no-key": rx(r"(?i)no key|not set|judged by you|session model", "trace"), "no-crash": rx(r"Traceback", "trace", match="not_contains")}),
 # ---------------- calcom (tier 3)
 dict(name="calcom-setup", tags=["calcom","tier3"], scaffold="calcom_base",
      prompt="/product-builder-setup"+OVERRIDE.format(gate="the four files are written"),
      turns=100, timeout=2400, graders={
        "profile": exists(".product-builder/profile.md"), "stack-detected": rxfile(".product-builder/profile.md", r"(?i)yarn|turbo|prisma|next"),
        "forge-unknown-honest": rxfile(".product-builder/profile.md", r"(?i)UNKNOWN|fixture|denied"), "drive": exists(".product-builder/drive.md")}),
 dict(name="calcom-investigation", tags=["calcom","tier3","team"], scaffold="calcom_base; calcom_profile",
      prompt="/product-builder how does a booking get confirmed after the attendee submits the booking form, and where is the confirmation email sent?",
      turns=80, timeout=1800, graders={
        "route-investigation": read_pb("investigation"), "how-invoked": skill("how"), "explorers": agent(r"(?i)explorer|angle", 1),
        "anchors": rx(r"(apps|packages)/[\w/.-]+\.tsx?:\d+"), "no-change": exists("apps/**", False)}),
 dict(name="calcom-built-first", tags=["calcom","tier3","flow","team"], scaffold="calcom_base; calcom_pr_branch 1 pr-embed-guard",
      prompt="/product-builder review what I built on this branch before I open the PR"+OVERRIDE.format(gate="the Definition of Ready is printed and the hand-off is stated"),
      turns=200, timeout=3600, graders={
        "route-built-first": read_pb("built-first"), "derived-plan": exists("docs/plans/*/decisions.md"), "assumed-derived": rx(r"ASSUMED: derived from the diff", "trace"),
        "review-invoked": skill("review"), "techlead-invoked": skill("techlead"), "anchors": rx(r"(apps|packages)/[\w/.-]+\.tsx?:\d+", "trace"), "dor-printed": rx(r"Definition of Ready")}),
 dict(name="calcom-review", tags=["calcom","tier3","team"], scaffold="calcom_base; calcom_pr_branch 1 pr-embed-guard; git checkout -q main",
      prompt="/product-builder-review --diff main..pr-embed-guard",
      turns=100, timeout=2400, graders={
        "seats-cast": agent(r"(?i)staff|simplicity|QA|product owner", 3), "by-signal-seat": agent(r"(?i)frontend|security|integration|silent.failure|backwards", 1),
        "verifier": rx(r"(?i)verif", "trace"), "findings-block": rx(r"(?i)act on|consider|noted|dismissed"), "no-edit": never("Edit", r".")}),
 dict(name="calcom-plan-bounded", tags=["calcom","tier3","flow"], scaffold="calcom_base; calcom_profile",
      prompt="/product-builder plan: on the booking success page, add a Copy link button that copies the booking's reschedule link"+OVERRIDE.format(gate="the Definition of Ready is printed or the intake probe stops the plan"),
      turns=200, timeout=3600, graders={
        "route-plan": read_pb("plan"), "probe-ran": bash(r"git grep|git ls-tree|origin/main"), "anchors": rx(r"(apps|packages)/[\w/.-]+\.tsx?:\d+", "trace"),
        "dor-or-stop": rx(r"(?i)Definition of Ready|already ships|nothing to do")}),
]

def write_case(c):
    d = EVALS / c["name"]
    if d.exists(): shutil.rmtree(d)
    (d / "graders").mkdir(parents=True)
    (d / "case.yaml").write_text(
        f'schema_version: "1.1"\nname: {c["name"]}\ntags: {json.dumps(c["tags"])}\nruns: 1\ncontext:\n  scaffold_script: scaffold.sh\n'
        f'execution:\n  max_turns: {c["turns"]}\n  timeout_seconds: {c["timeout"]}\n  allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite]\n')
    (d / "scaffold.sh").write_text('#!/usr/bin/env bash\nsource "$(dirname "$0")/../fixtures/lib.sh"\n' + c["scaffold"] + "\n")
    os.chmod(d / "scaffold.sh", 0o755)
    (d / "prompt.md").write_text(c["prompt"] + "\n")
    for gname, g in c["graders"].items():
        g = dict(g); body = ""
        if g["type"] == "llm": body = g.pop("criteria")
        def yv(v):
            if isinstance(v, str): return "'" + v.replace("'", "''") + "'"
            if isinstance(v, bool): return "true" if v else "false"
            if isinstance(v, (int, float)): return str(v)
            if isinstance(v, dict): return "{ " + ", ".join(f"{k}: {yv(x)}" for k, x in v.items()) + " }"
            return json.dumps(v)
        fm = "\n".join(f"{k}: {yv(v)}" for k, v in g.items())
        (d / "graders" / f"{gname}.md").write_text(f"---\n{fm}\n---\n" + (f"\n{body}\n" if body else ""))

for c in CASES: write_case(c)
print(f"{len(CASES)} cases; graders: {sum(len(c['graders']) for c in CASES)}")
