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
    errorMessage: 'This setting is required.',
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
