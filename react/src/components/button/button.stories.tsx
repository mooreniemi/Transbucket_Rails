import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { fn } from 'storybook/test';

import { Button } from './button';

const meta = {
  title: 'Components/Button',
  component: Button,
  tags: ['autodocs'],
  parameters: {
    layout: 'fullscreen',
  },
  args: {
    children: 'Label',
    isDisabled: false,
    isPending: false,
    onClick: fn(),
  },
  argTypes: {
    size: {
      options: ['xs', 'sm', 'md', 'lg', 'icon-xs', 'icon-sm', 'icon-lg', 'icon'],
      control: { type: 'select' },
    },
    variant: {
      options: ['primary', 'destructive', 'outline', 'secondary', 'ghost', 'link'],
      control: { type: 'select' },
    },
    isPending: {
      control: { type: 'boolean' },
    },
    isDisabled: {
      control: { type: 'boolean' },
    },
    onClick: {
      table: {
       disable: true 
      }
    }
  },
} satisfies Meta<typeof Button>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {};

export const Secondary: Story = {
  args: { variant: 'secondary' },
};

export const Outline: Story = {
  args: { variant: 'outline' },
};

export const Ghost: Story = {
  args: { variant: 'ghost' },
};

export const Destructive: Story = {
  args: { variant: 'destructive' },
};

export const Link: Story = {
  args: { variant: 'link' },
};

export const Pending: Story = {
  args: { isPending: true },
};

export const LinkButton: Story = {
  args: {
    href: '#',
  }
}
