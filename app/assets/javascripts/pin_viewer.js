// Phone pin viewer: tapping a card in the feed opens the pin in a full-screen
// layer over the feed instead of loading a new page, so closing it drops you
// back exactly where you were (like Instagram). Discussion cards
// (pins/_feed_item) open their discussion page (comments/show) the same way;
// ?reply_to=<id> on their Reply link opens that comment's reply box.
//
// The pin's own URL is pushed onto the history, so the system back button or
// gesture closes the viewer, sharing or reloading gives the real pin page, and
// forward reopens it. The content is the normal pin page rendered without the
// layout (PinsController#show with ?viewer=1; likewise comments/show and
// discussions/show), so comments, safe mode and
// analytics behave the same as on the full page.
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
(function() {
  var PHONE = '(max-width: 767px)',
      PIN_PATH = /\/pins\/[^\/]+\/?$/,
      // Discussions on a procedure or surgeon (comments/show) and standalone
      // ones (discussions/show).
      DISCUSSION_PATH = /\/(comments|discussions)\/\d+\/?$/;

  function init() {
    var pins = document.getElementById('pins');
    if (!pins || !window.fetch || !window.matchMedia || !window.history.pushState) { return; }

    var paginator = document.getElementById('paginator'),
        closeLabel = (paginator && paginator.getAttribute('data-close-label')) || 'Close',
        feedTitle = document.title,
        feedUrl = window.location.href,
        viewer, bar, title, body, closeButton,
        isOpen = false,
        pushed = false,
        returnFocus = null,
        request = 0;

    function build() {
      viewer = document.createElement('div');
      viewer.className = 'pin-viewer';
      viewer.setAttribute('role', 'dialog');
      viewer.setAttribute('aria-modal', 'true');
      viewer.setAttribute('aria-labelledby', 'pin-viewer-title');
      viewer.hidden = true;

      bar = document.createElement('div');
      bar.className = 'pin-viewer-bar';
      closeButton = document.createElement('button');
      closeButton.type = 'button';
      closeButton.className = 'pin-viewer-close';
      closeButton.setAttribute('aria-label', closeLabel);
      closeButton.title = closeLabel;
      closeButton.innerHTML = '<i class="fa fa-arrow-left" aria-hidden="true"></i>';
      title = document.createElement('h2');
      title.id = 'pin-viewer-title';
      title.className = 'pin-viewer-title';
      bar.appendChild(closeButton);
      bar.appendChild(title);

      body = document.createElement('div');
      body.className = 'pin-viewer-body';

      viewer.appendChild(bar);
      viewer.appendChild(body);
      document.body.appendChild(viewer);

      closeButton.addEventListener('click', requestClose);
      viewer.addEventListener('click', function(event) {
        // The pin page's own "back to submissions" arrow.
        var back = closest(event.target, function(node) { return node.hasAttribute('data-pin-viewer-close'); });
        if (back) {
          event.preventDefault();
          requestClose();
        }
      });
    }

    function closest(node, test) {
      while (node && node !== document && node.nodeType === 1) {
        if (test(node)) { return node; }
        node = node.parentNode;
      }
      return null;
    }

    function viewerUrl(url) {
      var bare = url.split('#')[0];
      return bare + (bare.indexOf('?') === -1 ? '?' : '&') + 'viewer=1';
    }

    function spinner() {
      return '<div class="pin-viewer-loading"><i class="fa fa-spinner fa-spin fa-2x" aria-hidden="true"></i></div>';
    }

    function open(url, label, fromHistory) {
      if (!viewer) { build(); }
      var token = ++request,
          hash = url.indexOf('#') === -1 ? '' : url.slice(url.indexOf('#') + 1);

      title.textContent = label || '';
      body.innerHTML = spinner();
      body.scrollTop = 0;
      viewer.hidden = false;
      document.documentElement.className += ' pin-viewer-open';
      isOpen = true;
      if (!fromHistory) {
        window.history.pushState({ pinViewer: url }, '', url);
        pushed = true;
      }
      closeButton.focus();

      window.fetch(viewerUrl(url), { credentials: 'same-origin', headers: { 'Accept': 'text/html' } })
        .then(function(response) {
          if (!response.ok) { throw new Error('HTTP ' + response.status); }
          return response.text();
        })
        .then(function(html) {
          if (token !== request || !isOpen) { return; }
          body.innerHTML = html;
          var heading = body.querySelector('.pin-page-title');
          if (heading) {
            title.textContent = heading.textContent;
            document.title = heading.textContent + ' - Transbucket.com';
          }
          if (window.recordContentEvents) { window.recordContentEvents(body); }
          if (window.formatPinAges) { window.formatPinAges(body); }
          if (window.syncCommentForms) { window.syncCommentForms(body); }
          openRequestedReply(url);
          focusComposer(hash);
          var target = hash && document.getElementById(hash);
          if (target && body.contains(target)) {
            // Again once the photos above it have loaded and pushed it down,
            // unless you have started scrolling yourself by then.
            target.scrollIntoView();
            var landed = body.scrollTop;
            imagesLoaded(body, function() {
              if (token === request && isOpen && body.scrollTop === landed) { target.scrollIntoView(); }
            });
          }
        })
        .catch(function() {
          if (token !== request || !isOpen) { return; }
          // Fall back to the ordinary page rather than a dead end.
          window.location.href = url;
        });
    }

    // A discussion card's Reply asks for the reply box: tap that comment's own
    // Reply (comments/new.js.erb opens the box and focuses it).
    function openRequestedReply(url) {
      var match = url.match(/[?&]reply_to=(\d+)/);
      var comment = match && document.getElementById('comment-' + match[1]);
      if (!comment || !body.contains(comment)) { return; }
      var actions = comment.querySelector('.comment-actions');
      var reply = actions && actions.querySelector('.comment-reply');
      if (reply) { reply.click(); }
    }

    // A standalone discussion card's Reply points at its reply box.
    function focusComposer(hash) {
      if (hash !== 'commentable') { return; }
      var box = body.querySelector('#commentable textarea');
      if (box) { box.focus({ preventScroll: true }); }
    }

    function cardLabel(card) {
      var description = card.querySelector('.description, .feed-discussion-topic');
      return description ? description.textContent.replace(/\s+/g, ' ').trim() : '';
    }

    function hide() {
      if (!isOpen) { return; }
      request++;
      isOpen = false;
      pushed = false;
      viewer.hidden = true;
      body.innerHTML = '';
      document.documentElement.className = document.documentElement.className.replace(/(^|\s)pin-viewer-open(?=\s|$)/g, '');
      document.title = feedTitle;
      if (returnFocus && document.body.contains(returnFocus)) {
        returnFocus.focus({ preventScroll: true });
      }
    }

    // Closing goes through the history when we added an entry, so the back
    // button and the close button always agree about where you are.
    function requestClose() {
      if (pushed) {
        window.history.back();
      } else {
        hide();
        window.history.replaceState(null, '', feedUrl);
      }
    }

    pins.addEventListener('click', function(event) {
      if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) { return; }
      if (!window.matchMedia(PHONE).matches) { return; }
      var link = closest(event.target, function(node) { return node.nodeName === 'A'; });
      if (!link || link.hasAttribute('data-method') || link.hasAttribute('data-remote')) { return; }
      if (link.host !== window.location.host) { return; }
      var isPin = PIN_PATH.test(link.pathname),
          isDiscussion = DISCUSSION_PATH.test(link.pathname);
      if (!isPin && !isDiscussion) { return; }
      var card = closest(link, function(node) {
        return isPin ? node.hasAttribute('data-pin-id') : node.hasAttribute('data-feed-key');
      });
      if (!card) { return; }

      event.preventDefault();
      // Hand focus back on close only to keyboard users (a click with no
      // pointer detail); after a tap it would just draw a focus ring.
      returnFocus = event.detail === 0 ? link : null;
      open(link.href, cardLabel(card));
    });

    window.addEventListener('popstate', function(event) {
      var state = event.state;
      if (state && state.pinViewer) {
        open(state.pinViewer, '', true);
        pushed = true;
      } else {
        hide();
      }
    });

    document.addEventListener('keydown', function(event) {
      if (isOpen && (event.key === 'Escape' || event.key === 'Esc')) { requestClose(); }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
