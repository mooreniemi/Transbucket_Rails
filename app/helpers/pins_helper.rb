module PinsHelper
  # How many filter values are applied to the feed right now (for the badge on
  # the Filter button).
  def active_filter_count
    %i[scope procedure surgeon].sum { |key| Array(params[key]).reject(&:blank?).size }
  end

  # Keyed by Gender#name rather than id -- ids aren't stable across
  # environments (or even within one, if genders are ever reseeded), so an
  # id-keyed hash risks silently misgendering users if a Gender's id ever
  # doesn't match what this hash assumed.
  PRONOUN_HASH = {
    "FTM" => "he/him/his",
    "MTF" => "she/her/hers",
    "GenderQueer" => "they/them/theirs",
    "None" => "they/them/theirs",
    "Cisgender" => "they/them/theirs"
  }

  # used to mimic the shape of a PinImage
  class FakeImage
    def url(_size)
      'http://placekitten.com/200/300'
    end
  end

  def uses_pronouns(author_gender)
    return "they/them/theirs" if author_gender.nil?
    PRONOUN_HASH.fetch(author_gender.name, "they/them/theirs")
  end

  # What the author asked to be called, else the pronouns their gender implies.
  def author_pronouns(user)
    user.try(:pronouns).presence || uses_pronouns(user.try(:gender))
  end

  # Standard pronoun sets read in the viewer's language (she/her -> sie/ihr) where
  # we have a well-established equivalent; everything else, including whatever
  # people typed themselves, is shown exactly as stored.
  def pronouns_label(value)
    return value unless User::PRONOUN_PRESETS.include?(value)

    t("public.auth.pronoun_labels.#{value.tr('/', '_')}", default: value)
  end

  # FIXME: this could be a lot more robust, and reflect user preference rather than last
  #
  # +_safe_mode+ is ignored: safe mode used to swap in a cat picture here, and now
  # blurs the real image in the view instead (see safe_blur.css.scss).
  def cover_image(_safe_mode = false)
    images.try(:last) ? images.last : FakeImage.new
  end

  def images
    pin_images.collect { |pin| pin.photo }
  end

  def unknown_surgeon?
    if surgeon.present?
      surgeon.id == 911
    else
      update_attributes(surgeon_id: 911)
    end
  end

  def latest_comment_snippet
    try(:comment_threads).try(:last).try(:snippet)
  end
end
