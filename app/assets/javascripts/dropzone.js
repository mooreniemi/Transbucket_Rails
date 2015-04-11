$(document).ready(function() {
    // dropzone setup
    var container = document.querySelector('#dropper'),
        template = $('.hide').html(),
        counter = -1;

    if (container) {
        Dropzone.autoDiscover = false;
        var myDropzone = new Dropzone("#dropper", {
            url: '/pin_images',
            maxFilesize: 1,
            previewTemplate: template,
            // changed the passed param to one accepted by
            // our rails app
            paramName: function(n) {
                return "pin_images[" + n + "][photo]"
            },
            // show remove links on each image pin_image
            // params: {
            //     caption: "doodle"
            // },
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
        myDropzone.on("addedfile", function(file) {
            $(".dz-preview:last-child").attr('id', "LM-" + file.lastModified);
        });
        myDropzone.on("sending", function(file, xhr, formData) {
            counter += 1
            formData.append('pin_images[' + counter + ']caption', $('#LM-'+file.lastModified+' .caption').val());
        });
    }
});