import type { Meta, StoryObj } from '@storybook/tanstack-react';

import { Table } from './table';
import { TableHeader } from './tableHeader';
import { TableBody } from './tableBody';
import { Column } from './column';
import { Row } from './row';
import { Cell } from './cell';

const meta = {
  title: 'Components/Data/Table/Cell',
  component: Cell,
  args: {
    children: 'Cell content',
  },
  render: (args) => (
    <Table>
        <TableHeader>
            <Column isRowHeader>Test</Column>
        </TableHeader>
        <TableBody>
            <Row><Cell {...args} /></Row>
        </TableBody>
    </Table>
  )
} satisfies Meta<typeof Cell>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
};
