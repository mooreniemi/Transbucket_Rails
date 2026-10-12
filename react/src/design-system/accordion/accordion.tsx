"use client"

import type { ReactNode } from "react"
import { ChevronDown, ChevronRight } from "lucide-react"
import { cn } from "#/lib/utils"
import {
  Button as ButtonPrimitive,
  Disclosure,
  DisclosureGroup,
  DisclosurePanel,
  Heading,
  type DisclosureGroupProps,
  type DisclosureProps,
} from "react-aria-components"

export interface AccordionProps extends Omit<DisclosureGroupProps, "className"> {
  className?: string
}

// A plain stack of AccordionItems, no box around them. By default several
// items can be open at once; pass allowsMultipleExpanded={false} for
// one-at-a-time.
function Accordion({ className, ...props }: AccordionProps) {
  return (
    <DisclosureGroup
      allowsMultipleExpanded
      {...props}
      className={cn("flex flex-col gap-1", className)}
    />
  )
}

export interface AccordionItemProps extends Omit<DisclosureProps, "className" | "children"> {
  /** The always-visible trigger text. */
  title: ReactNode
  /** Heading level for the trigger, so it fits the page's outline. */
  headingLevel?: 2 | 3 | 4 | 5 | 6
  className?: string
  children?: ReactNode
}

function AccordionItem({
  title,
  headingLevel = 3,
  className,
  children,
  ...props
}: AccordionItemProps) {
  return (
    <Disclosure {...props} className={className}>
      {({ isExpanded }) => (
        <>
          <Heading level={headingLevel} className="m-0">
            <ButtonPrimitive
              slot="trigger"
              className="-ms-1 flex cursor-pointer items-center gap-2 rounded-md px-1 py-1 text-start text-sm font-medium text-black-900 outline-none transition-colors hover:bg-black-100 focus-visible:ring-3 focus-visible:ring-blue-500/50 disabled:cursor-not-allowed disabled:text-black-600"
            >
              {isExpanded ? (
                <ChevronDown aria-hidden className="size-4 shrink-0" />
              ) : (
                <ChevronRight aria-hidden className="size-4 shrink-0 rtl:rotate-180" />
              )}
              <span>{title}</span>
            </ButtonPrimitive>
          </Heading>
          <DisclosurePanel
            // Tailwind's preflight strips paragraph margins and list markers,
            // so give rich content (paragraphs, lists) its spacing back here.
            className="py-1 ps-6 text-sm text-black-700 [&>*+*]:mt-2 [&_ul]:list-disc [&_ul]:ps-5 [&_ol]:list-decimal [&_ol]:ps-5 [&_li+li]:mt-0.5"
          >
            {children}
          </DisclosurePanel>
        </>
      )}
    </Disclosure>
  )
}

export { Accordion, AccordionItem }
