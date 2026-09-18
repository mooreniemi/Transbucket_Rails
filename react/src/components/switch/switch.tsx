"use client"

import type * as React from "react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import {
  SwitchField as SwitchFieldPrimitive,
  SwitchButton as SwitchButtonPrimitive,
  Text,
  FieldError,
  type SwitchFieldProps as SwitchFieldPrimitiveProps,
  type ValidationResult,
} from "react-aria-components"

const switchStyles = tv({
  base: "flex items-center gap-2 font-sans text-sm transition [-webkit-tap-highlight-color:transparent]",
  variants: {
    isDisabled: {
      true: "cursor-not-allowed text-black-600",
      false: "cursor-pointer text-black-900",
    },
  },
})

const trackStyles = tv({
  base: "flex h-5 w-9 shrink-0 items-center rounded-full border border-transparent bg-black-300 px-0.5 transition",
  variants: {
    isSelected: {
      true: "bg-blue-500",
    },
    isDisabled: {
      true: "bg-black-100",
    },
    isFocusVisible: {
      true: "border-blue-500 ring-3 ring-blue-500/50",
    },
  },
})

const handleStyles = tv({
  base: "size-4 rounded-full bg-white shadow transition-transform",
  variants: {
    isSelected: {
      true: "translate-x-full",
      false: "translate-x-0",
    },
  },
})

export interface SwitchProps extends Omit<SwitchFieldPrimitiveProps, "className" | "children"> {
  className?: string
  children?: React.ReactNode
  description?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
}

function Switch({
  className,
  children,
  description,
  errorMessage,
  ...props
}: SwitchProps) {
  return (
    <SwitchFieldPrimitive {...props} className={cn("flex flex-col gap-1", className)}>
      <SwitchButtonPrimitive
        className={(renderProps) => switchStyles({ isDisabled: renderProps.isDisabled })}
      >
        {({ isSelected, isDisabled, isFocusVisible }) => (
          <>
            <div className={trackStyles({ isSelected, isDisabled, isFocusVisible })}>
              <div className={handleStyles({ isSelected })} />
            </div>
            {children}
          </>
        )}
      </SwitchButtonPrimitive>
      {description && (
        <Text slot="description" className="ms-11 text-xs text-black-600">
          {description}
        </Text>
      )}
      <FieldError className="ms-11 text-xs text-red-500">{errorMessage}</FieldError>
    </SwitchFieldPrimitive>
  )
}

export { Switch, switchStyles }
