url = Paperclip::Attachment.default_options[:url]
Paperclip::Attachment.default_options[:path] = "#{Rails.root}/public/test_files#{ENV['TEST_ENV_NUMBER']}#{url}"
Paperclip::Attachment.default_options[:url] = "/test_files#{ENV['TEST_ENV_NUMBER']}#{url}"

RSpec.configure do |config|
  config.before(:each) do
    FileUtils.mkdir_p("#{Rails.root}/public/test_files#{ENV['TEST_ENV_NUMBER']}")
  end

  config.after(:each) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/test_files#{ENV['TEST_ENV_NUMBER']}/"])
  end

  config.before(:each, :fake_images => true) do
    # Rails 7.1+ loads config/routes.rb lazily, on first use. A route added
    # before that is wiped when the real routes load a moment later, so a
    # browser spec that was the first to touch routes in a run got a
    # RoutingError for every fake photo. Load them first.
    Rails.application.routes.routes.size
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

class TestFilesController < ActionController::Base
  def missing
    head :no_content
  end
end
