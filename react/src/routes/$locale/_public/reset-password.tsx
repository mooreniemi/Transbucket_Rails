import { useState } from 'react';
import { createFileRoute } from '@tanstack/react-router';
import { Form } from 'react-aria-components';
import { Eye, EyeOff } from 'lucide-react';
import { Input } from '#/design-system/input';
import { Button } from '#/design-system/button';
import { Card } from '#/design-system/card';
import { Alert } from '#/design-system/alert';
import { CsrfToken } from '#/components/csrfToken';
import { useRailsForm } from '#/lib/hooks/useRailsForm';
import { m } from '#/generated/paraglide/messages';

interface ResetPasswordSearch {
  reset_password_token?: string
}

export const Route = createFileRoute('/$locale/_public/reset-password')({
  component: ResetPasswordPage,
  // The reset email links here with the token in the query string.
  validateSearch: (search: Record<string, unknown>): ResetPasswordSearch => ({
    reset_password_token: typeof search.reset_password_token === 'string' ? search.reset_password_token : undefined,
  }),
  head: () => {
    return {
      title: 'Reset password - Transbucket',
      meta: [
        {
          property: 'og:title',
          content: 'Reset password - Transbucket'
        }
      ]
    };
  }
})

interface PasswordChanged {
  message: string
  redirect_to: string
}

function ResetPasswordPage() {
  const { locale } = Route.useParams();
  const { reset_password_token: token } = Route.useSearch();
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const [changed, setChanged] = useState<PasswordChanged | null>(null);

  const form = useRailsForm<PasswordChanged>({
    url: `/${locale}/users/password`,
    method: 'PUT',
    scope: 'user',
    summary: m['global.errorSummary'](),
    onSuccess: setChanged,
  });

  // The token is a hidden field, so an error on it (the link is wrong, already
  // used, or older than Devise's reset_password_within) can't be shown inline
  // and retrying won't help: send them to request a new link instead.
  const linkRejected = !token || 'user[reset_password_token]' in form.fieldErrors;

  const handleTogglePassword = () => {
    setShowPassword((prev) => !prev);
  };

  return (
    <Card className="md:mx-auto flex flex-col w-full md:max-w-sm min-h-full md:min-h-auto gap-6 my-0 md:my-20">
      <h2 className="text-xl font-semibold">{m['global.pages.resetPassword']()}</h2>
      {changed ? (
        <>
          <Alert variant="info">{changed.message}</Alert>
          {/* A full page load: the signed-in pages are still server-rendered
              and need the session cookie this response just set. */}
          <Button href={changed.redirect_to}>{m['resetPassword.continue']()}</Button>
        </>
      ) : linkRejected ? (
        <>
          <Alert variant="error">{m['resetPassword.invalidLink']()}</Alert>
          <Button href={`/${locale}/forgot-password`}>{m['resetPassword.requestNewLink']()}</Button>
        </>
      ) : (
        <>
          {form.banner && (
            <Alert ref={form.bannerRef} tabIndex={-1} variant="error" className="outline-none focus-visible:ring-3 focus-visible:ring-blue-500/50">
              {form.banner}
            </Alert>
          )}
          <Form validationErrors={form.fieldErrors} onSubmit={form.onSubmit} className="flex flex-col gap-4">
            <CsrfToken />
            <input type="hidden" name="user[reset_password_token]" value={token} />
            <Input
              name="user[password]"
              type={showPassword ? 'text' : 'password'}
              label={m['resetPassword.passwordInputLabel']()}
              autoFocus
              isRequired
              autoComplete="new-password"
              minLength={8}
              maxLength={128}
              append={{
                content: showPassword ? <EyeOff size={16} /> : <Eye size={16} />,
                onClick: handleTogglePassword,
                isPressed: showPassword,
                ariaLabel: showPassword ? 'hide password' : 'show password'
              }} />
            <Input
              name="user[password_confirmation]"
              type={showPassword ? 'text' : 'password'}
              label={m['resetPassword.confirmationInputLabel']()}
              isRequired
              autoComplete="new-password"
              maxLength={128} />
            <Button type="submit" isPending={form.isPending}>{m['resetPassword.submit']()}</Button>
          </Form>
        </>
      )}
    </Card>
  )
}
