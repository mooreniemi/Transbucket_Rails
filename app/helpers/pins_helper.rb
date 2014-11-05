module PinsHelper
	PRONOUN_HASH = {
		1 => "he/him/his",
		2 => "she/her/hers",
		3 => "they/them/theirs",
		4 => "they/them/theirs"
	}

	def uses_pronouns(author_gender)
		return "they/them/theirs" if author_gender.nil?
		PRONOUN_HASH[author_gender.id]
	end

	def show_new_comments(pin)
		# TODO huge performance hit happening here
		comments = Comment.new_comments_to(signed_in_user, pin.id)
	end

	def signed_in_user
		User.find(current_user).last_sign_in_at
	end
end
