require 'rails_helper'

# The feed used to run about four extra queries per card (images, surgeon,
# procedure, procedure translations). This keeps the number of queries flat as the
# page fills, on every way of reaching the feed.
describe 'feed query count', type: :request do
  include Warden::Test::Helpers

  after { Warden.test_reset! }

  def count_queries
    # The filtered feed caches its query by filter values; start each measurement clean
    # so the count doesn't depend on which spec ran before this one.
    Rails.cache.clear
    count = 0
    subscription = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      count += 1 unless payload[:name] == 'SCHEMA' || payload[:sql] =~ /\A\s*(BEGIN|COMMIT|SAVEPOINT|RELEASE)/i
    end
    yield
    count
  ensure
    ActiveSupport::Notifications.unsubscribe(subscription)
  end

  it 'does not add queries per card' do
    viewer = create(:user, :with_confirmation)
    User.where(id: viewer.id).update_all(last_sign_in_at: 3.days.ago)
    authors = create_list(:user, 3, :with_confirmation)
    procedures = create_list(:procedure, 3)
    surgeons = create_list(:surgeon, 3)
    add_pins = lambda do |how_many|
      how_many.times do |i|
        pin = create(:pin, user: authors[i % 3], surgeon: surgeons[i % 3], procedure: procedures[i % 3], satisfaction: 3, sensation: 3, pin_images: build_list(:pin_image, 2))
        create_list(:comment, 2, commentable: pin, user: authors[(i + 1) % 3])
      end
    end
    login_as(viewer, scope: :user)

    paths = {
      'recent' => '/en/pins',
      'for you' => '/en/pins?feed=for_you',
      'filtered' => '/en/pins?satisfaction=3', # every pin below has satisfaction 3, so the filter always matches them
      'by user' => "/en/pins?user=#{authors.first.id}"
    }
    add_pins.call(3)
    paths.each_value { |path| get path } # warm class-level lookups so only per-card queries are counted
    few = paths.map { |name, path| [name, count_queries { get path }] }.to_h

    add_pins.call(9)
    many = paths.map { |name, path| [name, count_queries { get path }] }.to_h

    paths.each_key do |name|
      expect(many[name]).to be <= few[name] + 2, "#{name}: #{few[name]} queries for a few cards, #{many[name]} for many"
    end
  end
end
