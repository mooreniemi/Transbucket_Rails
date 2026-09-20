import type { ReactNode } from "react";

interface CardProps {
    children: ReactNode;
    className?: string;
}

export function Card({ children, className }: CardProps) {
    const tailwindClasses = 'bg-white md:rounded-sm [&_+_&]:border-t md:border border-black-300 p-4 md:[&_+_&]:mt-2';
    return <div className={className ? `${className} ${tailwindClasses}` : tailwindClasses}>{children}</div>
}