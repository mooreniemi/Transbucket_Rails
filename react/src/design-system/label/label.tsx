"use client"

import { tv } from "tailwind-variants"
import { cn } from "cn"
import { Label as LabelPrimitive, type LabelProps as LabelPrimitiveProps } from "react-aria-components"

const labelStyles = tv({
  base: "text-sm font-medium text-black-900",
  variants: {
    isInvalid: {
      true: "text-red-500",
    },
  },
})

export interface LabelProps extends Omit<LabelPrimitiveProps, "className"> {
  className?: string
  isInvalid?: boolean
}

/**
 * The `Label` component is used to identify form inputs both visually and for screen readers.
 * 
 * ## Import
 * ```javascript
 * import { Label } from '#/design-system/label';
 * ```
 * 
 * ## Accessibilty information
 * All form inputs should be labeled. If the default position of an input's built-in label is undesirable this standalone label component can be used. If an input has an icon or some other information that makes a label redundent to sighted users an `aria-label` must be used on the input in lieu of an associated label element.
 */
function Label({ className, isInvalid, ...props }: LabelProps) {
  return <LabelPrimitive {...props} className={cn(labelStyles({ isInvalid }), className)} />
}

export { Label }
