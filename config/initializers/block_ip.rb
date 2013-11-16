use Rack::Block do
  ip_pattern '142.157.201.53' do
  # expressions like '192.0.0.' also available
    halt 404
  end
end
run App.new