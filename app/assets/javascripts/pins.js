$(document).ready(function() {
  var path = location.pathname.match(/pins\/(?:new|[^/]+\/edit)/);
  if (!!path) {
    // dropzone setup

    var isEditing = path[0] !== "pins/new",
        template = $('#preview-template').html(),
        queueCounter = -1;

    Dropzone.autoDiscover = false;
    $("#submit-all").prop("disabled", true);

    var dropzoneOptions = {
      previewsContainer: "#dropper",
      clickable: "#dropper",
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

        submitButton.addEventListener("click", function(event) {
          event.preventDefault();
          myDropzone.processQueue(); // Tell Dropzone to process all queued files.
        });
      }
    };

    var myDropzone = new Dropzone(".form-inline", dropzoneOptions);

    myDropzone.on("addedfile", function(file) {
      $(".dz-message:visible").hide();
      $(".dz-preview:last-child").attr('id', "LM-" + file.lastModified);
      $('#submit-all').prop("disabled", false);
    });

    myDropzone.on("removedfile", function(file) {
      if ($(".dz-preview:visible").length == 0) {
        $(".dz-message").show();
        $('#submit-all').prop("disabled", true);
      }

      if (isEditing) {
        $.ajax({
          url: "pin_images/" + file.id,
          type: 'DELETE'
        });
      }
    });

    myDropzone.on("sending", function(file, xhr, formData) {
      var captionEl = '#LM-' + file.lastModified + ' .caption';
      queueCounter += 1;
      formData.append('pin_images[' + queueCounter + ']caption', $(captionEl).val());
    });

    myDropzone.on("sendingmultiple", function() {
      tinyMCE.triggerSave();
    });

    myDropzone.on("successmultiple", function(file, responseText) {
      window.location.href = "/pins/" + responseText.id;
    });

    myDropzone.on("errormultiple", function(file, errorMessage) {
      $("#error_explanation ul").empty();
      errorMessage.forEach(function(error) {
        $("#error_explanation ul").append("<li>" + error + "</li>");
      });
    });

    if (isEditing) {
      $(".dz-message:visible").hide();

      $.getJSON("pin_images.json", function(pinImages) {
        if (pinImages) {
          pinImages.forEach(function(pinImage) {
            myDropzone.options.addedfile.call(myDropzone, pinImage);
            $(pinImage.previewElement).data('pin-image-id', pinImage.id);
            $(pinImage.previewElement).children('input').val(pinImage.caption);
            myDropzone.options.thumbnail.call(myDropzone, pinImage, pinImage.url);
          });
        }

        // allow caption updates independently
        $("input.caption").on("change", function(e) {
          var pinImageId = $(this.parentElement).data('pin-image-id'),
              input = $(this),
              captionText = input.val();

          $.ajax({
            url: '/pin_images/' + pinImageId + '.json',
            type: 'PUT',
            data: {
              id: pinImageId,
              caption: captionText
            },
            success: function() {
              input.css('border-color', 'green');
              input.append('✔');
            }
          });
        });
        return pinImages;
      });
    }
  }
});
