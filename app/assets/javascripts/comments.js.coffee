# Create a comment
$(document)
  .on "ajax:beforeSend", "#create_comment_form", (evt, xhr, settings) ->
    $(this).find('textarea')
      .addClass('uneditable-input')
      .attr('disabled', 'disabled');
  .on "ajax:success", "#create_comment_form", (evt, data, status, xhr) ->
    $(this).find('textarea')
      .removeClass('uneditable-input')
      .removeAttr('disabled', 'disabled')
      .val('');
    $($.parseHTML(xhr.responseText)).hide().insertAfter($(this)).show('slow')
    $(this).hide()

# Delete a comment
$(document)
  .on "ajax:beforeSend", ".close", (evt, xhr) ->
    $(this.parentElement.parentElement).fadeTo('fast', 0.5)
  .on "ajax:success", ".close", (evt, xhr) ->
    $(this.parentElement.parentElement).hide('fast')
  .on "ajax:error", ".close", ->
    $(this.parentElement.parentElement).fadeTo('fast', 1)
