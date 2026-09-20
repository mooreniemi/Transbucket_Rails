import { createFileRoute } from '@tanstack/react-router'
import { Input } from '#/components/input'
import { Checkbox } from '#/components/checkbox'
import { Button } from '#/components/button'
import { Card } from '#/components/card';

export const Route = createFileRoute('/$locale/_public/login')({ component: LoginPage })

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
    <Card className="md:mx-auto flex flex-col w-full md:max-w-sm min-h-full md:min-h-auto gap-6 my-0 md:my-20">
      <h2 className="text-xl font-semibold">Log in</h2>
      <form action={`/${locale}/users/sign_in`} method="post" className="flex flex-col gap-4">
        <input type="hidden" name="authenticity_token" value={getCsrfToken()} />
        <Input name="user[login]" label="Username or email" autoFocus isRequired />
        <Input name="user[password]" type="password" label="Password" isRequired autoComplete="password" />
        {/* Hidden "0" before the checkbox, matching Rails' own check_box
            helper -- an unchecked box submits nothing on its own, so the
            hidden field is what tells Devise remember_me is explicitly
            false rather than absent. */}
        <div className="flex items-center gap-2">
          <input type="hidden" name="user[remember_me]" value="0" />
          <Checkbox name="user[remember_me]" value="1">Remember me</Checkbox>
        </div>
        <Button type="submit">Log in</Button>
        <hr className="border-black-400" />
        <p className="text-center">New to Transbucket?</p>
        <Button variant="outline" href="/en/register">Register</Button>
        <Button variant="ghost" href="/en/users/confirmation/new">Didn't receive confirmation instructions?</Button>
      </form>
    </Card>
  )
}
