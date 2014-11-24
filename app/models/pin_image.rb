class PinImage < ActiveRecord::Base
  belongs_to :pin

  has_attached_file :photo, styles: {medium: "320x240>", thumb: "100x100#"}, default_url: "http://placekitten.com/200/300"
  validates_attachment_content_type :photo, content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
