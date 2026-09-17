# Writing rules

Apply to plan documents, PR bodies, ledger rows, and the UI copy written inside user stories (empty states, errors, labels). Match the tone the repo already uses when it has one; these rules are the floor.

## Contents
- Shape
- Words
- Punctuation and layout
- UI copy
- Self-check

## Shape

- One idea per sentence. If a reader has to backtrack, split it.
- Say what it does, not how it feels. "The parser rejects a bad date and exits with code 2" beats "robust date handling".
- Name the mechanism or the number. "Latency 420 ms to 180 ms" beats "much faster".
- Active voice with the actor named. "The service validates the payload" beats "the payload is validated".
- Whole sentences with their articles. No arrow-speak, no dropped verbs, no abbreviations the reader has to decode.
- A sentence that could sit unchanged in another project's docs says nothing about this one. Cut it.

## Words

- Plain words: use, help, many, if, because. Not utilize, facilitate, numerous, in the event that, due to the fact that.
- No filler openers: "it is important to note", "in order to", "at the end of the day".
- No hedging stacks: "may" is enough.
- No abstract metaphor nouns for concrete things: not "surface", "vector", "north star", "flywheel", "scaffolding" when a plain word exists.
- Consistent terms: one name per concept, taken from the repo's glossary, repeated rather than varied.
- No praise, no chat phrases, no "great question", no "hope this helps".

## Punctuation and layout

- Sentence case headings. No decorative emoji.
- No em dashes or en dashes in prose you write. End the sentence or use a comma. Verbatim quotes of code, error messages, docs, and the user's own words keep their punctuation.
- Colons only before a list or an example, never as a mid-sentence connector in prose. Digest lines, table cells, and key-value lines in a findings or capsule block are exempt; there a colon is a separator.
- Bold a lead-in that names an item and is followed by new detail. Do not bold every noun.
- Lists for parallel items only; a line of argument stays in prose.
- Tables when three or more items share the same fields.

## UI copy

- Title Case for labels and buttons when the repo does; sentence case for body text and messages.
- Empty states say what the space is for and the one action that fills it.
- Error messages say what happened, what the user can do, and never blame the user.
- Confirmations name the object and the consequence: "Delete the Billing stack? Its three tasks stay."
- Buttons are verbs that name the outcome: "Merge PR", not "OK".
- No jokes in errors, no exclamation marks, no "oops".

## Self-check

Before handing a document or a PR body back, read it once asking "what makes this obviously machine-written?" and fix those lines. Then read it once as the person who will act on it and cut anything they do not need.
