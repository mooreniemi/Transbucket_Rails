require 'rails_helper'

describe NotificationsHelper do
  describe '#notify_admin' do
    let(:comment) { create(:comment) }
    it 'sends an async email to admin about review' do
      expect(comment.admin_review).to be_a Delayed::Backend::ActiveRecord::Job
    end
    let(:pin) { create(:pin) }
    it 'sends an async email to admin about review' do
      expect(pin.admin_review).to be_a Delayed::Backend::ActiveRecord::Job
    end
  end
end
