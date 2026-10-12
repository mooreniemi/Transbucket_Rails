import type { ComponentProps, ReactNode } from "react"
import { Info, OctagonAlert, TriangleAlert } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"

const alertStyles = tv({
  base: "flex items-start gap-3 rounded-lg border p-3 text-sm text-black-900",
  variants: {
    variant: {
      info: "border-blue-300 bg-blue-100",
      warning: "border-yellow-500 bg-yellow-100",
      // A tint of the brand red rather than red-50, which is a muddy grey.
      error: "border-red-400 bg-red-500/10",
    },
  },
})

const iconStyles = tv({
  base: "mt-0.5 size-4 shrink-0",
  variants: {
    variant: {
      info: "text-blue-700",
      warning: "text-yellow-800",
      error: "text-red-700",
    },
  },
})

const defaultIcons = {
  info: Info,
  warning: TriangleAlert,
  error: OctagonAlert,
}

export interface AlertProps extends Omit<ComponentProps<"div">, "title"> {
  variant?: keyof typeof defaultIcons
  /** Short bold lead-in above the message. */
  title?: ReactNode
  /** Replaces the variant's default icon; pass false to omit it. */
  icon?: ReactNode | false
}

// Callout for important information. Defaults to role="note" -- content
// that's present on load, which screen readers read in place -- and to
// role="alert" for the error variant, so it's announced immediately. Pass
// role explicitly to override either default.
function Alert({
  variant = "info",
  title,
  icon,
  role,
  className,
  children,
  ...props
}: AlertProps) {
  const DefaultIcon = defaultIcons[variant]

  return (
    <div {...props} role={role ?? (variant === "error" ? "alert" : "note")} className={cn(alertStyles({ variant }), className)}>
      {icon === false ? null : icon ?? <DefaultIcon aria-hidden className={iconStyles({ variant })} />}
      <div className="min-w-0 flex-1">
        {title && <p className="font-semibold">{title}</p>}
        {children && <div className={title ? "mt-0.5" : undefined}>{children}</div>}
      </div>
    </div>
  )
}

export { Alert }
