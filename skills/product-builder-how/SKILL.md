---
name: product-builder-how
description: Explains how part of the system works. Routes the question by complexity, spawns 2-4 parallel read-only explorers on distinct angles for a multi-file subsystem, then one explainer that synthesises Overview, Key concepts, How it works, Where things live, Gotchas, every claim with file:line at a named SHA. Use for "how does X work", "walk me through", "map this area", or when product-builder-research needs a system map (--map).
argument-hint: [question] [--map]
---

# product-builder-how

Read-only. Run the profile's baseline rule, then record the SHA (`git rev-parse --short HEAD`); explorers cite that SHA, they do not compute it. Each explorer is budgeted at roughly 40 tool calls; say so in its prompt.

1. Route by complexity. One module → one explainer subagent reads and explains. Cross-cutting → two to four explorer subagents first, one per angle: entry points and user-facing surfaces; data model, persistence, migrations; services, events, jobs, realtime; tests, fixtures, similar existing features, extension seams, permissions, glossary and ADR constraints. Use the profile's map agent when it names one, else the built-in Explore agent; when the map agent is reporting-only, the judgment fields (Closest feature, Cost) are filled by you from its report.
2. Explorer prompt (self-contained): baseline SHA, area, keywords, starting paths, the angle, and this contract: "Report only what you verified by reading. Cite file:line for every claim, with the line number taken from `grep -n` or `sed -n '<n>p'`, never counted from a range. A negative claim ("no cron", "not found") names the exact search that failed (the grep pattern and the directories). Flag docs that contradict code. The hard budget is 40 lines; count them before returning and cut from the bottom. Return: Map (entry → flow → persistence → events → tests, one real path per hop); Reuse (helpers, patterns, components to extend); Closest feature (the nearest existing feature and its files); Constraints (ADRs, glossary, permissions, deploy reality); Cost (the layers a change must touch); Open (facts you could not settle, as questions). No code dumps."
3. Synthesise yourself, in the session, over the explorer returns (no explainer subagent): Overview; Key concepts; How it works; Where things live; Gotchas. Where two explorers disagree, read the file and settle it. Every claim carries file:line or a label (inferred, guess). Flag stale docs.
4. `--map`: return only the merged Map, Reuse, Closest feature, Constraints, Cost, Open blocks, for the research skill.

**Reply:** the explanation. Pointers, not dumps. Read the profile's `learnings.md` first; cite "prior learning" only when an entry applied.
