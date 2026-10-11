require 'rails_helper'
require 'rake'

describe 'health:check' do
  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?('health:check')
  end

  before do
    ActionMailer::Base.deliveries.clear
    Rake::Task['health:check'].reenable
  end

  it 'sends no email when healthy' do
    allow_any_instance_of(AuthHealthCheck).to receive(:failing).and_return([])

    expect { Rake::Task['health:check'].invoke }.to output("health ok\n").to_stdout
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it 'emails the failing checks when unhealthy' do
    allow_any_instance_of(AuthHealthCheck).to receive(:failing).and_return(['logins'])

    expect { Rake::Task['health:check'].invoke }.to output("health failing: logins\n").to_stdout
    expect(ActionMailer::Base.deliveries.last.subject).to eq('[Transbucket health] failing: logins')
  end
end
