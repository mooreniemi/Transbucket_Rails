Rails.logger.info("Initializing Elasticsearch client")

# FIXME: switch to gem?
# https://github.com/omc/bonsai-elasticsearch-rails/blob/master/lib/bonsai/elasticsearch/rails/railtie.rb

host = ENV['BONSAI_URL'] || "http://localhost:9200"

# for local dev
config = {
  host: host,
  transport_options: {
    request: { timeout: 500 }
  }
}

if File.exists?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml")[Rails.env].deep_symbolize_keys)
end

if Rails.env.development?
  Rails.logger.warn("Will hit LOCAL Elasticsearch")
else
  Rails.logger.info("Will hit Bonsai Elasticsearch")
end

Elasticsearch::Model.client = Elasticsearch::Client.new(config)

# Make sure we can connect
# Elasticsearch::Model.client.cluster.health
