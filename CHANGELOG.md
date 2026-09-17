# Changelog

## Unreleased

A judge. The profile may name a decision model (`Judge` section: `Model: typesafe/jev-latest | none`, `Mode: shadow | gate`) that six gates consult through `skills/product-builder/scripts/judge`, with every question and threshold in `skills/product-builder/references/judge-questions.json`: `question-gate` runs as a `PreToolUse` hook on the question tool (`hooks/hooks.json`) and, in `gate` mode, blocks a question an experiment or a read would settle; `anchor` checks a file:line claim against its excerpt (how, research); `spec-line` checks an acceptance line against the test that claims it (review `--contract`); `finding` and `finding-pair` bucket panel and review findings with a calibrated confidence (pm, techlead, review, personas); `pr-comment` triages review comments (babysit). `shadow` mode logs verdicts to `.product-builder/judge-log.jsonl` and changes nothing; setup writes `shadow`, reflect reads the log and proposes `gate`. No key or `Model: none` keeps every gate on the session model, said once per run. Not yet run against the live API.

## 0.1.0 (2026-09-16)

First release. The mode, fourteen playbooks (plan, revise, implement, qa, ship, program, investigation, bug-fix, refactoring, perf-issue, babysit, pickup-and-pause, opening-a-pr, plan-interview), thirteen leaf skills (setup, how, why, research, prototype, personas, pm, techlead, review, verify, resume, reflect, plain), the plan templates with the Definition of Ready and Done, the principles, the interaction model, the writing rules, a default profile and a worked example, and the design plan, research landscape and stress-test record under docs/. Shaped by six scenario runs against a real repo with simulated users; see docs/stress-test.md.
