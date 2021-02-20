# FIXME
# There should be able to use https://github.com/trailblazer/reform-rails/blob/master/lib/reform/form/validation/unique_validator.rb#L14
# But I could not get it to fire, so I added in this class
class ValidateUniqueNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # we only want to validate this if we haven't persisted this yet
    unless record.model.persisted?
      seen_this = record.model.class.where(name: value.downcase).count
      if seen_this
        record.errors[attribute] << (options[:message] || "not a unique name, please use existing #{record.model.class.name}")
      end
    end
  end
end
