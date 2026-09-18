import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, userEvent, within } from 'storybook/test';

import { Header } from './header';
import { HeaderLink } from './headerLink';
import { HeaderMenu, HeaderMenuItem } from './headerMenu';

const meta = {
  title: 'Components/Navigation/Header',
  component: Header,
  render: () => (
    <Header
      sectionRight={<HeaderLink href="#">Sign in</HeaderLink>}
    >
      <HeaderLink href="#" aria-current="page">Explore</HeaderLink>
      <HeaderMenu label="Procedures">
        <HeaderMenuItem href="#">Phalloplasty</HeaderMenuItem>
        <HeaderMenuItem href="#">Vaginoplasty</HeaderMenuItem>
        <HeaderMenuItem href="#">Mastectomy</HeaderMenuItem>
        <HeaderMenuItem href="#">Facial feminization</HeaderMenuItem>
      </HeaderMenu>
      <HeaderLink href="#">Surgeons</HeaderLink>
    </Header>
  ),
} satisfies Meta<typeof Header>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const MobileMenuOpen: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);
    await userEvent.click(canvas.getByLabelText('Open menu'));
    expect(await canvas.findByLabelText('Close menu')).toBeInTheDocument();
  },
};

export const DesktopDropdown: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement.ownerDocument.body);
    await userEvent.click(canvas.getByRole('button', { name: 'Procedures' }));
    expect(await canvas.findByRole('menuitem', { name: 'Phalloplasty' })).toBeInTheDocument();
  },
};
