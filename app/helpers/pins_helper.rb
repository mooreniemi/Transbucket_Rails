module PinsHelper
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

  # FIXME: this could be a lot more robust, and reflect user preference rather than last
  def cover_image(safe_mode = false)
    kitty_url = FakeImage.new
    cover = images.try(:last) ? images.last : kitty_url
    image = safe_mode == true ? kitty_url : cover
    image
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
