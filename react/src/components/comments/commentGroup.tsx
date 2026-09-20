import { type ReactNode } from 'react';

export function CommentGroup({ children } : { children: ReactNode }) {
    return (
        <ol>
            {children}
        </ol>
    );
}