import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, within } from 'storybook/test';

import { GalleryItem } from './gallery';

// Deliberately mixed portrait/landscape/square dimensions -- pin photos
// come from users at whatever aspect ratio and orientation they uploaded,
// so the story exercises that instead of a uniform grid of squares.
const pins = [
  { id: 1, procedure: 'Vaginoplasty, 6 months post-op', doctor: 'Dr. Chen', updatedAt: '2026-08-02T12:00:00.000Z', image: 'https://picsum.photos/seed/pin1/480/640' },
 ];

const meta = {
  title: 'Components/Data/Gallery/Gallery Item',
  component: GalleryItem,
  args: {
    src: pins[0].image,
    headline: pins[0].procedure,
    description: pins[0].doctor,
    updatedAt: pins[0].updatedAt
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
