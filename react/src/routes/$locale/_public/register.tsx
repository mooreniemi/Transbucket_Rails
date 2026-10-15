import { useState } from 'react';
import { createFileRoute } from '@tanstack/react-router';
import { Form, type Key } from 'react-aria-components';
import { Input } from '#/design-system/input';
import { Button } from '#/design-system/button'
import { Card } from '#/design-system/card';
import { Checkbox } from '#/design-system/checkbox';
import { m } from '#/generated/paraglide/messages';
import { Alert } from '#/design-system/alert';
import { Select, SelectItem } from '#/design-system/select';
import { CsrfToken } from '#/components/csrfToken';
import { ParaglideMessage } from '@inlang/paraglide-js-react';
import { Accordion, AccordionItem } from '#/design-system/accordion';
import { useRailsForm } from '#/lib/useRailsForm';

export const Route = createFileRoute('/$locale/_public/register')({
  component: RegisterPage,
  head: () => {
    return {
      title: 'Register - Transbucket',
      meta: [
        {
          property: 'og:title',
          content: 'Register - Transbucket'
        }
      ]
    };
  }
})

// What the backend expects in user[pronouns]: blank means "default" (derived
// from gender), and "custom" tells it to read user[pronouns_custom].
const PRONOUN_VALUES: Record<string, string> = {
  default: '',
  sheHer: 'she/her',
  heHim: 'he/him',
  theyThem: 'they/them',
  other: 'custom',
}

interface SignUpSuccess {
  message: string
  redirect_to: string
}

function RegisterPage() {
  const { locale } = Route.useParams()
  const [pronouns, setPronouns] = useState<Key | null>('default')
  const [success, setSuccess] = useState<SignUpSuccess | null>(null)

  const form = useRailsForm<SignUpSuccess>({
    url: `/${locale}/users`,
    scope: 'user',
    summary: m['register.errorSummary'](),
    onSuccess: setSuccess,
  })

  return (
    <Card className="md:mx-auto flex flex-col w-full md:max-w-sm min-h-full md:min-h-auto gap-6 my-0 md:my-20">
      <h2 className="text-xl font-semibold">{m['global.pages.register']()}</h2>
      {success ? (
        <>
          <Alert variant="info">{success.message}</Alert>
          <Button href={success.redirect_to}>{m['global.buttons.login']()}</Button>
        </>
      ) : (
      <>
      {form.banner && (
        <Alert ref={form.bannerRef} tabIndex={-1} variant="error" className="outline-none focus-visible:ring-3 focus-visible:ring-blue-500/50">
          {form.banner}
        </Alert>
      )}
      <Form
        validationErrors={form.fieldErrors}
        onSubmit={form.onSubmit}
        className="flex flex-col gap-4"
      >
        <CsrfToken />
        <Input
            type="text"
            name="user[username]"
            label={m['register.usernameInputLabel']()}
            description={m['register.usernameDescription']()}
            autoComplete="off"
            autoFocus
            isRequired
        />
        <Input
            type="text"
            name="user[email]"
            label={m['register.emailInputLabel']()}
            description={m['register.emailDescription']()}
            autoComplete="email"
            isRequired
        />
        <Input
            name="user[password]"
            type="password"
            label={m['register.passwordInputLabel']()}
            isRequired
            autoComplete="new-password"
            minLength={8}
            maxLength={128}
        />
        <Input
            name="user[password_confirmation]"
            type="password"
            label={m['register.confirmationInputLabel']()}
            isRequired
            autoComplete="new-password"
            minLength={8}
            maxLength={128}
        />
        <Input
            type="text"
            name="user[name]"
            label={m['register.nameInputLabel']()}
            description={m['register.nameDescription']()}
            autoComplete="name"
            isRequired
        />
        <Alert variant="warning">{m['register.nameWarning']()}</Alert>
        <Select
            name="user[gender]"
            label={m['register.genderInputLabel']()}
            description={m['register.genderDescription']()}
            isRequired
        >
            <SelectItem id="FTM">{m['register.genderOptions.ftm']()}</SelectItem>
            <SelectItem id="MTF">{m['register.genderOptions.mtf']()}</SelectItem>
            <SelectItem id="GenderQueer">{m['register.genderOptions.genderQueer']()}</SelectItem>
            <SelectItem id="None">{m['register.genderOptions.none']()}</SelectItem>
            <SelectItem id="Cisgender">{m['register.genderOptions.cisgender']()}</SelectItem>
        </Select>
        <input type="hidden" name="user[pronouns]" value={PRONOUN_VALUES[String(pronouns)] ?? ''} />
        <Select
            label={m['register.pronounsInputLabel']()}
            description={m['register.pronounsDescription']()}
            isRequired
            onChange={setPronouns}
            value={pronouns}
        >
            <SelectItem id="default">{m['register.pronounsOptions.default']()}</SelectItem>
            <SelectItem id="sheHer">{m['register.pronounsOptions.sheHer']()}</SelectItem>
            <SelectItem id="heHim">{m['register.pronounsOptions.heHim']()}</SelectItem>
            <SelectItem id="theyThem">{m['register.pronounsOptions.theyThem']()}</SelectItem>
            <SelectItem id="other">{m['register.pronounsOptions.other']()}</SelectItem>
        </Select>
        { pronouns === 'other' && (
          <Input
            type="text"
            name="user[pronouns_custom]"
            aria-label={m['register.customPronouns']()}
            placeholder={m['register.pronounPlaceholder']()}
            max-length={40}
          />
        )}
        <Accordion>
            <AccordionItem title={m['register.genderPronounAccordion']()}>
                <p className="text-sm">{m['register.genderAccordionDescription']()}</p>
                <p className="text-sm">{m['register.pronounsAccordionDescription']()}</p>
                <p className="text-sm">{m['register.pronounDefaultTitle']()}</p>
                <ul className="text-sm">
                    <li>{m['register.ftmDefault']()}</li>
                    <li>{m['register.mtfDefault']()}</li>
                    <li>{m['register.genderQueerDefault']()}</li>
                    <li>{m['register.noneDefault']()}</li>
                    <li>{m['register.cisgenderDefault']()}</li>
                </ul>
            </AccordionItem>
        </Accordion>
        <Checkbox name="user[terms]" isRequired value="1">
            <ParaglideMessage
                message={m['register.termsText']}
                markup={{
                    privacy: (props) => (<a href={`/${locale}/privacy`} target="_blank" rel="noopener noreferrer">{props.children}</a>),
                    terms: (props) => (<a href={`/${locale}/terms`} target="_blank" rel="noopener noreferrer">{props.children}</a>),
                }}
            />
        </Checkbox>
        <Button type="submit" isPending={form.isPending}>{m['global.buttons.register']()}</Button>
        <hr className="border-black-400" />
        <p className="text-center">{m['register.loginTitle']()}</p>
        <Button variant="outline" href={`/${locale}/login`}>{m['global.buttons.login']()}</Button>
        <Button variant="ghost" href={`/${locale}/users/confirmation/new`}>{m['global.buttons.confirmation']()}</Button>
      </Form>
      </>
      )}
    </Card>
  )
}
