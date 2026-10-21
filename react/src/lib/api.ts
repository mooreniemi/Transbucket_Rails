import { csrfToken } from '#/lib/csrf'

export interface ApiResult<T> {
  ok: boolean
  status: number
  // null when the response had no JSON body (or the request never completed)
  data: T | null
  // true when the request never got a response (offline, DNS, etc.)
  networkError: boolean
}

export type JsonMethod = 'POST' | 'PUT' | 'PATCH'

// Send JSON to Rails with its CSRF token. Never throws: callers branch on
// `ok` / `data` rather than catching, since a 401 or 422 is an expected
// answer here, not an exception.
export async function postJson<T>(url: string, body: unknown, method: JsonMethod = 'POST'): Promise<ApiResult<T>> {
  try {
    const response = await fetch(url, {
      method,
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        'X-CSRF-Token': csrfToken(),
      },
      body: JSON.stringify(body),
    })

    let data: T | null = null
    try {
      data = (await response.json()) as T
    } catch {
      // An error page or empty body: leave data null.
    }

    return { ok: response.ok, status: response.status, data, networkError: false }
  } catch {
    return { ok: false, status: 0, data: null, networkError: true }
  }
}

// Turns a form's `user[login]`-style field names into the nested object
// Rails expects: { user: { login: ... } }.
export function formToParams(form: HTMLFormElement) {
  const params: Record<string, Record<string, string>> = {}

  for (const [key, value] of new FormData(form).entries()) {
    const match = /^([^[\]]+)\[([^\]]+)\]$/.exec(key)
    if (!match || typeof value !== 'string') continue

    const [, scope, field] = match
    params[scope] ??= {}
    params[scope][field] = value
  }

  return params
}
