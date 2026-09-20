// Login / sign-up pages: password show-hide toggle, and desktop-only autofocus.
//
// The toggle button ships with the `hidden` attribute (see
// devise/shared/_password_toggle) and is revealed here, so there is never a
// dead button without JavaScript.
(function() {
  function initPasswordToggles() {
    var toggles = document.querySelectorAll('[data-auth-password-toggle]');

    Array.prototype.forEach.call(toggles, function(button) {
      var input = document.getElementById(button.getAttribute('aria-controls'));
      if (!input) { return; }

      button.hidden = false;
      button.addEventListener('click', function() {
        var showing = input.type === 'password';
        var label = button.getAttribute(showing ? 'data-hide-label' : 'data-show-label');
        var icon = button.querySelector('.fa');

        input.type = showing ? 'text' : 'password';
        button.setAttribute('aria-pressed', showing ? 'true' : 'false');
        button.setAttribute('aria-label', label);
        button.title = label;
        if (icon) {
          icon.classList.toggle('fa-eye', !showing);
          icon.classList.toggle('fa-eye-slash', showing);
        }
      });
    });
  }

  // Autofocus on a phone opens the keyboard over the page before anyone has
  // seen it, so only focus the first field with a mouse-and-keyboard setup.
  function initAutofocus() {
    var field = document.querySelector('[data-auth-autofocus]');
    if (field && window.matchMedia && window.matchMedia('(hover: hover) and (pointer: fine)').matches) {
      field.focus();
    }
  }

  function init() {
    initPasswordToggles();
    initAutofocus();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
