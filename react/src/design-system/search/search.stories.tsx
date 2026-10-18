import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, fn, userEvent, waitFor } from 'storybook/test';

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
    validationBehavior: 'native',
    onChange: fn(),
  },
  argTypes: {
    errorMessage: {
      control: { type: 'text' }
    },
    validationBehavior: {
      options: ['native', 'aria'],
      control: { type: 'select' }
    }
  },
} satisfies Meta<typeof Search>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getByRole('searchbox')).toHaveValue('');
  }
};

export const WithValue: Story = {
  args: {
    value: 'vaginoplasty',
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

export const Debounced: Story = {
  args: {
    debounceMs: 200,
  },
  play: async ({ args, canvas }) => {
    const input = canvas.getByRole('searchbox');
    await userEvent.type(input, 'vagi');

    // The input updates immediately even though onChange hasn't fired yet.
    expect(input).toHaveValue('vagi');
    expect(args.onChange).not.toHaveBeenCalled();

    await waitFor(() => expect(args.onChange).toHaveBeenCalledTimes(1));
    expect(args.onChange).toHaveBeenCalledWith('vagi');
  }
};

export const ClearSkipsDebounce: Story = {
  args: {
    value: 'vaginoplasty',
    debounceMs: 5000,
  },
  play: async ({ args, canvas }) => {
    await userEvent.click(canvas.getByRole('button'));

    expect(args.onChange).toHaveBeenCalledWith('');
    expect(canvas.getByRole('searchbox')).toHaveValue('');
  }
};

export const Controlled: Story = {
  args: {
    value: 'mastectomy',
    debounceMs: 200,
  },
  play: async ({ args, canvas }) => {
    const input = canvas.getByRole('searchbox');
    expect(input).toHaveValue('mastectomy');

    // Typing still works even though the parent's value doesn't change.
    await userEvent.type(input, 'X');
    expect(input).toHaveValue('mastectomyX');
    await waitFor(() => expect(args.onChange).toHaveBeenCalledWith('mastectomyX'));
  }
};
