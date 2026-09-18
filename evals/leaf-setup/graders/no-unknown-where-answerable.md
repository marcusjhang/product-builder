---
type: 'regex'
pattern: 'dev: UNKNOWN|check: UNKNOWN'
target: { source: 'file', path: '.product-builder/profile.md' }
match: 'not_contains'
flags: 'i'
---
