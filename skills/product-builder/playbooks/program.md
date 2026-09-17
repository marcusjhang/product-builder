### Program

**You own the overview. Parts are shippable increments, each planned with the Plan playbook.**

1. Overview interview, at most six questions: the problem, who, the appetite for the whole, the parts as the user sees them, what lands first, what is out. The intake probe from `playbooks/plan.md` step 1 has run before this interview; its three lines (ships, closest feature, target tree) open the first question, and a `ships` or `partial` verdict is stated before any part is named.
2. Research at overview depth: the subsystems each part touches and the shared decisions (vocabulary, data ownership, order of landing).
3. Write `docs/plans/<slug>/README.md` from the overview template: parts table, each part a shippable user-facing increment, never a layer; part 1 is the walking skeleton.
4. One **product-builder-techlead** pass on the ordering and the shared decisions.
5. Run `playbooks/plan.md` per part under `docs/plans/<slug>/parts/<part>/`, sharing the root ledger.
6. The overview's Definition of Ready is the union of the parts'.

**Reply:** the overview path; the parts table with order and status; the shared decisions; which part is planned next.
