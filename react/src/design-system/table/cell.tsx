import { tv } from "tailwind-variants";
import { Cell as CellPrimitive, type CellProps } from "react-aria-components";

const cellStyles = tv({
  base: "truncate border-b border-black-300 px-3 py-2 outline-none focus-visible:ring-3 focus-visible:ring-blue-500/50",
})

function Cell(props: CellProps) {
  return <CellPrimitive {...props} className={cellStyles()} />
}

export { Cell, type CellProps };
