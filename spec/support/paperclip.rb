url = Paperclip::Attachment.default_options[:url]
Paperclip::Attachment.default_options[:path] = "#{Rails.root}/public/test_files#{ENV['TEST_ENV_NUMBER']}#{url}"
Paperclip::Attachment.default_options[:url] = "/test_files#{ENV['TEST_ENV_NUMBER']}#{url}"

RSpec.configure do |config|
  config.after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/test_files#{ENV['TEST_ENV_NUMBER']}/"])
  end
end
