import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Select, SelectItem } from './select';

const meta = {
  title: 'Components/Forms/Select',
  component: Select,
  args: {
    label: 'Procedure',
    placeholder: 'Select a procedure',
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
  render: (args) => (
    <Select {...args}>
      <SelectItem id="phalloplasty">Phalloplasty</SelectItem>
      <SelectItem id="vaginoplasty">Vaginoplasty</SelectItem>
      <SelectItem id="mastectomy">Mastectomy</SelectItem>
      <SelectItem id="facial-feminization">Facial feminization</SelectItem>
    </Select>
  ),
} satisfies Meta<typeof Select>;

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
};

export const Disabled: Story = {
  args: {
    isDisabled: true,
  },
};
