$(document).ready(function() {
  // dropzone setup
  var container = document.querySelector('#dropper'),
  template = $('.hide').html(),
  queueCounter = -1;

  Dropzone.autoDiscover = false;
  if (container && !location.pathname.match(/pins\/new/)) {
    var myDropzone = new Dropzone("#dropper", {
      url: '/pin_images',
      method: 'put',
      maxFilesize: 1,
      previewTemplate: template,
      paramName: function(n) {
        return "pin_images[" + n + "][photo]";
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

        myDropzone.on("addedfile", function(file) {
          $('#submit-all').prop("disabled", false);
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
          // allow caption updates independently
          $(".save-caption").on("click", function(e) {
            var pinImageId = this.parentElement.id,
            input = $(this.parentElement).find("input:first"),
            captionText = input.val(),
            target = $(this);
            $.ajax({
              url: '/pin_images/' + pinImageId + '.json',
              type: 'PUT',
              data: {
                id: pinImageId,
                caption: captionText
              },
              success: function() {
                input.css('border-color', 'green');
                target.append('✔');
              }
            });
          });
          return pinImages;
        });
      }
    });
  }
});