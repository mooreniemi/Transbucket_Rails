import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, userEvent, within } from 'storybook/test';

import { Modal, DialogTrigger } from './modal';
import { Button } from '../button';

const meta = {
  title: 'Components/Overlays/Modal',
  component: Modal,
  subcomponents: { DialogTrigger },
  args: {
    role: 'dialog'
  },
  argTypes: {
    role: {
      options: ['dialog', 'alertdialog'],
      control: { type: 'select' },
    },
    UNSTABLE_portalContainer: {
      control: false
    }
  }
} satisfies Meta<typeof Modal>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    title: 'Remove this submission?',
    children: (
      <>
        <p className="text-sm text-black-600">
          This will permanently remove the pin and its comments. This action can't be undone.
        </p>
        <div className="flex justify-end gap-2">
          <Button slot="close" variant="outline">Cancel</Button>
          <Button slot="close" theme="destructive">Delete</Button>
        </div>
      </>
    )
  },
  render: (args) => (
    <DialogTrigger>
      <Button theme="destructive">Delete submission</Button>
      <Modal {...args} />
    </DialogTrigger>
  ),
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement.ownerDocument.body);
    await userEvent.click(canvas.getByRole('button', { name: 'Delete submission' }));
    expect(await canvas.findByRole('dialog')).toBeInTheDocument();
    expect(canvas.getByText('Remove this submission?')).toBeInTheDocument();
  },
};

export const NotDismissable: Story = {
  args: {
    title: 'Accept the terms of agreement',
    isDismissable: false,
    children: (
      <>
        <p className="text-sm text-black-600">
          This modal will not close unless you accept the terms of agreement
        </p>
        <div className="flex justify-end">
          <Button slot="close">Accept</Button>
        </div>
      </>
    )
  },
  render: (args) => (
    <DialogTrigger>
      <Button>Open undismissable prompt</Button>
      <Modal {...args} />
    </DialogTrigger>
  ),
};
