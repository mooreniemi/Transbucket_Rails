import type { ReactNode } from "react";

interface CardProps {
    children: ReactNode;
    className?: string;
}

export function Card({ children, className }: CardProps) {
    return <div className={`${className} bg-white rounded-sm border border-black-300 p-4`}>{children}</div>
}