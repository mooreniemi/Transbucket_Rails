"use client"

import { cn } from "cn"
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

/**
 *
 * The `Table` component is for displaying large data sets. Refer to the [React-Aria table documentation](https://react-aria.adobe.com/Table) for full set of features for the underlying component. This component is responsive, but cards are preferred for mobile devices and in cases where data is less dense.
 * 
 * ## Import
 * ```javascript
 * import { Table, Cell, Column, Row, TableHeader, TableBody } from '#/design-system/table';
 * ```
 */
function Table({ className, ...props }: TableProps) {
  return (
    <div className={cn("w-full overflow-auto rounded-lg border border-black-300", className)}>
      <TablePrimitive {...props} className="w-full border-separate border-spacing-0 text-sm" />
    </div>
  )
}

export { Table }
