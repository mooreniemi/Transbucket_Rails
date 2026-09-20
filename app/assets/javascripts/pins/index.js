$(document).ready(function() {
  // Desktop uses Chosen. Phones and tablets get touch_picker.js instead (Chosen
  // switches itself off on phones, but not on tablets).
  if (!(window.TouchPicker && window.TouchPicker.shouldUse())) {
    $("#scope").chosen({
      width: "100%",
      placeholder_text_multiple: "General tags"
    });

    $("#procedure").chosen({
      width: "100%",
      placeholder_text_multiple: "Procedures"
    });

    $("#surgeon").chosen({
      width: "100%",
      placeholder_text_multiple: "Surgeons"
    });
  }

  // used to explain flagging
  $('.label-with-popover').popover();

  // masonry setup
  var container = document.querySelector('#pins'),
    msnry;

  // TODO hack
  if (container) {
    // Card boxes have stable dimensions, so position them immediately and
    // only refresh after image loading in case intrinsic content changes.
    msnry = new Masonry(container, {});
    imagesLoaded(container, function() {
      msnry.layout();
    });
  }
});
