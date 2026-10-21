import { useEffect, useRef, useState, type FormEvent } from 'react'
import { formToParams, postJson, type JsonMethod } from '#/lib/api'
import { messageFor, messageForStatus, type ErrorCode } from '#/lib/errorMessages'

type FieldErrors = Record<string, string[]>
type ServerErrors = Record<string, ErrorCode[]>

interface Options<T> {
  url: string
  // POST unless the endpoint wants another verb, e.g. PUT for Devise's
  // password change.
  method?: JsonMethod
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
// page needs. Rails answers failures with `{ errors: { field: [codes],
// base: [codes] } }` (a 422 from validation, a 401 from Devise), where each
// code is `{ code: 'too_short', count: 8 }`; the words come from messageFor.
//
// - fieldErrors: keyed by input name (`user[email]`), the shape React Aria's
//   <Form validationErrors> wants.
// - banner: text for an alert at the top of the form, with bannerRef to focus
//   it when it appears (the Form guide's pattern for server errors).
export function useRailsForm<T>({ url, method, scope, summary, onSuccess }: Options<T>) {
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

    const result = await postJson<T & { errors?: ServerErrors }>(url, params, method)

    if (result.ok && result.data) {
      onSuccess(result.data)
      return
    }

    setPending(false)

    if (result.data?.errors) {
      const { base, ...fields } = result.data.errors
      setFormError(base ? base.map((error) => messageFor(error, 'base')).join(' ') : null)
      setFieldErrors(
        Object.fromEntries(
          Object.entries(fields).map(([field, codes]) => [`${scope}[${field}]`, codes.map((error) => messageFor(error, field))]),
        ),
      )
    } else {
      setFormError(messageForStatus(result.status, result.networkError))
    }
  }

  return { onSubmit, isPending, fieldErrors, banner, bannerRef }
}
