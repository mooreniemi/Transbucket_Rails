import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { formatDateTime } from '#/lib/dateTime';

import { Card } from './card';

const meta = {
  title: 'Components/Features/Card',
  component: Card,
  args: {
    children: (
      <>
        <h2 className="font-bold">News Item</h2>
        <div className="text-xs text-black-700">{formatDateTime(new Date())}</div>
        <p className="mt-2">Some information that is in the news</p>
      </>
    ),
  },
} satisfies Meta<typeof Card>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
};