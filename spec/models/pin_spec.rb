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
