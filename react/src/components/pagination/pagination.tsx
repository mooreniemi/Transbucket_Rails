"use client"

import { ChevronLeft, ChevronRight, MoreHorizontal } from "lucide-react"
import { cn } from "#/lib/utils"
import { Button } from "../button/button"

export interface PaginationProps {
  /** The current page, 1-indexed. */
  page: number
  /** Total number of pages. */
  totalPages: number
  /**
   * Returns the URL for a given page. Page links render as real anchor
   * elements pointing at these URLs so each page has its own unique,
   * crawlable address -- see Google's guidance on paginated content:
   * https://developers.google.com/search/docs/specialty/ecommerce/pagination-and-incremental-page-loading
   */
  getPageHref: (page: number) => string
  /** Called when a page link is activated, e.g. to update app state/history. */
  onPageChange?: (page: number) => void
  className?: string
  "aria-label"?: string
}

const ELLIPSIS = "ellipsis"
// Page links shown on each side of the current page.
const SIBLING_COUNT = 1
const TOTAL_SLOTS = SIBLING_COUNT * 2 + 5 // first + last + current + 2 ellipses

function getPageRange(page: number, totalPages: number) {
  if (totalPages <= TOTAL_SLOTS) {
    return Array.from({ length: totalPages }, (_, i) => i + 1)
  }

  const leftSibling = Math.max(page - SIBLING_COUNT, 1)
  const rightSibling = Math.min(page + SIBLING_COUNT, totalPages)
  const showLeftEllipsis = leftSibling > 2
  const showRightEllipsis = rightSibling < totalPages - 1

  const range: (number | typeof ELLIPSIS)[] = [1]

  if (showLeftEllipsis) range.push(ELLIPSIS)
  for (let p = Math.max(leftSibling, 2); p <= Math.min(rightSibling, totalPages - 1); p++) {
    range.push(p)
  }
  if (showRightEllipsis) range.push(ELLIPSIS)

  range.push(totalPages)

  return range
}

function Pagination({
  page,
  totalPages,
  getPageHref,
  onPageChange,
  className,
  "aria-label": ariaLabel = "Pagination",
}: PaginationProps) {
  const range = getPageRange(page, totalPages)
  const isFirstPage = page <= 1
  const isLastPage = page >= totalPages

  return (
    <nav aria-label={ariaLabel} className={cn("flex flex-col items-center gap-2", className)}>
      <ul className="flex items-center gap-1">
        <li>
          <Button
            variant="ghost"
            size="icon-sm"
            aria-label="Previous page"
            href={getPageHref(Math.max(page - 1, 1))}
            isDisabled={isFirstPage}
            onPress={() => onPageChange?.(page - 1)}
          >
            <ChevronLeft aria-hidden />
          </Button>
        </li>
        {range.map((item, index) =>
          item === ELLIPSIS ? (
            <li key={`ellipsis-${index}`} aria-hidden className="max-[300px]:hidden">
              <span className="flex size-7 items-center justify-center text-black-600">
                <MoreHorizontal className="size-4" />
              </span>
            </li>
          ) : item === page ? (
            <li key={item} className="max-[300px]:hidden">
              {/* Current page is shown, not linked -- matches the standard
                  pagination a11y pattern of marking aria-current="page"
                  on a non-interactive item rather than a self link. */}
              <span
                aria-current="page"
                className="flex size-7 items-center justify-center rounded-[min(var(--radius-md),12px)] bg-blue-300 text-sm font-medium text-black-900"
              >
                {item}
              </span>
            </li>
          ) : (
            <li key={item} className="max-[300px]:hidden">
              <Button
                variant="ghost"
                size="icon-sm"
                href={getPageHref(item)}
                aria-label={`Page ${item}`}
                onPress={() => onPageChange?.(item)}
              >
                {item}
              </Button>
            </li>
          ),
        )}
        <li>
          <Button
            variant="ghost"
            size="icon-sm"
            aria-label="Next page"
            href={getPageHref(Math.min(page + 1, totalPages))}
            isDisabled={isLastPage}
            onPress={() => onPageChange?.(page + 1)}
          >
            <ChevronRight aria-hidden />
          </Button>
        </li>
      </ul>
      <p className="text-xs text-black-600">
        Page {page} of {totalPages}
      </p>
    </nav>
  )
}

export { Pagination }
