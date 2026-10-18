"use client"

import type { ComponentPropsWithoutRef } from "react"
import { Link, type LinkProps } from "react-aria-components"
import { cn } from "cn"
import { formatDateTime } from "#/lib/dateTime"

export interface GalleryProps extends ComponentPropsWithoutRef<"div"> {}

/**
 * 
 * The `Gallery` component is a grid-style container for `GalleryItem` components.
 * 
 * ## Import
 * ```javascript
 * import { Gallery, GalleryItem } from '#/design-system/gallery';
 */
function Gallery({ className, ...props }: GalleryProps) {
  return (
    // Multi-column masonry layout, not a grid -- items vary in aspect
    // ratio, so each renders at its natural height and stacks within
    // whichever column it lands in, rather than being cropped to a
    // uniform cell.
    <div {...props} className={cn("columns-1 gap-4 sm:columns-2 md:columns-3 lg:columns-4", className)} />
  )
}

export interface GalleryItemProps extends Omit<LinkProps, "className" | "children"> {
  className?: string
  src: string
  description: string
  headline: string
  updatedAt: string | Date
}

/**
 * 
 * The `GalleryItem` component is an individual card featuring a hero image, a headline, a description, and a date. It should be used within a `Gallery` component. This component should link to a detail page.
 * 
 * ## Import
 * ```javascript
 * import { Gallery, GalleryItem } from '#/design-system/gallery';
 */
function GalleryItem({
  className,
  src,
  description,
  headline,
  updatedAt,
  ...props
}: GalleryItemProps) {
  const date = typeof updatedAt === "string" ? new Date(updatedAt) : updatedAt

  return (
    <Link
      {...props}
      className={cn(
        "group mb-4 flex min-w-48 flex-col overflow-hidden rounded-lg border border-black-300 outline-none transition-shadow break-inside-avoid hover:shadow-md focus-visible:ring-3 focus-visible:ring-blue-500/50",
        className,
      )}
    >
      {/* No aspect-ratio/object-cover -- images vary in aspect ratio and
          orientation, so each renders at its natural size within the
          column rather than being cropped to a uniform shape. */}
      <img src={src} alt="" className="block w-full transition-transform group-hover:scale-105" />
      <div className="flex flex-col gap-1 p-3">
        <span className="text-sm font-medium text-black-900">{headline}</span>
        <span className="text-sm text-black-600">{description}</span>
        <time dateTime={date.toISOString()} className="text-xs text-black-600 italic">
          Updated {formatDateTime(date)}
        </time>
      </div>
    </Link>
  )
}

export { Gallery, GalleryItem }
