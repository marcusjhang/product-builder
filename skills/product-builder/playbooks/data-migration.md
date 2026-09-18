### Data migration

**You own the data on both sides of the cutover.** A schema change with a backfill, a move between stores, a re-encoding, a split or merge of tables. Expand, backfill, verify, cut over, contract; each step its own PR and its own rollback.

1. Inventory: the rows or records affected (a count from the real store or a scratch copy of it), every reader and writer at file:line, the invariants a reader assumes, and the profile's deploy reality (migrations run when, by whom, with what lock behaviour).
2. Plan the five steps as slices per `playbooks/plan.md` step 5, riskiest first: expand (the new shape beside the old, no reader changes); backfill or dual-write (idempotent, resumable, batched, rate-limited, with a progress record); verify (a query that compares old and new, and its expected zero); cut over (readers move behind a flag); contract (the old shape removed after the watch window). A step that cannot be rolled back names why and gets the user's explicit go at that step.
3. Replay every migration on a scratch database with production-shaped data through **product-builder-verify**, with its timing; anything over the profile's lock budget is batched or run online.
4. Backfill with a kill switch and a progress row; a run that stops resumes from the row, never from zero. The comparison query runs during and after.
5. **product-builder-techlead** with the database seat on the slice plan before the expand PR; **product-builder-review** on each PR.
6. Cut over behind a flag, both flag states verified with the comparison query at zero; contract only after the watch window in the plan.
7. `playbooks/opening-a-pr.md` per slice. Blast radius names the row count, the lock behaviour, and the rollback for that step.

**Reply:** the inventory with counts; the five slices with a rollback per step; the replay timing; the comparison query and its result; the PR URLs; what waits for the user.
