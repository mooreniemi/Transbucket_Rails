import { useState } from 'react';
import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { DropZone, FileTrigger, Text } from './dropZone';
import { Button } from '../button';

const meta = {
  title: 'Components/Forms/Drop zone',
  component: DropZone,
} satisfies Meta<typeof DropZone>;

export default meta;
type Story = StoryObj<typeof meta>;

function DropZoneWithPreview() {
  const [content, setContent] = useState<string | React.ReactElement | null>(null);

  async function handleFiles(files: FileList | null) {
    const file = files && [...files].find((f) => f.type.startsWith('image/'));
    if (file) {
      const url = URL.createObjectURL(file);
      setContent(<img src={url} alt={file.name} className="max-h-24 max-w-full" />);
    }
  }

  return (
    <DropZone
      getDropOperation={(types) =>
        ['text/plain', 'image/jpeg', 'image/png', 'image/gif'].some((t) => types.has(t))
          ? 'copy'
          : 'cancel'
      }
      onDrop={async (event) => {
        const item = event.items.find(
          (item) =>
            (item.kind === 'text' && item.types.has('text/plain')) ||
            (item.kind === 'file' && item.type.startsWith('image/'))
        );

        if (item?.kind === 'text') {
          const text = await item.getText('text/plain');
          setContent(text);
        } else if (item?.kind === 'file') {
          const file = await item.getFile();
          const url = URL.createObjectURL(file);
          setContent(<img src={url} alt={item.name} className="max-h-24 max-w-full" />);
        }
      }}
    >
      <Text slot="label">{content || 'Drag a file here, or browse to select one'}</Text>
      <FileTrigger acceptedFileTypes={['image/*']} onSelect={handleFiles}>
        <Button variant="outline" size="sm">Browse</Button>
      </FileTrigger>
    </DropZone>
  );
}

export const Default: Story = {
  render: () => <DropZoneWithPreview />,
  play: async ({ canvas }) => {
    expect(canvas.getByRole('button', { name: 'Browse' })).toBeInTheDocument();
  },
};
