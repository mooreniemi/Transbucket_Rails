$(document).ready(function() {
  var path = location.pathname.match(/pins\/(?:new|[^/]+\/edit)/);
  if (!!path) {
    // dropzone setup

    var isEditing = path[0] !== "pins/new",
        formSelector = ".form-inline",
        template = $('#preview-template').html(),
        fileCounter = 0,
        queueCounter = 0;

    Dropzone.autoDiscover = false;

    if (!isEditing) $("#submit-all").prop("disabled", true);

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
          if (myDropzone.getQueuedFiles().length > 0) {
            event.preventDefault();
            myDropzone.processQueue(); // Tell Dropzone to process all queued files.
          }
        });
      }
    };

    var myDropzone = new Dropzone(formSelector, dropzoneOptions);

    myDropzone.on("addedfile", function(file) {
      $(".dz-message:visible").hide();
      file.index = fileCounter++;
      $(".dz-preview:last-child").attr('id', "file-" + file.index);
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
      var captionEl = '#file-' + file.index + ' .caption';
      formData.append('pin_images[' + (queueCounter++) + ']caption', $(captionEl).val());
    });

    myDropzone.on("sendingmultiple", function(files, xhr, formData) {
      tinyMCE.triggerSave();

      var existingIds = $("[data-pin-image-id]:not([data-pin-image-id=''])").map(function() {
        return $(this).data('pin-image-id');
      }).get();

      existingIds.forEach(function(d,i) {
        formData.append("pin_images[" + (i+files.length) + "][id]", d);
      });
    });

    myDropzone.on("successmultiple", function(file, responseText) {
      if (isEditing) {
        var pinId = $(formSelector).data("pin-id");
        window.location.href = "/pins/" + pinId;
      } else {
        window.location.href = "/pins/" + responseText.id;
      }
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
            $(pinImage.previewElement).attr('data-pin-image-id', pinImage.id);
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