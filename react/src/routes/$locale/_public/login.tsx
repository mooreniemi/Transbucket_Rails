import { createFileRoute } from '@tanstack/react-router'
import { Input } from '#/design-system/input'
import { Checkbox } from '#/design-system/checkbox'
import { Button } from '#/design-system/button'
import { Card } from '#/design-system/card';
import { CsrfToken } from '#/components/csrfToken';
import { Alert } from '#/design-system/alert';
import { useRailsForm } from '#/lib/hooks/useRailsForm';
import { m } from '#/generated/paraglide/messages';
import { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';

export const Route = createFileRoute('/$locale/_public/login')({
  component: LoginPage,
  head: () => {
    return {
      title: 'Login - Transbucket',
      meta: [
        {
          property: 'og:title',
          content: 'Login - Transbucket'
        }
      ]
    };
  }
})

interface SignInResult {
  redirect_to: string
}

function LoginPage() {
  const { locale } = Route.useParams();
  const [showPassword, setShowPassword] = useState<boolean>(false);

  const form = useRailsForm<SignInResult>({
    url: `/${locale}/users/sign_in`,
    scope: 'user',
    summary: m['global.errors.generic'](),
    // A full page load: the signed-in pages are still server-rendered and
    // need the session cookie this response just set.
    onSuccess: (data) => window.location.assign(data.redirect_to),
  });

  const onTogglePassword = () => {
    setShowPassword((prev) => !prev);
  };

  return (
    <Card className="md:mx-auto flex flex-col w-full md:max-w-sm min-h-full md:min-h-auto gap-6 my-0 md:my-20">
      <h2 className="text-xl font-semibold">{m['global.pages.login']()}</h2>
      {form.banner && (
        <Alert ref={form.bannerRef} tabIndex={-1} variant="error" className="outline-none focus-visible:ring-3 focus-visible:ring-blue-500/50">
          {form.banner}
        </Alert>
      )}
      <form name="login" onSubmit={form.onSubmit} className="flex flex-col gap-4">
        <CsrfToken />
        <Input name="user[login]" label={m['login.userInputLabel']()} autoFocus isRequired autoComplete="username" />
        <Input
          name="user[password]"
          type={showPassword ? 'text' : 'password'}
          label={m['login.passwordInputLabel']()}
          isRequired
          autoComplete="current-password"
          append={{
            content: showPassword ? <EyeOff size={16} /> : <Eye size={16} />,
            onClick: onTogglePassword,
            isPressed: showPassword,
            ariaLabel: showPassword ? 'hide password' : 'show password'
          }} />
        <div className="text-right text-xs"><a href={`/${locale}/forgot-password`}>{m['login.forgotPasswordLink']()}</a></div>
        {/* Hidden "0" before the checkbox, matching Rails' own check_box
            helper -- an unchecked box submits nothing on its own, so the
            hidden field is what tells Devise remember_me is explicitly
            false rather than absent. */}
        <div className="flex items-center gap-2">
          <input type="hidden" name="user[remember_me]" value="0" />
          <Checkbox name="user[remember_me]" value="1">{m['login.rememberInputLabel']()}</Checkbox>
        </div>
        <Button type="submit" isPending={form.isPending}>{m['global.buttons.login']()}</Button>
        <hr className="border-black-400" />
        <p className="text-center">{m['global.registrationTitle']()}</p>
        <Button variant="outline" href={`/${locale}/register`}>{m['global.buttons.register']()}</Button>
        <Button variant="ghost" href={`/${locale}/users/confirmation/new`}>{m['global.buttons.confirmation']()}</Button>
      </form>
    </Card>
  )
}
