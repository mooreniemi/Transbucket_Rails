module ApplicationHelper
  def localized_gender_options(selected_id = nil)
    Gender.all.map do |gender|
      [I18n.t("gender_labels.#{gender.name}", default: gender.name), gender.id, { selected: gender.id == selected_id }]
    end
  end

  def locale_url(locale)
    url_for(request.query_parameters.merge(locale: locale))
  end

  def locale_alternate_links
    links = ApplicationController::SUPPORTED_LOCALES.map do |locale|
      tag(:link, rel: 'alternate', hreflang: locale, href: locale_url(locale))
    end
    links << tag(:link, rel: 'alternate', hreflang: 'x-default', href: locale_url('en'))
    safe_join(links, "\n")
  end

  def seo_meta(description:, canonical: nil, noindex: false)
    robots = noindex ? 'noindex,follow' : 'index,follow'
    canonical ||= "#{request.base_url}#{request.path}"

    set_meta_tags(
      description: description,
      canonical: canonical,
      robots: robots,
      og: { description: description },
      twitter: { description: description }
    )

    nil
  end

  def json_ld_tag(data)
    content_for :head do
      javascript_tag(type: 'application/ld+json') do
        raw(data.to_json)
      end
    end

    nil
  end

  def website_json_ld
    search_url = pins_url(locale: I18n.locale)
    {
      '@context' => 'https://schema.org',
      '@type' => 'WebSite',
      'name' => 'Transbucket.com',
      'url' => root_url(locale: I18n.locale),
      'potentialAction' => {
        '@type' => 'SearchAction',
        'target' => "#{search_url}?query={search_term_string}",
        'query-input' => 'required name=search_term_string'
      }
    }
  end

  def organization_json_ld
    {
      '@context' => 'https://schema.org',
      '@type' => 'Organization',
      'name' => 'Transbucket.com',
      'url' => request.base_url
    }
  end
end
