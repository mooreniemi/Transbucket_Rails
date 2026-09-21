import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Checkbox } from './checkbox';

const meta = {
  title: 'Components/Forms/Checkbox',
  component: Checkbox,
  args: {
    children: 'I agree to the terms and conditions',
    isDisabled: false,
    isRequired: false,
    isInvalid: false,
    isIndeterminate: false,
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
    isIndeterminate: {
      control: { type: 'boolean' },
    },
  },
} satisfies Meta<typeof Checkbox>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getByRole('checkbox')).not.toBeChecked();
  }
};

export const Selected: Story = {
  args: {
    defaultSelected: true,
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('checkbox')).toBeChecked();
  }
};

export const Indeterminate: Story = {
  args: {
    isIndeterminate: true,
  },
};

export const WithDescription: Story = {
  args: {
    description: 'You must accept before continuing.',
  },
};

export const Invalid: Story = {
  args: {
    isInvalid: true,
    errorMessage: 'You must agree to continue.',
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('checkbox')).toBeInvalid();
  }
};

export const Disabled: Story = {
  args: {
    isDisabled: true,
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('checkbox')).toBeDisabled();
  }
};
