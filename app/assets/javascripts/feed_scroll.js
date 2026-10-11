// Infinite scroll for the submissions feed on phones.
//
// The server still renders numbered pages (and the paginator stays for
// desktop and as the no-JS fallback). On phones the paginator is swapped for a
// status line, and when it comes near the bottom of the screen the next page
// is fetched as ordinary HTML and its cards are appended to #pins. Together
// with pin_viewer.js you can scroll, open a pin, close it and carry on without
// ever losing your place.
//
// Ad slots (ads/_slot) come in with each page like any other card. HTML added
// this way does not run its scripts, so each new slot is started here: Google's
// ad script is loaded if no page has needed it yet, and each slot is started
// exactly once. Slots change size as ads arrive, so the feed lays itself out
// again when one does (Masonry positions the cards, and would let a growing ad
// cover the next card).
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
(function() {
  var PHONE = '(max-width: 767px)';

  function init() {
    var pins = document.getElementById('pins'),
        paginator = document.getElementById('paginator');
    if (!pins || !paginator || !pins.querySelector('.item') || !window.fetch || !window.matchMedia || !window.IntersectionObserver || !window.DOMParser) { return; }

    var loading = false,
        failed = false,
        status = document.createElement('div'),
        observer;

    status.className = 'feed-scroll-status';
    status.setAttribute('role', 'status');
    status.setAttribute('aria-live', 'polite');
    paginator.parentNode.insertBefore(status, paginator.nextSibling);

    function nextUrl(root) {
      var link = root.querySelector('a[rel~="next"]');
      return link ? link.href : null;
    }

    function setStatus(state) {
      var label = paginator.getAttribute('data-' + state + '-label') || '';
      status.className = 'feed-scroll-status is-' + state;
      status.innerHTML = '';
      if (state === 'error') {
        var retry = document.createElement('button');
        retry.type = 'button';
        retry.className = 'btn btn-default';
        retry.textContent = label;
        retry.addEventListener('click', function() { failed = false; loadMore(); });
        status.appendChild(retry);
      } else {
        status.textContent = label;
      }
    }

    // Pins are keyed by id; discussion cards (pins/_feed_item) carry their
    // own data-feed-key, so the two can't collide.
    function cardKey(item) {
      return item.getAttribute('data-feed-key') || ('pin-' + item.getAttribute('data-pin-id'));
    }

    function appendCards(doc) {
      var seen = {}, added = [];
      Array.prototype.forEach.call(pins.querySelectorAll('.item[data-pin-id], .item[data-feed-key]'), function(item) {
        seen[cardKey(item)] = true;
      });
      // A post added while you scroll shifts every page down by one, so the
      // next page can repeat the last card. Ad slots have no key and are never
      // repeats; they stay in place before the card they were rendered with.
      Array.prototype.forEach.call(doc.querySelectorAll('#pins > .item[data-pin-id], #pins > .item[data-feed-key], #pins > .item.ad'), function(item) {
        var isAd = /(^|\s)ad(\s|$)/.test(item.className);
        if (!isAd) {
          var id = cardKey(item);
          if (seen[id]) { return; }
          seen[id] = true;
        }
        var card = document.importNode(item, true);
        if (isAd) { loadAdScript(card); }
        pins.appendChild(card);
        added.push(card);
      });
      return added;
    }

    // Pasted-in scripts do not run, so take them out of an ad slot, and load
    // Google's ad script once if the page does not have it yet (the first page
    // may have had no ad).
    function loadAdScript(card) {
      Array.prototype.forEach.call(card.querySelectorAll('script'), function(script) {
        var src = script.getAttribute('src');
        script.parentNode.removeChild(script);
        if (!src) { return; }
        var present = Array.prototype.some.call(document.getElementsByTagName('script'), function(existing) {
          return existing.getAttribute('src') === src;
        });
        if (present) { return; }
        var loader = document.createElement('script');
        loader.async = true;
        loader.src = src;
        document.head.appendChild(loader);
      });
    }

    // Start each new slot once (Google fills the next slot that has not been
    // started, so this runs after the slot is in the page), and report on it.
    function startAds(cards) {
      cards.forEach(function(card) {
        var slot = card.querySelector('ins.adsbygoogle');
        if (!slot || slot.getAttribute('data-ad-started')) { return; }
        slot.setAttribute('data-ad-started', '1');
        try {
          (window.adsbygoogle = window.adsbygoogle || []).push({});
        } catch (error) {
          // The slot stays empty; ad_tracking.js records that.
        }
        if (window.trackAdSlots) { window.trackAdSlots(card); }
      });
    }

    var layoutQueued = false, resizeObserver = null;

    function masonryOf() {
      return window.Masonry && window.Masonry.data && window.Masonry.data(pins);
    }

    function relayout() {
      if (layoutQueued) { return; }
      layoutQueued = true;
      window.requestAnimationFrame(function() {
        layoutQueued = false;
        var masonry = masonryOf();
        if (masonry) { masonry.layout(); }
      });
    }

    // Lay the feed out again whenever an ad slot changes size.
    function watchAd(item) {
      if (!window.ResizeObserver) { return; }
      if (!resizeObserver) { resizeObserver = new window.ResizeObserver(relayout); }
      resizeObserver.observe(item);
    }

    function afterAppend(cards) {
      if (!cards.length) { return; }
      var wrapper = $(cards);
      if (window.formatPinAges) { window.formatPinAges(wrapper); }
      wrapper.find('.label-with-popover').popover();
      cards.forEach(function(card) {
        if (window.recordContentEvents) { window.recordContentEvents(card); }
      });
      var masonry = masonryOf();
      if (masonry) {
        masonry.appended(cards);
        imagesLoaded(pins, function() { masonry.layout(); });
      }
      startAds(cards);
      cards.forEach(function(card) {
        if (/(^|\s)ad(\s|$)/.test(card.className)) { watchAd(card); }
      });
    }

    function loadMore() {
      var url = nextUrl(paginator);
      if (loading || failed) { return; }
      if (!url) { setStatus('done'); return; }

      loading = true;
      setStatus('loading');
      // fragment=1: only the cards and the page links, no header or footer.
      window.fetch(url + (url.indexOf('?') === -1 ? '?' : '&') + 'fragment=1', { credentials: 'same-origin', headers: { 'Accept': 'text/html' } })
        .then(function(response) {
          if (!response.ok) { throw new Error('HTTP ' + response.status); }
          return response.text();
        })
        .then(function(html) {
          var doc = new DOMParser().parseFromString(html, 'text/html'),
              nextPaginator = doc.getElementById('paginator');
          afterAppend(appendCards(doc));
          paginator.innerHTML = nextPaginator ? nextPaginator.innerHTML : '';
          loading = false;
          setStatus(nextUrl(paginator) ? 'idle' : 'done');
          // A short page can leave the status line on screen, and the
          // observer only fires on changes, so check again.
          observer.unobserve(status);
          observer.observe(status);
        })
        .catch(function() {
          loading = false;
          failed = true;
          setStatus('error');
        });
    }

    observer = new IntersectionObserver(function(entries) {
      if (entries[0].isIntersecting && window.matchMedia(PHONE).matches) { loadMore(); }
    }, { rootMargin: '0px 0px 1200px 0px' });

    document.documentElement.className += ' feed-infinite';
    setStatus(nextUrl(paginator) ? 'idle' : 'done');
    observer.observe(status);
    Array.prototype.forEach.call(pins.querySelectorAll('.item.ad'), watchAd);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
