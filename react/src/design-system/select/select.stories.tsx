import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Select, SelectItem, type SelectOption } from './select';

const meta = {
  title: 'Components/Forms/Select',
  component: Select,
  args: {
    label: 'Procedure',
    placeholder: 'Select a procedure',
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
    items: {
      control: false
    }
  },
  render: (args) => (
    <Select {...args}>
      <SelectItem id="phalloplasty">Phalloplasty</SelectItem>
      <SelectItem id="vaginoplasty">Vaginoplasty</SelectItem>
      <SelectItem id="mastectomy">Mastectomy</SelectItem>
      <SelectItem id="facial-feminization">Facial feminization</SelectItem>
    </Select>
  ),
} satisfies Meta<typeof Select<SelectOption>>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getByRole('button')).toHaveTextContent('Select a procedure');
  }
};

export const WithDefaultValue: Story = {
  args: {
    defaultSelectedKey: 'vaginoplasty',
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('button')).toHaveTextContent('Vaginoplasty');
  }
};

export const WithDescription: Story = {
  args: {
    description: 'Choose the procedure this pin is about.',
  },
};

export const Invalid: Story = {
  args: {
    isInvalid: true,
    errorMessage: 'Please select a procedure.',
  },
  play: async ({ canvas }) => {
    expect(canvas.getByRole('button')).toHaveClass('border-red-500');
  }
};

// Error text alone shouldn't paint the label red; validity comes from isInvalid / validation.
export const ErrorMessageWithoutInvalid: Story = {
  args: {
    errorMessage: 'Please select a procedure.',
  },
  play: async ({ canvas }) => {
    expect(canvas.getByText('Procedure')).not.toHaveClass('text-red-500');
  }
};

export const Disabled: Story = {
  args: {
    isDisabled: true,
  },
  play: async ({ canvas }) => {
    expect(canvas.getByRole('button')).toHaveClass('cursor-not-allowed');
  }
};

export const WithItems: Story = {
  args: {
    items: [
      { id: 'phalloplasty', name: 'Phalloplasty' },
      { id: 'vaginoplasty', name: 'Vaginoplasty' },
    ],
    defaultSelectedKey: 'vaginoplasty',
  },
  render: (args) => <Select {...args} />,
  play: async ({ canvas }) => {
    expect(canvas.getByRole('button')).toHaveTextContent('Vaginoplasty');
  }
};
