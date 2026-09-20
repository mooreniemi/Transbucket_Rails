module ApplicationHelper
  # Pin submission is a focused workflow. Keep every state of that workflow
  # (including validation failures rendered by create/update) free of ads.
  # This guard lives at the ad partials rather than only in the form templates,
  # so a future shared view cannot accidentally reintroduce an ad there.
  def ads_allowed?
    !(controller_path == 'pins' && %w[new edit create update].include?(action_name))
  end

  def display_complication_rate(complication)
    rate = complication[:rate].to_i
    return '<1%' if rate.zero? && complication[:count].to_i.positive?

    "#{rate}%"
  end

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
      tag(:link, rel: 'alternate', hreflang: locale, href: url_for(request.query_parameters.merge(locale: locale, only_path: false)))
    end
    links << tag(:link, rel: 'alternate', hreflang: 'x-default', href: url_for(request.query_parameters.merge(locale: 'en', only_path: false)))
    safe_join(links, "\n")
  end

  def seo_meta(description:, title: nil, canonical: nil, noindex: false, image: nil, type: 'website')
    robots = noindex ? 'noindex,follow' : 'index,follow'
    canonical ||= "#{request.base_url}#{request.path}"

    set_meta_tags(
      description: description,
      canonical: canonical,
      robots: robots,
      og: { title: title, description: description, url: canonical, type: type, image: image }.compact,
      twitter: { title: title, description: description, image: image }.compact
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
