---
name: product-builder-pm
description: Casts a product panel of read-only subagents over a product plan: a product manager (problem, audience, stories, non-goals, appetite, existing leverage, decisions needed now), a skeptic (what breaks the hypothesis, what the workaround already solves), a designer (surfaces, states, copy, keyboard and mobile, scored 0-10), a data analyst (success signal as a hypothesis with baseline, target, guardrails; instrumentation that can answer it), and a customer voice from the persona roster. Then asks one scope question: hold, reduce to the wedge, selective expansion, or expansion. Merges findings into act on / consider / noted / dismissed with attribution and confidence, applies accepted edits, records rulings. Use when the Plan playbook reaches verification, or for "review my product plan", "is the PRD solid", "poke holes in the stories".
argument-hint: [slug] [--seats pm,skeptic,designer,analyst,customer]
---

# product-builder-pm

1. Read `product.md`, `decisions.md`, `research.md`, `.product-builder/personas.md`, `.product-builder/learnings.md`, and the profile's analytics convention.
2. Cast three to five seats. The PM and the skeptic always sit; the designer when a UI story exists; the analyst when a success signal or instrumentation is claimed; the customer voice from the roster. Say the cast in one line.
3. Dispatch in parallel, read-only, each with `${CLAUDE_SKILL_DIR}/references/panel-prompt.md` filled for its seat.
4. Verifier pass: drop findings the plan already answers; keep confidence; below 60 lands in noted. When the profile names a judge, run its `finding` gate over every returned finding first through `${CLAUDE_SKILL_DIR}/../product-builder/scripts/judge` (`--batch`; state: the finding and the `product.md` section it names, verbatim); in `gate` mode its `already_answered` verdict does the dropping and its bucket and confidence replace the seat's, in `shadow` mode they are logged beside yours.
5. One block, at most eight lines, grouped by bucket with seat and confidence, the proposed edit attached. Apply the reversible edits to `product.md` (stories, states, copy, assumptions, instrumentation, non-goals, deferred) and list them. Rulings that cut scope or change a product call are asked with one multi-select and the reply ends there; never write "waiting on you" and continue. Record every ruling in `decisions.md`.
6. Scope question, one, with the question tool: hold scope (recommended when the appetite check passed); reduce to the wedge (the smallest version that still moves the signal, the rest to Deferred with what brings it back); selective expansion (the panel's one or two high-impact additions, each its own yes or no); expansion (only when the user asked to think bigger). Apply the answer to `product.md` and the ledger.
7. Anything that changes a slice goes to **product-builder-techlead**.

**Reply:** the cast; the findings block; what was applied; the scope answer; what needs the user; "prior learning applied" where it did.
