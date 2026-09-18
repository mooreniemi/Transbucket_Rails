"use client"

import type * as React from "react"
import { Check, ChevronDown } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import {
  Select as SelectPrimitive,
  SelectValue,
  Button as SelectTriggerPrimitive,
  Popover,
  ListBox,
  ListBoxItem,
  Text,
  FieldError,
  type SelectProps as SelectPrimitiveProps,
  type ListBoxItemProps,
  type ValidationResult,
} from "react-aria-components"
import { Label } from "../label/label"

const triggerStyles = tv({
  base: "flex h-8 w-full min-w-[180px] cursor-default items-center gap-2 rounded-lg border border-black-300 bg-white px-3 text-start text-sm text-black-900 outline-none transition [-webkit-tap-highlight-color:transparent] focus-visible:border-blue-500 focus-visible:ring-3 focus-visible:ring-blue-500/50 aria-invalid:border-red-500 aria-invalid:ring-3 aria-invalid:ring-red-500/20",
  variants: {
    isDisabled: {
      true: "cursor-not-allowed border-black-200 bg-black-100 text-black-600",
    },
  },
})

const popoverStyles = tv({
  base: "min-w-(--trigger-width) overflow-auto rounded-lg border border-black-300 bg-white p-1 shadow-lg outline-none",
})

const itemStyles = tv({
  base: "flex cursor-default items-center gap-2 rounded-md px-2 py-1.5 text-sm text-black-900 outline-none select-none",
  variants: {
    isFocused: {
      true: "bg-blue-100",
    },
    isDisabled: {
      true: "cursor-not-allowed text-black-600",
    },
  },
})

export interface SelectProps<T extends object>
  extends Omit<SelectPrimitiveProps<T>, "className" | "children"> {
  className?: string
  label?: string
  description?: string
  placeholder?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
  items?: Iterable<T>
  children?: React.ReactNode | ((item: T) => React.ReactNode)
}

function Select<T extends object>({
  className,
  label,
  description,
  placeholder,
  errorMessage,
  items,
  children,
  ...props
}: SelectProps<T>) {
  return (
    <SelectPrimitive
      {...props}
      placeholder={placeholder}
      className={cn("flex flex-col gap-1", className)}
    >
      {label && <Label isInvalid={!!errorMessage}>{label}</Label>}
      <SelectTriggerPrimitive className={triggerStyles()}>
        <SelectValue className="flex-1 truncate" />
        <ChevronDown aria-hidden className="size-4 shrink-0 text-black-600" />
      </SelectTriggerPrimitive>
      {description && (
        <Text slot="description" className="text-xs text-black-600">
          {description}
        </Text>
      )}
      <FieldError className="text-xs text-red-500">{errorMessage}</FieldError>
      <Popover className={popoverStyles()}>
        <ListBox items={items} className="outline-none">
          {children}
        </ListBox>
      </Popover>
    </SelectPrimitive>
  )
}

export interface SelectItemProps extends Omit<ListBoxItemProps, "children"> {
  children?: React.ReactNode
}

function SelectItem({ children, ...props }: SelectItemProps) {
  return (
    <ListBoxItem {...props} className={(renderProps) => itemStyles(renderProps)}>
      {({ isSelected }) => (
        <>
          <span className="flex-1 truncate">{children}</span>
          {isSelected && <Check aria-hidden className="size-4 shrink-0 text-blue-500" />}
        </>
      )}
    </ListBoxItem>
  )
}

export { Select, SelectItem }
