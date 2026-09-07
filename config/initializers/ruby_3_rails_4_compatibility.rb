if RUBY_VERSION >= '3.0'
  # i18n 0.9.5's YAML loader (used by faker's locale files, among others)
  # calls YAML.load_file, which under Psych 4 rejects the YAML aliases those
  # files use. Restore the pre-Psych-4 permissive behavior for this path.
  require 'i18n/backend/base'
  module I18n
    module Backend
      module Base
        def load_yml(filename)
          YAML.unsafe_load_file(filename)
        rescue TypeError, ScriptError, StandardError => e
          raise InvalidLocaleData.new(filename, e.inspect)
        end
      end
    end
  end

  module ActiveRecord::Associations::Builder
    class CollectionAssociation
      def initialize(model, name, scope, options, &extension)
        super(model, name, scope, options)
        @mod = nil

        if extension
          @mod = Module.new(&extension)
          @scope = wrap_scope @scope, @mod
        end
      end
    end
  end

  # Several places in Rails 4.2 rely on Ruby's old implicit `Proc.new`
  # (capturing the caller's block with no explicit `&block` param), which
  # Ruby 3.0 removed. Each one is hit by ordinary app usage (association
  # queries, default_scope, every controller action), so they're patched
  # here to take an explicit block instead.
  class ActiveRecord::StatementCache
    def self.create(connection, &block)
      relation      = block.call ActiveRecord::StatementCache::Params.new
      bind_map      = ActiveRecord::StatementCache::BindMap.new relation.bind_values
      query_builder = connection.cacheable_query relation.arel
      new query_builder, bind_map
    end
  end

  module ActiveRecord::Scoping::Default::ClassMethods
    def default_scope(scope = nil, &block)
      scope = block if block_given?

      if scope.is_a?(ActiveRecord::Relation) || !scope.respond_to?(:call)
        raise ArgumentError,
          "Support for calling #default_scope without a block is removed. For example instead " \
          "of `default_scope where(color: 'red')`, please use " \
          "`default_scope { where(color: 'red') }`. (Alternatively you can just redefine " \
          "self.default_scope.)"
      end

      self.default_scopes += [scope]
    end
  end

  class ActionController::MiddlewareStack
    def build(action, app = nil, &block)
      app ||= block
      action = action.to_s

      middlewares.reverse.inject(app) do |a, middleware|
        middleware.valid?(action) ? middleware.build(a) : a
      end
    end
  end

  # URI.escape/unescape were removed in Ruby 3.0; paperclip's URL generator
  # still calls them.
  module URI
    def self.escape(*args)
      DEFAULT_PARSER.escape(*args)
    end

    def self.unescape(*args)
      DEFAULT_PARSER.unescape(*args)
    end
  end
end
