# Frontend modernization

Modernizing Transbucket's frontend, informed by the aianddesign.systems course
(Brad Frost/Ian Frost/TJ Pitre — atomic design, design-system health: Complete,
Sound, Synchronized, Extensible, AI-Ready).

## Direction (not yet fully locked)

- Target stack: **React + Tailwind**. User prefers CSS Modules but is
  deliberately trying Tailwind as a learning goal and because it pairs well
  with AI-assisted workflows.
- Architecture leaning: **hybrid**, not full SPA — mount React components
  into specific interactive screens rather than converting Rails to a pure
  JSON API. Reasoning: this app has zero token/API auth infra (plain Devise +
  `cookie_store` session, no JWT/CORS/API namespace). Hybrid reuses the
  existing same-origin cookie session as-is (`fetch(..., {credentials:
  'same-origin'})` + the existing CSRF meta tag); full SPA would mean
  rebuilding login/registration/password-reset/session handling as a JSON
  API from scratch. Not fully committed — revisit if requirements change.
- Sequencing: frontend modernization first, i18n later (deliberately
  deferred; do not start on i18n work here).

## Current backend surface relevant to this work

Small app: 12 controllers, ~20 models, 83 view templates (~2,000 lines).

JSON-ready controllers (already respond with real JSON, good foundation for
React to call): `PinsController`, `PinImagesController`, `FlagsController`,
`SearchController`.

Controllers still using the old Rails `format.js` pattern (server renders a
`<script>` snippet that mutates the DOM directly) — **these need real JSON
endpoints built before React can replace their UI**:
- `CommentsController` (threaded comments + flagging)
- Inline surgeon/procedure "select existing or create new" widgets
  (`SurgeonsController#create`/`new`, `ProceduresController#create`/`new`)

## Page audit

@react/pages.md — checklist of unique page types for tracking migration
progress. Update the checkboxes there as pages get rebuilt.

## Component inventory / build order

See full breakdown from the architecture audit (2026-09-08 session) — summary:

**Tier 1 — Atoms:** Button, Input/Textarea/Select, Badge/Label, Icon, Link

**Tier 2 — Molecules:** Form field (label+input+error), Alert/flash, Navbar
item, Pagination, Card/well container, Dropdown menu

**Tier 3 — Organisms (the real work, priority order):**
1. Pin card (masonry grid item) — highest priority, core to index/show/by_user
2. Star rating input (sensation/satisfaction)
3. Multi-select filter (replaces Chosen — scope/procedure/surgeon filters)
4. Search-with-autocomplete (replaces jQuery UI autocomplete)
5. Comment thread + flag button
6. Image uploader (replaces Dropzone) — most complex single widget
7. Inline "select existing or create new" surgeon/procedure picker
8. Admin queue row (lowest priority, single internal-only page)

## Domain model

Pinterest-style feed of user-submitted "pins" (photos + procedure/surgeon/
outcome data) for gender-affirming surgery info, with comments, flags,
ratings, and a moderation queue. Key models: `Pin`, `PinImage`, `Surgeon`,
`Procedure`, `Comment`, `Flag`, `User`, `Preference`.

## Dev environment

Working Docker setup lives on `fix/docker-dev-environment` (this branch is
based off it) — `docker compose up -d db web`, then `docker compose exec web
bundle exec rake db:setup` for schema+seed data. See that branch's PR
(#135) for what was fixed and why; no CLAUDE.md needed for those changes,
they're self-explanatory from the Dockerfile/compose diffs themselves.
