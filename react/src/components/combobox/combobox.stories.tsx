import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { ComboBox, ComboBoxItem } from './combobox';

const meta = {
  title: 'Components/Forms/ComboBox',
  component: ComboBox,
  args: {
    label: 'Procedure',
    placeholder: 'Search for a procedure',
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
    <ComboBox {...args}>
      <ComboBoxItem id="phalloplasty">Phalloplasty</ComboBoxItem>
      <ComboBoxItem id="vaginoplasty">Vaginoplasty</ComboBoxItem>
      <ComboBoxItem id="mastectomy">Mastectomy</ComboBoxItem>
      <ComboBoxItem id="facial-feminization">Facial feminization</ComboBoxItem>
    </ComboBox>
  ),
} satisfies Meta<typeof ComboBox>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getByRole('combobox')).toHaveValue('');
  }
};

export const WithDefaultValue: Story = {
  args: {
    defaultSelectedKey: 'vaginoplasty',
  },
  play: async ({ canvas }) => {
   expect(canvas.getByRole('combobox')).toHaveValue('Vaginoplasty');
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
