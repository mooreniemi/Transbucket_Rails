require 'rails_helper'

describe HealthMailer, type: :mailer do
  let(:mail) { HealthMailer.alert(%w[logins signups]) }

  it 'names the failing checks in the subject' do
    expect(mail.subject).to eq('[Transbucket health] failing: logins, signups')
  end

  it 'goes to the admin address by default' do
    expect(mail.to).to eq([HealthMailer::ADMIN])
  end

  it 'explains each failing check with its window' do
    expect(mail.body.encoded).to include('logins (none in the last 3 hours)')
    expect(mail.body.encoded).to include('signups (none in the last 6 hours)')
  end
end
