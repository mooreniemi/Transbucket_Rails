require 'rails_helper'

describe NeverSignedInOutreachService do
  let(:unconfirmed_user) { create(:user) }
  let!(:never_contacted) { create(:user, :with_confirmation, created_at: 2.days.ago) }
  let!(:already_contacted) { create(:user, :with_confirmation, created_at: 2.days.ago, never_signed_in_outreach_sent_at: 1.day.ago) }
  let!(:has_signed_in) { create(:user, :with_confirmation, created_at: 2.days.ago, sign_in_count: 1) }
  let!(:too_old) { create(:user, :with_confirmation, created_at: 1.year.ago) }

  def service(**opts)
    described_class.new(sleep_between: 0, **opts)
  end

  before { unconfirmed_user }

  describe '#scope' do
    it 'only includes confirmed users who have never signed in and have not already been contacted' do
      expect(service.scope).to contain_exactly(never_contacted, too_old)
    end

    it 'excludes users outside a given time range' do
      expect(service(since: 1.week.ago).scope).to contain_exactly(never_contacted)
    end

    it 'respects the limit, ordered newest first' do
      expect(service(limit: 1).scope).to eq([never_contacted])
    end

    it 'hard-caps the limit even if a larger one is requested' do
      svc = service(limit: described_class::MAX_LIMIT + 1000)
      expect(svc.instance_variable_get(:@limit)).to eq(described_class::MAX_LIMIT)
    end
  end

  describe '#call' do
    it 'sends a password reset email and stamps never_signed_in_outreach_sent_at' do
      expect { service.call }.to change { never_contacted.reload.never_signed_in_outreach_sent_at }.from(nil)
    end

    it 'does not mark a user as contacted unless the send actually succeeds' do
      allow_any_instance_of(User).to receive(:send_reset_password_instructions).and_raise(Net::SMTPError)

      expect { service.call rescue nil }.not_to change { never_contacted.reload.never_signed_in_outreach_sent_at }
    end

    it 'does not touch users outside the scope' do
      service.call
      expect(already_contacted.reload.never_signed_in_outreach_sent_at).to be_within(1.minute).of(1.day.ago)
    end

    it 'returns the number of users contacted' do
      expect(service.call).to eq(2)
    end
  end
end
