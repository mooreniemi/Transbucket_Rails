import { http, HttpResponse } from 'msw';

export const MOCK_USER_RESPONSE = {
    id: 123,
    name: 'John Smith',
    username: 'jsmith',
    email: 'jsmith@example.com',
    safe_mode: false,
};

const { safe_mode: safeMode, ...rest } = MOCK_USER_RESPONSE;
export const MOCK_USER = { ...rest, safeMode };

export const userHandlers = [
    http.get('/me.json', () => {
        return HttpResponse.json({
            user: MOCK_USER_RESPONSE
        })
    })
];
