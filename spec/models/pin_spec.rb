# spec/models/pin_spec.rb
require 'rails_helper'

describe Pin do
  it 'has a valid factory' do
    expect(create(:pin)).to be_valid
  end
  it 'is invalid without a surgeon' do
    expect(build(:pin, surgeon: nil)).to_not be_valid
  end
  it 'is invalid without a user_id' do
    expect(build(:pin, user_id: nil)).to_not be_valid
  end
  it 'is invalid without a procedure' do
    expect(build(:pin, procedure: nil)).to_not be_valid
  end
  it 'is published as its initial state' do
    expect(build(:pin).state).to eq('published')
  end
  describe '.recent' do
    it 'orders published pins by submission or attachment activity and then id' do
      timestamp = 1.day.ago
      older_id = create(:pin, created_at: timestamp, updated_at: timestamp, state: 'published')
      newer_id = create(:pin, created_at: timestamp, updated_at: timestamp, state: 'published')
      [older_id, newer_id].each do |pin|
        pin.pin_images.update_all(created_at: timestamp, updated_at: timestamp, photo_updated_at: nil)
      end
      create(:pin, updated_at: timestamp, state: 'pending')

      expect(Pin.recent).to eq([newer_id, older_id])
    end

    it 'resurfaces a pin when an attachment is updated' do
      older_pin = create(:pin, created_at: 2.days.ago)
      newer_pin = create(:pin, created_at: 1.day.ago)
      older_pin.pin_images.update_all(created_at: 2.days.ago, updated_at: 2.days.ago, photo_updated_at: 2.days.ago)
      newer_pin.pin_images.update_all(created_at: 1.day.ago, updated_at: 1.day.ago, photo_updated_at: 1.day.ago)
      older_pin.pin_images.first.update_column(:photo_updated_at, 1.hour.ago)

      expect(Pin.recent.first).to eq(older_pin)
    end
  end
  describe '#comments_asc' do
    it 'returns comments for pin in desc order' do
      pin = create(:pin, :with_comments)
      expect(pin.comments_asc).to eq(pin.comment_threads.order('updated_at asc'))
    end
  end
  describe '#complications' do
    it 'allows complication tags to be added' do
      pin = create(:pin)
      pin.complication_list = "runny nose, pain"
      pin.save
      pin.reload
      expect(pin.complications.first.name).to eq('runny nose')
    end
  end
end
