"use client"

import { useEffect, useMemo, useRef, useState } from "react"
import debounce from "lodash/debounce"
import { Search as SearchIcon, X } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "cn"
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

export interface SearchProps
  extends Omit<SearchFieldPrimitiveProps, "className" | "defaultValue"> {
  className?: string
  label?: string
  description?: string
  placeholder?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
  // onChange is debounced: it fires debounceMs after the user stops typing.
  // Clearing and submitting fire it immediately.
  debounceMs?: number
}

/**
 * The `Search` component provides a debounced input for searching.
 * 
 * ## Import
 * ```javascript
 * import { Search } from '#design-system/search';
 * ```
 * 
 * ## Accessibility information
 * If using the `Search` component in a compact area without a label, for example to filter a table, provide the `aria-label` property to the component.
 * 
 */
function Search({
  className,
  label,
  description,
  placeholder,
  errorMessage,
  debounceMs = 300,
  value,
  onChange,
  onClear,
  onSubmit,
  ...props
}: SearchProps) {
  // Two values: displayValue is what's in the box and updates on every
  // keystroke; value/onChange is the debounced value the parent sees. value
  // seeds the display, and changing it later (reset, prefill) updates it.
  const [displayValue, setDisplayValue] = useState(value ?? "")
  useEffect(() => {
    setDisplayValue(value ?? "")
  }, [value])

  // Keep the latest callback in a ref so a new inline function each render
  // doesn't recreate (and reset) the debounced timer.
  const onChangeRef = useRef(onChange)
  useEffect(() => {
    onChangeRef.current = onChange
  }, [onChange])

  const debouncedChange = useMemo(
    () => debounce((next: string) => onChangeRef.current?.(next), debounceMs),
    [debounceMs]
  )
  useEffect(() => () => debouncedChange.cancel(), [debouncedChange])

  const handleChange = (next: string) => {
    setDisplayValue(next)
    debouncedChange(next)
  }

  // Clearing and submitting are deliberate, so don't make the user wait.
  const handleClear = () => {
    onClear?.()
    debouncedChange.cancel()
    onChangeRef.current?.("")
  }

  const handleSubmit = (submitted: string) => {
    onSubmit?.(submitted)
    debouncedChange.flush()
  }

  return (
    <SearchFieldPrimitive
      {...props}
      value={displayValue}
      onChange={handleChange}
      onClear={handleClear}
      onSubmit={handleSubmit}
      className={cn("flex flex-col gap-1", className)}
    >
      {({ isEmpty, isDisabled, isInvalid }) => (
        <>
          {label && <Label isInvalid={isInvalid}>{label}</Label>}
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
