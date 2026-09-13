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
  ApplicationController::SUPPORTED_LOCALES.each do |locale|
    add root_path(locale: locale), :priority => 1.0, :changefreq => 'always'
    add procedures_path(locale: locale), :priority => 0.7, :changefreq => 'weekly'
    add surgeons_path(locale: locale), :priority => 0.7, :changefreq => 'weekly'
    add newsfeed_path(locale: locale), :changefreq => 'weekly'
    add about_path(locale: locale), :priority => 0.2, :changefreq => 'yearly'
  end
  Procedure.find_each do |procedure|
    ApplicationController::SUPPORTED_LOCALES.each do |locale|
      add procedure_path(procedure, locale: locale), :lastmod => procedure.updated_at
    end
  end
  Surgeon.find_each do |surgeon|
    ApplicationController::SUPPORTED_LOCALES.each do |locale|
      add surgeon_path(surgeon, locale: locale), :lastmod => surgeon.updated_at
    end
  end
end
