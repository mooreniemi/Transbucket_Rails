$(document).ready(function() {
    // disable auto discover
    Dropzone.autoDiscover = false;

    // grap our pin_image form by its id
    $("#new_pin_image").dropzone({
        url: '/pin_images',
        // restrict image size to a maximum 1MB
        maxFilesize: 1,
        // changed the passed param to one accepted by
        // our rails app
        paramName: "pin_image[photo]",
        // show remove links on each image pin_image
        addRemoveLinks: true,
        headers: {
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        }
    });
});