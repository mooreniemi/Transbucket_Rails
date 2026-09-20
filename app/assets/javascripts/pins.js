$(document).ready(function() {
  var path = location.pathname.match(/pins\/(?:new|[^/]+\/edit)/);
  if (!!path) {
    // dropzone setup

    var complicationInput = $('#pin_complication_list');
    var complicationTags = $('#pin-complication-tags');
    var complicationToggles = $('input[data-complications-toggle]');
    function updateComplicationVisibility() {
      var hasComplications = complicationToggles.filter(':checked').val() === '1';
      complicationTags.toggleClass('hide', !hasComplications);
      complicationInput.prop('disabled', !hasComplications);
      complicationInput.siblings('.complication-tag-input').prop('disabled', !hasComplications);
      complicationTags.attr('aria-hidden', hasComplications ? 'false' : 'true');
    }
    complicationToggles.on('change', updateComplicationVisibility);
    updateComplicationVisibility();

    if (complicationInput.length && $('#pin_complication_input').length) {
      var complicationTextInput = $('#pin_complication_input'),
          complicationChips = $('#pin-complication-chips');
      var originalComplications = complicationInput.data('complication-original'),
          complicationValidation = complicationInput.data('complication-validation');

      function currentTags() {
        return complicationInput.val().split(',').map(function(tag) {
          return $.trim(tag);
        }).filter(Boolean);
      }

      function renderComplicationChips() {
        complicationChips.empty();
        currentTags().forEach(function(tag, index) {
          var chip = $('<span class="complication-chip">').text(tag),
              remove = $('<button type="button" class="complication-chip-remove" aria-label="Remove ' + $('<div>').text(tag).html() + '">').text('×');
          remove.on('click', function() {
            var tags = currentTags();
            tags.splice(index, 1);
            complicationInput.val(tags.join(', ')).trigger('input');
            renderComplicationChips();
          });
          chip.append(remove).appendTo(complicationChips);
        });
      }

      function commitComplicationText() {
        var pieces = complicationTextInput.val().split(','),
            tags = currentTags(),
            remainder = pieces.pop(),
            invalid = [];
        pieces.forEach(function(piece) {
          var tag = $.trim(piece);
          if (!tag) return;
          if (tag.length > 80 || /[\r\n]/.test(tag)) {
            invalid.push(tag);
          } else if (tags.every(function(existing) { return existing.toLowerCase() !== tag.toLowerCase(); })) {
            tags.push(tag);
          }
        });
        complicationInput.val(tags.join(', ')).trigger('input');
        complicationTextInput.val(invalid.concat(remainder || '').filter(Boolean).join(', '));
        renderComplicationChips();
      }

      function validateComplications() {
        var value = complicationInput.val() + (complicationTextInput.val() ? ', ' + complicationTextInput.val() : ''),
            tags = value.split(',').map(function(tag) { return $.trim(tag); }).filter(Boolean),
            valid = value === originalComplications || (!/[\r\n]/.test(value) && tags.every(function(tag) {
              return tag.length <= 80;
            }));

        complicationTextInput[0].setCustomValidity(valid ? '' : complicationValidation);
      }

      complicationTextInput.on('input', function() {
        if (complicationTextInput.val().indexOf(',') !== -1) commitComplicationText();
        validateComplications();
      });
      complicationTextInput.on('keydown', function(event) {
        if (event.key === 'Enter') {
          event.preventDefault();
          commitComplicationText();
          validateComplications();
        }
      });
      complicationTextInput.closest('form').on('submit', function() {
        commitComplicationText();
        validateComplications();
      });
      complicationInput.on('input change', function() {
        renderComplicationChips();
        validateComplications();
      });
      complicationTextInput.autocomplete({
        source: complicationTextInput.data('complication-suggestions-url'),
        minLength: 2,
        select: function(event, ui) {
          event.preventDefault();
          complicationTextInput.val(ui.item.value + ',');
          commitComplicationText();
          validateComplications();
        }
      });
      complicationInput.val(originalComplications || '');
      renderComplicationChips();
      validateComplications();
    }

    var isEditing = path[0] !== "pins/new",
        formSelector = ".form-inline",
        template = $('#preview-template').html(),
        fileCounter = 0,
        queueCounter = 0,
        preprocessingUploads = 0;

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

    function normalizedEntityName(value) {
      return (value || '').toString().toLowerCase().normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, ' ').trim();
    }

    function editDistance(left, right) {
      var previous = [], current, i, j, cost;
      for (j = 0; j <= right.length; j++) previous[j] = j;
      for (i = 1; i <= left.length; i++) {
        current = [i];
        for (j = 1; j <= right.length; j++) {
          cost = left.charAt(i - 1) === right.charAt(j - 1) ? 0 : 1;
          current[j] = Math.min(current[j - 1] + 1, previous[j] + 1, previous[j - 1] + cost);
        }
        previous = current;
      }
      return previous[right.length];
    }

    function bindEntitySuggestion(inputSelector, selectSelector, suggestionSelector, containerSelector) {
      var input = $(inputSelector), select = $(selectSelector), suggestion = $(suggestionSelector);
      if (!input.length || !select.length || !suggestion.length) return;

      function renderSuggestion() {
        var typed = normalizedEntityName(input.val()), best = null;
        suggestion.empty().addClass('hide');
        if (typed.length < 4) return;

        select.find('option[value]').each(function() {
          var option = $(this), candidate = normalizedEntityName(option.text()), distance;
          if (!candidate || candidate === typed) return;
          distance = editDistance(typed, candidate);
          if (candidate.indexOf(typed) === 0) distance -= 2;
          if (candidate.indexOf(typed) !== -1) distance -= 1;
          if (!best || distance < best.distance) best = { distance: distance, option: option };
        });

        if (!best || best.distance > Math.max(2, Math.floor(typed.length * 0.35))) return;
        $('<span>').text(suggestion.data('label') + ' ' + best.option.text() + ' ').appendTo(suggestion);
        $('<button type="button" class="btn btn-link btn-sm">').text(suggestion.data('use')).appendTo(suggestion)
          .on('click', function() {
            select.val(best.option.val()).trigger('chosen:updated').trigger('change');
            input.val('');
            $(containerSelector).addClass('hide');
            suggestion.empty().addClass('hide');
          });
        suggestion.removeClass('hide');
      }

      input.on('input blur', renderSuggestion);
    }

    bindEntitySuggestion('#pin_surgeon_attributes_last_name', '#pin_surgeon_attributes_id', '#surgeon-suggestion', '#surgeon_container');
    bindEntitySuggestion('#pin_procedure_attributes_name', '#pin_procedure_attributes_id', '#procedure-suggestion', '#procedure_container');

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

    // Phone photos are commonly several megabytes, while PinImage keeps a
    // deliberately small storage limit. Resize JPEG and PNG photos in the
    // browser before Dropzone sees them, so users don't need a separate image
    // editor just to submit a pin. GIFs are left untouched to preserve their
    // animation.
    function resizePhotoForUpload(file, maxBytes, callback) {
      var supportedType = /^image\/(jpe?g|png)$/i.test(file.type);

      if (file.size <= maxBytes || !supportedType || !window.FileReader || !window.Blob || !HTMLCanvasElement.prototype.toBlob) {
        callback(file);
        return;
      }

      var reader = new FileReader(), image = new Image();
      reader.onerror = function() { callback(file); };
      image.onerror = function() { callback(file); };
      reader.onload = function(event) {
        image.onload = function() {
          var maxDimension = 1600,
              scale = Math.min(1, maxDimension / Math.max(image.width, image.height)),
              width = Math.max(1, Math.round(image.width * scale)),
              height = Math.max(1, Math.round(image.height * scale)),
              canvas = document.createElement('canvas'),
              attempts = 0;

          function makeUpload(blob) {
            var name = file.name.replace(/\.[^.]+$/, '') + '.jpg';
            try {
              return new File([blob], name, { type: 'image/jpeg' });
            } catch (e) {
              blob.name = name;
              return blob;
            }
          }

          function compress() {
            var quality = Math.max(0.5, 0.9 - (attempts * 0.1));
            canvas.width = width;
            canvas.height = height;
            var context = canvas.getContext('2d');
            context.fillStyle = '#ffffff';
            context.fillRect(0, 0, width, height);
            context.drawImage(image, 0, 0, width, height);

            canvas.toBlob(function(blob) {
              if (!blob) {
                callback(file);
              } else if (blob.size <= maxBytes) {
                callback(makeUpload(blob));
              } else if (attempts < 5) {
                attempts += 1;
                compress();
              } else if (width > 640 && height > 640) {
                attempts = 0;
                width = Math.round(width * 0.8);
                height = Math.round(height * 0.8);
                compress();
              } else {
                callback(file);
              }
            }, 'image/jpeg', quality);
          }

          compress();
        };
        image.src = event.target.result;
      };
      reader.readAsDataURL(file);
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

    // This version of Dropzone predates its transformFile hook. Wrapping
    // addFile keeps the existing queue and preview behaviour while handing it
    // the compressed File rather than the original camera image.
    var addFile = myDropzone.addFile;
    myDropzone.addFile = function(file) {
      var targetBytes = parseInt($('#dropper').data('upload-size-limit'), 10) - (64 * 1024);
      preprocessingUploads += 1;
      $('#submit-all').prop('disabled', true);
      resizePhotoForUpload(file, targetBytes, function(resizedFile) {
        preprocessingUploads -= 1;
        addFile.call(myDropzone, resizedFile);
      });
    };

    myDropzone.on("addedfile", function(file) {
      $(".dz-message:visible").hide();
      file.index = fileCounter++;
      $(".dz-preview:last-child").attr('id', "file-" + file.index);
      if (preprocessingUploads === 0) $('#submit-all').prop("disabled", false);
      onAddedPreview();
    });

    myDropzone.on("removedfile", function(file) {
      if ($(".dz-preview:visible").length === 0) {
        $(".dz-message").show();
        $('#submit-all').prop("disabled", true);
      }

      clearError(file.index);

      if (isEditing && file.id) {
        $.ajax({
          url: "pin_images/" + file.id,
          type: 'DELETE'
        });
      }
    });

    myDropzone.on("sending", function(file, xhr, formData) {
      var captionEl = '#file-' + file.index + ' .pin-image-caption';
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
        window.location.href = "/" + document.documentElement.lang + "/pins/" + pinId;
      } else {
        window.location.href = "/" + document.documentElement.lang + "/pins/" + responseText.id;
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
            $(pinImage.previewElement).find('input.pin-image-caption').val(pinImage.caption);
            myDropzone.options.thumbnail.call(myDropzone, pinImage, pinImage.url);
          });

          onAddedPreview();
        }

        // allow caption updates independently
        $("input.pin-image-caption").on("change", function(e) {
          var pinImageId = $(this).parents('.dz-preview').data('pin-image-id'),
              input = $(this),
              captionText = input.val();

          if (pinImageId) {
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
          }
       });
        return pinImages;
      });
    }
  }
});
