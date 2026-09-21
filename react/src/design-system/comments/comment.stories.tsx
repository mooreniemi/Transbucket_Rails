import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { fn } from 'storybook/test';

import { Comment } from './comment';
import { CommentGroup } from './commentGroup';

const reportComment = fn();
const replyComment = fn();

const meta = {
  title: 'Components/Features/Comments/Comment',
  component: Comment,
  args: {
    comment: {id: "1", text: 'Looks good', date: new Date(), user: { name: 'Person 1', id: "1"} },
    onReply: replyComment,
    onReport: reportComment,
    children: (
        <Comment comment={({id: "2", text: 'Thanks', date: new Date(), user: { name: 'OP 1', id: "2"} })} onReply={replyComment} onReport={reportComment} />
    )
  },
  decorators: [(Story) => (<CommentGroup><Story/></CommentGroup>)]
} satisfies Meta<typeof Comment>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
};
