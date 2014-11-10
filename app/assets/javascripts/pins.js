$(document).ready(function() {
    $("#scope").multiSelect({
        afterSelect: function() {
            $("#submit-filter").trigger("click");
        },
        selectableHeader: "General categories",
        selectionHeader: "Selected general"
    });

    $("#surgeon").multiSelect({
        afterSelect: function() {
            $("#submit-filter").trigger("click");
        },
        selectableHeader: "Surgeons",
        selectionHeader: "Selected surgeons"
    });

    $("#procedure").multiSelect({
        afterSelect: function() {
            $("#submit-filter").trigger("click");
        },
        selectableHeader: "Procedures",
        selectionHeader: "Selected procedures"
    });

    // used to explain flagging
    $('.label-with-popover').popover();
});