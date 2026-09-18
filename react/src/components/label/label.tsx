"use client"

import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
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

function Label({ className, isInvalid, ...props }: LabelProps) {
  return <LabelPrimitive {...props} className={cn(labelStyles({ isInvalid }), className)} />
}

export { Label }
