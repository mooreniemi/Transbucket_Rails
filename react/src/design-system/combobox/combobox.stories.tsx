import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { ComboBox, ComboBoxItem, type ComboBoxOption } from './combobox';

const meta = {
  title: 'Components/Forms/ComboBox',
  component: ComboBox,
  subcomponents: {
    ComboBoxItem
  },
  args: {
    label: 'Procedure',
    placeholder: 'Search for a procedure',
    isDisabled: false,
    isRequired: false,
    isInvalid: false,
    defaultItems: [
      { id: 'phalloplasty', name: 'Phalloplasty' },
      { id: 'vaginoplasty', name: 'Vaginoplasty' },
      { id: 'mastectomy', name: 'Mastectomy' },
      { id: 'facial-feminization', name: 'Facial Feminization' }
    ],
    formValue: 'key',
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
    defaultItems: {
      control: false
    },
    formValue: {
      options: ['key', 'textValue'],
      control: { type: 'select' },
    }
  },
  render: (args) => (
    <ComboBox {...args} />
  ),
} satisfies Meta<typeof ComboBox<ComboBoxOption>>;

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

export const WithRenderFunction: Story = {
  render: (args) => (
    <ComboBox {...args}>
      {(item) => (
        <ComboBoxItem id={item.id} textValue={item.name}>
          <strong>{item.name}</strong>
        </ComboBoxItem>
      )}
    </ComboBox>
  ),
};

export const WithStaticItems: Story = {
  render: ({ defaultItems: _defaultItems, ...args }) => (
    <ComboBox {...args}>
      <ComboBoxItem id="phalloplasty">Phalloplasty</ComboBoxItem>
      <ComboBoxItem id="vaginoplasty">Vaginoplasty</ComboBoxItem>
    </ComboBox>
  ),
};
