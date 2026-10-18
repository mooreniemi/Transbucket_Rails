"use client"

import { tv } from "tailwind-variants"
import { cn } from "cn"
import { type ReactNode } from "react";
import {
  TextField as TextFieldPrimitive,
  Input as InputPrimitive,
  Text,
  FieldError,
  type ButtonProps as ButtonPrimitiveProps,
  type TextFieldProps as TextFieldPrimitiveProps,
  type ValidationResult,
} from "react-aria-components"
import { Label } from '../label';
import { Button } from '../button';

const inputStyles = tv({
  base: "w-full rounded-lg border border-black-300 bg-white px-3 py-1.5 text-sm text-black-900 outline-none transition-colors placeholder:text-black-600 focus-visible:border-blue-500 focus-visible:ring-3 focus-visible:ring-blue-500/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-red-500 aria-invalid:ring-3 aria-invalid:ring-red-500/20",
  variants: {
    withPrepend: {
      true: 'rounded-s-none border-l-0 pl-1.5',
    },
    withAppend: {
      true: 'rounded-e-none border-r-0',
    }
  }
});

const prependStyles = tv({
  base: 'flex-none rounded-s-lg py-1 text-sm flex items-center justify-center py-1 pe-1.5 pl-3',
  variants: {
    button: {
      true: 'border-black-300 rounded-e-none h-auto relative focus-visible:z-10',
      false: 'border border-r-0 border-black-300 text-black-900'
    }
  }
});

const appendStyles = tv({
  base: 'flex-none rounded-e-lg py-1 text-sm flex items-center justify-center py-1 pl-1.5 pr-3',
  variants: {
    button: {
      true: 'border-black-300 rounded-s-none h-auto relative focus-visible:z-10',
      false: 'border border-l-0 border-black-300 text-black-900'
    }
  }
});

export interface StartEndElement {
  content: ReactNode;
  onClick?: ButtonPrimitiveProps["onClick"];
  isPressed?: boolean; // Indicate state if button is a toggle (i.e. show/hide password)
  ariaLabel?: string; // Use for icon only buttons, if element is decorative and not functional leave undefined
}

export interface InputProps extends Omit<TextFieldPrimitiveProps, "className"> {
  className?: string;
  label?: string;
  description?: string;
  placeholder?: string;
  errorMessage?: string | ((validation: ValidationResult) => string);
  prepend?: StartEndElement;
  append?: StartEndElement;
}

/**
 * 
 * Input component for forms. Defaults to a plain text input, for other types use the `type` property. Ensure you are using proper [autocomplete attributes](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/autocomplete) to make forms easier for users.
 * 
 * ## Import
 * ```javascript
 * import { Input } from '#/design-system/input';
 * ```
 * ## Accessibilty information
 * All inputs should be labeled. If the default position of an input's built-in label is undesirable the [standalone label component](?path=/docs/components-forms-label--docs) can be used. If an input has an icon or some other information that makes a label redundent to sighted users an `aria-label` must be used on the input in lieu of an associated label element.
 */
function Input({
  className,
  label,
  description,
  placeholder,
  errorMessage,
  prepend,
  append,
  ...props
}: InputProps) {
  return (
    <TextFieldPrimitive {...props} className={cn("flex flex-col gap-1", className)}>
      {label && <Label isInvalid={!!errorMessage}>{label}</Label>}
      <div className="flex">
        {prepend && prepend.onClick && (
          <Button
            variant="ghost"
            className={prependStyles({ button: true })}
            onClick={prepend.onClick}
            aria-ispressed={prepend.isPressed}
            aria-label={prepend.ariaLabel}
          >
            {prepend.content}
          </Button>
        )}
        {prepend && !prepend.onClick && (
          <div className={prependStyles({ button: false })}>{prepend.content}</div>
        )}
        <InputPrimitive placeholder={placeholder} className={inputStyles({ withPrepend: !!prepend, withAppend: !!append })} />
        {append && append.onClick && (
          <Button
            variant="ghost"
            className={appendStyles({ button: true })}
            onClick={append.onClick}
            aria-ispressed={append.isPressed}
            aria-label={append.ariaLabel}
          >
            {append.content}
          </Button>
        )}
        {append && !append.onClick && (
          <div className={appendStyles({ button: false })}>
            {append.content}
          </div>
        )}
      </div>
      {description && (
        <Text slot="description" className="text-xs text-black-600">
          {description}
        </Text>
      )}
      <FieldError className="text-xs text-red-500">{errorMessage}</FieldError>
    </TextFieldPrimitive>
  )
}

export { Input, inputStyles }
