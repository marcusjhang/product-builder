---
type: 'regex'
pattern: '## Review rulings[\s\S]*\| (techlead|tech lead|hawk|security|frontend|database|SRE|integration|cost)'
target: { source: 'file', path: 'docs/plans/shared-boards/decisions.md' }
---
