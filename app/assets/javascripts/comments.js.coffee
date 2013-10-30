# comments.js.coffee
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
    $('<div class="">').html(xhr.responseText).hide().insertAfter($(this)).show('slow')

# Delete a comment
$(document)
  .on "ajax:beforeSend", ".comment", ->
    $(this).fadeTo('fast', 0.5)
  .on "ajax:success", ".comment", ->
    $(this).hide('fast')
  .on "ajax:error", ".comment", ->
    $(this).fadeTo('fast', 1)

