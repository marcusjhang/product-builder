---
name: product-builder-techlead
description: Casts a tech-lead panel (tech lead and staff simplicity hawk always; database or release, security, frontend, SRE, integration seats by signal) of read-only subagents to review an implementation plan against the code at the baseline SHA. Verifies every current-state claim, looks for a simpler seam, checks change-site completeness, migration and rollout safety, riskiest-first slice order and the walking skeleton, test strategy as a QA-executable test matrix, observability, permissions, performance at scale, the prime directives (no silent failures, named errors, shadow paths, interaction edge cases), mandatory diagrams, story-to-slice coverage, and unverified assumptions. Merges findings with attribution and confidence, kills false positives, applies accepted edits, records rulings. Use when the Plan playbook reaches verification, or for "is this plan sound", "tech lead review", "sanity-check the approach". For a diff, use product-builder-review.
argument-hint: [slug] [--slices P1,P2]
---

# product-builder-techlead

1. Read the plan folder, `.product-builder/learnings.md`, and the profile's canon, deploy reality, flags, reviewers-by-path. Record the baseline SHA.
2. Cast two to four seats by signal and say why: tech lead and staff simplicity hawk always; database or release engineer when schema or migrations are touched; security when auth, permissions, or user input; frontend when a UI surface; SRE when jobs, retries, timeouts, or realtime; integration when a third-party API. Use the profile's reviewer agents for their paths when named; every other seat is a general-purpose subagent with a read-only instruction and the seat prompt, on the model `models.md` assigns to techlead seats.
3. Dispatch in parallel, read-only, each with `${CLAUDE_SKILL_DIR}/references/reviewer-prompt.md` filled for its seat.
4. Verifier pass by you: re-check every critical and high finding against the code and drop what does not survive. Below 60 confidence lands in noted. When the profile names a judge, run its `finding` gate over every returned finding first through `${CLAUDE_SKILL_DIR}/../product-builder/scripts/judge` (`--batch`; state: the finding and the plan section it names, verbatim) and `finding-pair` for the agreement map; in `gate` mode its bucket and confidence replace the seat's and your re-check covers what it leaves in act on or consider, in `shadow` mode its buckets are logged beside yours.
5. One block, at most eight lines, grouped by bucket with seat and confidence, the proposed edit attached; an agreement map in one line. Apply the reversible edits to `implementation.md` (anchors, change sites, slice order, tests, diagrams) and list them. Rulings that change what the user sees, cost appetite, or cut scope are asked with one multi-select and the reply ends there; the Definition of Ready runs on the next turn after the answer. Never write "waiting on you" and continue in the same reply. Record rulings in `decisions.md`.
6. If any seat marked an assumption unverified, recommend a spike and route it to **product-builder-research --spikes**.
7. Re-run the affected seat only if a slice changed shape.

**Reply:** the cast and why; the findings block; the simplest-path statement; the coverage matrix; what was applied; what needs the user.
