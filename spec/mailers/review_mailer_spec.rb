require "rails_helper"

describe ReviewMailer, type: :mailer do
  describe '#please_review' do
    let(:comment) { create(:comment) }
    let(:mail) do
      ReviewMailer.please_review(comment)
    end
    it 'should have the right subject line' do
      expect(mail.subject).to eq("TB Admin: Please Review #{comment.id}")
    end
    it 'should contain the iterm id to be reviewed' do
      expect(mail.body.raw_source).to include("Please Review Comment ##{comment.id}")
    end
  end
end
