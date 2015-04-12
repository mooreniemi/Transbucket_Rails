$(document).ready(function() {
    // dropzone setup
    var container = document.querySelector('#dropper'),
        template = $('.hide').html(),
        queueCounter = -1;

    if (container && location.pathname.split("/")[2] != "new") {
        Dropzone.autoDiscover = false;
        var myDropzone = new Dropzone("#dropper", {
            url: '/pin_images',
            method: 'put',
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
                var submitButton = document.querySelector("#submit-all")
                myDropzone = this; // closure

                submitButton.addEventListener("click", function() {
                    myDropzone.processQueue(); // Tell Dropzone to process all queued files.
                });

                $.getJSON("pin_images.json", function(pinImages) {
                    if (pinImages) {
                        pinImages.forEach(function(pinImage) {
                            myDropzone.options.addedfile.call(myDropzone, pinImage);
                            $(pinImage.previewElement).prop('id', pinImage.id);
                            $(pinImage.previewElement).children('input').val(pinImage.caption);
                            myDropzone.options.thumbnail.call(myDropzone, pinImage, pinImage.url);
                        });
                    }
                    $(".dz-preview .caption").mouseout(function() {
                        var pinImageId = this.parentElement.parentElement.id;
                        $.ajax({
                            url: '/pin_images/' + pinImageId + '.json',
                            type: 'PUT',
                            data: {
                                id: pinImageId,
                                caption: this.value
                            },
                            success: function(response) {
                                console.log('yes')
                            }
                        });
                    });
                    return pinImages;
                });   
            }
        });
    }
});