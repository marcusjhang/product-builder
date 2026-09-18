### Decision record

**You own the record of a decision already made.** An architecture decision, a convention, a rejected approach, a constraint from outside; found in the ledger, a conversation, a PR thread, or a meeting. The record says what was decided, why, what it cost, and what would reopen it.

1. Locate the decision: the ledger row, the PR discussion, the message, the commit. **product-builder-why** when the reason is not written anywhere; a decision with no recoverable reason is recorded as "reason not recorded" with the date and who to ask.
2. Read the profile's ADR convention (directory, numbering, template, status words) and every existing record on the area; a new record that contradicts one supersedes it by number, never edits it.
3. Write in the repo's template, or with none, in this order: context (the forces, with file:line where the code is the force); the decision as one sentence; the options considered with the reason each lost; the consequences (what is now easier, what is now harder, what to watch); the trigger that would reopen it. Numbers and quotes verbatim from their source, linked.
4. Link both ways: the record cites the ledger row or the PR; the ledger row, or a comment at the decision's site in the code, cites the record.
5. **product-builder-review** is skipped for a record alone (`skip: prose`). `playbooks/opening-a-pr.md` when the repo reviews docs by PR; otherwise a commit on the default branch waits for the user.

**Reply:** the record path; the decision in one sentence; the options it beat; what would reopen it; the links made.
