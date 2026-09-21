import {mergeProps} from 'react-aria/mergeProps';
import {
  useRadio,
  useRadioGroup,
  type AriaRadioGroupProps,
  type AriaRadioProps,
} from 'react-aria/useRadioGroup';
import {useFocusRing} from 'react-aria/useFocusRing';
import {useHover} from 'react-aria/useHover';
import {useRadioGroupState, type RadioGroupState} from 'react-stately/useRadioGroupState';
import {VisuallyHidden} from 'react-aria/VisuallyHidden';
import { createContext, useContext, useRef, useMemo } from 'react';
import { tv } from 'tailwind-variants';
import { Button } from '../button';
import { Trash } from 'lucide-react';

export interface RatingProps extends Omit<AriaRadioGroupProps, 'orientation' | 'children'> {
    errorMessage?: string;
    scale: Map<number, string>;
}

const groupLabelStyles = tv({
  base: "text-sm font-medium text-black-900",
  variants: {
    isInvalid: {
      true: "text-red-500",
    },
  },
});

const starLabelStyles = tv({
  base: "block size-6 cursor-pointer",
  variants: {
    isDisabled: {
      true: "cursor-default pointer-events-none",
    },
    isFocusVisible: {
      true: "outline-[3px] outline-blue-600 -outline-offset-[1.5px] rounded-md",
    },
  },
});

const tagStyles = tv({
  base: "ms-2 p-1 text-xs rounded-md font-semibold bg-black-300",
  variants: {
    value: {
        1: "bg-rose-200",
        2: "bg-orange-300",
        3: "bg-blue-300",
        4: "bg-sky-300",
        5: "bg-green-300",
    }
  },
})

// The group state is shared with each radio through React context.
let RatingContext = createContext<RadioGroupState | null>(null);

export function Rating({ scale, ...props }: RatingProps) {
    const ratingProps: AriaRadioGroupProps = { orientation: 'horizontal', ...props };
    let state = useRadioGroupState(ratingProps);
    let {radioGroupProps, labelProps, isInvalid, errorMessageProps } = useRadioGroup(ratingProps, state);
    const clearValue = () => {
        state.setSelectedValue(null);
    };
    const currentValue = useMemo(() => {
        if (state.selectedValue) {
            return parseInt(state.selectedValue, 10) as 1 | 2 | 3 | 4 | 5;
        }
    }, [state.selectedValue]);
    
    return (
        <div
            {...radioGroupProps}
            className="flex flex-col gap-1"
            data-orientation={ratingProps.orientation}
            data-invalid={state.isInvalid || undefined}
            data-disabled={state.isDisabled || undefined}
            data-readonly={state.isReadOnly || undefined}
        >
            {ratingProps.label && (
                <div {...labelProps} className={groupLabelStyles({ isInvalid })}>
                    {ratingProps.label}
                    <Button
                        size="icon-xs"
                        variant="secondary"
                        theme="destructive"
                        onClick={clearValue}
                        className="ms-2"
                    >
                        <Trash /><span className="sr-only">Clear rating</span>
                    </Button>
                </div>
            )}
            <div className="flex">
                <RatingContext.Provider value={state}>
                    <Star value="1">{scale.get(1)}</Star>
                    <Star value="2">{scale.get(2)}</Star>
                    <Star value="3">{scale.get(3)}</Star>
                    <Star value="4">{scale.get(4)}</Star>
                    <Star value="5">{scale.get(5)}</Star>
                </RatingContext.Provider>
                <span className={tagStyles({ value: currentValue })} aria-hidden="true">{currentValue ? scale.get(currentValue) : 'not rated' }</span>
            </div>
            {isInvalid && props.errorMessage && (
                <span className="text-xs text-red-500" {...errorMessageProps}>
                    {props.errorMessage}
                </span>
           )}
        </div>
    );
}

export function Star(props: AriaRadioProps) {
  let state = useContext(RatingContext)!;
  let ref = useRef<HTMLInputElement>(null);
  let {labelProps, inputProps, isSelected, isPressed, isDisabled} = useRadio(props, state, ref);
  let {hoverProps, isHovered} = useHover({isDisabled: isDisabled || state.isReadOnly});
  let {isFocused, isFocusVisible, focusProps} = useFocusRing();

  return (
    <div
      className="group"
      data-selected={isSelected || undefined}
      data-disabled={isDisabled || undefined}>
      {/* The label wraps a visually hidden native radio input plus the styled indicator. */}
      <label
        {...mergeProps(labelProps, hoverProps)}
        className={starLabelStyles({ isDisabled, isFocusVisible })}
        data-selected={isSelected || undefined}
        data-pressed={isPressed || undefined}
        data-hovered={isHovered || undefined}
        data-focused={isFocused || undefined}
        data-focus-visible={isFocusVisible || undefined}
        data-disabled={isDisabled || undefined}
        data-readonly={state.isReadOnly || undefined}
        data-invalid={state.isInvalid || undefined}>
            <input
              className="size-6 cursor-pointer appearance-none bg-black-200 checked:bg-yellow-500 hover:bg-yellow-600 group-has-[~[data-selected]]:bg-yellow-500"
              style={{
                clipPath:
                  "path('M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z')",
              }}
              {...mergeProps(inputProps, focusProps)}
              ref={ref}
            />
            <VisuallyHidden elementType="span">{props.children}</VisuallyHidden>
      </label>
    </div>
  );
}
