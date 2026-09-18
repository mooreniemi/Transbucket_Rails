"use client"

import type { ComponentPropsWithoutRef } from "react"
import { Link, type LinkProps } from "react-aria-components"
import { cn } from "#/lib/utils"

export interface GalleryProps extends ComponentPropsWithoutRef<"div"> {}

function Gallery({ className, ...props }: GalleryProps) {
  return (
    // Multi-column masonry layout, not a grid -- items vary in aspect
    // ratio, so each renders at its natural height and stacks within
    // whichever column it lands in, rather than being cropped to a
    // uniform cell.
    <div {...props} className={cn("columns-1 gap-4 sm:columns-2 md:columns-3 lg:columns-4", className)} />
  )
}

// timeZone: "UTC" because a date-only string like "2026-08-02" parses as
// UTC midnight -- formatting in the viewer's local zone can roll it back
// to the previous day west of UTC. Formatting in UTC always matches the
// calendar date that was passed in, string or Date.
const dateFormatter = new Intl.DateTimeFormat("en-US", { dateStyle: "medium", timeZone: "UTC" })

export interface GalleryItemProps extends Omit<LinkProps, "className" | "children"> {
  className?: string
  src: string
  doctor: string
  procedure: string
  updatedAt: string | Date
}

function GalleryItem({
  className,
  src,
  doctor,
  procedure,
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
        <span className="text-sm font-medium text-black-900">{procedure}</span>
        <span className="text-sm text-black-600">{doctor}</span>
        <time dateTime={date.toISOString()} className="text-xs text-black-600 italic">
          Updated {dateFormatter.format(date)}
        </time>
      </div>
    </Link>
  )
}

export { Gallery, GalleryItem }
