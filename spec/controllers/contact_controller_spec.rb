require 'rails_helper'

describe ContactController do
  let(:valid_message) do
    { name: 'Sam', email: 'sam@example.com', subject: 'Hello', body: 'A question' }
  end

  before { ActionMailer::Base.deliveries.clear }

  it 'sends the contact message to the admin and redirects home' do
    post :create, params: { message: valid_message }

    expect(response).to redirect_to(root_path)
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([ContactMailer::ADMIN])
    expect(mail.subject).to eq('[Transbucket.com Support] Hello from sam@example.com')
  end

  it 're-renders the form without sending when the message is invalid' do
    post :create, params: { message: valid_message.merge(email: '') }

    expect(response).to render_template(:new)
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
