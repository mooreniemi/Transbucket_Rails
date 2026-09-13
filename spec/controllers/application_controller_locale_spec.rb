require 'rails_helper'

# Regression test for a real bug found via the full suite: capture_user_locale
# ran unguarded on every authenticated request and raised
# ActiveRecord::ActiveRecordError ("cannot update a new record") whenever
# current_user was an unsaved record -- which is exactly what the bare
# `sign_in` controller-spec helper defaults to (build(:user), not create).
# Can't happen with a real Warden session, but this is a non-essential side
# effect that must never be able to take a real request down regardless.
describe PagesController, type: :controller do
  it 'redirects the alternate production hostname to the canonical host' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

    @request.host = 'www.transbucket.com'
    get :home

    expect(response).to redirect_to('https://transbucket.com/en')
  end

  it 'does not redirect the staging hostname to production' do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

    @request.host = 'transbucket-staging.herokuapp.com'
    get :home

    expect(response).to have_http_status(:ok)
  end

  it 'does not raise when current_user is an unsaved record' do
    sign_in(build(:user))

    expect { get :home }.not_to raise_error
  end

  it 'runs CSRF verification before locale capture' do
    filters = ApplicationController._process_action_callbacks.map(&:filter)

    expect(filters.index(:verify_authenticity_token)).to be < filters.index(:set_locale)
  end
end
