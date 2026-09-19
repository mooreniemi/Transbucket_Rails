import { type ReactNode, useState, type SubmitEvent} from 'react';
import { formatDateTime } from '#/lib/dateTime';
import { type Comment } from './types';
import { Button } from '../button';
import { ChevronDown, ChevronRight, MessageSquare, Flag } from 'lucide-react';
import { Disclosure, DisclosurePanel } from 'react-aria-components';
import { Textarea } from '../textarea';

interface CommentProps {
    comment: Comment;
    children?: ReactNode;
    locale?: string;
    onReply(data: FormDataEntryValue | null): void;
    onReport(commentId: string): void;
    isPending?: boolean;
}

export function Comment({ children, comment, locale, onReply, onReport, isPending = false }: CommentProps) {
    const formattedDate = formatDateTime(comment.date, true, locale);
    const [editMode, setEditMode ] = useState(false);
    const openReplyBox = () => {
        setEditMode(true);
    }
    const closeReplyBox = () => {
        setEditMode(false);
    }
    const handleReply = (ev: SubmitEvent) => {
        ev.preventDefault();
        const formValue = new FormData(ev.target);
        onReply(formValue.get("reply"));
    }
    const handleReportComment = () => {
        onReport(comment.id);
    } 

    return (
        <li className="mb-4 last:mb-0">
            <div>{comment.text}</div>
            <div className="text-xs text-black-700 font-medium grid auto-cols-auto grid-flow-col justify-start items-center mt-1 mb-2" style={{columnRule: "1px solid var(--ds-color-black-200)"}}>
                <Button href={`/?user=${comment.user.id}`} variant="link" className="pl-0 text-xs h-auto">{comment.user.name}</Button>
                <span className="px-2.5">{formattedDate}</span>
                <Button variant="link" onClick={openReplyBox} className="text-xs h-auto">reply<MessageSquare size={16}/></Button>
                <Button variant="link" onClick={handleReportComment} className="text-xs h-auto"><Flag size={16} />Report</Button>
            </div>
            { editMode && (
                <form onSubmit={handleReply}>
                    <Textarea name="reply" />
                    <div className="mt-2 text-right">
                        <Button
                            type="button"
                            variant="outline"
                            className="mr-2"
                            onClick={closeReplyBox}
                        >
                            Cancel
                        </Button>
                        <Button type="submit" isPending={isPending}>Save</Button>
                    </div>
                </form>
            )}
            { children && (
                <Disclosure defaultExpanded>
                    {({ isExpanded }) => (
                        <>
                            <Button slot="trigger" variant='ghost' size="icon-xs" className="mt-2">
                                { isExpanded
                                    ? (<ChevronDown />)
                                    : (<ChevronRight />)
                                }
                                <span className="sr-only">Toggle replies</span>
                            </Button>
                            <DisclosurePanel>
                                <ol className="pl-8 border-l border-black-100">{children}</ol>
                            </DisclosurePanel>
                        </>
                    )}
                </Disclosure>
            )}
        </li>
    );
}