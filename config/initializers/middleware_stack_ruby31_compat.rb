# ActionDispatch::MiddlewareStack::Middleware stores each middleware's
# registration args as a plain Array and later splats them back into
# `klass.new(app, *args)`. A trailing options hash (e.g. ActionDispatch::
# Static's `index:`/`headers:` kwargs) loses its keyword-ness across that
# round trip under Ruby 3, so it arrives as an extra positional argument
# instead. Splitting a trailing Hash back out with ** at the final call
# site fixes it regardless of which layer (config.middleware.use, an
# engine, a railtie) registered it.
#
# This has to be a regular initializer, not a config/application.rb-level
# patch: reopening ActionDispatch::MiddlewareStack::Middleware before the
# classic autoloader has loaded that file itself confuses it into loading
# action_controller/metal.rb's own (differently-superclassed) MiddlewareStack
# a second time later, raising "superclass mismatch for class MiddlewareStack".
# The actual failure this fixes happens during the Finisher phase of
# Rails.application.initialize!, well after initializers have loaded, so
# there's no ordering problem waiting until here.
if RUBY_VERSION >= '3.0'
  class ActionDispatch::MiddlewareStack::Middleware
    def build(app)
      if args.last.is_a?(Hash)
        klass.new(app, *args[0..-2], **args.last, &block)
      else
        klass.new(app, *args, &block)
      end
    end
  end
end
