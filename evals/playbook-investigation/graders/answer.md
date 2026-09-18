---
type: 'llm'
---

PASS if the reply explains the archive path (POST /tasks/:id/archive in src/server.js gated by the archive flag, calling archive() in src/tasks.js which sets status archived and tracks task_archived) and says plainly that nothing stops an archived task from being completed today (complete() checks no status), with file:line citations. FAIL if it invents a guard that does not exist, proposes or makes a code change, or gives no file:line citations.
