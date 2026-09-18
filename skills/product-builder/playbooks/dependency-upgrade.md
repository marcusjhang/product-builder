### Dependency upgrade

**You own the breaking changes, not the version number.** A major bump of a library, framework, runtime, or toolchain. The changelog is read before the lockfile moves.

1. Scope: the package, current and target versions, every consumer in the repo (grep for the import and the config keys), transitive pins that fight the bump.
2. Read the upstream changelog and migration guide between the two versions; list every breaking change that touches a consumer here, with the file:line it touches. A codemod the upstream ships runs before any hand edit.
3. Characterise: the profile's checks and tests green at the baseline, and a live run of the surfaces the package serves through **product-builder-verify**, recorded first.
4. Bump in one commit; fix breakages in commits grouped by breaking change, each green with the profile's checks. A behaviour change the upgrade brings (a default that flipped, a stricter parser) is its own commit with the test that pins the new behaviour.
5. Verify the same surfaces as step 3, compared; a perf-sensitive package gets the interleaved measurement from `playbooks/perf-issue.md`.
6. **product-builder-review** with the changelog excerpt as the intent; the backwards-compatibility seat is mandatory.
7. `playbooks/opening-a-pr.md`. Blast radius names every consumer and every behaviour change; Verification names the surfaces driven before and after.

**Reply:** the versions; the breaking changes and where each landed; the behaviour changes with their pinning tests; the surfaces verified before and after; the PR URL.
