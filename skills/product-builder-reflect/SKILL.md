---
name: product-builder-reflect
description: After a hard or surprising run, reviews the transcript and the plan folder for friction (questions the user answered twice, facts the profile lacked, personas that were missing, prompts that produced dumps instead of pointers, steps skipped, Definition of Ready items red at hand-off) and proposes concrete edits to .product-builder/ files and to the suite's skills, sorted into accepted / rejected / backlog, applying only what the user approves. Approved learnings are appended to .product-builder/learnings.md. Use for "what should we change about the workflow", "that was painful, learn from it", or after a ship.
argument-hint: [slug]
---

# product-builder-reflect

1. Read the plan folder (ledger, revision log, review rulings, qa report), `.product-builder/judge-log.jsonl` when it exists (per gate: calls, the verdict split, and in `shadow` mode the agreement rate between the judge and the decision actually taken; a gate above 90 percent over at least twenty calls earns a proposed switch to `Mode: gate`, one below 70 earns a proposed question edit in `judge-questions.json`), and this session's transcript for friction: a question the user answered twice; a fact the profile lacked; a persona that was missing; a subagent that returned a dump; a step skipped without a reason; a Definition of Ready item red at hand-off; a fallback that fired; a budget exceeded.
2. Propose edits, each with the file, the change, and the friction it removes: project edits (`.product-builder/profile.md`, `personas.md`, `drive.md`, `models.md`) and suite edits (a playbook or a leaf skill). Sort into accepted, rejected, backlog with a one-line reason each; present as one table.
3. Ask once, multi-select, which to apply. Apply project edits in place. Write suite edits as a patch under `docs/plans/<slug>/reflect-<date>.patch` for the user to apply in the suite's repo.
4. Learnings: for each approved learning append a row to `.product-builder/learnings.md`: date, type (pattern, pitfall, preference, architecture, tool), confidence 1-10, files it refers to, one-line note. Only what saves time in a future session. Rows the mode's profile-correction rule wrote mid-playbook are reviewed here (kept, merged, or retired with a reason), not rewritten and not duplicated.

Nothing changes without approval.

**Reply:** the friction found; the table; what was applied; the patch path; the learnings appended.
