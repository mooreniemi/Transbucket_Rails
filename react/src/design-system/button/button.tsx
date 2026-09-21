"use client"

import type * as React from "react"
import { tv, type VariantProps } from "tailwind-variants"
import { LoaderCircle } from "lucide-react"
import {
  Button as ButtonPrimitive,
  Link as LinkPrimitive,
  type ButtonProps as ButtonPrimitiveProps,
  type LinkProps as LinkPrimitiveProps,
} from "react-aria-components"

const buttonVariants = tv({
  // disabled: covers native <button disabled>; aria-disabled: covers
  // react-aria-components' Link, which renders as a <span aria-disabled>
  // (not a disableable native element, so :disabled never matches it) when
  // its own isDisabled is set.
  base: "group/button inline-flex shrink-0 cursor-pointer items-center justify-center gap-1.5 rounded-lg border border-transparent bg-clip-padding text-sm font-medium whitespace-nowrap transition-all outline-none select-none focus-visible:border-blue-500 focus-visible:ring-3 focus-visible:ring-blue-500/50 disabled:pointer-events-none disabled:opacity-50 aria-disabled:pointer-events-none aria-disabled:opacity-50 data-pending:pointer-events-none data-pending:opacity-70 aria-invalid:border-red-500 aria-invalid:ring-3 aria-invalid:ring-red-500/20 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*=size-])]:size-4",
  variants: {
    variant: {
      primary: "bg-blue-500 text-black-900 hover:bg-blue-500/80",
      outline:
        "border-blue-300 bg-white hover:bg-black-100 aria-expanded:bg-black-100",
      secondary:
        "bg-blue-300 text-black-900 hover:bg-blue-300/80 aria-expanded:bg-blue-300",
      ghost: "hover:bg-black-100 aria-expanded:bg-black-100",
      link: "text-blue-500 underline-offset-4 hover:underline",
    },
    theme: {
      default: "",
      destructive: "focus-visible:border-red-500/40 focus-visible:ring-red-500/20"
    },
    size: {
      md: "h-8 px-2.5",
      xs: "h-6 rounded-[min(var(--radius-md),10px)] px-2 text-xs [&_svg:not([class*=size-])]:size-3",
      sm: "h-7 rounded-[min(var(--radius-md),12px)] px-2.5 text-[0.8rem] [&_svg:not([class*=size-])]:size-3.5",
      lg: "h-9 px-2.5",
      icon: "size-8",
      "icon-xs": "size-6 rounded-[min(var(--radius-md),10px)] [&_svg:not([class*=size-])]:size-3",
      "icon-sm": "size-7 rounded-[min(var(--radius-md),12px)]",
      "icon-lg": "size-9",
    },
  },
  defaultVariants: {
    variant: "primary",
    size: "md",
    theme: "default",
  },
  compoundVariants: [
    {
      variant: 'primary',
      theme: 'destructive',
      className: 'bg-red-500 text-white hover:bg-red-500/80',
    },
    {
      variant: "outline",
      theme: "destructive",
      className: "border-red-300 text-red-500"
    },
    {
      variant: "secondary",
      theme: "destructive",
      className: "bg-red-500/10 text-red-500 hover:bg-red-500/20"
    },
    {
      variant: "link",
      theme: "destructive",
      className: "text-red-500"
    }
  ]
})

type ButtonType = Omit<ButtonPrimitiveProps, "className" | "children">
  & React.RefAttributes<HTMLButtonElement>
  & VariantProps<typeof buttonVariants>
  & {
    className?: string
    // Rendered directly alongside the pending spinner below, so (unlike
    // ButtonPrimitiveProps) this doesn't support the render-prop function
    // form -- plain content only.
    children?: React.ReactNode
  };

type LinkButtonType = Omit<LinkPrimitiveProps, "className">
  & VariantProps<typeof buttonVariants> & {
    className?: string
  };

function isLink(props: ButtonType | LinkButtonType): props is LinkButtonType {
  return "href" in props;
}

function Button({
  className,
  variant = "primary",
  size = "md",
  theme = "default",
  ...props
}: ButtonType | LinkButtonType) {
  if (isLink(props)) {
    return (
      <LinkPrimitive
        data-slot="button"
        data-variant={variant}
        data-size={size}
        className={buttonVariants({ variant, size, theme, className })}
        {...props}
      />
    );
  }

  const { isPending, children, ...rest } = props as ButtonType;
    return (
      <ButtonPrimitive
        data-slot="button"
        data-variant={variant}
        data-size={size}
        isPending={isPending}
        className={buttonVariants({ variant, size, theme, className })}
        {...rest}
      >
        {isPending && <LoaderCircle className="animate-spin" aria-hidden="true" />}
        {children}
      </ButtonPrimitive>
    )
}

export { Button, buttonVariants }
