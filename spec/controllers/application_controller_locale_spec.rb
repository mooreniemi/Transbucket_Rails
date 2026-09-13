require 'rails_helper'

# Regression test for a real bug found via the full suite: capture_user_locale
# ran unguarded on every authenticated request and raised
# ActiveRecord::ActiveRecordError ("cannot update a new record") whenever
# current_user was an unsaved record -- which is exactly what the bare
# `sign_in` controller-spec helper defaults to (build(:user), not create).
# Can't happen with a real Warden session, but this is a non-essential side
# effect that must never be able to take a real request down regardless.
describe PagesController, type: :controller do
  it 'does not raise when current_user is an unsaved record' do
    sign_in(build(:user))

    expect { get :home }.not_to raise_error
  end
end
