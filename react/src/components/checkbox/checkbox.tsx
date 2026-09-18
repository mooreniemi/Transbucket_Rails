"use client"

import type * as React from "react"
import { Check, Minus } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import {
  CheckboxField as CheckboxFieldPrimitive,
  CheckboxButton as CheckboxButtonPrimitive,
  Text,
  FieldError,
  type CheckboxFieldProps as CheckboxFieldPrimitiveProps,
  type ValidationResult,
} from "react-aria-components"

const checkboxStyles = tv({
  base: "group flex items-center gap-2 font-sans text-sm transition [-webkit-tap-highlight-color:transparent]",
  variants: {
    isDisabled: {
      true: "cursor-not-allowed text-black-600",
      false: "cursor-pointer text-black-900",
    },
  },
})

const boxStyles = tv({
  base: "flex size-4.5 shrink-0 items-center justify-center rounded-sm border border-black-300 bg-white transition group-focus-visible:border-blue-500 group-focus-visible:ring-3 group-focus-visible:ring-blue-500/50",
  variants: {
    isSelected: {
      true: "border-blue-500 bg-blue-500",
    },
    isInvalid: {
      true: "border-red-500",
    },
    isDisabled: {
      true: "border-black-200 bg-black-100",
    },
  },
})

const iconStyles = "pointer-events-none size-3.5 text-white"

export interface CheckboxProps extends Omit<CheckboxFieldPrimitiveProps, "className" | "children"> {
  className?: string
  children?: React.ReactNode
  description?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
}

function Checkbox({
  className,
  children,
  description,
  errorMessage,
  ...props
}: CheckboxProps) {
  return (
    <CheckboxFieldPrimitive {...props} className={cn("flex flex-col gap-1", className)}>
      <CheckboxButtonPrimitive
        className={(renderProps) => checkboxStyles({ isDisabled: renderProps.isDisabled })}
      >
        {({ isSelected, isIndeterminate, isInvalid, isDisabled }) => (
          <>
            <div
              className={boxStyles({
                isSelected: isSelected || isIndeterminate,
                isInvalid,
                isDisabled,
              })}
            >
              {isIndeterminate ? (
                <Minus aria-hidden className={iconStyles} />
              ) : isSelected ? (
                <Check aria-hidden className={iconStyles} />
              ) : null}
            </div>
            {children}
          </>
        )}
      </CheckboxButtonPrimitive>
      {description && (
        <Text slot="description" className="ms-6.5 text-xs text-black-600">
          {description}
        </Text>
      )}
      <FieldError className="ms-6.5 text-xs text-red-500">{errorMessage}</FieldError>
    </CheckboxFieldPrimitive>
  )
}

export { Checkbox, checkboxStyles }
