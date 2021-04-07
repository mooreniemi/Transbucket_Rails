// FIXME: this is the bare minimum to give some feedback to users
$(document).ready(function(){
  // on index page
  $(".flag-comment").each(function(){
    $(this).unbind().on('ajax:success', function(e, data, status, xhr){
      var commentId = $(this).data('comment-id');

      switch(data["status"]) {
        case "voted_down":
          // doesn't persist, but at least shows tapping it did something
          $(this).replaceWith('<i class="fa fa-exclamation-circle" aria-hidden="true"></i>');
          break;
        case "removed":
          // persists, item won't show up from server once in review
          $('.comment[data-comment-id="' + commentId + '"]').hide();
          break;
        default:
          console.log("unknown status reached while flagging " + commentId);
      }
    }).on('ajax:error',function(e, xhr, status, error){
      console.log("error = " + JSON.stringify(error));
    });
  });

  // on admin page
  $(".unflag-comment").each(function(){
    $(this).unbind().on('ajax:success', function(e, data, status, xhr){
      var commentId = $(this).data('comment-id');

      switch(data["status"]) {
        case "unflagged":
          // doesn't persist, but at least shows tapping it did something
          $(this).replaceWith('<i class="fa fa-check" aria-hidden="true"></i>');
          break;
        default:
          console.log("unknown status reached while unflagging " + commentId);
      }
    }).on('ajax:error',function(e, xhr, status, error){
      console.log("error = " + JSON.stringify(error));
    });
  });

  $(".delete-comment").each(function(){
    $(this).unbind().on('ajax:success', function(e, data, status, xhr){
      var commentId = $(this).data('comment-id');
      switch(data["status"]) {
        case "destroyed":
          // persists, item won't show up from server once in review
          $('.review-comment-row[data-comment-id="' + commentId + '"]').hide();
          break;
        default:
          console.log("unknown status reached while deleting " + commentId);
      }
    }).on('ajax:error',function(e, xhr, status, error){
      console.log("error = " + JSON.stringify(error));
    });
  });
});
