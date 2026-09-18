"use client"

import { useEffect, useState, type ComponentPropsWithoutRef, type ReactNode } from "react"
import { Menu as MenuIcon, X } from "lucide-react"
import { cn } from "#/lib/utils"
import { Button as ButtonPrimitive } from "react-aria-components"
import { HeaderContext, NavVariantContext, useHeaderContext } from "./headerContext"
import logo from "#/assets/keys_optimized.png"

export interface HeaderProps extends Omit<ComponentPropsWithoutRef<"header">, "children"> {
  /**
   * Primary nav items (HeaderLink / HeaderMenu). Rendered twice internally
   * -- once in the desktop nav row, once in the mobile menu -- so each item
   * only needs to be authored once and adapts to whichever it lands in.
   */
  children?: ReactNode
  /** Right-aligned content, e.g. a sign-in link. Shown next to the desktop nav and inside the mobile menu. */
  sectionRight?: ReactNode
}

function Header({ className, sectionRight, children, ...props }: HeaderProps) {
  const [isMobileNavOpen, setMobileNavOpen] = useState(false)

  useEffect(() => {
    if (!isMobileNavOpen) return
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") setMobileNavOpen(false)
    }
    document.addEventListener("keydown", onKeyDown)
    return () => document.removeEventListener("keydown", onKeyDown)
  }, [isMobileNavOpen])

  return (
    <HeaderContext.Provider value={{ isMobileNavOpen, setMobileNavOpen }}>
      <header
        {...props}
        className={cn(
          "relative flex items-center justify-between gap-4 border-b border-black-300 bg-white px-4 py-3",
          className,
        )}
      >
        <div className="flex items-center gap-4">
          <a href="/">
            <img src={logo} alt="" className="h-8 w-auto inline"/>
            <span className="font-bold align-middle ml-2">Transbucket</span>
          </a>
          <NavVariantContext.Provider value="desktop">
            {/* max-md:hidden + md:flex (not the bare "hidden" utility) so
                both sides of the toggle are variant-scoped and mutually
                exclusive by media query -- pairing a bare display utility
                with a responsive one on the same element has unreliable
                cascade order in this project's build. */}
            <nav aria-label="Primary" className="max-md:hidden md:flex items-center gap-1">
              {children}
            </nav>
          </NavVariantContext.Provider>
        </div>
        <div className="flex items-center gap-4">
          <NavVariantContext.Provider value="desktop">
            <div className="max-md:hidden md:flex items-center gap-4">{sectionRight}</div>
          </NavVariantContext.Provider>
          <HeaderMobileTrigger />
        </div>
        <div
          inert={!isMobileNavOpen}
          className={cn(
            "absolute inset-x-0 top-full max-md:grid md:hidden border-b border-black-300 bg-white transition-[grid-template-rows] duration-200",
            isMobileNavOpen ? "grid-rows-[1fr]" : "grid-rows-[0fr]",
          )}
        >
          <NavVariantContext.Provider value="mobile">
            <nav aria-label="Primary" className="flex flex-col gap-1 overflow-hidden p-2">
              {children}
              {sectionRight}
            </nav>
          </NavVariantContext.Provider>
        </div>
      </header>
    </HeaderContext.Provider>
  )
}

function HeaderMobileTrigger() {
  const { isMobileNavOpen, setMobileNavOpen } = useHeaderContext()
  return (
    <ButtonPrimitive
      aria-expanded={isMobileNavOpen}
      aria-label={isMobileNavOpen ? "Close menu" : "Open menu"}
      onPress={() => setMobileNavOpen(!isMobileNavOpen)}
      className="max-md:flex md:hidden size-9 items-center justify-center rounded-md text-black-900 outline-none hover:bg-black-100 focus-visible:ring-3 focus-visible:ring-blue-500/50"
    >
      {isMobileNavOpen ? (
        <X aria-hidden className="size-5" />
      ) : (
        <MenuIcon aria-hidden className="size-5" />
      )}
    </ButtonPrimitive>
  )
}

export { Header }
