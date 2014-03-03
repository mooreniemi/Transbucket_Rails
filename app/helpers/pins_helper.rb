module PinsHelper
	PRONOUN_HASH = {
		"FTM" => "he/him/his",
		"MTF" => "she/her/hers",
		"GenderQueer" => "they/them/theirs",
		"None" => "they/them/theirs"
	}

	def uses_pronouns(author_gender)
		unless PRONOUN_HASH[author_gender].nil?
			PRONOUN_HASH[author_gender]
		else
			"they/them/theirs"
		end
	end
end
