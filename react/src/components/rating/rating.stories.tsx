import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Rating } from './rating';

const meta = {
  title: 'Components/Forms/Rating',
  component: Rating,
  args: {
    label: 'Satisfaction',
    isDisabled: false,
    isRequired: false,
    isInvalid: false,
    scale: new Map([
      [1, 'very poor'],
      [2, 'poor'],
      [3, 'ok'],
      [4, 'good'],
      [5, 'very good']
    ])
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
    }
  },
} satisfies Meta<typeof Rating>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {

}

export const Invalid: Story = {
    args: {
        isInvalid: true,
        errorMessage: "Please select a rating.",
    }
}