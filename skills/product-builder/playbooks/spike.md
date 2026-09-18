### Spike

**You own the verdict, not the code.** A time-boxed answer to "can we", "how hard is", or "does this API do what we think", on a branch that is never merged. The deliverable is a verdict with evidence; the code is scaffolding.

1. The question as one sentence with a yes or no or a number in it, the budget (hours or turns), and what each outcome changes about the plan or decision that asked. A spike with no consumer decision is research; route it to **product-builder-research**.
2. The cheapest experiment that answers it: a probe script with a real call (secrets redacted, never production credentials), a mock stub, a throwaway branch `spike/<slug>`, a benchmark. Name the pass and fail predicate before writing it.
3. Run it. Record the command, the output, and the numbers verbatim to `docs/plans/<slug>/research.md` under Spikes, or to `docs/spikes/<slug>.md` when no plan exists.
4. Verdict at the budget, not after: yes, no, or "unknown, because", with the evidence path. An unknown names the next experiment and its cost rather than extending this one.
5. The branch is deleted, or kept with `spike/` in its name and a link to the verdict; nothing from it is cherry-picked without going through Plan or Implement.

**Reply:** the question; the experiment and its command; the output verbatim, cut to what decides it; the verdict; what it changes for the decision that asked.
