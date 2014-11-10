$(document).ready(function() {
    $("#clear-filter").click(function() {
        $("#filter_dropdown").multiSelect('deselect_all')
    });
    $("#scope").multiSelect({
        selectableHeader: "General categories",
        selectionHeader: "Selected general"
    });

    $("#surgeon").multiSelect({
        selectableHeader: "Surgeons",
        selectionHeader: "Selected surgeons"
    });

    $("#procedure").multiSelect({
        selectableHeader: "Procedures",
        selectionHeader: "Selected procedures"
    });

    // used to explain flagging
    $('.label-with-popover').popover();
});