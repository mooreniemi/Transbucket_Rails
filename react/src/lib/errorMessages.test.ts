import { beforeAll, describe, expect, it } from 'vitest'
import { overwriteGetLocale } from '#/generated/paraglide/runtime'
import { messageFor, messageForStatus } from './errorMessages'

// Paraglide reads the locale from the URL, which doesn't exist in Node.
beforeAll(() => overwriteGetLocale(() => 'en'))

describe('messageFor', () => {
  it('fills in the count for length errors', () => {
    expect(messageFor({ code: 'too_short', count: 8 }, 'password')).toBe('Must be at least 8 characters')
  })

  it('words "taken" for the field it is on', () => {
    expect(messageFor({ code: 'taken' }, 'username')).toBe('This username is unavailable')
    expect(messageFor({ code: 'taken' }, 'email')).toBe('This email is unavailable')
  })

  it('falls back to the generic message for unknown codes', () => {
    expect(messageFor({ code: 'nonsense' }, 'base')).toBe(messageForStatus(500, false))
  })
})

describe('messageForStatus', () => {
  it('prefers the network message over the status', () => {
    expect(messageForStatus(401, true)).not.toBe(messageForStatus(401, false))
  })

  it('treats a bare 422 as an expired session', () => {
    expect(messageForStatus(422, false)).toMatch(/session/i)
  })
})
