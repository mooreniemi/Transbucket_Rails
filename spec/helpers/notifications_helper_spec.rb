require 'rails_helper'

describe NotificationsHelper do
  describe '#admin_review' do
    let(:comment) { create(:comment) }
    it 'queues only a reviewable type and ID' do
      job = comment.admin_review

      expect(job).to be_a Delayed::Backend::ActiveRecord::Job
      payload = job.payload_object
      expect(payload.method_name).to eq(:admin_review_async_without_delay)
      expect(payload.object).to eq(Comment)
      expect(payload.args).to eq(['Comment', comment.id])
      expect(payload.args).not_to include(comment)
    end

    let(:pin) { create(:pin) }
    it 'reloads the reviewable when the primitive job runs' do
      job = pin.admin_review
      delivery = double('delivery')

      allow(Pin).to receive(:find_by).with(id: pin.id).and_return(pin)
      allow(ReviewMailer).to receive(:please_review).with(pin).and_return(delivery)
      expect(delivery).to receive(:deliver_now)

      job.payload_object.perform
    end
  end
end
