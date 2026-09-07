module ApplicationHelper
  def seo_meta(description:, canonical: nil, noindex: false)
    robots = noindex ? 'noindex,follow' : 'index,follow'

    set_meta_tags(
      description: description,
      canonical: canonical,
      robots: robots
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
    {
      '@context' => 'https://schema.org',
      '@type' => 'WebSite',
      'name' => 'Transbucket.com',
      'url' => request.base_url,
      'potentialAction' => {
        '@type' => 'SearchAction',
        'target' => "#{request.base_url}/pins?query={search_term_string}",
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
