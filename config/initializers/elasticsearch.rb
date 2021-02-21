# for local dev
config = {
  host: "http://localhost:9200",
  transport_options: {
    request: { timeout: 500 }
  }
}

if File.exists?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].deep_symbolize_keys)
end

Rails.logger.info("Initializing Elasticsearch client")

if Rails.env.development?
  # we don't sign requests to localhost
  Rails.logger.warn("Will hit LOCAL Elasticsearch")
  Elasticsearch::Model.client = Elasticsearch::Client.new(config)
elsif Rails.env.test?
  # FIXME: we can do better than this?
  # we don't want to run callbacks in this environment
  Rails.logger.warn("Not initializing Elasticsearch in test")
  Elasticsearch::Model.client = nil
else
  # https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-request-signing.html#es-request-signing-ruby
  require 'faraday_middleware/aws_sigv4'
  Rails.logger.info("Will hit AWS Elasticsearch")
  Elasticsearch::Model.client = Elasticsearch::Client.new(config) do |f|
    f.request :aws_sigv4,
      service: 'es',
      region: 'us-east-1',
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  end
end

# Make sure we can connect
# Elasticsearch::Model.client.cluster.health
