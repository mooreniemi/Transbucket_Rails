require 'spec_helper'

describe Message do
  it "has name, email, subject, and body to be valid" do
    message = Message.new(
      {name: 'foo',
       email: 'foo@foo.com',
       subject: 'hello',
       body: 'yeah'})
    expect(message.valid?).to eq(true)
  end
end
