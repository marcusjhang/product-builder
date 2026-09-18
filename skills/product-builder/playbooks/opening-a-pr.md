### Opening a PR

**Invoked at the end of every playbook that changed code.**

Commits: rebase into small ordered commits grouped in dependency order (schema, core logic, wiring, UI, tests). After any history rewrite, compare the tree hash with the original before pushing. Prefer five narrow PRs to one wide one; a dependent PR targets its parent branch.

Title: conventional commit, `type(scope): subject`, imperative, no trailing period.

Body, in this order, drop a section with nothing to say:

```
## Why            intent and approach; the first line is a TL;DR that matches the actual diff
## Scope          real symbols and paths; mechanical or generated files listed apart from logic
## Tradeoffs      rejected alternatives a reviewer would otherwise ask about
## Blast radius   who or what this touches, why it is safe or risky, flag state; a shared credential, a metered key, or a quota the change can spend, and what bounds the spend
## Verification   each real run path and its outcome; numbered "to see it yourself" steps; before/after screenshots or a recording for UI, per the profile's Evidence section (`gh` cannot attach an asset to a PR body, so the default is screenshots committed under the plan folder within the size cap and embedded by blob URL, recordings linked); perf as before → after with a unit; anything not exercised against the real dependency (a stubbed model, a mocked API, a fake clock) listed as unproven, by name
Plan: docs/plans/<slug>/ · Stories: S1, S3 · Slice: P2        (when a plan exists)
```

Before the PR: plan completion, when a plan exists (every item of the slice marked done, changed, or deferred in the ledger; files touched outside the slice's list are named as scope drift and explained or moved to their own PR); the changelog or release-notes line composed from the diff without asking, when the profile names a changelog (otherwise `skip: no changelog in profile`); docs synced through the profile's docs skill when the diff changed user-facing behaviour; a fresh run of the profile's checks in this reply (no claim rests on an earlier run).

No "Summary" or "Test plan" boilerplate, no SHA lists, no file-by-file essays. Open ready, never draft. Forge per the profile's Forge section, `gh` by default, with the login the section names for this remote; a push or PR call that fails on authentication is retried once with that login's token and the reply says which login was used; a second failure stops with the command and its output, never a workaround the profile does not record. Link the tracker task on request.

Refuses: to push from the base branch, to force-push, to open a PR whose checks fail on the branch's own files (a check that is already red at the baseline in files the branch does not touch is named in the body's Verification section with the baseline evidence, and does not block), to open a PR whose slice has an unresolved review finding marked act on, to paste a credential into a body.

**Reply:** before opening, the title and body inline for the user to read; after opening, the PR URL as a full link and one line on what a reviewer should read first.
