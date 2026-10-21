---
name: project-tako-tour-site
description: "Tako Tour travel-agency website (~/sannonthachai/travel-agency) — static client preview built 2026-10-19, CMS planned next"
metadata:
  node_type: memory
  type: project
  originSessionId: a70215ae-0f5a-4a4f-9866-ca4f7b511028
  modified: 2026-10-21T08:23:33.481Z
---

Tako Tour (client: travel agency, Thon Buri, Bangkok; LINE @takoworld, tel 099 449 5465) website lives in ~/sannonthachai/travel-agency as static HTML/CSS/vanilla JS. Published as client preview artifact https://claude.ai/artifact/YDPvzpxFwW9VoYTRqxmrDb; design canvas (mockups + logo concepts) https://claude.ai/artifact/LvQrxPCAVGrf3R6jtkPmjB.

- Logo = Thai chula kite (ว่าว, "tako" = kite in Japanese — NOT a squid), 3D coral, angled like a gliding bird. Files assets/img/logo.svg + favicon.svg (navy badge).
- Palette: Midnight #0B1F3A, Coral #FF6B4A (text variant #C2410C), Sand #FFF6EC. Fonts Prompt + Anuphan.
- Content in assets/js/data.js is sample data (prices, rounds, policies) pending client confirmation; header/footer rendered by assets/js/site.js; routing uses #hash (artifact host drops query strings).
- Hosted on GitHub Pages: repo github.com/sannonthachai/travel-agency (made PUBLIC 2026-10-19 only because free Pages needs public; user may flip back to private after client review, which kills the Pages site). Live: https://sannonthachai.github.io/travel-agency/ — noindex while preview. Push to main redeploys.
- Pages were generated once by a throwaway python script; edit the HTML files directly now.

- Phase 2 (started 2026-10-21): production code in ~/sannonthachai/travel-agency-cms (github.com/sannonthachai/travel-agency-cms, PRIVATE, pushed to main 2026-10-21 at d591ad5; CI image build only on v* tags). Local test = Docker stack `takotour-local` on Colima (deploy/.env.local, https://localhost + https://cms.localhost); admin UI got a Modernize-style Tako theme — user cares about editors not getting confused, so audit admin UX details proactively. User decided the stack (client does not choose): 2 services web (Next 16.4) + cms (Payload 3.90.2, cms.<domain> subdomain), Postgres, all Docker; docs in repo as Markdown (user rejected a Claude Docs version). Repo CLAUDE.md holds the design decisions.

**Why:** user is showing this to the client first; a CMS to manage content comes later.
**How to apply:** keep data.js shape CMS-friendly; don't treat sample prices/policies as real; move header/footer to server render when building the real stack.
