# comments.js.coffee
    jQuery ->
      # Create a comment
      $(".comment-form")
        .on "ajax:beforeSend", (evt, xhr, settings) ->
          $(this).find('textarea')
            .addClass('uneditable-input')
            .attr('disabled', 'disabled');
        .on "ajax:success", (evt, data, status, xhr) ->
          $(this).find('textarea')
            .removeClass('uneditable-input')
            .removeAttr('disabled', 'disabled')
            .val('');
          $(xhr.responseText).hide().insertAfter($(this)).show('slow')

          # Delete a comment
      $(document)
        .on "ajax:beforeSend", ".comment", ->
          $(this).fadeTo('fast', 0.5)
        .on "ajax:success", ".comment", ->
          $(this).hide('fast')
        .on "ajax:error", ".comment", ->
          $(this).fadeTo('fast', 1)