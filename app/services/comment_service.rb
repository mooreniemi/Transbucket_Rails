#app/services/comments_service.rb
class CommentService
	attr_reader :body, :commentable, :commenter
	attr_accessor :comment

	def initialize(commentable, commenter, body)
		@commentable = commentable
		@body = body
		@commenter = commenter
	end

	def create
		policy = UserPolicy.new(commentable.user)

		if policy.wants_email?
			@comment = create_and_notify
		else
			@comment = build
		end

		@comment.save
	end

	private

	def build
		Comment.build_from(commentable, commenter, body)
	end

	# TODO we shouldnt be sending notification until we are
	# sure the save happened without error
	def create_and_notify
		comment = build

		begin
			send_email_notification(comment)
		rescue => e
			puts "#{e} was raised while attempting to send notification " +
				"on #{commentable.class} #{commentable.id} to User #{commentable.user.id}"
		end

		comment
	end

	def send_email_notification(comment)
		CommentMailer.new_comment_email(commentable.user.id, commentable.id).deliver_now
	end
end
