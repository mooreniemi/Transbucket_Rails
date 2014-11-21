// TODO switch to https://blog.twitter.com/2013/twitter-typeaheadjs-you-autocomplete-me

$(document).ready(function() {
    $(function() {
        var realTime = '/search_terms.json'
        $("#query").autocomplete({
            source: realTime,
            minLength: 3,
            open: function() {
                setTimeout(function() {
                    $('.ui-autocomplete').css('z-index', 99999999999999);
                }, 0);
            }
        });
    });
});