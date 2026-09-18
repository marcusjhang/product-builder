#!/usr/bin/env python3
"""summarize.py aggregate-result.json: a Markdown table of cases, scores, run errors, and failed graders."""
import json, sys
d = json.load(open(sys.argv[1]))
a = d.get("aggregates", {})
print(f"# Eval run\n\nclaude {d.get('claudeVersion')} · {d.get('durationSeconds')}s · est. ${d.get('costUsd', 0):.2f} · partial: {d.get('partial')} {d.get('partialReason') or ''}\n")
print(f"Cases passed {a.get('casesPassed')}/{a.get('casesTotal')} · overall {a.get('overallScore')} · mean delta {a.get('meanDelta')}\n")
print("| Case | Score | Delta | Runs | Errors | Failed graders |\n|---|---|---|---|---|---|")
for c in d.get("cases", []):
    ag = c.get("aggregates", {})
    runs = c.get("arms", {}).get("with", [])
    errs = [r.get("error") for r in runs if r.get("error")]
    failed = sorted({g["name"] for r in runs for g in r.get("graders", []) if not g.get("passed") and g.get("scored", True)})
    print(f"| {c['name']} | {ag.get('score')} | {ag.get('delta', '')} | {len(runs)} | {'; '.join(e[:80] for e in errs)} | {', '.join(failed)} |")
print("\n## Per-run detail\n")
for c in d.get("cases", []):
    for i, r in enumerate(c.get("arms", {}).get("with", [])):
        print(f"### {c['name']} run {i+1}: score {r.get('score')} · {r.get('turns')} turns · {r.get('durationSeconds')}s · ${r.get('costUsd', 0):.2f} · error: {r.get('error')}")
        for g in r.get("graders", []):
            mark = "pass" if g.get("passed") else "FAIL"
            print(f"- {mark} `{g['name']}`" + ("" if g.get("scored", True) else " (indicator)") + f": {(g.get('explanation') or g.get('evidence') or '')[:300]}")
        print()
