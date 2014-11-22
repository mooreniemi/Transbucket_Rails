$(document).ready(function() {
    Dropzone.autoDiscover = false;
    var myDropzone = new Dropzone("#dropper", {
        url: '/pin_images',
        maxFilesize: 1,
        // changed the passed param to one accepted by
        // our rails app
        paramName: "pin_image[photo]",
        // show remove links on each image pin_image
        addRemoveLinks: true,
        headers: {
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        autoProcessQueue: true,
        uploadMultiple: true,
        parallelUploads: 100,
        maxFiles: 10
    });
    myDropzone.on("success", function(file, responseText) {
        // Handle the responseText here. For example, add the text to the preview element:
        var element = $('#pin_pin_image_ids');
        element.val(element.val() + "," + responseText.id);
    });
});