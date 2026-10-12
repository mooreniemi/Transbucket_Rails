import type { Meta, StoryObj } from '@storybook/tanstack-react';

import { Alert } from './alert';

const meta = {
  title: 'Components/Feedback/Alert',
  component: Alert,
  args: {
    children: 'Care providers must use their real name or the account will be removed.',
  },
  argTypes: {
    variant: {
      options: ['info', 'warning', 'error'],
      control: { type: 'select' },
    },
  },
} satisfies Meta<typeof Alert>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Info: Story = {
  args: { variant: 'info' },
};

export const Warning: Story = {
  args: { variant: 'warning' },
};

export const Error: Story = {
  args: { variant: 'error' },
};

export const WithTitle: Story = {
  args: { variant: 'warning', title: 'Use your real name' },
};

export const WithoutIcon: Story = {
  args: { icon: false },
};
