# product-builder principles

Seventeen standing rules. Skills cite them by number. A repo appends its own in `.product-builder/principles.md`.

## Contents
- Product and process (1-12)
- Engineering (13-17)

## Product and process

**1. Explore before you ask.** If the codebase, git history, or docs answer a question, read them and say what you found. Ask the user only for intent, priorities, and product calls. A question the code could have answered costs a turn and signals that the agent did not look.

**2. One question at a time, with a recommended answer.** Bundled questions get partial answers. Each question carries the agent's recommendation and a one-line reason, so the user can disagree with the reason rather than only the answer. Two exceptions: a set of user stories is presented as a numbered list, and reviewer rulings are a multi-select over at most four findings.

**3. Product calls are the user's. Execution calls are the agent's.** Naming, scope, defaults, who sees what, what gets cut: stop and ask. Data shape, seam, file layout, test strategy: recommend, proceed, record, and let the user course-correct.

**4. Never block on reversible work.** The user supervises asynchronously. If they are away, record the recommended answer as an `ASSUMED` row in the ledger and continue; list assumed decisions first at every hand-off. Stop for product calls and for irreversible actions: merge, push to a shared branch, a migration against a shared database, a delete, an external message.

**5. The simplest change that could work.** Reuse an existing seam, then the framework or standard library, then an installed dependency, then new code. Every new abstraction, table, or dependency is justified in writing or removed. Subtract before you add. Minimum means the least code that solves the problem correctly, not the fewest lines.

**6. Every current-state claim carries `file:line` read at a named SHA.** Plan headers name the baseline commit. A claim without an anchor is a guess and is labelled as one. When main moves, anchors are refreshed, not trusted.

**7. Non-goals are as firm as goals, and the appetite bounds the solution.** Write what is cut and why, and what would bring it back. A rabbit hole gets a decision that keeps it shallow, not a wish.

**8. Decide by prototype, not debate, when the question is feel.** Layout, interaction, density, copy: build two or three throwaway variants behind a switcher and let people click. Logic and data questions are decided on paper or by a spike. No named decision, no prototype.

**9. Verify with the audience, not just the author.** Personas from the plan's own audience click through the prototype or the build. A tech-lead panel reads the implementation plan against the code. Reviewers read the diff. Findings land in four buckets: act on, consider, noted, dismissed. Dismissed stays visible with its reason, and the user rules on the first two.

**10. Vertical slices, one PR each, each verifiable.** A slice cuts through every layer for one story or story fragment and can be demoed alone. Prefer five narrow PRs to one wide one. Dependent slices stack.

**11. Plans are living documents with a ledger.** Decisions are superseded, never silently rewritten. Every revision has a date, a trigger, and the phases it re-ran. Post-implementation corrections are a dated note at the top, not an edit of the decision record.

**12. Rough means short.** `product.md` fits in about two pages and `implementation.md` in about three. Evidence lives in `research.md`, reasons in `decisions.md`, and the plan links to them.

## Engineering

**13. Fix root causes.** Trace the symptom to the mechanism and name it at `file:line`. A guard, retry, or catch that silences the symptom is not a fix. Check sibling callers for the same mechanism.

**14. Prove it works.** Verification means the surface that matches the change: a UI change is clicked, a CLI change is run, an API change gets a real request, a migration is replayed, a perf change is measured against its baseline. Evidence is a screenshot, a log line, a response body, a number with a unit, or a SHA. "The build passed" and "inconclusive" are not passes. Before any claim of done, fixed, or passing: name the command that proves it, run it fresh in the same reply, read the whole output, and show it. "Should work", "probably passes", and "done" ahead of that run are forbidden.

**15. Sequence work into verifiable units.** Break work into units that each end in a state you can check, and check each before the next. Stack commits and PRs in the order that proves the work: the failing test, then the fix.

**16. Attack the premise.** When two fixes that share one premise have failed the same gate, write the premise down and question it before writing a third fix that assumes it.

**17. Test behaviour, not implementation.** Tests pin what the user or caller observes, so a refactor that preserves behaviour stays green and a change that breaks it goes red.
