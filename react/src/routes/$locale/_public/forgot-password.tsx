import { useState } from 'react';
import { createFileRoute } from '@tanstack/react-router';
import { Form } from 'react-aria-components';
import { Input } from '#/design-system/input';
import { Button } from '#/design-system/button';
import { Card } from '#/design-system/card';
import { Alert } from '#/design-system/alert';
import { CsrfToken } from '#/components/csrfToken';
import { useRailsForm } from '#/lib/hooks/useRailsForm';
import { m } from '#/generated/paraglide/messages';

export const Route = createFileRoute('/$locale/_public/forgot-password')({
  component: ForgotPasswordPage,
  head: () => {
    return {
      title: 'Forgot password - Transbucket',
      meta: [
        {
          property: 'og:title',
          content: 'Forgot password - Transbucket'
        }
      ]
    };
  }
})

interface ResetRequested {
  message: string
  redirect_to: string
}

function ForgotPasswordPage() {
  const { locale } = Route.useParams();
  const [sent, setSent] = useState<ResetRequested | null>(null);

  // The answer is the same whether or not the email has an account (see
  // PasswordsController), so success always shows the same message.
  const form = useRailsForm<ResetRequested>({
    url: `/${locale}/users/password`,
    scope: 'user',
    summary: m['global.errors.generic'](),
    onSuccess: setSent,
  });

  return (
    <Card className="md:mx-auto flex flex-col w-full md:max-w-sm min-h-full md:min-h-auto gap-6 my-0 md:my-20">
      <h2 className="text-xl font-semibold">{m['global.pages.forgotPassword']()}</h2>
      {sent ? (
        <>
          <Alert variant="info">{sent.message}</Alert>
          <Button href={sent.redirect_to}>{m['global.buttons.login']()}</Button>
        </>
      ) : (
        <>
          {form.banner && (
            <Alert ref={form.bannerRef} tabIndex={-1} variant="error" className="outline-none focus-visible:ring-3 focus-visible:ring-blue-500/50">
              {form.banner}
            </Alert>
          )}
          <p>{m['forgotPassword.instructions']()}</p>
          <Form validationErrors={form.fieldErrors} onSubmit={form.onSubmit} className="flex flex-col gap-4">
            <CsrfToken />
            <Input name="user[email]" type="email" label={m['forgotPassword.emailInputLabel']()} autoFocus isRequired autoComplete="email" />
            <Button type="submit" isPending={form.isPending}>{m['forgotPassword.submit']()}</Button>
            <Button variant="ghost" href={`/${locale}/login`}>{m['forgotPassword.backToLogin']()}</Button>
          </Form>
          <hr className="border-black-400" />
          <p className="text-center">{m['login.registrationTitle']()}</p>
          <Button variant="outline" href={`/${locale}/register`}>{m['global.buttons.register']()}</Button>
          <Button variant="ghost" href={`/${locale}/users/confirmation/new`}>{m['global.buttons.confirmation']()}</Button>
        </>
      )}
    </Card>
  )
}
