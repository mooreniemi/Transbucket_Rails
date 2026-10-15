import { m } from '#/generated/paraglide/messages'

// What the server sends for a failure: a code, plus numeric options where the
// message needs one (e.g. too_short has a count). See app/lib/error_codes.rb
// and lib/auth_failure_app.rb.
export interface ErrorCode {
  code: string
  count?: number
}

// `field` is the attribute the error is on ("email", "username", or "base").
type Message = (error: ErrorCode, field: string) => string

// The words live here, in Paraglide, so they're translated and worded for a
// spot under a labelled field -- not borrowed from Rails' attribute names.
const MESSAGES: Record<string, Message> = {
  blank: () => m['global.errors.blank'](),
  invalid: () => m['global.errors.invalid'](),
  // Only email and username are unique, and the wording differs per field (and
  // per language -- the noun's grammatical gender), so these are two messages.
  taken: (_error, field) =>
    field === 'username' ? m['global.errors.usernameTaken']() : field === 'email' ? m['global.errors.emailTaken']() : m['global.errors.invalid'](),
  too_short: ({ count }) => m['global.errors.tooShort']({ count: count ?? 0 }),
  too_long: ({ count }) => m['global.errors.tooLong']({ count: count ?? 0 }),
  confirmation: () => m['global.errors.confirmation'](),
  pronouns_invalid: () => m['global.errors.pronounsInvalid'](),
  invalid_credentials: () => m['global.errors.invalidCredentials'](),
}

export function messageFor(error: ErrorCode, field: string) {
  return (MESSAGES[error.code] ?? (() => m['global.errors.generic']()))(error, field)
}

// For a failure that came with no error codes in the body: say what the HTTP
// status itself tells us. 401 is a rejected sign-in; 422 with no JSON is
// Rails' CSRF rejection (an old tab, an expired session); anything else is
// the server or the network.
export function messageForStatus(status: number, networkError: boolean) {
  if (networkError) return m['global.errors.network']()
  if (status === 401) return m['global.errors.invalidCredentials']()
  if (status === 422) return m['global.errors.sessionExpired']()
  return m['global.errors.generic']()
}
