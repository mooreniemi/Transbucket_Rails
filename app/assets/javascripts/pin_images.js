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
        var imageIdList = $('#pin_pin_image_ids'),
            captionButton = document.createElement("button"),
            captionInput = document.createElement("input");

        $(captionButton).on("click", function() {
            $.ajax({
                headers: {
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                url: "/pin_images/174.json",
                type: 'PATCH',
                data: JSON.stringify({
                    caption: $(event.target).text()
                }),
                success: function(response, textStatus, jqXhr) {
                    console.log("Pin image Successfully Patched!");
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    // log the error to the console
                    console.log("The following error occured: " + textStatus, errorThrown);
                },
                complete: function() {
                    console.log("Pin image Patch Ran");
                }
            });
        })
        // dynamically adding the save pin_image ids to the pin submission form
        imageIdList.val(imageIdList.val() + "," + responseText.id);

        captionInput.type = "text";
        captionInput.name = "caption_" + responseText.id;
        captionInput.placeholder = "Caption";

        file.previewTemplate.appendChild(captionInput);
        file.previewTemplate.appendChild(captionButton);

    });
});