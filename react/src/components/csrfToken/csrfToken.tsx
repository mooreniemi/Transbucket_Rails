import { csrfParam, csrfToken } from '#/lib/csrf'

// For plain HTML form posts: the token has to be inside the form so it's part
// of the POST body. fetch requests send it as a header instead (lib/api.ts).
export function CsrfToken() {
  return <input type="hidden" name={csrfParam()} value={csrfToken()} />
}
