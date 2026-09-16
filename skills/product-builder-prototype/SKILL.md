---
name: product-builder-prototype
description: Builds a throwaway prototype to settle one named product or UX decision. Standalone clickable HTML (default) with variants behind a switcher and a catalog where every user story and state is a jump; an in-app spike on a branch that is never merged when the feel depends on real data; or a contract sample (requests and responses, CLI transcript, event payloads) for non-UI surfaces. Uses the project's design tokens, checks readiness, serves and screenshots it, presents alternatives with a recommendation, records the decision in the plan ledger. Use when the Plan playbook marks a decision "→ prototype", or for "prototype X", "mock this up", "let me click through it".
argument-hint: [slug] [--decision "..."] [--mode html|in-app|contract]
---

# product-builder-prototype

No decision, no prototype: name the decision first (from the ledger's `→ prototype` marks, or one question). Throwaway: speed over polish, no tests, no abstractions, never imported into the app. Read the closest existing feature's screen first so the prototype matches the app's shape; use the tokens in the profile.

Modes:
- **Standalone HTML** (default for UI feel): one `docs/plans/<slug>/prototype/index.html`, vanilla HTML, CSS, JS, CDN dependencies allowed; a catalog sidebar listing every story `S1..Sn` and every state (loading, empty, error, populated, live) as a jump; variants `A/B/C` via `?v=` and a floating switcher; state visible after every action; in-memory only; realistic data, real copy, never placeholder text; the flag-off state shown when rollout uses a flag.
- **In-app spike** (feel depends on real data, latency, or a real component): branch `<slug>/spike-<decision>` behind the feature flag, the smallest code that renders the idea, never merged; screenshots and the decision recorded, the branch left to expire.
- **Contract sample** (API, CLI, job, event): `docs/plans/<slug>/prototype/contract.md` with example requests and responses, a CLI transcript, or payloads for every story and failure line; consumer personas read it.

Steps: 1 name the decision · 2 read stories, personas, tokens, the closest screen · 3 pick the mode and build · 4 serve with `${CLAUDE_SKILL_DIR}/scripts/serve.sh <dir> [port]` (prints the URL; `--stop` ends it) · 5 readiness check in the browser driver from the profile: click every catalog row, screenshot each variant and story to `prototype/shots/`, fix what is broken; no driver → check by reading the rendered file and say so · 6 present variants, trade-offs, recommendation; ask only if variants differ on a product call · 7 record: ledger decision row with the prototype as evidence, `Prototype:` header line in `product.md`, `Verified by: prototype #` on stories.

"If a row cannot be clicked, the plan is not done."

**Reply:** the variants explored, the evidence (screenshot paths), trade-offs, the recommendation, the prototype path. Say plainly that it is throwaway.
