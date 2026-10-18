import {
  Collection,
  useTableOptions,
  TableHeader as TableHeaderPrimitive,
  Column as ColumnPrimitive,
  type TableHeaderProps,
} from "react-aria-components";
import { Checkbox } from "../checkbox/checkbox";

const selectionColumnStyles = "w-10 border-b border-black-300 bg-black-100 px-3"

function TableHeader<T extends object>(props: TableHeaderProps<T>) {
  const { selectionBehavior, selectionMode } = useTableOptions()
  return (
    <TableHeaderPrimitive {...props}>
      {selectionBehavior === "toggle" && (
        <ColumnPrimitive className={selectionColumnStyles}>
          {selectionMode === "multiple" ? (
            <div className="flex h-9 items-center">
              <Checkbox slot="selection" />
            </div>
          ) : (
            // Single selection has no select-all checkbox, but the header
            // still needs a name for screen readers.
            <span className="sr-only">Select</span>
          )}
        </ColumnPrimitive>
      )}
      <Collection items={props.columns}>{props.children}</Collection>
    </TableHeaderPrimitive>
  )
}

export { TableHeader, type TableHeaderProps };