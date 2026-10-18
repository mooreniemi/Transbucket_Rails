import { useState } from 'react';
import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect, userEvent, within } from 'storybook/test';

import { Pagination } from './pagination';

const meta = {
  title: 'Components/Navigation/Pagination',
  component: Pagination,
  args: {
    page: 1,
    totalPages: 10,
    // Real apps should pass real per-page URLs (see the component's own
    // getPageHref doc comment). These stories point at "#", and the render
    // below blocks the links' default navigation as well: under the Vitest
    // browser runner even a "#" link navigates the test page away and
    // drops the runner's connection.
    getPageHref: () => '#',
  },
  render: (args) => {
    function Controlled() {
      const [page, setPage] = useState(args.page);
      const handleClickCapture = (event: React.MouseEvent) => event.preventDefault();
      return (
        <div onClickCapture={handleClickCapture}>
          <Pagination
            {...args}
            page={page}
            getPageHref={() => '#'}
            onPageChange={setPage}
          />
        </div>
      );
    }
    return <Controlled />;
  },
} satisfies Meta<typeof Pagination>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const FirstPage: Story = {
  args: {
    page: 1,
    totalPages: 10,
  },
};

export const LastPage: Story = {
  args: {
    page: 10,
    totalPages: 10,
  },
};

export const MiddleOfManyPages: Story = {
  args: {
    page: 8,
    totalPages: 20,
  },
};

export const FewPages: Story = {
  args: {
    page: 2,
    totalPages: 3,
  },
};

export const SinglePage: Story = {
  args: {
    page: 1,
    totalPages: 1,
  },
};

export const Interaction: Story = {
  args: {
    page: 1,
    totalPages: 10,
  },
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);
    expect(canvas.getByText('Page 1 of 10')).toBeInTheDocument();
    expect(canvas.getByLabelText('Previous page')).toHaveAttribute('aria-disabled', 'true');

    await userEvent.click(canvas.getByLabelText('Page 2'));
    expect(await canvas.findByText('Page 2 of 10')).toBeInTheDocument();

    await userEvent.click(canvas.getByLabelText('Next page'));
    expect(await canvas.findByText('Page 3 of 10')).toBeInTheDocument();
  },
};
