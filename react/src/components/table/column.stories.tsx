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
