// Rails rejects any non-GET request without its CSRF token. The Rails shell
// renders it into <meta> tags (csrf_meta_tags).
function metaContent(name: string) {
  return document.querySelector(`meta[name="${name}"]`)?.getAttribute('content')
}

export function csrfParam() {
  return metaContent('csrf-param') ?? 'authenticity_token'
}

export function csrfToken() {
  return metaContent('csrf-token') ?? ''
}
