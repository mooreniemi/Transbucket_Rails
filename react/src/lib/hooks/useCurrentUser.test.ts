import { describe, expect, test } from 'vitest';
import { waitFor } from '@testing-library/react';
import { useCurrentUser } from './useCurrentUser';
import { MOCK_USER } from '../mocks/user';
import  { renderHookWithQueryProvider } from '../testing/renderWithQueryProvider';
import { server } from '../mocks/mockServer';
import { http, HttpResponse } from 'msw';

describe('useCurrentUser', () => {
  test('should return the current user data', async () => {
    const { result } = renderHookWithQueryProvider(() => useCurrentUser());
    expect(result.current).toEqual(expect.objectContaining({
        data: undefined,
        isPending: true
    }));
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(MOCK_USER);
  });

  test('should return null if fetch current user fails', async () => {
    server.use(http.get('/me.json', () => HttpResponse.error()));
    const { result } = renderHookWithQueryProvider(() => useCurrentUser());
    expect(result.current).toEqual(expect.objectContaining({
        data: undefined,
        isPending: true
    }));
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toBeNull();
  });

  test('should return null if fetch current user response is not ok', async () => {
    server.use(http.get('/me.json', () => HttpResponse.json({ user: null }, { status: 404 })));
    const { result } = renderHookWithQueryProvider(() => useCurrentUser());
    expect(result.current).toEqual(expect.objectContaining({
        data: undefined,
        isPending: true
    }));
    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toBeNull();
  });
});