### Plan interview reference

Rules: one question per reply; a recommended answer with a one-line reason under every question; explore the repo before asking; depth-first, dependencies first; stop when the frontier is empty, when three answers in a row raise nothing new, when the answer is predictable, when the user signals fatigue (record the rest as Open), or when the decision is cheaply reversible (do not grill it). "skip" or "you decide" takes the recommendation and records it ASSUMED. If the user says "I'll answer later" or names a stakeholder who holds the answer, write `docs/plans/<slug>/questions.md` (most important first, one question per heading, recommended answer and an answer stub under each) and continue on the recommendations as ASSUMED.

Interview 1 bank, in priority order, ask at most eight:

1. Trigger story. "What happened that made this worth doing now? Tell it as one concrete situation, with a name if you have one." Explore first: recent issues, support notes, commits in the area. Push back on a vague framing: a category of users is not a person.
2. Who, and how do you know. "Who has this problem, how often, and what is the evidence (a ticket, a message, a metric, a guess)?" Explore first: `.product-builder/personas.md`. Label the evidence.
3. Today's workaround. "What do they do today instead, and what does that cost them?" The workaround is usually the smallest solution's competitor.
4. Done. "If this shipped perfectly, what does that person do differently, or what stops happening?"
5. Narrowest wedge and appetite. "What is the smallest version that solves the story in question 1, and is it one PR this week, a few PRs over a couple of weeks, or a program?" Recommend the wedge first; the full vision goes to Deferred.
6. Non-goals. "What are we explicitly not doing even though it is adjacent?" Recommend from adjacent features in the repo.
7. Constraints. "Anything fixed: dates, must-use or must-not-use tech, compatibility, decisions already made?" Explore first: ADRs, glossary.
8. Success signal and kill criterion. "A week after shipping, what tells us it worked, and what would tell us we were wrong?" Ask for the baseline number here when one exists. Write the hypothesis with the user's own numbers and windows, verbatim; the kill criterion is a separate number, never a restatement of the baseline.
9. Prior attempts. "Has this been tried or drafted before?" The intake probe has already searched the plan root, design docs, branches, other worktrees, and the log; quote its answer and ask only what it left open.
10. Stakeholders. "Who else must agree, and who will be surprised?"
11. Observation. "What did you notice about this problem that the obvious solution misses?" Ask only when the answers so far are conventional; it is the question that changes the framing.

Closing interview 1: state the three to five premises the plan will rest on ("members defer rather than dismiss", "the sweeper is the right place for unsnooze"), each as one sentence the user can agree or disagree with. Present them as the G1 block and ask once, with the question tool: agree with all, or name the one to change. A disagreed premise is rewritten before research starts.

Interview 2 categories with sample forcing questions: scope forks from research ("the code has X and Y paths; both, or only X, and why?"); terminology ("the glossary calls this a Stack; you said bundle; which word?"); defaults and permissions ("who can do this by default, who must never, what does a viewer see?"); states and copy ("what does the empty state say, what happens on failure, what does flag-off look like?"); destructive actions ("undo, confirmation, or neither?"); story priority ("which story goes first if the appetite runs out?"); seam ("reuse seam A, recommended because …, or add B?"); rollout ("flag with a cohort, dark launch, or everyone?"); instrumentation ("which event proves the success signal, and what property makes it queryable?"); assumptions ("what must be true for this to work, and how much evidence do we have?"). Forcing patterns: why X and not Y; what is the kill criterion; what is blocking the decision; which side of the trade-off; what is the dependency; even at 60% confidence, what is the call today.

Story format:

```
### S1. <short name>
As a <persona>, I want <capability>, so that <benefit>.
Surface: <screen or endpoint or command> · States: loading, empty, error, populated, live   (UI)
Consumer: <who calls it> · Contract sample: <request → response, transcript, or payload>   (non-UI)
Acceptance:
- WHEN <trigger or context> THEN <observable result>
- WHEN <failure or edge> THEN <observable result>
Permissions: owner …, member …, viewer …   (when roles exist)
Priority: must | should | later · Verified by: prototype catalog #, persona walkthrough, <test name>, QA
```
