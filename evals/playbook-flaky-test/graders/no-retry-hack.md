---
type: 'regex'
pattern: 'retry|setTimeout\(.*\d{3,}'
target: { source: 'file', path: 'tests/counts.test.js' }
match: 'not_contains'
---
