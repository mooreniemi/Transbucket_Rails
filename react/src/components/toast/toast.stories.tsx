import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, userEvent, within } from 'storybook/test';

import { ToastRegion, createToastQueue } from './toast';
import { Button } from '../button';

// In a real app this queue is created once near the app root, not per-story
// -- storybook's own remounting is why it's created here instead.
const queue = createToastQueue();

const meta = {
  title: 'Components/Overlays/Toast',
  component: ToastRegion,
  args: {
    queue,
  },
  render: () => (
    <div className="flex gap-2">
      <ToastRegion queue={queue} />
      <Button
        onPress={() =>
          queue.add({
            title: 'Pin published',
            description: 'Your pin is now visible to others.',
          })
        }
      >
        Show toast
      </Button>
      <Button
        theme="destructive"
        onPress={() =>
          queue.add({
            title: 'Upload failed',
            description: 'Check your connection and try again.',
            variant: 'destructive',
          })
        }
      >
        Show error toast
      </Button>
      <Button
        variant="secondary"
        onPress={() =>
          queue.add({
            title: 'Comment saved',
            variant: 'success',
          })
        }
      >
        Show success toast
      </Button>
    </div>
  )
} satisfies Meta<typeof ToastRegion>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement.ownerDocument.body);
    await userEvent.click(canvas.getByRole('button', { name: 'Show toast' }));
    expect(await canvas.findByText('Pin published')).toBeInTheDocument();
  },
};
