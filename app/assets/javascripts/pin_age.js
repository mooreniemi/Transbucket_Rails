// Replaces the card footer's "Updated about 3 hours ago" with a short, localized
// "3h ago" (the full sentence stays as the tooltip). Uses the browser's
// Intl.RelativeTimeFormat so every supported language works without extra
// translations; without it the full sentence simply stays. Plain ES5 for Uglifier.
$(document).ready(function () {
  if (typeof Intl === 'undefined' || typeof Intl.RelativeTimeFormat !== 'function') { return; }

  var formatter;
  try {
    formatter = new Intl.RelativeTimeFormat(document.documentElement.lang || undefined, { numeric: 'always', style: 'narrow' });
  } catch (e) {
    return;
  }

  var steps = [
    ['year', 31536000],
    ['month', 2592000],
    ['day', 86400],
    ['hour', 3600],
    ['minute', 60]
  ];

  $('time.pin-age').each(function () {
    var updated = Date.parse(this.getAttribute('datetime'));
    if (isNaN(updated)) { return; }

    var seconds = Math.max(0, Math.round((Date.now() - updated) / 1000));
    var unit = 'minute';
    var amount = 1;
    for (var i = 0; i < steps.length; i++) {
      if (seconds >= steps[i][1]) {
        unit = steps[i][0];
        amount = Math.floor(seconds / steps[i][1]);
        break;
      }
    }
    this.textContent = formatter.format(-amount, unit);
  });
});
