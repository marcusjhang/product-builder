#!/usr/bin/env python3
"""trace-summary.py <trace.jsonl | kept run dir | aggregate-result.json> [--full]
Prints what a run did: the prompt, tool histogram, Skill and Agent calls, playbook and skill files read, the last message.
With an aggregate-result.json, summarises every run in it. Kept run directories are chmod 700'd on the way."""
import json, os, re, subprocess, sys
from pathlib import Path

def unseal(p):
    d = p if p.is_dir() else p.parent
    for up in [d, *d.parents]:
        if up.name.startswith("e-") and str(up).startswith("/private/tmp/"):
            subprocess.run(["chmod", "700", str(up), str(up / "sealed")], stderr=subprocess.DEVNULL)
            break

def summarize(trace, full=False):
    trace = Path(trace); unseal(trace)
    tools, skills, agents, reads, texts, prompt = {}, [], [], [], [], None
    for line in trace.open():
        try: m = json.loads(line)
        except Exception: continue
        msg = m.get("message") if isinstance(m.get("message"), dict) else {}
        content = msg.get("content")
        if msg.get("role") == "user" and prompt is None:
            if isinstance(content, str): prompt = content
            elif isinstance(content, list):
                for c in content:
                    if c.get("type") == "text": prompt = c["text"]; break
        if msg.get("role") == "assistant" and isinstance(content, list):
            for c in content:
                if c.get("type") == "text": texts.append(c["text"])
                if c.get("type") == "tool_use":
                    n = c["name"]; i = c.get("input", {}); tools[n] = tools.get(n, 0) + 1
                    if n == "Skill": skills.append(i.get("skill"))
                    if n == "Agent": agents.append(f"{i.get('subagent_type','?')}: {(i.get('description') or '')[:50]} | {(i.get('prompt') or '')[:90].replace(chr(10),' ')}")
                    if n == "Read":
                        fp = i.get("file_path", "")
                        if "playbooks/" in fp or "SKILL.md" in fp or "references/" in fp: reads.append(fp.split("skills/")[-1])
        if m.get("type") == "result": last = m.get("result")
    print(f"trace: {trace}")
    print(f"prompt: {(prompt or '')[:200].replace(chr(10),' ')}")
    print(f"tools: {tools}")
    print(f"skills: {skills}")
    print(f"suite files read: {reads}")
    for a in agents: print(f"  agent: {a}")
    lm = texts[-1] if texts else ""
    print(f"last message ({len(lm)} chars):\n  " + lm[: (4000 if full else 700)].replace("\n", "\n  "))

arg = Path(sys.argv[1]); full = "--full" in sys.argv
if arg.suffix == ".json":
    d = json.load(arg.open())
    for c in d["cases"]:
        for r in c["arms"].get("with", []):
            print("=" * 100); print(f"CASE {c['name']} score={r.get('score')} error={r.get('error')}")
            for g in r.get("graders", []):
                if not g.get("passed"): print(f"  FAIL {g['name']}: {(g.get('explanation') or '')[:200]}")
            if r.get("tracePath") and Path(r["tracePath"]).exists(): summarize(r["tracePath"], full)
            else: print("  (trace not kept)")
elif arg.is_dir(): summarize(arg / "out" / "trace.jsonl", full)
else: summarize(arg, full)
