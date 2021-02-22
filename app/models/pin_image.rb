# PinImages is probably somewhat confusing.
# Probably should've just stuck paperclip on pin.
class PinImage < ActiveRecord::Base
  # NOTE: CDN to reduce data transfer cost from S3
  CLOUDFRONT_URL = "https://dwusg3ww9j123.cloudfront.net/"
  belongs_to :pin

  has_attached_file :photo,
    styles: { medium: '320x240>', thumb: '100x100#' },
    default_url: 'http://placekitten.com/200/300',
    s3_host_alias: CLOUDFRONT_URL

  validates_attachment_content_type :photo,
    content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']

end
