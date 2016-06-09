Paperclip::Attachment.default_options[:path] = "#{Rails.root}/spec/test_files/:class/:id_partition/:style.:extension"

RSpec.configure do |config|
  config.after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/test_files/"])
  end
end
