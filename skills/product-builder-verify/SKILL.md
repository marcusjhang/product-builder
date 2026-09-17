---
name: product-builder-verify
description: Verifies a change on the surface that matches it, per .product-builder/drive.md. A UI change is clicked through in a real browser, a CLI change is run, an API change gets a real request and response, a migration is replayed on a scratch database, a job is triggered and its side effect read back, a flag is checked in both states. Returns evidence (screenshots, logs, response bodies, exit codes) and a pass or fail per scenario. Never accepts "the build passed" as proof. Use for "does this work", "prove it", "run it like a user would", or from any playbook that just changed code.
argument-hint: [scenario ...] [--target url]
---

# product-builder-verify

1. Read `.product-builder/drive.md`: launch command, readiness signal, login or seed, selectors, flag flip, teardown. When an installed browser-testing skill provides a server-lifecycle helper and headless-browser conventions, use it instead of hand-rolling them.
2. Pick the surface by what changed: UI → the browser driver in the profile; CLI → run it; API → a real request with the real client; migration → replay on a scratch database; job → trigger it and read the side effect back.
3. For each scenario: the click path or command, the observable result, the pass predicate, and the flag state. Write them down before driving.
4. Drive it. Capture evidence to the scratchpad first, then move what a claim will cite to its home per the profile's Evidence section: text (response bodies, log lines, exit codes, command transcripts) to `docs/plans/<slug>/evidence/<slice>-<scenario>.txt`, screenshots and recordings to the PR as attachments or to the artifact store the profile names; a binary is committed only when the profile says so. The reply and the ledger cite the durable path, never the scratchpad. Run the command in this reply; a pass claimed from an earlier run is not a pass.
5. Regression lane on trunk when the scenario is load-bearing and trunk has the feature: the same scenario at the base, compared.
6. No driver reachable → say so in one line, run what can be run (commands, requests), and mark the UI scenarios "not verified, no driver" rather than inferring.

**Reply:** per scenario: pass or fail, the evidence path or output, the flag state. "Inconclusive" is a fail and says why.
