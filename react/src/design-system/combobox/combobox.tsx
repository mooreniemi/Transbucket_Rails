"use client"

import type * as React from "react"
import { Check, ChevronDown } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import {
  ComboBox as ComboBoxPrimitive,
  Input as InputPrimitive,
  Button as ComboBoxTriggerPrimitive,
  Popover,
  ListBox,
  ListBoxItem,
  Text,
  FieldError,
  type ComboBoxProps as ComboBoxPrimitiveProps,
  type ListBoxItemProps,
  type ValidationResult,
} from "react-aria-components"
import { Label } from "../label/label"

// Baseline combo box: single-select text filtering. Deliberately leaves out
// react-aria's multi-select (ComboBoxValue) support -- add it only once a
// real screen actually needs it.

const groupStyles = tv({
  base: "flex h-8 w-full min-w-[180px] items-center gap-1 rounded-lg border border-black-300 bg-white ps-3 pe-1 transition [-webkit-tap-highlight-color:transparent] focus-within:border-blue-500 focus-within:ring-3 focus-within:ring-blue-500/50",
  variants: {
    isDisabled: {
      true: "cursor-not-allowed border-black-200 bg-black-100 text-black-600",
    },
    isInvalid: {
      true: "border-red-500",
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

export interface ComboBoxProps<T extends object>
  extends Omit<ComboBoxPrimitiveProps<T>, "className" | "children"> {
  className?: string
  label?: string
  description?: string
  placeholder?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
  items?: Iterable<T>
  children?: React.ReactNode | ((item: T) => React.ReactNode)
}

function ComboBox<T extends object>({
  className,
  label,
  description,
  placeholder,
  errorMessage,
  items,
  children,
  ...props
}: ComboBoxProps<T>) {
  return (
    <ComboBoxPrimitive {...props} className={cn("flex flex-col gap-1", className)}>
      {({ isDisabled, isInvalid }) => (
        <>
          {label && (
            <Label isInvalid={isInvalid}>{label}</Label>
          )}
          <div className={groupStyles({ isDisabled, isInvalid })}>
            <InputPrimitive
              placeholder={placeholder}
              className="w-full bg-transparent text-sm text-black-900 outline-none placeholder:text-black-600"
            />
            <ComboBoxTriggerPrimitive className="flex size-6 shrink-0 items-center justify-center rounded-md outline-none focus-visible:ring-3 focus-visible:ring-blue-500/50">
              <ChevronDown aria-hidden className="size-4 shrink-0 text-black-600" />
            </ComboBoxTriggerPrimitive>
          </div>
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
        </>
      )}
    </ComboBoxPrimitive>
  )
}

export interface ComboBoxItemProps extends Omit<ListBoxItemProps, "children"> {
  children?: React.ReactNode
}

function ComboBoxItem({ children, textValue, ...props }: ComboBoxItemProps) {
  return (
    <ListBoxItem
      {...props}
      textValue={textValue ?? (typeof children === "string" ? children : undefined)}
      className={(renderProps) => itemStyles(renderProps)}
    >
      {({ isSelected }) => (
        <>
          <span className="flex-1 truncate">{children}</span>
          {isSelected && <Check aria-hidden className="size-4 shrink-0 text-blue-500" />}
        </>
      )}
    </ListBoxItem>
  )
}

export { ComboBox, ComboBoxItem }
