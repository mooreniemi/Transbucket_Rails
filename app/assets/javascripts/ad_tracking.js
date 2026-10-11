// Records how our ad slots fare, into our own events (ContentEvent, a 'Page'
// event for the 'ad_slot' target; see TrackedTarget and ContentEventRecorder).
//
// Each slot (ads/_slot) is wrapped in [data-ad-slot-tracking]. Once it has
// settled we send one 'impression' whose status says what happened:
//   filled, unfilled, unfill-optimized   what Google reports (data-ad-status)
//   hidden          something on the visitor's side hid the slot (an ad blocker)
//   script_blocked  Google's ad script never loaded (blocked or offline)
//   no_response     the script loaded but never answered within a few seconds
// A filled ad that stays at least half on screen for a second also sends a
// 'view'. Nothing about the ad itself is recorded, and a failure here never
// affects the page.
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
(function() {
  var DEFAULTS = { pollMs: 400, giveUpMs: 6000, viewMs: 1000 };

  function settings(options) {
    var merged = {};
    Object.keys(DEFAULTS).forEach(function(key) {
      merged[key] = options && typeof options[key] === 'number' ? options[key] : DEFAULTS[key];
    });
    return merged;
  }

  // The slot's state once it is known, otherwise null (still waiting).
  function settledStatus(ins) {
    var style = window.getComputedStyle(ins);
    if (style.display === 'none' || style.visibility === 'hidden' || ins.getBoundingClientRect().width === 0) {
      return 'hidden';
    }
    return ins.getAttribute('data-ad-status') || null;
  }

  // Statuses that mean no ad will appear in the slot.
  var EMPTY = ['unfilled', 'unfill-optimized', 'hidden', 'script_blocked'];

  // A feed slot (.pin-ad-slot) that will stay empty gives back its space, so
  // there is no blank gap between cards.
  function collapseIfEmpty(wrapper, status) {
    if (EMPTY.indexOf(status) === -1) { return; }
    var node = wrapper.parentNode;
    while (node && node !== document) {
      if (node.className && /(^|\s)pin-ad-slot(\s|$)/.test(node.className)) {
        node.className += ' ad-collapsed';
        return;
      }
      node = node.parentNode;
    }
  }

  function send(wrapper, eventType, status) {
    if (!window.recordContentEvent) { return; }
    try {
      var marker = document.createElement('div');
      marker.setAttribute('data-content-event-url', wrapper.getAttribute('data-content-event-url'));
      marker.setAttribute('data-content-type', 'Page');
      marker.setAttribute('data-content-id', wrapper.getAttribute('data-content-id'));
      marker.setAttribute('data-event-context', JSON.stringify({
        surface: wrapper.getAttribute('data-ad-surface') || '',
        status: status
      }));
      window.recordContentEvent(marker, eventType);
    } catch (error) {
      // Tracking is optional.
    }
  }

  function watchViewable(ins, wrapper, config) {
    if (!window.IntersectionObserver) { return; }
    var timer = null, sent = false, observer;
    observer = new IntersectionObserver(function(entries) {
      var entry = entries[entries.length - 1];
      var visible = entry.isIntersecting && entry.intersectionRatio >= 0.5;
      if (visible && !timer && !sent) {
        timer = setTimeout(function() {
          timer = null;
          if (document.hidden) { return; }
          sent = true;
          observer.disconnect();
          send(wrapper, 'view', 'filled');
        }, config.viewMs);
      } else if (!visible && timer) {
        clearTimeout(timer);
        timer = null;
      }
    }, { threshold: [0, 0.5, 1] });
    observer.observe(ins);
  }

  function watch(wrapper, ins, config) {
    var started = new Date().getTime(), done = false;

    function finish(status) {
      if (done) { return; }
      done = true;
      collapseIfEmpty(wrapper, status);
      send(wrapper, 'impression', status);
      if (status === 'filled') { watchViewable(ins, wrapper, config); }
    }

    function poll() {
      if (done) { return; }
      var status = settledStatus(ins);
      if (status) { finish(status); return; }
      if (new Date().getTime() - started >= config.giveUpMs) {
        finish(window.adsbygoogle && window.adsbygoogle.loaded ? 'no_response' : 'script_blocked');
        return;
      }
      setTimeout(poll, config.pollMs);
    }

    setTimeout(poll, config.pollMs);
  }

  // Also called for slots added to the page later, and by specs with short waits.
  window.trackAdSlots = function(root, options) {
    var config = settings(options);
    var wrappers = (root || document).querySelectorAll('[data-ad-slot-tracking]:not([data-ad-tracked])');
    Array.prototype.forEach.call(wrappers, function(wrapper) {
      var ins = wrapper.querySelector('ins.adsbygoogle');
      if (!ins) { return; }
      wrapper.setAttribute('data-ad-tracked', '1');
      watch(wrapper, ins, config);
    });
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() { window.trackAdSlots(); });
  } else {
    window.trackAdSlots();
  }
})();
