import type { ReactNode } from "react";

interface CardProps {
    children: ReactNode;
}

export function Card({ children }: CardProps) {
    return <div className="bg-white rounded-sm border border-black-400 p-4">{children}</div>
}