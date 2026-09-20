import { createFileRoute } from '@tanstack/react-router'
import { Input } from '#/components/input/input'
import { Checkbox } from '#/components/checkbox/checkbox'
import { Button } from '#/components/button/button'

export const Route = createFileRoute('/$locale/login')({ component: LoginPage })

// A plain HTML form post, not a fetch -- the browser handles the
// navigation/redirect and Devise sets the session cookie exactly as it
// does for the old server-rendered login page. No JSON login endpoint
// exists (or is needed) for this.
function getCsrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') ?? ''
}

function LoginPage() {
  const { locale } = Route.useParams()

  return (
    <div className="mx-auto flex w-full max-w-sm flex-col gap-6 px-4 py-16">
      <h1 className="text-xl font-semibold text-black-900">Log in</h1>
      <form action={`/${locale}/users/sign_in`} method="post" className="flex flex-col gap-4">
        <input type="hidden" name="authenticity_token" value={getCsrfToken()} />
        <Input name="user[login]" label="Username or email" autoFocus isRequired />
        <Input name="user[password]" type="password" label="Password" isRequired />
        {/* Hidden "0" before the checkbox, matching Rails' own check_box
            helper -- an unchecked box submits nothing on its own, so the
            hidden field is what tells Devise remember_me is explicitly
            false rather than absent. */}
        <div className="flex items-center gap-2">
          <input type="hidden" name="user[remember_me]" value="0" />
          <Checkbox name="user[remember_me]" value="1">Remember me</Checkbox>
        </div>
        <Button type="submit">Log in</Button>
      </form>
    </div>
  )
}
