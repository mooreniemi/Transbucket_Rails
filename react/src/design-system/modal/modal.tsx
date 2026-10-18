"use client"

import { type  ReactNode } from "react"
import { X } from "lucide-react"
import { tv } from "tailwind-variants"
import { cn } from "cn"
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

export interface DialogProps extends Omit<DialogPrimitiveProps, "className" | "children"> {
  className?: string
  children?: ReactNode
  title?: string
  showCloseButton?: boolean;
}

function Dialog({ className, title, showCloseButton = true, children, ...props }: DialogProps) {
  return (
    <DialogPrimitive {...props} className={cn("relative flex flex-col gap-3 p-6 outline-none", className)}>
      {title && (
        <Heading slot="title" className="pe-6 text-lg font-semibold text-black-900">
          {title}
        </Heading>
      )}
      {showCloseButton && (
        <Button
          slot="close"
          variant="ghost"
          size="icon-sm"
          className="absolute top-3 inset-e-3"
          aria-label="Close"
        >
          <X aria-hidden className="size-4" />
        </Button>
      )}
      {children}
    </DialogPrimitive>
  )
}

export interface ModalProps extends Omit<ModalOverlayPrimitiveProps, "className" | "children"> {
  className?: string;
  dialogClassName?: string;
  title?: string;
  showCloseButton?: boolean;
  children: ReactNode;
  role?: 'dialog' | 'alertdialog';
}

/**
 * 
 * The `Modal` component opens an overlay with a dialog. You can use the `DialogTrigger` to wrap clickable elements to open the modal or manually set `isOpen`.
 * 
 * ## Import
 * ```javascript
 * import { Modal, DialogTrigger } from '#/design-system/modal';
 * ```
 * 
 * ## Accessibility information
 * The default role for the `Modal` component is `dialog`. For critical workflow-interrupting alerts use `role="alertdialog"` to notify users.
 */
function Modal({ className, dialogClassName, title, children, isDismissable = true, role='dialog', ...props }: ModalProps) {
  return (
    <ModalOverlayPrimitive isDismissable={isDismissable} isKeyboardDismissDisabled={!isDismissable} {...props} className={(renderProps) => overlayStyles(renderProps)}>
      <ModalPrimitive
        {...props}
        isKeyboardDismissDisabled={!isDismissable}
        isDismissable={isDismissable}
        className={(renderProps) => cn(modalStyles(renderProps), className)}
      >
        <Dialog title={title} showCloseButton={isDismissable} className={dialogClassName} role={role}>
          {children}
        </Dialog>
      </ModalPrimitive>
    </ModalOverlayPrimitive>
  )
}

export { Modal, Dialog, DialogTrigger, Heading }
