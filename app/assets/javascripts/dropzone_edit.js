$(document).ready(function() {
    // dropzone setup
    var container = document.querySelector('#dropper'),
        template = $('.hide').html(),
        queueCounter = -1;

    if (container) {
        Dropzone.autoDiscover = false;
        var myDropzone = new Dropzone("#dropper", {
            url: function(pin){
                console.log(pin)
                return '/pin_images/' + pinId + '.json'
            },
            method: 'put',
            maxFilesize: 1,
            previewTemplate: template,
            paramName: function(n) {
                return "pin_images[" + n + "][photo]"
            },
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
        });
        myDropzone.on("sending", function(file, xhr, formData) {
            var captionEl = '#' + file.id + ' .caption';
            queueCounter += 1
            formData.append('pin_images[' + queueCounter + ']caption', $(captionEl).val());
        });
    }
});