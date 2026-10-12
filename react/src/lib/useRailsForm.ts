import { useEffect, useRef, useState, type FormEvent } from 'react'
import { m } from '#/generated/paraglide/messages'
import { formToParams, postJson } from '#/lib/api'

type FieldErrors = Record<string, string[]>

interface Options<T> {
  url: string
  // Rails' param scope for the form's fields, e.g. "user" for user[email].
  scope: string
  // Text for the alert when field errors come back, e.g. "Please fix the
  // problems below".
  summary: string
  // Called with the response body when the request succeeds. The form stays
  // pending afterwards, since the caller navigates away or swaps the form out.
  onSuccess: (data: T) => void
}

// Submits a form to a Rails JSON endpoint and sorts the answer into what the
// page needs. Rails answers failures with `{ errors: { field: [messages],
// base: [messages] } }` (a 422 from validation, a 401 from Devise).
//
// - fieldErrors: keyed by input name (`user[email]`), the shape React Aria's
//   <Form validationErrors> wants.
// - banner: text for an alert at the top of the form, with bannerRef to focus
//   it when it appears (the Form guide's pattern for server errors).
export function useRailsForm<T>({ url, scope, summary, onSuccess }: Options<T>) {
  const [isPending, setPending] = useState(false)
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({})
  const [formError, setFormError] = useState<string | null>(null)
  const bannerRef = useRef<HTMLDivElement>(null)

  const banner = formError ?? (Object.keys(fieldErrors).length > 0 ? summary : null)

  // Each submit clears the errors first, so a repeat failure takes `banner`
  // through null and back and focuses it again.
  useEffect(() => {
    if (banner) bannerRef.current?.focus()
  }, [banner])

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const params = formToParams(event.currentTarget)

    setPending(true)
    setFormError(null)
    setFieldErrors({})

    const result = await postJson<T & { errors?: FieldErrors }>(url, params)

    if (result.ok && result.data) {
      onSuccess(result.data)
      return
    }

    setPending(false)

    if (result.data?.errors) {
      const { base, ...fields } = result.data.errors
      setFormError(base?.join(' ') ?? null)
      setFieldErrors(
        Object.fromEntries(
          Object.entries(fields).map(([field, messages]) => [`${scope}[${field}]`, messages]),
        ),
      )
    } else {
      setFormError(result.networkError ? m['global.errors.network']() : m['global.errors.generic']())
    }
  }

  return { onSubmit, isPending, fieldErrors, banner, bannerRef }
}
