import type { Meta, StoryObj } from '@storybook/tanstack-react';
import { fn } from 'storybook/test';

import { CommentGroup } from './commentGroup';
import { Comment } from './comment';

const reportComment = fn();
const replyComment = fn();

const meta = {
  title: 'Components/Features/Comments/Comment Group',
  component: CommentGroup,
  subcomponents: {
    Comment
  },
  args: {
    children: (
        <>
            <Comment comment={({id: "1", text: 'Looks good', date: new Date(), user: { name: 'Person 1', id: "1"} })} onReply={replyComment} onReport={reportComment}>
                <Comment comment={({id: "3", text: 'Thanks', date: new Date(), user: { name: 'OP 1', id: "2"}})} onReply={replyComment} onReport={reportComment}>
                    <Comment comment={({id: "4", text: 'Agree, it looks great', date: new Date(), user: { name: 'Person 2', id: "3"}})} onReply={replyComment} onReport={reportComment} />
                    <Comment comment={({id: "5", text: '+2', date: new Date(), user: { name: 'Person 3', id: "3"}})} onReply={replyComment} onReport={reportComment} />
                </Comment>
            </Comment>
            <Comment comment={({id: "3", text: 'Hate it', date: new Date(), user: { name: 'Person 4', id: "4"}})} onReply={replyComment} onReport={reportComment} />
        </>
    )
  }
} satisfies Meta<typeof CommentGroup>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
};
