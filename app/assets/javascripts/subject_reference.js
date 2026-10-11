// The reference sections on procedure pages (<details data-open-on-desktop>)
// start closed on phones, where they would push the submissions and stats a
// long way down, and open on wider screens.
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
$(function() {
  if (!window.matchMedia || !window.matchMedia('(min-width: 768px)').matches) { return; }
  Array.prototype.forEach.call(document.querySelectorAll('details[data-open-on-desktop]'), function(details) {
    details.open = true;
  });
});
