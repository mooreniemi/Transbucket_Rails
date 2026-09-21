"use client"

import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import {
  TextField as TextFieldPrimitive,
  Input as InputPrimitive,
  Text,
  FieldError,
  type TextFieldProps as TextFieldPrimitiveProps,
  type ValidationResult,
} from "react-aria-components"
import { Label } from "../label/label"

const inputStyles = tv({
  base: "w-full rounded-lg border border-black-300 bg-white px-3 py-1.5 text-sm text-black-900 outline-none transition-colors placeholder:text-black-600 focus-visible:border-blue-500 focus-visible:ring-3 focus-visible:ring-blue-500/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-red-500 aria-invalid:ring-3 aria-invalid:ring-red-500/20",
})

export interface InputProps extends Omit<TextFieldPrimitiveProps, "className"> {
  className?: string
  label?: string
  description?: string
  placeholder?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
}

function Input({
  className,
  label,
  description,
  placeholder,
  errorMessage,
  ...props
}: InputProps) {
  return (
    <TextFieldPrimitive {...props} className={cn("flex flex-col gap-1", className)}>
      {label && <Label isInvalid={!!errorMessage}>{label}</Label>}
      <InputPrimitive placeholder={placeholder} className={inputStyles()} />
      {description && (
        <Text slot="description" className="text-xs text-black-600">
          {description}
        </Text>
      )}
      <FieldError className="text-xs text-red-500">{errorMessage}</FieldError>
    </TextFieldPrimitive>
  )
}

export { Input, inputStyles }
