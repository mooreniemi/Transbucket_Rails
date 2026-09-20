// Server renders comment timestamps as the true UTC instant, localized in
// wording/format via I18n (see comments/_comment.html.erb). Browsers that
// support Intl get the extra step of having that instant reformatted in the
// viewer's own local clock, since the server has no stored per-user timezone
// to render against directly.
//
// The Intl locale here is the page's own locale (<html lang>), not
// navigator.language -- the timestamp should stay in whatever language the
// rest of the page is in, not flip to the visitor's browser language. Local
// timezone conversion still happens automatically since it's controlled by
// the separate (omitted) timeZone option, independent of the locale used.
function localizeTimes() {
  if (typeof Intl === 'undefined' || !Intl.DateTimeFormat) { return; }

  var pageLocale = document.documentElement.lang || navigator.language;

  $('time.local-time[datetime]').each(function() {
    var iso = this.getAttribute('datetime');
    var date = new Date(iso);
    if (!iso || isNaN(date.getTime())) { return; }

    try {
      this.textContent = new Intl.DateTimeFormat(pageLocale, {
        year: 'numeric', month: 'long', day: 'numeric',
        hour: 'numeric', minute: '2-digit'
      }).format(date);
    } catch (e) {}
  });
}

$(document).ready(localizeTimes);
$(document).on('page:load', localizeTimes);
