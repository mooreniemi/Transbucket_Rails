import { type ReactNode } from 'react';

export function CommentGroup({ children } : { children: ReactNode }) {
    return (
        <ol className="bg-white border-black-400 border rounded-md p-4">
            {children}
        </ol>
    );
}