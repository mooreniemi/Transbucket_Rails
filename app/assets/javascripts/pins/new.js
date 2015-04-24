$(document).ready(function() {
    // dropzone setup
    var container = document.querySelector('#dropper'),
        template = $('.hide').html(),
        queueCounter = -1;
    // TODO this should work but maybe load order prevents?
    Dropzone.autoDiscover = false;
    if (container && !!location.pathname.match(/pins\/new/)) {
        var myDropzone = new Dropzone("#dropper", {
            url: '/pin_images',
            method: 'post',
            maxFilesize: 1,
            previewTemplate: template,
            paramName: function(n) {
                return "pin_images[" + n + "][photo]"
            },
            addRemoveLinks: true,
            headers: {
                'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
            },
            autoProcessQueue: false,
            uploadMultiple: true,
            parallelUploads: 100,
            maxFiles: 10,
            init: function() {
                var submitButton = document.querySelector("#submit-all");
                myDropzone = this; // closure

                submitButton.addEventListener("click", function() {
                    myDropzone.processQueue(); // Tell Dropzone to process all queued files.
                });
            }
        });
        myDropzone.on("addedfile", function(file) {
            $(".dz-preview:last-child").attr('id', "LM-" + file.lastModified);
            $('#submit-all').prop("disabled", false);
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