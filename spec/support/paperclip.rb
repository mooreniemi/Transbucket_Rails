url = Paperclip::Attachment.default_options[:url]
Paperclip::Attachment.default_options[:path] = "#{Rails.root}/public/test_files#{ENV['TEST_ENV_NUMBER']}#{url}"
Paperclip::Attachment.default_options[:url] = "/test_files#{ENV['TEST_ENV_NUMBER']}#{url}"

RSpec.configure do |config|
  config.after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/test_files#{ENV['TEST_ENV_NUMBER']}/"])
  end

  config.before(:each, :fake_images => true) do
    Rails.application.routes.send(:eval_block,
                                  Proc.new do
                                    get "/test_files#{ENV['TEST_ENV_NUMBER']}/:url",
                                        to: 'test_files#missing', url: /.+/
                                  end)
  end

  config.after(:each, :fake_images => true) do
    Rails.application.reload_routes!
  end
end

class TestFilesController < ApplicationController
  def missing
    head :no_content
  end
end
