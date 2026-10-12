# Login and registration: testing gaps

Status as of the move of `/login` and `/register` to the React app
(`src/routes/$locale/_public/login.tsx`, `register.tsx`). Both pages post JSON to Devise (`POST /:locale/users/sign_in`,
`POST /:locale/users`) with `fetch`, so the Rails side is covered reasonably well and the React side is not covered
at all.

## What is covered today

| Area | Spec |
| --- | --- |
| Sign-up parameter contract (gender name to id, pronoun shapes, confirmation mismatch, unknown gender, missing email) | `spec/requests/react_registration_spec.rb` |
| Confirmation email, confirm link signs the user in | `spec/requests/react_registration_spec.rb` |
| Sign-in by username/email with real CSRF protection; post without token is rejected | `spec/requests/sign_in_spec.rb` |
| Signed-in users are redirected away from `/login` | `spec/requests/already_signed_in_spec.rb` |
| Both pages render for every locale; Devise's own URLs redirect to them | `spec/requests/localization_spec.rb` |
| Pronoun validation | `spec/models/user_pronouns_spec.rb` |
| Components in isolation (Alert, Accordion, Checkbox, Select, Input) | Storybook stories |

All of these run with the Vite tags stubbed (`spec/support/vite.rb`): no bundle
is built and no React code executes.

## Gaps

Failures are shown to the user (see gap 4); the remaining gaps are about
coverage of the React side.

### 1. Nothing runs the React pages
- The bundle is never built or loaded in a browser by any test. A broken
  entrypoint, manifest lookup, base path, or runtime error in the page passes CI.
  (The `main.ts` vs `main.tsx` tag mismatch was only found by hand.)
- The production build path (`/vite/` base, hashed assets, `og:image` from
  `react/public`) has no test. Dev and production resolve assets differently.

### 2. The form contract is duplicated and only half-tested
- Field names and values (`user[password_confirmation]`, `user[pronouns]` =
  `custom`, gender names such as `GenderQueer`) live in `register.tsx` and are
  re-typed by hand in the request spec. Renaming one in React passes every spec.
- The login page's `user[remember_me]` hidden `0` plus checkbox `1` pair is
  only tested with `0`.

### 3. Client behavior is untested
- Pronouns: "Other" reveals the custom field; the hidden `user[pronouns]` is
  mapped from the select (`default` posts blank).
- Native validation: required fields, `minLength={8}`.
- Checkbox label: clicking a link does not toggle the box; links open in a new
  tab (`target="_blank"`).
- Select and checkbox hidden inputs stay inside `<main>` (the footer-stretch bug).
- Keyboard use of the selects, accordion, and checkbox links.

### 4. Error handling: server side is covered, the React display is not
- Both pages submit JSON with `fetch` (`src/lib/api.ts`). Covered by request
  specs: 401 with a generic message for wrong password, unknown user and
  unconfirmed account (`lib/auth_failure_app.rb`); 422 with full messages keyed
  by attribute for sign-up; 201 with the confirmation message; no secrets in
  responses; CSRF header required.
- Not covered: the pages themselves handling those answers (`Alert`, inline
  field errors, focus on the first invalid field, pending button, the
  success view after sign-up, the network-failure message). Checked by hand.
- Not handled and not tested: locked accounts and rate limiting (no UI), a
  stale-tab CSRF failure (`ActionController::InvalidAuthenticityToken` returns
  an HTML error page, which the pages show as the generic error), and
  "email has already been taken" on sign-up (this confirms that an account with
  that email exists; it needs a product decision, e.g. treating a duplicate
  email like a success and emailing the existing owner).

### 5. Terms acceptance is not enforced or recorded
- `user[terms]` is posted and ignored. No spec, because no behavior. Needs a
  product/legal decision (a stored timestamp requires a migration).

### 6. Internationalization
- Only `en` has `register.json`; the other 15 locales fall back to English
  silently. Nothing checks key parity between locales.
- Paraglide compile errors (e.g. the `{#/terms}` markup typo) surface only when
  the dev server or build runs, not in CI.
- RTL (`ar`): `dir`/`lang` on `<html>` and the logical-property conversions
  were checked by hand once. No test.

### 7. Accessibility
- Storybook's a11y addon covers components in isolation. The assembled pages
  (labels, descriptions, error association, focus order, the `role="alert"`
  announcement once errors exist) are not checked.

### 8. Responsive and visual regressions
- Overflow at 320px and the footer stretch were both found manually.
  Chromatic covers Storybook components, not these pages.

### 9. Related flows still on server-rendered pages
- Resend confirmation (`/users/confirmation/new`), password reset, and account
  edit remain Devise ERB pages and are linked from React pages. Their look and
  behavior can drift from the React pages with no test noticing.

### 10. Existing failure unrelated to these pages
- `spec/features/mobile_feed_spec.rb:80` (scroll position after closing the pin
  viewer) fails on a clean checkout of `HEAD` too.

## Suggested order
1. A small browser suite (Playwright or Capybara against a built bundle) with
   register, login, signed-in redirect, one failed login and one failed sign-up. Closes gaps 1-4.
2. A `vite build` step in CI that asserts the manifest contains the entrypoint.
3. Add browser tests for the error display (gap 4).
4. Locale key-parity check across `src/assets/locales/*` (gap 6).
