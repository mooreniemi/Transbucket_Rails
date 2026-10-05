// Phone header search (layouts/_header, _search): below 768px the search field
// is an icon until tapped, then it takes over the top bar with the keyboard up,
// and Cancel or Escape puts the bar back. Without this script the field just
// stays open in the bar, as it always used to. Desktop is untouched.
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
(function() {
  function init() {
    var nav = document.querySelector('.navbar-signed-in'),
        openButton = nav && nav.querySelector('.header-search-open'),
        form = nav && nav.querySelector('#header-search');
    if (!openButton || !form) { return; }

    var field = form.querySelector('#query'),
        cancel = form.querySelector('.header-search-cancel');

    nav.className += ' search-collapsible';

    function setOpen(open) {
      nav.className = nav.className.replace(/(^|\s)is-searching(?=\s|$)/g, '') + (open ? ' is-searching' : '');
      openButton.setAttribute('aria-expanded', open ? 'true' : 'false');
      if (open) {
        field.focus();
      } else {
        openButton.focus({ preventScroll: true });
      }
    }

    openButton.addEventListener('click', function() { setOpen(true); });
    if (cancel) { cancel.addEventListener('click', function() { setOpen(false); }); }
    form.addEventListener('keydown', function(event) {
      if (event.key === 'Escape' || event.keyCode === 27) { setOpen(false); }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
