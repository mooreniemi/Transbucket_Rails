$(document).ready(function() {
  return $("#new_surgeon").on("ajax:success", function(e, data, status, xhr) {
    return $("#pin_surgeon_id").trigger("chosen:updated");
  }).on("ajax:error", function(e, xhr, status, error) {
    console.log("error")
  });
});
