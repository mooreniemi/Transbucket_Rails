"use client"

import type * as React from "react"
import { Check, ChevronDown } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "cn"
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
  type Key,
  type ListBoxItemProps,
  type ValidationResult,
} from "react-aria-components"
import { Label } from "../label/label"

const triggerStyles = tv({
  base: "flex h-8 w-full min-w-[180px] cursor-default items-center gap-2 rounded-lg border border-black-300 bg-white px-3 text-start text-sm text-black-900 outline-none transition [-webkit-tap-highlight-color:transparent] focus-visible:border-blue-500 focus-visible:ring-3 focus-visible:ring-blue-500/50",
  variants: {
    isDisabled: {
      true: "cursor-not-allowed border-black-200 bg-black-100 text-black-600",
    },
    isInvalid: {
      true: "border-red-500 ring-3 ring-red-500/20",
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

// Shape the default item renderer understands. Pass items in this shape and
// you can omit children entirely.
export interface SelectOption {
  id: Key
  name: string
}

export interface SelectProps<T extends object>
  extends Omit<SelectPrimitiveProps<T>, "className" | "children"> {
  className?: string
  label?: string
  description?: string
  placeholder?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
  // react-aria's Select has no items prop of its own; these go to the ListBox.
  items?: Iterable<T>
  // Static <SelectItem>s, or a render function for items. Omit it when the
  // items are SelectOptions to use the default renderer.
  children?: React.ReactNode | ((item: T) => React.ReactNode)
}

function renderDefaultItem(item: object) {
  const { id, name } = item as SelectOption
  return <SelectItem id={id}>{name}</SelectItem>
}

/**
 * The `Select` component can be used in a form to select an item from a list. Provide a list of items via the `items` property or provide `SelectItem` components as children.
 * 
 * ## Import
 * ```javascript
 * import { Select, SelectItem } from '#/design-system/select';
 * ```
 */
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
      {({ isDisabled, isInvalid }) => (
        <>
          {label && <Label isInvalid={isInvalid}>{label}</Label>}
          <SelectTriggerPrimitive className={triggerStyles({ isDisabled, isInvalid })}>
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
              {children ?? renderDefaultItem}
            </ListBox>
          </Popover>
        </>
      )}
    </SelectPrimitive>
  )
}

export interface SelectItemProps extends Omit<ListBoxItemProps, "children"> {
  children?: React.ReactNode
}

function SelectItem({ children, textValue, ...props }: SelectItemProps) {
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

export { Select, SelectItem }
