// Safe mode: images arrive blurred (safe_blur.css.scss) with a "tap to reveal"
// button on top. Tapping the button lifts the blur on that one image. The tap
// is swallowed, so it neither follows the image's link nor counts as an "open".
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
(function() {
  function closest(node, test) {
    while (node && node !== document) {
      if (node.nodeType === 1 && test(node)) { return node; }
      node = node.parentNode;
    }
    return null;
  }

  function boxOf(node) {
    return closest(node, function(candidate) { return /(^|\s)safe-blur(\s|$)/.test(candidate.className); });
  }

  document.addEventListener('click', function(event) {
    var reveal = closest(event.target, function(node) { return node.getAttribute('data-safe-reveal') !== null; });
    var hide = reveal ? null : closest(event.target, function(node) { return node.getAttribute('data-safe-hide') !== null; });
    var box = boxOf(reveal || hide);
    if (!box) { return; }

    event.preventDefault();
    event.stopPropagation();

    if (reveal) {
      box.className += ' is-revealed';
      // The button is gone now; keep keyboard users on something useful.
      var link = box.querySelector('a');
      if (link && link.focus) { link.focus(); }
    } else {
      // Blur it again, and put focus back on the button that lifts the blur.
      box.className = box.className.replace(/(^|\s)is-revealed(?=\s|$)/g, '');
      var again = box.querySelector('[data-safe-reveal]');
      if (again && again.focus) { again.focus(); }
    }
  }, true);
})();
