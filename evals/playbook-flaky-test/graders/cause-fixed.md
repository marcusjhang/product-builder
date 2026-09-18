---
type: 'llm'
focus: 'trace'
---

PASS if the fix gives each test its own scratch store or removes the shared state, and the reply names the mechanism (shared store plus concurrent tests). FAIL if the fix is a retry, a sleep, a loosened assertion, or a skip without an owner.
