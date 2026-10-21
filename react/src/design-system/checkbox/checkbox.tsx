"use client"

import type * as React from "react"
import { Check, Minus } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "cn"
import {
  CheckboxField as CheckboxFieldPrimitive,
  CheckboxButton as CheckboxButtonPrimitive,
  Text,
  FieldError,
  type CheckboxFieldProps as CheckboxFieldPrimitiveProps,
  type ValidationResult,
} from "react-aria-components"

const checkboxStyles = tv({
  base: "flex items-center gap-2 font-sans text-sm transition [-webkit-tap-highlight-color:transparent]",
  variants: {
    isDisabled: {
      true: "cursor-not-allowed text-black-600",
      false: "cursor-pointer text-black-900",
    },
  },
})

const boxStyles = tv({
  base: "flex size-4.5 shrink-0 items-center justify-center rounded-sm border border-black-300 bg-white transition",
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
    isFocusVisible: {
      true: "border-blue-500 ring-3 ring-blue-500/50",
    },
  },
})

const iconStyles = "pointer-events-none size-3.5 text-white"

function stopIfLink(event: React.SyntheticEvent) {
  if ((event.target as Element).closest("a")) event.stopPropagation()
}

const stopLinkPresses = {
  onPointerDown: stopIfLink,
  onPointerUp: stopIfLink,
  onMouseDown: stopIfLink,
  onMouseUp: stopIfLink,
  onClick: stopIfLink,
  onKeyDown: stopIfLink,
  onKeyUp: stopIfLink,
}

export interface CheckboxProps extends Omit<CheckboxFieldPrimitiveProps, "className" | "children"> {
  className?: string
  children?: React.ReactNode
  description?: string
  errorMessage?: string | ((validation: ValidationResult) => string)
}

/**
 * `Checkbox` component for use within forms. If multiple related checkboxes are needed, use within a `CheckboxGroup` component.
 * 
 * ## Import
 * ```javascript
 * import { Checkbox } from '#/design-system/checkbox';
 * ```
 */
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
        {({ isSelected, isIndeterminate, isInvalid, isDisabled, isFocusVisible }) => (
          <>
            <div
              className={boxStyles({
                isSelected: isSelected || isIndeterminate,
                isInvalid,
                isDisabled,
                isFocusVisible,
              })}
            >
              {isIndeterminate ? (
                <Minus aria-hidden className={iconStyles} />
              ) : isSelected ? (
                <Check aria-hidden className={iconStyles} />
              ) : null}
            </div>
            {/* One flex item, so rich labels (text mixed with links) flow
                inline instead of each text run becoming its own column.
                Presses that start on a link are kept from reaching the
                field's own press handling, which would otherwise toggle
                the checkbox and swallow the link's navigation. */}
            <span {...stopLinkPresses}>{children}</span>
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
