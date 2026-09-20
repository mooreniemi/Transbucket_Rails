import { Outlet, createRootRouteWithContext } from '@tanstack/react-router'
import type { QueryClient } from '@tanstack/react-query'

import { TanStackRouterDevtoolsPanel } from '@tanstack/react-router-devtools'
import { TanStackDevtools } from '@tanstack/react-devtools'
import { currentUserQueryOptions } from '#/lib/currentUser'

import '../styles.css'

interface RouterContext {
  queryClient: QueryClient
}

export const Route = createRootRouteWithContext<RouterContext>()({
  // Runs once per navigation before anything renders, so the top-level
  // layout (Header, etc.) always has an answer to "is someone signed in"
  // on first paint instead of flashing "Sign in" then flipping to an
  // account menu once a fetch resolves. ensureQueryData only fetches when
  // the cache is missing/stale, so this isn't a refetch-on-every-navigation
  // like a plain beforeLoad fetch would be.
  loader: ({ context: { queryClient } }) =>
    queryClient.ensureQueryData(currentUserQueryOptions()),
  component: RootComponent,
})

function RootComponent() {
  return (
    <>
      <Outlet />
      <TanStackDevtools
        config={{
          position: 'bottom-right',
        }}
        plugins={[
          {
            name: 'TanStack Router',
            render: <TanStackRouterDevtoolsPanel />,
          },
        ]}
      />
    </>
  )
}
