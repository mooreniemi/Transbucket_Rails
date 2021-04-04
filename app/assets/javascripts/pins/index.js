$(document).ready(function() {
  console.log("pins/index.js");

  $("#clear-filter").click(function() {
    $("#filter_dropdown select").val([]);
    $("#filter_dropdown select").trigger('chosen:updated');
    // FIXME: hard coding the pins path here
    window.history.pushState("cleared filter", "Submissions", "/pins");
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
    // initialize Masonry after all images have loaded
    imagesLoaded(container, function() {
      // https://masonry.desandro.com/options.html
      msnry = new Masonry(container, {});
    });
  }
});
