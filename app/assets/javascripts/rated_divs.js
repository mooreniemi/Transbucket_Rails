$(document).ready(function() {
    function setupRating(selector) {
        var field = $(selector),
            captions = field.data('rating-captions'),
            hint = field.siblings('.rating-hint'),
            help = field.data('rating-help');

        if (typeof captions === 'string') captions = JSON.parse(captions);

        field.rating({
        size: 'xs',
        step: 1,
        showCaption: false,
        showClear: false,
        starCaptions: captions
        });

        field.on('rating.hover', function(event, value, caption) {
            hint.text(captions[value] || $('<div>').html(caption).text());
        }).on('rating.hoverleave rating.change', function() {
            hint.text(help);
        });
    }

    setupRating("#pin_sensation");
    setupRating("#pin_satisfaction");
});
