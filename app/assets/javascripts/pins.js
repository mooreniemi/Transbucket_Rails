$(document).ready(function() {
    $("#clear-filter").click(function() {
        $("#filter_dropdown select").val([]);
        $("#filter_dropdown select").trigger('chosen:updated');
    });

    $("#scope").chosen({ width:"100%", placeholder_text_multiple: "General tags" });

    $("#procedure").chosen({ width:"100%", placeholder_text_multiple: "Procedures" });

    $("#surgeon").chosen({ width:"100%", placeholder_text_multiple: "Surgeons" });

    $("#pin_procedure_id").chosen({ width:"80%", placeholder_text_single: "Procedures", max_selected_options: 1 });

    $("#pin_surgeon_id").chosen({ width:"80%", placeholder_text_single: "Surgeons", max_selected_options: 1 });

    // used to explain flagging
    $('.label-with-popover').popover();
});