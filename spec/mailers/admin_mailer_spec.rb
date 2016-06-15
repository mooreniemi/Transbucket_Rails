require "spec_helper"

describe AdminMailer do
  let(:user) { build(:user) }
  let(:mail) {AdminMailer.announcement_email(user)}
  it "should have the right subject line" do
    expect(mail.subject).to eq("Announcements from Transbucket.com")
  end
end
