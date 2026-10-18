import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, within } from 'storybook/test';

import { GalleryItem } from './gallery';

const meta = {
  title: 'Components/Data/Gallery/Gallery Item',
  component: GalleryItem,
  args: {
    src: 'https://picsum.photos/seed/pin1/480/640',
    headline: 'Vaginoplasty, 6 months post-op',
    description:'Dr. Chen',
    updatedAt: '2026-08-02T12:00:00.000Z',
    href: "#pin-1"
  },
  argTypes: {
    src: {
      control: { type: 'file' }
    },
    updatedAt: {
        control: { type: 'date' }
    }
  }
} satisfies Meta<typeof GalleryItem>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);
    const link = canvas.getByRole('link', { name: /Vaginoplasty, 6 months post-op/ });
    expect(link).toHaveAttribute('href', '#pin-1');
    expect(canvas.getByText('Updated Aug 2, 2026')).toBeInTheDocument();
  },
};
