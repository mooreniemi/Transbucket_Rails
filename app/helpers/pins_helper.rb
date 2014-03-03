module PinsHelper
	PRONOUN_HASH = {
		1 => "he/him/his",
		2 => "she/her/hers",
		3 => "they/them/theirs",
		4 => "they/them/theirs"
	}

	def uses_pronouns(author_gender)
		return "they/them/theirs" if author_gender.nil?
		unless PRONOUN_HASH[author_gender.id].nil?
			PRONOUN_HASH[author_gender.id]
		else
			"they/them/theirs"
		end
	end
end
