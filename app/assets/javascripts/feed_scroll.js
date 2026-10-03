// Infinite scroll for the submissions feed on phones.
//
// The server still renders numbered pages (and the paginator stays for
// desktop and as the no-JS fallback). On phones the paginator is swapped for a
// status line, and when it comes near the bottom of the screen the next page
// is fetched as ordinary HTML and its cards are appended to #pins. Together
// with pin_viewer.js you can scroll, open a pin, close it and carry on without
// ever losing your place.
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

    function appendCards(doc) {
      var seen = {}, added = [];
      Array.prototype.forEach.call(pins.querySelectorAll('.item[data-pin-id]'), function(item) {
        seen[item.getAttribute('data-pin-id')] = true;
      });
      // A pin posted while you scroll shifts every page down by one, so the
      // next page can repeat the last card. Ad slots need their script run,
      // which parsed HTML does not do, so leave them out.
      Array.prototype.forEach.call(doc.querySelectorAll('#pins > .item[data-pin-id]'), function(item) {
        var id = item.getAttribute('data-pin-id');
        if (seen[id]) { return; }
        seen[id] = true;
        var card = document.importNode(item, true);
        pins.appendChild(card);
        added.push(card);
      });
      return added;
    }

    function afterAppend(cards) {
      if (!cards.length) { return; }
      var wrapper = $(cards);
      if (window.formatPinAges) { window.formatPinAges(wrapper); }
      wrapper.find('.label-with-popover').popover();
      cards.forEach(function(card) {
        if (window.recordContentEvents) { window.recordContentEvents(card); }
      });
      var masonry = window.Masonry && window.Masonry.data && window.Masonry.data(pins);
      if (masonry) {
        masonry.appended(cards);
        imagesLoaded(pins, function() { masonry.layout(); });
      }
    }

    function loadMore() {
      var url = nextUrl(paginator);
      if (loading || failed) { return; }
      if (!url) { setStatus('done'); return; }

      loading = true;
      setStatus('loading');
      window.fetch(url, { credentials: 'same-origin', headers: { 'Accept': 'text/html' } })
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
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
