"use client"

import { tv } from "tailwind-variants"
import {
  DropZone as DropZonePrimitive,
  Text,
  FileTrigger,
  type DropZoneProps,
} from "react-aria-components"

const dropZoneStyles = tv({
  base: "flex min-h-24 flex-col items-center justify-center gap-2 rounded-lg border border-dashed border-black-300 bg-white p-8 text-center text-sm text-black-900 outline-none transition-colors",
  variants: {
    isFocusVisible: {
      true: "border-blue-500 ring-3 ring-blue-500/50",
    },
    isDropTarget: {
      true: "border-blue-500 bg-blue-100 ring-3 ring-blue-500/50",
    },
  },
})

/**
 * The `DropZone` component can be used to attach files in a form. Files can be added via drag & drop in the outlined zone or by clicking the browse button to browse the file system.
 * 
 * ## Import
 * ```javascript
 * import { DropZone } from '#/design-system/dropZone';
 * ``` 
 */
function DropZone(props: DropZoneProps) {
  return (
    <DropZonePrimitive
      {...props}
      className={(renderProps) => dropZoneStyles(renderProps)}
    />
  )
}

export { DropZone, FileTrigger, Text }
