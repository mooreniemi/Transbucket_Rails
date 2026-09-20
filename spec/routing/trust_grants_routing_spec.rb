require 'rails_helper'

describe TrustGrantsController, type: :routing do
  it 'uses the short trust path for the role-management screen' do
    expect(get: '/en/trust').to route_to(controller: 'trust_grants', action: 'index', locale: 'en')
  end
end
