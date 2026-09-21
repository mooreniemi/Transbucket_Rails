"use client"

import type * as React from "react"
import { cn } from "#/lib/utils"
import {
  CheckboxGroup as CheckboxGroupPrimitive,
  Text,
  FieldError,
  type CheckboxGroupProps as CheckboxGroupPrimitiveProps,
  type ValidationResult,
} from "react-aria-components"
import { Label } from "../label/label"

export interface CheckboxGroupProps
  extends Omit<CheckboxGroupPrimitiveProps, "className" | "children"> {
  className?: string
  children?: React.ReactNode
  label?: string
  description?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
}

function CheckboxGroup({
  className,
  children,
  label,
  description,
  errorMessage,
  ...props
}: CheckboxGroupProps) {
  return (
    <CheckboxGroupPrimitive {...props} className={cn("flex flex-col gap-2", className)}>
      {label && <Label isInvalid={!!errorMessage}>{label}</Label>}
      <div className="flex flex-col gap-2">{children}</div>
      {description && (
        <Text slot="description" className="text-xs text-black-600">
          {description}
        </Text>
      )}
      <FieldError className="text-xs text-red-500">{errorMessage}</FieldError>
    </CheckboxGroupPrimitive>
  )
}

export { CheckboxGroup }
