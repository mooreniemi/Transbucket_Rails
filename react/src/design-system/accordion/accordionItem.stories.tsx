import type { Meta, StoryObj } from '@storybook/tanstack-react';

import { AccordionItem } from './accordion';

const meta = {
  title: 'Components/Features/Accordion/AccordionItem',
  component: AccordionItem,
  args: {
    title: 'How is my gender used?',
    children: (
        <p>Your gender sets some defaults for the content you see, and for your pronouns if you leave them on Default.</p>
    ),
    headingLevel: 3,
  },
  argTypes: {
    headingLevel: {
        control: { type: 'number', min: 2, max: 6 }
    },
    id: {
        control: false,
    },
  }
} satisfies Meta<typeof AccordionItem>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {};
