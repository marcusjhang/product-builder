### Incident

**You own the mitigation first and the cause second.** Production is wrong now: an alert, an error spike, a user report of data loss, a security report. Stop the harm, then run Bug fix, then write the postmortem. Every action here is logged with its time.

1. Declare: what is wrong, since when, who is affected, how you know (the alert, the log line, the report), and the severity by the profile's scale or, with none, by users affected and data at risk. One line to the user before anything else; an incident is never worked silently.
2. Mitigate with the smallest reversible step that stops the harm, in this order of preference: flag off, revert the deploy, roll back the release, disable the entry point, scale. A mitigation that touches shared state (a database, a queue, a third-party account) or a production flag waits for the user per the profile's deploy reality. Confirm the harm stopped with the same signal that showed it.
3. Preserve evidence before it rotates: logs, traces, the failing request, the row or record, the deploy SHA and the previous one, saved as text under `docs/plans/<slug>/evidence/`.
4. Root cause through `playbooks/bug-fix.md` steps 1 to 4 on the mitigated system, with the deploy diff (`git log <previous>..<current>`) as the first suspect and **product-builder-why** on the change that introduced it.
5. Fix, verify, review, and PR per `playbooks/bug-fix.md` steps 5 to 7. The fix PR names the incident and the mitigation still in place; undoing the mitigation (flag back on, redeploy) is a separate step the user takes after the fix ships.
6. A security report is an incident whose harm is disclosure: reproduction details, exploit inputs, and affected identifiers stay out of commit messages, PR bodies, and public trackers; the profile's security contact is named; the fix PR says "security" and no more until the user says otherwise.
7. Postmortem, blameless, to `docs/plans/<slug>/postmortem.md`: a timeline with times, impact with numbers, the mechanism at file:line, why detection took as long as it did, what mitigated it, the fix, and the follow-ups (a missing alert, a missing test, a missing guard) as tickets or slices, each with an owner.
8. Offer **product-builder-reflect** when one of the suite's own gates should have caught it.

**Reply:** the declaration; the mitigation and the signal that confirms it; the root cause at file:line; the fix PR URL; the postmortem path with its follow-ups; what the user must undo and when.
