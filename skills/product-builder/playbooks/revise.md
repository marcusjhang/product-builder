### Revise

**You own the plan's history. Classify the trigger, re-run only what it touches, supersede, never rewrite.**

1. Load every file in `docs/plans/<slug>/`. Print status, baseline, last revision, open ASSUMED rows, and the rejected list.
2. One question for the trigger, with the question tool: (a) requirement or scope change, (b) new fact or main moved, (c) review or QA finding, (d) implementation friction, (e) wording only, (f) post-implementation correction.
3. Apply the matching row. Wording: edit in place. Decision change: old ledger row becomes `superseded by Dn`, new row with why, touch the sections, mark dependent decisions `re-check` and walk them; if the new decision re-introduces a rejected idea, say so and ask. Scope or story change: interview 2 on the new branch only, stories updated, coverage and appetite checks, slices adjusted, personas on changed stories, tech lead on changed slices. New fact or main moved: **product-builder-research** in delta mode, refresh anchors, re-check approach and changes table, tech lead if the changes table changed. Implementation friction: deviation row in the implementation log; supersede the decision, split the slice, or scrap the approach for that slice; never patch silently. Framing change: back to interview 1 and say so. Post-implementation correction: a dated `> Update` blockquote at the top of the doc; the decision record is never rewritten.
4. Baseline drift: if `origin/main` moved since the header SHA, diff the paths in the changes table and update the header.
5. Status: back to Drafted or Prototyped if verification was invalidated, else unchanged; re-run the Definition of Ready if the plan was at Ready to implement or later.
6. Revision-log row.

**Reply:** the trigger and its classification; what changed, section by section; decisions superseded and by what; steps re-run and their results; what still needs the user.
