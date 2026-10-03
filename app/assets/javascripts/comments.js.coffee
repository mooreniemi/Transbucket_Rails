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
      .val('')
      .trigger('input')
      .blur();
    # The box under the thread folds back to one line once it is empty again.
    $(this).removeClass('is-open') if $(this).closest('.comment-composer').length
    comment = $($.parseHTML(xhr.responseText)).hide()
    list = $(this).closest('.comment-composer').siblings('.comment-list')
    if list.length
      # The always-open box under a pin's comments: the new comment joins the
      # end of the list and the box stays, empty, for the next one.
      list.append(comment)
      window.formatPinAges?(comment)
      comment.show('slow')
    else
      # A reply form (or a procedure page's "add thread" form): it is done.
      comment.insertAfter($(this)).show('slow')
      window.formatPinAges?(comment)
      $(this).hide()

# Delete a comment
$(document)
  .on "ajax:beforeSend", ".close", (evt, xhr) ->
    $(this).closest('.comment').fadeTo('fast', 0.5)
  .on "ajax:success", ".close", (evt, xhr) ->
    $(this).closest('.comment').hide('fast')
  .on "ajax:error", ".close", ->
    $(this).closest('.comment').fadeTo('fast', 1)
