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
end
