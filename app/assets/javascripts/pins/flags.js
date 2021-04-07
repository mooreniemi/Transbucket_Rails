// FIXME: this is the bare minimum to give some feedback to users
$(document).ready(function(){
  // on index page
  $(".flag-pin").each(function(){
    $(this).unbind().on('ajax:success', function(e, data, status, xhr){
      var pinId = $(this).data('pin-id');

      switch(data["status"]) {
        case "voted_down":
          // doesn't persist, but at least shows tapping it did something
          $(this).replaceWith('<i class="fa fa-exclamation-circle" aria-hidden="true"></i>');
          break;
        case "removed":
          // persists, item won't show up from server once in review
          $('.item[data-pin-id="' + pinId + '"]').hide();
          break;
        default:
          console.log("unknown status reached while flagging " + pinId);
      }
    }).on('ajax:error',function(e, xhr, status, error){
      console.log("error = " + JSON.stringify(error));
    });
  });

  // on admin page
  $(".unflag-pin").each(function(){
    $(this).unbind().on('ajax:success', function(e, data, status, xhr){
      var pinId = $(this).data('pin-id');

      switch(data["status"]) {
        case "unflagged":
          // doesn't persist, but at least shows tapping it did something
          $(this).replaceWith('<i class="fa fa-check" aria-hidden="true"></i>');
          break;
        default:
          console.log("unknown status reached while unflagging " + pinId);
      }
    }).on('ajax:error',function(e, xhr, status, error){
      console.log("error = " + JSON.stringify(error));
    });
  });

  $(".delete-pin").each(function(){
    $(this).unbind().on('ajax:success', function(e, data, status, xhr){
      var pinId = $(this).data('pin-id');

      switch(data["status"]) {
        case "destroyed":
          // persists, item won't show up from server once in review
          $('.review-pin-row[data-pin-id="' + pinId + '"]').hide();
          break;
        default:
          console.log("unknown status reached while deleting " + pinId);
      }
    }).on('ajax:error',function(e, xhr, status, error){
      console.log("error = " + JSON.stringify(error));
    });
  });
});
