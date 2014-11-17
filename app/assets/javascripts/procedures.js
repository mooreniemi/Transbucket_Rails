$(document).ready(function() {
  return $("#new_procedure").on("ajax:success", function(e, data, status, xhr) {
    return $("#pin_procedure_id").trigger("chosen:updated");
  }).on("ajax:error", function(e, xhr, status, error) {
    console.log("error")
  });
});
