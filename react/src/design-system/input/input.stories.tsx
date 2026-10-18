import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';
import { Search, Eye, EyeOff } from 'lucide-react';
import { useState } from 'react';

import { Input, type StartEndElement } from './input';

const meta = {
  title: 'Components/Forms/Input',
  component: Input,
  args: {
    label: 'Name',
    placeholder: 'John Smith',
    isDisabled: false,
    isRequired: false,
    isInvalid: false,
    type: 'text',
    autoComplete: 'name',
    validationBehavior: 'native'
  },
  argTypes: {
   errorMessage: {
      control: { type: 'text' }
    },
    validationBehavior: {
      options: ['native', 'aria'],
      control: { type: 'select' }
    },
    prepend: {
      control: false
    },
    append: {
      control: false
    },
    type: {
      table: {
        disable: true
      }
    },
  },
} satisfies Meta<typeof Input>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getByRole('textbox')).toHaveValue('');
  }
};

export const WithDescription: Story = {
  args: {
    description: 'Your name will be visible only to administrators and used in communications.',
  },
};

export const Invalid: Story = {
  args: {
    isInvalid: true,
    errorMessage: 'Must be at least 2 characters long.',
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('textbox')).toBeInvalid();
  }
};

export const Disabled: Story = {
  args: {
    isDisabled: true,
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('textbox')).toBeDisabled();
  }
};

/**
 * Prepend an element with the following shape to the input:
 * `{ content: ReactNode; isPressed?: Boolean; onClick()?: void; ariaLabel?: string; }`
 * 
 * If passing an `onClick` handler the prepended element will be wrapped in a button. Provide the `ariaLabel` property if an `onClick` handler is being used and only an icon is provided to the `content` property. If the action has a toggle state use the `isPressed` property to indicate whether it is active or not.
 */
export const WithPrependedElement: Story = {
  args: {
    'aria-label': 'Search',
    label: undefined,
    autoComplete: 'off',
    prepend: {
      content: <Search size={16} />
    }
  }
};

/**
 * Append an element with the following shape to the input:
 * `{ content: ReactNode; isPressed?: Boolean; onClick()?: void; ariaLabel?: string; }`
 * 
 * If passing an `onClick` handler the appended element will be wrapped in a button. Provide the `ariaLabel` property if an `onClick` handler is being used and only an icon is provided to the `content` property. If the action has a toggle state use the `isPressed` property to indicate whether it is active or not.
 */
export const WithAppendedElement: Story = {
  args: {
    label: 'Password',
    type: 'password',
    autoComplete: 'off',
    append:  {
      content: <Eye size={16} />,
      isPressed: false,
      onClick: () => {},
      ariaLabel: 'show password',
    },
    placeholder: undefined,
  },
  render: ({ type, append, ...args }) => {
    const [appendState, setAppendState] = useState<StartEndElement>({
      content: append?.content,
      ...append,
      onClick: () => {
        setAppendState((prev) => ({
          ...prev,
          isPressed: !prev.isPressed,
          content: prev.isPressed ? <Eye size={16} /> : <EyeOff size={16} />,
          ariaLabel: prev.isPressed ? 'show password' : 'hide password',
        }));
      }
    });

    return (
      <Input type={appendState.isPressed ? 'text' : type } {...args} append={appendState} />
    )
  }
};

