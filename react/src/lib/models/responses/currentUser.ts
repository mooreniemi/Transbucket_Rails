export interface CurrentUser {
    id: number;
    name: string;
    username: string;
    email: string;
    /** From the user's Preference record, not the user record itself -- whether to show NSFW pins (e.g. on the logged-in home page). Named to match the JSON response's snake_case key, not transformed to camelCase. */
    safe_mode: boolean;
}

/** GET /me.json -- CurrentUserController#show renders this as-is, no `data` wrapper. */
export interface CurrentUserResponse {
    user: CurrentUser | null;
}