"use client"

import { useContext, type AriaAttributes, type ReactNode } from "react"
import { ChevronDown } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import {
  Button as ButtonPrimitive,
  MenuTrigger,
  Menu as MenuPrimitive,
  MenuItem as MenuItemPrimitive,
  Popover,
  Disclosure,
  DisclosurePanel,
  Heading,
  Link,
  type LinkProps,
} from "react-aria-components"
import { NavVariantContext, useHeaderContext } from "./headerContext";

const triggerStyles =
  "cursor-pointer rounded-md px-3 py-2 text-sm font-medium text-black-900 outline-none transition-colors hover:bg-black-100 focus-visible:ring-3 focus-visible:ring-blue-500/50 aria-expanded:bg-black-100"

export interface HeaderMenuProps {
  label: ReactNode;
  children?: ReactNode
  className?: string
}

// Renders as a popover menu in the desktop nav and as an accordion in the
// mobile menu, based on which copy of Header's children it's part of --
// see NavVariantContext in headerContext.ts. Either way, HeaderMenuItem
// children are authored once and adapt the same way.
function HeaderMenu({ label, children, className }: HeaderMenuProps) {
  const variant = useContext(NavVariantContext)

  if (variant === "mobile") {
    return (
      <Disclosure className={cn("group flex flex-col", className)}>
        <Heading className="m-0">
          <ButtonPrimitive slot="trigger" className={cn(triggerStyles, "flex w-full items-center justify-between")}>
            <span className="flex items-center">{label}</span>
            <ChevronDown
              aria-hidden
              className="size-4 transition-transform group-data-expanded:rotate-180"
            />
          </ButtonPrimitive>
        </Heading>
        <DisclosurePanel className="flex flex-col gap-0.5 overflow-hidden py-1 pl-3">
          {children}
        </DisclosurePanel>
      </Disclosure>
    )
  }

  return (
    <MenuTrigger>
      <ButtonPrimitive className={cn(triggerStyles, "flex items-center gap-1", className)}>
        {label}
        <ChevronDown aria-hidden className="size-3.5" />
      </ButtonPrimitive>
      <Popover className="min-w-40 overflow-auto rounded-lg border border-black-300 bg-white p-1 shadow-lg outline-none">
        <MenuPrimitive className="outline-none">{children}</MenuPrimitive>
      </Popover>
    </MenuTrigger>
  )
}

const menuItemStyles = tv({
  base: "flex cursor-pointer items-center rounded-md px-2 py-1.5 text-sm text-black-900 outline-none select-none",
  variants: {
    isFocused: { true: "bg-blue-100" },
    isDisabled: { true: "cursor-not-allowed text-black-600" },
  },
})

export interface HeaderMenuItemProps
  extends Pick<LinkProps, "href" | "target" | "rel" | "isDisabled" | "onPress"> {
  className?: string
  children?: ReactNode
  "aria-current"?: AriaAttributes["aria-current"]
}

function HeaderMenuItem({ children, className, onPress, ...props }: HeaderMenuItemProps) {
  const variant = useContext(NavVariantContext)
  const { setMobileNavOpen } = useHeaderContext()

  if (variant === "mobile") {
    return (
      <Link
        {...props}
        onPress={(e) => {
          onPress?.(e)
          setMobileNavOpen(false)
        }}
        className={cn(
          "rounded-md px-3 py-2 text-sm font-medium text-black-900 outline-none hover:bg-black-100 focus-visible:ring-3 focus-visible:ring-blue-500/50",
          className,
        )}
      >
        {children}
      </Link>
    )
  }

  return (
    <MenuItemPrimitive
      {...props}
      textValue={typeof children === "string" ? children : undefined}
      className={(renderProps) => menuItemStyles({ ...renderProps, className })}
    >
      {children}
    </MenuItemPrimitive>
  )
}

export { HeaderMenu, HeaderMenuItem }
