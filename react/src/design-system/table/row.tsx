import { tv } from "tailwind-variants";
import {
    useTableOptions,
    Row as RowPrimitive,
    Cell as CellPrimitive,
    Collection,
    type RowProps
} from "react-aria-components";
import { Checkbox } from "../checkbox/checkbox";

const rowStyles = tv({
  base: "cursor-default text-sm text-black-900 outline-none select-none hover:bg-black-100 focus-visible:ring-3 focus-visible:ring-blue-500/50",
  variants: {
    isSelected: {
      true: "bg-blue-100 hover:bg-blue-300/40",
    },
  },
})

function Row<T extends object>({ id, columns, children, ...props }: RowProps<T>) {
  const { selectionBehavior } = useTableOptions()
  return (
    <RowPrimitive id={id} {...props} className={(renderProps) => rowStyles(renderProps)}>
      {selectionBehavior === "toggle" && (
        <CellPrimitive className="border-b border-black-300 px-3 py-2">
          <Checkbox slot="selection" />
        </CellPrimitive>
      )}
      <Collection items={columns}>{children}</Collection>
    </RowPrimitive>
  )
}

export { Row, type RowProps };
