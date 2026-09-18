import { useState } from 'react';
import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';
import type { SortDescriptor } from 'react-aria-components';

import { Table } from './table';
import { TableHeader } from './tableHeader';
import { TableBody } from './tableBody';
import { Column } from './column';
import { Row } from './row';
import { Cell } from './cell';

const pins = [
  { id: 1, patient: 'A. Rivera', procedure: 'Vaginoplasty', surgeon: 'Dr. Chen', status: 'Published' },
  { id: 2, patient: 'J. Okafor', procedure: 'Phalloplasty', surgeon: 'Dr. Patel', status: 'Pending' },
  { id: 3, patient: 'S. Novak', procedure: 'Mastectomy', surgeon: 'Dr. Chen', status: 'Published' },
  { id: 4, patient: 'M. Delgado', procedure: 'Facial feminization', surgeon: 'Dr. Ibrahim', status: 'Flagged' },
];

const meta = {
  title: 'Components/Table',
  component: Table,
  subcomponents: { TableHeader, TableBody, Column, Row, Cell },
  args: {
    'aria-label': 'Patients',
  },
  render: (args) => (
    <Table {...args}>
      <TableHeader>
        <Column isRowHeader allowsSorting>Patient</Column>
        <Column allowsSorting>Procedure</Column>
        <Column allowsSorting>Surgeon</Column>
        <Column>Status</Column>
      </TableHeader>
      <TableBody>
        {pins.map((pin) => (
          <Row key={pin.id} id={pin.id}>
            <Cell>{pin.patient}</Cell>
            <Cell>{pin.procedure}</Cell>
            <Cell>{pin.surgeon}</Cell>
            <Cell>{pin.status}</Cell>
          </Row>
        ))}
      </TableBody>
    </Table>
  ),
} satisfies Meta<typeof Table>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  play: async ({ canvas }) => {
    expect(canvas.getAllByRole('row')).toHaveLength(5);
  },
};

export const SingleSelection: Story = {
  args: {
    selectionMode: 'single',
  },
  play: async ({ canvas }) => {
    expect(canvas.getAllByRole('row')).toHaveLength(5);
  },
};

export const MultipleSelection: Story = {
  args: {
    selectionMode: 'multiple',
  },
  play: async ({ canvas }) => {
    expect(canvas.getAllByRole('checkbox')).toHaveLength(5);
  },
};

export const Empty: Story = {
  render: (args) => (
    <Table {...args}>
      <TableHeader>
        <Column isRowHeader>Patient</Column>
        <Column>Procedure</Column>
        <Column>Surgeon</Column>
        <Column>Status</Column>
      </TableHeader>
      <TableBody renderEmptyState={() => 'No patients found.'}>
        {[]}
      </TableBody>
    </Table>
  ),
  play: async ({ canvas }) => {
    expect(canvas.getByText('No patients found.')).toBeInTheDocument();
  },
};

function SortableTable() {
  const [sortDescriptor, setSortDescriptor] = useState<SortDescriptor>({
    column: 'patient',
    direction: 'ascending',
  });

  const sorted = [...pins].sort((a, b) => {
    const key = sortDescriptor.column as keyof (typeof pins)[number];
    const cmp = String(a[key]).localeCompare(String(b[key]));
    return sortDescriptor.direction === 'descending' ? -cmp : cmp;
  });

  return (
    <Table aria-label="Pins" sortDescriptor={sortDescriptor} onSortChange={setSortDescriptor}>
      <TableHeader>
        <Column id="patient" isRowHeader allowsSorting>Patient</Column>
        <Column id="procedure" allowsSorting>Procedure</Column>
        <Column id="surgeon" allowsSorting>Surgeon</Column>
        <Column>Status</Column>
      </TableHeader>
      <TableBody>
        {sorted.map((pin) => (
          <Row key={pin.id} id={pin.id}>
            <Cell>{pin.patient}</Cell>
            <Cell>{pin.procedure}</Cell>
            <Cell>{pin.surgeon}</Cell>
            <Cell>{pin.status}</Cell>
          </Row>
        ))}
      </TableBody>
    </Table>
  );
}

export const Sortable: Story = {
  render: () => <SortableTable />,
  play: async ({ canvas }) => {
    const rowHeaders = canvas.getAllByRole('rowheader');
    expect(rowHeaders[0]).toHaveTextContent('A. Rivera');
  },
};
