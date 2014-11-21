$(document).ready(function() {
    $("#clear-filter").click(function() {
        $("#filter_dropdown select").val([]);
        $("#filter_dropdown select").trigger('chosen:updated');
    });

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

    // used to explain flagging
    $('.label-with-popover').popover();

    // masonry setup
    var container = document.querySelector('#pins'),
        msnry;
    // initialize Masonry after all images have loaded
    imagesLoaded(container, function() {
        msnry = new Masonry(container);
    });
});
