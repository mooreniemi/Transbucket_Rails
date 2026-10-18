import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, userEvent, within } from 'storybook/test';

import { Header } from './header';
import { HeaderMenu, HeaderMenuItem } from './headerMenu';

const meta = {
  title: 'Components/Navigation/Header/Header Menu Item',
  component: HeaderMenuItem,
  args: {
    href: "#",
    children: 'Vaginoplasty',
  },
  argTypes: {
    'aria-current': {
        control: false,
    }
  },
  render: (args) => (
    <div>
        <Header skipNavId={false}>
            <HeaderMenu label="Procedures">
                <HeaderMenuItem {...args} />
            </HeaderMenu>
        </Header>
    </div>
  ),
} satisfies Meta<typeof HeaderMenuItem>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
    play: async ({ canvasElement }) => {
        const canvas = within(canvasElement.ownerDocument.body);
        await userEvent.click(canvas.getByRole('button', { name: 'Procedures' }));
        expect(await canvas.findByRole('menuitem', { name: 'Vaginoplasty' })).toBeInTheDocument();
    },
};
