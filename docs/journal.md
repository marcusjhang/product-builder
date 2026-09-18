# Run journal

Field runs of the suite, one entry per run, newest first. Each entry records the shape of the run, the score its user gave, what the suite did or would have done, and the changes the run produced. Repositories, products, and people are not named; the point is what the suite learned.

## 2026-09-19, a Bounded plan run from files, scored per skill on a five-point scale

**Shape.** The session began as a question (does a decision model make sense for a search box), became a build, was stopped, and became a plan: an opt-in that lets a decision model rerank the rows a search box already found, off by default, one PR. The suite was not installed; the agent read the mode, the plan playbook, the interview bank, the principles, the writing rules, the templates, and six leaf skills from a checkout and reconstructed every step from prose. Setup wrote a profile in about twenty tool calls with no question; the launch validation was skipped as paper-only. Intake carried five decisions the user had stated in chat; the interview still asked three frame questions and one decision question, and every answer took the recommendation. Research ran zero explorers because the session had read the area an hour earlier, re-anchored everything at the baseline, and recorded one spike as blocked by a dead key. The tech-lead panel cast four seats and found five structural defects the author had missed; applying the rulings was a rewrite. The Definition of Ready printed green with the blocked spike as an accepted risk. Verify then spent almost all its effort on the environment: a closed cache port, missing packages, a rotated database credential, a login page that proxied to another host, a local database clone, a minted session cookie.

**Scores.** Mode 4, setup 3, plan 4, interview bank 3, research 4, tech lead 5, templates and Definition of Ready 4, verify 3, implement 3, opening-a-pr 2, reflect 2.

**What held.** The Bounded caps kept the interview to four questions. Premises at G1 gave the panel the sentence it later used to reject a shared code path. Explore-before-ask answered workaround, constraints, and prior attempts from the repo. Zero explorers was the right call and the rule allowed it. The tech-lead panel was the highest-value step: latency coupling, a dedupe that swallowed the best row, a request that would have failed validation for one cohort, a dead abort path with a dead test, fifteen queries per keystroke. The verifier pass made the agent re-read the code before accepting any of it. The hawk's four cuts each contradicted a decision the user had just locked and sit in the ledger as dismissed with the decision named. ASSUMED rows kept the session moving. The printed Definition of Ready made ready a fact.

**What fought.**

- Not installed, so hand-driven; nothing said what to read first.
- The Bounded row said one page per doc; the templates said two and three and demanded tables no one-page doc can hold. Both docs came out at three and a half pages.
- Nine replies to Ready against a budget of five to seven, with three frame questions re-asking what the chat had settled.
- Setup skipped the two facts that later cost an hour: a rotated database credential and a login proxy set by the provisioning script.
- The success-signal question asked for the number and the window, not the numerator, the denominator, and the grain; the draft counted them at different grains and would have fired the kill criterion on a perfect feature.
- The mode said tech lead alone on Bounded; the skill said two to four; the agent cast four and spent ten minutes.
- The panel reviewed a moving tree; rulings from the first seat back were applied while the others ran.
- The reviewer prompt is written for plans; with a draft in the tree, two seats would have anchored to the tree without an ad hoc instruction.
- opening-a-pr assumed a PR asset upload that `gh` does not have, and the Evidence section it cites was not in the schema setup pointed at.
- verify assumed a validated `drive.md` and had no step for a login that leaves localhost or a credential that fails.
- A blocked spike had no rule; the agent invented `verdict: blocked, owner`.
- A mock decider shipped as forty lines because no cheaper standard path (the preview environment) was named.
- Ledger bookkeeping took about fifteen tool calls; a one-word change to an agent-owned technical call cost a superseding row.
- After the user delegated the rest of the run, two real blockers were still asked one per reply.
- Same-session artifacts (a design doc, a draft build) were cited as prior attempts and then left beside the plan folder with overlapping content.
- One PR with slices as commits was done as an exception rather than a supported shape.
- The frontend seat caught a test that could not fail (a synthetic click before a focus assertion); no skill said that is a finding.

**Changes accepted, fifteen.** All of the above have a rule now; see the CHANGELOG paragraph for this date. **Backlog.** A script for ledger rows, so bookkeeping is one call per row rather than a string replacement.

## 2026-09-19, a feature built without the suite, scored 5/10

**Shape.** A one-line ask for a feature with an AI lane (a decision model answering typed questions). The suite was not installed in the worktree and nothing routed the ask through it. The session fast-forwarded a checkout several hundred commits behind, read the codebase for the model's real contract, mirrored a recent precedent, fetched the provider's live API description to check a limit, and built the feature as one PR of about 1,400 lines across a dozen files with unit tests. Three review rounds with the repo's own multi-agent review followed: round one cast twenty seats in four waves and found three highs, all reproduced; round two found no highs but three regressions caused by round one's fixes; round three verified round two's fixes. Verification against the real model was still pending at the time of the write-up.

