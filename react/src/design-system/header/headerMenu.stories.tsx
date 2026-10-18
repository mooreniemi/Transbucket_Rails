import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, userEvent, within } from 'storybook/test';

import { Header } from './header';
import { HeaderMenu, HeaderMenuItem } from './headerMenu';

const meta = {
  title: 'Components/Navigation/Header/Header Menu',
  component: HeaderMenu,
  subcomponents: {
    HeaderMenuItem,
  },
  args: {
    label: 'Procedure'
  },
  render: (args) => (
    <div>
        <Header skipNavId={false}>
            <HeaderMenu {...args}>
                <HeaderMenuItem href="#">Phalloplasty</HeaderMenuItem>
                <HeaderMenuItem href="#">Vaginoplasty</HeaderMenuItem>
                <HeaderMenuItem href="#">Mastectomy</HeaderMenuItem>
                <HeaderMenuItem href="#">Facial feminization</HeaderMenuItem>
            </HeaderMenu>
        </Header>
    </div>
  ),
} satisfies Meta<typeof HeaderMenu>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
    play: async ({ canvasElement }) => {
        const canvas = within(canvasElement.ownerDocument.body);
        await userEvent.click(canvas.getByRole('button', { name: 'Procedures' }));
        expect(await canvas.findByRole('menuitem', { name: 'Phalloplasty' })).toBeInTheDocument();
    },
};
