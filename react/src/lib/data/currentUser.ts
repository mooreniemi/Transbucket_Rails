import { queryOptions } from '@tanstack/react-query'

export interface CurrentUser {
  id: number
  name: string
  username: string
  email: string
  /** From the user's Preference record, not the user record itself -- whether to show NSFW pins (e.g. on the logged-in home page). Named to match the JSON response's snake_case key, not transformed to camelCase. */
  safe_mode: boolean
}

// No locale prefix needed -- the route matches with or without one
// (Rails' locale scope segment is optional), and set_locale falls back to
// the session/Accept-Language when it's missing. This endpoint's response
// doesn't depend on locale anyway (identity, not translated content).
//
// Called from the root route's loader via queryClient.ensureQueryData,
// which has no error boundary configured -- a network failure (Rails
// unreachable, dev server not proxying yet, etc.) must resolve to "not
// signed in" rather than throwing, or it takes the whole route tree down
// instead of just showing signed-out layout.
async function fetchCurrentUser(): Promise<CurrentUser | null> {
  try {
    const response = await fetch('/me.json', { credentials: 'same-origin' })
    if (!response.ok) return null

    const data: { user: CurrentUser | null } = await response.json()
    return data.user
  } catch {
    return null
  }
}

// Rarely changes within a session, so a longer staleTime avoids refetching
// on every navigation -- the root route's loader still ensures it's fetched
// at least once before anything renders.
export const currentUserQueryOptions = () =>
  queryOptions({
    queryKey: ['currentUser'],
    queryFn: fetchCurrentUser,
    staleTime: 5 * 60 * 1000,
  })
