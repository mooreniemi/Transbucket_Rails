$(document).ready(function() {
  // dropzone setup
  var container = document.querySelector('#dropper'),
  template = $('#preview-template').html(),
  queueCounter = -1;
  // TODO this should work but maybe load order prevents?
  Dropzone.autoDiscover = false;
  if (container && !!location.pathname.match(/pins\/new/)) {
    $("#submit-all").prop("disabled", true);
    var myDropzone = new Dropzone("#new_pin", {
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
    });

    myDropzone.on("addedfile", function(file) {
      $(".dz-message:visible").hide();
      $(".dz-preview:last-child").attr('id', "LM-" + file.lastModified);
      $('#submit-all').prop("disabled", false);
    });

    myDropzone.on("removedfile", function() {
      if ($(".dz-preview:visible").length == 0) {
        $(".dz-message").show();
        $('#submit-all').prop("disabled", true);
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
  }
});
