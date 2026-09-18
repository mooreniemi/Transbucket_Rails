import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, userEvent, within } from 'storybook/test';

import { Modal, Dialog, DialogTrigger } from './modal';
import { Button } from '../button';

const meta = {
  title: 'Components/Overlays/Modal',
  component: Modal,
  subcomponents: { Dialog, DialogTrigger },
} satisfies Meta<typeof Modal>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  render: (args) => (
    <DialogTrigger>
      <Button>Delete pin…</Button>
      <Modal {...args}>
        <Dialog title="Delete this pin?">
          <p className="text-sm text-black-600">
            This will permanently remove the pin and its comments. This action can't be undone.
          </p>
          <div className="flex justify-end gap-2">
            <Button slot="close" variant="outline">Cancel</Button>
            <Button slot="close" variant="destructive">Delete</Button>
          </div>
        </Dialog>
      </Modal>
    </DialogTrigger>
  ),
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement.ownerDocument.body);
    await userEvent.click(canvas.getByRole('button', { name: 'Delete pin…' }));
    expect(await canvas.findByRole('dialog')).toBeInTheDocument();
    expect(canvas.getByText('Delete this pin?')).toBeInTheDocument();
  },
};

export const Dismissable: Story = {
  args: {
    isDismissable: true,
  },
  render: (args) => (
    <DialogTrigger>
      <Button>Open settings…</Button>
      <Modal {...args}>
        <Dialog title="Notification settings">
          <p className="text-sm text-black-600">
            Click outside this dialog, or press the X, to close it.
          </p>
        </Dialog>
      </Modal>
    </DialogTrigger>
  ),
};
