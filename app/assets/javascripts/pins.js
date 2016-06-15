$(document).ready(function() {
  var path = location.pathname.match(/pins\/(?:new|[^/]+\/edit)/);
  if (!!path) {
    // dropzone setup

    var isEditing = path[0] !== "pins/new",
      formSelector = ".form-inline",
      template = $('#preview-template').html(),
      fileCounter = 0,
      queueCounter = 0;

    $(".add-button").click(function() {
      var controls = $(this).parents('.controls'),
        add_form = controls.find(".add-form.hide");
      add_form.toggleClass('hide');
    });

    $(".controls .cancel").click(function() {
      var add_form = $(this).parents('.add-form');
      add_form.find("input[type=text]").val("");
      add_form.addClass('hide');
    });

    $("#pin_procedure_attributes_id").chosen({
      width: "80%",
      placeholder_text_single: "Procedures",
      max_selected_options: 1
    });

    $("#pin_surgeon_attributes_id").chosen({
      width: "80%",
      placeholder_text_single: "Surgeons",
      max_selected_options: 1
    });

    Dropzone.autoDiscover = false;

    if (!isEditing) $("#submit-all").prop("disabled", true);

    function onAddedPreview() {
      $('.dz-preview').off('click');
      $('.dz-preview').click(function (event) {
        event.stopPropagation();
      });
    }

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
      onAddedPreview();
    });

    myDropzone.on("removedfile", function(file) {
      if ($(".dz-preview:visible").length === 0) {
        $(".dz-message").show();
        $('#submit-all').prop("disabled", true);
      }

      clearError(file.index);

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

    function clearError(fileIndex) {
      $("#error-file-" + fileIndex).remove();
      updateErrorCount();
    }

    function updateErrorCount() {
      var errorBlock = $("#error_explanation"),
          errorCount = $("#error_explanation li").length,
          fileErrorCount = $("#error_explanation li.error-file").length,
          errorCountStr = errorCount == 1 ? "1 error" : errorCount + " errors";

      if (errorCount == 0) {
        errorBlock.addClass("hide");
      } else {
        errorBlock.find("h2").remove();
        errorBlock.prepend($("<h2>" + errorCountStr + " prohibited this pin from being saved:</h2>"));
        errorBlock.removeClass("hide");
      }

      $("#submit-all").prop("disabled", (fileErrorCount > 0));
   }

    function errorsCallback(file, errorMessage) {
      var fromRails = Array.isArray(errorMessage);

      if (fromRails) {
        errorMessage.forEach(function(error) {
          $("#error_explanation ul").append($("<li>" + error + "</li>"));
        });
      }

      updateErrorCount();
    }

    myDropzone.on("error", function(file, errorMessage) {
      $("#error_explanation ul").append($("<li class='error-file' id='error-file-" + file.index + "'>" + errorMessage + "</li>"));
    });

    myDropzone.on("errormultiple", errorsCallback);

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

          onAddedPreview();
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
