import { Column as ColumnPrimitive } from 'react-aria-components'
import { ArrowUp } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import type { ColumnProps } from "react-aria-components"

const columnStyles = tv({
  base: "border-b border-black-300 bg-black-100 px-3 text-start text-sm font-semibold text-black-900 outline-none focus-visible:ring-3 focus-visible:ring-blue-500/50",
})

function Column(props: ColumnProps) {
  return (
    <ColumnPrimitive {...props} className={columnStyles()}>
      {({ allowsSorting, sortDirection }) => (
        <div className="flex h-9 items-center gap-1">
          <span className="truncate">{props.children as React.ReactNode}</span>
          {allowsSorting && (
            <ArrowUp
              aria-hidden
              className={cn(
                "size-3.5 shrink-0 text-black-600 transition-transform",
                sortDirection === "descending" && "rotate-180",
                !sortDirection && "invisible"
              )}
            />
          )}
        </div>
      )}
    </ColumnPrimitive>
  )
}

export { Column, type ColumnProps };
