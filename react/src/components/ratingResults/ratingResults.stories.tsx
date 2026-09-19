import type { Meta, StoryObj } from '@storybook/tanstack-react';

import { RatingResults } from './ratingResults';

const meta = {
  title: 'Components/Data/Rating Results',
  component: RatingResults,
  args: {
    data: [
        {
            id: "1",
            rating: 2
        },
        {
            id: "2",
            rating: 2
        },
        {
            id: "3",
            rating: 1
        },
        {
            id: "5",
            rating: 5
        }
    ]
  }
} satisfies Meta<typeof RatingResults>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
};
