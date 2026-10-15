import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';
import { Search, Eye, EyeOff } from 'lucide-react';
import { useState } from 'react';

import { Input, type StartEndElement } from './input';

const meta = {
  title: 'Components/Forms/Input',
  component: Input,
  args: {
    label: 'Email',
    placeholder: 'you@example.com',
    isDisabled: false,
    isRequired: false,
    isInvalid: false,
    type: 'email',
  },
  argTypes: {
    isDisabled: {
      control: { type: 'boolean' },
    },
    isRequired: {
      control: { type: 'boolean' },
    },
    isInvalid: {
      control: { type: 'boolean' },
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
    description: "We'll never share your email.",
  },
};

export const Invalid: Story = {
  args: {
    isInvalid: true,
    errorMessage: 'Please enter a valid email address.',
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

export const WithPrependedElement: Story = {
  args: {
    'aria-label': 'Search',
    label: undefined,
    prepend: {
      content: <Search size={16} />
    }
  }
};

export const WithAppendedElement: Story = {
  args: {
    label: 'Password',
    type: 'password',
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

