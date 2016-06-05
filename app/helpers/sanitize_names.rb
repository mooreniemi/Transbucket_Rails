module SanitizeNames
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
