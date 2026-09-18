---
type: 'regex'
pattern: 'catch\s*\{\s*\}'
target: { source: 'file', path: 'src/import.js' }
match: 'not_contains'
---
