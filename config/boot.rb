# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

require 'bigdecimal'
require 'pg'
require 'uri'

unless BigDecimal.respond_to?(:new)
  def BigDecimal.new(*args)
    BigDecimal(*args)
  end
end

unless URI.class_variable_defined?(:@@schemes)
  URI.class_variable_set(:@@schemes, URI.scheme_list)
end

PGconn = PG::Connection unless defined?(PGconn)
PGresult = PG::Result unless defined?(PGresult)
PGError = PG::Error unless defined?(PGError)

module Kernel
  alias transbucket_original_gem gem

  def gem(name, *requirements)
    if name == 'pg' && requirements == ['~> 0.15']
      transbucket_original_gem(name)
    else
      transbucket_original_gem(name, *requirements)
    end
  end
end
