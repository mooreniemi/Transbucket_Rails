"use client"

import { X } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import { flushSync } from "react-dom"
import {
  UNSTABLE_ToastRegion as ToastRegionPrimitive,
  UNSTABLE_Toast as ToastPrimitive,
  UNSTABLE_ToastQueue as ToastQueue,
  UNSTABLE_ToastContent as ToastContent,
  Button as ToastButtonPrimitive,
  Text,
  type ToastProps as ToastPrimitiveProps,
} from "react-aria-components"

export interface ToastContentValue {
  title: string
  description?: string
  variant?: "default" | "destructive" | "success"
}

// Baseline toast: a fixed content shape (title/description/variant).
// Deliberately leaves out react-aria's generic <T> content typing -- wrap
// this file's exports if a screen ever needs a genuinely different toast
// content shape. Uses react-aria-components' UNSTABLE_ Toast APIs -- still
// unstable upstream as of this version.
//
// The queue itself is owned by the app, not this library: call
// createToastQueue() once near the app root, keep the returned queue
// wherever the app keeps that kind of singleton, and pass it to
// <ToastRegion queue={...} /> and to queue.add(...) calls.
function createToastQueue() {
  return new ToastQueue<ToastContentValue>({
    wrapUpdate(fn) {
      if ("startViewTransition" in document) {
        // A transition already in flight (e.g. toasts firing in quick
        // succession) gets aborted by the new one -- that's expected, not an
        // error, so swallow the rejection rather than let it surface as an
        // unhandled promise rejection.
        const transition = document.startViewTransition(() => {
          flushSync(fn)
        })
        transition.ready.catch(() => {})
        transition.finished.catch(() => {})
      } else {
        fn()
      }
    },
  })
}

const toastStyles = tv({
  base: "flex w-80 items-center gap-3 rounded-lg border px-4 py-3 shadow-lg outline-none transition-all",
  variants: {
    variant: {
      default: "border-black-300 bg-white text-black-900",
      destructive: "border-red-500 bg-red-500 text-white",
      success: "border-blue-500 bg-blue-500 text-white",
    },
    isFocusVisible: {
      true: "ring-3 ring-blue-500/50",
    },
  },
})

function Toast(props: ToastPrimitiveProps<ToastContentValue>) {
  const variant = props.toast.content.variant ?? "default"
  return (
    <ToastPrimitive
      {...props}
      className={(renderProps) => toastStyles({ variant, isFocusVisible: renderProps.isFocusVisible })}
    >
      <ToastContent className="flex min-w-0 flex-1 flex-col gap-0.5">
        <Text slot="title" className="text-sm font-semibold">
          {props.toast.content.title}
        </Text>
        {props.toast.content.description && (
          <Text slot="description" className="text-xs opacity-90">
            {props.toast.content.description}
          </Text>
        )}
      </ToastContent>
      <ToastButtonPrimitive
        slot="close"
        aria-label="Close"
        className="flex size-6 shrink-0 items-center justify-center rounded-md outline-none hover:bg-black-900/10 focus-visible:ring-3 focus-visible:ring-blue-500/50"
      >
        <X aria-hidden className="size-4" />
      </ToastButtonPrimitive>
    </ToastPrimitive>
  )
}

export interface ToastRegionProps {
  queue: ToastQueue<ToastContentValue>
  className?: string
}

function ToastRegion({ queue, className }: ToastRegionProps) {
  return (
    <ToastRegionPrimitive
      queue={queue}
      className={cn("fixed right-4 bottom-4 z-50 flex flex-col-reverse gap-2 outline-none", className)}
    >
      {({ toast }) => <Toast toast={toast} />}
    </ToastRegionPrimitive>
  )
}

export type ToastQueueInstance = ToastQueue<ToastContentValue>

export { Toast, ToastRegion, createToastQueue }
