---
name: product-builder-review
description: Reviews a diff (branch, PR, or working tree) with 3-5 read-only reviewer subagents cast by what the diff touches (always a staff simplicity hawk, a QA engineer, and a product owner; database, security, frontend, SRE, integration, cost, accessibility, adversarial user, silent-failure hunter by signal), each with the stated intent of the change. Merges findings into act on / consider / noted / dismissed with attribution and a confidence score, runs a verifier that re-checks every critical and high against the code, names the one fact a risky diff is safe because of and proves it by running real code, and with a slice contract returns two verdicts: spec compliance against the acceptance lines, and quality, plus deviations from the plan. Use for "review this", "tear this apart", "find blind spots", or from the implement, bug-fix, refactoring, and perf-issue playbooks.
argument-hint: [--diff base..head | --pr N] [--contract path]
---

# product-builder-review

Never edits code. Read `.product-builder/learnings.md` first.

1. Scope and intent: the diff (`git diff <base>...HEAD`, a PR, or the working tree); the intent from the task, the PR body, the commits, then the diff. State the intent in two sentences; every reviewer receives it verbatim.
2. Cast three to five seats with reasons. Always: staff engineer (simplicity, DRY, YAGNI, divergence from existing patterns), QA engineer (are the tests meaningful, edge cases), product owner (does the change serve the stated intent, scope creep). By signal: database or migration, security, frontend, SRE or resilience, integration, cost, accessibility, adversarial user; a silent-failure hunter whenever the diff touches error handling, retries, or async code. The profile's reviewers-by-path are mandatory seats when their paths are touched.
3. Dispatch in parallel, read-only, self-contained prompts: the intent, the list of changed files with the base and head refs (never the raw diff when it is over 300 lines) and an instruction to read them, the seat's mandate, and the output schema (severity, confidence 0-100, file:line, the concrete failure scenario, the suggested change; at most 40 lines; pointers, not payloads).
4. Verifier pass by you: re-check every critical and high against the code; drop what does not survive. Below 60 confidence lands in noted. For a diff that touches shared code, name the one fact it is safe because of and prove it with a script or test that runs the real code; if you cannot prove it cheaply, mark it unproven.
5. One block, at most eight lines, grouped by bucket with seat and confidence; an agreement map in one line; the rest counted, dismissed with reasons.
6. With `--contract`: the spec-compliance verdict (each acceptance line: covered by a named test or live check, or not) and the quality verdict, both required; deviations from the plan's change table named for the Revise playbook.
7. Rulings: apply what the contract allows; hand the rest back to the calling playbook as a "your call" list with recommendations rather than asking here, unless the review was invoked directly by the user, in which case one multi-select over the act-on and consider items, at most four per question. Record in the ledger when a plan exists.

**Reply:** the intent; the cast; the findings block; the safety fact and its proof or "unproven"; with a contract, both verdicts and the deviations; what needs the user.
