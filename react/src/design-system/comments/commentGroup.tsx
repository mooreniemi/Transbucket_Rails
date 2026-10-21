import { type ReactNode } from 'react';

/**
 * The `CommentGroup` component contains a list of `Comment` components for user discussion.
 * ## Import
 * ```javascript
 * import { CommentGroup } from '#/design-system/comments';
 * ```
 */
export function CommentGroup({ children } : { children: ReactNode }) {
    return (
        <ol>
            {children}
        </ol>
    );
}