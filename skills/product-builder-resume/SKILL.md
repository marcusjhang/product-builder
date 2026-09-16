---
name: product-builder-resume
description: Rebuilds working context before starting or resuming. Reads the plan folder and its ledger, the git state (branches, worktrees, uncommitted work), open PRs and their checks, and recent session notes, then hands back a capsule: what this is and where it stands, one line per thread with a status tag, the recurring problems, the ASSUMED decisions still waiting, and the single next move. With --handoff writes a redacted hand-off note another session can start from. Use for "where was I", "catch me up on <slug>", "what's in flight", "hand this off", or at the start of any session that continues earlier work.
argument-hint: [slug | --all] [--handoff]
---

# product-builder-resume

1. Scope: the slug given, or the slug inferred from the current branch (`<slug>/p2-…`), or `--all` (every plan folder with status between Framed and Shipping). State the scope back in one line.
2. Read `docs/plans/<slug>/decisions.md` (implementation log, revision log, ASSUMED rows, open questions), the plan headers, and `qa-report.md` if present.
3. Live state: `git branch --list '<slug>/*'` plus the branch names in the ledger's implementation log, `git worktree list`, `git status --short`, and PRs by head branch (`gh pr list --state all --head <branch>` for each slice branch; a title search is a fallback and its hits are labelled fuzzy).
4. Verify the ledger against live state: a PR the ledger calls open that is merged, a branch the ledger does not know, uncommitted work on a slice branch. Each mismatch is a finding.
5. Write the capsule. With `--handoff`, also write `docs/plans/<slug>/handoff.md`: the capsule, the artifact paths, the playbook or skill to invoke next, secrets redacted.

Capsule contract:

```
Capsule      at most 5 bullets: what this work is and where it stands
Threads      one line each, prefixed with exactly one tag: [merged #N] [open PR #N] [in flight <branch>] [verified, uncommitted] [reverted #N] [planned, not started]
Problems     at most 5, the recurring ones, with what was tried
Assumed      ASSUMED decisions still awaiting the user
Next move    the single most useful next action, concrete, with the playbook or skill that runs it; when the next move is itself a fork, name the fork in one line and end the reply there; the question comes on the user's "continue"
```

**Reply:** the capsule, and the ledger-versus-live findings if any.
