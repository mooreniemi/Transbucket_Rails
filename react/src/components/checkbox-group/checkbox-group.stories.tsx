import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { CheckboxGroup } from './checkbox-group';
import { Checkbox } from '../checkbox/checkbox';

const meta = {
  title: 'Components/Forms/CheckboxGroup',
  component: CheckboxGroup,
  args: {
    label: 'Notifications',
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
    <CheckboxGroup {...args}>
      <Checkbox value="product" description="Get notified about new features and improvements">
        Product updates
      </Checkbox>
      <Checkbox value="security" description="Important notifications about your account safety">
        Security alerts
      </Checkbox>
      <Checkbox value="marketing" description="Receive promotions, offers, and newsletters">
        Marketing emails
      </Checkbox>
    </CheckboxGroup>
  ),
} satisfies Meta<typeof CheckboxGroup>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
   expect(canvas.getAllByRole('checkbox')).toHaveLength(3);
  }
};

export const WithDefaultValue: Story = {
  args: {
    defaultValue: ['product', 'security'],
  },
};

export const WithDescription: Story = {
  args: {
    description: 'Choose which emails you want to receive.',
  },
};

export const Invalid: Story = {
  args: {
    isInvalid: true,
    errorMessage: 'Please select at least one option.',
  },
};

export const Disabled: Story = {
  args: {
    isDisabled: true,
  },
};
