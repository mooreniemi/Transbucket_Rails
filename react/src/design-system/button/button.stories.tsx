import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, fn } from 'storybook/test';

import { Button } from './button';

const onClickSpy = fn();

const meta = {
  title: 'Components/Forms/Button',
  component: Button,
  args: {
    children: 'Label',
    isDisabled: false,
    isPending: false,
    onClick: onClickSpy,
  },
  argTypes: {
    size: {
      options: ['xs', 'sm', 'md', 'lg', 'icon-xs', 'icon-sm', 'icon-lg', 'icon'],
      control: { type: 'select' },
    },
    variant: {
      options: ['primary', 'outline', 'secondary', 'ghost', 'link'],
      control: { type: 'select' },
    },
    theme: {
      options: ['default', 'destructive'],
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

/**
 * Use for primary action or form submission.
 */
export const Primary: Story = {
  play: async ({ canvas, userEvent }) => {
    await userEvent.click(canvas.getByRole('button'));
    expect(onClickSpy).toHaveBeenCalledTimes(1);
  }
};

/**
 * Alternate variant for actions that are less important than the primary action. Should not be used for form submission.
 */
export const SecondaryVariant: Story = {
  args: { variant: 'secondary' },
};

/**
 * Alternate variant for actions that are less important than the primary action and require more subtle visual treatments than secondary actions. Should not be used for form submission.
 */
export const OutlineVariant: Story = {
  args: { variant: 'outline' },
};

/**
 * Alternate variant for actions that are less important than the primary action. This is the most subtle visual treatment. Should not be used for form submission.
 */
export const GhostVariant: Story = {
  args: { variant: 'ghost' },
};

/**
 * Alternate variant that styles a button to appear visually as a link. This is typically used to perform actions within a menu.
 */
export const LinkVariant: Story = {
  args: { variant: 'link' },
};

/**
 * Use the destructive theme to indicate that a destructive action is being taken (delete, remove, clear, etc). This theme can be used with any style variant.
 */
export const DestructiveTheme: Story = {
  args: { theme: 'destructive' },
};

/**
 * The pending property disables the button and adds an indicator to the element that an action is in progress and not yet complete. It can be used with any variant or theme.
 */
export const Pending: Story = {
  args: { isPending: true },
  play: async ({ canvas }) => {
    expect(canvas.getByRole('button')).toHaveAttribute('aria-disabled', 'true');
  }
};

/**
 * Pass a `href` and any other link properties to the `Button` component to visually style a link as a button
 */
export const LinkButton: Story = {
  args: {
    href: '#',
  }
}
