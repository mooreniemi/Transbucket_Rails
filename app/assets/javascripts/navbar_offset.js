// Keep page content clear of the fixed navbar when it wraps.
//
// <body> reserves a fixed 60px under the fixed top navbar (styles.css.scss),
// which is right while the navbar is a single row. At tablet and small-laptop
// widths the signed-in navbar (seven links plus search and menus) wraps to two
// rows (about 101px) and covered the top of every page. From 768px up, follow
// the navbar's real height; below that the navbar is one row above a collapsed
// menu that overlays the page, so the stylesheet's 60px stays.
(function() {
  var TABLET_AND_UP = 768;

  function syncOffset() {
    var navbar = document.querySelector('.navbar-fixed-top');
    if (!navbar) { return; }

    if (window.innerWidth >= TABLET_AND_UP) {
      document.body.style.paddingTop = (navbar.offsetHeight + 10) + 'px';
    } else {
      document.body.style.paddingTop = '';
    }
  }

  function init() {
    syncOffset();
    window.addEventListener('resize', syncOffset);
    window.addEventListener('load', syncOffset);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
