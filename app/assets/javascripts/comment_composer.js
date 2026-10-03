// Comment box behaviour (comments/_form.html.erb).
//
// The box under a pin's comments starts as a single line and opens when you
// tap into it; it closes again if you leave it empty. A reply form opens
// already open, with the cursor in it. Post is greyed out until there is
// something to post. Return is a new line (comments here run to paragraphs);
// Ctrl+Return or ⌘+Return posts, as on most sites.
//
// Everything is delegated from the document, so forms that arrive later (the
// phone pin viewer, reply forms) work without setup.
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
(function() {
  function formOf(node) {
    return $(node).closest('[data-comment-form]');
  }

  function isBlank(form) {
    return $.trim(form.find('textarea').val() || '') === '';
  }

  function syncButton(form) {
    form.find('input[type=submit]').prop('disabled', isBlank(form));
  }

  function collapsible(form) {
    return form.closest('.comment-composer').length > 0;
  }

  $(document)
    .on('focusin', '[data-comment-form] textarea', function() {
      formOf(this).addClass('is-open');
    })
    .on('focusout', '[data-comment-form] textarea', function() {
      var form = formOf(this);
      if (collapsible(form) && isBlank(form)) { form.removeClass('is-open'); }
    })
    .on('input', '[data-comment-form] textarea', function() {
      syncButton(formOf(this));
    })
    .on('keydown', '[data-comment-form] textarea', function(event) {
      if ((event.key === 'Enter' || event.keyCode === 13) && (event.ctrlKey || event.metaKey)) {
        var form = formOf(this);
        event.preventDefault();
        if (!isBlank(form)) { form.find('form').trigger('submit'); }
      }
    })
    // jquery-ujs turns the button back on when the request finishes, even
    // though the box has just been emptied; put it back the way the box says.
    .on('ajax:complete', '[data-comment-form]', function() {
      var form = $(this);
      setTimeout(function() { syncButton(form); }, 0);
    });

  // Grey out Post on forms in the page as it loads; code that adds a form
  // later (the pin viewer, reply forms) calls this for it.
  function syncAll(root) {
    $(root || document).find('[data-comment-form]').each(function() { syncButton($(this)); });
  }
  window.syncCommentForms = syncAll;

  $(function() { syncAll(); });
})();
