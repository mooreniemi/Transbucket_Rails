// The feed toolbar (pins/index, pins/_toolbar_actions): Filter and + Discussion
// each open a form above the feed, one at a time. The discussion form posts in
// place (DiscussionsController#create answers with the new card, or the form
// with what to fix) and the card goes to the top of the feed. On phones the
// same buttons float at the bottom once the toolbar has scrolled away; their
// Filter and Discussion scroll back up and open the form there.
// Without this script Bootstrap still opens the panels and the form posts as
// a normal page. ES5 only: the asset pipeline's minifier cannot parse newer
// syntax.
(function() {
  function init() {
    var toolbar = document.getElementById('feed-toolbar');
    if (!toolbar || !window.jQuery) { return; }
    var $ = window.jQuery,
        panels = ['feed-filter-panel', 'feed-compose-panel'],
        compose = document.getElementById('feed-compose-panel'),
        dock = document.querySelector('.feed-dock');

    // One form at a time: opening one closes the other.
    panels.forEach(function(id) {
      $('#' + id).on('show.bs.collapse', function() {
        panels.forEach(function(other) {
          if (other !== id) { $('#' + other + '.in').collapse('hide'); }
        });
      });
    });

    if (compose) {
      $(compose).on('shown.bs.collapse', focusTitle);

      // Arrived from Start a discussion in the menu (?compose=1): the form is
      // already open, so put the cursor in it.
      if ($(compose).hasClass('in')) { focusTitle(); }

      // Start a discussion in the menu while already on the feed: open the
      // form here instead of reloading the page.
      document.addEventListener('click', function(event) {
        var link = event.target.closest && event.target.closest('[data-open-compose]');
        if (!link) { return; }
        event.preventDefault();
        hideWhenOpen($('.navbar-collapse.in, .navbar-collapse.collapsing'));
        toolbar.scrollIntoView({ block: 'start' });
        if ($(compose).hasClass('in')) { focusTitle(); } else { $(compose).collapse('show'); }
      });
      compose.addEventListener('submit', function(event) {
        var form = event.target;
        if (!form.classList || !form.classList.contains('discussion-form') || !window.fetch || !window.FormData) { return; }
        event.preventDefault();
        post(form);
      });
    }

    // Without scrolling: the dock or the menu may be scrolling the page up.
    function focusTitle() {
      var title = compose && compose.querySelector('.discussion-title-input');
      if (title) { title.focus({ preventScroll: true }); }
    }

    // Bootstrap ignores hide while a panel (or the menu) is still opening.
    function hideWhenOpen($panel) {
      var collapse = $panel.data('bs.collapse');
      if (collapse && collapse.transitioning) {
        $panel.one('shown.bs.collapse', function() { $panel.collapse('hide'); });
      } else {
        $panel.collapse('hide');
      }
    }

    function closeCompose() {
      hideWhenOpen($(compose));
    }

    function post(form) {
      var submit = form.querySelector('[type=submit]');
      if (submit) { submit.disabled = true; }
      window.fetch(form.action, {
        method: 'POST',
        body: new FormData(form),
        credentials: 'same-origin',
        headers: { 'X-Requested-With': 'XMLHttpRequest', 'Accept': 'text/html' }
      }).then(function(response) {
        return response.text().then(function(html) { return { status: response.status, html: html }; });
      }).then(function(result) {
        if (result.status === 201) {
          addCard(result.html);
          form.reset();
          closeCompose();
        } else if (result.status === 422) {
          // The form again, with what to fix.
          form.parentNode.innerHTML = result.html;
          var first = compose.querySelector('.control-group.error input, .control-group.error textarea');
          if (first) { first.focus(); }
        } else {
          throw new Error('HTTP ' + result.status);
        }
      }).catch(function() {
        // Fall back to the ordinary page rather than losing what was typed.
        form.submit();
      }).then(function() {
        if (submit) { submit.disabled = false; }
      });
    }

    function addCard(html) {
      var pins = document.getElementById('pins');
      if (!pins) { return; }
      var holder = document.createElement('div');
      holder.innerHTML = html.trim();
      var card = holder.firstElementChild;
      if (!card) { return; }
      pins.insertBefore(card, pins.firstChild);
      var masonry = window.Masonry && window.Masonry.data && window.Masonry.data(pins);
      if (masonry) { masonry.prepended([card]); }
      if (window.formatPinAges) { window.formatPinAges(card); }
      if (window.recordContentEvents) { window.recordContentEvents(card); }
      card.classList.add('is-new');
      card.scrollIntoView({ block: 'center' });
    }

    if (dock) { initDock(); }

    function initDock() {
      // Shown only on phones (CSS), once the toolbar is above the screen.
      if (window.IntersectionObserver) {
        new window.IntersectionObserver(function(entries) {
          var entry = entries[0];
          dock.hidden = entry.isIntersecting || entry.boundingClientRect.top > 0;
        }).observe(toolbar);
      }

      dock.addEventListener('click', function(event) {
        var button = event.target.closest && event.target.closest('[data-feed-dock-open]');
        if (!button) { return; }
        event.preventDefault();
        var panel = document.getElementById(button.getAttribute('data-feed-dock-open'));
        var smooth = !window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        toolbar.scrollIntoView({ behavior: smooth ? 'smooth' : 'auto', block: 'start' });
        if (panel && !$(panel).hasClass('in')) { $(panel).collapse('show'); }
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
