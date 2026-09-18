### Removal

**You own what depends on it.** Removing a feature, a flag, an endpoint, a config option, or dead code. Consumers first, the dark removal second, the delete third.

1. Inventory every consumer: callers and imports, routes, jobs, config keys, flag reads, analytics events, docs, tests, and the external clients the profile names (an API consumer, a webhook subscriber). A "no consumers" claim names the exact searches that returned nothing.
2. **product-builder-why** for the reason it was added; a removal that undoes a recorded decision says so and supersedes it in an ADR or the ledger.
3. Dark removal: the entry point disabled behind the existing flag or a new one, default on for the old behaviour; usage measured over the watch window through the profile's analytics or logs. Zero measured use is evidence; zero assumed use is not.
4. Delete in dependency order (callers, then the thing, then its tests and docs, then the flag), each commit green with the profile's checks; net lines negative, or the reply says why not.
5. Data the feature owned: kept, archived, or deleted, per one question to the user with the row count; a delete against a shared store waits for the user.
6. **product-builder-review** with the backwards-compatibility seat mandatory; `playbooks/opening-a-pr.md` with a deprecation note in the changelog when external consumers exist.

**Reply:** the consumer inventory and the searches behind it; the usage measured over the watch window; what was deleted in what order; the data decision; the PR URL.
