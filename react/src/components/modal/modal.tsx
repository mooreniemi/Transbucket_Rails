"use client"

import type * as React from "react"
import { X } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "#/lib/utils"
import {
  ModalOverlay as ModalOverlayPrimitive,
  Modal as ModalPrimitive,
  Dialog as DialogPrimitive,
  Heading,
  DialogTrigger,
  type ModalOverlayProps as ModalOverlayPrimitiveProps,
  type DialogProps as DialogPrimitiveProps,
} from "react-aria-components"
import { Button } from "../button/button"

const overlayStyles = tv({
  base: "fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4 backdrop-blur-xs transition-opacity",
  variants: {
    isEntering: {
      true: "duration-200 ease-out",
    },
    isExiting: {
      true: "duration-150 ease-in opacity-0",
    },
  },
})

const modalStyles = tv({
  base: "w-full max-w-md rounded-lg border border-black-300 bg-white text-black-900 shadow-lg outline-none transition-all",
  variants: {
    isEntering: {
      true: "duration-200 ease-out",
    },
    isExiting: {
      true: "scale-95 opacity-0 duration-150 ease-in",
    },
  },
})

export interface ModalProps extends Omit<ModalOverlayPrimitiveProps, "className"> {
  className?: string
}

function Modal({ className, ...props }: ModalProps) {
  return (
    <ModalOverlayPrimitive {...props} className={(renderProps) => overlayStyles(renderProps)}>
      <ModalPrimitive
        {...props}
        className={(renderProps) => cn(modalStyles(renderProps), className)}
      />
    </ModalOverlayPrimitive>
  )
}

export interface DialogProps extends Omit<DialogPrimitiveProps, "className" | "children"> {
  className?: string
  children?: React.ReactNode
  title?: string
  showCloseButton?: boolean
}

function Dialog({ className, title, showCloseButton = true, children, ...props }: DialogProps) {
  return (
    <DialogPrimitive {...props} className={cn("relative flex flex-col gap-3 p-6 outline-none", className)}>
      {title && (
        <Heading slot="title" className="pr-6 text-lg font-semibold text-black-900">
          {title}
        </Heading>
      )}
      {showCloseButton && (
        <Button
          slot="close"
          variant="ghost"
          size="icon-sm"
          className="absolute top-3 right-3"
          aria-label="Close"
        >
          <X aria-hidden className="size-4" />
        </Button>
      )}
      {children}
    </DialogPrimitive>
  )
}

export { Modal, Dialog, DialogTrigger, Heading }
