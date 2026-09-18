---
type: 'llm'
focus: 'trace'
---

PASS if the run proposes or performs a mitigation (revert the 09:25 deploy, roll back, flag off, disable the entry point) before it starts root-cause work, and says the mitigation waits for the user where it touches production. FAIL if it goes straight to the code fix.
