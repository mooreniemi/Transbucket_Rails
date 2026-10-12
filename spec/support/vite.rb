# The React shell (app/views/layouts/react_app.html.erb) asks vite_rails for
# the bundle's script and style tags, which raises when there's no built
# bundle -- and specs don't build one (it needs Node, which this suite doesn't
# depend on). Return empty tags instead so server-side specs can render the
# shell and assert on everything around it.
module ViteTagStubs
  def vite_react_refresh_tag(**) = ''
  def vite_client_tag(**) = ''
  def vite_javascript_tag(*, **) = ''
  def vite_typescript_tag(*, **) = ''
  def vite_stylesheet_tag(*, **) = ''
end

ActionView::Base.prepend(ViteTagStubs)
