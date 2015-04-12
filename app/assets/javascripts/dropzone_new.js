$(document).ready(function() {
    // dropzone setup
    var container = document.querySelector('#dropper'),
        template = $('.hide').html(),
        queueCounter = -1;

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
            }
        });
        myDropzone.on("addedfile", function(file) {
            $(".dz-preview:last-child").attr('id', "LM-" + file.lastModified);
        });
        myDropzone.on("sending", function(file, xhr, formData) {
            var captionEl = '#LM-' + file.lastModified + ' .caption';
            queueCounter += 1
            formData.append('pin_images[' + queueCounter + ']caption', $(captionEl).val());
        });
        myDropzone.on("success", function(file, responseText) {
            var imageIdList = $('#pin_pin_image_ids');
            // dynamically adding the save pin_image ids to the pin submission form
            imageIdList.val(imageIdList.val() + "," + responseText.id);
        });
    }
});