"use client"

import { Search as SearchIcon, X } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import {
  SearchField as SearchFieldPrimitive,
  Input as InputPrimitive,
  Button,
  Text,
  FieldError,
  type SearchFieldProps as SearchFieldPrimitiveProps,
  type ValidationResult,
} from "react-aria-components"
import { Label } from "../label/label"

const groupStyles = tv({
  base: "flex items-center gap-2 rounded-lg border border-black-300 bg-white px-3 py-1.5 transition-colors focus-within:border-blue-500 focus-within:ring-3 focus-within:ring-blue-500/50",
  variants: {
    isDisabled: {
      true: "cursor-not-allowed bg-black-100 opacity-50",
    },
    isInvalid: {
      true: "border-red-500",
    },
  },
})

export interface SearchProps extends Omit<SearchFieldPrimitiveProps, "className"> {
  className?: string
  label?: string
  description?: string
  placeholder?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
}

function Search({
  className,
  label,
  description,
  placeholder,
  errorMessage,
  ...props
}: SearchProps) {
  return (
    <SearchFieldPrimitive {...props} className={cn("flex flex-col gap-1", className)}>
      {({ isEmpty, isDisabled, isInvalid }) => (
        <>
          {label && <Label isInvalid={!!errorMessage}>{label}</Label>}
          <div className={groupStyles({ isDisabled, isInvalid })}>
            <SearchIcon aria-hidden className="size-4 shrink-0 text-black-600" />
            <InputPrimitive
              placeholder={placeholder}
              className="w-full bg-transparent text-sm text-black-900 outline-none placeholder:text-black-600 [&::-webkit-search-cancel-button]:hidden"
            />
            <Button
              className={cn(
                "flex size-4 shrink-0 items-center justify-center rounded-full text-black-600 outline-none hover:text-black-900 focus-visible:ring-3 focus-visible:ring-blue-500/50",
                isEmpty && "invisible"
              )}
            >
              <X aria-hidden className="size-3.5" />
            </Button>
          </div>
          {description && (
            <Text slot="description" className="text-xs text-black-600">
              {description}
            </Text>
          )}
          <FieldError className="text-xs text-red-500">{errorMessage}</FieldError>
        </>
      )}
    </SearchFieldPrimitive>
  )
}

export { Search }
