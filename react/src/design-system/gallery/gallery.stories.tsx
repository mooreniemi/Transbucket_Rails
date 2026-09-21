import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, within } from 'storybook/test';

import { Gallery, GalleryItem } from './gallery';

// Deliberately mixed portrait/landscape/square dimensions -- pin photos
// come from users at whatever aspect ratio and orientation they uploaded,
// so the story exercises that instead of a uniform grid of squares.
const pins = [
  { id: 1, procedure: 'Vaginoplasty, 6 months post-op', doctor: 'Dr. Chen', updatedAt: '2026-08-02', image: 'https://picsum.photos/seed/pin1/480/640' },
  { id: 2, procedure: 'Phalloplasty, 1 year post-op', doctor: 'Dr. Patel', updatedAt: '2026-07-18', image: 'https://picsum.photos/seed/pin2/480/320' },
  { id: 3, procedure: 'Mastectomy, 3 months post-op', doctor: 'Dr. Smith', updatedAt: '2026-06-30', image: 'https://picsum.photos/seed/pin3/480/480' },
  { id: 4, procedure: 'Facial feminization, 2 years post-op', doctor: 'Dr. Banana', updatedAt: '2026-05-11', image: 'https://picsum.photos/seed/pin4/480/720' },
  { id: 5, procedure: 'Vaginoplasty, 2 weeks post-op', doctor: 'Dr. Doe', updatedAt: '2026-04-22', image: 'https://picsum.photos/seed/pin5/480/360' },
  { id: 6, procedure: 'Mastectomy, 1 year post-op', doctor: 'Dr. Evil', updatedAt: '2026-03-09', image: 'https://picsum.photos/seed/pin6/480/560' },
];

const meta = {
  title: 'Components/Data/Gallery',
  component: Gallery,
  subcomponents: {
    GalleryItem
  },
  render: (args) => (
    <Gallery {...args}>
      {pins.map((pin) => (
        <GalleryItem
          key={pin.id}
          href={`#pin-${pin.id}`}
          src={pin.image}
          doctor={pin.doctor}
          procedure={pin.procedure}
          updatedAt={pin.updatedAt}
        />
      ))}
    </Gallery>
  ),
} satisfies Meta<typeof Gallery>;

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
