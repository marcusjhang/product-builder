### Refactoring

**You own the shape. Behaviour does not change; every batch proves it.**

1. Scope and blast radius: every caller and alias, enumerated.
2. **product-builder-why** if a recorded decision is being undone.
3. Characterise: existing tests or captured outputs that pin behaviour.
4. Expand (new shape beside the old), migrate callers in batches sized to stay green with the profile's checks after each, contract (delete the old form). Subtract before you add; a refactor that grows net lines needs a sentence explaining why.
5. **product-builder-review**, then `playbooks/opening-a-pr.md` per batch, or one PR for a small sweep.

**Reply:** what moved and what stayed; the characterisation that pinned behaviour; each batch with its green check; net lines with the reason if positive; the PR URLs.
