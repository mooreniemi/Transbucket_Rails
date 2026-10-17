import type { Meta, StoryObj } from '@storybook/tanstack-react';

import { Table } from './table';
import { TableHeader } from './tableHeader';
import { TableBody } from './tableBody';
import { Column } from './column';
import { Row } from './row';
import { Cell } from './cell';

const meta = {
  title: 'Components/Data/Table/Column',
  component: Column,
  args: {
    children: 'Column content',
  },
  argTypes: {
    id: { control: 'text'},
    className: {
      control: { type: 'text' }
    },
    focusMode: {
      options: ['cell', 'child'],
      control: { type: 'select' }
    },
    width: {
      control: { type: 'number' }
    },
    defaultWidth: {
      control: { type: 'number' }
    },
    minWidth: {
      control: { type: 'number' }
    },
    maxWidth: {
      control: { type: 'number' }
    }
  },
  render: (args) => (
    <Table>
        <TableHeader>
            <Column {...args}>{args.children}</Column>
        </TableHeader>
        <TableBody>
            <Row><Cell>Test data</Cell></Row>
        </TableBody>
    </Table>
  )
} satisfies Meta<typeof Column>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
};
