// Fit each feed card's photo to its 4:3 box once the photo has loaded.
//
// The box keeps a fixed shape so cards never move as photos arrive (Masonry
// relies on that too). A photo close to that shape fills the box, losing at
// most a thin strip at the edges; the full photo is one tap away in the pin.
// A much taller or wider photo is shown whole, and the empty sides get a
// blurred, enlarged copy of the same photo instead of flat grey.
// ES5 only: the asset pipeline's minifier cannot parse newer syntax.
(function() {
  var BOX_RATIO = 4 / 3,
      // 0.8-1.25 times the box's shape means cropping at most 20% of a side.
      MAX_STRETCH = 1.25;

  function fit(img) {
    var box = img.parentNode && img.parentNode.parentNode;
    if (!box || !/(^|\s)pin-card-image(\s|$)/.test(box.className) || !img.naturalWidth || !img.naturalHeight) { return; }
    if (/(^|\s)(is-filled|has-backdrop)(\s|$)/.test(box.className)) { return; }

    var stretch = (img.naturalWidth / img.naturalHeight) / BOX_RATIO;
    if (stretch < 1) { stretch = 1 / stretch; }

    if (stretch <= MAX_STRETCH) {
      box.className += ' is-filled';
    } else {
      box.style.setProperty('--card-backdrop', 'url("' + (img.currentSrc || img.src).replace(/"/g, '%22') + '")');
      box.className += ' has-backdrop';
    }
  }

  function fitWithin(root) {
    Array.prototype.forEach.call((root || document).querySelectorAll('.pin-card-image > a > img'), function(img) {
      if (img.complete) { fit(img); }
    });
  }

  // load does not bubble, but it can be caught on the way down, which covers
  // photos on cards that infinite scroll adds later.
  document.addEventListener('load', function(event) {
    var img = event.target;
    if (img.nodeName === 'IMG' && img.parentNode && img.parentNode.nodeName === 'A') { fit(img); }
  }, true);

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() { fitWithin(); });
  } else {
    fitWithin();
  }
})();
