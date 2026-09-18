"use client"

import { Link, type LinkProps } from "react-aria-components"
import { cn } from "#/lib/utils"
import { useHeaderContext } from "./headerContext"

export interface HeaderLinkProps extends Omit<LinkProps, "className"> {
  className?: string
}

// Same styling and behavior whether it lands in the desktop nav row or the
// mobile menu -- closing the mobile nav on press is a no-op when it's
// already closed, so this doesn't need to know which one it's in.
function HeaderLink({ className, onPress, ...props }: HeaderLinkProps) {
  const { setMobileNavOpen } = useHeaderContext()
  return (
    <Link
      {...props}
      onPress={(e) => {
        onPress?.(e)
        setMobileNavOpen(false)
      }}
      className={cn(
        "rounded-md px-3 py-2 text-sm font-medium text-black-900 outline-none transition-colors hover:bg-black-100 focus-visible:ring-3 focus-visible:ring-blue-500/50 aria-expanded:bg-black-100 aria-[current=page]:font-semibold aria-[current=page]:underline aria-[current=page]:decoration-yellow-500 aria-[current=page]:decoration-2 aria-[current=page]:underline-offset-10",
        className,
      )}
    />
  )
}

export { HeaderLink }
