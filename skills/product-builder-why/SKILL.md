---
name: product-builder-why
description: Finds evidence for why the system was built a certain way. Queries git history and blame across renames, PR descriptions and review threads, issues, ADRs and design docs, and the profile's observability tools in parallel, then returns a dated rationale with links and says plainly what has no recorded reason. Use for "why is it like this", "who decided", "what was the reason", or before a refactor that would undo a past decision.
argument-hint: [question]
---

# product-builder-why

1. Identify the symbol, file, or behaviour in question.
2. Evidence lanes, in parallel (read-only subagents or direct commands): `git log --follow` and `git blame` on the files; PR search and bodies (`gh pr list --search`, `gh pr view`); issues; the ADR and design directories; the profile's logs or error tracker when the question is about runtime behaviour.
3. Merge into a timeline: date, actor, artifact link, the stated reason. Mark inferred reasons as inferred; never fabricate a link or a citation.
4. Close with "no recorded reason" where that is the truth, and name the ADR it would take to record one when the decision meets the ADR bar (hard to reverse, surprising without context, a real trade-off).

**Reply:** the timeline, the recorded reason or its absence, the decision it would take to change it.
