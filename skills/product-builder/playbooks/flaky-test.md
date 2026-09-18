### Flaky test

**You own the mechanism, not the retry.** A test that passes and fails on the same code. Quantify it, isolate it, fix the cause or quarantine it with an owner. Never add a retry, a sleep, or a looser assertion without a named mechanism.

1. Quantify: run the test alone N times and inside its suite N times with CI's exact lane configuration (pool, isolation, order, shards); record the failure rate for each and the failure output verbatim.
2. Isolate by the pattern of step 1. Fails only in the suite: shared state or order (run with the tests before it, then without). Fails alone: timing, a real race, or an external dependency (clock, network, filesystem, a port). Fails only in CI: environment (concurrency, resources, a missing service). One hypothesis at a time; each run is evidence for or against it.
3. Root cause at file:line, in the test or in the code under test. A flaky test that exposes a real race in the product is a Bug fix, routed there with the repro.
4. Fix at the cause: an awaited promise, a unique fixture, a fake clock, an isolated port, a deterministic order. Re-run step 1; the rate is zero over the same N or the fix is not done.
5. Quarantine only when the cause needs more than the appetite: skip with the reason, the failure rate, the issue link, and an owner in the skip message. A quarantine with no owner is a deletion.
6. **product-builder-review**, then `playbooks/opening-a-pr.md` with the before and after rates in Verification.

**Reply:** the rates alone, in suite, and in CI, before and after; the mechanism at file:line; the fix, or the quarantine with its owner; the PR URL.
