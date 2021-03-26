# rake sitemap:refresh
# https://github.com/kjvarga/sitemap_generator#rails
#
# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.transbucket.com"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  add procedures_path, :priority => 0.7, :changefreq => 'weekly'
  add surgeons_path, :priority => 0.7, :changefreq => 'weekly'
  add newsfeed_path, :changefreq => 'weekly'
  add about_path, :priority => 0.2, :changefreq => 'yearly'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  Procedure.find_each do |procedure|
    add procedure_path(procedure), :lastmod => procedure.updated_at
  end
  Surgeon.find_each do |surgeon|
    add surgeon_path(surgeon), :lastmod => surgeon.updated_at
  end
end
