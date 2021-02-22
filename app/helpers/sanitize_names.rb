module SanitizeNames
  # https://gist.github.com/bcoe/6505434
  def sanitize_string(str)
    # Escape special characters
    # http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1/queryparsersyntax.html#Escaping Special Characters
    escaped_characters = Regexp.escape('\\+-&|!(){}[]^~*?:\/')
    str = str.gsub(/([#{escaped_characters}])/, '\\\\\1')

    # AND, OR and NOT are used by lucene as logical operators. We need
    # to escape them
    ['AND', 'OR', 'NOT'].each do |word|
      escaped_word = word.split('').map {|char| "\\#{char}" }.join('')
      str = str.gsub(/\s*\b(#{word.upcase})\b\s*/, " #{escaped_word} ")
    end

    # Escape odd quotes
    quote_count = str.count '"'
    str = str.gsub(/(.*)"(.*)/, '\1\"\3') if quote_count % 2 == 1

    str
  end

  def sanitize_query(query)
    query.gsub!(/(dr.|Dr.|dr|Dr)/, '')
    query.gsub!(/[\W]/, ' ')
    return sanitize_string(query)
  end

  def sanitize_last_name
    name = self[:last_name] || self['last_name'] || self.last_name
    name.gsub!(/(dr.|Dr.|dr|Dr|DR)/, '')
    name.split(',').first
    name.gsub!(/(MD$|md$|m.d.$|M.D.$)/, '')
    name.gsub!(/^\s/, '')
    name.gsub!(/\s$/, '')
    name
  end

  def sanitize_procedure_name
    name = self[:name] || self.name
    return if name.split(',').length > 1
  end
end
