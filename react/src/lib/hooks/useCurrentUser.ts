import { useQuery } from '@tanstack/react-query'
import { currentUserQueryOptions } from '../data/currentUser'

// Reads from the query cache the root route's loader already populated
// (see routes/__root.tsx) -- resolves instantly post-load, no extra
// fetch, and picks up TanStack Query's own background-refetch behavior
// going forward.
export function useCurrentUser() {
  return useQuery(currentUserQueryOptions()).data
}
