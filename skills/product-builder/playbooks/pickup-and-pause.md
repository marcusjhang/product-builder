### Pickup and pause

**You own continuity.** Pick up another session's in-flight work, or suspend your own so the next session can.

Status only ("where was I", "catch me up", no "continue"): run **product-builder-resume**, reply with the capsule and the next move, and stop; nothing is written. Pickup ("continue", "pick up"): 1 **product-builder-resume** for the capsule · 2 verify the capsule against git, PRs, and the ledger · 3 claim the work in the ledger (implementation-log row with this session) · 4 continue in the matched playbook from the last completed step.

Pause: 1 commit, or stash with a unique tag, any uncommitted work and name it in the ledger · 2 write the capsule to `docs/plans/<slug>/handoff.md` through **product-builder-resume** `--handoff` · 3 tick or skip-mark every open todo with its state · 4 stop with the capsule as the reply.

**Reply:** the capsule; what was claimed or released; the next move.
