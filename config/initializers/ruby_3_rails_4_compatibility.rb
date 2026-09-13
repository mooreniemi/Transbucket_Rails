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
