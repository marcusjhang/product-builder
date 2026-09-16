### Babysit

**You own merge-ready, never the merge.** Declare the mode before polling: one pass, or watch until green.

1. Read the PR, its checks, and its comments.
2. For each failing check: root cause per `playbooks/bug-fix.md`, never a retry-until-green.
3. Comment triage table: comment, bucket (act, push back, clarify), reason, action. Bots catch real bugs and file noise; dismiss noise with a concrete reason.
4. Rebase, push, re-run **product-builder-verify** after changes.
5. Report: checks, open comments, what changed since the last report.
6. Stop at merge-ready. The merge is the user's.

**Reply:** checks and their state; the comment triage table; what changed since the last report; merge-ready or what blocks it.