**What the suite already had, applied by hand.** The baseline rule (fetch, count, reset or rebase, stale threshold). The review skill's verifier pass and the sixty-confidence floor; the verifier killed fourteen claims in round one. The research skill's spike for a third-party API's real shape. The PR body's Blast radius and Verification sections. The judge, whose finding gates use the same kind of model the feature integrated.

**What was missing.**

- Discoverability. Nothing said the suite existed; the setup command fires only when the user remembers it.
- Three product calls (a naming rule, the meaning of an "any" match, a threshold) were resolved as execution calls, and two were wrong.
- A display gap. The feature wrote values the main screen could not show or remove. The interview bank's states question and the Definition of Ready's five-states line would have caught it before code; a reviewer caught it after.
- No appetite check, so one large PR where the suite would have demanded riskiest-first slices.
- Fixes moved boundaries (a narrowed catch, a close order, a name cap) and nothing re-reviewed the fix commits; the regressions were caught only because a second full round ran.
- An untouched test that read a changed file by path failed on the branch; a changed-files run could not see it because the test has no import edge.
- The request payload was measured only because two reviewers chose to; a wording-only edit spent headroom silently.
- Prompt text was code no seat read as the model would; a self-contradicting instruction reached round two.
- The forge had two logins and every push needed a workaround the profile did not record.

**Changes accepted, nine.** The first-run hook. The fix wave in review, called from implement and babysit. Backwards-compatibility, prompt-quality, and cost seats by signal in review, and the cost seat in techlead. The CI-exact regression lane and the path-read test grep in verify, with the lane recorded at setup. The forge login recorded at setup and used by opening-a-pr. The round-trip question in the interview bank and the designer's panel prompt. The AI-lane line in the Definition of Ready. The Built first playbook for code that exists before a plan.

**Changes rejected, one.** A default review cast of twenty seats. The three highs came from seats missing from the cast, not from too few seats; the two seats are now cast by signal and the default stays three to five.

**Also added.** Nine playbooks for asks the routing table had no row for: incident, spike, dependency upgrade, data migration, removal, flaky test, release, decision record, hardening.

## 2026-09-18, two stacked model-routing features planned, reviewed, and shipped

**Shape.** From a behavioural-validation brief on an open PR, the session built a live rig (isolated database and cache, a gateway stub, seeded fixtures) and then used the plan playbook, the tech-lead panel, the multi-agent review, and a verifier round for two features in sequence: a classifier that fills a record's metadata at creation, and a router that picks a model per record on two paths. Both were re-sized from Feature to Bounded, shipped inert behind a flag with a shadow mode, and validated live against a mocked model API with database and telemetry evidence plus a browser pass.

**What held.** The decisions ledger with tech-lead rulings was the standout: every scope and UX call named, statused, and sourced, so a post-review scope change was an amended row with a rationale rather than a reopened design. The tech-lead panel killed a sentinel value that collided with an existing name before any code existed. The re-sizing to Bounded, backend first, UI as a follow-up, is what made the change safe to merge. Two review seats converged independently on the same real high (an un-timed-out external call on a launch hot path), which says the seats are not redundant. Prior art gave the default an external anchor.

**What fought.**

- The plan doc drifted from the rulings: `product.md` kept describing the sentinel the panel had overruled, and only a review persona noticed. Nothing reconciled the docs against the rulings table.
- The plan reasoned about "the create path" as if singular; there were two, and the second was found unrouted in review. No change-site census.
- Non-functional requirements were absent from the ledger; the timeout on a synchronous external call surfaced as the top review high instead of a design decision.
- A behavioural clause ("re-resolve when the record changes materially") was locked without a feasibility check and turned out to be unimplementable in scope; the implementation had to drop a locked decision.
- Rollout safety was implied: "do not go live before the model is visible and overridable" became a review high instead of a first-class gate.
- Hand-run from files, the profile untracked per worktree, no single command running plan to review to verify.

**Changes accepted, six.** Reconciliation in the plan's verify step with a Definition of Ready box; a change-site census in research and the changes table; an External calls section in `implementation.md` and its Definition of Ready line; a detection mechanism and cost per behavioural clause before a decision locks; a live gate on the Rollout line, checked by ship's pre-flight; setup asks once whether to commit `.product-builder/` and recommends it, and the README says to install rather than read from files.
