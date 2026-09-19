import { type ReactNode } from 'react';
import { Card } from '../card';

export function CommentGroup({ children } : { children: ReactNode }) {
    return (
        <ol>
            <Card>
                {children}
            </Card>
        </ol>
    );
}