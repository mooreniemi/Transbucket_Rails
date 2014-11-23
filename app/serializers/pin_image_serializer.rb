class PinImageSerializer < ActiveModel::Serializer
  attributes :id, :name, :size, :type, :url
  def name
    object.photo_file_name
  end
  def size
    object.photo_file_size
  end
  def type
    object.photo_content_type
  end
  def url
    object.photo.url(:thumb)
  end
end
