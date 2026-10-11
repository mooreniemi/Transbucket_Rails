require 'rails_helper'
require 'scout_apm'

# New Relic instruments Elasticsearch and Net::HTTP with Module#prepend. Scout's
# default alias_method chaining on those same methods recursed until the stack
# overflowed, so every pin search returned 500 once both agents ran together on
# production. Scout must prepend too. This loads the config the way the agent
# does, for the environment Heroku runs (staging and production both use it).
describe 'Scout APM configuration' do
  def scout_config_for(env)
    context = ScoutApm::AgentContext.new
    allow(context.environment).to receive(:env).and_return(env)
    ScoutApm::Config.with_file(context, Rails.root.join('config', 'scout_apm.yml').to_s)
  end

  it 'instruments with Module#prepend in production so it composes with New Relic' do
    expect(scout_config_for('production').value('use_prepend')).to eq(true)
  end

  it 'keeps SCOUT_KEY and SCOUT_MONITOR coming from the environment' do
    raw = YAML.safe_load(File.read(Rails.root.join('config', 'scout_apm.yml')))
    expect(raw.fetch('production').keys).not_to include('key', 'monitor')
  end
end
