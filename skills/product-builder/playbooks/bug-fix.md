### Bug fix

**You own this task. Reproduce, root-cause, fix with runtime evidence.** Every shipped line traces to evidence; a change that "might help" is a hypothesis and does not ship.

1. Reproduce: the narrowest failing test or scripted repro, on the matching surface per `.product-builder/drive.md`, with its output. Do not hand the repro to the user.
2. Root cause: the mechanism at file:line, and why sibling callers do or do not share it. Use the profile's debugging agent when one exists; **product-builder-how** and **product-builder-why** for the subsystem and the regression history.
3. Premise check: if two fixes already failed this gate, write the shared premise down and attack it before a third.
4. Fix: the smallest change at the root; the regression test stays red then green. A nil check, a retry, or a try/catch without a named mechanism is rejected here.
5. Verify: **product-builder-verify** on the same surface; the original repro now passes; the profile's checks. "Inconclusive" is not a pass.
6. Review: **product-builder-review** on the diff, with the mechanism from step 2 as the intent. Fix loop of at most three rounds, each fix commit through the review skill's fix wave on the fix diff only. A finding that is not about that mechanism (a crash elsewhere, a missing guard on another path, a test that could be stronger) is listed under "your call" with a recommendation and is never fixed in this PR; a bug fix that grows past the mechanism has become a Hardening or a Plan, and the reply says so.
7. `playbooks/opening-a-pr.md`; the body names the mechanism and the evidence.

**Reply:** what was broken, the root cause at file:line, the fix, how it was verified. Paste the failing-then-passing repro output verbatim. The PR URL.
