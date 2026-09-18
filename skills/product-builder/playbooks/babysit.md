### Babysit

**You own merge-ready, never the merge.** Declare the mode before polling: one pass, or watch until green.

1. Read the PR, its checks, and its comments.
2. For each failing check: root cause per `playbooks/bug-fix.md`, never a retry-until-green.
3. Comment triage table: comment, bucket (act, push back, clarify), reason, action. Bots catch real bugs and file noise; dismiss noise with a concrete reason. When the profile names a judge, run its `pr-comment` gate per comment through `${CLAUDE_SKILL_DIR}/scripts/judge` (`--batch`; state: the comment, the hunk it targets, the PR intent in two sentences); in `gate` mode the bucket column is the verdict with its confidence shown and `dismissed` carries the judge's reason plus one line of yours, in `shadow` mode the verdict is logged beside yours.
4. Rebase, push, then invoke **product-builder-verify** (the Skill tool, not a test run in this session) on the surfaces the fixes touched, and **product-builder-review** `--fix-wave` on each fix commit that answers a comment or a failing check, before the thread is resolved.
5. Report: checks, open comments, what changed since the last report.
6. Stop at merge-ready. The merge is the user's.

**Reply:** checks and their state; the comment triage table; what changed since the last report; merge-ready or what blocks it.
