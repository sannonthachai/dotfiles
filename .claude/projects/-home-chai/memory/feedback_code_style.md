---
name: Code style preferences
description: Small functions with early returns, explicit error handling, minimal comments — applies to Go and TypeScript
type: feedback
originSessionId: 0cdae9f7-ec4d-4876-8af5-a2d84b5fdf54
---
- Small, focused functions with early returns over nested conditionals.
- Explicit error handling — no silent failures, handle every error.
- Go: idiomatic `if err != nil` checks, don't ignore errors with `_`.
- TypeScript: strict typing, avoid `any`.
- Minimal comments — only when the WHY is non-obvious.

**Why:** User explicitly selected "Small functions, early returns" and "Explicit error handling" in global preference setup.

**How to apply:** When writing or reviewing Go/TS code, prefer guard clauses at the top, return early on errors/edge cases, and surface errors rather than swallowing them.
