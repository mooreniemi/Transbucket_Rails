$(document).ready(function() {
    // dropzone setup
    var container = document.querySelector('#dropper'),
        template = $('.hide').html();

    if (container) {
        Dropzone.autoDiscover = false;

        var myDropzone = new Dropzone("#dropper", {
            url: '/pin_images',
            maxFilesize: 1,
            previewTemplate: template,
            // changed the passed param to one accepted by
            // our rails app
            paramName: "pin_images",
            // show remove links on each image pin_image
            addRemoveLinks: true,
            headers: {
                'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
            },
            autoProcessQueue: false,
            uploadMultiple: true,
            parallelUploads: 100,
            maxFiles: 10,
            init: function() {
                var submitButton = document.querySelector("#submit-all")
                myDropzone = this; // closure

                submitButton.addEventListener("click", function() {
                    myDropzone.processQueue(); // Tell Dropzone to process all queued files.
                });

                // TODO break this out
                // getting this pin's current pin_images, for edit page
                var pathname = window.location.pathname;
                if (pathname.match(/\/pins\/\d*\/edit/)) {
                    $.getJSON("pin_images.json", function(pinImages) {
                        if (pinImages) {
                            pinImages.forEach(function(pinImage) {
                                myDropzone.addFile.call(myDropzone, pinImage);
                                myDropzone.options.thumbnail.call(myDropzone, pinImage, pinImage.url);
                                $(pinImage.previewElement).prop('id', pinImage.id);
                                $(pinImage.previewElement).children('input').val(pinImage.caption)
                            });
                        }
                    });
                }
            }
        });
        myDropzone.on("success", function(file, responseText) {
            var imageIdList = $('#pin_pin_image_ids');
            // dynamically adding the save pin_image ids to the pin submission form
            imageIdList.val(imageIdList.val() + "," + responseText.id);
        });
        myDropzone.on("sendingmultiple", function(file, xhr, formData) {
            //TODO need to specify per file
            //Add additional data to the upload
            formData.append('pin_images[0]caption', $('.caption').val());
        });
    }
});