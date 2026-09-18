### Hardening

**You own the gaps, not the redesign.** Adding tests, error handling, input validation, or observability to code that works but is thin, with no behaviour change on the happy path. Every addition names the failure it now catches.

1. Map the area through **product-builder-how**: entry points, inputs, failure modes, what is tested and what is not (the coverage report when the profile has one, else the test names against the public functions).
2. Gap table: the failure mode, where it enters, what happens today (traced or reproduced, with output), what should happen, the test that would prove it. Rank by blast radius times likelihood; when the table exceeds the appetite, the user picks the cut with one question.
3. Characterise the happy path first: tests that pin current behaviour before any guard is added, green at the baseline.
4. Per gap, one commit: the failing test that reproduces the gap, then the smallest guard that closes it with a named error, a typed result, or a logged event with its properties. Never a bare catch, a silent default, or a retry without a mechanism. The happy-path tests stay green in every commit.
5. Silent-failure sweep by a subagent over the area: catches that swallow, defaults that hide, logs at the wrong level, timeouts without a limit; each becomes a row in the gap table or a `noted` with the reason.
6. **product-builder-review** with the silent-failure hunter and QA seats mandatory; `playbooks/opening-a-pr.md`, Verification showing each gap's test red then green.

**Reply:** the gap table with what was cut; per gap, the test and the guard; the happy-path characterisation; the PR URL.
