# Page audit

Unique page types in the current Rails app, for tracking frontend
modernization progress. Distinguishes **routes** (distinct URLs) from
**page types** (distinct UI patterns worth their own page component) — e.g.
`/pins` and `/by_user` are two routes but the same page type (masonry grid +
pagination), since `by_user.html.erb` is a near-duplicate of `index.html.erb`
missing only the search/filter controls.

Check off as each page type is rebuilt.

## Content/marketing
- [ ] Home (`/`, `/home`)
- [ ] About (`/about`)
- [ ] Terms (`/terms`)
- [ ] Privacy (`/privacy`)
- [ ] Newsfeed (`/newsfeed`)
- [ ] Contact (`/contact`)

## Pins (core feature)
- [ ] Pins grid/list — covers `/pins` (index+search) and `/by_user` (filtered
      by user); same underlying page, parameterize by query instead of
      treating as separate pages
- [ ] Pin detail (`/pins/:id`) — single pin, comments thread, edit/flag actions
- [ ] New pin (`/pins/new`)
- [ ] Edit pin (`/pins/:id/edit`)
- [ ] Admin moderation queue (`/queendom`) — reuses pin/comment rendering but
      adds approve/reject actions; keep as its own page

## Surgeons / Procedures
- [ ] Surgeons index (`/surgeons`)
- [ ] Surgeon detail (`/surgeons/:id`)
- [ ] Procedures index (`/procedures`)
- [ ] Procedure detail (`/procedures/:id`)

## Account / auth (Devise)
- [ ] Sign in (`/login`)
- [ ] Sign up (`/register`)
- [ ] My Account — profile + settings + submissions in one page, three
      partials (`/users/edit`)
- [ ] Forgot password (`/users/password/new`)
- [ ] Reset password (`/users/password/edit`)
- [ ] Resend confirmation (`/users/confirmation/new`)
- [ ] Unlock account (`/users/unlock/new`)

## Not counted as pages
`pin_images`, `comments`, `flags`, `search_terms`, and the inline
surgeon/procedure create widgets are AJAX/JSON endpoints with no standalone
page — see the component list in `react/CLAUDE.md` for those.
