### Ship

**You own the launch, not the flip. Pre-flight, prepare, watch, close.**

1. Read the plan and the profile's flags, analytics, observability, and deploy reality.
2. Pre-flight: walk the Definition of Done items that precede the flip; a red item routes back to QA, Implement, or docs. The live gate from `product.md`'s Rollout line is its own box: when the feature can change what a user sees without their action, what must be visible and overridable to them is verified on the deployed head before any stage past internal users; a shadow mode stays shadow until that box is green. Freshness: the review and QA verdicts must name the head SHA that is deployed; a verdict for an older head is stale and is re-run before the flip.
3. Prepare, never execute: the rollout stages in order (internal users, a named cohort, a percentage, everyone) each with the check that gates it, the kill switch, the changelog or docs entry, the support note, the announcement draft. The user flips and announces (G9, irreversible and external).
4. Watch. Canary in the first hour after each stage: the touched surfaces load without console or server errors, the instrumentation events arrive, the flag-off path is unchanged. Then, after the window in `product.md` (default three days): run the success-signal query against its baseline, compare error rates and latency on the touched surfaces against the week before, sample the instrumentation events.
5. Close: status Shipped, ship-log row with the numbers; schedule flag removal as a follow-up slice or ticket; if the signal is missing or errors rose, present the revert path (flag off) and route to Revise or Bug fix; offer **product-builder-reflect**.

**Reply:** the pre-flight with each box; the rollout stages and their gates; what the user must flip and announce; after the watch, the success signal against its baseline, error rates against the prior week, the flag-removal follow-up; status.
