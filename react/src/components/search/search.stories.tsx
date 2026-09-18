import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Search } from './search';

const meta = {
  title: 'Components/Forms/Search',
  component: Search,
  args: {
    label: 'Search',
    placeholder: 'Search pins',
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
} satisfies Meta<typeof Search>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getByRole('searchbox')).toHaveValue('');
  }
};

export const WithDefaultValue: Story = {
  args: {
    defaultValue: 'vaginoplasty',
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('searchbox')).toHaveValue('vaginoplasty');
  }
};

export const WithDescription: Story = {
  args: {
    description: 'Search by patient, procedure, or surgeon.',
  },
};

export const Invalid: Story = {
  args: {
    isInvalid: true,
    errorMessage: 'Please enter a search term.',
  },
};

export const Disabled: Story = {
  args: {
    isDisabled: true,
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('searchbox')).toBeDisabled();
  }
};
