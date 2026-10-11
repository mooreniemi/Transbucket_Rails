# Compatibility shims for legacy gems that have not yet replaced Ruby APIs
# removed in Ruby 3.3. Remove these once TinyMCE Rails and
# will_paginate-bootstrap are upgraded or replaced.
unless File.respond_to?(:exists?)
  File.define_singleton_method(:exists?) { |path| File.exist?(path) }
end

Fixnum = Integer unless defined?(Fixnum)
