import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Switch } from './switch';

const meta = {
  title: 'Components/Forms/Switch',
  component: Switch,
  args: {
    children: 'Enable notifications',
    isDisabled: false,
    isRequired: false,
    isInvalid: false,
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
  },
} satisfies Meta<typeof Switch>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getByRole('switch')).not.toBeChecked();
  }
};

export const Selected: Story = {
  args: {
    defaultSelected: true,
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('switch')).toBeChecked();
  }
};

export const WithDescription: Story = {
  args: {
    description: "We'll only send you important updates.",
  },
};

export const Invalid: Story = {
  args: {
    isInvalid: true,
    errorMessage: 'Must select at least one option.',
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('switch')).toBeInvalid();
  }
};

export const Disabled: Story = {
  args: {
    isDisabled: true,
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('switch')).toBeDisabled();
  }
};
