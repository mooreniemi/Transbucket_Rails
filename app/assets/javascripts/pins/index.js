$(document).ready(function() {
  $("#clear-filter").click(function() {
    $("#filter_dropdown select").val([]);
    $("#filter_dropdown select").trigger('chosen:updated');
    // FIXME: hard coding the pins path here
    window.history.pushState("cleared filter", "Submissions", "/" + document.documentElement.lang + "/pins");
  });

  $("#scope").chosen({
    width: "100%",
    placeholder_text_multiple: "General tags"
  })

  $("#procedure").chosen({
    width: "100%",
    placeholder_text_multiple: "Procedures"
  });

  $("#surgeon").chosen({
    width: "100%",
    placeholder_text_multiple: "Surgeons"
  });

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
