import { TableBody as TableBodyPrimitive, type TableBodyProps } from "react-aria-components";
import { cn } from "#/lib/utils";

function TableBody<T extends object>(props: TableBodyProps<T>) {
  return (
    <TableBodyPrimitive
      {...props}
      className={(renderProps) =>
        cn("text-black-900", renderProps.isEmpty && "h-32 text-center text-sm text-black-600")
      }
    />
  )
}

export { TableBody, type TableBodyProps };
