import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { expect } from 'storybook/test';

import { Accordion, AccordionItem } from './accordion';

const meta = {
  title: 'Components/Features/Accordion/Group',
  component: Accordion,
  subcomponents: {
    AccordionItem,
  },
  args: {
    children: (
      <>
        <AccordionItem id="gender" title="How is my gender used?">
          Your gender sets some defaults for the content you see, and for your pronouns if you
          leave them on Default.
        </AccordionItem>
        <AccordionItem id="pronouns" title="Where do my pronouns appear?">
          Pronouns are shown on your submissions so people can address you correctly.
        </AccordionItem>
      </>
    ),
  },
} satisfies Meta<typeof Accordion>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  play: async ({ canvas, userEvent }) => {
    const trigger = canvas.getByRole('button', { name: /how is my gender used/i });
    await expect(trigger).toHaveAttribute('aria-expanded', 'false');
    await userEvent.click(trigger);
    await expect(trigger).toHaveAttribute('aria-expanded', 'true');
  },
};

export const SingleItem: Story = {
  args: {
    children: (
      <AccordionItem title="How is this used?">
        Short explanation that sits under a form field.
      </AccordionItem>
    ),
  },
};

export const OneAtATime: Story = {
  args: { allowsMultipleExpanded: false },
};

export const DefaultOpen: Story = {
  args: { defaultExpandedKeys: ['gender'] },
};

export const RichContent: Story = {
  args: {
    defaultExpandedKeys: ['rich'],
    children: (
      <AccordionItem id="rich" title="How are my gender and pronouns used?">
        <p>Gender is used to set default content, including pronouns unless otherwise indicated.</p>
        <p>Default pronouns:</p>
        <ul>
          <li>FTM: he/him</li>
          <li>MTF: she/her</li>
          <li>Everyone else: they/them</li>
        </ul>
      </AccordionItem>
    ),
  },
};
