require 'json'

# Bridges the react/ Vite app into a Rails view. Not Sprockets -- the React
# build is a separate pipeline entirely (see lib/tasks/vite.rake), this just
# points a <script>/<link> tag at wherever that pipeline's output currently
# lives: the Vite dev server itself in development (for HMR), or the
# manifest-resolved hashed files copied into public/vite in production.
module ViteHelper
  VITE_DEV_SERVER_URL = 'http://localhost:5173'.freeze
  VITE_PUBLIC_DIR = Rails.root.join('public', 'vite').freeze
  VITE_ENTRY = 'src/main.tsx'.freeze

  def vite_tags
    if Rails.env.development?
      vite_dev_server_tags
    else
      vite_production_tags
    end
  end

  private

  def vite_dev_server_tags
    # @vitejs/plugin-react normally injects this Fast Refresh setup script
    # itself when Vite serves the HTML page directly. Since Rails serves
    # our page instead, it never gets injected -- without it, the React
    # bundle throws "can't detect preamble" as soon as it loads. This is
    # Vite's own documented workaround for non-Vite backends.
    preamble = <<~HTML.html_safe
      <script type="module">
        import RefreshRuntime from "#{VITE_DEV_SERVER_URL}/@react-refresh"
        RefreshRuntime.injectIntoGlobalHook(window)
        window.$RefreshReg$ = () => {}
        window.$RefreshSig$ = () => (type) => type
        window.__vite_plugin_react_preamble_installed__ = true
      </script>
    HTML

    safe_join [
      preamble,
      javascript_include_tag("#{VITE_DEV_SERVER_URL}/@vite/client", type: 'module'),
      javascript_include_tag("#{VITE_DEV_SERVER_URL}/#{VITE_ENTRY}", type: 'module'),
    ], "\n".html_safe
  end

  def vite_production_tags
    entry = vite_manifest.fetch(VITE_ENTRY)

    tags = (entry['css'] || []).map { |css| stylesheet_link_tag("/vite/#{css}") }
    tags << javascript_include_tag("/vite/#{entry['file']}", type: 'module')
    safe_join(tags, "\n".html_safe)
  end

  def vite_manifest
    @vite_manifest ||= JSON.parse(File.read(VITE_PUBLIC_DIR.join('.vite', 'manifest.json')))
  end
end
