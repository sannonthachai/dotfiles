---
name: Grammar-check user input before answering
description: Before answering, correct grammar of the user's English input, show the corrected version, then answer the original intent
type: feedback
originSessionId: a2d809f6-a6f7-4d64-8803-ef2b229a9308
---
Before answering any user message written in English, always:
1. Check and correct the grammar of the user's input.
2. Show the corrected version to the user.
3. Then answer the original intent of the message.

**Why:** User is practicing English and wants passive correction as part of every interaction.

**How to apply:**
- Apply to every English message, including short/casual ones, unless the message is already grammatically clean (in which case still note it briefly or skip the correction step and proceed).
- Do NOT correct Thai (ภาษาไทย) input — only English.
- Do NOT correct code, commands, file paths, or technical identifiers inside the message.
- Keep the correction terse — one line showing the fixed sentence, then proceed to the answer. Don't lecture on grammar rules unless asked.
- A dedicated `english-grammar-checker` subagent exists (created 2026-05-08). For inline one-liner corrections do them yourself — spawning a subagent every turn is too heavyweight. Delegate to it only for longer/multi-paragraph proofreading requests where a deeper review is wanted.
