# Example profile: Cal.com

A worked example of `.product-builder/profile.md`, filled in the way `product-builder-setup` fills it, for a public repository: [calcom/cal.com](https://github.com/calcom/cal.com), a Next.js and Prisma monorepo with feature flags, telemetry, Playwright, and a rules directory written for AI agents. Every fact names where it was read, at `main` @ `6bc45298` (read 2026-09-14). Copy the shape; re-read the facts, they move. The section list is the contract every playbook reads.

## Contents
- Baseline
- Stack and commands
- Where docs live
- Domain language and law
- Agents by phase
- Skills by phase
- Browser drivers
- Design tokens and UX invariants
- Architecture canon
- Deploy reality
- Feature flags
- Analytics and instrumentation
- Required reviewers by path
- Tracker
- Observability
- Forge
- Evidence
- Judge
- Companion files

## Baseline

Default branch `main`. `git fetch origin --prune && git rev-list --left-right --count HEAD...origin/main`. If the branch has no unique commits and `git status --porcelain --untracked-files=no` is empty, `git reset --hard origin/main`; otherwise rebase. Record the SHA and the behind-count in every plan header. Stale threshold: 100 commits behind; above it the plan asks which tree is the target and reads anchors from `origin/main`. The repo's own rule for shared branches is never force push or rebase them (`AGENTS.md` Never do; `agents/rules/ci-git-workflow.md` Never Force Push); that is about shared branches, and a local worktree still moves onto `origin/main`.

## Stack and commands

TypeScript. Next.js App Router (`apps/web/app/`, `AGENTS.md` Key files), tRPC (`packages/trpc/server/routers/`), Prisma on Postgres (`packages/prisma/schema.prisma`), Turborepo (`turbo.json`), Biome for lint and format, Vitest, Playwright. Package manager `yarn@4.12.0` (`package.json` packageManager). Run from the repo root:
- check: `yarn type-check:ci --force` then `yarn biome check --write .` (`AGENTS.md:83-84`); `yarn lint` is `turbo lint` (`package.json`)
- tests: `TZ=UTC yarn test`, which is `vitest run` (`package.json:77`, `AGENTS.md:85`); one file: `TZ=UTC yarn vitest run <path>`; watch: `yarn tdd`; there is no changed-files test script, `yarn workspace @calcom/web check-changed-files` is a type check (`apps/web/package.json`)
- e2e: `PLAYWRIGHT_HEADLESS=1 yarn e2e [file.e2e.ts]`, never bare `yarn playwright test` (`agents/rules/testing-playwright.md`); `yarn test-e2e` seeds first (`package.json`)
- dev: `yarn dx` (Docker Postgres, migrate, seed, then dev; `README.md:132-138`), or `yarn dev` when the database is already up (`turbo run dev --filter=@calcom/web`); port 3000 (`playwright.config.ts:34`, `packages/lib/constants.ts:33`)
- db: `yarn workspace @calcom/prisma db-up | db-migrate | db-deploy | db-seed | db-reset | db-studio` (`packages/prisma/package.json`); `yarn prisma generate` after any schema change and after switching Node versions (`agents/rules/data-prisma-migrations.md`); after tRPC changes, `cd packages/trpc && yarn build` (`agents/rules/ci-git-workflow.md`)
- what runs only in CI (`.github/workflows/pr.yml`): type-check, lint, unit tests for web and api-v2, security audit, `check-prisma-migrations`, `setup-db`, production builds (web without database, api-v2, atoms), integration tests. E2E runs only when the PR carries the `ready-for-e2e` label, and the required check fails on purpose when e2e was skipped (`pr.yml:227-284`, `agents/rules/testing-playwright.md` CI Behavior). Merge queue: `all-checks.yml` runs on `merge_group`.

## Where docs live

- plan root: `docs/plans/<slug>/` (absent at this SHA; the suite creates it)
- design docs for agents: `AGENTS.md`, `agents/README.md` (rules index), `agents/knowledge-base.md` (domain rules), `agents/commands.md`, `SPEC-WORKFLOW.md` (opt-in spec workflow, `AGENTS.md:229-235`)
- engineering rules: `agents/rules/*.md`, 45 files, each with frontmatter `title`, `impact`, `tags`, grouped by prefix `architecture-`, `quality-`, `data-`, `api-`, `performance-`, `testing-`, `patterns-`, `culture-` (`agents/rules/README.md`)
- ADRs: none detected (no `adr/`, `docs/adr/`, or `docs/design/` in the tree)
- product docs site: `apps/docs` (Next.js, pagefind; `apps/docs/package.json`)
- glossary: `packages/i18n/locales/en/common.json`, 4,731 keys, the source of every user-facing noun (`AGENTS.md` Key files)

## Domain language and law

Nouns, from the glossary: event type, booking, availability, schedule, team, organization, round robin, seats, workflows, routing forms, insights, managed event type (`packages/i18n/locales/en/common.json`; `agents/knowledge-base.md` sections on managed event types, organizations and teams, round-robin scheduling, workflows versus webhooks). Law, in order of impact (`agents/rules/README.md`): `architecture-*` and `quality-*` are CRITICAL, `data-*` and `api-*` HIGH. The boundaries in `AGENTS.md`: always use `select` in Prisma queries, conventional-commit PR titles, run Biome; ask first before a new dependency, a change to `schema.prisma`, a change across packages, a delete, a full build or e2e run; never commit secrets, expose `credential.key` in a query, use `as any`, force push a shared branch, or edit generated files. Errors: `ErrorWithCode` outside tRPC, converted by `errorConversionMiddleware`; `TRPCError` inside (`agents/rules/quality-error-handling.md:20-28`).

## Agents by phase

No `.claude/agents/` in the repo. The `agents/` directory is documentation for AI agents, not spawnable agents; the techlead and review skills read its rules as law. Playbooks use the built-in Explore agent for maps and general-purpose read-only subagents for seats. Cast by signal: a database seat whenever `packages/prisma/schema.prisma` is touched (`AGENTS.md` Ask first), a security seat whenever a `credential` field or an auth route is touched (`AGENTS.md` Never do).

## Skills by phase

None detected as Claude skills. `agents/rules/*.md` are read by techlead and review (light). `SPEC-WORKFLOW.md` is the repo's own opt-in spec flow (light); the plan playbook cites it as prior art and supersedes it for a run. Changelog: changesets (`.changeset/README.md`, `.github/workflows/changesets.yml`); opening-a-pr composes the changeset entry from the diff.

## Browser drivers

Main session: UNKNOWN until a run proves it. Subagents: none (paper mode). Playwright is installed in the repo (`npx playwright install`, `CONTRIBUTING.md:177`), so verify can drive the app by running an e2e spec, and `yarn workspace @calcom/web test-codegen` opens codegen against `localhost:3000` (`apps/web/package.json`). Selectors: `data-testid` throughout the specs (`apps/web/playwright/booking-pages.e2e.ts`, 69 uses; `availability.e2e.ts`, 22).

## Design tokens and UX invariants

Shared components in `packages/ui` (`AGENTS.md` Project structure). Font "Cal Sans" from `/fonts/cal.ttf` (`packages/ui/styles/shared-globals.css:1-3`). Brand colours are set as CSS variables by `packages/ui/styles/useCalcomTheme.tsx:7`. Invariants beyond that: UNKNOWN; a prototype copies the closest existing screen.

## Architecture canon

Vertical slices (`agents/rules/architecture-vertical-slices.md`); feature code in `packages/features`, app-specific modules in `apps/web/modules` (`architecture-features-modules.md`); auth in `page.tsx`, never `layout.tsx` (`architecture-page-level-auth.md`); repositories named `Prisma<Entity>Repository` (`CONTRIBUTING.md:107-121`, `data-repository-pattern.md`), DTOs at boundaries, `select` over `include`, no barrel imports, thin controllers, dependency injection modules (`packages/features/flags/di/`), Trigger.dev for background jobs (`patterns-trigger-dev.md`, `dev:trigger` scripts). The cost of a "simple field": `schema.prisma`, a migration, `yarn prisma generate`, the tRPC package rebuild, the router, the UI, and the `check-prisma-migrations` CI job.

## Deploy reality

Migrations: created with `npx prisma migrate dev --name <name>`, deployed with `yarn workspace @calcom/prisma db-deploy` (`agents/rules/data-prisma-migrations.md`); timestamp fields get no default when existing rows should stay null (same rule). Expand and contract: UNKNOWN, not stated in the rules. Merge queue on `main` (`all-checks.yml`). E2E gated by the `ready-for-e2e` label. Never force push `main` (`ci-git-workflow.md`). Artifacts the repo builds: a Docker image `calcom/cal.diy` (`README.md:30`) and a `heroku-postbuild` script (`package.json`); the hosted deploy target is UNKNOWN from the tree.

## Feature flags

Mechanism: a `Feature` table with `slug`, `enabled`, `description`, `type`, `stale`, `lastUsedAt` (`packages/prisma/schema.prisma:1369-1383`); `type` is `RELEASE | EXPERIMENT | OPERATIONAL | KILL_SWITCH | PERMISSION` (`schema.prisma:1419-1425`). The typed list of flags is `AppFlags` in `packages/features/flags/config.ts:5-28` (boolean only, `config.ts:2`). Read on the server through `checkIfFeatureIsEnabledGlobally`, `checkIfTeamHasFeature`, `checkIfUserHasFeature` (`packages/features/flags/features.repository.interface.ts:8-11`), on the client through `useFlagMap()` inside `FeatureProvider` (`packages/features/flags/context/provider.ts:23-35`). A new flag is seeded by a migration that inserts into `"Feature"` (`agents/rules/data-prisma-feature-flags.md`) and a key added to `AppFlags`. Rollout stages: global row off, then team or user rows, then global on. Kill switch: set `enabled = false` on the row. Who may flip in production: UNKNOWN. Flag removal: mark `stale`, then delete the row and the `AppFlags` key in a follow-up PR after the watch window.

## Analytics and instrumentation

Helper: `packages/lib/telemetry.ts`, a Jitsu collector (`telemetry.ts:44`) with `telemetryEventTypes` such as `page_view`, `booking_confirmed`, `booking_cancelled`, `login`, `embed_view`, `onboarding_started`, `onboarding_finished` (`telemetry.ts:5-22`). Naming convention: object plus past-tense verb, snake_case, as the existing events do. Where events are queried: UNKNOWN from the tree.

## Required reviewers by path

None. `.github/CODEOWNERS` is empty at this SHA. The techlead skill still casts the database seat on schema changes and the security seat on credentials, per Agents by phase.

## Tracker

GitHub issues and PRs. PR titles are conventional commits, enforced by `.github/workflows/semantic-pull-requests.yml`; labels by `labeler.yml`. Tickets only when the user asks.

## Observability

Errors: Sentry through `@sentry/nextjs` (`apps/web/instrumentation.ts:1-17`, `apps/web/sentry.server.config.ts`, `apps/web/sentry.edge.config.ts`; `yarn sentry:release` runs in the web build, `apps/web/package.json`). Logs: `tslog` via `packages/lib/logger.ts:1-22`; level set by `NEXT_PUBLIC_LOGGER_LEVEL`, 0 silly to 6 fatal (`agents/knowledge-base.md` Logging Levels). Where to query them in a hosted environment: UNKNOWN from the tree.

## Forge

Tool: `gh`. Repo: `calcom/cal.com`, public. Account with access: your fork or your membership, verified by `gh repo view --json nameWithOwner,viewerPermission` at setup; write the login and the permission here, and the date. Accounts tried and denied: none yet.

## Evidence

Text evidence: `docs/plans/<slug>/evidence/<slice>-<scenario>.txt`, committed with the plan. Screenshots and recordings: attached to the PR, not committed; the repo's precedent is Playwright reports published as CI artifacts (`.github/workflows/e2e-report.yml`, `publish-report.yml`). Binaries committed to the repo: no. Prototype screenshots: `docs/plans/<slug>/prototype/shots/`, gitignored.

## Judge

Model: none (no `TYPESAFE_API_KEY` in the shell at setup; `typesafe/jev-latest` when there is one).
Mode: shadow.

## Companion files

What setup would seed into the other three files from this repo, before asking anything:
- `personas.md`: the seeded accounts are a roster in themselves: a free user, a pro user, a trial user, an admin, and a user who has not finished onboarding (`README.md:140-152`); add an integrator calling the API (`apps/api/v2`) and an embed host (`packages/embeds`).
- `drive.md`: launch `yarn dx` (Docker required); readiness HTTP 200 on `http://localhost:3000/`; login `pro@example.com` / `pro` or `admin@example.com` / `ADMINadmin2022!` (`README.md:140-152`), or `users.create()` from the e2e fixture (`apps/web/playwright/fixtures/users.ts:253-342`); selectors `data-testid`; isolation: one Postgres from `packages/prisma/docker-compose.yml`, so one instance at a time; flag flip: insert or update the `Feature` row locally; teardown `yarn workspace @calcom/prisma db-nuke`.
- `models.md`: every role `inherit` until the session proves it can spawn another model.
