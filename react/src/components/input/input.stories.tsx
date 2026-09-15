import type { Meta, StoryObj } from '@storybook/tanstack-react';

import { Input } from './input';

const meta = {
  title: 'Components/Input',
  component: Input,
  tags: ['autodocs'],
  parameters: {
    layout: 'fullscreen',
  },
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

export const Default: Story = {};

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
};

export const Disabled: Story = {
  args: {
    isDisabled: true,
  },
};
