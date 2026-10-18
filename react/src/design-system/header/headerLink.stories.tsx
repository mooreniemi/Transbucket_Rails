import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Header } from './header';
import { HeaderLink } from './headerLink';

const meta = {
  title: 'Components/Navigation/Header/Header Link',
  component: HeaderLink,
  args: {
    href: '#',
    children: 'Surgeons',
  },
  render: (args) => (
    <Header skipNavId={false}>
      <HeaderLink {...args} />
    </Header>
  ),
} satisfies Meta<typeof HeaderLink>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
    // Header renders its children in both the desktop nav and the mobile menu.
    expect(canvas.getAllByRole('link', { name: 'Surgeons' })[0]).toBeInTheDocument();
  },
};

// aria-current isn't in react-aria's LinkProps, so it can't be a story arg;
// JSX passes it through as a DOM attribute.
export const CurrentPage: Story = {
  render: (args) => (
    <Header skipNavId={false}>
      <HeaderLink {...args} aria-current="page" />
    </Header>
  ),
  play: async ({ canvas }) => {
    expect(canvas.getAllByRole('link', { name: 'Surgeons' })[0]).toHaveAttribute('aria-current', 'page');
  },
};
