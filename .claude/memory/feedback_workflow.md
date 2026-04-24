---
name: Workflow preferences
description: Simple tasks → just do; big changes → plan first; ambiguous → ask; always confirm destructive actions
type: feedback
originSessionId: 0cdae9f7-ec4d-4876-8af5-a2d84b5fdf54
---
- Simple/obvious tasks: just do it, no planning overhead.
- Non-trivial changes: explore related code first, then show a plan before writing code.
- Ambiguous requirements: ask clarifying questions instead of guessing.
- Always confirm before destructive actions: `rm -rf`, force push, dropping tables, `kubectl delete`, `terraform destroy`, resource deletion in Huawei Cloud, etc.

**Why:** User selected all four of these in global preference setup — they want judgment calls scaled to task size, and they're cautious about destructive ops in a DevOps context where mistakes hit production.

**How to apply:** Before acting, classify: is this obvious (edit one line, rename a var)? Or does it touch architecture, configs, or infra? The former skips planning; the latter gets a plan first. For any command that deletes, overwrites, or force-changes state — pause and confirm.
