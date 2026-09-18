import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Label } from './label';

const meta = {
  title: 'Components/Forms/Label',
  component: Label,
  args: {
    children: 'Email',
    isInvalid: false,
  },
  argTypes: {
    isInvalid: {
      control: { type: 'boolean' },
    },
  },
} satisfies Meta<typeof Label>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getByText('Email')).toBeInTheDocument();
  }
};

export const Invalid: Story = {
  args: {
    isInvalid: true,
  },
};
