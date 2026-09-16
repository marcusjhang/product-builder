### QA

**You own the verdict. Charter from the stories, prove each line on the real app, report with evidence.**

1. Inputs: slug; target (PR preview, staging, or local per `.product-builder/drive.md`); which slices are merged; how to flip the flag there; the mode: diff-aware (default: the surfaces in the changes table plus the pages `git diff <base> --stat` touches), full, quick (a five-minute smoke pass), or regression against a saved baseline.
2. Charter table: story, acceptance line, how tested (test name, persona, or lane), role.
3. Automated: the profile's suites and journey-test tools.
4. Acceptance: **product-builder-personas** in live mode against the target with the story filter.
5. Exploratory pass by a QA-engineer subagent: flag off shows the old behaviour and flag on the new; empty and first-run states; every failure line; each role in the permissions matrix; two users at once; mobile width; slow network; keyboard path and icon labels.
6. Instrumentation: the events named in `product.md` fire with their properties, checked in the analytics tool or the logs.
7. Rollback rehearsal: flip the flag off, confirm the old behaviour and no orphaned data.
8. Regression on the surfaces in the changes table through **product-builder-verify**.
9. Write `docs/plans/<slug>/qa-report.md` from the template: verdict, per story pass or fail with evidence, bug table, coverage gaps, environment.
10. Fix tier, when the user asked for fixes or the bug is trivially local: one fix per bug, the smallest change at the source, one commit per fix named `fix(qa): <bug id> <description>`, a regression test per verified fix that reproduces the exact precondition and asserts the correct behaviour (not merely "no crash"), a before and after screenshot pair, then re-test the affected surface. Stop fixing when a fix needs more than one file outside the slice's files, when a fix was reverted, or when the risk of a wrong fix exceeds one in five by your own estimate; the rest go to the bug table.
11. Health score: the share of charter lines passing, before and after fixes, in the report.
12. Feed back: remaining bugs to tickets on request or to Implement fix slices; status QA passed or QA failed.

**Reply:** the verdict first; the health score before and after; per story pass or fail with its evidence path; fixes made with their commits and regression tests; the bug table; what could not be tested and why; the next move (Ship, or Implement for the fix slices).
