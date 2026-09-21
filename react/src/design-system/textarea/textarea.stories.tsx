import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Textarea } from './textarea';

const meta = {
  title: 'Components/Forms/Textarea',
  component: Textarea,
  args: {
    label: 'Comment',
    placeholder: 'Enter a comment',
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
    rows: {
      control: { type: 'number' },
    },
  },
} satisfies Meta<typeof Textarea>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getByRole('textbox')).toHaveValue('');
  }
};

export const WithDescription: Story = {
  args: {
    description: 'Maximum 500 characters.',
  },
};

export const Invalid: Story = {
  args: {
    isInvalid: true,
    errorMessage: 'Comment is required.',
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
