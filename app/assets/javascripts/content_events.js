// Best-effort activity telemetry. This must never interfere with page rendering
// or navigation: failures are intentionally ignored.
(function() {
  function recordContentEvent(element, eventTypeOverride) {
    var url = element.getAttribute('data-content-event-url');
    var contentType = element.getAttribute('data-content-type');
    var contentId = element.getAttribute('data-content-id');
    var eventType = eventTypeOverride || element.getAttribute('data-event-type');
    var eventContext = parseEventContext(element.getAttribute('data-event-context'));

    if (!url || !contentType || !contentId || !eventType) { return; }

    try {
      var body = 'content_type=' + encodeURIComponent(contentType) +
        '&content_id=' + encodeURIComponent(contentId) +
        '&event_type=' + encodeURIComponent(eventType);
      var context = clientContext();
      Object.keys(context).forEach(function(key) {
        body += '&client_context[' + encodeURIComponent(key) + ']=' + encodeURIComponent(context[key]);
      });
      Object.keys(eventContext).forEach(function(key) {
        body += '&event_context[' + encodeURIComponent(key) + ']=' + encodeURIComponent(eventContext[key]);
      });

      send(url, body);
    } catch (error) {
      // Analytics is optional; do not surface or rethrow telemetry failures.
    }
  }

  function parseEventContext(value) {
    try { return value ? JSON.parse(value) : {}; } catch (error) { return {}; }
  }

  function clientContext() {
    var ua = navigator.userAgent || '';
    var width = window.innerWidth || document.documentElement.clientWidth || 0;
    var connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection || {};
    var browser = /Edg\/([0-9]+)/.exec(ua) || /Firefox\/([0-9]+)/.exec(ua) || /Version\/([0-9]+).*Safari/.exec(ua) || /Chrome\/([0-9]+)/.exec(ua);
    var browserFamily = /Edg\//.test(ua) ? 'Edge' : /Firefox\//.test(ua) ? 'Firefox' : /Version\/.*Safari/.test(ua) ? 'Safari' : /Chrome\//.test(ua) ? 'Chrome' : 'Other';
    var osFamily = /iPhone|iPad|iPod/.test(ua) ? 'iOS' : /Android/.test(ua) ? 'Android' : /Windows/.test(ua) ? 'Windows' : /Mac OS X/.test(ua) ? 'macOS' : /Linux/.test(ua) ? 'Linux' : 'Other';
    return {
      device_class: width < 768 ? 'mobile' : width < 1024 ? 'tablet' : 'desktop',
      browser_family: browserFamily,
      browser_major: browser ? browser[1] : 'unknown',
      os_family: osFamily,
      viewport_bucket: width < 768 ? 'small' : width < 1200 ? 'medium' : 'large',
      beacon: navigator.sendBeacon ? 'yes' : 'no', fetch: window.fetch ? 'yes' : 'no',
      webp: 'unknown', avif: 'unknown', save_data: connection.saveData ? 'yes' : 'no',
      connection_type: connection.effectiveType || 'unknown'
    };
  }

  function recordPageContentEvents() {
    var markers = document.querySelectorAll('[data-content-event]');
    var impressions = [];
    for (var index = 0; index < markers.length; index += 1) {
      if (markers[index].getAttribute('data-event-type') === 'impression') {
        impressions.push(markers[index]);
      } else {
        recordContentEvent(markers[index]);
      }
    }
    recordImpressionBatch(impressions);
  }

  function recordImpressionBatch(markers) {
    if (!markers.length) { return; }
    var url = markers[0].getAttribute('data-content-event-batch-url');
    if (!url) { return; }

    try {
      var body = '', context = clientContext();
      markers.forEach(function(marker, index) {
        var prefix = 'events[' + index + ']', eventContext = parseEventContext(marker.getAttribute('data-event-context'));
        body += prefix + '[content_type]=' + encodeURIComponent(marker.getAttribute('data-content-type')) + '&';
        body += prefix + '[content_id]=' + encodeURIComponent(marker.getAttribute('data-content-id')) + '&';
        body += prefix + '[event_type]=impression&';
        Object.keys(eventContext).forEach(function(key) {
          body += prefix + '[event_context][' + encodeURIComponent(key) + ']=' + encodeURIComponent(eventContext[key]) + '&';
        });
      });
      Object.keys(context).forEach(function(key) {
        body += 'client_context[' + encodeURIComponent(key) + ']=' + encodeURIComponent(context[key]) + '&';
      });
      send(url, body);
    } catch (error) {
      // Analytics is optional; do not surface or rethrow telemetry failures.
    }
  }

  function send(url, body) {
    if (navigator.sendBeacon) {
      navigator.sendBeacon(url, new Blob([body], { type: 'application/x-www-form-urlencoded;charset=UTF-8' }));
    } else if (window.fetch) {
      window.fetch(url, {
        method: 'POST', body: body, credentials: 'same-origin',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' }, keepalive: true
      }).catch(function() {});
    }
  }

  document.addEventListener('click', function(event) {
    var element = event.target;
    while (element && element !== document) {
      if (element.getAttribute && element.getAttribute('data-content-event-open')) {
        recordContentEvent(element, 'open');
        return;
      }
      element = element.parentNode;
    }
  });

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', recordPageContentEvents);
  } else {
    recordPageContentEvents();
  }
})();
