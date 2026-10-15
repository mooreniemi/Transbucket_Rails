import { queryOptions } from '@tanstack/react-query';
import type { User } from '../models';
import type { CurrentUserResponse } from '../models/responses';

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
async function fetchCurrentUser(): Promise<User | null> {
  try {
    const response = await fetch('/me.json', { credentials: 'same-origin' });
    if (!response.ok) return null

    const { user }: CurrentUserResponse = await response.json();
    if (user) {
      const { safe_mode: safeMode, ...rest } = user; // normalize object to camelCase
      return { safeMode, ...rest };
    }
    return null;
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
