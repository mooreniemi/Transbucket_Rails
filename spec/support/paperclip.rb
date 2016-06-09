url = Paperclip::Attachment.default_options[:url]
Paperclip::Attachment.default_options[:path] = "#{Rails.root}/public/test_files#{url}"
Paperclip::Attachment.default_options[:url] = "/test_files#{url}"

RSpec.configure do |config|
  config.after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/test_files/"])
  end
end
