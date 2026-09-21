"use client"

import { useEffect, useState, type ComponentPropsWithoutRef, type ReactNode } from "react"
import { Menu as MenuIcon, X } from "lucide-react"
import { cn } from "#/lib/utils"
import { Button as ButtonPrimitive, Link } from "react-aria-components"
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
  /**
   * Target for the built-in skip-navigation link, e.g. "#main-content".
   * Pair it with a target element carrying that id and tabIndex={-1} so
   * focus actually lands there. Every page that renders a Header gets one
   * of these for free -- pass false to omit it (e.g. in isolated previews).
   */
  skipNavHref?: string | false
}

function Header({
  className,
  sectionRight,
  children,
  skipNavHref = "#main-content",
  ...props
}: HeaderProps) {
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
          "relative border-b border-black-200 bg-white px-4 py-3 shadow-[0_8px_10px_-13px_var(--color-black-300)]",
          className,
        )}
      >
        {skipNavHref && <SkipNav href={skipNavHref} />}
        <div className="flex w-full items-center justify-between">
          <div className="flex items-center gap-4">
            <h1>
              <a href="/" className="inline-block hover:no-underline focus-visible:no-underline">
                <img src={logo} alt="" className="h-8 w-auto inline"/>
                <span className="font-bold align-middle ms-2 text-black-900">Transbucket</span>
              </a>
            </h1>
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
        </div>
        <div
          inert={!isMobileNavOpen}
          className={cn(
            // A full-height sheet: starts under the header and runs to the
            // bottom of the viewport (100% here is the header's own height,
            // since the header is the containing block), scrolling
            // internally when expanded accordions outgrow it. Fades/slides
            // rather than animating height, and visibility is transitioned
            // too so the closed sheet is hidden without popping.
            "absolute inset-x-0 top-full z-40 max-md:block md:hidden h-[calc(100dvh-100%)] overflow-y-auto overscroll-contain bg-white transition-[opacity,translate,visibility] duration-200",
            isMobileNavOpen ? "visible translate-y-0 opacity-100" : "invisible -translate-y-2 opacity-0",
          )}
        >
          <NavVariantContext.Provider value="mobile">
            <nav aria-label="Primary" className="flex flex-col gap-1 p-4">
              {children}
              <div className="mt-2 flex flex-col gap-1 border-t border-black-200 pt-3">
                {sectionRight}
              </div>
            </nav>
          </NavVariantContext.Provider>
        </div>
      </header>
    </HeaderContext.Provider>
  )
}

// Hidden until focused (first Tab press on the page), then jumps keyboard
// users past the header straight to the target passed as skipNavHref.
function SkipNav({ href }: { href: string }) {
  return (
    <Link
      href={href}
      // Padding/background/rounding live on the inner span, not here --
      // Tailwind's own not-sr-only utility resets padding to 0 as part of
      // undoing sr-only, and .focus\:not-sr-only:focus (class+pseudo)
      // outranks a plain .px-6/.py-4 (class only), so padding on this
      // element would always lose to that reset while focused.
      className="sr-only rounded-md outline-none focus:not-sr-only focus:fixed focus:top-4 focus:end-4 focus:z-50 focus-visible:ring-3 focus-visible:ring-blue-300/50"
    >
      <span className="block rounded-md bg-blue-300 px-3 py-2 text-sm font-medium text-black-900">
        Skip to main content
      </span>
    </Link>
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
