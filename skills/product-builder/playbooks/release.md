### Release

**You own the notes and the checklist, not the publish.** Cutting a version: changelog, bump, tag, notes, artifacts. Ship rolls a feature out behind a flag; Release sends a version to everyone who installs it.

1. Read the profile's release convention (versioning scheme, changelog format, tag format, publish command, who may publish) and the commits since the last tag (`git log <last-tag>..HEAD`).
2. Classify every commit as breaking, feature, fix, or internal; the bump follows the highest class under the scheme. A breaking change without a migration note in the changelog blocks the release.
3. Write the changelog entry from the commits, for the person who upgrades: what changed for them and what they must do, in the format the repo uses; internal commits are omitted.
4. Pre-flight: checks and tests green on the release commit with CI's exact configuration; the artifact built locally and its contents inspected; the install or upgrade path run once through **product-builder-verify** on the matching surface (a CLI installed from the artifact, a package installed into a scratch project, a container pulled and started).
5. Prepare, never execute: the bump commit, the tag command, the publish command, the announcement draft, each shown. The user runs the tag and the publish (G9, irreversible and external).
6. After publish, on request: the install path verified once more from the public registry; the notes posted. A broken release is yanked or superseded by a patch, never edited in place.

**Reply:** the version and why that bump; the changelog entry inline; the pre-flight with each box; the exact commands the user runs; what was verified after publish.
