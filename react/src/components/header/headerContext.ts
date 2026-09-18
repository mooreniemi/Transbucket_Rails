import { createContext, useContext } from "react"

export interface HeaderContextValue {
  isMobileNavOpen: boolean
  setMobileNavOpen: (open: boolean) => void
}

const HeaderContext = createContext<HeaderContextValue | null>(null)

function useHeaderContext() {
  const context = useContext(HeaderContext)
  if (!context) {
    throw new Error("Header subcomponents must be rendered within <Header>")
  }
  return context
}

// Lets the same HeaderMenu/HeaderMenuItem elements -- passed once as
// Header's children -- render as a desktop popover in one copy of the nav
// and as a mobile accordion in the other, without the consumer authoring
// separate desktop/mobile components.
export type NavVariant = "desktop" | "mobile"

const NavVariantContext = createContext<NavVariant>("desktop")

export { HeaderContext, useHeaderContext, NavVariantContext }
