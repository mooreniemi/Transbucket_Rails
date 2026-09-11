require 'rails_helper'

describe UnconfirmedReminderService do
  let(:confirmed_user) { create(:user, :with_confirmation) }
  let!(:never_reminded) { create(:user, created_at: 2.days.ago) }
  let!(:already_reminded) { create(:user, created_at: 2.days.ago, confirmation_reminder_sent_at: 1.day.ago) }
  let!(:too_old) { create(:user, created_at: 1.year.ago) }

  def service(**opts)
    described_class.new(sleep_between: 0, **opts)
  end

  before { confirmed_user }

  describe '#scope' do
    it 'only includes unconfirmed users who have not already been reminded' do
      expect(service.scope).to contain_exactly(never_reminded, too_old)
    end

    it 'excludes users outside a given time range' do
      expect(service(since: 1.week.ago).scope).to contain_exactly(never_reminded)
    end

    it 'respects the limit, ordered newest first' do
      expect(service(limit: 1).scope).to eq([never_reminded])
    end

    it 'hard-caps the limit even if a larger one is requested' do
      svc = service(limit: described_class::MAX_LIMIT + 1000)
      expect(svc.instance_variable_get(:@limit)).to eq(described_class::MAX_LIMIT)
    end
  end

  describe '#call' do
    it 'sends a reminder and stamps confirmation_reminder_sent_at' do
      expect { service.call }.to change { never_reminded.reload.confirmation_reminder_sent_at }.from(nil)
    end

    it 'marks the mail as a reminder so the mailer view can render different copy' do
      mail = nil
      allow_any_instance_of(User).to receive(:send_confirmation_instructions) do |user|
        mail = user.confirmation_reminder
      end

      service.call

      expect(mail).to eq(true)
    end

    it 'does not touch users outside the scope' do
      service.call
      expect(already_reminded.reload.confirmation_reminder_sent_at).to be_within(1.minute).of(1.day.ago)
    end
  end
end
