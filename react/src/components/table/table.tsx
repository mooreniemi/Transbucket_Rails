"use client"

import { cn } from "#/lib/utils"
import {
  Table as TablePrimitive,
  type TableProps as TablePrimitiveProps,
} from "react-aria-components"

// Baseline table: sortable columns + row selection. Deliberately leaves out
// react-aria's tree rows, drag-and-drop, and column resizing -- add those
// only once a real screen actually needs them.

export interface TableProps extends Omit<TablePrimitiveProps, "className"> {
  className?: string
}

function Table({ className, ...props }: TableProps) {
  return (
    <div className={cn("w-full overflow-auto rounded-lg border border-black-300", className)}>
      <TablePrimitive {...props} className="w-full border-separate border-spacing-0 text-sm" />
    </div>
  )
}

export { Table }
